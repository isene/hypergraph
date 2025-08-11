#!/usr/bin/env ruby
# encoding: utf-8
#
# Graph Generator Module
# Converts parsed HyperList data into DOT format for Graphviz

module HyperGraph
  class GraphGenerator
    attr_reader :dot_output

    def initialize(parsed_lines, options = {})
      @lines = parsed_lines
      @options = {
        type: 'state',
        direction: 'TB',
        arrows: true,
        spline: 'spline',
        theme: 'default',
        sep: nil
      }.merge(options)
      
      @dot_output = ""
      @node_index = 0
      @themes = load_themes
    end

    def generate
      build_header
      build_nodes
      build_edges
      build_footer
      @dot_output
    end

    private

    def load_themes
      {
        default: {
          node_color: 'black',
          edge_color: 'black',
          font: 'Helvetica',
          bgcolor: 'white'
        },
        business: {
          node_color: '#2c3e50',
          edge_color: '#34495e',
          font: 'Arial',
          bgcolor: '#ecf0f1',
          node_style: 'rounded,filled',
          node_fillcolor: '#3498db',
          node_fontcolor: 'white'
        },
        tech: {
          node_color: '#00ff00',
          edge_color: '#00aa00',
          font: 'Courier',
          bgcolor: 'black',
          node_fontcolor: '#00ff00'
        },
        pastel: {
          node_color: '#8b7d6b',
          edge_color: '#cdaa7d',
          font: 'Georgia',
          bgcolor: '#fff8dc',
          node_style: 'filled',
          node_fillcolor: '#ffe4b5'
        }
      }
    end

    def current_theme
      @themes[@options[:theme].to_sym] || @themes[:default]
    end

    def build_header
      theme = current_theme
      
      @dot_output << "digraph HyperGraph {\n"
      @dot_output << "rankdir=#{@options[:direction]}\n"
      @dot_output << "splines=#{@options[:spline]}\n"
      @dot_output << "bgcolor=\"#{theme[:bgcolor]}\"\n" if theme[:bgcolor]
      
      if @options[:sep]
        @dot_output << "nodesep=#{@options[:sep]}\n"
        @dot_output << "ranksep=#{@options[:sep]}\n"
      end
      
      @dot_output << "overlap=false\n"
      @dot_output << "edge [fontsize=8 len=1"
      @dot_output << " color=\"#{theme[:edge_color]}\"" if theme[:edge_color]
      @dot_output << " dir=\"none\"" unless @options[:arrows]
      @dot_output << "]\n"
      
      @dot_output << "node ["
      @dot_output << "shape=#{@options[:type] == 'trans' ? 'box' : 'ellipse'}"
      @dot_output << " color=\"#{theme[:node_color]}\"" if theme[:node_color]
      @dot_output << " fontname=\"#{theme[:font]}\"" if theme[:font]
      @dot_output << " fontcolor=\"#{theme[:node_fontcolor]}\"" if theme[:node_fontcolor]
      @dot_output << " style=\"#{theme[:node_style]}\"" if theme[:node_style]
      @dot_output << " fillcolor=\"#{theme[:node_fillcolor]}\"" if theme[:node_fillcolor]
      @dot_output << "]\n"
      @dot_output << "\n"
    end

    def build_nodes
      @lines.each_with_index do |line, index|
        node_id = "node_#{index}"
        label = line[:display_text].empty? ? "(#{index})" : escape_label(line[:display_text])
        
        # Add quantity qualifiers to label
        quantity_qual = line[:qualifiers].find { |q| [:count, :range, :minimum].include?(q[:type]) }
        if quantity_qual
          case quantity_qual[:type]
          when :count
            label = "[#{quantity_qual[:value]}] #{label}"
          when :range
            label = "[#{quantity_qual[:value][:min]}..#{quantity_qual[:value][:max]}] #{label}"
          when :minimum
            label = "[#{quantity_qual[:value]}+] #{label}"
          end
        end
        
        attributes = []
        attributes << "label=\"#{label}\""
        
        # Handle operators
        if line[:operators].any?
          attributes << "shape=doubleoctagon"
          attributes << "width=0.2 height=0.2"
        end
        
        # Handle qualifiers
        if line[:qualifiers].any? { |q| q[:type] == :condition }
          attributes << "shape=diamond"
        end
        
        # Handle checkboxes
        checkbox_qualifier = line[:qualifiers].find { |q| [:unchecked, :checked, :in_progress].include?(q[:type]) }
        if checkbox_qualifier
          case checkbox_qualifier[:type]
          when :unchecked
            label = "☐ #{label}"
          when :checked
            label = "☑ #{label}"
          when :in_progress
            label = "⊙ #{label}"
          end
          attributes[0] = "label=\"#{label}\""
        end
        
        # Handle properties (colors)
        if line[:properties]['color']
          attributes << "color=\"#{line[:properties]['color']}\""
        end
        if line[:properties]['fillcolor']
          attributes << "fillcolor=\"#{line[:properties]['fillcolor']}\""
          attributes << "style=filled"
        end
        if line[:properties]['fontcolor']
          attributes << "fontcolor=\"#{line[:properties]['fontcolor']}\""
        end
        
        # Handle tags
        if line[:tags].any?
          attributes << "tooltip=\"Tags: #{line[:tags].join(', ')}\""
        end
        
        # Handle literal blocks
        if label.include?("-----")
          attributes << "shape=tab"
        end
        
        @dot_output << "\"#{node_id}\" [#{attributes.join(', ')}]\n"
      end
      @dot_output << "\n"
    end

    def build_edges
      if @options[:type] == 'state'
        build_state_edges
      else
        build_transition_edges
      end
    end

    def build_state_edges
      @lines.each_with_index do |line, index|
        # Find children
        child_indices = find_children(index)
        
        child_indices.each do |child_index|
          child = @lines[child_index]
          from_node = "node_#{index}"
          to_node = "node_#{child_index}"
          
          edge_attrs = []
          
          # Style based on operator
          if line[:operators].include?('OR')
            edge_attrs << "style=\"dashed\""
            edge_attrs << "color=\"black:black\""
          elsif line[:operators].include?('AND')
            edge_attrs << "color=\"black:black\""
          end
          
          @dot_output << "\"#{from_node}\" -> \"#{to_node}\""
          @dot_output << " [#{edge_attrs.join(', ')}]" if edge_attrs.any?
          @dot_output << "\n"
        end
        
        # Handle references
        line[:references][:hard].each do |ref|
          target_index = find_reference_target(ref)
          if target_index
            @dot_output << "\"node_#{index}\" -> \"node_#{target_index}\" [style=\"dashed\"]\n"
          end
        end
        
        line[:references][:soft].each do |ref|
          target_index = find_reference_target(ref)
          if target_index
            @dot_output << "\"node_#{index}\" -> \"node_#{target_index}\" [style=\"dotted\"]\n"
          end
        end
      end
    end

    def build_transition_edges
      @lines.each_with_index do |line, index|
        # Handle OR operator specially - connect to all children and skip to next sibling
        if line[:operators].include?('OR')
          children = find_children(index)
          if children.any?
            # Connect OR node to all its children
            children.each do |child_index|
              @dot_output << "\"node_#{index}\" -> \"node_#{child_index}\" [style=\"dashed\"]\n"
            end
            
            # Find where all OR paths converge (next item at same or lower level)
            converge_index = find_next_at_level_or_above(index, line[:level])
            if converge_index
              # Connect all OR children to the convergence point
              children.each do |child_index|
                # Find last item in each OR branch
                last_in_branch = find_last_in_branch(child_index)
                @dot_output << "\"node_#{last_in_branch}\" -> \"node_#{converge_index}\"\n"
              end
            end
          end
          next
        end
        
        # Handle AND operator - connect children in parallel
        if line[:operators].include?('AND')
          children = find_children(index)
          if children.any?
            # Connect AND node to all its children
            children.each do |child_index|
              @dot_output << "\"node_#{index}\" -> \"node_#{child_index}\" [color=\"black:black\"]\n"
            end
            
            # Find convergence point
            converge_index = find_next_at_level_or_above(index, line[:level])
            if converge_index
              # Connect all AND children to convergence
              children.each do |child_index|
                last_in_branch = find_last_in_branch(child_index)
                @dot_output << "\"node_#{last_in_branch}\" -> \"node_#{converge_index}\" [color=\"black:black\"]\n"
              end
            end
          end
          next
        end
        
        # Handle conditional branches (items with condition qualifiers)
        if line[:qualifiers].any? { |q| q[:type] == :condition }
          # This is a conditional branch
          # Connect from previous item (if exists)
          if index > 0
            prev_index = index - 1
            # Only connect if previous item is at same or parent level
            if @lines[prev_index][:level] <= line[:level]
              @dot_output << "\"node_#{prev_index}\" -> \"node_#{index}\" [label=\"#{line[:qualifiers].first[:value]}\"]\n"
            end
          end
          
          # Process children normally
          children = find_children(index)
          children.each do |child_index|
            @dot_output << "\"node_#{index}\" -> \"node_#{child_index}\"\n"
          end
          
          # Find where this branch ends and connect to convergence
          last_in_branch = find_last_in_branch(index)
          converge_index = find_next_at_level_or_above(index, line[:level])
          if converge_index && last_in_branch != index
            @dot_output << "\"node_#{last_in_branch}\" -> \"node_#{converge_index}\"\n"
          elsif converge_index && last_in_branch == index
            # If this conditional item has no children, connect directly
            @dot_output << "\"node_#{index}\" -> \"node_#{converge_index}\"\n"
          end
          next
        end
        
        # Normal sequential flow
        next_index = index + 1
        next if next_index >= @lines.length
        
        # Skip if we're inside an operator block
        parent_index = find_parent(index)
        if parent_index && @lines[parent_index][:operators].any?
          parent_op = @lines[parent_index][:operators].first
          # Skip internal connections for OR/AND children
          if ['OR', 'AND'].include?(parent_op)
            # Only connect within the branch
            if next_index < @lines.length && @lines[next_index][:level] > @lines[parent_index][:level]
              @dot_output << "\"node_#{index}\" -> \"node_#{next_index}\"\n"
            end
            next
          end
        end
        
        # Skip if next item is a conditional at same level (it will be handled separately)
        if @lines[next_index][:qualifiers].any? { |q| q[:type] == :condition } && 
           @lines[next_index][:level] == line[:level]
          # Still need to connect to it if we're not in a conditional ourselves
          unless line[:qualifiers].any? { |q| q[:type] == :condition }
            @dot_output << "\"node_#{index}\" -> \"node_#{next_index}\"\n"
          end
          next
        end
        
        # Skip if next item is at lower level (going back up the tree)
        next if @lines[next_index][:level] < line[:level]
        
        from_node = "node_#{index}"
        to_node = "node_#{next_index}"
        
        @dot_output << "\"#{from_node}\" -> \"#{to_node}\"\n"
        
        # Handle hard references
        line[:references][:hard].each do |ref|
          target_index = find_reference_target(ref)
          if target_index
            @dot_output << "\"node_#{index}\" -> \"node_#{target_index}\"\n"
          end
        end
        
        # Handle soft references
        line[:references][:soft].each do |ref|
          target_index = find_reference_target(ref)
          if target_index
            @dot_output << "\"node_#{index}\" -> \"node_#{target_index}\" [style=\"dotted\"]\n"
          end
        end
      end
    end

    def build_footer
      @dot_output << "}"
    end

    def find_children(parent_index)
      children = []
      parent_level = @lines[parent_index][:level]
      
      (parent_index + 1...@lines.length).each do |i|
        if @lines[i][:level] > parent_level
          children << i if @lines[i][:level] == parent_level + 1
        else
          break
        end
      end
      
      children
    end

    def find_parent(child_index)
      child_level = @lines[child_index][:level]
      
      (child_index - 1).downto(0) do |i|
        return i if @lines[i][:level] < child_level
      end
      
      nil
    end

    def find_reference_target(ref)
      # Simple implementation - can be enhanced
      @lines.find_index { |line| line[:display_text].include?(ref) }
    end
    
    def find_next_at_level_or_above(start_index, level)
      (start_index + 1...@lines.length).each do |i|
        return i if @lines[i][:level] <= level
      end
      nil
    end
    
    def find_last_in_branch(start_index)
      current_level = @lines[start_index][:level]
      last_index = start_index
      
      (start_index + 1...@lines.length).each do |i|
        if @lines[i][:level] > current_level
          last_index = i
        else
          break
        end
      end
      
      last_index
    end

    def escape_label(text)
      text.gsub('\\', '\\\\').gsub('"', '\\"').gsub('#', '\\#')
    end
  end
end