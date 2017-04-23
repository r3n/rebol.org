REBOL [
    title: "Card File"
    date: 5-Mar-2010
    file: %card-file.r
    author:  Nick Antonaccio
    purpose: {
        This is the quintessential simple text field storage application. 
        It can be used as shown here, to save contact information, but by
        adjusting just a few lines of code and text labels, it could be easily
        adapted to store recipes, home inventory information, or any other
        type of related pages of data.
 
        A version of this script with line-by-line documentation is available
        at http://re-bol.com
    }
]

write/append %data.txt ""
database: load %data.txt

view center-face gui: layout [
    text "Load an existing record:"
    name-list: text-list blue 400x100 data sort (extract database 4) [
        if value = none [return]
        marker: index? find database value
        n/text: pick database marker
        a/text: pick database (marker + 1)
        p/text: pick database (marker + 2)
        o/text: pick database (marker + 3)
        show gui
    ]
    text "Name:"       n: field 400
    text "Address:"    a: field 400
    text "Phone:"      p: field 400
    text "Notes:"      o: area  400x100
    across
    btn "Save" [
        if n/text = "" [alert "You must enter a name." return]
        if find (extract database 4) n/text [
            either true = request "Overwrite existing record?" [
               remove/part (find database n/text) 4
            ] [
               return
            ]
        ]
        save %data.txt repend database [n/text a/text p/text o/text]
        name-list/data: sort (extract copy database 4)
        show name-list
    ]
    btn "Delete" [
        if true = request rejoin ["Delete " n/text "?"] [
            remove/part (find database n/text) 4
            save %data.txt database
            do-face clear-button 1
            name-list/data: sort (extract copy database 4)
            show name-list
        ]
    ]
    clear-button: btn "New" [
        n/text: copy  ""
        a/text: copy  ""
        p/text: copy  ""
        o/text: copy  ""
        show gui
    ]
]