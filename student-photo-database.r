REBOL [
    title: "Student Photo Database"
    date: 6-6-2010
    file: %student-photo-database.r
    author:  Nick Antonaccio
    purpose: {
        This example came from a question at: 
        http://synapse-ehr.com/forums/showthread.php?95-Connecting-to-an-Excel-spreadsheet
        It's based on the card file example at:
        http://www.rebol.org/view-script.r?script=card-file.r&sid=iwmh5vi
    }
]

; Here's an example CSV data file, exported from Excel
; (not really part of this program, but included here
; to demonstrate a fully working example):

write %StudentList.csv {STUDENTID,LASTNAME,FIRSTNAME,DOB,GRADE
111111,Doe,Steven D,6/16/1992,12
111112,Doe,Jonathan Daniel,12/16/1991,12
111113,Smith,Karen J,12/3/1991,12
111114,Jones,Michael J,6/4/1992,12
111115,Taylor,Ryan C,1/10/1992,12
111116,Adam,Kaitlan C,4/30/1992,12
111117,Washington,Gabryela,3/31/1992,12
111118,Travolta,Juan D,1/24/1992,12
111119,Cruise,Amber E,5/8/1992,12}

; Program starts here:

either exists? %data.txt [
    database: load %data.txt
][
    filename: %StudentList.csv
    database: copy []
    lines: read/lines filename
    foreach line lines [
        append database parse/all line ","
    ]
    remove/part database 5  ; get rid of headers
    for counter 6 ((length? database) + 12) 6 [
        insert (at database counter) to-file rejoin [
            "/C/Photos/image_" (pick database (counter - 5)) ".jpg"
        ]
    ]
    save %data.txt database
]

update: func [marker] [
    n/text: pick database marker
    a/text: pick database (marker + 1)
    p/text: pick database (marker + 2)
    o/text: pick database (marker + 3)
    g/text: pick database (marker + 4)
    i/text: pick database (marker + 5)
    if error? try [photo/image: load to-file i/text] [
        ; alert "No image selected"
        photo/image: none
    ]
    photo/text: ""
    show gui
]

view center-face gui: layout [
    text "Load an existing record:"
    name-list: text-list blue 300x80 data sort (extract database 6) [
        if value = none [return]
        marker: index? find database value
        update marker
    ]
    text "ID:"       n: field 300
    text "Last:"     a: field 300
    text "First:"    p: field 300
    text "BD:"       o: field 300
    text "Grade:"    g: field 300
    text "Image:"    i: btn 300 [
        i/text: to-file request-file 
        photo/image: load to-file i/text
        show gui
    ]
    at 340x20 photo: image white 300x300
    across
    btn "Save" [
        if n/text = "" [alert "You must enter a name." return]
        if find (extract database 6) n/text [
            either true = request "Overwrite existing record?" [
               remove/part (find database n/text) 6
            ] [
               return
            ]
        ]
        save %data.txt repend database [
            n/text a/text p/text o/text g/text i/text
        ]
        name-list/data: sort (extract copy database 6)
        show name-list
    ]
    btn "Delete" [
        if true = request rejoin ["Delete " n/text "?"] [
            remove/part (find database n/text) 6
            save %data.txt database
            do-face clear-button 1
            name-list/data: sort (extract copy database 6)
            show name-list
        ]
    ]
    clear-button: btn "New" [
        n/text: copy  ""
        a/text: copy  ""
        p/text: copy  ""
        o/text: copy  ""
        g/text: copy  ""
        i/text: copy  ""
        photo/image: none
        show gui
    ]
    next-btn: btn "Next"  [
        if error? try [
            old-num: copy n/text
            n/text: form ((to-integer n/text) + 1)
            show n
            marker: index? find database n/text
            update marker
        ] [n/text: copy old-num show n alert "No more records"]
    ]
    prev-btn: btn "Previous"  [
        if error? try [
            old-num: copy n/text
            n/text: form ((to-integer n/text) - 1)
            show n
            marker: index? find database n/text
            update marker
        ] [n/text: copy old-num show n alert "No more records"]
    ]
    key keycode [down] [do-face next-btn 1]
    key keycode [up] [do-face prev-btn 1]
    at 340x340 d1: drop-down 300 data [
        "Last Name" "First Name" "Birthday" "Grade"
    ]
    at 340x380 f2: field 300 "Select field above, type search text here" [
        if d1/data = none [alert "Select a search field above" return]
        search-field: to-integer select [
            "Last Name" 2 "First Name" 3 "Birthday" 4 "Grade" 5
        ] d1/data
        results: copy []
        for counter search-field (length? database) 6 [
            if find (pick database counter) copy f2/text [
                append results pick database (counter - search-field + 1)
            ]
        ]
        t/data: copy results  show t
        if [] = results [alert "None found"]
    ]
    at 340x420 t: text-list 300x60 [
        name-list/picked: copy value
        show name-list
        if value = none [return]
        marker: index? find database value
        update marker
    ]
]