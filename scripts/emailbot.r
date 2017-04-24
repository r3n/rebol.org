#!/usr/bin/rebol

REBOL [
    Title: "emailbot"
    File:  %emailbot.r
    Author: caffo
    Date:  17-Oct-2003
    Purpose: {
        A small prototype of a email robot. The program check
        a POP3 account for emails with a special subject, and
        reply with the result of the requested task.
    }
    Note: {
 	Put that on your crontab to ensure the daemon work.
    }
    Category: [email net 1] 

 library: [
        level: 'beginner 
        platform: 'all
        type: 'how-to
        domain: [web email other-net] 
        tested-under: 'linux / windoze
        support: none 
        license: none 
        see-also: none
    ]
]

 

page: read http://neoplastique.com/caffo/fortunes.pl  ;; get the fortune from web
inbox: open pop://username:password@mail.server.com  ;; open the mailbox

forall inbox [   
    mail: import-email first inbox  
	  
	  ;; check the mail subject for the specified command, and send the fortune
	  
	  if find mail/subject "send fortune" [	
			send first mail/from join "the fortune teller says..." [
				    newline  page  newline
				]
			
			print join  "sending the fortune to: " mail/from
			remove inbox
	    ]
	 
	
	;; if the command is 'send about', send a bunch of useless information
	
	  if find mail/subject "send about" [
			
			
			send first mail/from join "about akasha daemon services" [
				    newline  "Merry meet!" 
				    newline
				    newline  "Akasha is a mailbot daemon coded using a miraculous language called REBOL."  
				    newline
				]
			
			print join  "sending info to: " mail/from
			remove inbox
	    ]
	
	
	]
