REBOL [
    Title: "Email attachments"
    Date: 20-Jul-1999
    File: %attach.r
    Author: "Sterling Newton"
    Purpose: "Send email with base64 encoded attachments"
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

line-break: func [data /num length] [
    if not num [length: 70]
    while [not tail? data] [
        data: insert skip data length "^/"
    ]
    data: head data
]

mail: func [
    {send a message with attached files}
    mesg [string!] {the message body}
    headers [object!] {headers object; usually made from system/standard/email}
    files [block!] {list of items to send; files will be loaded, 
other objects should be listed as [attachment-name object]}
    /local header make-boundary make-file-mime message boundary
][
    headers: make headers [MIME-Version: "1.0"]
    make-boundary: func [] [
        join "--__REBOL--" [system/version "--" now "--" 
            random to-integer (100 * (third now/time))
        ]
    ]
    make-file-mime: func [file /local data] [
        data: make string! 250
        insert data net-utils/export make object! [
            Content-Type: join {application/octet-stream; name="} [file {"}]
            Content-Transfer-Encoding: "base64"
            Content-Disposition: join {attachment; filename="} [file {"^/}]
        ]
        data
    ]
    message: make string! (length? mesg)
    header: headers
    if (length? files) > 0 [
         boundary: make-boundary
        header: make headers [
            content-type: join "multipart/mixed; boundary=" [
                {"} skip boundary 2 {"}
            ]
        ]
        insert mesg join boundary ["^/Content-type: text/plain^/^/"]
        append mesg "^/^/"
        foreach file files [
            file: reduce file
            append mesg join boundary [
                "^/" make-file-mime 
                either file? file [last parse file "/"] [first file]
            ]
            append mesg line-break 
            enbase either file? file [
                print ["reading file: " file] 
                read/binary file
            ] [
                either any-string? second file [
                    print ["attaching string object as: " first file] 
                    second file
                ] [
                    print ["attaching non-string object as: " first file] 
                    mold second file
                ]
            ]
        ]
        append mesg join boundary "--^/"
    ]
    send/header header/to mesg header
    reduce [header mesg]
]
