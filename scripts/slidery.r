REBOL [
    title: "Slidery"
    date: 21-Dec-2013
    file: %slidery.r
    author:  Nick Antonaccio
    purpose: {
        See the help-text below.
        An MS Windows .exe. is available at http://re-bol.com/slidery.exe
    }
]

;-------------------------------------------------------------------------

help-text: { 
SLIDERY   by Nick Antonaccio  slidery@com-pute.com  http://rebolforum.com

Slidery allows you to create full screen slide presentations quickly and easily.  Entire presentations are written as essays, using simple markup characters to indicate which elements are displayed in the presentation.  This encourages presenters to think about slide content naturally, as opposed to focusing on the mechanics of laying out page displays.  With Slidery, you create each full presentation within a single text file, and that text file can be used for both printed handouts and as the slide presentation source.

In printed handouts, viewers are able to see which bullet phrases were selected, within the context of the full presentation content.  This allows the audience to more easily understand what each bullet means.  Often in presentations, bullet points are so cryptic that handouts don't serve any useful purpose... or they force the listener to furiously scribble notes, instead of understanding and processing the information being presented.  

Slidery provides a simple solution to those common problems, for both audience and presenter.

Slidery can include images and even entire executable programs in a presentation.  This allows you to create features which are difficult to complete in other presentation systems.  The potential capabilities of this option are limited only by your needs and creative abilities.  You could, for example, include bar charts which display live data collected from a web survey.  Or you could include formulas with computations performed live, using slider controls or other widgets.  You could include spreadsheet calculations performed from files read live during a presentation, etc.  The code used to build powerful little apps is simple to learn.

Slidery runs instantly, without installation, on Windows, Mac, Linux, and Android, as well as on many legacy platforms.  The entire system is about 1/2 meg (small enough even to email every OS version as a tiny attachment), so you can be sure your presentation will run anywhere there is a computer.


HOW THE PROGRAM WORKS:

By default, the folder C:\slidery\ is created as a working directory, so if you already happen to have a folder by that name, you may want to move contents elsewhere.  If that folder can't be created (for example, on PCs with restricted security access), you'll be prompted for an alternate folder to use.

The first dialogue displayed by the program asks for some basic layout settings:

The font size settings are used to set the header, bullet, sub-bullet and subtext sizes.  This allows some generalized control of the presentation layout sizing (i.e., how much info can appear on screen, how items fit on different screen resolutions, etc.).  Click each compontent to choose a size (defaults are shown in parentheses).

The header and bullet color options allow you to customize the colors in your presentation.  Click each item to select colors using a popup color selector.

The "bullet" option allows you to choose the character(s) displayed at the beginning of each bullet point line.  Bullets can be as many characters as desired (defaults are a single asterisk and a single hyphen, each followed by a single space).

The uppercase option allows the system to automatically capitalize the first letter of each bullet point.  The default is 'true'.  Set it to false to leave all bullet points upper/lower case, as-is in the source text.

The max lines option allows you to set a maximum number of bullet points on each slide.  Topics (headers) which contain more than the max number of bullet lines will automatically bleed over onto new slides.  This ensures that bullet points won't disappear below the bottom of the presenter's screen display area.  Automatic bleeding saves the author from having to manually break up source texts with numerous headers to layout page content.  Together with the font size options, the max lines option allows presenters to quickly fit the content to any given screen size, at the moment of presentation.  

NOTE:  since sub-bullet items can be of a different font size than bullet items, a relative size is calculated, and the number of sub-bullets allowed on a page is adjusted so that each complete slide layout is approximately the same size as the set max lines size.  You can adjust the ratio used in this calculation by setting the "Bleed Sizing Factor" option.  In most cases, these settings can all be left at the default, and all you need to set is the number of bullets per slide.

Use the "Always on Top" option to keep any other windows from popping up in front of your presentation (currently on MS Windows only).

With the file option, you can select an existing presentation file, or create a new file name.  Presentation files can also be loaded directly from any URL - you can save your presentations as text files on your FTP or http web server, and read directly from the web address.  If you create a new file, a sample template with 2 generic slides, a slide with 2 image examples, and a slide with live running code, is generated.  Whether the file is newly created or loaded from a previous session, you can edit and save the layout, or simply quit the editor to view the presentation.

OPTION SETTINGS ARE SAVED in the file C:\slidery\slidery-settings, and reloaded every time the program runs, so that you can instantly restart any presentation using the exact same settings.  To move your presentation settings to another machine, simply copy this single file, along with the presentation source text file.  To restart a presentation with all the original option settings, either rename or delete the slidery-settings file.

The basic presentation syntax is simple:

    Header text (each main slide topic) is preceded with "===",
        and headers end with a newline (carriage return).
        
    Bullet items are enclosed in square brackets [].
        A bullet's extended text follows the closing bracket.
        During the presentation, you can click on any bullet to
        display its extended text.

    Sub-bullet items are also enclosed in square backets, 
        and each sub-bullet item is marked with an "*" (precede
        each sub-bullet item with an asterisk).

    [#image %file] or [#image http://url.com/file.jpg]
        inserts an image (jpg png gif bmp).  You can load from
        a web site, as in http://url.com/file.jpg, or from a
        file on a flash drive, hard drive, etc. on your computer
        using the format %localfile.jpg.

    [#code file.r] includes a Rebol VID (GUI) code file.
        This allows you to include executable code in a live
        presentation.  You can run fully functional apps
        directly *on* a slide.  Just save the Rebol code in
        the specified file, and be sure to use unique variables
        that aren't duplicated elsewhere in the slide layout.

NOTE:  double quotes (") in headers and bullet points will be changed to single quotes (').

Below is an example layout.  It contains 4 slides.  The first 2 slides contain 3 bullet points, each with some extended text that can be read by clicking on the bullet points in the presentation, and each with 2 sub-bullet points.  The third slide contains 2 bullet points with extended text, and 2 images, one loaded from a web URL and the other from a local file (logo.png).  The last slide contains one bullet and a layout with some executable code (a small app that is contained in the file app.r):

    ===Slide Header 1
    [Item 1.1] in slide 1 has this text content...
    [*sub-bullet 1.1.1 *sub-bullet 1.1.2]
    [Item 1.2] in slide 1 has this text content...
    [*sub-bullet 1.2.1 *sub-bullet 1.2.2]
    [Item 1.3] in slide 1 has this text content...
    [*sub-bullet 1.3.1 *sub-bullet 1.3.2]
    ===Slide Header 2
    [Item 2.1] in slide 2 has this text content...
    [*sub-bullet 2.1.1 *sub-bullet 2.1.2]
    [Item 2.2] in slide 2 has this text content...
    [*sub-bullet 2.2.1 *sub-bullet 2.2.2]
    [Item 2.3] in slide 2 has this text content...
    [*sub-bullet 2.3.1 *sub-bullet 2.3.2]
    ===Images
    [Image #1] is loaded live from a URL.
    [#image http://rebol.com/view/bay.jpg]
    [Image #2] is loaded from a local file.
    [#image logo.png]
    ===Slide Header 4
    [Running code] is loaded from a file.
    [#code app.r]

During the presentation, you can use these controls to view slide content:

    right arrow key, space bar, or left mouse button
        advances to the next slide
    left arrow key or right mouse button 
        moves back 1 slide
    mouse click any bullet point 
        to view the bullet's extended text content 
        [Esc] key to exit this view
    [F1] starts ANNOTATION MODE
        In this mode, a screen shot of the current
        slide is opened, on which you can draw
        annotations with the mouse.  [F2] saves the
        current screenshot and annotations to a .png
        image file of your choice.  [F3] erases all
        current annotations.  [ESC] closes draw
        mode and returns to the presentation.
    [Esc] key to end the presentation

Be sure to load the business-programming.txt presentation example in the C:\slidery\ folder, to see a longer example of text presented using Slidery.  That text was taken directly from the text introduction at http://business-programming.com . It should give you a good idea of how simple it is to create long a slide presentation from a single prose text file, with lots of bullet points that bleed onto numerous slides.}

;-------------------------------------------------------------------------

; THIS CODE CREATES A SAMPLE TEMPLATE:

do %e                       ; editor undo/redo and options
home-folder: %/c/slidery/
if error? try [make-dir home-folder] [
    home-folder: request-dir
    make-dir home-folder
]
change-dir home-folder
write %sliders.r {
    slider 200x20 [
        x/text: round 100 * value 
        z/text: (to-integer x/text) * (to-integer y/text) 
        show slide
    ]
    slider 200x20 [
        y/text: round 100 * value 
        z/text: (to-integer x/text) * (to-integer y/text) 
        show slide
    ]
    across
    x: field 40 "1" text "X" y: field 40 "1" text "=" z: field 60
    return
}
save/png %logo.png to-image layout [image 150x36 logo.gif]
template: copy {}
repeat i 2 [ 
     append template rejoin [{===Slide Header } i newline] 
     repeat j 3 [
         append template rejoin [
             {[Item } j {] in slide } i { has this text content...^/}
             {[*sub-bullet 1 *sub-bullet 2]^/}
         ]
     ]
]
append template {===Images
[Image #1] is loaded live from a URL.
[#image http://rebol.com/view/bay.jpg]
[Image #2] is loaded from a local file.
[#image %logo.png]
===Formulas with Slider Controls
[Running code] is simple - just load it from a file.  This example
is loaded from the file %sliders.r.  It's just normal Rebol VID code. 
[#code sliders.r]
}

;-------------------------------------------------------------------------

; THIS CODE ALLOWS YOU TO LOAD OR CREATE, AND OPTIONALLY MANUALLY EDIT,
; ANY NEW OR EXISTING TEMPLATE (and to adjust some layout settings):

sfile: %slidery-settings
view center-face layout [
    ; backdrop white
    style txt text 120 right
    across
    txt "" btn "Help" [editor help-text] return
    txt bold "FONT SIZES:"
    s1: text "Header" 400x75 font-size 50 [
        face/font/size: to-integer request-text/title/default
            "Header Font Size (50):" form face/font/size
        show face
    ]
    return
    txt ""
    s2: text "Bullet" 140x50 font-size 30 [
        face/font/size: to-integer request-text/title/default
            "Header Font Size (30):" form face/font/size
        show face
    ]
    s2a: text "Sub-Bullet" 120x50 font-size 22 [
        face/font/size: to-integer request-text/title/default
            "Header Font Size (22):" form face/font/size
        show face
    ]
    s3: text "Subtext" 120x50 font-size 20 [
        face/font/size: to-integer request-text/title/default
            "Header Font Size (20):" form face/font/size
        show face
    ]
    return
    txt bold "COLORS:"
    hc: text "Header" 90 white 0.0.255 [
        header-color: request-color
        unless header-color = none [hc/color: header-color show hc]
    ]
    bc: text "Bullet" 90 white 0.0.0 [
        bullet-color: request-color
        unless bullet-color = none [bc/color: bullet-color show bc]
    ] 
    sbc: text "Sub-Bullet" 90 white 120.120.120 [
        sub-bullet-color: request-color
        unless sub-bullet-color = none [
            sbc/color: sub-bullet-color show sbc
        ]
    ] return
    txt "Bullet:" b: field 60 "* " 
    txt "Sub-Bullet:" b2: field 60 "- "  
    return 
    txt "Uppercase:" upr: drop-down 60 data ["true" "false"]  
    txt "Always on Top:" ot: check
    return
    txt "Max Lines:" mlines: field 60 "10"
    txt "Bleed Sizing Factor:" bf: field 60 "1.3"
    return
    txt "Settings File:" sf: field 190 "slidery-settings"
    btn "Files..." [
        sf/text: request-file/only/file %slidery-settings show sf
    ]
    btn "URL" [
        if error? try[
            url-file: to-url request-text/title/default "URL:"
                "http://re-bol.com/slidery-settings"
            local-sfile: last split-path url-sfile
            either exists? local-sfile [
                if true = request {That file already exists locally - 
                        overwrite with the downloaded file?} [
                    write local-sfile read url-sfile
                ]
            ][
                write local-sfile read url-sfile
            ]
            sf/text: local-sfile show sf
        ][alert "Error downloading URL"]
    ]
    return
    txt "File:" f: field 190 "template.txt" [do-face load-it 1]
    btn "Files..." [f/text: request-file/only/file %template.txt show f]
    btn "URL" [
        if error? try[
            url-file: to-url request-text/title/default "URL:"
                "http://re-bol.com/business-programming.slides"
            local-file: last split-path url-file
            either exists? local-file [
                if true = request {That file already exists locally - 
                        overwrite with the downloaded file?} [
                    write local-file read url-file
                ]
            ][
                write local-file read url-file
            ]
            f/text: local-file show f
        ][alert "Error downloading URL"]
    ]
    return
    txt "" load-it: btn "LOAD PRESENTATION" [
        save sfile compose [
            (file: to-file f/text)
            (f1-size: to-integer s1/font/size)
            (f2-size: to-integer s2/font/size)
            (f2a-size: to-integer s2a/font/size)
            (f3-size: to-integer s3/font/size)
            (bleed-factor: to-decimal bf/text)
            (b-text: b/text)
            (b2-text: b2/text)
            (upprcs: to-logic either "true" = get-face upr [true] [false])
            (ontp: get-face ot)
            (max-lines: to-integer mlines/text)
            (header-color: hc/color)
            (bullet-color: bc/color)
            (sub-bullet-color: sbc/color)
            (sfile: to-file sf/text)
        ]
        unview
    ]
    do [
        set-face upr "True" 
        if exists? sfile [
            ss: load sfile
            f/text: ss/1
            s1/font/size: ss/2
            s2/font/size: ss/3
            s2a/font/size: ss/4
            s3/font/size: ss/5
            bf/text: ss/6
            b/text: ss/7
            b2/text: ss/8
            set-face upr form ss/9
            set-face ot either 'true = ss/10 [true][false]
            mlines/text: ss/11
            hc/color: ss/12
            bc/color: ss/13
            sbc/color: ss/14
            sf/text: ss/15
        ]
        focus f
    ]
]
if false = value? 'file [quit]
if %"" = file [quit]
unless exists? file [write file template]
editor file   ; ONLY USE 'SAVE' (NOT 'SAVE-AS')

;-------------------------------------------------------------------------

; THIS CODE PARSES THE TEMPLATE AND BUILDS THE GUI CODE FOR EACH SLIDE:

slides: copy []
topics: copy []
parse/all replace/all read file {"} {'} [
    [
        any [
            thru {===} copy header-p to {===} (append topics header-p)
            | thru {===} copy header-p to end (append topics header-p)
        ] 
        to end
    ]
]
remove-each topic topics [topic = ""]
foreach topic topics [if error? try [
    current-topic: trim/lines copy/part topic l: index? find topic newline
    bleeds: copy []
    bleed: copy next parse/all (at topic l) "[]"
    bleed-page: copy []
    bleed-count: 0
    foreach [used unused] bleed [
        either find used "*" [
           foreach u next parse/all used "*" [
               append bleed-page reduce [(join "*" u) ""]
               bleed-count: bleed-count + (
                   f2a-size / f2-size * bleed-factor
               )
               if (round/ceiling bleed-count) >= max-lines [
                   append/only bleeds bleed-page
                   bleed-page: copy []
                   bleed-count: 0
               ]
           ]           
        ] [
            append bleed-page reduce [used unused]
            bleed-count: bleed-count + 1
            if bleed-count >= max-lines [
                append/only bleeds bleed-page
                bleed-page: copy []
                bleed-count: 0
            ]
        ]
    ]
    if not empty? bleed-page [append/only bleeds bleed-page]
    foreach bullets bleeds [
        append slides current-topic
        gui: copy []
        repeat i length? bullets [
            either odd? i [
                case [
                    find cur: bullets/(i) {#image } [
                        append gui compose [
                            image load (find/tail cur "#image ")
                        ]
                        includes-image: true
                    ]
                    find cur {#code } [
                        append gui load to-file find/tail cur {#code }
                        includes-image: true
                    ]
                    find cur {*} [ 
                        foreach sub-bullet next parse/all cur "*" [
                            append gui compose [
                                across 
                                text font-size (f2a-size) ""
                                text font-size (f2a-size) ""
                                title font-size (f2a-size)
                                sub-bullet-color (join 
                                either sub-bullet = "" [""] [b2-text] 
                                either upprcs [
                                    (uppercase/part sub-bullet 1)
                                ][
                                    sub-bullet
                                ])
                                below
                            ]
                        ]
                        includes-image: true
                    ]
                    true [
                        append gui compose [
                            title font-size (f2-size) 
                            bullet-color (join 
                            either cur = "" [""] [b-text] 
                            either upprcs [
                                (uppercase/part cur 1)
                            ][
                                cur
                            ])
                        ]
                        includes-image: false
                    ]
                ]
            ] [
                unless includes-image = true [
                    append/only gui compose/deep [
                        view/new center-face layout [
                            size system/view/screen-face/size
                            backdrop white
                            area system/view/screen-face/size - 40x40 
                                wrap font-size (f3-size)
                                (join bullets/(i - 1) bullets/(i))
                            key #"^[" [unview]
                        ]
                    ]
                ]
            ]
        ]
        append/only slides gui
    ]
][alert join "Error parsing: " topic]]

;-------------------------------------------------------------------------

; THIS CODE DISPLAYS THE SLIDES:

if ontp [
    user32.dll: load/library %user32.dll
    find-window-by-class: make routine! [
        ClassName [string!] WindowName [integer!] return: [integer!]
    ] user32.dll "FindWindowA"
    SetWindowPos: make routine! [
        hWnd [integer!] hWndInsertAfter [integer!] X [integer!] 
        Y [integer!] cx [integer!] cy [integer!] wFlags [integer!] 
        return: [integer!]
    ] user32.dll "SetWindowPos"
]

write %blank-backdrop.r {
REBOL []
view/options center-face  layout [
    size system/view/screen-face/size
    backdrop white
     key #"^[" [quit]
] 'no-title
}
launch %blank-backdrop.r
wait .3

indx: 1
forever [
    slide: compose [
        size system/view/screen-face/size
        backdrop white [
            if indx < ((length? slides) / 2) [indx: indx + 1 unview]
        ] [
            if indx > 1 [indx: indx - 1 unview]
        ]
        at 20x20 title font-size (f1-size) 
            header-color (pick slides (indx * 2 - 1))
        box black as-pair (system/view/screen-face/size/1 - 40) 2
        (pick slides (indx * 2))
        box black as-pair (system/view/screen-face/size/1 - 40) 2
        key #"^[" [quit]
        key #" " [
            if indx < ((length? slides) / 2) [indx: indx + 1 unview]
        ]
        key keycode [right] [
            if indx < ((length? slides) / 2) [indx: indx + 1 unview]
        ]
        key keycode [left] [
            if indx > 1 [indx: indx - 1 unview]
        ]
        key keycode [f1] [
            alert {Use the mouse to draw annotations, [F2] to save image,
                [F3] to erase current annotations, [ESC] to quit, Select
                a pen color now...}
            annt-color: request-color
            slide-screenshot: to-image slide
            view center-face layout/tight [
                size system/view/screen-face/size
                scrn: box slide-screenshot feel [
                    engage: func [face action event] [
                        if find [down over] action [
                            append scrn/effect/draw event/offset
                            show scrn
                        ]
                        if action = 'up [append scrn/effect/draw 'line]
                    ]
                ] effect compose/deep [draw [pen (annt-color) line]]
                key keycode [f2] [
                    img-file: request-file/only/save/filter/file "*.png"
                        %screencap1.png
                    if img-file = none [return]
                    if exists? img-file [
                        if not true = request {
                            That file already exists.  Overwrite?
                        } [return]
                    ]
                    save/png img-file to-image scrn
                    alert join "Saved " form img-file
                ]
                key keycode [f3] [
                    if not true = request "Really erase drawing?" [return]
                    scrn/effect/draw: copy compose [pen (annt-color) line]
                    show scrn
                ]
                key #"^[" [
                    if true = request "Really exit drawing mode?" [unview]
               ]
            ]
        ]
    ]
    slide: layout slide
    view/new/options center-face slide 'no-title
    if ontp [
        hwnd: find-window-by-class "REBOLWind" 0
        SetWindowPos hwnd -1 0 0 0 0 3
    ]
    do-events
]
quit