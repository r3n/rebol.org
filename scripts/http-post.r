REBOL [
    Title: "Simple HTTP POST"
    Date: 30-Jun-1999
    File: %http-post.r
    Author: "Martin Johannesson"
    Purpose: {
        This script sends a "form" to a webserver using the POST
        method. The included example translates a string in English
        to German by posting the data to AltaVista's translation
        web page and then parsing the reply.
    }
    Email: d95-mjo@nada.kth.se
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [web other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
] 

url-encode: func [
    {URL-encode a string}
    data "String to encode"
    /local new-data
][
    new-data: make string! ""
    normal-char: charset [
        #"A" - #"Z" #"a" - #"z"
        #"@" #"." #"*" #"-" #"_"
        #"0" - #"9"
    ]
    if not string? data [return new-data]
    forall data [
        append new-data either find normal-char first data [
            first data
        ][
            rejoin ["%" to-string skip tail (to-hex to-integer first data) -2]
        ]
    ]
    new-data
]

http-post-form: func [
    {Post a form to a web server}
    url "The URL to post to"
    data [block!] "A block of name/value pairs to represent the form"
    /local 
    encoded-data
    port-spec
    HTTP-Post-Header
    http-request
    buffer
    tmp-buffer
][
    port-spec: make port! [
        scheme: 'tcp
        port-id: 80
        timeout: 0:10
    ]
    net-utils/url-parser/parse-url port-spec url

    encoded-data: make string! ""
    foreach [name value] data [
        append encoded-data rejoin [
                url-encode name "=" url-encode value "&"
        ]
    ]
    remove back tail encoded-data

    HTTP-Post-Header: make object! [
        Accept: "*/*"
        User-Agent: reform ["REBOL" system/version]
        Host: port-spec/host
        Content-Type: "application/x-www-form-urlencoded"
        Content-Length: length? encoded-data
    ]

    http-request: rejoin [
        "POST /"
        either found? port-spec/path [port-spec/path][""] 
        either found? port-spec/target [port-spec/target][""]
        " HTTP/1.0^/"
        net-utils/export HTTP-Post-Header "^/"
        encoded-data
    ]

    http-port: open/lines [
        scheme: 'tcp
        port-id: port-spec/port-id
        timeout: port-spec/timeout
        host: port-spec/host
        user: port-spec/user
        pass: port-spec/pass
    ]

    insert http-port http-request

    buffer: make string! 10000
    tmp-buffer: reform ["HTTP-Response:" pick http-port 1]
    while [not none? tmp-buffer] [
        append buffer rejoin [tmp-buffer "^/"]
        tmp-buffer: pick http-port 1
    ]
    close http-port

    HTTP-Header: make object! [
        HTTP-Response: Date: Server: Last-Modified: none
        Accept-Ranges: Content-Encoding: Content-Type: none 
        Content-Length: Location: Expires: Referer: Connection: none
    ] 

    parse-header HTTP-Header buffer
]



english-to-german: func [
    {Translates a string in English to German, using babelfish.altavista.com}
    english-text "String in english"
][
    not-lt-gt: complement charset [#"<" #">"]
    tag-rule: ["<" some not-lt-gt ">"]  

    tmp: http-post-form http://babelfish.altavista.com/cgi-bin/translate? reduce [
        "doit" "done"
        "urltext" english-text
        "lp" "en_de"
    ]

    if none? find tmp/HTTP-Response "200" [return join "Error: " tmp/HTTP-Response]

    either parse tmp/content [
        thru "Auf Deutsch:" to "<font" thru ">" copy trans to "<" to end
    ][
        return trans
    ][
        return "Error: Unable to parse Babelfish HTML"
    ]
]

print english-to-german "hello, how are you?"
