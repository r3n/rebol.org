REBOL [
    Title: "Save email attachments to disk"
    Date: 9-Jun-1999
    File: %detach.r
    Author: "Sterling Newton"
    Usage: "Detach message"
    Purpose: "Detach mail attachments"
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [email file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

find-filename: func [headers [object!] /local file] [
    if error? try [file: to-file headers/content-description] [
        if error? try [
            file: to-file any [
                find/tail headers/content-type {name="}
                find/tail headers/content-disposition {name="}
            ]
            head remove back tail file
        ] [none]
    ]
    file
]

detach: func [
    {takes in the whole email text and returns a block of filenames 
and decoded base64 attachments present in the email}
    email [string!] 
    /local boundary body attached headers file
][
   print "starting decoding process..."
   headers: import-email email
   boundary: headers/content-type
   if boundary: find/tail boundary {boundary="} [
        remove back tail boundary
        print ["Boundary string:" boundary]
   ]
   either boundary [
        attached: make block! 2
        body: headers/content
        while [body: find/tail body boundary] [
            print ["Found message attachment; remaining length:" length? body]
            headers: parse-header system/standard/email skip body 1
            ; end of the message attachments?
            if find/match body "--" [print "attachents finished" break]
            file: copy/part headers/content find body: headers/content "^/--"
            either all [
                not error? try [headers/content-transfer-encoding] 
                find headers/content-transfer-encoding "base64"
            ] [ 
                print "about to decode..."
                insert file "64#{" append file "}"
                print ["Adding attachment; encoded length:" length? file]
                seek: file
                while [seek: find seek "^/"] [remove seek]
                append attached reduce [find-filename headers to-string load file]
            ] [ ; not base64 encoded... just add it directly
                append attached reduce [find-filename headers file]
            ]
        ]
        attached
    ] [none]
]
