REBOL [
    Title: "Cookie Client"
    Date: 5-Aug-1999
    File: %cookies-client.r
    Author: ["Martin Johannesson" "Andrew Grossman" "Graham Chiu"]
    Usage: {
    There are three words here which are very similar in function
    HTTP-GET
        To fetch a web page that requires a cookie of name "foo" and value "bar":

        tmp: http-get http://server.com/page.html ["foo" "bar"]

        To view the resulting page:
            print tmp/content
    If no cookie is required, use an empty list as the parameter
        tmp: http-get http://server.com/page.html []

    HTTP-POST
    To post values to a web form that does not require cookies set

        tmp: http-post http://server.com/page.html ["name1" "value1" "name2" "value2" ... ]

    Note that the name and values pairs will be url encoded by http-post
    If cookies are returned, then one is placed into cookie-data, and the other is
    accessible as tmp/set-cookie

    HTTP-POSTC
    To post values to a web form that requires cookies set

    Preset the cookies values in global variables cookie-data, cookie-data2

        tmp: http-postc http://server.com/page.html ["name1" "value1" "name2" "value2" ... ]

    Note that the name and values pairs will be url encoded by http-post, and the 
    cookies must be pre-urlencoded.
    If cookies are returned, then one is placed into cookie-data, and the other is
    accessible as tmp/set-cookie
    }
    Purpose: {
        To grab cookies from the server and post form data.
    }
    Email: [grossdog@dartmouth.edu gchiu@compkarori.co.nz]
    Notes: {
        Modification of Andrew Grossman's cookies-client script by Graham Chiu. 
        Modification of Martin Johannesson's POST script by Andrew Grossman.
        Orig. available at www.rebol.com in users' library.
    }
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: 'web 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
] 

cookie-data: ""
cookie-data2: ""

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

http-post: func [
    {Post a form to a web server without including cookie in the header for identification}
    url "The URL"
    data [block!] "A block of name/value pairs to represent the form data"
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
    remove back tail encoded-data

    HTTP-Post-Header: make object! [
    Accept: "text/html"
        User-Agent: reform ["REBOL" system/version]
 ;       Referer: "http://www.mtnsms.com/default.asp?action=login"
        Content-Type: "application/x-www-form-urlencoded" 
    Content-Length: length? encoded-data
    ]

    http-request: rejoin [
        "POST /"
        either found? port-spec/path [port-spec/path][""] 
        either found? port-spec/target [port-spec/target][""]
        " HTTP/1.0"
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
        insert http-port net-utils/export HTTP-Post-Header "^/" 
        insert http-port encoded-data

comment {
  print http-request
  print net-utils/export HTTP-Post-Header 
  print encoded-data 
}

    buffer: make string! 10000
    tmp-buffer: reform ["HTTP-Response:" pick http-port 1]
    while [not none? tmp-buffer] [
        append buffer rejoin [tmp-buffer "^/"]
        tmp-buffer: pick http-port 1
    ]


    close http-port

    parse buffer [ thru "Set-Cookie:" copy cookie-data to ";" ]

    HTTP-Header: make object! [
        HTTP-Response: Date: Server: Last-Modified: none
        Accept-Ranges: Content-Encoding: Content-Type: none 
        Content-Length: Location: Expires: Referer: Connection: none 
    ] 

    parse-header HTTP-Header buffer
]

http-post-cookie: func [
    {Post a form to a web server and include cookie in the header for identification}
    url "The URL"
    data [block!] "A block of name/value pairs to represent the form data"
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
    remove back tail encoded-data

    HTTP-Post-Header-Cookie: make object! [
    Accept: "text/html"
        User-Agent: reform ["REBOL" system/version]
;        Referer: "http://www.mtnsms.com/sms/"
        Cookie: join cookie-data [ "; " cookie-data2 ]
        Content-Type: "application/x-www-form-urlencoded" 
    Content-Length: length? encoded-data
    ]

    http-request: rejoin [
        "POST /"
        either found? port-spec/path [port-spec/path][""] 
        either found? port-spec/target [port-spec/target][""]
        " HTTP/1.0"
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
        insert http-port net-utils/export HTTP-Post-Header-Cookie "^/" 
        insert http-port encoded-data
comment {
  print http-request
  print net-utils/export HTTP-Post-Header-Cookie
  print encoded-data
}

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



http-get: func [
    {Retrieve a page from web server}
    url "The URL"
    data [block!] "A block of name/value pairs to represent the cookies"
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
                url-encode name "=" url-encode value "; "
        ]
    ]
    remove back tail encoded-data
    remove back tail encoded-data

    HTTP-Post-Header: make object! [
        Accept: "*/*"
        User-Agent: reform ["REBOL" system/version]
        Host: port-spec/host
    ]

    HTTP-Post-Header-Cookie: make object! [
        Accept: "*/*"
        User-Agent: reform ["REBOL" system/version]
        Host: port-spec/host
        Cookie: encoded-data
    ]

    http-request: rejoin [
        "GET /"
        either found? port-spec/path [port-spec/path][""] 
        either found? port-spec/target [port-spec/target][""]
        " HTTP/1.0^/"
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
    if encoded-data > "" [
            insert http-port net-utils/export HTTP-Post-Header-Cookie  "^/"
    ][
            insert http-port net-utils/export HTTP-Post-Header  "^/"    
    ]

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
    Set-Cookie: none Set-Cookie: none
    ] 

    parse-header HTTP-Header buffer
]
