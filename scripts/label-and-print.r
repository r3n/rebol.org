REBOL [
    Title: "Make And Print A CD Label"
    Date: 07-01-2007
    File: %label-and-print.r
    Author: R. v.d.Zee
    Owner:   "R. v.d.Zee"
    Rights:  "Copyright (C) R. v.d.Zee 2008"
    Purpose: {
         This script illustrates how CD labels may be drawn and printed with REBOL and
         illustrates how REBOL output may be printed when incorporated into an HTML page.
    }
    Library: [
        level: 'beginner
        platform: 'all
        type: [demo how-to]
        domain: [graphics printing text]
        support: none
        tested-under: [View 1.3.2.3.1 [Windows]]
        license: none
        see-also: [%pdf-labels.r %bestfit.r]
    ]
    Note: {
        Vectorial text of the Draw dialect is used for the CD label title.
        The vector points to bend the text around the label are determined with
        the Pythagorean Theorem.

        The drawn layout of the label is presented in the GUI.  The layout may be saved
        as a PNG image.  The script can incorporate this image into an HTML page. 

        The HTML page includes Javascript's onload command and print function.

        So the script calls the PC's browser, which loads the HTML page.  The
        Javascript in HTML page causes the page to be printed when the page is loaded.

        Finally, %label-and-print.r deletes the HTML page with the "Quit" button.    

        Other scripts that may be of interest: 
        -  %pdf-labels.r, a script by Gregg Irwin for making 3x10 labels from an 8.5x11 PDF document.
        -  %bestfit.r, a script by Mauro Fontana to list the files that best fill up the available disc space.

        This script is provided "as is", without warranty of any kind, express or implied, 
        including but not limited to the warranties of merchantability, fitness for a particular 
        purpose and non infringement. In no event shall the author or copyright holder(s) be liable 
        for any claim, damages or other liability, whether in an action of contract, tort or otherwise,
        arising from, out of or in connection with the software or the use or other dealings in 
        this script.
    }
]

either exists? %all-cds.txt [
    all-cds: load %all-cds.txt
    last-number: first all-cds
][
    all-cds: make block! 50
    last-number: 0
]

start-sketch: [
    font bold32
    line-width 1
    pen silver
    text  vectorial
]


label-maker: func [title-string][
    radius: 228 - 32
    center: 300x300
    x: 80
    circumference: 2 * pi * radius
    intervals: round circumference / 32
    points: make block! intervals
    loop  intervals [
        radius-squared: radius * radius
        side: center/x - x
        side-squared: side * side
        y: center/y - round square-root absolute radius-squared - side-squared 
        if y > 300 [y: 300]
        append points as-pair x y
        x: x + 10
    ]


    do rejoin ["points/" (length? points) "/x: points/" (length? points) "/x - 3"]
    do rejoin ["points/" (length? points) "/y: points/" (length? points) "/y + 3"]

    characters: (length? title-string)
    if characters > 28 [title-string: copy/part title-string 28 characters: 28]
    loops: (18 - round (.5 * characters))
    loop loops [insert title-string " "]

    bold32: make face/font [style: 'bold size: 32 name: font-fixed]

    label-sketch: copy start-sketch        ;copy start-sketch for a new sketch to prevent overwriting the title

    append label-sketch rejoin [points title-string]
    append label-sketch        [line-width 2 circle center 223]
    append label-sketch        [line-width 1 circle center  38]

]

file-saved?: false

label: layout [
    size 600x600
    origin 0x0   
    title-box: box 600x600 white effect [draw label-sketch]
    origin 250x140 sequence-info: info 100x40 font-size 25 center middle font-size 15 with [edge: none]
]


controls: layout [
    size 600x650
    backdrop effect [
        gradient 0x1 255.255.255 190.190.190 draw [
            pen none 
            fill-pen linear 47x913 0 146 186 4 2 139.69.19.154 44.80.132.144 255.0.0.207 0.48.0.165 0.48.0.176 100.136.116.180 
            64.64.64.152 0.0.255.146 100.136.116.142 128.128.0.186 128.128.0.199 178.34.34.159 178.34.34.192 160.180.160.146 
            255.0.0.201 245.222.129.152 box 0x0 600x650 
            pen none 
            fill-pen conic 911x932 0 186 235 3 7 245.222.129.136 255.228.196.132 0.255.255.136 76.26.0.147 box 0x0 600x650 
            pen none 
            fill-pen cubic -116x-136 0 267 302 4 9 255.255.0.195 255.0.0.187 0.0.0.198 170.170.170.181 0.128.128.203 72.72.16.196 
            128.128.0.210 255.255.240.176 64.64.64.149 128.0.128.145 64.64.64.159 0.0.255.156 179.179.126.142 128.0.128.185 
            179.179.126.149 0.255.0.137 0.0.255.210 255.255.0.149 box 0x0 600x650
        ]
     ]
 
    origin 0x0
    label-box: box 600x600
    across

    
    indent 200 title-input: field effect [gradient 139.123.107 126.94.58] font-size 15 250 [
        title: copy face/text
        new-cd-number: last-number + 1
        sequence-info/text: new-cd-number
        label-maker copy title-input/text
        label-box/pane: label
        show label-box
    ]

    btn "Save" [
        insert all-cds title
        insert all-cds new-cd-number
        save %all-cds.txt all-cds
        file-saved?: true
        save/png to-file join title %.png to-image label
        last-number: new-cd-number
    ]

    btn "Print" [
        either file-saved? [
            file-saved?: false
            start-page: [
                <htmL>
                <head>
                <script language="Javascript1.2">{ function printpage()  ^{ window.print() ^}}
                </script>
                </head>
                <body bgcolor="#FFFFFF" topmargin=20 onload="printpage()">
            ]

            print-page: copy start-page

            replace/all  title " " " "
            append print-page to-tag rejoin ["img src = " title ".png"]
            append print-page [
                </body>
                </html>
            ]
            write %printer-page.html print-page
            browse %printer-page.html
            clear title
            clear print-page

            either exists? %all-cds.txt [
                all-cds: load %all-cds.txt
                last-number: first all-cds
            ][
                all-cds: make block! 50
                last-number: 0
           ]

           hide label-box
           clear title-input/text
           focus title-input

          ][
          alert "Save Label Before Printing"
        ]
        
    ]

    btn "Quit" [if exists? %printer-page.html [delete %printer-page.html]  quit]

]

label-box/show?: false

label-box/pane: label
label/offset: 0x0
focus title-input

    view controls