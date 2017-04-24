REBOL[
	File: %form-error.r
	Date: 20-Dec-2006
	Title: {Trapping and displaying an error}
	Purpose: {Beginner's example for trapping errors.}
	Author: "Tim Johnson"
	email: tim@johnsons-web.com
	NOTE: {See comments for some code illustrations}
	Library: [
		level: 'Intermediate
		platform: 'all
		type: [Function how-to]
		domain: [debug testing]
		tested-under: "Linux, CGI"
		support: ["Tim Johnson" tim@johnsons-web.com]
		license: none
		see-also: none
		]
	]

form-error: func[{Compose a message representation of an error object} 
	error[error!] "The error" 
	markup[block! string! none!] 
	{Use to make more readable. markup 1 & 4 'wrap' the message.
     markup 2 & 3 for 'near and 'where attributes respectively.
     All four elements of 'markup are optional}
	/local arg1 arg2 arg3 message format
	][
	error: disarm error  ;; convert to object
	format: compose[(any[markup ["" "" "" ""]])]
	all[4 > length? format
		append format array/initial (4 - length? format) ""
		]
 	set [arg1 arg2 arg3][error/arg1 error/arg2 error/arg3]
 	message: get in get in system/error error/type error/id
 	if block? message[bind message 'arg1]
	message: reform reduce message
	if error/near [append message rejoin[format/2 " Near: " error/near]]
	if error/where [append message rejoin[format/3 " Where: " error/near]]
	rejoin[format/1 message format/4]
	]

;;; Explanations:
;;	1) If you do not fully understand the 'magic' of setting arg2 and arg3
;;     it would be useful to probe system/error. The 3 arguments are used
;;     to extract a human-readable message from the system/error object
;;     look for :arg1, :arg2, :arg3 etc.
;;  2) Although I was an experienced 'C' programmer when I started using rebol,
;;    thinking in 'C'-style imperative logic could be an obstacle.
;;    EXAMPLE: Convert a data-type - the C programmer might want to do the following:
;;    if not markup[format: ["" "" "" ""]] ;; put in default empty strings
;;    if string? markup[format: reduce[markup]] ;; convert 'markup to a block
;;    Thinking about this in more 'rebol-esque' terms, we actually use:
;;    format: compose[(any[markup ["" "" "" ""]])]  ;; combining the two 
;;    ;; lines above and using 'any instead of 'if
;;  3) If 'markup doesn't have the necessary 4 strings, the imperative approach
;;     would be something like this:
;;     if (length? markup) < 4[loop 4 - (length? markup)[append markup ""]]
;;     ;; filling in the block with empty strings, and reallocating memory in each
;;     ;; loop
;;    	all[4 > length? format
;;		append format array/initial (4 - length? format) ""
;;		]  ;; HINT: in your console, >> help all
;;         ;;                        >> help array

;; Usage: combine with the 'try construct, checking for an error. 
;; Example in comments. Think of a python
;; try:
;; except:
;; finally:
comment{
  either error? res: try[ ;; attempted code follows
  	do-some-code
	do-some-more-code
	1 / 0  ;; YIKES! Don't touch me there!
  	][ ;; 'res is an error and we catch it here
  	print "<h3>Error executing code. Explanation follows:</h3>"
  	print form-error res ["<h3>" "<br>&nbsp;&nbsp;" "<br>&nbsp;&nbsp;" "</h3>"]
  	][ ;; Finish up here. in python this would be the finally section
	finish-code
  	]
}
