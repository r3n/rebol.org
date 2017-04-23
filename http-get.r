REBOL [
    Title: "http/1.1 get"
    Date: 31-Aug-2001
    Version: 1.0.0
    File: %http-get.r
    Author: "Viktor Pavlu"
    Purpose: {dumps the response header from requesting
a file via TCP from a host using http/1.1
}
    Email: viktor_pavlu@hotmail.com
    Web: http://idefix2.htl-tex.ac.at/~vpavlu/
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'tcp 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

file:  "platforms.html"      ;file to read (if empty, retrieves '/')

http-port: open/lines [      ;opens a tcp connection
  scheme:   'tcp
  host:     "www.rebol.com"
  port-id:  80
]

insert http-port rejoin [    ;write request to port
  "GET /" file " HTTP/1.1^/Host:" http-port/host "^/^/"
]    

header: make block! 10       ;get header from reply
while [ not empty? reply: first http-port ][
    repend header [ reply newline ]
]

;page: copy http-port         ;get the page

close http-port              ;close the port as we dont need it anymore

print header                                   