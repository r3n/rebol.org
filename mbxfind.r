REBOL [
    Title: "Search Mailbox"
    Date: 4-Jun-1999
    File: %mbxfind.r
    Author: "Carl Sassenrath"
    Purpose: {
        Search a Eudora mailbox file and output a file with
        all the messages that contain a given string.
    }
    Note: "Very simple search method. Matches partial words."
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [email text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

mailbox: read %in.mbx

string: ask "Search for what? "

;-- Determine the marker for message separation:
first-line: copy/part mailbox find mailbox newline
parts: parse first-line ""
marker: reform [parts/1 parts/2]

msg-count: 0
msg-data: make string! 10000

parse mailbox [
    some [thru marker thru newline copy message to marker
        (mail: import-email message
        if find mail/content string [
            print mail/subject
            append msg-data "<----->^/"
            append msg-data message
            msg-count: msg-count + 1
        ]
    )]
]

print [msg-count "messages found"]
write %result.txt msg-data
