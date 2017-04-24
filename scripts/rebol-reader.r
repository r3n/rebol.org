REBOL [
    Title:   "Rebol Reader"
    Date:    8-Mar-2006
    Name:    'Rebol-Reader

    Version: 0.1.2
    File:    %rebol-reader.r

    Author:  "R.v.d.Zee"
    Owner:   "R.v.d.Zee"
    Rights:  {Copyright (C) R.v.d.Zee 2006}

    Tabs:    4

    Purpose: {
        The script is a method to provide an orderly collection of scripts and
        documents to form a  Rebol reference.
    }
    Library: [
        level: 'beginner
        platform: 'Windows 
        type: 'tool 
        domain: [GUI] 
        tested-under: none
        support: none 
        license: none 
        see-also: none
    ]
Notes: {

                                   Welcome To The Rebol Reader !


When first opened, the Rebol Reader doesn't appear to contain anything - except a list of Topics.   The 

Rebol Reader is a book waiting to be written!  

The Rebol Reader is a both a method and a script.  The Reader's intended purpose is to provide a means 

by which information may be  gathered and created, reviewed and edited, and also  transferred between 

documents.  

The Reader, with it's organised file structure of Topics and Titles, brings together the internet browser, a 

PDF reader, a text editor,  the Rebol Web Blog, the Rebol/Core Manual,  the Rebol Library and the many, 

many Rebol related Internet documents - and... the script writer.  

The Firefox Browser and the Adobe Acrobat Reader may be used with this script.  These browsers may 

be  resized and placed over this text area, at the top left of the screen.  There they will  function  almost 

as if they  were designed to be part the Rebol Reader.  

The Rebol Reader may make it  easy to travel back and forth between related documents.   Notes or 

scripts may be created or edited. 

Rebol scripts may also be launched from the Reader, so scripts may be developed, tested and edited.


                                       Getting Started

First, scroll down the Topics and find "Rebol Reader".  Select that and then "Welcome To The Rebol 

Reader" in the Titles text-list.  This document will then reappear!

Scroll the Topics text-list down to "Manual" and download the Rebol/Core manual.
Dowloading the "Desktop Library" script and selecting and reviewing scripts is a good
way to become familiar with the Reader.

Save material using the Firefox browser into the Reader's Topics directory structure.  

Later, when that Topic is picked from the Reader's list, that page and other related titles may  be found in  

the "Titles"  text-list.  Selecting the title  enables it to be viewed again.

Text and Rebol scripts may be displayed in the text area of the Rebol Reader.  PDF files may be viewed 

with the Adobe Acrobat Reader.

Parts of the reference documents may be copied and pasted into new or existing notes or scripts.
    

                                           Long File Names

Long file names with spaces between words may  make for  informative titles which may improve the 

Rebol Reader's usability.  There is no need to write a file suffix in the file name field, as the suffix will be 

provided by the script.


                                              File Back Up

Copies of  %.txt and %.r files may be made when they are read by the Reader.   Copied files may be 

found by selecting the "Back Up" topic.  These files may be deleted with the button "Delete Back Up".


                                         RebolCore  Manual

The Rebol/Core Manual's zip file may automatically download, unzip and be written  into a subdirectory of 

the Manual topic. 


                                                 Library

The Desktop Library may be downloaded with the Internet browser. From the Rebol Reader,  go to  the 

topic "Library" and click the title "Get Desktop Library".  

The download page will open  in the web browser.  From the browser, save the %library.r file into the  

"Topics" directory of the Rebol Reader.  (Only the Topics directory!) 

Then click the title "Install Library". The Library will install and run.  The Rebol Reader will also close at 

this point and will have to be opened again.

These instructions will display again when the "Titles" topic is selected if no library scripts are 

downloaded. 


                                             PDF Documents

The Rebol Reader may also display PDF documents.  The Acrobat Reader may also be resized to fit over 

the Reader's large black text area.  The first time  a PDF title is selected, a pop-up  directory finder will 

appear.  The directory home of the available PDF viewer must then be selected.


                                             Text Editor

The Copy, Cut and Paste buttons of the editor are  limited in their functions:  
    -  Text may not be pasted into highlighted areas.
    -  Text may not be pasted to the end of existing text.
    -  If the keyboard is used or the text scrolled, two attempts to use
       the edit buttons must be made! 
While they have their limitations, these edit buttons are useful.  Please send a comment if you can 

suggest an improvement here.

The Rebol keyboard text edit functions are more reliable:
    -  "Control" & "C" keys:  copy highlighted text
    -  "Control" & "X"  keys:  cut highlighted text & write it to the clipboard
    -  "Control" & "V"  keys:  paste text

                                             No Warranty

This script has no warranty expressed or implied, nor is this script claimed to be suitable for  any 

particular use.



             Copyright R.v.d.Zee  February 21, 2006  All Rights Reserved.





    }


    History: [
        0.1.0    1-Mar-2006 "Created" 
        0.1.1  18-Mar-2006 "Change Rebol Blog Button script"  
        0.1.2  23-Mar-2006 "Change Cut Button"  
        0.1.3  11-Apr-2006 "Replace user REBOL/VIEW lookup with system/options/boot" 
    ]

    Language: 'English
]


home: what-dir
if not exists? %Topics/ [make-dir %Topics]

                     ;*************** Some Suggested Topics  To Start With  **************************

change-dir %topics
topics: ["Areas""Arrows""Rebol Blogs" "Buttons""Calendar""Checkboxes""Clipboard"
            "Draw""Email" "Encryption" "Errors" "Feel""Fields""Files"
            "Gradients""Html""Images""Inform""Ip Adress""Keyboard"
            "Layouts""Mouse""Networking""Panels""Printing""Rebol Reader""Series""Sliders"
            "Sound""Text""Text-list""Server" "Manual" "Projects" "Library"
       ]

                                      ;******************* Make Suggested Topic Directories *********************

foreach topicIn topics [
    if not exists? to-file topicIn [make-dir to-file topicIn]
]

                                        ;******************* Make Required Topics ******************************
 
if not exists? %"Back 20Ups/" [make-dir %"Back Ups"]
if not exists? %"Library Scripts/" [make-dir %"Library Scripts/" ]
if not exists? %Library/scripts/ [make-dir %Library/scripts/ ]


                                         ;**************** Read For Topic Directories ***************
readDirs:  read %.
onlyDirs: make block! (length? readDirs)
onlydirs: make block! (length? readDirs)
foreach itemIn readDirs [if dir? itemIn [append onlyDirs (replace itemIn "/" "") ]]
sort onlyDirs


                                       ;******************* Read For Title Files **************************

readForTitles: [
    readIn: read %.
    while [not tail? readIn] [
        either find [%.txt %.r  %.htm  %.html  %.pdf] find/last first readIn "." [
            readIn: next readIn
            ][remove readIn]                                       ;if the specified file type is not found, remove that file 

from series
    ]
    readIn: head readIn
    sort readIn
]

do readForTitles 


                                    ;****************** Get Titles From File Names *****************

 titlesFromNames: [
    titles: make block! (length? readIn)
    forall readIn [
        parse (to-string readIn/1)  [copy aTitle to "."]
        append titles aTitle
    ]
]

do titlesFromNames


                                   ;*********************** Up Date Title List ******************

upDateTitleList: [
    change-dir keepDir    
    do readForTitles                                           
    do titlesFromNames                 ;titles, the text-list data source now updated
    titlesList/data: titles
    show titlesList
    change-dir %../../                     ;back home


                        ;*************** Pick The New Title & Show It In The Text-List **************** 

    clear-face titlesList ;
    do coverUp
    titlesList/picked: to-block mold fileNameField/text
    forall titles [titles/1: form titles/1]
    pickAt: index? (find titles form  titlesList/picked)
    titlesList/sn: pickAt  - 3                                     ;pushes the picked value further down display
    if pickAt < 3 [titlesList/sn: 0]                             ;adjustment for items at top of list
    titlesList/sld/data: divide (pickAt - 3)  (length? titles) 
    show titlesList
]

change-dir home

                           ;************* Make Block To To  Call Other Programs **************

    thisProgram: array 2                                   ;holds the path of the executable file and the file to run


                    ;************* True Or False Swtiches Enable/Disable Buttons *****************

rebolLoaded:  false                        ; when true enables "Launch" & launches a script
folderLoaded: false                        ; "New Text" & "New Rebol" files need a directory, no folder at startUp 
fileLoaded:      false                        ; enables "Save"  if true, that is, when there is a file for saving
renaming:        false                        ; enables "Rename"  when true, there is a file to rename
newName:       false                        ; only one  input  field is used, so - naming or renaming? 
libraryScript:    false                        ; Desktop Library Rebol Scripts


libraryReadMe: {

Rebol Org maintains an Internet  Script Library.  A desktop version of the library is available and can be 

used with the Rebol Reader.  

To get the Desktop Library, click on the "Get Library"  title below.  The link to the file will open in your 

browser.  Once downloaded, move the file into the Rebol Reader's "Topics" Directory.  The Topics 

directory may now contain all of the topic directories and the file %library.r

Select the "Install Library" title in the Titles list and the Library will install & run.  

The Rebol Reader will also be shut down by this action and must be reopened.
}

if not exists? %"topics/library/Library Read Me.txt"   [
    write  %"topics/library/Library Read Me.txt" libraryReadMe
]

manualReadMe: {




The Rebol/Core Manual may not yet have been downloaded.  If connected to the Internet, 
the Rebol Reader may already be attempting to download and decompress the Rebol/Core Manual.  

Reselect the "Manual" Topic when the file has been downloaded and installed, and also to begin the 

download if you have yet to connect to the internet .


The script "Rebzip" is  used to download and unzip the manual.  

Rebzip was written by  Vincent Ecuyer , 13-Jan-2005. (Version: 1.0.0  File: %rebzip.r)  

}
if not exists? %"topics/Manual/Manual Read Me.txt"   [
    write  %"topics/Manual/Manual Read Me.txt" manualReadMe
]


                                         ;************* Template For New Rebol Scripts *****************  

newRebolText: {                                
REBOL [title: "New Rebol Layout"]

newRebol: layout [

]
                                  view newRebol
        }


                                     ;********** Cover & Uncover Field & Buttons *************

unCover: [
    hide coverBox
    focus fileNameField
]

coverUp: [coverBox/show?: false  show coverBox]

readerFont: make face/font [style: [italic bold] size: 29]                  ; a font for draw
startTopics: read %topics/.                                                               ; to establish topicsList dragger 

size....
 

                                             ; *********** Get Desktop Library ************************

getLibrary: [
    either connected? [
textReader/text: {
        

        When the file is downloaded , It  **Must Be Moved**  To The Reader's 
        "TOPICS" Directory.

        Click "Install Desktop Library" In Titles to start the installation.

        When the installation is finished, the Rebol Reader will be closed
        and must be opened again.
     
     }
    show textReader
    wait 3    
    browse  http://www.rebol.org/cgi-bin/cgiwrap/rebol/download-librarian.r
    ][alert "No Internet" break]
]

installLibrary: [
    either exists? %topics/library.r [
    wait 7
      do %topics/library.r  
     ][alert "Desktop Library Install File  Not Found" break]
]

listLibraryScripts: [
    change-dir join home %topics/LIbrary/scripts/
    keepdir: %scripts/
    do readForTitles

    do titlesFromNames             
    titlesList/data: titles
    show titlesList
    change-dir %../      
    libraryScript: true            
]

                                           ;**************** Rebol Logo ************************

reb-logo60:  load 64#

{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
Sf8F8AIw84T7TKkAAAAASUVORK5CYII=
}

                                    ;**************** Gimp Image Covers Name Field ****************

coverImage: load 64#

{iVBORw0KGgoAAAANSUhEUgAAAUMAAAAuCAIAAAA9TOxgAAAACXBIWXMAAAsTAAAL
EwEAmpwYAAAAB3RJTUUH1gIWBAQH+gD2ygAAAPVJREFUeNrt2IERxCAIBEBxbN+e
00R0EHYbyHwCd/qx946IcZ6nJH9WvQe1mro1oKKbeZHB7PaDjSM1N9lEgk1G+Xt1
KV7d8kKhAP94IW0rvDena+OIezJIW5uMccQ9GXnh7elkcLqW+hiDbO9tmhLQySDW
bbIpgZ/471peUOEb6WRwukaxkOMD2WTQyaD8c1i+H/JCJ/t+0KCT5T2GQScDOlne
02kMdLJZoQKbDE7XoPl1MogMmwxc2WTHKpS/e7KwQFg4XYsMnK4RGdhkwD0ZzY9O
RmTYZBAZNhlwTwbNr5NBXthkcE9+9BwCNtmlBWyyyIAzPtC9Asx4/Zs4AAAAAElF
TkSuQmCC
}

change-dir home
either exists? %programHomes.txt [
    programHomes: load %programHomes.txt
    ][
    programHomes: array 2                                           ;paths of the applications that will be called
    programHomes/1: "placeHolder"                              ;if left to none, will be read back as word! type
    programHomes/2: system/options/boot                   
    save %programHomes.txt programHomes
]


findAdobe: [
    change-dir %"/c/Program Files/"
    adobeReaderHome: programHomes/1: request-dir/title "Find Adobe/Acrobat/Reader"
    change-dir home
    if any [
        adobeReaderHome = none
        (last split-path adobeReaderHome) <> %Reader/
    ][
        alert "Adobe Acrobat Reader Directory Not Found" 
        programHomes/1: "placeHolder" 
        break
    ]
    save %programHomes.txt programHomes
    thisProgram/1:  join programHomes/1 %AcroRd32.exe 
    thisProgram/2: rejoin [home keepDir  filetoRead]
    call thisProgram 
]

change-dir Home
getTitle: ""
                                              ;*****************REBOL READER LAYOUT *************

rebolReader: layout [
    size 1024x764  
    backdrop effect [gradient 0x1 orange pewter ]
    origin 2x600 box 362x200 coverimage
    origin 364x298 box 658x464 mint                                           ;right hand screen corner edge
    origin 365x300 box 655x460 effect [
        gradient 0x1 255.255.255 190.190.190 draw [
            pen none 
            fill-pen diamond 860x1198 0 77 335 6 10 179.179.126.160 0.0.0.146 0.128.128.144 76.26.0.140 

  72.0.90.130 72.72.16.150 0.0.128.160 100.120.100.144 box 0x0 655x460
        ]
    ] 
    origin 365x300 box 466x314     mint                                        ;lower right hand corner edge line
    
    origin 2x2  textReader: area 827x610 wrap font-size 19  0.0.0 0.0.0
    
    style silverButton btn silver 209.131.25 font-color coffee font-size 12 

    origin 30x620
    across
    space 2
    silverButton "Save"  [
        if fileLoaded = true [                                                                          ; if there is a file to be saved
            if newName = false [
                if any [(suffix? filetoRead) = %.txt  (suffix? filetoRead) = %.r] [      ; only .txt or .r
                    if (last split-path keepDir) = %"Back Ups/" [alert "Please Save To Another Topic!" break]
                    write  join keepDir fileToRead   textReader/text 
                    clear textReader/text                                                ;retaining line-list in this case
                    textReader/text: read join keepDir fileToRead
                    show textReader   
                    if (suffix? filetoRead) = %.r [rebolLoaded: true]



                   ;*********** Save %.txt  or %.r BackUp Text Gathered When File First Opened *****************
            
                    fileDate: replace/all to-string now/date "-" ""
                    fileTime: replace/all to-string now/time ":" ""                             
                    insert backUpFileName reduce [filedate filetime]              ;time&date stamp
                    write rejoin [%topics/ %"Back Ups/" backUpFileName] backUpText
                    clear backUpFileName
               ]
           ]
           if newName = true [do unCover ]
       ]
    ] 

    silverButton  "Copy" [
        clear clipboard://
        if system/view/highlight-start <> none [
            write clipboard:// copy/part system/view/highlight-start system/view/highlight-end
        ]
    ]

   silverButton "Cut"  [    
     if system/view/highlight-start <> none       [
         if (length? system/view/highlight-start) > (length? system/view/highlight-end)  [ 
             write clipboard:// copy/part   system/view/highlight-start     system/view/highlight-end 
             textReader/text: find textReader/text system/view/highlight-start 
             replace textReader/text (read clipboard://)   ""
             textReader/text: head textReader/text
             unfocus
             show textReader
           ]
        ]
    ]

    silverButton  "Paste" [
        if any [                
            none? system/view/highlight-start                                    ;do not paste into highlight range
            none? system/view/highlight-end
        ][
            if not none? ctx-text/view*/caret [                                      ; caret to end - wont paste at end
                workingText: copy textReader/text                               ; text to work with
                if not none? (find workingText ctx-text/view*/caret) [
                    lastSection: copy ctx-text/view*/caret
                    replace workingText lastSection ""                           ; from start to caret now workingText        

  
                    insert ctx-text/view*/caret read clipboard://               ; paste to start of caret text
                    append workingText ctx-text/view*/caret 
                    textReader/line-list: 10  ;from none

                    textReader/text: copy workingText
                    show textReader
                    clear [workingText ctx-text/view*/caret lastSection]
                ]
            ]
        ]
    ]
 silverButton "Editor" [
        either exists? %/c/windows/system32/notepad.exe [
            thisProgram/1:  %/c/windows/system32/notepad.exe
            checkOut: attempt [
                thisProgram/2: rejoin [home keepDir fileToRead]  
                call thisProgram 
            ]
          if checkOut = none [alert "Please Select A Topic And Title" ]
         ][
           alert "Editor Not Found"
        ]
    ]
    return

    silverButton   "New Text" [
        either folderLoaded = true [
               if any [
                   (last split-path keepDir) = %"Back Ups/" 
                   (last split-path keepDir) = %LIbrary/
                   (last split-path keepDir) = %Manual/
               ][
                  alert {Please Select Another Topic!}
                  break
            ]
            clear-face textReader  
            clear-face textReaderSlider 
            clear-face titlesList
            textReader/para/origin: 40x10
            textReader/text: backUptext: rejoin [now "^/ ^/"       "**" ]  
            show [textReader  textReaderSlider   titlesList]
            focus  textReader
            fileLoaded: true 
            newName: true
            fileSuffix: %.txt 
            fileToRead: %temp.txt    
            ] [alert  "Please Select A Subject"]
        ]


    silverButton "New Rebol" [
        either folderLoaded = true [
               if any [
                   (last split-path keepDir) = %"Back Ups/" 
                   (last split-path keepDir) = %LIbrary/
                   (last split-path keepDir) = %Manual/
               ][
                  alert {Please Select Another Topic!}
                  break
               ]
            clear-face textReader  
            clear-face textReaderSlider 
            clear-face titlesList
            textReader/para/origin: 40x10
            textReader/text: backUpText: copy newRebolText
            show [textReader  textReaderSlider   titlesList]
            focus  textReader
            newName: true
            fileSuffix: %.r
            fileLoaded: true
            fileToRead: %temp.r                                               ; to satisfy the save 
            ] [
              alert "Please Select A Topic"
        ]
    ]


    silverButton "Rename" [
        if all [
            fileLoaded = true 
            newName  = false
        ] [
            if (last split-path keepDir) = %"Back Ups/" [alert "Please Save To Another Topic!" break]
            renaming:  true
            do unCover
        ]
    ]
    below
    space 0
    origin 55x720 image reb-logo60 [
        either connected? [browse http://www.rebol.com][alert "No Internet"]
    ]
    

                                                 ;************* Field For New Names **************

    origin 30x670  fileNameField: field  320x26 mint font-size 17 

    origin 260x700 namingButton: btn "Save"  font-color coffee [
        if  fileNameField/text <> ""  [                                             
            if any [renaming = true newName = true ] [
                if  find titlesList/data  fileNameField/text [
                    alert  "Document Title  Already Used"
                    break
                ]

                newFileName: to-file join fileNameField/text  suffix? fileSuffix

                                     ;**************** Saving When Renaming A  File **************

                if reNaming = true [

                                          ;*********** Save Edited Text & BackUp Original File *****************

if any [
    ((suffix? fileToRead) = %.txt) = true
    ((suffix? fileToRead) = %.r)    = true
    ][
               if backupText <> textReader/text [
                    write (join keepDir fileToRead) textReader/text        ;save new text before renaming
                    fileDate: replace/all to-string now/date "-" ""
                    fileTime: replace/all to-string now/time ":" "" 
                    backUpFileName: copy filetoRead                            ;backed up as the old file name                

               
                    insert backUpFileName reduce [filedate filetime] 
                    write rejoin [%topics/ %"Back Ups/" backUpFileName] backUpText
                    clear backUpFileName
                ]
               if none?  attempt [rename  (join keepDir fileToRead) newFileName ] [
                   do coverUp
                   alert "Either  File In Use    Or     Invalid File Name "
                    renaming: false    ;has to be since user can go on to another file
                    break
                ]
]
if (suffix? fileToRead) = %.pdf [
                   if none?  attempt [rename  (join keepDir fileToRead) newFileName ] [
                    alert "Either  File In Use    Or     Invalid File Name "
                    break
                ]
]


htmlFolder: copy fileToRead
                if any [                                                                            ;change assoicated html folder name 

too
                    (suffix? fileToRead) = %.htm
                    (suffix? fileToRead) = %.html
                 ][
                   if none?  attempt [rename  (join keepDir fileToRead) newFileName ] [
                    alert "Either  File In Use    Or     Invalid File Name "
                    break
                ]

                    parse (to-string htmlFolder)      [copy oldFolderName  to "."]
                    parse (to-string newfileName)  [copy newFolderName to "."]
                    oldFolder: to-file rejoin [keepDir oldFolderName "_files/"]
                    if exists? oldFolder [
                        rename  oldFolder   to-file (join newFolderName "_files/") 
                        ] 
                    ]
                    unfocus
                    do coverUp
                    do upDateTitleList
                    fileToRead: copy newFileName                                         ;so it can be launched if rebol file
                    renaming: false
                ] 


                                              ;****************Saving A New File **************

                if newName = true [
                    if none?  attempt [write rejoin [keepDir newFileName] textReader/text ] [
                        alert   "Invalid File Name"
                        break
                    ]
                    fileToRead: newFileName 
        
                    backUpText: textReader/text                                    ;where new file is saved and worked on 

again
                    backUpFileName: copy filetoRead  
                    fileDate: replace/all to-string now/date "-" ""
                    fileTime: replace/all to-string now/time ":" ""                        
                    insert backUpFileName reduce [filedate filetime] 
                    write rejoin [%topics/ %"Back Ups/" backUpFileName] backUpText
                    clear backUpFileName
                    do upDateTitleList
                    newName: false
                ]
            ]
        ]
    ]

    origin 300x700 cancelButton:  btn "Cancel"  font-color coffee  [
        do coverUp
    ]  


    origin 90x695 newFileLabel: H3 "File Name (no suffix)" coffee  
    below
    origin 850x20 box  260x300 effect [
        draw [
            pen 8
            pen black
            font readerFont text "R"     10x44
                                       text "E"     30x44
                                       text "B"     50x44
                                       text "O"     70x44
                                       text "L"      90x44
 
                                       text "R"     30x74
                                       text "E"     50x74
                                       text "A"     70x74
                                       text "D"     90x74
                                       text "E"   110x74
                                       text "R"   130x74
       ]
    ]                
    origin 805x466  textReaderSlider: scroller 18x40 mint mint  [
        textSize: (size-text textReader) - 400
        textReader/para/origin/y: (textReaderSlider/data * textSize/y) - 2 * -1
        show textReader
    ]


                                          ;********  The Directories, Or Topics  ************
                                     
    origin 850x320 topicsList: text-list 160x290 gold  black  font-size 17 data onlyDirs [
        change-dir join home  %topics/
        either (topicsList/picked/1 = %"Library Scripts") [
            change-dir %Library/scripts/
        ][
            change-dir topicsList/picked/1
        ]

        folderLoaded: true                                                                ; sets directory for title files
        rebolLoaded: false                                                               ; prevents calls of other loaded files
        clear-face titlesList  
        titlesList/sn:         0 
        titlesList/sld/data: 0        
        clear-face textReader  
        clear-face textReaderSlider 
        textReader/para/origin: 40x10
        show [titlesList textReader  textReaderSlider]
        fileLoaded: false

                ; ********** Get Title Files, Then Parse Them To Get To Get Descriptive Prefix, Or Title **********

        keepDir: join %topics/ last split-path what-dir 
        if topicsList/picked/1 = %"Library Scripts" [ keepDir: join %topics/ %Library/scripts/]
        do readForTitles
        do titlesFromNames
        titlesList/data: titles


                           ; ********Code For Manual To Show Only Contents Page In Titles ********

        if keepDir = %topics/Manual/ [
            either exists? rejoin [home %topics/manual/ %core23/rebolCore.html][
                clear readIn
                append readIn %core23/rebolCore.html
                clear titles
                append titles    "Rebol/Core Manual"
                show titlesList
            ][
                clear textReader/text
                textReader/line-list: none
                textReader/text: copy manualReadme
                show textReader
                if connected? [
                clear textReader/text
                textReader/line-list: none
                textReader/text: {


                Downloading manual...   File will decompress & install.

                When installed, the contents page of the manual will open in the browser.
                 }  
                 wait 4
                show textReader
                    forManualPages: join home keepDir
                     print "Please wait... downloading...."
                    unzip forManualPages http://www.rebol.com/docs/rebol-core23-manual.zip
                    pages: read %core23/.
                    foreach pageIn pages [
                        if (suffix? pageIn) = %.html [
                            changePage: read join %core23/ pageIn
                            print pageIn
                            print "working..."
                            replace changePage "http://www.rebol.com/graphics/doc-bar.gif"  "graphics/doc-bar.gif" 
                        replace changePage "http://www.rebol.com/graphics/rcugcover-120.gif" 

"graphics/rcugcover-120.gif"
                       write join %core23/ pageIn changePage 
                   ]
               ]
               print "downloading image...."
        write/binary %core23/graphics/rcugcover-120.gif  read/binary 

http://www.rebol.com/graphics/rcugcover-120.gif
                print "Done!"
                browse %core23/rebolcore.html
               ]
          ]
    ]

                                 ;********************** Topics Library Code *********************************
  
  if keepDir = %topics/Library/ [
        either exists? rejoin [home %topics/library/ %run-librarian.r] [
            clear readIn
            append readIn [%run-librarian.r %bogusFile.no]                 ;if librarian is there, prepare to call it
            clear titles
            append titles   "Desktop Library Script" 
        ][  
            either all [                                                                          ;if not there & downloaded file is, 

prepare to install
                exists? rejoin [home %topics/ %library.r] 
                not exists? rejoin [home %topics/library/ %run-librarian.r 
            ]
        ][
                clear readIn
                append readIn [%noInstallFile.no]                       ;bogus filename so not acted on
                clear titles
                append titles    ["Install Desktop Library" ]
                clear textReader/text
                textReader/line-list: none
                textReader/text: copy libraryReadMe
                show textReader
             ][                                                                                 ;neither librarian nor source, so prepare to 

download
                clear readIn
                append readIn [%noGetFile.no %noInstallFile.no]               ;bogus filenames so not acted on
                clear titles
                append titles    ["Get Desktop Library" "Install Desktop Library"]
                clear textReader/text
                textReader/line-list: none
                textReader/text: copy libraryReadMe
                show textReader
           ]                
        ]
    ]
    

                                                      ; ******* Finally Display Titles ************
              
    show titlesList
    change-dir %../../                                                                                         
    ] 


          ;**************************** Titles*********************************

    origin 380x625 titlesList: text-list 450x125 gold black font-size 17 data startTopics [
                                     ;************* Bring Text & Slider Dragger To Top **************

        clear textReader/text                       ;prevent working disconnected file
        textReader/line-list: none
        textReader/para/origin/y: 0     
        textReaderSlider/data: 0
        textReader/text: join "Last Title Was  " getTitle
        show [textReader textReaderSlider]
        unfocus

        newName: false
        getTitle:  form copy  titlesList/picked         


                                                  ;************* Relate Title To File Name ********

        pickPoint: index? (find titles form titlesList/picked)                              ;using form over 

titlesList/picked/1
        fileToRead: pick readIn pickPoint

       if titlesList/picked/1 = %rebolCore [fileToRead: %rebolCore.html]      ;only the contents page 
                                                                              
       if (last split-path what-dir) = %topics/ [change-dir %../]

                                                     
                                     ;************* Bring Text & Slider Dragger To Top **************

        textReader/para/origin/y: 0     
        textReaderSlider/data: 0
        show [textReader textReaderSlider]
        unfocus


                                        ;********* Read & Show Titles, Enable Buttons ************** 

        if any [
            (suffix? filetoRead)  = %.html
            (suffix? filetoRead)  = %.htm
        ] [
            browse join keepDir filetoRead 
            fileLoaded: true
            fileSuffix: (suffix? filetoRead) 
        ]

        if equal? (suffix? filetoRead) %.txt [
            textReader/text:  read  join keepDir filetoRead                     fileLoaded: true  
            show textReader
            backUpText: copy textReader/text                                ;get backUp ready to save if 

textReader/text is saved
            backUpFileName: copy fileToRead
            fileSuffix: %.txt
        ]
        if equal? (suffix? filetoRead) %.r [
            rebolLoaded: true                                                                  fileLoaded:    true
            textReader/text:  read  join keepDir filetoRead    
            show textReader
            backUpText: copy textReader/text    
            backUpFileName: copy fileToRead
            fileSuffix: %.r
        ]
        if equal? (suffix? filetoRead) %.pdf [
        either (programHomes/1) <> "placeHolder" [
                dirBeforeAdobe: what-dir   
                thisProgram/1:  join programHomes/1 %AcroRd32.exe 
                thisProgram/2: rejoin [home keepDir  filetoRead] 
                call thisProgram
                fileSuffix: %.pdf          
                fileLoaded: true                                               
             ][
                alert "Please Find The Directory Of The Adobe Acrobat Reader"
                do findAdobe 
            ]
        ]
                                              ;************* Titles LIbrary Code ***************************

        if getTitle = "Get Desktop Library"     [fileToRead: %noFile.tx  do getLibrary]
        if getTitle = "Install Desktop Library"  [fileToRead: %noFile.tx  do installLibrary]
        if getTitle = "Library Scripts"               [fileToRead: %noFile.tx  do listLibraryScripts]
        ]    
        space 5
        across
        origin 850x630  silverButton "Quit" [quit]



         ;******************** Make A New Topic & Update The Topics Text-List******************

    silverButton "New Topic"  [
        beforeNewDir: what-dir
        newDir: request-dir/dir %topics
        clear-face topicsList                                                     ; removes persistent picked highlight
        clear topicsList/data
        clear onlyDirs
        topicsList /sn:         0                                                    ; setting up the directory list for new data
        topicsList /sld/data: 0
        
        change-dir %topics/
        readForDirs: read %.
        foreach itemIn readForDirs [if dir? itemIn [append onlyDirs (replace itemIn "/" "") ]]
        sort onlyDirs
        folderLoaded: true  
        show  topicsList 
        change-dir beforeNewDir
    ]

    return

            ;********************** Call Rebol To Operate Scripts *************************

    silverButton "Launch"  [
        if rebolLoaded = true [
            rebolLoaded: false                                                      ;set it back preventing unintended ongoing 

launches
            if libraryScript = true [keepDir: %topics/library/scripts/ ]
            dirBeforeRebol: what-dir
            if (last split-path dirBeforeRebol) = %topics/ [replace  dirBeforeRebol "topics/"  ""] 
            thisProgram/1:  programHomes/2  
            thisProgram/2: rejoin [home keepDir  filetoRead] 
            call thisProgram 
             if libraryScript = true [change-dir home  libraryScript: false]
        ]
    ]

    silverButton "Rebol Blog"  [
        if connected? [
            blogPage: read http://www.rebol.net/cgi-bin/blog.r
            browse http://www.rebol.net/cgi-bin/blog.r
        ]  
    ]
    return
     
    silverButton "Delete Back Up "  [     
        if folderLoaded = true [
            if (last split-path keepDir) = %"Back Ups/" [
                if not confirm "All Rebol Reader Back Up Files Will Be Deleted!" [break]
                change-dir home
                change-dir %"topics/Back Ups/"
                files: read %.
                foreach fileIn files [delete filein]
                do readForTitles
                do titlesFromNames
                clear   titles
                titlesList/data: titles
                titleslist/sld/data: 0
                show titlesList
                change-dir home
            ]
        ]    
    ]
    return
    silverButton "Comments"  [ 
         toComment: layout [
            size 827x610
            backdrop effect [gradient 0x1 olive orange]
            style tile image reb-logo60    
            style textLine text 627x78  wrap font-size 19
            below
            space 20
            origin 0x5
            tile tile tile tile tile tile tile tile tile tile tile tile tile tile
            origin 140x80  
            textLine 627x104 {
                Comments on the Rebol Reader  may be made by first logging on as
                member of the Rebol Org Library.  In a few seconds and if online, the log
                on page will be viewed in the browser.  When the Reader's script is viewed
                in the browser, a comment link may appear below it.
            }        
            textLIne {If you find the Reader useful in the study of the Rebol language, please send in a 
            comment.  Also, any improvements especially to the text edit button functions, are welcome.
        }

       indent 500 btn "Close" orange yellow [unview/only toComment]
    ]
    toComment/offset: 2x2
    view/new/options toComment [no-title]

        wait 7
        if connected? [browse http://www.rebol.org]
        change-dir home
    ]
 silverButton "Viewtop" [
        if not exists? join  home %desktop.r [write %desktop.r "REBOL [] desktop"]
            thisProgram/1:  programHomes/2  
            thisProgram/2: rejoin [home %desktop.r]  
            call thisProgram 
    ]

    origin 30x670 coverBox: box 330x53                                     ;to cover & uncover field & buttons
    origin 893x300 h3 150x26 "Topics" coffee
    origin 550x745 h3 "Titles"  coffee

]                                                     

            ;**************************** End Of Layout ****************************


show titleslist
clear titlesList/data
show titleslist

coverBox/image: coverImage
change-dir %../

textReader/para/origin: 40x40 ;margin
textReader/font/color:  green
rebolReader/offset: 1x0
                                   
                      ;*************** Set Text-Lists Selection Bar Color ********************

topicsList/iter/feel: make  topicsList/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [water] [slf/color]  
    ] in topicsList 'self 
]

titlesList/iter/feel: make titlesList/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [water] [slf/color]  
    ] in titlesList 'self 
]
change-dir home
change-dir %"topics/Rebol Reader"
if not exists? to-file "Welcome To The Rebol Reader.txt" [
    write to-file "Welcome To The Rebol Reader.txt"     system/script/header/notes
    textReader/text:  system/script/header/notes
]

topicsList/sld/color:                  titlesList/sld/color:                     orange
topicsList/sld/pane/1/color:      titlesList/sld/pane/1/color:        mint                    ;dragger
topicsList/sld/pane/2/colors/1: titlesList/sld/pane/2/colors/1:   mint                    ;top arrow
topicsList/sld/pane/3/colors/1: titlesList/sld/pane/3/colors/1:   mint                    ;bottom arrow
topicsList/sld/pane/3/colors/2: titlesList/sld/pane/3/colors/2:   mint                    ;2nd color bottom arrow



change-dir %../../

    ;****************************************************************************

    {The following  zip & unzip script was written by Vincent Ecuyer. "rebzip", 13-Jan-2005 1.0.0 %rebzip.r}
 
                                         ;******************* rebzip *****************
ctx-zip: context [
    crc-long: [
                 0             1996959894  -301047508  -1727442502    124634137    1886057615
        -379345611  -1637575261   249268274    2044508324  -522852066   -1747789432
         162941995   2125561021   -407360249  -1866523247    498536548    1789927666
        -205950648  -2067906082    450548861   1843258603   -187386543   -2083289657
         325883990   1684777152     -43845254   -1973040660    335633487   1661365465
         -99664541  -1928851979   997073096  1281953886  -715111964 -1570279054
        1006888145   1258607687  -770865667 -1526024853   901097722  1119000684
        -608450090  -1396901568   853044451  1172266101  -589951537 -1412350631
         651767980   1373503546  -925412992 -1076862698   565507253  1454621731
        -809855591  -1195530993   671266974  1594198024  -972236366 -1324619484
         795835527   1483230225 -1050600021 -1234817731  1994146192    31158534
       -1731059524   -271249366  1907459465   112637215 -1614814043  -390540237
        2013776290    251722036 -1777751922  -519137256  2137656763   141376813
       -1855689577   -429695999  1802195444   476864866 -2056965928  -228458418
        1812370925    453092731 -2113342271  -183516073  1706088902   314042704
       -1950435094    -54949764  1658658271   366619977 -1932296973   -69972891
        1303535960    984961486 -1547960204  -725929758  1256170817  1037604311
       -1529756563   -740887301  1131014506   879679996 -1385723834  -631195440
        1141124467    855842277 -1442165665  -586318647  1342533948   654459306 
       -1106571248   -921952122  1466479909   544179635 -1184443383  -832445281 
        1591671054    702138776 -1328506846  -942167884  1504918807   783551873 
       -1212326853  -1061524307  -306674912 -1698712650    62317068  1957810842 
        -355121351  -1647151185    81470997  1943803523  -480048366 -1805370492 
         225274430   2053790376  -468791541 -1828061283   167816743  2097651377 
        -267414716  -2029476910   503444072  1762050814  -144550051 -2140837941 
         426522225   1852507879   -19653770 -1982649376   282753626  1742555852 
        -105259153  -1900089351   397917763  1622183637  -690576408 -1580100738 
         953729732   1340076626  -776247311 -1497606297  1068828381  1219638859 
        -670225446  -1358292148   906185462  1090812512  -547295293 -1469587627 
         829329135   1181335161  -882789492 -1134132454   628085408  1382605366 
        -871598187  -1156888829   570562233  1426400815  -977650754 -1296233688 
         733239954   1555261956 -1026031705 -1244606671   752459403  1541320221
       -1687895376   -328994266  1969922972    40735498 -1677130071  -351390145
        1913087877     83908371 -1782625662  -491226604  2075208622   213261112 
       -1831694693   -438977011  2094854071   198958881 -2032938284  -237706686 
        1759359992    534414190 -2118248755  -155638181  1873836001   414664567 
       -2012718362    -15766928  1711684554   285281116 -1889165569  -127750551 
        1634467795    376229701 -1609899400  -686959890  1308918612   956543938 
       -1486412191   -799009033  1231636301  1047427035 -1362007478  -640263460
        1088359270    936918000 -1447252397  -558129467  1202900863   817233897 
       -1111625188   -893730166  1404277552   615818150 -1160759803  -841546093 
        1423857449    601450431 -1285129682 -1000256840  1567103746   711928724 
       -1274298825  -1022587231  1510334235   755167117
   ]

    right-shift-8: func [
        "Right-shifts the value by 8 bits and returns it."
        value [integer!] "The value to shift"
    ][
        either negative? value [
            -1 xor value and -256 / 256 xor -1 and 16777215
        ][
            -256 and value / 256
        ]
    ]
    
    update-crc: func [
        "Returns the data crc."
        data [any-string!] "Data to checksum"
        crc [integer!] "Initial value"
    ][
        foreach char data [
             crc: (right-shift-8 crc) xor pick crc-long crc and 255 xor char + 1
        ]
    ]

    crc-32: func [
        "Returns a CRC32 checksum."
        data [any-string!] "Data to checksum"
    ][
        either empty? data [#{00000000}][
            load join "#{" [to-hex -1 xor update-crc data -1 "}"]
        ]
    ]

    ;signatures
    local-file-sig: to-string #{504B0304}
    central-file-sig: to-string #{504B0102}
    end-of-central-sig: to-string #{504B0506}
    data-descriptor-sig: to-string #{504B0708}

    ;conversion funcs
    to-ilong: func [
        "Converts an integer to a little-endian long."
        value [integer!] "Value to convert"
    ][
        to-binary rejoin [
            to-char value and 255
            to-char to-integer (value and 65280) / 256
            to-char to-integer (value and 16711680) / 65536
            to-char to-integer (value / 16777216)
        ]
    ]
    to-ishort: func [
        "Converts an integer to a little-endian short."
        value [integer!] "Value to convert"
    ][
        to-binary rejoin [
            to-char value and 255
            to-char to-integer value / 256
        ]
    ]
    to-long: func [
        "Converts an integer to a big-endian long."
        value [integer!] "Value to convert"
    ][do join "#{" [to-hex value "}"]]
    get-ishort: func [
        "Converts a little-endian short to an integer."
        value [any-string! port!] "Value to convert"
    ][to-integer head reverse to-binary copy/part value 2]
    get-ilong: func [
        "Converts a little-endian long to an integer."
        value [any-string! port!] "Value to convert"
    ][to-integer head reverse to-binary copy/part value 4]
    to-msdos-time: func [
        "Converts to a msdos time."
        value [time!] "Value to convert"
    ][
        to-ishort (value/hour * 2048)
            or (value/minute * 32)
            or (to-integer value/second / 2)
    ]
    to-msdos-date: func [
        "Converts to a msdos date."
        value [date!] "Value to convert"
    ][
        to-ishort 512 * (max 0 value/year - 1980)
            or (value/month * 32) or value/day
    ]
    get-msdos-time: func [
        "Converts from a msdos time."
        value [any-string! port!] "Value to convert"
    ][
        value: get-ishort value
        to-time reduce [
            63488 and value / 2048
            2016 and value / 32
            31 and value * 2
        ]
    ]
    get-msdos-date: func [
        "Converts from a msdos date."
        value [any-string! port!] "Value to convert"
    ][
        value: get-ishort value
        to-date reduce [
            65024 and value / 512 + 1980
            480 and value / 32
            31 and value
        ]
    ]
    
    zip-entry: func [
{Compresses a file and returns [
         local file header + compressed file
         central file directory entry
     ]}
        name [file!] "Name of file"
        date [date!] "Modification date of file"
        data [any-string!] "Data to compress"
    /local
        crc method compressed-data uncompressed-size compressed-size
    ][
        ; info on data before compression
        crc: head reverse crc-32 data
        uncompressed-size: to-ilong length? data

        either empty? data [
            method: 'store
        ][
            ; zlib stream
            compressed-data: compress data
            ; if compression inefficient, store the data instead
            either (length? data) > (length? compressed-data) [
                data: copy/part
                    skip compressed-data 2
                    skip tail compressed-data -8
                method: 'deflate
            ][
                method: 'store
                clear compressed-data
            ]
        ]

        ; info on data after compression
        compressed-size: to-ilong length? data

        reduce [
            ; local file entry
            join #{} [
                local-file-sig
                #{0000} ; version
                #{0000} ; flags
                either method = 'store [
                    #{0000} ; method = store
                ][
                    #{0800} ; method = deflate
                ]
                to-msdos-time date/time
                to-msdos-date date/date
                crc     ; crc-32
                compressed-size
                uncompressed-size
                to-ishort length? name ; filename length
                #{0000} ; extrafield length
                name    ; filename
                        ; no extrafield
                data    ; compressed data
            ]
            ; central-dir file entry
            join #{} [
                central-file-sig
                #{0000} ; version source
                #{0000} ; version min
                #{0000} ; flags
                either method = 'store [
                    #{0000} ; method = store
                ][
                    #{0800} ; method = deflate
                ]
                to-msdos-time date/time
                to-msdos-date date/date
                crc     ; crc-32
                compressed-size
                uncompressed-size
                to-ishort length? name ; filename length
                #{0000} ; extrafield length
                #{0000} ; filecomment length
                #{0000} ; disknumber start
                #{0000} ; internal attributes
                #{00000000} ; external attributes
                #{00000000} ; header offset
                name    ; filename
                        ; extrafield
                        ; comment
            ]
        ]
    ]

    any-file?: func [
        "Returns TRUE for file and url values." value [any-type!]
    ][any [file? value url? value]]

    to-path-file: func [
        {Converts url! to file! and removes heading "/"}
        value [file! url!] "Value to convert"
    ][
        if file? value [
            if #"/" = first value [value: copy next value]
            return value
        ]
        value: decode-url value
        join %"" [
            value/host "/"
            any [value/path ""]
            any [value/target ""]
        ]
    ]

    set 'zip func [
{Builds a zip archive from a file or a block of files.
     Returns number of entries in archive.}
        where [file! url! binary! string!] "Where to build it"
        source [file! url! block!] "Files to include in archive"
        /deep "Includes files in subdirectories"
        /verbose "Lists files while compressing"
    /local
        name data entry nb-entries files no-modes
        central-directory files-size out date
    ][
        out: func [value] either any-file? where [
            [insert where value]
        ][
            [where: insert where value]
        ]
        if any-file? where [where: open/direct/binary/write where]

        files-size: nb-entries: 0
        central-directory: copy #{}

        source: compose [(source)]
        while [not tail? source][
            name: source/1
            no-modes: any [url? name dir? name]
            files: any [
                all [dir? name name: dirize name read name][]
            ]
            ; is name a not empty directory?
            either all [deep not empty? files] [
                ; append content to file list
                    foreach file read name [
                        insert tail source name/:file
                ]
            ][
                nb-entries: nb-entries + 1
                date: now

                ; is next one data or filename?
                data: either any [tail? next source any-file? source/2][
                    either #"/" = last name [copy #{}][
                        if not no-modes [
                            date: get-modes name 'modification-date
                        ]
                        read/binary name
                    ]
                ][
                    first source: next source
                ]
                name: to-path-file name
                if verbose [print name]
                ; get compressed file + directory entry
                entry: zip-entry name date data
                ; write file offset in archive
                change skip entry/2 42 to-ilong files-size
                ; directory entry
                insert tail central-directory entry/2
                ; compressed file + header
                out entry/1
                files-size: files-size + length? entry/1
            ]
            ; next arg
            source: next source
        ]
        out join #{} [
            central-directory
            end-of-central-sig
            #{0000} ; disk num
            #{0000} ; disk central dir
            to-ishort nb-entries ; nb entries disk
            to-ishort nb-entries ; nb entries
            to-ilong length? central-directory
            to-ilong files-size
            #{0000} ; zip file comment length
                    ; zip file comment
        ]
        if port? where [close where]
        nb-entries
    ]

    set 'unzip func [
{Decompresses a zip archive to a directory or a block.
     Only works with compression methods 'store and 'deflate.}
            where  [file! url! any-block!]  "Where to decompress it"
            source [file! url! any-string!] "Archive to decompress"
            /verbose "Lists files while decompressing (default)"
            /quiet "Don't lists files while decompressing"
    /local
        flags method compressed-size uncompressed-size
        name-length name extrafield-length data time date
        uncompressed-data nb-entries path file info errors
    ][
        errors: 0
        info: func [value] either all [quiet not verbose][
            [none]
        ][
            [prin join "" value]
        ]
        if any-file? where [where: dirize where]
        if all [any-file? where not exists? where][
            make-dir/deep where
        ]
        if any-file? source [source: read/binary source]
        nb-entries: 0

        parse/all source [
            to local-file-sig
            some [
                thru local-file-sig
                (nb-entries: nb-entries + 1)
                2 skip ; version
                copy flags 2 skip
                    (if not zero? flags/1 and 1 [return false])
                copy method 2 skip
                    (method: get-ishort method)
                copy time 2 skip (time: get-msdos-time time)
                copy date 2 skip (
                    date: get-msdos-date date
                    date/time: time
                    date: date - now/zone
                )
                4 skip ; crc-32
                copy compressed-size 4 skip
                    (compressed-size: get-ilong compressed-size)
                copy uncompressed-size 4 skip
                    (uncompressed-size: get-ilong uncompressed-size)
                copy name-length 2 skip
                    (name-length: get-ishort name-length)
                copy extrafield-length 2 skip
                    (extrafield-length: get-ishort extrafield-length)
                copy name name-length skip (
                    name: to-file name
                    info name
                )
                extrafield-length skip
                data: compressed-size skip
                (
                    switch/default method [
                        0 [
                            uncompressed-data:
                                copy/part data compressed-size
                            info "^- -> ok [store]^/"
                        ]
                        8 [
                           data: to-binary rejoin [
                                #{89504E47} #{0D0A1A0A} ; signature
                                #{0000000D} ; IHDR length
                                "IHDR" ; type: header
                                ; width = uncompressed size
                                to-long uncompressed-size
                                #{00000001} ; height = 1 line
                                #{08} ; bit depth
                                #{00} ; color type = grayscale
                                #{00} ; compression method
                                #{00} ; filter method = none
                                #{00} ; no interlace
                                #{00000000} ; no checksum
                                ; length
                                to-long 2 + 6 + compressed-size
                                "IDAT" ; type: data
                                #{789C} ; zlib header
                                ; 0 = no filter for scanline
                                #{00 0100 FEFF 00}
                                copy/part data compressed-size
                                #{00000000} ; no checksum
                                #{00000000} ; length
                                "IEND" ; type: end
                                #{00000000} ; no checksum
                            ]

                            either error? try [data: load data][
                                info "^- -> failed [deflate]^/"
                                errors: errors + 1
                                uncompressed-data: none
                            ][
                                uncompressed-data:
                                    make binary! uncompressed-size
                                repeat i uncompressed-size [
                                    insert tail uncompressed-data
                                        to-char pick pick data i 1
                                ]
                                info "^- -> ok [deflate]^/"
                            ]
                        ]
                    ][
                        info ["^- -> failed [method " method "]^/"]
                        errors: errors + 1
                        uncompressed-data: none
                    ]
                    either any-block? where [
                        where: insert where name
                        where: insert where either all [
                            #"/" = last name
                            empty? uncompressed-data
                        ][none][uncompressed-data]
                    ][
                        ; make directory and / or write file
                        either #"/" = last name [
                            if not exists? where/:name [
                                make-dir/deep where/:name
                            ]
                        ][
                            set [path file] split-path name
                            if not exists? where/:path [
                                make-dir/deep where/:path
                            ]
                            if uncompressed-data [
                                write/binary where/:name
                                    uncompressed-data
                                set-modes where/:name [
                                    modification-date: date
                                ]
                            ]
                        ]
                    ]
                )
            ]
            to end
        ]
        info ["^/"
            "Files/Dirs unarchived: " nb-entries "^/"
            "Decompression errors: " errors "^/"
        ]
        zero? errors
    ]
]


                                                            view rebolReader



