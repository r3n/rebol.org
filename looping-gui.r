Rebol [
    title: "Looping through data GUI"
    date: 29-june-2008
    file: %looping-gui.r
    purpose: {
        An example demonstrating how to accomplish goals similar to the
        'Looping through data' demo, using GUI techniques.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

users: [
    ["John" "Smith" "123 Tomline Lane" "Forest Hills, NJ" "555-1234"]
    ["Paul" "Thompson" "234 Georgetown Place" "Peanut Grove, AL" "555-2345"]
    ["Jim" "Persee" "345 Pickles Pike" "Orange Grove, FL" "555-3456"]
    ["George" "Jones" "456 Topforge Court" "Mountain Creek, CO" ""]
    ["Tim" "Paulson" "" "" "555-5678"]
]
user-list: copy []
foreach user users [append user-list user/1]
user-list: sort user-list

view display-gui: layout [
    h2 "Click a user name to display their information:"
    across
    list-users: text-list 200x400 data user-list [
        current-info: []
        foreach user users [
            if find user/1 value [
                current-info: rejoin [
                    "FIRST NAME:  " user/1 newline newline
                    "LAST NAME:   " user/2 newline newline
                    "ADDRESS:     " user/3 newline newline
                    "CITY/STATE:  " user/4 newline newline
                    "PHONE:       " user/5
                ]
            ]
        ]
        display/text: current-info
        show display show list-users
    ]
    display: area "" 300x400 wrap
]