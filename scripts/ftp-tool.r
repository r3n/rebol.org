REBOL [
    File: %ftp-tool.r
    Date: 30-Aug-2009
    Title: "FTP Tool"
    Author:  Nick Antonaccio
    Purpose:  {
        Full featured FTP application.
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

Instructions: {

    Enter your username, password, and FTP URL in the text field, and
    hit [ENTER].
    
    BE SURE TO END YOUR FTP URL PATH WITH "/".  
    
    URLs can be saved and loaded in multiple config files for future use.

    CONFIG FILES ARE STORED AS PLAIN TEXT, SO KEEP THEM SECURE.
    
    Click folders to browse through any dir on your web server.  Click
    text files to open, edit and save changes back to the server.
    Click images to view.  Also upload/download any type of file,
    create new files and folders, change file names, copy and delete
    files, change permissions, etc.
    
    Taken from the tutorial at http://musiclessonz.com/rebol.html

}
connect: does [
    either (to-string last p/text) = "/" [
    if error? try [
        f/data: sort append read to-url p/text "../" show f
        ][
        alert "That is not a valid FTP address, or the connection failed."
        ]
    ][
        editor to-url p/text
    ]
]
view center-face layout [
    p: field 600 "ftp://user:pass@website.com/" [connect]
    across
    btn "Connect" [connect]
    btn "Load URL" [
        config: to-file request-file/file %/c/ftp.cfg
        either exists? config [
            if (config <> %none) [
                my-urls: copy []
                foreach item read/lines config [append my-urls item]
                if error? try [
                    p/text: copy request-list "Select a URL:" my-urls
                ] [break]
            ]
        ][
            alert "First, save some URLs to that file..."
        ]
        show p focus p
    ]
    btn "Save URL" [
        url: request-text/title/default "URL to save:" p/text
        if url = none [break]
        config-file: to-file request-file/file/save %/c/ftp.cfg
        if (url <> none) and (config-file <> %none) [
            if not exists? config-file [
                write/lines config-file ftp://user:pass@website.com/
            ]
            write/append/lines config-file to-url url
            alert "Saved"
        ]
    ]
    below
    f: text-list 600x350 [
        either (to-string value) = "../" [
            for i ((length? p/text) - 1) 1 -1 [
                if (to-string (pick p/text i)) = "/" [
                    clear at p/text (i + 1) show p
                    f/data: sort append read to-url p/text "../" show f
                    break
                ]
            ]
        ][
            either (to-string last value) = "/" [
                p/text: rejoin [p/text value] show p
                f/data: sort append read to-url p/text "../" show f
            ][
                if ((request "Edit/view this file?") = true) [
                    either find [%.jpg %.png %.gif %.bmp] suffix? value [
                        view/new layout [
                            image load to-url join p/text value
                        ]
                    ][
                        editor to-url rejoin [p/text value]
                    ]
                ]
            ]
        ]
    ]
    across
    btn "Get Info" [
        p-file: to-url rejoin [p/text f/picked]
        alert rejoin ["Size: " size? p-file " Date: " modified? p-file]
    ]
    btn "Delete" [
        p-file: to-url request-text/title/default "File to delete:"
            join p/text f/picked
        if ((confirm: request "Are you sure?") = true) [delete p-file]
        f/data: sort append read to-url p/text "../" show f
        if confirm = true [alert "File deleted"]
    ]
    btn "Rename" [
        new-name: to-file request-text/title/default "New File Name:"
            to-string f/picked
        if ((confirm: request "Are you sure?") = true) [
            rename (to-url join p/text f/picked) new-name
        ]
        f/data: sort append read to-url p/text "../" show f
        if confirm = true [alert "File renamed"]
    ]
    btn "Copy" [
        new-name: to-url request-text/title/default "New Path:"
            (join p/text f/picked)
        if ((confirm: request "Are you sure?") = true) [
            write/binary new-name read/binary to-url join p/text f/picked
        ]
        f/data: sort append read to-url p/text "../" show f
        if confirm = true [alert "File copied"]
    ]
    btn "New File" [
        p-file: to-url request-text/title/default "New File Name:"
            join p/text "ENTER-A-FILENAME.EXT"
        if ((confirm: request "Are you sure?") = true) [
            write p-file ""
            ; editor p-file
        ]
        f/data: sort append read to-url p/text "../" show f
        if confirm = true [alert "Empty file created - click to edit."]
    ]
    btn "New Dir" [
        make-dir x: to-url request-text/title/default "New folder:" p/text
        alert "Folder created"
        p/text: x show p
        f/data: sort append read to-url p/text "../" show f
    ]
    btn "Download" [
        file: request-text/title/default "File:" (join p/text f/picked)
        l-file: next to-string (find/last (to-string file) "/")
        save-as: request-text/title/default "Save as..." to-string l-file
        write/binary (to-file save-as) (read/binary to-url file)
        alert "Download Complete"
    ]
    btn "Upload" [
        file: to-file request-file
        r-file: request-text/title/default "Save as..." 
            join p/text (to-string to-relative-file file)
        write/binary (to-url r-file) (read/binary file)
        f/data: sort append read to-url p/text "../" show f
        alert "Upload Complete"
    ]
    btn "Chmod" [
        p-file: to-url request-text/default rejoin [p/text f/picked]
        chmod: to-block request-text/title/default "Permissions:"
            "read write execute"
        write/binary/allow p-file (read/binary p-file) chmod
        alert "Permissions changed"
    ]
    btn-help [inform layout[backcolor white text bold as-is instructions]]
    do [focus p]
]




{ ; BONUS: here's a useful 1-liner FTP Tool in 133 BYTES:

u: :to-url view layout[p: field[either dir? u v: value[f/data: read u v show f][editor u v]]f: text-list[editor u join p/text value]]

; Enter your URL into the text field.  You can change folders at any time
; by typing into the text field - be sure to include a trailing "/".  To
; create a new file, just type its path into the text field.  Click any
; file to view, edit, and save changes back to the server.

} 
