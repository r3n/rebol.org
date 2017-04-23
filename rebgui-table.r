REBOL [
    Title: "RebGUI table Example"
    File: %rebgui-table.r
    Author: "Brian Tiffin"
    Date: 04-Jun-2007
    Version: 1.0.0
    Rights: "Copyright (c) 2007 Brian Tiffin"
    Credits: "Ashley Truter; RebGUI designer...the 'u' in Truter is properly &#252;"
    Home: http://www.dobeash.com
    Usage: "do http://rebol.org/cgi-bin/cgiwrap/rebol/download-a-script?script-name=rebgui-table.r"
    Purpose: "RebGUI tutorial; display a table"
    Comment: "RebGUI does not need VID...but here, it is loaded with VID by using REBOL/View"
    History: [04-Jun-2007 1.0.0 "btiffin" "First cut"]
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'how-to
        domain: 'GUI
        tested-under: [view 2.7.5.4.2 on "Debian GNU/Linux 4.0" by "btiffin"]
        support: [
            http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=rebgui-table.r
            svn://svn.geekisp.com/rebgui
            "Altme REBOL3 World !RebGUI forum"
            http://www.opensource.org/licenses/mit-license.html
        ]
        license: 'MIT
        see-also: "rebgui-image.r"
    ]
]

; Check to see if RebGUI is already loaded; if not go to the cache (or net) and get it.
unless value? 'ctx-rebgui [do-thru http://www.dobeash.com/RebGUI/rebgui.r]


; Build a data table, two columns; color name and color tuple!
table-data: copy []
foreach color ctx-rebgui/locale*/colors [
    append table-data color
    append table-data get color
]

; Display a RebGUI table
display "RebGUI table Example" [
    table options ["Color" left .4 "RGB" right .6]  data table-data  on-click [
        set-color abox second face/selected   set-color bbox subtract 255.255.255 second face/selected
    ]
    return
    abox: box 24x10  bbox: box 24x10
]
do-events
