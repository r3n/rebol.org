REBOL [
    title: "CRUD Builder"
    date: 10-Dec-2013
    file: %crudbuilder.r
    author:  Nick Antonaccio
    purpose: {
        A simple GUI application builder.  For each unique application, just copy this
        script to a new file name, edit the 'filename used to store record data (replace 
        %mycruddatafile with a filename specific to each new app), and then edit the
        'widgets block.  Any field or area widgets assigned a label will automatically be
        included in the app (i.e., item, info, sku, and notes, in the demo app below).
        You can include any number of such widgets, and the app will automatically allow
        you to create, save, edit, retrieve and delete records containing all of the labeled
        field data.  Select existing records using the automatically updated text-list widget.
        Create, save, and delete records using the buttons, and/or by using shortcut
        keystrokes (save: CTRL+S, new record: CTRL-N, delete currently selected
        record: DELETE key).
    }
]

;-------------------------------
;  EDIT HERE:
;-------------------------------

filename: %mycruddatafile

widgets: [
    h4 "Item:" 
    item: field
    h4 "Description:" 
    info: area wrap  
    h4 "SKU:"  
    sku: field
    h4 "Notes:"
    notes: field
]

;--------------------------------

fields: copy []
foreach widget widgets [
    if (set-word! = (type? widget)) [append fields to-word widget]
]
count: length? fields
write/append filename ""
dlt: does [
    if true = request "Sure?" [
        temp-block: copy [] 
        foreach fld fields [
            append temp-block compose do rejoin ["copy " fld "/text"]
        ]
        m: reduce temp-block
        remove/part find f: load filename do rejoin [fields/1 "/text"] count
        save filename f clr
        t/data: extract f count
        t/sld/redrag t/lc / max 1 length? head t/lines
        show g
    ]
]
tl: does [
    indx: (index? find t/data t/picked) - 1 * count
    repeat i (length? fields) [
        wdgt: fields/:i
        cnt: i
        do rejoin [wdgt "/text: pick f (indx + cnt)"]
    ]
    show g
]
clr: does [
    foreach fc fields [
        do rejoin ["clear-face " fc]
    ] 
    do rejoin ["focus " fields/1]
]
sv: does [
    dlt 
    save filename sort/skip repend f m count
    t/data: extract f count
    t/sld/redrag t/lc / max 1 length? head t/lines
    show g
]
gui: [
    backdrop white
    h2 "Existing Records:"
    t: text-list blue 400x100 data (extract f: load filename count) [tl]
]
append gui widgets
append gui [
    box 1x10 white
    across
    btn "Save" #"^s" [sv]
    n: btn "New" #"^n" [clr]
    d: btn "Delete" #"^~" [dlt]
    btn "Edit Raw Data File" [editor filename]
]
view center-face g: layout gui