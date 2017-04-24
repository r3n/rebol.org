Rebol [
    title: "Title Bar - Windows API"
    date: 1-july-2008
    file: %title-bar.r
    author: Nick Antonaccio
    purpose: {
        This example demonstrates how to use the Windows API to adjust the title bar
        in your Rebol programs.  Just include this code in your script if you need
		to eliminate the default 'Rebol - ' text at the top of your GUI programs.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]


; first define the Windows API functions you'll need:

user32.dll: load/library %user32.dll
get-focus: make routine! [return: [int]] user32.dll "GetFocus"
set-caption: make routine! [hwnd [int] a [string!]  return: [int]] user32.dll "SetWindowTextA"


; next, create your GUI - be sure to use 'view/new', so that it doesn't appear immediately 
; (start the GUI later with 'do-events', after you've changed the title bar below):

view/new center-face layout [
	size 360x240 backcolor white
	text bold "Notice that there's no 'Rebol - ' in the title bar above."
    across
    at 110x100 btn "Change Title" [
		; these functions change the text in the title bar:
		hwnd-set-title: get-focus
		set-caption hwnd-set-title "Tada!"
    ]
    btn "Exit" [
        ; be sure to close the dll when you're done:
        free user32.dll
        quit
    ]
]


; once you've created your GUI, run the Dll functions to replace the default text in the title bar:

hwnd-set-title: get-focus
set-caption hwnd-set-title "My Title"


; finally, start your GUI:

do-events





NOTES: {

Not needed for this example, but this is another useful function you'll run into when manipulating
Rebol windows.  You'll often see a value needed for "hwnd".  Here's one way to get it: 

find-window-by-class: make routine! [ClassName [string!] WindowName [integer!] return: [integer!]] user32.dll "FindWindowA"
hwnd: find-window-by-class "REBOLWind" 0

Have fun playing with the Windows API!

}

