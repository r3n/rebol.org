REBOL [
    Title: "Search Mail for REBOL Scripts"
    Date: 30-May-2000
    File: %mbxscripts.r
    Author: "Carl Sassenrath"
    Purpose: {
        Search a mailbox file (e.g. Eudora) for email messages
        containing REBOL scripts.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: [tool] 
        domain: 'email 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print "Reading mailbox..."
mailbox: read %"/c/program files/qualcomm/eudora mail/in.mbx"

;-- Determine the marker for message separation:
first-line: copy/part mailbox find mailbox newline
parts: parse first-line ""
marker: reform [parts/1 parts/2]

scripts: make string! 100000

parse mailbox [
    some [thru marker thru newline copy message to marker
        (mail: import-email message
        if code: script? mail/content [
            print mail/subject
            repend scripts [
                newline newline
                "---------------" newline
                "From:    " mail/from newline
                "Date:    " mail/date newline
                "Subject: " mail/subject newline
                code
            ]
        ]
    )]
]

write %scripts.txt scripts
