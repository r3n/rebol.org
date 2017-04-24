REBOL [
    Title: "RebGUI span Example"
    File: %rebgui-sizing.r
    Author: "Brian Tiffin"
    Date: 05-Jun-2007
    Version: 1.0.0
    Rights: "Copyright (c) 2007 Brian Tiffin"
    Credits: "Ashley Truter; RebGUI designer...the 'u' in Truter is properly &#252;"
    Home: http://www.dobeash.com
    Usage: "do http://rebol.org/cgi-bin/cgiwrap/rebol/download-a-script?script-name=rebgui-sizing.r"
    Purpose: "RebGUI tutorial; display images, with widget span and window resizing"
    Comment: "RebGUI does not need VID...but here, it is loaded with VID by using REBOL/View"
    History: [05-Jun-2007 1.0.0 "btiffin" "First cut"]
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
        see-also: "rebgui-image.r and view-image.r"
    ]
]

; Load in RebGUI.  Please note; the #include %rebgui.r allows for SDK but still works with "do"
#include %rebgui.r
unless value? 'ctx-rebgui [do-thru http://www.dobeash.com/RebGUI/rebgui.r]

; Display all the stock REBOL/View VID images...a bit of a misnomer when using RebGUI...
;  There is no real 'intelligence' building this span sequence...it's just a demo
ispec: copy []   ; Empty spec
span: #WH        ; First panel widget can grow in Width and Height
insert tail ispec [after 4]   ; RebGUI will insert a "return" every 4 widgets
foreach [name data other] system/view/VID/image-stock [
  if image? data [
    insert tail ispec compose/deep [panel sky (span) data [text (form name) image (data)]]
    span: #XY    ; All other panels move in the X and the Y
  ]
]

display "RebGUI Resizable display of all VID Stock Images" ispec
do-events
