REBOL [
    Title:   "Parse & Display Of The Core23 Manual"
    Date:    25-Sept-2007
    Name:    "Parse & Display of Core23 Manual"
    Version: 1.0.1
    File:    %parse-core23-manual.r
    Author: "R. v.d.Zee"
    Rights: "Copyright (C) R. v.d.Zee"
    Tabs:   4
    History: [
        "14-Sep-2007  Version: 1.0.0 New Script"
        "27-Sept-2007 version: 1.0.0 Upload To Library"
        "28-Sept-2007 version: 1.0.1 Add Mising Script Area Sizing Line"
     ]
    
    Library: [
       level:          'intermediate 
       platform:     'all
       type:          [tool demo]
       domain:      [markup text-processing web] 
       tested-under: 'WXP
       support:      none
       License:      none
    ]

    Purpose:  {a parsing exercise}

    Note: {

        The parsed and displayed documents may edited and then saved by the reader.      

        Reversing the process might be used to produce HTML documents.
  
        Loading "REBOL [" is an issue in this arrangement, so "REBOL [" is changed to "r-ebol [", 
        and later, changed back to "REBOL [".

        No reliance on the parsed Rebol documents portrayed in this script can be made.  

        This script is an exercise in parsing. There is no representation of the
        accuracy or otherwise of the material converted from the source HTML documents.  

        Use only official REBOL documentation. 

        Comments may be made directly from the local documents.
    }

]

source-contents: [
    rebol-site: http://www.rebol.com/docs/core23/
    table-of-contents: read/lines http://www.rebol.com/docs/core23/rebolcore.html
    forall table-of-contents [
        if (find table-of-contents/1 "Introduction")[break]
    ] 
    source-documents: make block! 50
    foreach line table-of-contents [
        replace line "Network<BR>" "Network Protocols </SPAN>"
        if find line "A HREF" [
            parse line [thru {<A HREF="} copy part-url to {">}]
            parse line [thru <SPAN STYLE="Font-Size : 12pt"> copy doc-title to </SPAN>]
            append source-documents      doc-title
            append source-documents join rebol-site part-url
        ]
    ]
    replace source-documents (select source-documents "Changes") http://www.rebol.com/docs/changes.html
    source-documents: find source-documents "Updates"
    remove source-documents
    remove source-documents                     ;remove "Updates" format is different
    source-documents: head source-documents
    clear document-list/data

    forskip source-documents 2 [
        append document-list/data first source-documents
    ]
    show document-list
]


if not exists? %local-docs/ [make-dir %local-docs]


                 ;====   Parse & Convert Documents   ====

HTML-RTML: func [page-requested] [
    all-positions:     make block!  600
    p-tag-positions:   make block!  300
    pre-tag-positions: make block!  100
    h2-tag-positions:  make block!   50
    h3-tag-positions:  make block!   50
    image-positions:   make block!   10
    image-files:       make block!   10

    show advice


                 ;====     Parse HTML Functions      ====

    paragraphs: func [position][
        HTML: head HTML
        HTML: skip HTML position - 1
        parse HTML [thru <p> copy text-in-here to </P>]
        trim/tail text-in-here
        line-height: length? text-in-here
        if line-height < 25 [line-height: 45]          
        text-in-here: rejoin [  " p-area 490x"   (to-integer (line-height / 3) + 20) " "   mold text-in-here      newline newline ]
        append content to-block copy text-in-here
        clear text-in-here
    ]

    scripts: func [position][
        HTML: head HTML
        HTML: skip HTML position - 2
        parse HTML [thru "<pre>" copy text-in-here to "</pre>"]
        trim/tail text-in-here
        line-counter: 1
        formed-text: copy form text-in-here            ; to count newlines
        forall formed-text [if (formed-text/1 = to-char "^/") [line-counter: line-counter + 1]]
        area-y: (to-integer  line-counter * 18)
        if area-y < 30 [area-y: 30]
        text-in-here:  rejoin [" pre-area 440x" area-y " "  mold text-in-here   newline]
        append content  to-block text-in-here 
        line-counter: 1
        area-y: area-y + 40
    ]

    headings: func [position][
        HTML: head HTML
        HTML: skip HTML position - 1
        parse HTML [to "<h2" copy heading-in-here thru </h2>]
        parse HTML [thru ">" copy heading-in-here to     "<"]
        append heading-list/data copy heading-in-here
        heading-in-here: rejoin ["heading " mold heading-in-here newline]
        append content to-block copy heading-in-here
        clear heading-in-here
    ]

    sub-headings: func [position][
        HTML: head HTML
        HTML: skip HTML position - 1
        parse HTML [to "<h3" copy sub-in-here thru </h3>]
        parse HTML [thru ">" copy sub-in-here to "<"]
        append sub-heading-list/data copy sub-in-here
        sub-in-here: rejoin ["sub-heading " mold sub-in-here newline]
        append content to-block copy sub-in-here
        clear sub-in-here
    ]


   illustrations: func [position][
        HTML: head HTML
        HTML: skip HTML position - 2
        parse HTML [thru "<img src=" copy image-in-here to "></P>"]  ;breaks at "Updates" page with tables
        file: to-file form to-block image-in-here
        append image-files file
        if not exists? file [
            advice/text: "Downloading Image..."
            show advice
            write/binary file read/binary join rebol-site file
            advice/text: "Reading File...."
            hide advice
        ]
        image-in-here: rejoin ["pad 90x0 image "  "%" image-in-here  "pad -90x0" newline newline]
        append content to-block copy image-in-here
        clear image-in-here
    ]


                  ;====  Get the HTML document       ====

    HTML: read page-requested  ;read page-requested for internet, just page-requested for local
    a-scroller/data: 0
    show a-scroller
    hide advice
    content: []
    

                 ;====  Remove & Change Html Coding  ====
    
    replace/all HTML "<p></li>"  </p>   ;.....
    replace/all HTML {<span class="output">}  " "
    replace/all HTML </span>               " "
    replace/all HTML "&gt;"  "> "
    replace/all HTML "&lt;"  "<"
    replace/all HTML "<b><tt>"   "^""  ;??
    replace/all HTML "</tt></b>" "^""  ;??
    replace/all HTML <b> "^"" 
    replace/all HTML </b> "^"" 
    replace/all HTML <tt> "^"" 
    replace/all HTML </tt> "^"" 
    replace/all HTML <i> "^"" 
    replace/all HTML </i> "^"" 
    replace/all HTML </li> ""
    replace/all HTML <li>  ""
    replace/all HTML <li> <p>
    replace/all HTML </li> </p>
    replace/all HTML {<tr><td><a href="http://www.rebol.com/docs.html"><img src="http://www.rebol.com/graphics/doc-bar.gif" width="680" height="28" align="bottom" alt="rebol document" border="0" usemap="#bar-map" ismap></a></td></tr>
} ""
    replace/all html <ul> ""
    replace/all html </ul> ""
    replace/all HTML "(})."   "."                    ;closing brace issue in values page
    html-error: join "^{" "    "
    replace/all HTML html-error "    "
    replace HTML "{REBOL End User License Agreement IMPORT" "{REBOL End User License Agreement IMPORT}"
    if (find html  {<a class="toc2"}) [html: find/last html {<a class="toc2"}]



                 ;====     Find & Mark Positions     ====

    parse HTML [
        any [
            to "<p>" mark: thru "</p>"
            (append p-tag-positions index? mark)
        ]
    ]

    parse HTML [
        any [
            to "<pre" mark: thru "/pre>"
            ( append pre-tag-positions index? mark)
        ]
    ]
    parse HTML [
        any [
            to "<h2" mark: thru ">"
            (append h2-tag-positions index? mark)
        ]
    ]

    parse HTML [
        any [
            to "<h3" mark: thru ">"
            (append h3-tag-positions index? mark)
        ]
    ]


    parse HTML [
        any [
            to "<img src=" mark: thru "></p>"
            (append image-positions index? mark)
        ]
    ]

    append all-positions p-tag-positions
    append all-positions pre-tag-positions
    append all-positions h2-tag-positions
    append all-positions h3-tag-positions
    append all-positions image-positions

    sort all-positions


                  ;===     Reconstruct With Markers  ====


    foreach item all-positions [
        if find  p-tag-positions   item  [paragraphs    item]
        if find  pre-tag-positions item  [scripts       item]
        if find  h2-tag-positions  item  [headings      item]
        if find  h3-tag-positions  item  [sub-headings  item]
        if find image-positions    item  [illustrations item]
    ]


                 ;====        Start Document         ====

    rtml-page: copy rtml-template
    append rtml-page copy content
    clear content

    panel/pane: layout rtml-page
    panel/pane/offset: 0x0
    show [panel heading-list sub-heading-list]
    hide advice
]


    rtml-template: [                                 ; REBOL determines size
        backdrop linen
        style p-area   area linen  middle font-size 14 wrap with [edge/size: 0x0 para/origin: 5x3]
        style pre-area area silver font-size 14 wrap middle  with [para/origin: 40x-20]
        style heading h2 490x23 navy
        style sub-heading   h3 490x23 water
        origin 0x0
        across
        space 0
        image logo.gif
        document-header: box 450x24 coal green "Documentation"
        origin 40x40   ;can chop off the first of lines
        below
        space 0
    ]


local-file?: true



                 ;====         Main layout           ====

main: layout [
    backdrop with [effect: [gradient 0x1 gray 114.110.75]]
    origin 20x20
    panel: box 550x600 with [effect: [gradient 0x1  gray 181.181.132] ] 
    return
    pad -7x0
    a-scroller: scroller 16x600 [
        if not none? panel/pane [                                 ;without a layout - a scroller error
            panel/pane/offset/y: negate face/data * panel/pane/size/y
            show panel/pane
        ]
    ]
    return
    pad 0x20

    sub-heading-list: text-list 300x200 black silver data array 20 [
        all-offsets: make block! 100
        foreach pane-face panel/pane/pane [
            append all-offsets pane-face/offset/2
            if pane-face/text = face/picked/1 [
                face-place: pane-face/offset
                panel/pane/offset/y: negate face-place/2
            ]
        ]
        show panel/pane
        a-scroller/data: face-place/2 / last all-offsets
        show a-scroller
        reset-face heading-list
    ]

    heading-list:  text-list 300x100 black silver data array 20  [
        all-offsets: make block! 100
        foreach pane-face panel/pane/pane [
            append all-offsets pane-face/offset/2
            if pane-face/text = face/picked/1 [
                face-place: pane-face/offset
                panel/pane/offset/y: negate face-place/2
            ]
        ]
        show panel/pane
        a-scroller/data: face-place/2 / last all-offsets
        show a-scroller
        reset-face sub-heading-list
    ]

    document-list: text-list 300x100 black silver data array 20 [             ;...array used to set dragger
        show advice
        show face
        picked-page: select source-documents face/picked/1
        clear heading-list/data 
        clear sub-heading-list/data 

        either local-file? [            
            saved-page: load join %local-docs/ last split-path picked-page  ;saved-page
            saved-page: skip saved-page (length? rtml-template)
            while [not tail? saved-page] [
                if (saved-page/1 = 'pre-area) [replace/all saved-page/3 "r-ebol" "REBOL"]
                saved-page: next saved-page 
            ]
        saved-page: head saved-page
        panel/pane: layout rtml-page: saved-page    ;rtml-page is used for convenience of saving local files
        panel/pane/offSet: 0x0
        clear sub-heading-list/data
        clear heading-list/data
        show panel
        saved-page: skip saved-page (length? rtml-template )
        forall saved-page [
            if saved-page/1 = 'heading       [append       heading-list/data second saved-page]
            if saved-page/1 = 'sub-heading   [append   sub-heading-list/data second saved-page]
        ]
        a-scroller/data: sub-heading-list/sld/data: heading-list/sld/data: document-list/sld/data: 0
        sub-heading-list/sn: heading-list/sn: document-list/sn: 0
        reset-face heading-list
        reset-face sub-heading-list
        reset-face a-scroller
        a-scroller/show?: true
        ][         
            HTML-RTML picked-page 
        ]
        document-header/text: face/picked/1
        show document-header
        hide advice
    ]

    across
    pad 650x-180

    btn "Internet" [
        either connected? [
            clear heading-list/data 
            clear sub-heading-list/data
            clear document-list/data
            hide file-source
            show advice
            reset-face heading-list 
            reset-face sub-heading-list
            reset-face document-list

            do source-contents 

            hide advice
            file-source/text: "Online Files"
            show file-source
            local-file?: false
            reset-face a-scroller
            hide a-scroller 
        ][alert "No Internet"]
    ]

    btn "Save" [
        if error? try [ 
            forall rtml-page [
                if all [
                    rtml-page/1 = 'pre-area 
                    pair? rtml-page/2
                ][
                    replace/all rtml-page/3 "REBOL" "r-ebol"
                    line-counter: 1
                    formed-text: copy form rtml-page/3
                    forall formed-text [if (formed-text/1 = to-char "^/") [line-counter: line-counter + 1]]
                    area-y:  (line-counter * 18)
                    if rtml-page/2/2 < 30 [area-y: 30]
                    rtml-page/2/2: area-y
                ]
                if all  [
                    rtml-page/1 = 'p-area 
                    pair? rtml-page/2
                ][
                    text-length: length? rtml-page/3
                    if rtml-page/2/2 < 25 [rtml-page/2/2: 45] 
                    rtml-page/2/2:  (to-integer (text-length / 3) + 22)
                    if empty? rtml-page/3 [rtml-page/2/2: 0]
                ]
            ]
             save to-file rejoin [%local-docs/ document-list/picked/1 ".rtml"] rtml-page
        ][alert "Nothing To Save"]
    ]
    

    btn "Local"  [
        clear sub-heading-list/data
        clear     heading-list/data 
        clear     document-list/data
        reset-face sub-heading-list
        reset-face heading-list
        reset-face document-list
        either exists? %local-docs/ [
            local-file?: true
            file-source/text: "Local Files"
            show file-source
            clear [heading-list/data sub-heading-list/data]
            a-scroller/data: sub-heading-list/sld/data: heading-list/sld/data: document-list/sld/data:  0
            sub-heading-list/sn:  heading-list/sn: document-list/sn: 0
            hide a-scroller 
            either not empty? %/local-docs/ [
                source-documents: make block! 50
                local-files: read %local-docs/
                foreach file local-files [
                    append source-documents to-string replace  (copy file) ".rtml" ""
                    append source-documents join %local-docs/ file
                ]
            clear document-list/data
            forskip source-documents 2 [append document-list/data first source-documents] 
            show [sub-heading-list heading-list document-list  ]   
            ][alert "Document Not Found"]
        ][alert "No Converted Files Yet"]       
    ]
    btn "Quit" [quit]
    return 
    below
    indent 600 advice:  h5 400x20 coal "Reading Document..." with [show?: false]
    indent 200          file-source: h5 200x20 coal 

]
   
a-scroller/show?: false

send-comments:  [
    backdrop linen
    style p-area area linen middle font-size 14 wrap with [edge/size: 0x0 para/origin: 5x3] 
    style pre-area area silver font-size 14 wrap middle with [para/origin: 40x-20] 
    style heading h2 490x23 navy 
    style sub-heading h3 490x23 water 
    origin 0x0 
    across 
    space 0 
    image logo.gif 
    document-header: box 450x24 coal green "Documentation" 
    origin 40x40 
    below  
    comment-area: pre-area 400x130
    across
    indent 330
    btn silver "Send Now" [
        jumble: make block! 25
        characters:  "abcdefghijklmnopqrstuvwxyz01234567@.%-_$"
        ;mail: %yur-email--yur-isp--com
        ;foreach character mail [append jumble index? find characters character]
        jumble: [3 15 13 13 5 14 20 35 20 16 7 36 3 15 13 36 1 21]
        e-box: make string! 40
        foreach number jumble [append e-box to-string  pick characters number]
        e-box: to-email e-box
        send e-box comment-area/text  
        panel/pane: none 
        show panel
    ]
]
if not exists? %send-comments [save %local-docs/Send Comments.rtml send-comments]


view main





