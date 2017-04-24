REBOL [
    Title: "REBOL Directory Services Lookup"
    Date: 1-Jun-2001
    Version: 1.1.0
    File: %lookup.r
    Author: "Carl Sassenrath"
    Purpose: {Provides a simple but effective directory server for
peer-to-peer and other types of REBOL applications.
Can be installed on any CGI webserver.
}
    History: [
    1.1.0 "Thanks to Cal Dixon for file lock."
]
    Email: carl@rebol.com
    Examples: {
        "cmd=post&service=chat&name=carl&data=9080"
        "cmd=post&service=chat
        "cmd=find&service=chat&name=carl"
        "cmd=remove&service=chat&name=sean"
        "cmd=find&service=chat&name=carl"
        "cmd=find&service=chat"
        "cmd=find"
        "cmd=version"
        "cmd=info"
    }
    Note: {
        Structure: "service-name" ["name" ip time data]
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [cgi ldc other-net tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print "Content-type: text/html^/^/"

entry-size: 4   ; size of each service entry
time-out: 0:05  ; remove service item after this amount of time
test: not system/options/cgi/remote-addr  ; enables local test mode
op-email: op@example.com
set-net [site@example.net example.net]

either test [
    cgi: context [
        remote-addr: "1.2.3.4"
        query-string: "cmd=post&service=chat&name=sean&data=9080"
    ]
    file-path: %./
][
    cgi: system/options/cgi
    file-path: %/home/WWW_pages/rebol/
]

serv-file: file-path/service-db.r
lock-path: file-path/lock-

request: context [
    cmd: service: options: name: data: none
    ip: to-tuple cgi/remote-addr
]

lock-file: func [file retries /local retry] [
    file: second split-path file
    retry: 0
    while [error? try [make-dir rejoin [lock-path file "/"]]] [
        if (retry: retry + 1) > retries [return false]
        wait 0.5
    ]
    true
]

unlock-file: func [file] [
    delete rejoin [lock-path second split-path file "/"]
]

save-services: func [data] [
    either lock-file serv-file 40 [
        save serv-file data
        unlock-file serv-file
    ][
        send op-email {Lookup Error^/File lock failed, check server.^/}
    ]
]

post-service: func [serv req /local item entry] [
    if not all [req/service req/name req/data] [return 'bad-post]
    if none? serv [
        serv: copy []
        repend services [req/service serv]
    ]
    clear-old serv
    item: find serv req/name
    entry: reduce [req/name req/ip now req/data]
    either item [change/part item entry entry-size][insert serv entry]
    save-services services
    serv
]

clear-old: func [serv /local flag] [
    while [not tail? serv] [
        either now - time-out > serv/3 [remove/part serv entry-size][
            flag: true
            serv: skip serv entry-size
        ]
    ]
    if flag [save-services services]
    head serv
]

find-service: func [serv req /local item entry] [
    all [
        result: services
        serv
        result: serv
        clear-old serv
        req/name
        result: 'none
        item: find serv req/name
        copy/part item entry-size
    ]
    result
]

remove-service: func [serv req /local item] [
    either all [serv req/name item: find serv req/name] [
        either item/2 = req/ip [
            remove/part item entry-size
            save-services services
            'ok
        ]['bad-ip]
    ]['bad-target]
]

req: make request decode-cgi cgi/query-string
services: either exists? serv-file [load serv-file][[]]
serv: select services req/service

probe switch/default req/cmd [
    "post" [post-service serv req]
    "find" [find-service serv req]
    "remove" [remove-service serv req]
    "version" [system/script/header/version]
    "info" [third system/script/header]
]['bad-command]

if test [print "done" halt] 