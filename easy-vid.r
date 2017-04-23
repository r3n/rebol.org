REBOL [
    Title: "Easy VID Tutorial"
    Date: 7-Apr-2001
    Version: 1.1.2
    File: %easy-vid.r
    Author: "Carl Sassenrath"
    Purpose: "Beginner's tutorial to VID."
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tutorial 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

flash "Fetching image..."
read-thru/to http://www.rebol.com/view/demos/palms.jpg %palms.jpg
unview

content: {Easy VID - REBOL Visual Interface Dialect

===Introduction to VID

With REBOL/View it's easy and quick to create your own user
interfaces. The purpose of this tutorial is to teach you the
basic concepts or REBOL/View interfaces in about 20 minutes.

VID is REBOL's Visual Interface Dialect.  A dialect is an
extension of the REBOL language that makes it easier to express
or describe information, actions, or interfaces.  VID is a
dialect that provides a powerful method of describing user
interfaces.

VID is simple to learn and provides a smooth learning curve from
basic user interfaces to sophisticated distributed computing
applications.

---Creating VID Interfaces

VID interfaces are written in plain text. You can use any text
editor to create and edit your VID script. Save your script
as a text file, and run it with REBOL/View.

!Note: Using a word processor like Word or Wordpad is not
recommended because files are not normally saved as text.
If you use a word processor, be sure to save the output
file as text, not as a document (.doc) file.

===Minimal VID Example

Here is a minimal VID example.  It creates a window that
displays a short text message.  Only one line of code
is required:

    view layout [text "Hello REBOL World!"]

You can type this line at the REBOL console prompt, or save
it in a text file and run it with REBOL.  If you save it
as a file, the script will also need a REBOL header. The
header tells REBOL that the file contains a script. Here
is an example of the script file with a header:

    REBOL [Title: "Example VID Script"]

    view layout [text "VID Example!"]

You can also add buttons and other gadgets to the script. The
example below displays a text, list of files, and a button:

    view layout [
        h2 "File List:"
        text-list data read %.
        button "Great!"
    ]

!Click on the examples above to see how they will appear on your
screen.  Click on their close box to remove them.  All of the
examples that follow can be viewed this way.

===Two Basic Functions

Two functions are used to create graphical user interfaces
in REBOL: VIEW and LAYOUT.

The LAYOUT function creates a set of graphical objects.  These
objects are called faces.  You describe faces with words and
values that are put into a block and passed to the LAYOUT function.

The VIEW function displays faces that were previously created by
LAYOUT. The example below shows how the result of
the LAYOUT function is passed to the VIEW function, and the
interface is displayed.

    view layout [
        text "Layout passes its result to View for display."
        button "Ok"
    ]

Click on the above example to view it.

!Note: the block provided to a layout is not normal REBOL code,
it is a dialect of REBOL.  Using a dialect makes it much easier
to express user interfaces.

===Styles

Styles describe faces.  The examples above use the text and
button styles to specify a text line and a button. REBOL has
40 predefined face styles. You can also create your own custom
styles.  Here are a few example styles:

    view layout [
        h1 "Style Examples"
        box brick 240x2
        vtext bold "There are 40 styles built into REBOL."
        button "Great"
        toggle "Press" "Down"
        rotary "Click" "Several" "Times"
        choice "Choose" "Multiple" "Items"
        text-list 120x80 "this is" "a list" "of text"
        across
        check
        radio radio
        led
        arrow
        below
        field "Text Entry"
    ]

The words like backdrop, banner, box, text, and button are styles.

===Facets

Facets let you modify a style.  For instance, you can change the
color, size, text, font, image, edge, background, special
effects, and many other facets of a style.

Facets follow the style name.  Here is an example that shows
how you modify the text style to be bold and navy blue:

    view layout [txt bold navy "Facets are easy to use."]

The words bold and navy are not styles.  They are facets that
modify a style. Facets can appear in any order so you don't
have to remember which goes first.  For example, the line
above could be written as:

    view layout [txt "Facets are easy to use." navy bold]

Many facets that can be specified.  Here is an example that
creates bold red text centered in a black box.

    view layout [txt 300 bold red black center "Red Text"]

You can create facets that produce special effects, such
as a gradient colored backdrop behind the text:

    view layout [
        vtext bold "Wild Thing" effect [gradient 200.0.0 0.0.200]
    ]

===Custom Styles

Custom styles are shortcuts that save time.  When you define a
custom style, the facets you need go into the new style.  This
reduces what you need to specify each time you use the style,
and it allows you to modify the look of your interface by
changing the style definitions.

For example, here is a layout that defines a style for red
buttons.  The style word defines the new style, followed by
the old style name and its facets.

    view layout [
        style red-btn button red
        text "Testing red button style:"
        red-btn "Test"
        red-btn "Red"
    ]

So, if you wanted to create a text style for big, bold,
underlined, yellow, typewriter text:

    view layout [
        style yell tt 220 bold underline yellow font-size 16
        yell "Hello"
        yell "This is big old text."
        yell "Goodbye"
    ]


===Note About Examples

!From this point forward, all examples will assume that
the view and layout functions are provided.  Only the layout
block contents will be shown.  To use these examples in your
scripts, you will need to put them in a layout block, as was
shown earlier.

For example, code that is written as:

    view layout [button red "Test it"]

will now appear as:

    button red "Test it"

===Face Sizes

The size of a face depends on its style.  Most styles, such as
buttons, toggles, boxes, checks, text-lists, and fields, have a
convenient default size.  Here are some examples.

    button "Button"
    toggle "Toggle"
    box blue
    field
    text-list

If no size is given, text will automatically compute its size,
and images will use whatever their source size is:

    text "Short text line"
    text "This is a much longer line of text than that above."
    image %palms.jpg

You can change the size of any face by providing a size facet.
The size can be an integer or a pair.  An integer specifies
the width of the face.  A pair specifies both width and height.
Images will be stretched to fit the size.

    button 200 "Big Button"
    button 200x100 "Huge Button"
    image %palms.jpg 50x50
    image %palms.jpg 150x50

===Color Facets

Most styles have a default color.  For example the body of
buttons will default to a teal color.  To modify the color of
a face, provide a color facet:

    button blue "Blue Button"
    h2 red "Red Heading"
    image %palms.jpg orange

Colors can also be specifed as tuples. Each tuple contains three
numbers: the red, green, and blue components of the color. Each
component can range from 0 to 255. For example:

    button 200.0.200 "Red + Blue = Magenta" 200
    image %palms.jpg 0.200.200 "Green + Blue"

Some face styles also allow more than one color.  The effect of
the color depends on the style.  For text styles the first color
will be used for the text and the second color for the background
of the text:

    txt "Yellow on red background" yellow red
    banner "White on Navy Blue" white navy

For other styles, the body of the face is the first color, and
the second color will be used as its alternate.

    button "Multicolor" olive red
    toggle "Multicolor" blue orange

===Text Facets

Most faces will accept text to be displayed.  Even graphical
faces can display text.  For example, the box and image faces
will display text if it is provided:

    box blue "Box Face"
    image %palms.jpg "Image Face"

Most button faces will accept more than one text string. The
strings will be shown as alternates as the face is selected.

    button "Up" "Down"
    toggle "Off" "On"
    rotary "Red" "Green" "Blue" "Yellow"
    choice "Monday" "Tuesday" "Wednesday" "Thursday" "Friday"
    text-list "Monday" "Tuesday" "Wednesday" "Thursday" "Friday"

When other datatypes need to be displayed as text, use the form
function to convert them first:

    button 200 form now
    field form first read %.

===Normal Text Style

Normal text is light on dark and can include a number of facets
to set the font, style, color, shadow, spacing, tabbing, and
other attributes.

    text "Normal"
    text "Bold" bold
    text "Italic" italic
    text "Underline" underline
    text "Bold italic underline" bold italic underline
    text "Big" font-size 32
    text "Serif style text" font-name font-serif
    text "Spaced text" font [space: 5x0]

Text also includes these predefined styles:

    banner "Banner" 200
    vh1 "Video Heading 1"
    vh2 "Video Heading 2"
    vh3 "Video Heading 3"
    label "Label"

===Document Text Style

Document text is dark on light and can also include a number of
facets to set the font, style, color, shadow, spacing, tabbing,
and other attributes.

    txt "Normal"
    txt "Bold" bold
    txt "Italic" italic
    txt "Underline" underline
    txt "Bold italic underline" bold italic underline
    txt "Big" font-size 32
    txt "Serif style text" font-name font-serif
    txt "Spaced text" font [space: 5x0]

Document text also includes these predefined styles:

    title "Centered title" 200
    h1 "Heading 1"
    h2 "Heading 2"
    h3 "Heading 3"
    h4 "Heading 4"
    tt "Typewriter text"
    code "Code text"

===Text Entry Fields

Text input fields accept text until the enter or tab key is
pressed.  A text input field can be created with:

    field

To make the field larger or smaller, provide a width:

    field 30
    field 300

Fields will scroll when necessary.

Larger amounts of text can be entered in an area.  Areas also
accept an enter key and will break lines.

    area

You can also specify the area size:

    area 160x200

To force the text in an area to wrap rather than scroll
horizontally, provide the wrap option:

    area wrap

===Text Lists

Text lists are easy to create.  Here is an example.

    text-list "Eureka" "Ukiah" "Mendocino"

You can also provide it as a block:

    text-list data ["Eureka" "Ukiah" "Mendocino"]

Almost any type of block can be provided. Here is a list
of all the files in your current directory:

    text-list data read %.

Here is a list of all the words REBOL has scanned:

    text-list data first system/words

===Images

By default an image will be scaled to fit within a face.

    image 60x60 %palms.jpg
    image %palms.jpg red

Images can be framed in a number of ways:

    image 100x100 %palms.jpg frame blue
    image 100x100 %palms.jpg bevel
    image 100x100 %palms.jpg ibevel red 6x6

Most other faces can accept an image as well as text:

    box 100x100 %palms.jpg
    button "Button" %palms.jpg purple
    toggle "Toggle" %palms.jpg blue red
    field bold "This is a field." %palms.jpg effect [brighten 100]

The image can be provided as a filename, URL, or image data.

===Backdrops

A backdrop can be a color, an effect, an image, or a combination
of the three.  For example a backdrop color would be written as:

    backdrop navy
    banner "Color Backdrop" gold

To create a backdrop effect provide it on the line:

    backdrop effect [gradient 1x1 0.0.100 100.0.0]
    banner "Gradient Backdrop" gold

A backdrop image can be a file, URL, or image data:

    backdrop %palms.jpg
    banner "Image Backdrop" red

The backdrop image can be colorized:

    backdrop %palms.jpg blue
    banner "Blue Image Backdrop"

The image can include an effect:

    backdrop %palms.jpg effect [fit gradcol 1x1 100.0.0 0.0.250]
    banner "Gradient Image Backdrop"

===Effect Facets

A range of effects are supported for faces.  All of these
effects are performed directly on the face when it is rendered.
Here are examples of a few possible effects:

    style palms image 80x60 %palms.jpg 
    palms effect [flip 1x1]
    palms effect [rotate 90]
    palms effect [reflect 1x1]
    palms effect [crop 0x50 120x60 fit]
    palms effect [grayscale]
    palms effect [invert]
    palms effect [difference 200.0.0]
    palms effect [tint 80]
    return
    palms effect [contrast 50]
    palms effect [brighten 50]
    palms effect [sharpen]
    palms effect [blur]
    palms effect [colorize 200.0.0]
    palms effect [gradcol 1x1 150.0.0 0.0.150]
    palms effect [gradmul 0x1 0.100.0]
    palms effect [grayscale emboss]

Effects can be used in combination to create other interesting
results.  However, keep in mind that the computations are
performed in real time.  If complex combinations are required,
a temporary image should be created with the to-image function.

===Actions

An action can be associated with almost any face. To do so,
follow the face style with a block:

    button "Test" [print "test"]

The block is used as the body of a function that is passed
the face and the current value (if the face has one).  For
example:

    toggle "Toggle" [print value]
    rotary "A" "B" "C" [print value]
    text "Click Here" [print face/text]

If a second block is provide, it is used for the alternate
actions (right key):

    button "Click Here" [print "action"] [print "alt-action"]

Use variables to modify the contents or state of other faces.
For example, the slider will update the progress bar:

    slider 200x16 [p1/data: value show p1]
    p1: progress

!More on actions needed...

===More to Come

!Much more to come.  These still need to be covered in this
tutorial:

    text-list data [
        sensor
        key
        check
        radio
        led
        arrow
        slider
        progress
        icon
        panel
        list
    ]
}

code: text: layo: xview: none
sections: []
layouts: []
space: charset " ^-"
chars: complement charset " ^-^/"

rules: [title some parts]

title: [text-line (title-line: text)]

parts: [
      newline
    | "===" section
    | "---" subsect
    | "!" note
    | example
    | paragraph
]

text-line: [copy text to newline newline]
indented:  [some space thru newline]
paragraph: [copy para some [chars thru newline] (emit txt para)]
note: [copy para some [chars thru newline] (emit-note para)]
example: [
    copy code some [indented | some newline indented]
    (emit-code code)
]
section: [
    text-line (
        append sections text
        append/only layouts layo: copy page-template
        emit h1 text
    ) newline
]
subsect: [text-line (emit h2 text)]

emit: func ['style data] [repend layo [style data]]

emit-code: func [code] [
    remove back tail code
    repend layo ['code 460x-1 trim/auto code 'show-example]
]

emit-note: func [code] [
    remove back tail code
    repend layo ['tnt 460x-1 code]
]

show-example: [
    if xview [xy: xview/offset  unview/only xview]
    xcode: load/all face/text
    if not block? xcode [xcode: reduce [xcode]] ;!!! fix load/all
    if here: select xcode 'layout [xcode: here]
    xview: view/new/offset layout xcode xy
]

page-template: [
    size 500x480 origin 8x8
    backdrop white
    style code tt black silver bold as-is para [origin: margin: 12x8]
        font [colors: [0.0.0 0.80.0]]
    style tnt txt maroon bold
]

parse/all detab content rules

show-page: func [i /local blk][
    i: max 1 min length? sections i
    append clear tl/picked pick sections i show tl
    if blk: pick layouts this-page: i [f-box/pane: layout/offset blk 0x0 show f-box]
]

main: layout [
    across
    h2 title-line return
    space 0
    tl: text-list 160x480 bold black white data sections [
        show-page index? find sections value
    ]
    h: at
    f-box: info 500x480
    at h + 456x-24
    across space 4
    arrow left  keycode [up left] [show-page this-page - 1]
    arrow right keycode [down right] [show-page this-page + 1]
    pad -120
    txt form system/script/header/date/date
]
show-page 1
xy: main/offset + 480x100
view main