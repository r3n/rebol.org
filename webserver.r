REBOL [
    Title: "Micro Web Server"
    Date: 10-Jun-2000
    File: %webserver.r
    Purpose: {
        Here is a web server that works quite well and can be
        run from just about any machine. It's not only fast,
        but its also small so it's easy to enhance.
    }
    History: [
    10-Jun-2000 "Buffers the entire request, adds address" 
    22-Jun-1999 "First posted"
]
    Notes: {
        Set the web-dir to point to the file directory that
        contains your web site files, such as index.html.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

web-dir: %.   ; the path to where you store your web files

listen-port: open/lines tcp://:80  ; port used for web connections

errors: [
    400 "Forbidden" "No permission to access:"
    404 "Not Found" "File was not found:"
]

send-error: function [err-num file] [err] [
    err: find errors err-num
    insert http-port join "HTTP/1.0 " [
        err-num " " err/2 "^/Content-type: text/html^/^/" 
        <HTML> <TITLE> err/2 </TITLE>
        "<BODY><H1>SERVER-ERROR</H1><P>REBOL Webserver Error:"
        err/3 " " file newline <P> </BODY> </HTML>
    ]
]

send-page: func [data mime] [
    insert data rejoin ["HTTP/1.0 200 OK^/Content-type: " mime "^/^/"]
    write-io http-port data length? data
] 

buffer: make string! 1024  ; will auto-expand if needed

forever [
    http-port: first wait listen-port
    clear buffer
    while [not empty? request: first http-port][
        repend buffer [request newline]
    ]
    repend buffer ["Address: " http-port/host newline] 
    print buffer
    file: "index.html"
    mime: "text/plain"
    parse buffer ["get" ["http" | "/ " | copy file to " "]]
    parse file [thru "." [
            "html" (mime: "text/html") |
            "gif"  (mime: "image/gif") |
            "jpg"  (mime: "image/jpeg")
        ]
    ]
    any [
        if not exists? web-dir/:file [send-error 404 file]
        if error? try [data: read/binary web-dir/:file] [send-error 400 file]
        send-page data mime
    ]
    close http-port
]
