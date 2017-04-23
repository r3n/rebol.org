REBOL [
    Title: "Test Dot Graphviz with com2Rebol"
    Date: 16-Feb-2006
    File: %graphviz2rebol.r
    Author: "Ph. Le Goff" 
    EMail:  lp.legoff@free.fr
    Version: 0.0.2
    Purpose: "An example of use Graphviz with REBOL and COM objects "
    History: ["16-Feb-2006 - Initial" ]
    Purpose: {
        REBOL COM.interfacing with WinGraphviz
    }
    library: [
        level:    'intermediate
        platform: 'windows
        type:     [demo how-to]
        domain:   [external-library win-api]
        tested-under: [view/pro 1.3.2.3.1 on WXP]
        support:  none
        license:  none
        see-also: none
    ]
]
{USAGE :  
WinGraphviz is a tool supplied by ATT, to draw directed graphs (DOT), with a basic syntax.
With com2rebol.r and WinGraphviz COM object, it is possible to map Rebol and Dot files.
So : 
	1/ it is mandatory to have com2rebol from benjamin Maggi. 
	2/ it is mandatory to install WinGraphviz from .cab (http://home.so-net.net.tw/oodtsen/wingraphviz/index.htm)
	3/ have fun.
}


; load com2rebol.dll library for rebol <-> Com exchange
do load %com2rebol.r

initDipsHelper 1

dot: createObject "Wingraphviz.dot"

; Note that a DOT file could be dynamically created, with DOT syntax.

file: request-file/only/filter/title [ "*.dot" "*.txt" ] "GraphViz ScriptControl" "Load"
either file [ str: read file][ alert "You must provide a dot file !"]

dot-code: make string! str 

Img: retriveObject dot ".ToPNG(%s)" dot-code   ; PNG file output (could be change, see Dot doc)

defaut:  to-local-file rejoin [file ".png"]

result-png-file: to-string request-text/title/default  "file path and name to file ? " defaut

objectMethod Img ".save(%s)" result-png-file

browse result-png-file

