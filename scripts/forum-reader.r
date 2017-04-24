REBOL [
    title: "Forum Reader"
    date: 18-May-2010
    file: %forum-reader.r
    author:  Nick Antonaccio
    purpose: {
        Offline reader to download, save, and read the entire collection
        of forum messages at http://rebolforum.com (i.e., to keep the
        messages for later reference).   The message block is stored at
        http://rebolforum.com/bb.db.
    }
]

topics: copy []  database: copy []

update: does [
    topics: copy []
    database: copy load to-file request-file/title/file
        "Load Messages:" "" %rebolforum.txt
    foreach topic database [
        append topics first topic
    ]
    t1/data: copy topics
    show t1
]

view layout [
    across
    t1: text-list 200x400 data topics [
        messages: copy ""
        foreach [message name time] (at pick database t1/cnt 2) [
            append messages rejoin [
                message newline newline name "  " time newline newline
                "---------------------------------------"  newline newline
            ]
        ]
        a1/text: copy messages
        show a1
    ]
    a1: area 400x400
    return
    btn "Download Current Online Messages" [
        write to-file request-file/save/title/file
            "Save Messages to File:" "" %rebolforum.txt
            read http://rebolforum.com/bb.db
    ]
    btn "Load Locally Saved Messages" [update]  
]