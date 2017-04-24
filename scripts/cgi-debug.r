REBOL [
    Title: "CGI wrapper function for debugging"
    Date: 12-jul-2003
    Version: 0.0.1
    File: %cgi-debug.r
    Author: "Sunanda"
    Purpose: "Provides debugging info for scripts running as a CGI under a webserver"
    library: [
        level: 'beginner
        platform: 'all
        type: [function tool]
        domain: [cgi web]
        tested-under: [win unix linux]
        support: none
        license: bsd
        see-also: none
    ]
]
   cgi-debug: func [target-code [block!]
        /silent
        /local
         cgi-debug-capture-error
         ip-address
   ][

;; == Usage:
;; ==   cgi-debug [block of code]
;;
;; == With a bit of luck, wrapping this round a
;; == block of code will return a html page with
;; == the error details, if it goes wrong.
;; ==
;; == That html may be appended to to html you've
;; == emitted prior to the failure, so it might
;; == look a mess.

   if error? cgi-debug-capture-error: try [do target-code 1]
     [
     if not silent
        [
        print "Content-type: text/html^/"
        print <br />
        print <hr />
        print "<h1>[system name] Error</h1>"

        print <p>
        print form now/precise
        print "<br />Sorry, we've had an unexpected error"

        print ["<br /> =====Error in script" system/options/script "=====  <br />"]
        print <br />
        print <hr />
        print [replace/all copy mold disarm cgi-debug-capture-error newline " "]
        print <br />
        print <hr />

            ]
ip-address: none
error? try [ip-address: to-tuple system/options/cgi/remote-addr]

      ;;    now attempt to write it to the log file:
      ;;    ----------------------------------------

    error? try [
        write/append/lines %cgi-debug.log
               join "cgi-debug error captured -- "
                   [now/precise
                    " ... "
                    replace/all copy mold disarm cgi-debug-capture-error newline " "
                    " ... "
                   "ip-address: " ip-address
     ]
        ] ;;try

    ;;  Now attempt to send an email report
    ;;  -----------------------------------

    error? try [
        if not 127.0.0.1 = to-tuple system/options/cgi/remote-addr
           [set-net  [--from-email-address-- --default-server--]
            send  to-email "--to-email address--"
                  join  "cgi-debug: error -- "
                        [newline
                          mold disarm cgi-debug-capture-error
                          newline
                          "ip-address: " ip-address
                        ]
           ] ;;if
       ] ;; error/try
 quit
 ] ;; if


] ;; cgi-debug function






