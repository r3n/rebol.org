REBOL [
    title: "Simple Slideshow Presentation Framework"
    date: 22-1-2013
    file: %slideshow-presentation.r
    author:  Nick Antonaccio
    purpose: {

        This example is taken from the tutorial at:

        http://re-bol.com/business_programming.html

        It demonstrates a simple framework for presenting full screen GUI
        layouts with built-in keyboard and mouse controls.  It simplifies coding
        tediously repetitive layout elements, by only requiring unique GUI 
        elements in each slide. Widgets and layout code to appear in all
        slides can be inserted in the "forever" loop. This example separates out
        the title, the text background box color/effect, and layout code to
        appear in each unique slide, and adds forward and back key/mouse 
        controls, bar lines (black boxes), and colors to appear in every slide. 
        To create your own slides, all you need to do is edit the unique code
        to appear in each individual slide layout (title string and unique GUI
        code for each slide):

        For more information about using REBOL as presentation software, see:

        http://re-bol.com/business_programming.html#section-9

    }
]

slides: [
    "Slide 1 - A Few Basics"  
    [
        text "By default these slides are white and full screen."
        text bold "Adding images is easy:"
        image logo.gif
        image stop.gif
        image info.gif
        image exclamation.gif
        text {
            Press the space bar, right arrow key, or left click screen
            for the next slide.  Press the left arrow key, or right
            click screen to go back to previous slide.  Press the 'X'
            key to quit...
        }
    ]
    "Slide 2 - Colors and Gradients" 
    [
        at 0x90 box as-pair system/view/screen-face/size/1 220 effect [
            gradient 1x1 tan brown
        ]
        at 20x70 text "Colors and gradient effects are easy in REBOL:"
        box effect [gradient 123.23.56 254.0.12]
        box effect [gradient blue gold/2]
        text {
            Left arrow key or right click screen to go back, 'X' key to
            Quit...
        }
    ]
    "Slide 3 - A Simple Window"
    [
        text "This slide is as simple as can be."
    ]
    "Slide 4 - Lots of Stylized Text"
    [
        across
        text "Normal"
        text "Bold" bold
        text "Italic" italic
        text "Underline" underline
        text "Bold italic underline" bold italic underline
        text "Serif style text" font-name font-serif
        text "Spaced text" font [space: 5x0]
        return
        h1 "Heading 1"
        h2 "Heading 2"
        h3 "Heading 3"
        h4 "Heading 4"
        tt "Typewriter text"
        code "Code text"
        below
        text "Big" font-size 32
        title "Centered title" 200
        across
        vtext "Normal"
        vtext "Bold" bold
        vtext "Italic" italic
        vtext "Underline" underline
        vtext "Bold italic underline" bold italic underline
        vtext "Serif style text" font-name font-serif
        vtext "Spaced text" font [space: 5x0]
        return
        vh1 "Video Heading 1"
        vh2 "Video Heading 2"
        vh3 "Video Heading 3"
        vh4 "Video Heading 3"
        label "Label"
        below
        vtext "Big" font-size 32
        banner "Banner" 200
    ]
    "Slide 5 - Live Code"
    [
        h3 "Remember, These Slides Are Live, Fully Functional GUIs!"
        box red 500x2
        bar: progress
        slider 200x16 [bar/data: value show bar]
        area "Type here"
        drop-down 200 data reduce [now now - 5 now - 10]
        across 
        toggle "Click" "Here" [alert form value]
        rotary "Click" "Again" "And Again" [alert form value]
        choice "Choose" "Item 1" "Item 2" "Item 3" [alert form value]
        radio radio radio
        led
        arrow
        return
    ]
]
indx: 1
forever [
    slide: compose [
        size system/view/screen-face/size
        backdrop white [
            if indx < ((length? slides) / 2) [indx: indx + 1 unview]
        ] [
            if indx > 1 [indx: indx - 1 unview]
        ]
        at 20x20 h1 blue (pick slides (indx * 2 - 1))
        box black as-pair (system/view/screen-face/size/1 - 40) 2
        (pick slides (indx * 2))
        box black as-pair (system/view/screen-face/size/1 - 40) 2
        key #"x" [quit]
        key #" " [
            if indx < ((length? slides) / 2) [indx: indx + 1 unview]
        ]
        key keycode [right] [
            if indx < ((length? slides) / 2) [indx: indx + 1 unview]
        ]
        key keycode [left] [
            if indx > 1 [indx: indx - 1 unview]
        ]
    ]
    slide: layout slide
    view/options center-face slide 'no-title
]