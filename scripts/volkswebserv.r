REBOL [
   Title: "REBOL Web Server"
   File: %volkswebserv.r
   Author: "Cal Dixon"
   Email: zap@biglizard.kicks-ass.net
   Date: 23-Jan-2004
   Purpose: { A Simple HTTP-Server for running and debugging REBOL CGI scripts, modified %webserv.r }
   Note: {Name choosen because 1) i am Volker 2) its small, cheap, never crashes. like this vw-thing ;}
   Comment: {
      (c) 2000, 2001, 2002, 2003 Cal Dixon
      Requires Rebol/Core 2.5 or Rebol/View 1.0 or later
         By default the server will look for pages to serve in a folder called "www" in the
      current directory.  It will listen on port 80 and generate a log-file called
      "webserv.log".  Files with unrecognized types will be sent as "text/html".
      Settings can be changed by creating a configuration file called "webserv-cfg.r".
      EXAMPLE configuration file ---- cut here ---
         wwwpath: %./WWW/          ; change this to where the files are...
         port: 8080                ; change this to whatever port the server should listen to
         logfile: %webserv.log     ; the name of the logfile or set to none
         default-type: "application/octet-stream" ; Content-Type for unrecognized extensions
      --- cut here --- END of example file
      To make the server recognize additional content types, create a file called
      "content-types.r" and list pairs of extensions (without the dot) and content types.
      EXAMPLE content-type file ---- cut here ---
      "lha" "application/octet-stream"
      "png" "image/png"
      "mp3" "audio/mp3"
      "rar" "application/x-rar-compressed"
      "rtf" "application/rtf"
      "zip" "application/x-zip-compressed"
      --- cut here --- END of example file

      Files with an extension of ".r" or ".cgi" or in a folder called "cgi-bin/" will be treated
      as Rebol CGI scripts.  Output from CGI scripts was not buffered in versions before 0.0.0.12,
      but now is buffered before sending anything.
      Files with an extension of ".rhtml" are pre-proccesed by the server.  Anything enclosed
      in a pair of ":[" and "]:" will be executed as rebol code and the value of the expression
      will be inserted into the document at that location.

      To start the server:
         Place the %webserv.r script in a folder, start up rebol, change to the directory
         the script is in, then type "do %webserv.r".}
   Version: 0.0.0.15
   History: [ 
      0.0.0.3 {This version redirects all i/o to the web browser so 'read-io on 
               system/ports/input can be used to get POSTed data, etc.}
      0.0.0.4 {Now has better error checking and passes content-length as a string like it 
               should}
      0.0.0.5 "Can now send multiple files at once"
      0.0.0.6 {Now patches 'print and 'prin to work correctly and passes all http headers to           
               CGIs also translates access to a folder to %index.html in that folder.  Also  
               handles the HTTP HEAD method in addition to GET and sends the "Last-Modified"  
               header}
      0.0.0.7 {Added logging in Extended Common Log Format - but for CGI scripts the number of
               bytes sent is recorded as 1, due to current limitations of this program  }
      0.0.0.8 {Updated to work with Rebol/Core 2.5}
      0.0.0.9 {Added configuration file support, documentation, and .html preprocessing}
      0.0.0.10 {Misc. bugfixes}
      0.0.0.11 {Added simple path translation (for cgi-bin, etc.), and hack attempt logging}
      0.0.0.12 {Fixed various CGI bugs to allow this server to work with Vanilla.
                Added output buffering and support for CGI redirects using the "Location:" header.
                Files in cgi-bin are now treated as scripts automatically.
                Size of CGI output is now logged correctly.
                }
      0.0.0.13 {One more CGI bugfix to support Vanilla 0.6.}
      0.0.0.14 {Placed script into a context, now the only word added to the global context is 'webserv-ctx}
      0.0.0.15 {Improved CGI execution speed and fixed more incompatibilities with Vanilla.}
? {
Various changes by Volker.Nitsch@gmail.com (hopefully all marked with ";?")

Uses its own read-cgi. post works now, at least a few test-bytes.
--------------------------------------

webserv-port changed to 8039

small gui added. quit-button, alive-led. nicer for desktop-demos.

webserver-caching disabled for debugging (should be flag instead?)

'secure, 'protect-system disabled. else we could not rerun a cgi-script which uses them. 

'debug knows newlines

better tracing (should be optional, only for debugging):

- log is also written to console
- cgi-funcs show errors, and when they enter and leave.

}
      ]
   library: [
      level: 'advanced
      platform: 'all
      type: 'tool
      domain: [web cgi tcp] 
      tested-under: none 
      support: none 
      license: 'MIT
      see-also: none
      ]
   ]

;? 
; webserv.r needs read-cgi different:
; http://www.rebol.org/cgi-bin/cgiwrap/rebol/ml-display-thread.r?m=rmlDJDC

 read-cgi: func [/local data len] [
	either system/options/cgi/request-method = "POST" [
		set-modes system/ports/input [lines: false binary: true no-wait: false]
		len: to-integer system/options/cgi/content-length
		data: to-string copy/part system/ports/input len
	] [
		data: system/options/cgi/query-string
	]
	data
 ]

;? secure none ; removed. local folder is quite enough

secure: func[settings][] ; we cant extend security after cgi. sadly we have to disable security-changes
protect-system ; else the next rerun would protect the its own last functions 
unprotect [print prin quit halt protect-system] protect-system: none 

webserv-ctx: context [
file: request-method: Content: request: write-log: file-path: urlquery: responce: netmask: broadcast: dest-addr: none

wwwpath: %./www/          ; change this to where the files are...
port: 8039                  ; change this to whatever port the server should listen to
;?port: 80                  ; change this to whatever port the server should listen to
logfile: %webserv.log     ; the name of the logfile or set to none
default-type: "text/html" ; Content-Type for unrecognized extensions
max-queue: 3000           ; maximum simultaneous connections
server-name: read dns://

content-type-list: append reduce [
      "txt"   "text/plain"
      "gif"   "image/gif" 
      "jpg"   "image/jpeg" 
      "png"   "image/png" 
      "mov"   "video/quicktime" 
      "tif"   "image/tiff" 
      "tiff"  "image/tiff" 
      "wav"   "audio/wav" 
      "xml"   "text/xml" 
      "xsl"   "text/xml" 
      "mid"   "audio/midi"
      "html"  "text/html" 
      "rhtml" "rhtml"
      "r"     "text/plain"
      "rss"   "application/rss+xml"
      "wml"   "text/vnd.wap.wml"
      "cgi"   none
      ] either exists? %content-types.r [ load %content-types.r ] [ [] ]

custompaths: []
hackpaths: []
if exists? %webserv-cfg.r [ do bind load %webserv-cfg.r 'wwwpath ] ; FIXME

system/options/quiet: true
e: {<HTML><HEAD><TITLE>404 Not Found</TITLE></HEAD><BODY>Page not found.</BODY></HTML>}
cgi-obj: make system/options/cgi []
listen: open/lines/direct join tcp://: port
inport: system/ports/input
outport: system/ports/output
queue: []
cgiout: ""

debug: func [o /local][
   local: o
   if block? o [ o: reform o ]
   o: join mold o newline
replace/all o newline "^M^J" 
   write-io outport o length? o
   :local
   ]

; these replacements for 'print and 'prin should work better for CGI scripts
prin: func [ out /local data ] [
   data: replace/all (reform out) newline "^M^J"
;   append cgiout data
   write-io system/ports/output data length? data
   return
   ]

print: func [ out /local data ] [
   data: replace/all (reform out) newline "^M^J"
   data: append data "^M^J"
;   append cgiout data
   write-io system/ports/output data length? data
   return
   ]

quit: halt: func [] [throw]

www-send: func [ conn data ] [ write-io conn data length? data ]

either logfile [
   write-log: func [ entry ] [ write/append logfile join to-string entry newline debug entry append outport "^/"]
   ][
   write-log: func [ entry ] []
   ]

get-http-headers: func [ conn /local line buffer a b c ] [
   buffer: copy []
   while [ ((line: first conn) <> "") and not none? line ] [
      a: copy/part line b: find line ":"
      c: trim next b
      insert buffer reduce [ a c ]
      ]
   return buffer
   ]

lo: li: l: none
l: open/direct/binary tcp://:0
lo: open/direct/binary join tcp://localhost: l/local-port
insert lo local: to-binary random/secure checksum/secure form now
until [
   li: first l
   local = copy/part li length? local
   ]
close l
set-modes li [no-wait: true]
script-cache: copy []
handle-cgi: func [ conn request query headers /local cd s script globals] [
   headers: copy headers
   while [not tail? headers][
      change headers join "HTTP_" first headers
      headers: skip headers 2
      ]
   headers: head headers
   system/options/cgi: make cgi-obj compose [
      server-software: "REBOL Web Server"
      server-name: (server-name)
      gateway-interface: "CGI/1.1"
      server-protocol: "HTTP/1.0"
      server-port: "80"
      query-string: (any [query ""])
      request-method: (pick request 1)
      script-name: (first parse (pick request 2) "?")
      Content-Type: (select headers "HTTP_Content-Type")
      Content-Length: trim/head/tail (any [select headers "HTTP_Content-Length" ""])
      other-headers: (reduce [headers])
      ]
   s: system/options/script
   system/options/script: file-path
   cd: what-dir
   change-dir first split-path file-path
   system/ports/output: lo
   set-modes conn [no-wait: true]
   system/ports/input: conn
   clear cgiout
   globals: reduce bind [:print :prin :quit :halt] in system/words 'system
   set bind [print prin quit halt] in system/words 'system reduce [:print :prin :quit :halt]
;?
debug join "cgi: " file-path
   if error? local: try [
      if not script: select script-cache file-path [
         script: bind load file-path 'wwwpath
         ;? cache disabled for debug-reloading. TODO: make it optional
         ;?insert tail script-cache reduce [file-path script]
         ]
      catch [ do script ] none
;?
      ][debug disarm local] 
debug "cgi done."
   set bind [print prin quit halt] in system/words 'system globals


   cgiout: to-string copy li
   either find/part cgiout "Location:" 2000 [
      www-send conn "HTTP/1.0 303 See Other^M^J"
      ][
      www-send conn "HTTP/1.0 200 OK^M^J"
      ]
   www-send conn cgiout
   system/ports/input: inport
   system/ports/output: outport
   change-dir cd
   system/options/script: s
   close conn
   length? cgiout
   ]

track-hacker: func [ conn /local ip name data ] [
   ip: conn/remote-ip
   name: read join dns:// ip
   error? try [
      local: open/no-wait rejoin [tcp:// ip ":80"]
      insert local "GET / HTTP/1.0^/^/"
      wait reduce [local 3]
      data: copy local
      close local
      ]
   write/append %hack-attempts.txt reform [ ip name mold data newline ]
   ]

content-type?: func [ filename [string! file!] ] [
   first any [
      if find filename "cgi-bin/" [ reduce [none] ]
      select/skip content-type-list next find/last to-string filename "." 2
      reduce [ default-type ]
      ]
   ]

process-queue: func [ /local connection data file conn newqueue ] [
   newqueue: copy []
   foreach connection queue [
      set [ conn file ] connection
      data: copy/part file 2048
      file: skip file 2048
      write-io conn data length? data
      either tail? file [
         close conn
         ] [
         insert/only newqueue reduce [ conn file ]
         ]
      ]
   queue: newqueue
   ]

send-header: func [ conn result content-type data-length ] [
   www-send conn rejoin [ "HTTP/1.0 " result newline "Content-Type: " content-type newline
      "Content-Length: " data-length newline "Date: " to-idate now newline 
      "Last-Modified: " to-idate modified? file-path "^/^/" ]
   ]

path-parts: func [path /local r o p][
   r: to-file path
   o: copy []
   until [
      set [ r p ] split-path r
      if p [ insert o to string! p ]
      any [ r = %./ r = %/ r = "" ]
      ]
   insert o to string! r
   o
   ]

translate-request-to-resource: func [ file /local file-path saferoot ] [
   saferoot: clean-path wwwpath
   if find file "://" [ return clean-path join saferoot "index.html" ] ; Proxy attempt
   if (last file) = #"/" [ append file "index.html" ]
   foreach [pathrule rewrite] custompaths [
      if local: find/match path-parts file path-parts pathrule [
         if not exists? local: join rewrite rejoin local [ local: %"" ]
         saferoot: clean-path rewrite
         file: none
         ]
      ]
   file-path: clean-path either file [join wwwpath to-file next file][local]
   if none? find file-path clean-path saferoot [
      file-path: clean-path join saferoot "index.html"
      ]
   if dir? file-path [ append file-path "/index.html" ]
   return file-path
   ]

http-log: func [ host request status bytes /extended headers /local when agent referer] [
   when: rejoin [ replace/all copy/part mold now 11 "-" "/" replace skip mold now 11 "/" ":" ]
   replace when "-" " -"
   either (agent: select headers "User-Agent") [
      agent: join {"} [ agent {"} ]
      ][
      agent: "-"
      ]
   either (referer: select headers "Referer") [
     referer: join {"} [ referer {"} ]
     ][
     referer: "-"
     ]
   reform [
      host
      "- -" 
      rejoin [ "[" when "]" ] 
      mold form request
      status
      bytes
      either extended [
         reform [ referer agent ]
         ][ "" ]
      ]
   ]

rhtml: func [ text /local p out pos s p1 p2] [
   p: [ (out: copy "" pos: 1) s:
      any [
         thru ":[" p1: copy code to "]:"
         p2: (
            repend out [(copy/part at s pos ((index? p1) - 2 - pos) )(do code)]
            pos: 2 + index? p2
            )
         ]
      to end (append out at s pos)
      ]
   return either error? try [ parse text p ] [ text ] [ out ]
   ]

handle-new-connections: func [ /local data conn http-headers] [
   if none? wait reduce [ listen 0 ] [ return ]
   if error? try [ request: parse first (conn: first listen) none ] [ close conn return ]
   if (length? queue) > max-queue [
      insert conn "HTTP/1.0 503 Server Overloaded^/"
      close conn return
      ] ; refuse connections if server is overloaded
   if error? try [
   request-method: pick request 1
   repeat thispath hackpaths [ if find pick request 2 thispath [ track-hacker conn make error! "HACK" ] ]
   set [ file urlquery ] parse (pick request 2) "?"
   if not string? file [ close conn return ]
   file-path: translate-request-to-resource file
   if error? try [ http-headers: get-http-headers conn ] [ close conn return ]
   either exists? file-path [
      either none? content: content-type? file-path [
         write-log http-log/extended conn/host request 200 handle-cgi conn request urlquery http-headers http-headers
         return
         ] [
         write-log http-log/extended conn/host request 200 size? file-path http-headers
         set [ responce data ] reduce [ "200 OK" (data: read/binary file-path) ]
         ]
      ] [
      write-log http-log/extended conn/host request 404 0 http-headers
      set [ responce content data file-path ] reduce [ "404 Not Found" "text/html" e %. ]
      ]
   if content = "rhtml" [
      content: "text/html"
      data: rhtml data
      ]
   send-header conn responce content length? data
   if request-method = "HEAD" [ close conn return ]
   insert/only queue reduce [ conn data ]
   ][ error? try [close conn] ]
   ]

start-server: does [
   forever [
      if ( zero? ( length? queue ) ) [ wait listen ]
      handle-new-connections
      process-queue
      ]
   ]
]

;?
unless system/script/args [
; make some default-files
foreach [file data][
 %www/index.html {<html><body>Volkswebserv running<p><a href="cgi-bin/testme.cgi">Test cgi</a></body><html>}
 %www/index.r {rebol[title: 'index]^/link %index.html]}
 %www/cgi-bin/testme.cgi {rebol[] print [{Content-type: text/plain^/^/Its now} now/time]}
][
 if not exists? file[
  make-dir/deep first split-path file
  write file data
 ]
]
; run gui
view/new layout[
 title "Webserver running"
 led rate 1 yellow gray
 button "Quit" [quit]
 button "Browse" [browse join http://localhost: webserv-ctx/port]
 button "Explore" [browse join what-dir %www/]
]
webserv-ctx/start-server
]

