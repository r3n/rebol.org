Rebol [
    title: "Listview Demo"
    date: 29-june-2008
    file: %listview-demo.r
    purpose: {
        A demo of the listview control by Henrik Mikael Kristensen.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

if not exists? %list-view.r [write %list-view.r read
 ;;    http://www.hmkdesign.dk/rebol/list-view/list-view.r
       http://97.107.135.89/www.hmkdesign.dk/data/projects/list-view/downloads/list-view.r
]
do %list-view.r
if not exists? %database.db [write %database.db {[][]}]
database: load %database.db

view center-face gui: layout [
    theview: list-view 775x200 with [
        data-columns: [Student Teacher Day Time Phone 
            Parent Age Payments Reschedule Notes]
        data: copy database
        tri-state-sort: false
        editable?: true
    ]
    across
    button "add row" [theview/insert-row]
    button "remove row" [theview/remove-row]
    button "filter data" [
        filter-text: request-text/title trim {
            Filter Text (leave blank to refresh all data):}
        if filter-text <> none [
            theview/filter-string: filter-text
            theview/update
        ]
    ]
    button "save db" [save %database.db theview/data]
]