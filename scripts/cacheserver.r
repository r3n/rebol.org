REBOL [
    Title: "Cacheserver"
    Date:  08-dec-2001
    File:  %cacheserver.r
    Purpose: { This is a tiny cache server, about as small as can be.
               It may not be usable in a real-world application, but
               it sure was a lot more fun to write than the 600 line
               java application...
    }
    Notes: {
        Based on the webserver.r script found at
        http://www.rebol.com/library/scripts/webserver.r
    }
    Todo: {
      A lot, really. Too much to mention here. But if
      I ever get around to doing anything more with this
      script, I'll make a TODO list.
    }
    History: [
        08-December-2001 "Made the script"
        25-Sep-2004 "Added the library header"
    ]
    Library: [
      level: 'intermediate
      domain: [http]
      license: none
      Platform: 'all
      Tested-under: none
      Type: [module]
      Support: none
    ]
]

debug?: true

send-page: func [data mime] [
    insert data rejoin ["HTTP/1.0 200 OK^/Content-type: text/html^/^/"]
    write-io http-port data length? data
]

send-error-page: func [/local data] [
    data: {"HTTP/1.0 400 Bad Request
Content-type: text/plain

Your browser sent a request that this server could not understand
}
    write-io http-port data length? data
]

listen-port: open/lines tcp://:3128  ; standard proxy port
buffer: make string! 1024
hash: make hash! []

forever [
    if debug? [print ""]
    http-port: first wait listen-port
    clear buffer
    if error? try [
      while [not empty? request: first http-port] [
        repend buffer [request newline]
      ]
    ] [
      if debug? [print "Timeout!"]
    ]
    repend buffer ["Address: " http-port/host newline]
    either not (first parse buffer none) = "get"
    [
      send-error-page
    ] [
      if debug? [ print mold buffer ]
      url: to-url second parse buffer none
      if none? t: select head hash url [
        t: read url
        insert hash reduce [url t]
      ]
      send-page t "text/html";
    ]
    if debug? [
      hash: head hash
      print "URLs in hash:"
      print "------------"
      forskip hash 2 [
        print first hash
      ]
      print join "(" reduce [ ((length? head hash) / 2) " items)"]
    ]
    close http-port
]

