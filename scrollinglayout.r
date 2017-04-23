REBOL [
    Title: "Scrolling layout demo"       
    Author: "Steven White with help from Carl and MaxV"
    File: %scrollinglayout.r
    Date: 7-Feb-2013
    Purpose: {This is a demo of making a sub-layout, on a main window,
    that is too big for the main window and can be scrolled.
    It was adapted from the REBOL cookbook and heavily annotated as an
    aid in learning how the scroller works.}
    library: [
        level: 'intermediate
        platform: 'all
        type: [tutorial]
        domain: [gui vid]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]

]

;; [---------------------------------------------------------------------------]
;; [ This script shows how one might make a scrolling panel of buttons and     ]
;; [ such.  This could be useful if one had an application that had a lot      ]
;; [ of buttons, and was run on a physical screen such that all those          ]
;; [ buttons could not show at one time.  One could put the buttons in a       ]
;; [ box and scroll through them.                                              ]
;; [                                                                           ]
;; [ The explanation below is a bit lengthy because at the time of writing     ]
;; [ I still am trying to get a firm understanding of the use of the scroller. ]
;; [ This was written after examining Carl's cookbook article number 36        ]
;; [ called "Scrolling a GUI panel."                                           ]
;; [                                                                           ]
;; [ Here are some concepts you probably know but must get firmly into your    ]
;; [ head so you don't continually have to remember them.                      ]
;; [                                                                           ]
;; [ When you display something, on a screen or in a window, that item has     ]
;; [ an "offset" which is a pair of numbers (x and y) that show where it       ]
;; [ is displayed starting from the top left corner of wherever you are        ]
;; [ displaying it.  The offset of the top left corner is 0x0.  As you move    ]
;; [ to the right, the first number (x) gets bigger; as you move down, the     ]
;; [ second number (y) gets bigger.  If you are displaying something on a      ]
;; [ screen, the offset refers to the position relative to the top left        ]
;; [ corner of the screen.  If you are displaying something in a box in a      ]
;; [ window, the offset refers to the position relative to the top left        ]
;; [ corner of that container inside which you are displaying it.              ]
;; [ You can refer to the x and y parts of the offset separately, as in        ]
;; [ offset/x and offset/y.  An offset can be negative, which seems to         ]
;; [ make no sense, but actually does, as will be shown below.                 ]
;; [                                                                           ]
;; [ A "face," or "interface object," (like a button, box, area, and so on)    ]
;; [ has an attribute called "pane" which is something that holds one or       ]
;; [ more interface objects inside the original face.                          ]
;; [ This is what allows you, in this example, to put a bunch of buttons       ]
;; [ inside a box, because the "pane" of the box holds all the buttons.        ]
;; [ The box is a "face" ("interface object") and the "pane" of the box        ]
;; [ can hold more "faces" ("interface objects").                              ]
;; [                                                                           ]
;; [ You can get your hands on the size (in pixels) of certain interface       ]
;; [ object ("faces") with the "size" property, and you can get the x and y    ]
;; [ sizes by referring to size/x and size/y, as shown below.                  ]
;; [                                                                           ]
;; [ When you activate a scroller, a property of the scroller called "data"    ]
;; [ changes from zero (when the scroller is at the low end) to one (when      ]
;; [ the scroller is at the high end.  In VID code, if you declare             ]
;; [ a scroller and put a block on it in which you have REBOL code (or a       ]
;; [ function call), that code or function will be executed every time you     ]
;; [ move that scroller.  In that code or function, you can access the         ]
;; [ "data" property to decide where the scroller is.                          ]
;; [                                                                           ]
;; [ The following item will show well only if you are displaying this         ]
;; [ code in a text editor with a fixed font.                                  ]
;; [                                                                           ]
;; [ If you have a box, and in the "pane" of that box you have more stuff      ]
;; [ than can show in the box, you have a situation that looks like this:      ]
;; [ (In this example, we are dealing only with an example of vertical         ]
;; [ scrolling.)                                                               ]
;; [                                                                           ]
;; [                                           +--------------+                ]
;; [                                           |1             |                ]
;; [                                           |2             |                ]
;; [                                           |3             |                ]
;; [                       Data when the       |4             |                ]
;; [                       scroller is at      |5             |                ]
;; [  Visible box          the top             |6             |                ]
;; [                                           |7             |                ]
;; [ +---------------+    +---------------+    |8             |                ]
;; [ |1              |    |1              |    |9             |                ]
;; [ |2              |    |2              |    |10            |                ]
;; [ |3              |    |3              |    |11            |                ]
;; [ |4              |    |4              |    |12            |                ]
;; [ |5              |    |5              |    |13            |                ]
;; [ |6              |    |6              |    |14            |                ]
;; [ |7              |    |7              |    |15            |                ]
;; [ |8              |    |8              |    |16            |                ]
;; [ |9              |    |9              |    |17            |                ]
;; [ |10             |    |10             |    |18            |                ]
;; [ |11             |    |11             |    |19            |                ]
;; [ |12             |    |12             |    |20            |                ]
;; [ +---------------+    |13             |    +--------------+                ]
;; [                      |14             |                                    ]
;; [                      |15             |     Data when the                  ]
;; [                      |16             |     scroller is at                 ]
;; [                      |17             |     the bottom                     ]
;; [                      |18             |                                    ]
;; [                      |19             |                                    ]
;; [                      |20             |                                    ]
;; [                      +---------------+                                    ]
;; [                                                                           ]
;; [ We will discuss this example in terms of lines rather than pixels for     ]
;; [ clarity.                                                                  ]
;; [                                                                           ]
;; [ On the left we have a box that shows 12 lines.  In the "pane" of that     ]
;; [ box we have 20 lines.  Not all lines can show at the same time.           ]
;; [ Somewhere we have a scroller that controls the display in that box.       ]
;; [ When the scroller is at the top, the data is displayed as shown in        ]
;; [ the middle area, where the first line is at the top of the box            ]
;; [ and lines 13-20 don't show.  When the scroller is at the bottom,          ]
;; [ the data is displayed as shown in the right area, where the last line     ]
;; [ is at the bottom of the box and lines 1-8 don't show.                     ]
;; [                                                                           ]
;; [ The question being answered by this script is, what do we do to make      ]
;; [ the contents of the pane scroll up and down properly inside the container ]
;; [ that contains that pane?                                                  ]
;; [                                                                           ]
;; [ What we do is conceptually very simple.  The "pane" is what contains      ]
;; [ the stuff we want to show.  We adjust the "offset" of that pane, the      ]
;; [ "y" (vertical) value only, and then redisplay (show) the container        ]
;; [ that contains that pane.                                                  ]
;; [                                                                           ]
;; [ To understand what to do, it helps to consider the boundaries.            ]
;; [ When the scroller is at the top, the offset/y of the pane will be zero.   ]
;; [ That means that the pane starts at the top of the container.              ]
;; [ What will the offset be when the scroller is at the end?                  ]
;; [ The answer is that the offset will be negative.  A negative number        ]
;; [ for the offset/y means that the display will start at some place          ]
;; [ above the box.  How far above the box?  Far enough so that the last       ]
;; [ line of the data will be at the bottom of the box.  How far is that?      ]
;; [ The answer is that it is an amount that is the difference between         ]
;; [ the size of the stuff you want to show and the space you have to show it. ]
;; [ In the above example, you have 20 lines you want to show, but only        ]
;; [ 12 lines to show it, so 20 minus 12 gives 8, which means that if you      ]
;; [ show the pane with an offset of negative 8, it will fall into the         ]
;; [ container such that line of the data is at line 12 of the box.            ]
;; [                                                                           ]
;; [ The above is concept is very important.  When you scroll the box,         ]
;; [ the offset/y of the pane is going to vary from zero to a number that      ]
;; [ is the amount by which the data overflows the container.  If the data     ]
;; [ is smaller than the container, we want no scrolling to take place,        ]
;; [ so we will want to leave the offset/y at zero.                            ]
;; [                                                                           ]
;; [ So where does the scroller fit into this?  The scroller varies from       ]
;; [ zero to one.  It is a fraction.  It is the fractional amount of that      ]
;; [ total possible amount of scrolling.  In the above example, the total      ]
;; [ "travel" in that scroller is 8.  Eight is the amount that won't fit       ]
;; [ in the visible container.  Eight is the highest amount we will have       ]
;; [ to scroll, and a negative eight is the highest offset we will need        ]
;; [ to scroll to the bottom.  So what we do with the scroller is apply        ]
;; [ that fractional value to that maximimum possible offset to get the        ]
;; [ new offset represented by the scroller position.  When the scroller       ]
;; [ is at the half-way point, we multiply the maximum possible offset of      ]
;; [ eight by the scroller value of .5 to get a new offset of 4, or,           ]
;; [ actually, negative 4 because we are scrolling down and so want the        ]
;; [ data to display from a point four lines "higher" (a negative offset).     ]
;; [                                                                           ]
;; [ To put it all together into a tidy calculation, when we operate the       ]
;; [ scroller we want to do the following.                                     ]
;; [                                                                           ]
;; [ Subtract the size of the container from the size of the stuff we want     ]
;; [ to put in the container.  This gives us the maximum amount we possibly    ]
;; [ could have to scroll.  If the container is bigger that the stuff we       ]
;; [ want to show, use zero for that maximum amount because we don't want      ]
;; [ to do any scrolling.                                                      ]
;; [                                                                           ]
;; [ Multiply that maximum possible offset value by the fractional amount      ]
;; [ provided by the scroller.  That gives us the actual amount of offset      ]
;; [ we want to apply.                                                         ]
;; [                                                                           ]
;; [ Negate the amount we calculated, because if we are scrolling "down,"      ]
;; [ that means we have to start displaying the front of the data from         ]
;; [ some point "up," meaning the offset must be negative.                     ]
;; [                                                                           ]
;; [ When we calculate this new offset for the data inside the container       ]
;; [ (the "pane"), set that offset/y value of that pane and then               ]
;; [ redisplay the contiainer that contains the pane.                          ]
;; [                                                                           ]
;; [ The example below shows a screen with a bunch of buttons, so many         ]
;; [ buttons that we want to put them into a box and scroll the box with       ]
;; [ a scroller.                                                               ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This is the function that is called when the operator moves the           ]
;; [ scroller so much as a pixel.                                              ]
;; [                                                                           ]
;; [ In REBOL examples on the internet, you usually see the scroller or        ]
;; [ its "data" property passed to such a procedure.  In this example,         ]
;; [ we just refer to the scroller based on its name in the layout.            ]
;; [ The reason for this is so that we don't have any local variables in       ]
;; [ this function.  And the reason for not having local variables is so       ]
;; [ that when the operator clicks the "Debug halt" button and the program     ]
;; [ halts, he then can examine the various words in this program.             ]
;; [ If those word were local, they would not be available.                    ]
;; [ Remember that this is a demo and not a "real" program.                    ]
;; [---------------------------------------------------------------------------]

SCROLL-BUTTON-LIST: does [

;;  -- Display the type of the pane inside the box.
    DEBUG-BUTTONBOX-TYPE/text: type? BUTTONBOX/pane
    show DEBUG-BUTTONBOX-TYPE

;;  -- Display the number from 0 to 1 produced by operating the scroller.
    DEBUG-SCROLLER-VALUE/text: to-string BUTTONSCROLLER/data
    show DEBUG-SCROLLER-VALUE

;;  -- Display the size of the box that holds the pane of buttons.
    DEBUG-BUTTONBOX-SIZE/text: to-string BUTTONBOX/size/y
    show DEBUG-BUTTONBOX-SIZE

;;  -- Display the size of the pane of buttons we put in the above box.
    DEBUG-BUTTONBOX-PANE-SIZE/text: to-string BUTTONBOX/pane/size/y
    show DEBUG-BUTTONBOX-PANE-SIZE

;;  -- Calculate the new button pane offset based on scroller input.
    NEW-OFFSET: negate BUTTONSCROLLER/data *
        (max 0 (BUTTONBOX/pane/size/y - BUTTONBOX/size/y))
    BUTTONBOX/pane/offset/y: NEW-OFFSET
    show BUTTONBOX

;;  -- Display the new offset for the button pane as we move the scroller
    DEBUG-BUTTONBOX-PANE-OFFSET/text: to-string NEW-OFFSET
    show DEBUG-BUTTONBOX-PANE-OFFSET

]

;; [---------------------------------------------------------------------------]
;; [ Below is a sub-layout, that is, a layout that we will put into a          ]
;; [ a box in the main window.  It is deliberately more buttons than will      ]
;; [ fit in the hard-coded size of the box.                                    ] 
;; [ The keyword "tight" causes this layout to be put into the box             ]
;; [ with no offset.                                                           ]
;; [---------------------------------------------------------------------------]
  
BUTTONLAYOUT: layout/tight [
    across
    button "button 01" [DEBUG-WHICH-BUTTON/text: "01" show DEBUG-WHICH-BUTTON]
    button "button 02" [DEBUG-WHICH-BUTTON/text: "02" show DEBUG-WHICH-BUTTON]
    button "button 03" [DEBUG-WHICH-BUTTON/text: "03" show DEBUG-WHICH-BUTTON]
    button "button 04" [DEBUG-WHICH-BUTTON/text: "04" show DEBUG-WHICH-BUTTON]
    button "button 05" [DEBUG-WHICH-BUTTON/text: "05" show DEBUG-WHICH-BUTTON]
    return
    button "button 06" [DEBUG-WHICH-BUTTON/text: "06" show DEBUG-WHICH-BUTTON]
    button "button 07" [DEBUG-WHICH-BUTTON/text: "07" show DEBUG-WHICH-BUTTON]
    button "button 08" [DEBUG-WHICH-BUTTON/text: "08" show DEBUG-WHICH-BUTTON]
    button "button 09" [DEBUG-WHICH-BUTTON/text: "09" show DEBUG-WHICH-BUTTON]
    button "button 10" [DEBUG-WHICH-BUTTON/text: "10" show DEBUG-WHICH-BUTTON]
    return
    button "button 11" [DEBUG-WHICH-BUTTON/text: "11" show DEBUG-WHICH-BUTTON]
    button "button 12" [DEBUG-WHICH-BUTTON/text: "12" show DEBUG-WHICH-BUTTON]
    button "button 13" [DEBUG-WHICH-BUTTON/text: "13" show DEBUG-WHICH-BUTTON]
    button "button 14" [DEBUG-WHICH-BUTTON/text: "14" show DEBUG-WHICH-BUTTON]
    button "button 15" [DEBUG-WHICH-BUTTON/text: "15" show DEBUG-WHICH-BUTTON]
    return
    button "button 16" [DEBUG-WHICH-BUTTON/text: "16" show DEBUG-WHICH-BUTTON]
    button "button 17" [DEBUG-WHICH-BUTTON/text: "17" show DEBUG-WHICH-BUTTON]
    button "button 18" [DEBUG-WHICH-BUTTON/text: "18" show DEBUG-WHICH-BUTTON]
    button "button 19" [DEBUG-WHICH-BUTTON/text: "19" show DEBUG-WHICH-BUTTON]
    button "button 20" [DEBUG-WHICH-BUTTON/text: "20" show DEBUG-WHICH-BUTTON]
    return
    button "button 21" [DEBUG-WHICH-BUTTON/text: "21" show DEBUG-WHICH-BUTTON]
    button "button 22" [DEBUG-WHICH-BUTTON/text: "22" show DEBUG-WHICH-BUTTON]
    button "button 23" [DEBUG-WHICH-BUTTON/text: "23" show DEBUG-WHICH-BUTTON]
    button "button 24" [DEBUG-WHICH-BUTTON/text: "24" show DEBUG-WHICH-BUTTON]
    button "button 25" [DEBUG-WHICH-BUTTON/text: "25" show DEBUG-WHICH-BUTTON]
    return
    button "button 26" [DEBUG-WHICH-BUTTON/text: "26" show DEBUG-WHICH-BUTTON]
    button "button 27" [DEBUG-WHICH-BUTTON/text: "27" show DEBUG-WHICH-BUTTON]
    button "button 28" [DEBUG-WHICH-BUTTON/text: "28" show DEBUG-WHICH-BUTTON]
    button "button 29" [DEBUG-WHICH-BUTTON/text: "29" show DEBUG-WHICH-BUTTON]
    button "button 30" [DEBUG-WHICH-BUTTON/text: "30" show DEBUG-WHICH-BUTTON]
    return
    button "button 31" [DEBUG-WHICH-BUTTON/text: "31" show DEBUG-WHICH-BUTTON]
    button "button 32" [DEBUG-WHICH-BUTTON/text: "32" show DEBUG-WHICH-BUTTON]
    button "button 33" [DEBUG-WHICH-BUTTON/text: "33" show DEBUG-WHICH-BUTTON]
    button "button 34" [DEBUG-WHICH-BUTTON/text: "34" show DEBUG-WHICH-BUTTON]
    button "button 35" [DEBUG-WHICH-BUTTON/text: "35" show DEBUG-WHICH-BUTTON]
    return
    button "button 36" [DEBUG-WHICH-BUTTON/text: "36" show DEBUG-WHICH-BUTTON]
    button "button 37" [DEBUG-WHICH-BUTTON/text: "37" show DEBUG-WHICH-BUTTON]
    button "button 38" [DEBUG-WHICH-BUTTON/text: "38" show DEBUG-WHICH-BUTTON]
    button "button 39" [DEBUG-WHICH-BUTTON/text: "39" show DEBUG-WHICH-BUTTON]
    button "button 40" [DEBUG-WHICH-BUTTON/text: "40" show DEBUG-WHICH-BUTTON]
    return
    button "button 41" [DEBUG-WHICH-BUTTON/text: "41" show DEBUG-WHICH-BUTTON]
    button "button 42" [DEBUG-WHICH-BUTTON/text: "42" show DEBUG-WHICH-BUTTON]
    button "button 43" [DEBUG-WHICH-BUTTON/text: "43" show DEBUG-WHICH-BUTTON]
    button "button 44" [DEBUG-WHICH-BUTTON/text: "44" show DEBUG-WHICH-BUTTON]
    button "button 45" [DEBUG-WHICH-BUTTON/text: "45" show DEBUG-WHICH-BUTTON]
    return
    button "button 46" [DEBUG-WHICH-BUTTON/text: "46" show DEBUG-WHICH-BUTTON]
    button "button 47" [DEBUG-WHICH-BUTTON/text: "47" show DEBUG-WHICH-BUTTON]
    button "button 48" [DEBUG-WHICH-BUTTON/text: "48" show DEBUG-WHICH-BUTTON]
    button "button 49" [DEBUG-WHICH-BUTTON/text: "49" show DEBUG-WHICH-BUTTON]
    button "button 50" [DEBUG-WHICH-BUTTON/text: "50" show DEBUG-WHICH-BUTTON]
] 

;; [---------------------------------------------------------------------------]
;; [ This is the main window.                                                  ]
;; [ It has some buttons, and places for displaying debugging information,     ]
;; [ and then it has a box of a defined size into which we will place the      ]
;; [ above sub-layout of buttons.                                              ]
;; [ The above sub-layout of buttons is too big for this box.                  ]
;; [---------------------------------------------------------------------------]

MAIN-WINDOW: layout [
    across
    vh1 "Scrolling button panel test"
    return
    button "Quit" [quit]
    button "Debug halt" [halt]
    return
    vh2 "Start of sub-layout box"
    return
;;  -- Sub-panel and scroller
    BUTTONBOX: box 550x200
    BUTTONSCROLLER: scroller 16x200 [SCROLL-BUTTON-LIST]
;;  --
    return
    vh2 "End of sub-layout box"
    return
;;  -- Debugging data
    label "Button pressed: "
    DEBUG-WHICH-BUTTON: text "Button pressed"
    return
    label "type? BUTTONBOX/pane "
    DEBUG-BUTTONBOX-TYPE: text "Pane type"
    return
    label "BUTTONSCROLLER/data "
    DEBUG-SCROLLER-VALUE: text "Scroller value"
    return
    label "BUTTONBOX/size/y "
    DEBUG-BUTTONBOX-SIZE: text "Box y"
    return
    label "BUTTONBOX/pane/size/y "
    DEBUG-BUTTONBOX-PANE-SIZE: text "Pane y"
    return
    label "BUTTONBOX/pane/offset/y "
    DEBUG-BUTTONBOX-PANE-OFFSET: text "Pane offset"
]

;; [---------------------------------------------------------------------------]
;; [ Before we display the main window, load the box with the sub-layout       ]
;; [ of buttons.  This sub-layout goes into the "pane" property.               ]
;; [---------------------------------------------------------------------------]

BUTTONBOX/pane: BUTTONLAYOUT 

;; [---------------------------------------------------------------------------]
;; [ Display the main window and wait for input.                               ]
;; [---------------------------------------------------------------------------]

view MAIN-WINDOW
