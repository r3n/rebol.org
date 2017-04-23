REBOL [
    Title: "Menu demo, using choice"
    Author:  "Steven White"
    File: %menudemo.r
    Date: 15-JAN-2014
    Purpose: {Two purposes.  Number one, to break down a menu demo from
    Nick Antonaccio into such small pieces that I am able to understand
    each piece, and thus the whole.  Number two, to offer an idea of how
    to write a REBOL script that demonstrates how to write a REBOL script.
    This idea has been done before, so this is not completely new, just
    different.  It also shows how to use a scrolling text area as a nice
    side benefit.}
    library: [
        level: 'beginner
        platform: 'all
        type: [tutorial]
        domain: [demo]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;; [---------------------------------------------------------------------------]
;; [ Thanks to Nick Antonaccio who wrote the script on which I based this one, ]
;; [ and who explained how his own script works so I could understand how to   ]
;; [ write this one.                                                           ]
;; [ The purpose of this exercise is a personal one, to break down the         ]
;; [ coding of a menu into pieces so small that I can understand each piece,   ]
;; [ and thus the whole thing.                                                 ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is a demo of a demo, a lesson on using one REBOL feature,            ]
;; [ captured in a script so that running the script gives the demo.           ]
;; [ The main window contains text of the lesson in one area and a demo        ]
;; [ script in another area.  There are buttons to page through the lesson,    ]
;; [ run the demo script, copy the script to the clipboard.                    ]
;; [ All lesson text and demo scripts are coded into this one controlling      ]
;; [ script so you can just run this controlling script.                       ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ IMPORTANT NOTE:  This demo actually does not work correctly,              ]
;; [ although I think the concept would work just fine outside a demo.         ]
;; [ If you page through the demo and run all the scripts, and get to the last ]
;; [ page, sometimes passing the mouse over the buttons will cause the         ]
;; [ text to disappear, and the "Run" button will produce a demo window        ]
;; [ with no menu on it.  Paging through the demo again will correct this.     ]
;; [ I don't know what is going on.  If anyone does, feel free to fix it.      ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ These are the text items that can appear in the upper box of the          ]
;; [ window.  This is a block of strings, so that we can refer to              ]
;; [ text number 1, number 2, etc.                                             ]
;; [---------------------------------------------------------------------------]

LESSON-TEXTS: [
{Purpose of this demo

This is a demo of a way to make menus in REBOL.  It is A way, not necessarily
THE way.  It makes use of the 'choice' button in VID.

The demo is presented in pages that lead you through it.  Each page of text
can have an associated demo script for you to view and try.  There is a button
to run the script, and also a button to copy it to the clipboard if you want
to paste it into an editor of choice.
}

{The basic choice button

If you use a basic choice style, you get what looks like a button.  You can
specify choices after the keyword, and an action to be taken when a choice
is selected. 

Notice how the choices are gotten into the button, and how the select choice
is obtained.  The choices are loaded by the keyword 'data' followed by a
block of strings.  The selected choice is obtained by the keyword 'value.'  

Note another interesting feature.
When the program runs, the text in the choice button is the first of the
available choices, and when you click the button, the other choices appear
below the button.  We will take advantage of that behavior. 
}

{A modified choice button

With REBOL, almost any feature of a style can be modified.  So let's make a
custom choice button and take all the edges off to leave only text.
We will put the text into a band, that is, a narrow box, that will start
to look like a menu.  We will justify the text to the left.  The horizontal
size ot 190 will eventually become the width of the longest sub-menu
line under a main menu choice.

Try the script below.
}

{A menu item from a choice button

Now let's use what we did before to make something that looks like a menu
item out of a choice face.  

We will define the items that appear on the menu as lines of text.  We will
put those lines of text into a block so that they can be used by the 'data'
keyword for the choice face.  But we won't use that block directly, because
that block that defines the menu items also will define functions that will
be performed when the menu items are selected.  Look at the item called
OPTIONS-ITEMS.  The literals are the items that will appear in the menu.
Remember how the choice face will show, as the default item, the first
item of the list of items.  Notice, in OPTIONS-ITEMS, how the sub-items are
indented as you would expect to see when you activate a menu.  

Notice also that each menu item is followed by a block.  That block will
be executed when the matching menu item is selected.  How will that block
be chosen?  The code will search OPTIONS-ITEMS for what was selected from
the choice face, and when it finds that string, it will execute whatever
follows that string, which will be the appropriate block.  When a menu
items is not a real item, like the line of underscores, a blank block
will cause the program to do nothing.  

And finally, you might remember from the previous example that after you
make a choice, the choice face continues to display the item you chose.
That is not how a menu would behave.  What we want to happen is that
after the menu item is executed, we want the menu to return to its
original state.  We do that with a function that reloads the text on
the choice face with the first item in the block of choices.  That is the
RESET-MENU function.  The RESET-MENU function will work for any menu
item because we pass to it the menu item, namely, the choice face.
That is a feature of REBOL, you can pass around those faces on the screen.
}
]

;; [---------------------------------------------------------------------------]
;; [ These are the demo scripts that appear in the lower box in the window.    ]
;; [ Like the texts, it is a block of strings, and each string matches one     ]
;; [ of the lesson strings above.                                              ]
;; [---------------------------------------------------------------------------]

DEMO-SCRIPTS: [

{REBOL []
view/new layout [
    vh1 "No demo script for this page"
]}

{REBOL []
view/new layout [
    vh1 "The basic choice button"
    choice data ["A" "B"] [alert value]
    box 40x40 red; make window big enough to show all choices
]}

{REBOL []
MENU-COLOR: 235.240.245
view/new layout [
    style MENU-LINE choice 190x20 left MENU-COLOR with [
        edge: none font: [style: none shadow: none colors: [0.0.0]]
        para: [indent: 4x0] colors: reduce [MENU-COLOR 215.220.225]
    ]  
    vh1 "A custom choice button"
    MENU-LINE data ["A" "B"] [alert value]   
]}

{REBOL []
MENU-COLOR: 235.240.245
OPTIONS-ITEMS: [
    "Options" []
    "________________________" []
    "    Open" [OPTIONS-OPEN]
    "    Copy" [OPTIONS-COPY]
    "    Paste" [OPTIONS-PASTE]
    "________________________" []
    "    About" [OPTIONS-ABOUT]
    "________________________" []
    "    Quit" [OPTIONS-QUIT]
]
OPTIONS-OPEN: does [
    alert "Options/Open"
]
OPTIONS-COPY: does [
    alert "Options/Copy"
]
OPTIONS-PASTE: does [
    alert "Options/Paste"
]
OPTIONS-ABOUT: does [
    alert "Options/About"
]
OPTIONS-QUIT: does [
    alert "Options/Quit"
]
RESET-MENU: func [CHOICE-FACE] [
    CHOICE-FACE/text: CHOICE-FACE/texts/1
    show CHOICE-FACE
]
view/new layout [
    style MENU-LINE choice 190x20 left MENU-COLOR with [
        edge: none font: [style: none shadow: none colors: [0.0.0]]
        para: [indent: 4x0] colors: reduce [MENU-COLOR 215.220.225]
    ]  
    vh1 "A menu from a choice button"
    MENU-LINE data (extract OPTIONS-ITEMS 2) 
        [do select OPTIONS-ITEMS value RESET-MENU face]
    box 50x200 red ; Make window long enough to show choices 
]}
]

;; [---------------------------------------------------------------------------]
;; [ These are some working items the program uses.                            ]
;; [ We make them global data items so that if the program crashes they are    ]
;; [ available for probing.                                                    ]
;; [ They also would be available if one used the "Halt" button to stop the    ]
;; [ script and get a command prompt.                                          ]
;; [---------------------------------------------------------------------------]

CURRENT-PAGE: 1
PAGE-MAX: 4
CURRENT-TEXT: copy ""
CURRENT-SCRIPT: copy ""

;; [---------------------------------------------------------------------------]
;; [ This is the function called by the "Next" button.                         ]
;; [ The CURRENT-PAGE item identifies the page we are on, and will loop        ]
;; [ around to the first page when we are on the last page.                    ]
;; [ Find the next page number, and load the lesson text and the demo          ]
;; [ script into the appropriate text areas.                                   ]
;; [---------------------------------------------------------------------------]

NEXT-BUTTON: does [
    CURRENT-PAGE: CURRENT-PAGE + 1
    if (CURRENT-PAGE > PAGE-MAX) [
        CURRENT-PAGE: 1
    ]
    LOAD-TEXT-AREA CURRENT-PAGE
    LOAD-SCRIPT-AREA CURRENT-PAGE
]
LOAD-TEXT-AREA: func [PAGE] [
    CURRENT-TEXT: copy ""
    CURRENT-TEXT: pick LESSON-TEXTS PAGE
    TEXT-AREA/text: CURRENT-TEXT
    TEXT-AREA/para/scroll/y: 0
    TEXT-AREA/line-list: none
    TEXT-AREA/user-data: second size-text TEXT-AREA
    TEXT-SCROLLER/redrag TEXT-AREA/size/y / TEXT-AREA/user-data
    show TEXT-AREA
]
LOAD-SCRIPT-AREA: func [PAGE] [
    CURRENT-SCRIPT: copy ""
    CURRENT-SCRIPT: pick DEMO-SCRIPTS PAGE
    SCRIPT-AREA/text: CURRENT-SCRIPT
    SCRIPT-AREA/para/scroll/y: 0
    SCRIPT-AREA/line-list: none
    SCRIPT-AREA/user-data: second size-text SCRIPT-AREA
    SCRIPT-SCROLLER/redrag SCRIPT-AREA/size/y / SCRIPT-AREA/user-data
    show SCRIPT-AREA
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure activated by the scrollers.                         ]
;; [ We can have the same procedure for both scrollers because we can pass     ]
;; [ to this procedure the scoller itself as well as the text area that is     ]
;; [ being scrolled.                                                           ]
;; [---------------------------------------------------------------------------]

SCROLL-TEXT: func [TXT BAR] [
    ;; -- Make sure key values are not 'none'. 
    if TXT/user-data [
        if TXT/size/y [
            TXT/para/scroll/y: negate BAR/data * 
                (max 0 TXT/user-data - TXT/size/y)
            SHOW TXT
        ]
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure for the "Run" button.                               ]
;; [ It uses the CURRENT-PAGE to find the demo script that is showing on the   ]
;; [ window, loads that script, and runs it.                                   ]
;; [---------------------------------------------------------------------------]

RUN-BUTTON: does [
;;  do load pick DEMO-SCRIPTS CURRENT-PAGE  ;; is this causing our problem?
    THIS-DEMO: copy []                      ;; or is this way better?
    THIS-DEMO: load pick DEMO-SCRIPTS CURRENT-PAGE
    do THIS-DEMO
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure for the "Copy" button.                              ]
;; [ It uses the CURRENT-PAGE to find the script that is showing, and copies   ]
;; [ that script to the clipboard.                                             ]
;; [---------------------------------------------------------------------------]

COPY-BUTTON: does [
    write-clipboard:// pick DEMO-SCRIPTS CURRENT-PAGE
    alert "Code copied to clipboard"
]

;; [---------------------------------------------------------------------------]
;; [ This is the procedure for the "Quit" button.                              ]
;; [---------------------------------------------------------------------------]

QUIT-BUTTON: does [
    quit
]

;; [---------------------------------------------------------------------------]
;; [ This is the main window.  We will run it through the layout function      ]
;; [ but not display it yet.  We want to load up the first page of the         ]
;; [ lesson before we show the window.                                         ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    vh1 "Menu demo using choice"
    space 0
    across
    TEXT-AREA: text 500x400 wrap black white 
    TEXT-SCROLLER: scroller 16x400 [SCROLL-TEXT TEXT-AREA TEXT-SCROLLER]
    pad 0x5
    return
    SCRIPT-AREA: text 500x400 black white font-name font-fixed 
    SCRIPT-SCROLLER: scroller 16x400 [SCROLL-TEXT SCRIPT-AREA SCRIPT-SCROLLER]
    pad 0x5
    space 5 
    across
    return
    button "Next" [NEXT-BUTTON]
    button "Run" [RUN-BUTTON]
    button "Copy" [COPY-BUTTON]
    button "Quit" [QUIT-BUTTON]
    button "Halt" [halt] ;; so we can get a command prompt and do probing
]

;; [---------------------------------------------------------------------------]
;; [ Before we show the window, load the first lesson text and the first       ]
;; [ demo script.  The first demo script will be basically a place holder      ]
;; [ because the first text is an introduction that needs no script.           ]
;; [---------------------------------------------------------------------------]

LOAD-TEXT-AREA 1
LOAD-SCRIPT-AREA 1

;; [---------------------------------------------------------------------------]
;; [ Begin.                                                                    ]
;; [ Show the main window and respond to its buttons.                          ]
;; [---------------------------------------------------------------------------]

view center-face MAIN-WINDOW 
