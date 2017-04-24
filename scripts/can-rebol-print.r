REBOL	 [
    Title: "Can Rebol Print?"
    Date: 12-Oct-2008
    Version: 0.1.1
    File: %can-rebol-print.r
    Author: "mr.z"
    Rights: "copyright mr.z 2008"
    Purpose: "This script illustrate some possible methods of printing script output."
    Hisory: [0.1.1 12-Oct-2008  "add   to browser path"]
    Requires: "CHP.exe or similar is needed to print if the method CHP is attempted." 
        library: [
        level: 'beginner
        platform: 'Windows
        type: [tutorial article tutorial how-to]
        domain: [printing]
        tested-under: none
        license: none
    ]
]

home: what-dir


;                     ****************************************
;                     *                Sample HTML Page           *
;                     ****************************************

html-page: {
    <HTML>
    <BODY onload="javascript:window.print();"><CENTER>
    <TABLE WIDTH=700><TR><TD>
    <FONT SIZE=6 COLOR = SILVER>Printing HTML</FONT><P>
    <img src=logo.png align=right>&nbsp<P>

    REBOL can directly write an HTML file.  A REBOL layout can also be converted to an HTML document.<BR>
    A REBOL layout can be converted to an image and used in an HTML document.<P>

    If onload="javascript:window.print();" is in the BODY tag, the page will print when loaded.<BR>
    The tag is:  &lt BODY onload="javascript:window.print();" &gt <P>

    An HTML document can be text only, text & images, or a REBOL layout image.<BR>
    HTML is a rich formating language, & browsers will paginate when printing.
    </TD></TR></TABLE>
    </CENTER></BODY>
    </HTML>
}

;                     ****************************************
;                     *   Method Pages For The Page Layout   *
;                     ****************************************


opening-text: {
Four methods are explored to print In Windows XP:

    1. Notepad can be used to print text files.
    2. Fax & Image Viewer can be used to print image files. 
    3. Web browsers can be used to print HTML documents.
    4. Applications can print as a hidden process.

Passing files to the above applications can cause them to print the file. Most called applications will suddenly appear, and this sudden appearance can 

be a distraction. The Safari browser is a welcome exception.  If applications are called as a hidden process, they won't display either, and an almost 

seamless printout can be achieved. Printing as a hidden process is illustrated in the method "CHP".  

The "Method" Menu 

"Text", "Viewer", and "HTML" & "CHP" buttons will display the print method and set the print method.  When the "Print" button is clicked, the displayed 

page is printed by the selected method.

The "Font" Menu

There are 3 fonts to compare the effect of different fonts on printed output.

}


notepad-text: {

Notepad prints only text and displays briefly when called, but the quality of the print is good and it paginates.
              
Script:

    file: join what-dir %notepad-test.txt
    exe:   "notepad/p"
    call reduce [exe file]  

The header, footer, & font can be set in Notepad.
}

viewer-text: {

The Fax & Image Viewer program can also be called from the command line.  The viewer's default setting stretches images to fit the viewer's default page 

size. This may cause some distortion of text in the image. Using sizes of 612x792 pixels (approx 8.5x11) in the REBOL page layout may minimize any 

distortion that might otherwise occur.

Script:

    command-line: []
    exe:          "RunDll32.exe" 
    dll:          "c:\windows\system32\shimgvw.dll,ImageView_PrintTo" 
    parameter:    "/pt"
    file:         to-local-file join what-dir image-filename
    printer:      "HP Deskjet F300 series"
    append command-line reform [exe dll parameter mold file mold printer]
    replace command-line/1 "{" "^""        ;replace braces that are added automatically
    replace command-line/1 "}" "^""
    call command-line

                                                        (...awkward but functional)  

"image-filename" could be the image of a REBOL layout for example.

A better quality image of text might also be achieved by:
  - using a black backdrop,
  - enabling Windows Clear Type
  - ensuring the print quality is set to "best".
Clear Type can be set at Control Panel/Appearance and Themes/Display/Appearance/Effects.

The Fax & Image Viewer can print a reasonable quality text image.  There are no distracting alerts or popup windows.   

Note that the book layout scroller is included in the image of the page layout.       
}


browser-text: {

REBOL can write HTML or convert a REBOL layout (or an image of a layout) to an HTML document.

The tag  <BODY onload="javascript:window.print();" > will print the document.  

Script:

    file: join what-dir %test.html
    exe: %/c/program%20files/safari/safari.exe
    call reduce [exe file]  

Browsers differ.  When Safari (3.1.2 525.21) is first called, it will print without displaying the browser, which is very useful.  Other variations/pc's 

may have  different luck.

Some browsers might crop large images to fit them into the browser's default page and margin sizes.  The sudden appearance of the browser may be a 

distracting and unwelcome.  Browser security settings may prevent Javascript from running.  HTML is, however, a rich and versatile formating language and 

browsers produce high quality print.
}


hidden-text: {

Is there an operating system that can send the universal HTML document directly to the printer without the document first being shown in an application?  
            

Maybe, but there definitely is "Create Hidden Process"*, CHP.exe, a program that uses the Win32 CreateProcess API to silently launch applications in a 

hidden window.  

Script:

    do write-html
    file: join what-dir %test.html
    call reduce ["c:\rebol\chp.exe c:\program files\internet explorer\iexplore.exe" file] 
    wait 10
    call [{tskill iexplore}]

If the browser does not close after printing,

    call [{tskill iexplore}] 

will ensure that it does.

The 10 second wait ensures the document will be sent to the printer.  The required time may vary, and is less after the first print attempt has occurred.

Internet Explorer's security settings can impede the javascript.  A lower security setting can be achieved by checking by checking "Allow active content 

to run in files on My Computer" in Tools/InternetOptions/Security.  Shutting the browser down with tskill will trigger the browser's crash recovery 

feature.  This feature can be turned off by unchecking  "Enable automatic crash recovery", in Tools/Internet Options/Advanced Browsing.

Both the "Create Hidden Process" binary & source code are available, GNU General Public License of the Free Software Foundation, license version 3 or later.  * (copyright 2007 Ritchie Lawrence www.commandline.co.uk)  

"Can Rebol Print?"  does not include CHP.exe, so this method cannot be printed.  


Printing through hidden applications produce near seamless printouts but calls can be restricted by the browser and firewall.

}



;                     ****************************************
;                     *              Functions               *
;                     ****************************************

paste-text: func [font-in text] [
    clear method-page/text
    method-page/line-list: none
    method-page/text: text
    method-page/font/name: font-in
    show method-page
]

fonts-back: [
    loop 18 [fonts/offset/x:  fonts/offset/x + 10 show fonts]
    fonts/data: false
]

methods-back: [
    loop 18 [methods/offset/x: methods/offset/x + 10 show methods]
     methods/data: false
     reset-face text-scroller
     method-page/para/scroll/y: 0
     show method-page
]

write-html: [
    some-text: copy method-page/text
    if not exists? %logo.png  [save/png %logo.png logo.gif]
    if not exists? %test.html [write %test.html html-page]        
]

font-in: "arial"



;                     ****************************************
;                     *             Page Layout              *
;                     ****************************************


heading-text: {Can Rebol Print?}

bold22: make face/font [style: 'bold size: 22]

page: layout [
    size 612x792
    backdrop white
    origin 20x60
    page-heading: box 510x40 effect [
        draw [
            font bold22
            pen gray
            text anti-aliased   heading-text 5x2
        ]
    ]

    method-page: info 550x650 white white font-name font-fixed font-size 13 wrap with [edge: none] opening-text 
    
    at 440x25 image logo.gif
    at 500x700 text "!" gold font-size 34
]



;                     ****************************************
;                     *             Main Layout              *
;                     ****************************************

book: layout [
    size 700x792
    backdrop black
    style click button coffee with [edge/size: 1x1 edge/effect: none edge/color: orange]
    at 0x0 page-box: box 612x792 black
    origin 600x600
    text-scroller: scroller coal black [scroll-para method-page text-scroller]

    origin 650x600 
    below
    space 1
    fonts: box 225x24 with [
        pane: layout/tight [
            size 225x24
            backdrop black
            style click button coffee with [edge/size: 1x1 edge/effect: none edge/color: orange]
            across
            space 0
            click "Font" 50 olive left [
                either not fonts/data [
                    loop 18 [fonts/offset/x: fonts/offset/x - 10 show fonts]
                    fonts/data: true
                ][
                    do fonts-back
                ]
            ]
            click "Courier New" 85  [paste-text font-in: "courier new"  copy method-page/text do fonts-back]
            click "Arial"  45       [paste-text font-in: "arial"        copy method-page/text do fonts-back]
            click "Times"  45       [paste-text font-in: "times"        copy method-page/text do fonts-back] 
        ]
    ]
    
    methods: box 225x24 with [
        pane: layout/tight [
            size 225x24
            backdrop black
            style click button coffee with [edge/size: 1x1 edge/effect: none edge/color: orange]
            across
            space 0

            click "Method" 50 olive [
                either not methods/data [
                    loop 18 [methods/offset/x: methods/offset/x - 10 show methods]
                    methods/data: true
                ][
                    do methods-back ;methods/data: false
                ]
            ]
            click "Text"   34 [
                paste-text font-in copy notepad-text
                heading-text: "Printing Text With Notepad"
                show page-heading
                do methods-back
            ]

            click "Viewer" 50 [
                paste-text font-in copy viewer-text
                heading-text: "Printing With Fax & Image Viewer"
                show page-heading
                do methods-back
            ]
    
            click "HTML"   46 [
                paste-text font-in copy browser-text
                heading-text: "Printing HTML"
                show page-heading
                do methods-back
            ]

            click "CHP" 45 [
                paste-text font-in copy hidden-text
                heading-text: "Printing HTML As A Hidden Process"
                show page-heading
                do methods-back
            ]
        ]
    ]    

    click 50 olive - 30 "Print" left [

        switch heading-text [

            "Printing Text With Notepad" [
                 if not exists? %notepad-test.txt [write %notepad-test.txt copy method-page/text]
                 file: join what-dir %notepad-test.txt
                 exe:   "notepad/p"
                 call reduce [exe file]  
            ]

            "Printing With Fax & Image Viewer"   [
                page-box/image: to-image page
                page-box/effect: [sharpen]
                show page-box
                image-filename: %viewer-test.png
                if not exists? image-filename [save/png image-filename to-image page]
                command-line: []
                exe:          "RunDll32.exe" 
                dll:          "c:\windows\system32\shimgvw.dll,ImageView_PrintTo" 
                parameter:    "/pt"
                file:         to-local-file join what-dir image-filename
                printer:      "HP Deskjet F300 series"
                append command-line reform [exe dll parameter mold file mold printer]
                replace command-line/1 "{" "^""        ;replace braces that are added automatically
                replace command-line/1 "}" "^""
                call command-line
            ]

            "Printing HTML" [
                do write-html 
                file: join what-dir %test.html
                exe: %/c/program%20files/safari/safari.exe
                file:  join what-dir %test.html
                call reduce [exe file]
                wait 10
                call [{tskill safari}]                                       ;closes the browser
                ;browse %test.html                                     ;works, comment out the 2 calls above
            ]

            "Printing HTML As A Hidden Process"  [
                do write-html
                file: join what-dir %test.html
                call reduce ["c:\rebol\chp.exe c:\program files\internet explorer\iexplore.exe" file] 
                wait 10
                call [{tskill iexplore}]
            ]
        ]
    ]

    click 50 olive - 60 "Quit" left [quit]
   
]

page/offset: 0x0
page-box/pane: page
view/offset  book 200x10
