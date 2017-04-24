REBOL[
    Title: "extract-web-links"
    Version: 1.2.1
    Date: 18-04-2005
    Author: "Peter WA Wood"
    Copyright: "Peter WA Wood"
    File: %extract-web-links.r
    Purpose: {A function which scans a string (normally a web page)
              and creates a block of URL/Text combinations for each
              HTML <a> tag in the string.}
    Usage: { example: extract-web-links read http://www.rebol.org }
    Library: [
        level: 'beginner
        type: 'function
        domain: [web html markup]
        platform: 'all
        tested-under: [ core 2.5.6.2.4 "Mac OS X 10.2.8"
                        core 2.5.6.3.1 "Windows XP Professional"
                        view 1.2.10.3.1 "Windows XP Professiona"]
        support: none
        license: cc-by 
	 {see http://www.rebol.org/cgi-bin/cgiwrap/rebol/license-help.r}
    ]
]

extract-web-links: func [
     {scans a string (normally a web page)
     and returns a block of URL (url!) / Text (string!) combinations for         
     each HTML <a> tag in the string}
    web-page [string!]
        "The string from which to extract web links"
    /only-urls
        "Only URLs are returned in the block"
    /only-descriptions
        "Only the supplied descriptions of the links are returned"
    /local
	    result-block
	        "Block for harvesting URLs and descriptions"
    	collected-url
            "Used to harvest individual URLs"
        collected-desc
            "Used to harvest individual descriptions"
        end-pos
            "end position of selection of web-page"
][

it: [                       ; the main processing of the function

    do initialisation

    until [                     ; end of web-page is reached
    
                                            ;Get the next URL in web-page
        web-page: find/tail web-page "<a"   ; Position after <a
                                            ; Find is case-insensitive 
                                            ;  by default.
                                            ; So this captures <A> taqs too
					
        if web-page [                       ; <a> tag found
            if (not only-descriptions) [    ; URLs requested
                do harvest-url              ; Harvest the URL

                either collected-url        ; Add any URL to result block
                
                   [append result-block to-URL collected-url]
                   
                   [break]                  ; skip to next url

             ]    
	
             if not only-urls [             ; Descriptions wanted ?
                 do harvest-desc	    
                 append result-block collected-desc
             ]                       
        ]  
  
        web-page = none	                    ; test for end of web-page
    ] ; end until

    return result-block

] ; end it


;;=======================================================================

initialisation: [
    result-block: make block! []            ; initialise result block

;   If both "only" refinements are set, turn them off.
;     Using both refinements has the same effect as using neither.
;     This allows the  remainder of the code to treat the refinements as 
;     being mutually exclusive.      

    if all [only-urls only-descriptions] [
        only-urls: none
        only-descriptions: none
    ]

] ; end intialisation

;;=======================================================================

harvest-url: [             ; section to harvest URL

    collected-url: copy ""

    web-page:  find/tail web-page "href="   ; move to char after href=
   
    either web-page [                       ; check href present

                        ; Find start of URl
                                            ; href may be full or relative URL 
                                            ; Skip opening quote if full URL

        if (first web-page) = #"^""
             [web-page: next web-page]

        end-pos: find web-page ">"          ; find end of <a> tag                                    
         
        either end-pos [                    ; end of <a> tag found
        
	        collected-url: copy/part web-page end-pos
            if (last collected-url) = #"^"" ; remove trailing quote
            
                [collected-url: head remove back tail collected-url]
                
        ][                  ; no closing > for <a> tag !!
            collected-url: none
        ]

    ][                      ; no href !!!
        collected-url: none  
    ]

] ; end harvest-url

;;======================================================================

harvest-desc: [	        ; section to harvest description 
    collected-desc: copy ""
    web-page: find web-page ">"         ; move to end of <a> tag
    if web-page [
        web-page: next web-page         ; move past >

        if find web-page "</a>" [       ; look for closing tag

            end-pos: find web-page "</a>"   ; set end-pos at <
            
						;check for img tag
            either find/part web-page "<img" end-pos [
                do harvest-image-desc
            ][                          ; text description
	        collected-desc: copy/part web-page end-pos
                do strip-embedded-tags
            ] 
        ]
    ]    

] ; end harvest-desc

;;========================================================================

harvest-image-desc: [                       
    collected-desc: copy "Image: "
    if find/part web-page "alt=^"" end-pos [    ; Alt attribute ?
        web-page: find/tail web-page "alt=^""
        if find web-page "^""                   ; Alt ends with "
            [append collected-desc copy/part web-page find web-page "^""]
    ]

] ; end harvest-image-desc

;;========================================================================

strip-embedded-tags: [         

;; strips embedded html tags from collected-desc
    
    while [ all [ (find collected-desc "<") (find collected-desc ">")]][
        collected-desc: find collected-desc "<"
        remove remove/part collected-desc find collected-desc ">" 
         
    ]

collected-desc: head collected-desc		;  set index at start

] ; strip-embedded-tags

;;========================================================================


do it				; execute the function code
 
] ; end extract-web-links

;; History
;; 
;; 1.1.0 23-Dec-2004    Initial release
;; 1.2.0 16-Jan-2004    Usage, copyright added to header
;; 1.2.1 19-Apr-2004    Tested under View 1.2.10.3.1
;;
;;
