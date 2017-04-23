REBOL [
    Title: "Print Mailbox Subjects"
    Date: 4-Jun-1999
    File: %mbxsubjects.r
    Author: "Carl Sassenrath"
    Purpose: {
        Prints all the mail subject lines for a Eudora mailbox file.
    }
    Updated: 11-Oct-1999
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [email text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

mailbox: read %in.mbx

;-- Determine the marker for message separation:
first-line: copy/part mailbox find mailbox newline
parts: parse first-line ""
marker: reform [parts/1 parts/2]

parse mailbox [
    some [thru marker thru newline copy message [to marker | to end]
        (mail: import-email message print mail/subject)]
]

