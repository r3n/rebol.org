REBOL [
    Title: "RebGUI image Example"
    File: %rebgui-image.r
    Author: "Brian Tiffin"
    Date: 04-Jun-2007
    Version: 1.0.0
    Rights: "Copyright (c) 2007 Brian Tiffin"
    Credits: "Ashley Truter; RebGUI designer...the 'u' in Truter is properly &#252;"
    Home: http://www.dobeash.com
    Usage: "do http://rebol.org/cgi-bin/cgiwrap/rebol/download-a-script?script-name=rebgui-image.r"
    Purpose: "RebGUI tutorial; display an image, with tip and close action"
    Comment: "RebGUI does not need VID...but here, it is loaded with VID by using REBOL/View"
    History: [04-Jun-2007 1.0.0 "btiffin" "First cut"]
    library: [
        level: 'intermediate
        platform: 'all
        type: 'how-to
        domain: 'GUI
        tested-under: [view 2.7.5.4.2 on "Debian GNU/Linux 4.0" by "btiffin"]
        support: [
            http://www.dobeash.com/rebgui.html
            "Altme REBOL3 World !RebGUI forum"
            svn://svn.geekisp.com/rebgui
            http://www.opensource.org/licenses/mit-license.html
        ]
        license: 'MIT
        see-also: "rebgui-table.r"
    ]
]

; Check to see if RebGUI is already loaded; if not go to the cache (or net) and get it.
unless value? 'ctx-rebgui [do-thru http://www.dobeash.com/RebGUI/rebgui.r]

; Display a REBOL logo
display "RebGUI image Example" [
    image logo.gif  tip "Click to close"  [unview]
]
do-events
