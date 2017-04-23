REBOL [
    Title: "Layout Writer"
    Date: 18-Mar-2008
    Version: 0.1.1
    File: %layout-writer.r
    Author: "R.v.d.Zee"
    Owner: "R.v.d.Zee"
    Rights: "Copyright (C) R. v.d.Zee 2008"

    Usage: {The script loads a layout, but not the REBOL header portion of a REBOL script.
            An mp3 file or other media should be in the same directory as the script.}

    Purpose: {The script was intended as a method for writing  scripts.  A layout may
             be written in the editor and then displayed in the same script.  Writers can change
             the script and view the changes without leaving  the editor.

             Reference material may be drawn into the program, reviewed, and even copied
             and pasted into the editor.}


    Notes: {The background effect was generated by Pattern Generator, (Cyphre).
           http://www.rebol.com/view/tools/patterns.r

           The player script is an adaptation of the original by C. Sassenrath, originally presented
           as an introductory script, REBOL Quick Start: Part 5 - Files, Directories, and Playing Music,
           http://www.rebol.com/docs/quick-start5.html.

           The shell command requires the  file to be played to be in quotation marks.
           This script achieves this construction with the rejoin statement.

          "to-local-file" translates the Rebol file format to the operating system file format.

          "clean-path" provides the full path to the file.
          
           Using the Rebol "call" command to play the file requires that the files be in the
           format of the operating system, and not the Rebol file format normally used in scripts.

          There are no error controls built into this script.}


    History: [
      1.1.0  [18-Mar-2008  "Written"]
      1.1.1  [19-Mar-2008  "add  writers as global variable & if not empty? writers [writer/text: writers]"]
   ] 

    Library: [
        level: 'beginner
        platform: 'all
        type: [demo tool how-to reference]
        domain: [gui shell]
        support: none
        tested-under: [View 1.3.2.3.1 [Windows]]
        license: none
    ]
]


instructions: [
    {Welcome to the Rebol Layout Writer!

    The "Add File list" button will add some sample script to make a layout, one that should make Rebol script writing even more enjoyable.

    Write the script for your layout in editor area to the left and then click the "Load" Button.  Note the example starts with an empty layout, but still has brackets, "[ ]". Ensure your layout scripts have one left bracket, or "[", at the start of the layout, and one right bracket "]", at the end of the layout. At the moment, you must remove any headers from scripts before attempting to view the layout here.

    The "Reference" button will load your notes, scripts, or other text files.  

    Most changes made to the attributes of the faces in the editor can be viewed when the layout is reloaded.

Ctrl + C  keys copies highlighted text to the clipboard.

Ctrl + X  keys cuts   highlighted text from the text area and copies that text to the clipboard.

Ctrl + V  pastes clipboard text into the text area.

Clicking the mouse in a text area (no highlight) & then Ctrl + C copies all of the text of the area to the clipboard.

Similarly, all of the text can be cut, one click then Ctrl + X.

    Windows Media Player will remember it's mode and offset when set to compact mode, placing it initially at least, where you choose to view it in this script.}

{
    across
    audio-list: text-list 250x150 orange navy data array 14 [
        player: "C:\Program Files\Windows Media Player\wmplayer.exe"
        play-file: rejoin [
            {"}
            to-local-file clean-path audio-list/picked/1 
            {"}
        ]
        call reform [player play-file]
    ]}
{    return
     pad 120x5
     btn wheat "Find Audio Files" [
         clear audio-list/data  
         audio-list-formats: [%.wma %.mp3 %.wav]
         all-files: read %.
         foreach file all-files [
             if find audio-list-formats suffix? file [
                 append audio-list/data file
             ]
         ]
         reset-face audio-list
     ]}
{[
audio-list/pane/pane/2/color: 86.101.130 ;track color
audio-list/sld/pane/1/color: red  ;dragger color
audio-list/sld/pane/2/colors/1: ;top arrow square color
audio-list/sld/pane/3/colors/1: 17.132.205  ;bottom arrow square color
;;audio-list/pane/effect:  ;can be set if color & sub-area/color are none
audio-list/color: teal  ;none
audio-list/sub-area/color: purple ;olive ;none
]}

]

writers: make string! 200

top-screen: layout [
    backdrop khaki + 30
    across
    space 0
]

bottom-screen: layout [
    size 800x700
    backdrop effect [
        gradient 0x1 255.255.255 190.190.190 draw [
            pen none 
            fill-pen diamond
            1015x1017 0 271 128 1 5
            255.255.255.222 128.128.128.168 255.255.255.138 100.136.116.180 0.255.255.220
            245.222.129.141 222.184.135.191 255.150.10.180 100.136.116.195
            245.222.129.131 175.155.120.141 170.170.170.174 0.48.0.165 0.128.0.133
            128.0.0.216 76.26.0.224 0.0.0.188 255.80.37.133 80.108.142.208 160.180.160.168
            0.128.0.180 72.72.16.137 255.255.255.130
            box 0x0 800x700 
            pen none 
            fill-pen conic
            70x993 0 154 154 5 1
            255.80.37.136 44.80.132.174 64.64.64.196 255.255.0.167 240.240.240.139
            44.80.132.163 128.128.128.178 255.255.255.202 64.64.64.144 0.48.0.181
            64.64.64.136 72.72.16.150 255.80.37.196 44.80.132.197 76.26.0.196 
            box 0x0 800x700
        ]
    ]
    origin 0x0
    across
    space 0
    blackboard: box 760x800
    return
    pad 0x-330
    editor-box: box 420x185  ;790
    pad 5
    reader-box: box 395x185
    return
    pad 0x5
    btn wheat"Show Editor" [
        ;---move the boxes in & out of view - show [editor-box reader-box] is ok, 
        ;   hide editor-box & hide reader-box was not used, since the boxes did not hide together
        either face/text = "Show Editor" [
            editors-place: editor-box/offset
            readers-place: reader-box/offset
            editor-box/pane: editor
            reader-box/pane: researcher
            show [editor-box reader-box]
            face/text: "Hide Editor"
        ][
            editor-box/offset/y: 1000
            reader-box/offset/y: 1000
            show [editor-box reader-box]
            face/text: "Show Editor"   
            editor-box/offset: editors-place
            reader-box/offset: readers-place
        ]
    ]


    sample-script: btn wheat 90 "Add Playlist" ivory left [

        add-to-script: func [instruction button-text][
            poke writer/text (length? writer/text) newline
            append writer/text pick instructions  instruction
            append writer/text join newline "]"
            show writer
            writers: copy writer/text
            new-script: layout load first to-block writer/text
            new-script/offset: 0x0
            blackboard/pane: new-script
            writer/text: writers
            show blackboard
            face/text: button-text
            show face
        ]    

        if face/text = "Colors" [
            append writer/text join newline instructions/4
            writers: copy writer/text
            kr: to-block writer/text
            new-script: layout load first kr
            new-script/offset: 0x0
            blackboard/pane: new-script
            do form kr/2
            writer/text: writers
            show blackboard
            face/text: "Done"
            show face           
        ]
        if face/text = "Add File Button"     [add-to-script 3 "Colors"]
        if face/text = "Add Playlist"        [add-to-script 2 "Add File Button"]
    ]

    btn wheat "View" [
        kr: load to-block writer/text
        new-script: layout load first kr
        new-script/offset: 0x0
        blackboard/pane: new-script
        do form kr/2
        if not empty? writers [writer/text: writers]
        show blackboard
    ]

    btn wheat "Load Layout" [
        reset-face reader
        reset-face scroll-reader
        read-layout: request-file
        if not none? read-layout [
            writer/text: read first read-layout
            writers: copy writer/text
            focus writer
        ]
    ]

    btn wheat "Save Layout" [
        layout-to-save: request-file/title/save  "Save Layout" ""
        if not none? layout-to-save [
            save first layout-to-save to-block writer/text
        ]
    ]

    btn wheat  "Quit"  [quit] 
    pad 200

    btn wheat - 10 "Reference"  [
        web-pages: [%.html %.htm]
        text-pages: [%.r %.txt]
        file-to-read: request-file
        if not none? file-to-read [
            if find web-pages suffix? first file-to-read [browse first file-to-read]
            if find text-pages suffix? first file-to-read [
                reset-face reader
                reset-face scroll-reader
                reader/text: read first file-to-read
                show reader
            ]
        ]         
    ]

    btn wheat - 10 "Save Note" [
        file-name: request-file/save/title/filter "Save Note" "REBOL" "*.txt *.r"
        if not none? file-name [
            write first file-name reader/text
        ]
    ]

    btn wheat - 10 "?" [
        reset-face reader
        reset-face scroll-reader
        reader/text: first instructions
        show reader
    ]
]

blackboard/pane: top-screen
top-screen/offset: 0x0
blackboard/show?: false


editor: layout [
    backdrop brown + 30
    origin 0x0
    across
    space 0
    writer: area 400x185 khaki + 30  khaki + 40 wrap with [
        edge/effect: none
        edge/size: 1x1
        edge/color: brown
    ] "[ ]"
    scroll-writer: scroller 15x185 olive brown [scroll-para writer scroll-writer]
]
editor/offset: 0x0


researcher: layout [
    backdrop brown + 30
    origin 0x0
    across
    space 0
    reader: area 350x185 khaki + 30 khaki + 40 font-color black font-size 12 wrap with [
        edge/size: 1x1
        edge/color: brown
    ] instructions/1

    scroll-reader: scroller 15x185 olive brown [scroll-para reader scroll-reader]
]
researcher/offset: 0x0

view/offset bottom-screen 300x30