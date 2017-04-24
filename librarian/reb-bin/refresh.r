REBOL [
    Title: "REBOL Librarian refresh Module"
    Version: 0.0.0
    Date: 6-Jun-2004
    File: %refresh.r
    Author: "Sunanda / REBOL Library Team"
    Purpose: "Downloads new and updated scripts from REBOL.org."
    Category: [Util]
    ToDo: {
        - everything
    }
    History: [
        0.0.0 {Started -- Sunanda}
             ] ;; history
    ] ;;header


refresh: make object!
[



 do %prefs.r

		;;	define variables to make them
		;;	local to the refresh object
		;;

 lds-response: none
 script-list: none
 last-sync-point: none
 sync-list: none
 sync-status: none
 desktop-script: none

 refresh-panel: none
 panel-refresh-date: none
 panel-sync-status: none
 panel-messages: none
 panel-refresh-patch-button: none


;;	========================================

initialise-things: func [/local]
[
  script-list: read/lines join prefs/support-dir "scripts.lst"
  if error? try
	  	[last-sync-point: first reduce load read join prefs/support-dir "refresh-sync-point.txt"]
	  	[
	  	 last-sync-point: discover-sync-point
		]

 sync-status: last-sync-point/sync-status


;;	Attempt same colors as caller
;;	-----------------------------
if error? try [
		colors: reduce [(rebolor / 1.5) + (mint / 1.5) coal snow]
		append colors ((colors/1 / 2.5) + (colors/3 / 1.5))
		base-color: system/view/vid/vid-styles/face/color: colors/1
		]
		[colors: copy  [160.175.150 64.64.64 240.240.240 224.230.220]]

;;	------------------------------------
;;	Build appropriate panel depending on
;;	whether we have a proper refresh
;;	point or not
;;	------------------------------------

  refresh-panel: compose/deep
   [
   style lnk text with [font/colors: [(black) (blue)]]

    across h2 "Refresh Script Library"
    return h3 "Downloads new and changed scripts from the Library"
    return
    box 400x2 red
    return
    label 100 right "Last refresh date:"
    panel-refresh-date: field 85
    			[
    			 panel-sync-status/text: "Set by user"
    			 show panel-sync-status

    			]
    label 50 right "Status:"
    panel-sync-status: info (colors/4)
    return
    lnk  "Step 1: <Discover scripts>" bold
    					[refresh/discover-scripts]
    return
    lnk  "Step 2: <See changes>" bold
    					[refresh/view-changed-scripts]
    return
    lnk "Step 3: <Download and reindex changes>" bold
    					[refresh/download-scripts]
    return
    panel-messages: info 400x100 (colors/4) left font-color black
    return
		lnk  "<Help>" bold
							[refresh/browse-help]


   ]

 if desktop-needs-patching?
 	[
 	 append refresh-panel
 	 		  [panel-refresh-patch-button: lnk "<Patch Desktop Librarian>" bold
    					[refresh/patch-desktop]
    		]


 	]


 refresh-panel: layout refresh-panel


	;;	Display as own window, or as part of
	;;	Desktop application, depending on
	;;	whether Desktop is running or no


 panel-refresh-date/text: last-sync-point/timestamp
 show panel-refresh-date
 panel-sync-status/text: sync-status
 show panel-sync-status

	either error? try [out-box]
		[view/new refresh-panel
		 do-events
		]

   [out-box/pane: refresh-panel
    show out-box
   ]


] ;; func

;;	========================================

discover-sync-point: func [
											/local
											 sync-date

											]
[
	;;	--------------------------------------------------
	;;	We don't have a sync point record -- perhaps the
	;;	user downloaded the Library before refresh was
	;;	available.  Therefore we make an attempt at
	;;	discovering what it might be by checking the
	;;	file dates on all scripts in the Library.
	;;
	;;	This isn't guaranteed -- someone may have edited
	;;	a script. Or they may have the wrong
	;;	date in their machine...But it is a start.
	;;	--------------------------------------------------
 sync-date: 1-jan-2000
		;; well before the Library started
 foreach script script-list
 	[
 	 error? try [
 	  			sync-date: max sync-date modified? join prefs/script-dir next form script

 	  			]

 	]

 return make object!
 				 [
 				  timestamp: sync-date/date
 				  sync-status: "Tentative"


 				 ]

]

;;	========================================

 discover-scripts: func [/local

 												]
 [
  if error? try [lds]
   [
    set-message "Loading Library Data Services...."

    if error? try
      [
			 do http://www.rebol.org/library/public/lds-local.r
       ;;;;;;;;;;; do %/c/xitami/library/public/lds-local.r
      ]
    	[
    	 set-message "Can't load Library Data Services. Are we online?"
    	 return false

    	]

    set-message "Library Data Services loaded"

   ]

sync-list: none

 if error? try [panel-refresh-date/text: to-date panel-refresh-date/text]
 		[
 		 set-message "Please set a valid date in the last refresh date field, thanks"
 		 return false
 		]

 if 0 > (now/date - panel-refresh-date/text)
 		[
 		 set-message "Please use a past date in the last refresh date field, thanks"
 		 return false
 		]

  set-message "Discovering script changes..."

  if false = issue-lds-request "list-updated-scripts" reduce [1 + now/date - panel-refresh-date/text]
  		[return false]



 sync-list: sort lds-response/data/script-list

 if 0 = length? sync-list
 	[
 	   set-message "No changed scripts to download"
  	 return false
 	]

 set-message join "Changes to download: " length? sync-list
 return true

 ]

;;	========================================
download-scripts: func [/local
                        nn
                        saved-file
                        capture-error

 												]
 [


  if none? sync-list
  		[
  		 set-message {No files to download.  Did you click "Discover scripts" first?}
       return false
  		]
  for nn 1 length? sync-list 1
  	[
  	 set-message join nn ["/" length? sync-list " -- Downloading " sync-list/:nn]
     if false = issue-lds-request  "get-script" reduce [sync-list/:nn]
     		[return false]

     write join prefs/script-dir sync-list/:nn lds-response/data/script

     append script-list join "%" sync-list/:nn

  	]

  set-message "Reindexing: step 1 of 4 -- updating name index"

  script-list: sort unique script-list

  error? try [delete join prefs/support-dir "temp-scripts.lst"]

  foreach scr script-list
  	[
  	 write/lines/append join prefs/support-dir "temp-scripts.lst" scr
  	]

		delete join prefs/support-dir "scripts.lst"
		rename join prefs/support-dir "temp-scripts.lst" %scripts.lst



  set-message "Reindexing: step 2 of 4 -- updating header index"

  saved-file: none
  error? capture-error: try [saved-file: read join prefs/support-dir %header-index.rix]

  if error? try [do prefs/support-dir/make-header-idx.r]
  		[
  		 set-message join "Error rebuilding the header index:"
  		 								[
  		 								 newline
  		 								 mold disarm capture-error
  		 								]
  		 if not none? saved-file
  		 	[						;; restore original, if there was one
  		 	 write join prefs/support-dir %header-index.rix saved-file
  		 	]
  		 return false
  		]



  set-message "Reindexing: step 3 of 4 -- updating words index"

  saved-file: none
  error? capture-error: try [saved-file: read join prefs/support-dir %word-index.rix]

  if error? try [do prefs/support-dir/make-word-idx.r]
  		[
  		 set-message join "Error rebuilding the word index:"
  		 								[
  		 								 newline
  		 								 mold disarm capture-error
  		 								]
  		 if not none? saved-file
  		 	[						;; restore original, if there was one
  		 	 write join prefs/support-dir %word-index.rix saved-file
  		 	]
  		 return false
  		]

 saved-file: none				;; save some space

 do join prefs/support-dir %librarian-lib.r		;; reload to get new indexes

  set-message "Reindexing: step 4 of 4 -- saving refresh checkpoint file"
  last-sync-point/sync-status: "Actual"
  panel-refresh-date/text: now/date
  show panel-refresh-date
  last-sync-point/timestamp: panel-refresh-date/text
  write join prefs/support-dir %refresh-sync-point.txt mold last-sync-point

  panel-sync-status/text: "Actual"
  show panel-sync-status

  set-message "Download and reindexing is complete"

  return true
 ]

;;	========================================

view-changed-scripts: func [/local
														view-list

 												]
 [
  if none? sync-list
  		[
  		 set-message {No files to download.  Did you click "Discover scripts" first?}
       return false
  		]

 view-list: layout [text-list data sync-list]
 inform view-list

  return true
 ]

;;	========================================

patch-desktop: func [/local
                     patch-point
										]
 [

  if none? desktop-script
  		[set-message "Can't find librarian.r"
  		 return false
  		]

 if find desktop-script "do %refresh.r"
 			[
 		   set-message "Already patched"
 		   return false
 			]

  set-message "Saving unpatched as %unpatched-librarian.r"
  write %unpatched-librarian.r desktop-script

  patch-point: {lnk "Quit"     [quit]}

  replace desktop-script patch-point
  		join {
    				lnk "Refresh"
    					[do %refresh.r]
    					bullet
    			}
    			patch-point

  set-message "Saving patched version of %librarian.r"
  write %librarian.r desktop-script

  set-message "Librarian.r patched -- restart to see difference"

  return true
 ]


;;	========================================

 browse-help: func [/local
 										help-url
 									]
 [

 help-url: http://www.rebol.org/cgi-bin/cgiwrap/rebol/boiler.r?display=refresh-scripts-help.html
  if not error? try [browse help-url]
  			[return true]

 set-message join "Can't start browser in your version of REBOL...."
 								[newline
 								 "Please use this URL for help:"
 								 newline
 								 help-url
 								]
 return false


 ]




;;	========================================


 issue-lds-request: func [req [string!] parm [block!]]
 [

  lds-response: lds/send-server req parm

  if lds-response/status/1 = 0
  		[return true]

 set-message join "Sorry! LDS error: "
 									[form lds-response/status
 									 newline
 									 "Request: "
 									 	req
 									 newline
 									 "Parameters: "
 									 form parm
 									]
 return false

 ]

;;	========================================

 set-message: func [msg [string!]]
 [

  panel-messages/text: copy msg
  show panel-messages
  return true



 ]

;;	========================================

 desktop-needs-patching?: func []
 [
  if error? try [desktop-script: read %librarian.r]
  		[return false]

  either find desktop-script "do %refresh.r"
  			[return false]
  			[return true]
 ]




]  ;; refresh object


refresh/initialise-things
