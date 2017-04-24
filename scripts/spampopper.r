REBOL [
  Library: [
     level: 'beginner
     platform: 'all
     type: tool
     domain: email
     tested-under: Linux - Windows
     support: None
     license: GPL
     see-also: none
   ]

    Title: "SpamPopper"
    Date: 9-Sep-2004
    Name: 'SpamPopper
    Version: 1.0.0
    File: %spampopper.r
    Author: "Andrew Newton"
    Purpose: "Connects to POP3 Boxes - Deletes Messages Tagged as *****SPAM*****"
    Info: "Removes need to use Procmail or Qmail Scanner to delete spam tagged by Spamassassin"
    Info: "Address file is one mailbox per line in format user:pass@host.com"
    eMail: andrew@techanswers.co.uk
    Web: http://www.techanswers.co.uk
     
]
set '++ func ['word] [set word (get word) + 1]

accounts: read/lines %accounts.txt



curline: 1
foreach line accounts
[
    print pick accounts curline
    mailbox: open join pop:// [pick accounts curline]
    while [not tail? mailbox] 
    [
        msg: import-email first mailbox
	if find/match msg/subject "*****SPAM*****" 
	[
	    print msg/subject
	    print "^ Message Deleted"
	    print " " 
	    remove mailbox
        ]
        mailbox: next mailbox
     ]
     close mailbox
     ++ curline
]
