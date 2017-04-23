rebol[
    title: "HTTP HEAD"
    author: "Tom Conlin"
    date: 24-Feb-2005
    file: %http-head.r
    version: 0.0.2
    Library: [ 
        level: 'intermediate 
        platform: 'all 
        type: [function how-to tool] 
        domain: [http web] 
        tested-under: [unix win] 
        support: none 
        license: none 
        see-also: none
    ]
    purpose: {Issue a HTTP HEAD command}
]

http-head: func[url [url!] /local port spec result][
    spec: decode-url url
    port: open compose[ scheme: 'tcp host: spec/host 
    	port-id: either spec/port-id[spec/port-id][80] 
    	timeout: 10
    ]
    insert port rejoin["HEAD " url " HTTP/1.0^/^/"]
    wait port 
    result: copy port 
    close port
    result
]