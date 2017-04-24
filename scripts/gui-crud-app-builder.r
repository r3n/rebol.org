REBOL [
    title: "GUI CRUD App Builder"
    date: 10-Dec-2013
    file: %gui-crud-app-builder.r
    author:  Nick Antonaccio
    purpose: {
        CRUD is an acronym for "Create Read Update and Delete". 
        Familiar types of apps such as contact managers, inventory systems,
        home video databases, etc., are examples of typical CRUD data storage
        applications.  This script is a simple CRUD app maker that allows you to
        instantly create CRUD apps which store, retrieve, sort, etc. records made
        of fields of data.  The generated application scripts can be customized
        however desired, by adding your own of code.

        Video is available at http://www.youtube.com/watch?v=ROL33-Fi2g8
    }
]

builder: {
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
        remove/part find f: load filename do rejoin [
            fields/1 "/text"
        ] count
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
gui: [backdrop white]
append gui widgets
append gui [
    h2 "Existing Records:"
    t: text-list blue 400x100 data (extract f: load filename count) [tl]
    box 1x10 white
    across
    btn "Save" #"^s" [sv]
    n: btn "New" #"^n" [clr]
    d: btn "Delete" #"^~" [dlt]
    btn "Edit Raw Data File" [editor filename]
]
view center-face g: layout gui
}

view layout [
    h4 "Application Title:"
    filename: field "MyApp"
    h4 "Add New Data Fields to Your App:"
    across
    field-label: field 250 "(Type a new field label here - no spaces)"
    field-type: drop-down data ["field" "area"] [
        if face/text = "field" [field-size/text: "200x25"]
        if face/text = "area" [field-size/text: "400x100"]
        show field-size
    ]
    text "Size: " 
    field-size: field 60 "400x100"
    btn "Add Data Field" [
        if find filename/text " " [
            alert "Please remove spaces from the App Title"
            return
        ]
        if find field-label/text " " [
            alert "Please remove spaces from the field label"
            return
        ]
        if field-type/text = none [
            alert "Please select a field type from the drop-down selector"
            return
        ]
        if find code-area/text join field-label/text ":" [
            alert {Duplicate field labels not allowed.  Please choose
                   a new label for any added fields"}
            return
        ]
        append code-area/text rejoin [
            {    h4 "} field-label/text {:" } 
            field-label/text {: } field-type/text { } field-size/text
            newline
        ]
        show code-area
    ]
    return
    h4 "App Layout Code (generated automatically by adding fields above):"
    return
    code-area: area  600x300
    return
    btn "CREATE NEW APP" [
        replace filename/text ".r" ""  show filename
        if exists? to-file join filename/text ".r" [
            alert {An application by that name already exists.  Please
                   create a new application file name.}
            return
        ]
        write created-app: to-file join filename/text ".r" rejoin [
            {rebol [title: "} filename/text {"]} newline
            "filename: %" to-file filename/text newline
            "widgets: [" newline
            code-area/text newline
            "]" newline builder
        ]
        launch created-app
    ]
    btn "Run Existing App" [
        if error? try [do request-file/only] [
            alert {Error running selected app. Be sure to run ".r" files.}
        ]
    ]
    btn "Edit Existing App Code" [
        if error? try [editor request-file/only] [
            alert "Error editing selected app"
        ]
    ]
]
