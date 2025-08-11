# HyperGraph v2.0 - Enhanced Edition

An enhanced version of HyperGraph with modular architecture, advanced features, and improved usability.

## New Features

### ✅ Completed Enhancements

1. **Modular Architecture**
   - Separated parser, graph generator, and output modules
   - Clean, maintainable code structure
   - Easy to extend with new features

2. **Enhanced Validation**
   - `--validate` flag for syntax checking without graph generation
   - Detailed error messages with line numbers
   - Warning system for potential issues
   - Validates references and operator usage

3. **Theme Support**
   - Multiple built-in themes: default, business, tech, pastel
   - Easy theme selection with `--theme` flag
   - Customizable colors and styles per theme

4. **Configuration File Support**
   - Settings saved in `~/.hypergraphrc`
   - Save current options as defaults with `--save-config`
   - Automatic loading of saved preferences

5. **Better Error Handling**
   - Clear error messages with line numbers
   - Validation of HyperList structure
   - Warnings for unmatched references
   - Helpful suggestions for fixes

### 🚧 In Progress

6. **Interactive HTML Output** (basic implementation)
   - Generate HTML with D3.js visualization
   - Clickable, expandable nodes
   - Interactive exploration of large graphs

7. **Watch Mode** (requires 'listen' gem)
   - Auto-regenerate on file changes
   - Live preview during editing
   - Useful for iterative development

8. **Substitution Support** (parsed but not fully visualized)
   - Parse {variable} substitutions
   - Track substitution contexts
   - Prepare for expansion in graph

## Usage

### Basic Commands

```bash
# Validate HyperList syntax
./hypergraph2 --validate mylist.hl

# Generate with theme
./hypergraph2 --theme business -f svg process.hl

# Save configuration
./hypergraph2 -s --theme tech -f png --save-config

# Generate state diagram
./hypergraph2 -s todo.hl

# Generate transition diagram
./hypergraph2 -t workflow.hl
```

### Themes

- **default**: Classic black and white
- **business**: Professional blue theme
- **tech**: Matrix-style green on black  
- **pastel**: Soft pastel colors

### New Options

- `-V, --validate`: Validate syntax only
- `-T, --theme THEME`: Apply visual theme
- `-S, --save-config`: Save settings as defaults
- `-w, --watch`: Watch mode (auto-regenerate)
- `-b, --verbose`: Detailed output
- `-O, --output FILE`: Specify output filename
- `-W, --overwrite`: Overwrite existing files

## Installation

1. Ensure Ruby is installed
2. Ensure Graphviz is installed
3. Make executable: `chmod +x hypergraph2`
4. For watch mode: `gem install listen`

## Architecture

```
hypergraph2
├── lib/
│   └── hypergraph/
│       ├── parser.rb          # HyperList parsing
│       └── graph_generator.rb # DOT generation
└── hypergraph2                # Main CLI
```

## Examples

### Validation Example
```bash
$ ./hypergraph2 --validate test.hl
✅ HyperList validation successful!
  17 items parsed
```

### Theme Example
```bash
$ ./hypergraph2 --theme business -f svg test.hl
✅ Graph generated: test.svg
```

### Config Example
```bash
$ ./hypergraph2 --theme tech --save-config
Configuration saved to ~/.hypergraphrc
```

## Roadmap

### Next Features to Implement

1. **Full Substitution Support**
   - Expand substitutions in graph
   - Show multiple paths for substitution values
   - Visual differentiation for substituted items

2. **Interactive HTML/D3.js**
   - Complete D3.js implementation
   - Collapsible/expandable nodes
   - Search and filter capabilities
   - Export visible portion

3. **Advanced Graph Layouts**
   - Clustering for operators
   - Swimlanes for actors
   - Edge bundling for complex graphs
   - Hierarchical layouts

4. **Import/Export**
   - Import from Markdown lists
   - Export to Mermaid/PlantUML
   - Two-way sync with other tools

5. **Performance Optimizations**
   - Caching for large files
   - Incremental updates
   - Parallel processing

## Compatibility

The enhanced version (`hypergraph2`) is designed to coexist with the original `hypergraph`. Both can be used independently:

- `./hypergraph` - Original version
- `./hypergraph2` - Enhanced version

All original features are preserved and enhanced in v2.

## Contributing

The modular architecture makes it easy to contribute:

1. Parser enhancements in `lib/hypergraph/parser.rb`
2. Visualization in `lib/hypergraph/graph_generator.rb`
3. New themes in the `load_themes` method
4. CLI features in `hypergraph2`

## License

Same as original - GPL v3

## Author

Original by Geir Isene
Enhanced version improvements - 2025