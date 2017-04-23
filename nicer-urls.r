This is my REBOL version of the php script from http://www.alistapart.com/articles/succeed/
.htaccess
RewriteEngine on
RewriteRule !\.(gif|jpg|png|css)$ /your_web_root/home/index.r

index.r
#!/path/to/rebol -c
REBOL [Title: "The index takes it all"
    File: %nicer-urls.r
    Date: 17-sep-2012
    Version: 0.1.0
    Author: "Arnold van Hofwegen"
    Purpose: {  This is my REBOL version of the php script 
                       from http://www.alistapart.com/articles/succeed/  }
    library: [
       level: 'intermediate
       platform: 'all
       type: [cgi demo]
       domain: [cgi internet]
       tested-under: none 
       support: none 
       license: none 
       see-also: "%nice-urls.r"
    ]
]

; Get some necessary information
docroot: get-env "DOCUMENT_ROOT"
requesteduri: get-env "REQUEST_URI"
scriptname: get-env "SCRIPT_FILENAME"

; Set some default values, fill in yours
defaultfile: "/rebol/index.html"
default404:  "/errors/not_found.html"

init-html-page: does [
    print "Content-type: text/html^/"
]

redirect-to: func [ redirect-url [ string! ] ] [
    print ["Location: " redirect-url] 
    print "^m^j"
    ; and quit the script
    quit
]

; 0. Perform some savety checks
if  100 < length? requesteduri [
    ; redirect to the sites 404 page and quit the script
    redirect-to default404
]

; Return 404 when ../ attempted or /.scriptname 
; or be kind and strip these and strip all double slashes too
replace/all requesteduri "/../" "/"
replace/all requesteduri "/." "/"
replace/all requesteduri "./" "/"
parse requesteduri [some [to "//" mark: (remove/part mark 2 mark: back insert mark "/") :mark ]]

; Strip html javascript tags
parse test [any [to "<" begin: thru ">" ending: (remove/part begin ending) :begin]]

; 1. check to see if a "real" file exists..
if  all [exists? to-file rejoin [docroot requesteduri]
         "/" <> requesteduri
         scriptname <> rejoin [docroot requesteduri]] [
    init-html-page
    print read to-file rejoin [docroot requesteduri]
    print ""
    quit
]

; 2. if not, go ahead and check for dynamic content.
keywords: parse requesteduri "/"
remove/part keywords 1 ; First one is empty because requesteduri starts with "/"

if  length? keywords [ ; request for the index
    init-html-page
    ; now print read the default index file or construct the page
    print read to-file rejoin [docroot defaultfile]
    print ""
    quit
]

; Look if anything in the Database matches the request 
; This is an empty prototype. Insert your solution here.
check-database: func [keys [block!]] [
    ; connect to database and do a search for the entries in the table
    do %/path/to/connectdb.r 
    open-db ; function from %connectdb.r
    insert db "SELECT * from KEYWORDS_TABLE" ; example remember?
    results: copy db
    ; either get content from a file or from the database itself
]

do-stuff: func [] [
    ; This is what it says it is
]

output-content: does [
    init-html-page
    print [<HTML><BODY>]
    print ["Data" <br/>]    
    print ["Document root: " docroot <br/>]    
    print ["Requested uri: " requesteduri <br/>]    
    print ["Script name  : " scriptname <br/>]    
    print [</BODY></HTML>]
    print ""
]

if  check-database keywords [
    do-stuff
    output-content
    quit
]

; 3. nothing in DB either  Error 404!
; redirect to the standard 404 page
redirect-to default404
; End of script
; quit is implicit