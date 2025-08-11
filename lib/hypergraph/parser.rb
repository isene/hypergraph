#!/usr/bin/env ruby
# encoding: utf-8
#
# HyperList Parser Module
# Handles parsing of HyperList syntax into structured data

module HyperGraph
  class Parser
    attr_reader :lines, :errors, :warnings

    def initialize(content)
      @content = content
      @lines = []
      @errors = []
      @warnings = []
    end

    def parse
      raw_lines = @content.split("\n")
      @lines = []
      
      raw_lines.each_with_index do |line, index|
        parsed_line = parse_line(line, index + 1)
        @lines << parsed_line if parsed_line
      end

      validate_structure
      process_substitutions
      @lines
    end

    private

    def parse_line(line, line_number)
      return nil if line.strip.empty?

      item = {
        line_number: line_number,
        raw: line,
        level: line.count("\t"),
        text: line.gsub(/\t/, '').strip,
        type: nil,
        qualifiers: [],
        operators: [],
        properties: {},
        references: { hard: [], soft: [] },
        tags: [],
        substitutions: [],
        children: []
      }

      # Parse Type (S: or T: or | or /)
      if item[:text] =~ /^(S:|T:|\||\/)\s*/
        item[:type] = case $1
                      when 'S:', '|' then :state
                      when 'T:', '/' then :transition
                      end
        item[:text] = item[:text].sub(/^(S:|T:|\||\/)\s*/, '')
      end

      # Parse Qualifiers [...]
      item[:text].scan(/\[([^\]]+)\]/).each do |match|
        qualifier = parse_qualifier(match[0])
        item[:qualifiers] << qualifier
      end

      # Parse Operators (CAPITALS:)
      if item[:text] =~ /^([A-Z]+):\s*/
        item[:operators] << $1
        item[:text] = item[:text].sub(/^[A-Z]+:\s*/, '')
      end

      # Parse Properties (key = value:)
      item[:text].scan(/(\w+)\s*=\s*([^:]+):/).each do |key, value|
        item[:properties][key] = value.strip
      end

      # Parse Substitutions {var}
      item[:text].scan(/\{([^}]+)\}/).each do |match|
        item[:substitutions] << match[0]
      end

      # Parse References <...>
      # Hard references
      item[:text].scan(/(?<!\()<([^>]+)>(?!\))/).each do |match|
        item[:references][:hard] << match[0]
      end
      
      # Soft references
      item[:text].scan(/\(<([^>]+)>\)/).each do |match|
        item[:references][:soft] << match[0]
      end

      # Parse Tags #tag
      item[:text].scan(/#(\w+)/).each do |match|
        item[:tags] << match[0]
      end

      # Clean text for display
      display_text = item[:text].dup
      display_text.gsub!(/\[([^\]]+)\]/, '') # Remove qualifiers
      display_text.gsub!(/\{([^}]+)\}/, '\1') # Replace substitutions
      display_text.gsub!(/<([^>]+)>/, '') # Remove references
      display_text.gsub!(/\(<[^>]+>\)/, '') # Remove soft references
      display_text.gsub!(/#\w+/, '') # Remove tags
      display_text.gsub!(/(\w+)\s*=\s*([^:]+):/, '') # Remove properties
      display_text.gsub!(/\(color=[^)]+\)/, '') # Remove color properties
      display_text.gsub!(/\(fillcolor=[^)]+\)/, '') # Remove fillcolor properties
      display_text.gsub!(/\(fontcolor=[^)]+\)/, '') # Remove fontcolor properties
      
      # Special handling for literal block markers
      if display_text.strip == '\\'
        display_text = '-----'
      end
      
      item[:display_text] = display_text.strip

      # Extract color properties (special handling for backwards compatibility)
      if item[:text] =~ /\(color=([^)]+)\)/
        item[:properties]['color'] = $1
      end
      if item[:text] =~ /\(fillcolor=([^)]+)\)/
        item[:properties]['fillcolor'] = $1
      end
      if item[:text] =~ /\(fontcolor=([^)]+)\)/
        item[:properties]['fontcolor'] = $1
      end

      item
    end

    def parse_qualifier(qualifier_text)
      qualifier = {
        raw: qualifier_text,
        type: nil,
        value: nil,
        conditions: []
      }

      # Check for special qualifiers
      case qualifier_text
      when '?'
        qualifier[:type] = :optional
      when '_'
        qualifier[:type] = :unchecked
      when 'x'
        qualifier[:type] = :checked
      when 'O'
        qualifier[:type] = :in_progress
      when /^\d+$/
        qualifier[:type] = :count
        qualifier[:value] = qualifier_text.to_i
      when /^(\d+)\.\.(\d+)$/
        qualifier[:type] = :range
        qualifier[:value] = { min: $1.to_i, max: $2.to_i }
      when /^(\d+)\+$/
        qualifier[:type] = :minimum
        qualifier[:value] = $1.to_i
      when /^<(\d+)$/
        qualifier[:type] = :less_than
        qualifier[:value] = $1.to_i
      when /^>(\d+)$/
        qualifier[:type] = :greater_than
        qualifier[:value] = $1.to_i
      when /^\d{4}(-\d{2}(-\d{2})?)?/
        qualifier[:type] = :timestamp
        qualifier[:value] = qualifier_text
      else
        qualifier[:type] = :condition
        qualifier[:value] = qualifier_text
      end

      qualifier
    end

    def validate_structure
      # Check for proper indentation
      @lines.each_with_index do |line, index|
        if index > 0
          prev_level = @lines[index - 1][:level]
          curr_level = line[:level]
          
          if curr_level > prev_level + 1
            @errors << {
              line: line[:line_number],
              message: "Invalid indentation jump (from level #{prev_level} to #{curr_level})"
            }
          end
        end
      end

      # Check for unmatched references
      all_descriptions = @lines.map { |l| l[:display_text] }
      
      @lines.each do |line|
        line[:references][:hard].each do |ref|
          unless reference_exists?(ref, all_descriptions)
            @warnings << {
              line: line[:line_number],
              message: "Hard reference '#{ref}' not found"
            }
          end
        end
      end

      # Check for operator usage
      @lines.each do |line|
        if line[:operators].include?('OR') || line[:operators].include?('AND')
          next_line = @lines[@lines.index(line) + 1]
          if next_line.nil? || next_line[:level] <= line[:level]
            @warnings << {
              line: line[:line_number],
              message: "Operator #{line[:operators].join(', ')} has no child items"
            }
          end
        end
      end
    end

    def reference_exists?(ref, descriptions)
      # Simple check - can be enhanced
      descriptions.any? { |desc| desc.include?(ref) }
    end

    def process_substitutions
      # Process substitutions in context
      substitution_values = {}
      
      @lines.each do |line|
        # Check if line defines substitution values
        if line[:qualifiers].any? { |q| q[:raw] =~ /(\w+)\s*=\s*(.+)/ }
          var_name = $1
          var_values = $2.split(',').map(&:strip)
          substitution_values[var_name] = var_values
        end

        # Replace substitutions in text
        line[:substitutions].each do |sub|
          if substitution_values[sub]
            # Mark for expansion in graph generation
            line[:expand_with] = substitution_values[sub]
          end
        end
      end
    end
  end
end