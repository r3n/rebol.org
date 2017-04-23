REBOL [
	File: %tiny-server.r
	Date: 9-Mar-2013
	Title: "A Tiny Web Server"
	Purpose: {Inspired by Carl's Tiny Web Server: http://www.rebol.net/cookbook/recipes/0057.html. This one is compatible with Rebol 3.}
	Library: [
		level: 'intermediate
		platform: none
		type: none
		domain: [web other-net]
		tested-under: [ core 2.100.111.3.1 on "Win7" ]
		support: none
		license: none
		see-also: [ http://www.rebol.org/view-script.r?script=webserver.r   http://www.rebol.net/wiki/Port_Examples]
	]
]

web-dir: %.

server: open tcp://:8080

errors: [
	400 "Forbidden" "No permission to access:"
	404 "Not Found" "File was not found:"
]

send-error: func [ port err-num file /local err] [
	err: find errors err-num
	write port join "HTTP/1.1 " [
		err-num " " err/2 "^/Content-type: text/html^/^/"
		<HTML><TITLE> ERR/2 </TITLE>
		"<BODY><H1> SERVER ERROR </H1><P>REBOL Webserver Error:"
		err/3 " " file newline </P></BODY></HTML>
	]
	close port
]

send-page: func [ port data mime ] [
	insert data rejoin [ "HTTP/1.0 200 OK^/Content-type: " mime "^/Content-length: " length? data "^/^/" ]
	write port data
]
server/awake: func [ event /local port ] [
	if event/type = 'accept [
		port: first event/port
		port/awake: func [ event /local data dat] [
			probe event/type
			switch event/type [
				read [
					print [ "Client said:" ]
					request: to-string event/port/data
					file: "index.html"
					mime: "text/plain"
					parse request [ "GET" thru " " copy file to " "]
					parse file [thru "." [
                			"html" (mime: "text/html") |
                			"gif"  (mime: "image/gif") |
               				"jpg"  (mime: "image/jpeg") 
            			]
        			]
					print [ "debug:" web-dir/:file space mime]
					if not exists? to-file web-dir/:file [ send-error event/port 404 file return true ]
					if error? try [ data: read to-file web-dir/:file ] [ send-error event/port 400 file return true ]
					send-page event/port data mime
				]
				wrote [
					read event/port 
				]
				close [
					close event/port
					return true
				]
			]
			false
		]
		read port
	]
	false
]

wait [ server ]
close server
wait 2