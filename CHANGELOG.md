# Changelog

All notable changes to HyperGraph will be documented in this file.

## [2.0.0] - 2025-01-11

### Added
- **Modular Architecture** - Complete rewrite with separated parser and graph generator modules
- **Theme Support** - Four built-in themes: default, business, tech, pastel
- **Validation Mode** (`--validate`) - Check HyperList syntax without generating graphs
- **Configuration Files** - Save and load preferences from `~/.hypergraphrc`
- **Watch Mode** (`--watch`) - Auto-regenerate graphs when files change (requires 'listen' gem)
- **Interactive Mode** (`--interactive`) - Enter HyperList via stdin
- **Verbose Mode** (`--verbose`) - Detailed output for debugging
- **Save Config** (`--save-config`) - Save current options as defaults
- **Better Error Messages** - Line numbers and helpful suggestions for syntax errors
- **Warning System** - Non-fatal issues reported with line numbers
- **HTML Output** - Basic framework for interactive D3.js visualizations
- **Substitution Parsing** - Recognizes `{variable}` syntax for future expansion

### Changed
- **Qualifier Display** - Now correctly shows `[4] Wheels` as single node instead of splitting
- **File Organization** - Clean lib/ directory structure with modules
- **Output Control** - Better handling of file naming and overwrite protection
- **Command Line Interface** - More intuitive option names and help text
- **Default Behavior** - Smarter defaults based on common usage patterns

### Fixed
- **Qualifier Handling** - Quantities like `[4]`, `[2..5]`, `[3+]` now display correctly with items
- **Operator Logic** - OR and AND operators better represented in transition diagrams
- **Reference Resolution** - Improved handling of hard and soft references
- **Conditional Branches** - Better flow for `[condition]` items in transitions
- **Literal Blocks** - Proper handling of `\` literal text blocks
- **Color Properties** - Consistent parsing and application of color attributes
- **Graph Structure** - More accurate representation of HyperList hierarchy

### Technical Improvements
- **Code Structure** - Modular design for easier maintenance and extension
- **Parser Enhancement** - More robust parsing with better error recovery
- **Graph Generation** - Cleaner DOT output with proper escaping
- **Memory Efficiency** - Better handling of large HyperLists
- **Ruby Compatibility** - Works with Ruby 2.0+

## [1.5.3] - 2024-09-06

### Changed
- Better handling of links with State HyperLists
- Added color support (edge, fill and font)
- Minor fixes

## [1.5] - 2024

### Added
- Color support via `(color=name)` syntax
- Separation control with `--sep` option

## [1.0] - 2014

### Initial Release
- Basic HyperList to graph conversion
- State and Transition diagram support
- Multiple output formats (PNG, JPG, SVG, etc.)
- Directional control (up, down, left, right)
- Arrow and line style options