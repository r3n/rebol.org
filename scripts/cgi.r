REBOL [
   Title: "Rebol CGI library"
   File: %cgi.r
   Author: "Cal Dixon"
   Date: 2-Mar-2004
   Purpose: "Provide everything needed to create a CGI script"
   library: [
      level: 'advanced
      platform: 'all
      type: 'module
      domain: [cgi http web] 
      tested-under: none 
      support: none 
      license: 'MIT
      see-also: none
      ]
   ]

comment {
This script provides 15 functions (for more information run this script from the Rebol console and use 'HELP):
   ; these are very CGI specific
   process-cgi
   cgi
   all-cgi
   cookie
   set-cookies
   redirect

   ; these are frequently needed in CGI scripts but are not CGI specific
   cgi-escape
   html-escape
   onepx.gif
   binary-prin
   cgi-prin
   cgi-print

   ; these are generally useful and used internally in the other functions here
   rejoinif
   time-to-zone
   hex
}

use [buffer parts cgiobj cookieobj getobj postobj cookies cookies-buffer pc seg sep cdisp len][
cookies: copy [] postobj: copy [] parts: copy [] cgiobj: context []
process-cgi: func ["Processes HTTP Cookies, CGI GET and POST input - returns an object" /maxpostlength maxbytes][
   getobj: construct decode-cgi any [ system/options/cgi/query-string "" ]
   repeat cookie parse any [select system/options/cgi/other-headers "HTTP_COOKIE" ""] none [
	  pc: parse cookie "=" if all [ pc/1 pc/2 pc/1/1 pc/2/1 ] [ insert tail cookies reduce [ to-set-word pc/1 pc/2 ] ]
	  ]
   cookieobj: construct cookies
   if system/options/cgi/request-method = "POST" [
	  buffer: make string! 20 + len: to-integer system/options/cgi/content-length
      if all [maxbytes len > maxbytes][return context []]
      set-modes system/ports/input [lines: false]
	  while [ all [ len > length? buffer read-io system/ports/input buffer len ] ] [
         if all [ not empty? buffer len <> length? buffer not wait reduce [system/ports/input 30] ][quit]
         ]
	  postobj: construct either all [
		 sep: find/tail system/options/cgi/content-type "multipart/form-data;"
		 sep: find/tail sep "boundary="
		 ][
		 sep: rejoin [crlf "--" sep]
		 model: context [ content-disposition: name: filename: none content-type: "text/plain" ]
		 parse join crlf buffer [any [copy seg to sep (if seg [
			seg: parse-header model find seg complement charset crlf
			if all [seg/content-disposition cdisp: find/tail seg/content-disposition "form-data;"][
			   seg: make seg [
				  name: copy/part name: find/tail cdisp {name="} find name {"}
				  filename: if filename: find/tail cdisp {filename="} [
					 filename: copy/part filename find filename {"}
					 ]
				  ]
			   if not find seg/content-type "text/" [seg/content: to-binary seg/content]
			   either all [seg/filename not empty? seg/filename] [
				  seg/content: context [filename: seg/filename content-type: seg/content-type content: seg/content]
				  ][
				  if seg/content-type = "text/plain" [trim/head/tail seg/content]
				  ]
			   insert tail parts reduce [ to-set-word seg/name seg/content ]
			   ]
			]) sep]]
		 parts
		 ][
		 decode-cgi buffer
		 ]
	  ]
   return cgiobj: make cookieobj make getobj postobj
   ]
cgi: func ["Get a CGI variable that was read by process-cgi" var [any-string! any-word!] /cookie /get /post /local o][
   o: any [
      if get [ getobj ]
      if post [ postobj ]
      if cookie [ cookieobj ]
      cgiobj
      ]
   if var: in o to-word form var [ system/words/get :var ]
   ]
allcgi: func ["Returns a block of all CGI variables from process-cgi"][bind difference first cgiobj [self] in cgiobj 'self]

rejoinif: func [ "either :condition [ rejoin block ][ :default ]" condition [logic! none!] block [block!] default ][ either :condition [ rejoin block ][ :default ] ]

hex: func ["Returns a two character hexadecimal version of a number or character" c [char! string! integer!]][copy/part next next form to-binary to-char c 2]
cgi-escape: func ["Full URL escaping of a string" x [string!] /local echar nonechar s c][
   echar: complement nonechar: charset "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$-_.!*(),"
   parse/all x: to-string x [ any [ s: echar (c: s/1 remove s insert s join "%" hex c s: skip s 2) :s | nonechar ] ]
   x
   ]
html-escape: func ["Prepares a string for use in HTML forms" x [string!] /local echar nonechar s c t][
   nonechar: complement echar: charset {"<>^M^J}
   parse/all x: to-string x [ any [ s: echar (c: s/1 remove s insert s t: rejoin ["&#" to-integer c ";"] s: skip s length? t) :s | nonechar ] ]
   x
   ]
onepx.gif: func ["Returns a 1x1 transparent GIF file as a binary!"][#{4749463839610100010080000000000000000021F90401000000002C00000000010001004002024401003B}]

time-to-zone: func [ "Adjusts a time! to a different time zone" time [date! time!] zone [time!] /local a][a: (time - time/zone) + zone a/zone: zone a]
cookies-buffer: []
cookie: func [ "Sets or Unsets a Cookie - use set-cookies after all cookies have been set" name val /expires exp /path pth /kill ][
   if kill [ exp: now - 2 val: "." ]
   insert tail cookies-buffer rejoin [
      "Set-Cookie: " form :name "=" form :val
      rejoinif expires ["; expires=" to-idate time-to-zone exp 0:00 ] ""
      rejoinif ["; path=" pth ] ""
      newline
      ]
   ]
set-cookies: func ["Ouputs all cookie changes at once"][ if cookies-buffer/1 [cgi-print rejoin cookies-out] ]
redirect: func ["Does an HTTP redirect" url [url! string!] /quit ][ print [ "Location:" url ] if quit [system/words/quit]]
binary-prin: func [ "Outputs a value with no processing" data ] [ write-io system/ports/output data length? data ]
cgi-prin: func [ "Replacement for 'PRIN that always translates ^^/ to CRLF" out /local data ] [
   data: replace/all (reform out) newline "^M^J"
   write-io system/ports/output data length? data
   return
   ]
cgi-print: func ["Replacement for 'PRINT that always translates ^^/ to CRLF" out][
   data: head insert tail replace/all (reform out) newline "^M^J" "^M^J"
   write-io system/ports/output data length? data
   return
   ]
]

; The following is an example CGI script using this library
comment {
#!/usr/local/rebol/rebol -cs
REBOL [ file: %cgidemo.cgi ]

if error? e: try [
do %cgi.r
process-cgi

print "Content-type: text/html^/"

file: any [cgi 'filetest context [filename: none content-type: none content: ""]]

print rejoin [
{<HTML><HEAD><TITLE>CGI Demo</TITLE></HEAD><BODY>}
<h1> "CGI Demo Script" </h1>
<hr>
<pre> mold cgi 'gettest </pre>
<hr>
<form method="GET">
<input type="text" name="gettest">
<input type="submit">
</form>
<hr>
<pre> file/filename newline file/content-type newline length? file/content </pre>
<hr>
<form method="POST" enctype="multipart/form-data">
<input type="file" name="filetest" size="40">
<input type="submit" value="foo">
</form>
<hr>
<pre> mold cgi 'posttest </pre>
<hr>
<pre> mold cgi 'posttest2 </pre>
<hr>
<form method="POST">
<input type="text" name="posttest">
<textarea name="posttest2">
</textarea>
<input type="submit">
</form>
{</BODY></HTML>}
]
none
][
print "Content-type: text/plain^/"
probe mold disarm e
]
quit
}
