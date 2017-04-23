REBOL [
    File: %multi-column-data-grids.r
    Date: 23-sep-2009
    Title: "Multiple Column Data Grids"
    Author:  Nick Antonaccio
    Purpose: {
        A demonstration of how to create your own home made "listview"
        types of multiple column data grids.   Easier to use than the 'list 
        style, and built entirely using native VID, so completely adjustable
        to your needs.  Many useful features are demonstrated, such as
        user editing of data in the grid, saving and loading of data to/from
        files, row addition and removal, column extract, easily adjustable
        look and feel, etc.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

REBOL [Title: "Multi Column Data Grids"]

;-------------------------------------------------------------------------
; This first example creates a random block of two columns of data.  Then,
; a forskip loop is used to assemble a layout block of field widgets, with
; each row of fields containing 2 consecutive text items from the data
; block.  That GUI block is then displayed in the pane of a box widget,
; inside the layout of the main window.  A scroller widget is added to
; scroll the visible portion of the grid layout.  This is accomplished by
; adjusting the offset of the pane which contains the whole layout of
; field widgets.  IMPORTANT:  notice that each cell in this grid is USER
; EDITABLE (simply because each cell is displayed using a standard VID
; field widget). 
;-------------------------------------------------------------------------

x: copy [] for i 1 179 1 [append x reduce [i random "abcd"]]

grid: copy [across space 0]
forskip x 2 [append grid compose [field (form x/1)field (form x/2)return]]
view center-face layout [across
    g: box 400x200 with [pane: layout/tight grid pane/offset: 0x0]
    scroller [g/pane/offset/y: g/size/y - g/pane/size/y * value show g]
]

;-------------------------------------------------------------------------
; The next example demonstrates how to take two blocks of data and combine
; them into a single block that can be displayed using the layout above.
; First, the size of the longest block is determined, and a for loop is
; run to add consecutive items from each of the source blocks, in groups
; of 2, to the destination block.  If either column runs out of data,
; blank strings are added to the rest of the destination block as column
; place holders.
;-------------------------------------------------------------------------

x: copy [] 
block1: copy system/locale/months  block2: copy system/locale/days
for i 1 (max length? block1 length? block2) 1 [
    append x either g: pick block1 i [g] [""]
    append x either g: pick block2 i [g] [""]
]

grid: copy [across space 0]
forskip x 2 [append grid compose [field (form x/1)field (form x/2)return]]
view center-face layout [across
    g: box 400x200 with [pane: layout/tight grid pane/offset: 0x0]
    scroller [g/pane/offset/y: g/size/y - g/pane/size/y * value show g]
]

;-------------------------------------------------------------------------
; The next example demonstrates how to change the look of the grid layout,
; and how to obtain a block of data containing all the data displayed in
; the grid, INCLUDING USER EDITS.  An alternating color is assigned to
; each row in the grid.  This is handled using a "remainder" function.
; For every 4 pieces of text in the data block (every 2 displayed 
; columns), the color is set to white.  Otherwise, it's set to wheat.
; The most important part of this example is the line which collects all
; the data contained in each face of the displayed grid, and builds a
; block to store it.
;-------------------------------------------------------------------------

grid: copy [origin 0x0 across space 0x0]
forskip x 2 [
    color: either (remainder ((index? x) - 1) 4) = 0 [white][wheat]
    append grid compose [
        field 180 (form x/1) (color) edge none
        field 180 (form x/2) (color) edge none return
    ]
]
view center-face layout [
    across space 0  
    g: box 360x200 with [pane: layout grid pane/offset: 0x0]
    scroller[g/pane/offset/y: g/size/y - g/pane/size/y * value / 2 show g]
    return box 1x10 return  ; just a spacer
    btn "Get Data Block (INCLUDING USER EDITS)" [
        q: copy [] foreach face g/pane/pane [append q face/text] editor q
    ]
]

;-------------------------------------------------------------------------
; The next example demonstrates a number of features that really make the
; grid malleable and useful for entering, editing, and storing columns of
; data.  First, the look is adjusted by changing the edges of each field
; style.  To enable all these features, a function is created to run the
; line of code from the previous example which creates a block of data
; from the text displayed in every cell of the data grid.  In every case,
; the data is collected and stored in the variable "q", the desired
; operation is performed on that block (adding and removing rows or data,
; extracting vertical columns of data, saving and loading the data to/from
; files on the hard drive, etc.).  When the data has been changed by an
; operation, the entire layout is unviewed and rebuilt using the new data
; (i.e., when a data file is loaded from the hard drive, when rows are
; added, etc.).  There's also a button which demonstrates how to check the
; history of user edits.
;-------------------------------------------------------------------------

x: copy [] for i 1 179 1 [append x reduce [i random "abcd"]]

update: does [q: copy [] foreach face g/pane/pane [append q face/text]]
do qq: [grid: copy [across space 0]
forskip x 2 [append grid compose [
    field (form x/1) 40 edge none 
    field (form x/2) 260 edge [size: 1x1] return
]]
view center-face gui: layout [across space 0
    g: box 300x290 with [pane: layout/tight grid pane/offset: 0x0]
    slider 16x290 [
        g/pane/offset/y: g/size/y - g/pane/size/y * value show g
    ]
    return btn "Add" [
        row: (to-integer request-text/title "Insert at Row #:") * 2 - 1
        update insert at q row ["" ""] x: copy q unview do qq
    ]
    btn "Remove" [
        row: (to-integer request-text/title "Row # to delete:") * 2 - 1
        update remove/part (at q row) 2 x: copy q unview do qq
    ]
    btn "Col 1" [update editor extract q 2]
    btn "Col 2" [update editor extract/index q 2 2]
    btn "Save" [update save to-file request-file/save q]
    btn "Load" [x: load to-file request-file do qq]
    btn "History" [
        m: copy "ITEMS YOU'VE EDITED:^/^/" update for i 1 (length? q) 1 [
            if (to-string pick x i) <> (to-string pick q i) [
                append m rejoin [pick x i " " pick q i newline]
            ]
        ] editor m 
    ]
]]

;-------------------------------------------------------------------------
; This final example clarifies how to add additional columns, how to use
; GUI widgets other than fields to display the data (text widgets, in this
; case), how to make the widgets perform any variety of actions, and how
; to get data from the grid when not every widget has text on its face.
; It also demonstrates some additional changes to the look of the grid.
;-------------------------------------------------------------------------

x: copy [] for i 1 99 1 [append x reduce [i random 99x99 random "abcd"]]

grid: copy [origin 0x0 across space 0x0]
forskip x 3 [
    append grid compose [
        b: box 520x26 either (remainder((index? x)- 1)6)= 0 [white][beige]
        origin b/offset
        text bold 180 (form x/1)
        text 120 center blue (form x/2) [alert face/text]
        text 180 right purple (form x/3) [face/text: request-text] return
        box 520x1 green return
    ]
]
view center-face layout [
    across space 0  
    g: box 520x290 with [pane: layout grid pane/offset: 0x0]
    scroller 16x290 [
        g/pane/offset/y: g/size/y - g/pane/size/y * value / 2 show g
    ]
    return box 1x10 return  ; just a spacer
    btn "Get Data Block" [
        q: copy [] 
        foreach face g/pane/pane [
            if face/style = 'text [append q face/text]
        ]
        editor q
    ]
]