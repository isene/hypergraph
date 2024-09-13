# hypergraph
Graphing HyperListS

This program creates a graphical representation of a HyperList. A HyperList can be used to describe anything – any state or any transition - from a todo or shopping list to organizational structures, project plans, business processes or complex logic structures. It represents data in tree-structure lists with a very rich set of features.

To add colors ([all colors usable by Graphviz](https://graphviz.org/doc/info/colors.html#x11)) to each node in the graph, add them in separate parenthesis at the end of each item like this:

`An example item (color=red) (fillcolor=blue) (fontcolor=white)`

For more information on HyperList, see http://isene.me/hyperlist/

For an online version of Hypergraph, go to: https://isene.com/hypergraph.html

The helptext `hypergraph -h`

```
  DESCRIPTION
     This program converts a HyperList to a graph
     A HyperList can be graphed as a State or as a Transition
        A State graph is a hierarchical graph of the HyperList (similar to a MindMap)
        A Transition graph is a sequential graph (similar to a Flow Chart)
     See the manual for more information on Hyperlist <http://isene.me/hyperlist/>
     Note that this program will not graph the most advanced HyperList features (yet)
        Conditionals, Operators, Properties and Literals are (mostly) correctly graphed
     This help file is in itself a valid HyperList
  REQUIREMENTS
     This program requires Ruby and Graphviz
     For easy creation of HyperLists, use VIM with the HyperList plugin
  SYNOPSIS 
    hypergraph [OPTIONS] filename.hl
  OPTIONS
    HyperList type
      -s, --state
	      Treat the HyperList as a State, a hierarchy of items
      -t, --trans
	      Treat the HyperList as a Transition, sequence of actions
    Chart directions
      -d, --down
        Top-to-bottom rendering (DEFAULT)
      -u, --up
        Bottom-to-top rendering
      -l, --left
        Left-to-right rendering
      -r, right
        Right-to-left rendering
    Edge type
      -a, --arrow
        Use directional arrows (DEFAULT)
      -n, --noarrow
        Use non-directional lines (edges)
      -o, --ortho
        Use angled lines
      -p, --poly
        Use straight lines
    Separation
      -e, --sep
        Set node and rank separation to the value supplied
    Graphics format
      -f, --format [GRAPHICS FORMAT]
    Specify the graphics format used for the graph file; Possible formats:
      "png" (default), "jpg", "gif", "svg", "ps", "fig" (XFIG format)
    Other options
      -c, --clean
        Only convert the HyperList to a clean and strict HyperList
          + The program will always do this and save the "clean file",
          but with the -c option, the program exits after saving the file
	    -O, --overwrite
	      Overwrite existing files (strict, dot and graph files)
      -h, --help
        Displays the help text
      -v, --version
        Displays the version number of hypergraph
  COPYRIGHT
     Copyright 2014-2024, Geir Isene. Released under the GPL v. 3
     See http://isene.com for more contributions by Geir Isene.
```
