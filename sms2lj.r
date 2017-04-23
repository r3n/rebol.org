REBOL [
  Library: [
     level: 'intermediate
     platform: 'all
     type: [function tool]
     domain: [text-processing text html http shell markup]
     tested-under: 'Rebol 1.2.1.3.1
     support: none
     license: none
     see-also: none
   ]

	Title:  "SMS2LJ"
	Date:   3-Aug-2004
	File:   %sms2lj.r
	Version: 1.0.0

	Author: "Premshree Pillai"
	Home:	"http://premshree.org/"
	Rights:  "Copyright (C) Premshree Pillai 2004"

	Purpose: {
		Post to your LiveJournal account by sending
		an SMS to your POP3 account ... using a service
		like Yahoo! Mail for SMS.
        }
]

comment [LiveJournal config]
LJ_USER: 	"*****"
LJ_PASSWORD: 	"*****"
JOURNAL: 	"*****"

comment [POP3 config]
POP3_HOST: 	"*****"
POP3_USER: 	"*****"
POP3_PASS: 	"*****"


postEvent: func [user password event subject journal] [
	date_time: probe parse to-string now {:}
	year: now/year
	month: now/month
	day: now/day
	hour: second probe parse first date_time {/}
	min: second date_time

	sms_post: rejoin [
		"mode=" "postevent"
		"&user=" user
		"&password=" password
		"&event=" event
		"&lineendings=" "pc"
		"&subject=" subject
		"&year=" year
		"&mon=" month
		"&day=" day
		"&hour=" hour
		"&min=" min
		"&usejournal=" journal
	]

	send_output: read/custom
	http://www.livejournal.com/interface/flat/ reduce [
		'POST sms_post
	]
]

getMails: func [host user password] [
	url: append append append append append "pop://" user ":" password "@" host
	print url
	inbox: open to-url url
	forall inbox [
		mail: import-email message: first inbox
		if equal? mail/subject "[none]" [
			body: probe parse mail/content none
			replace body newline " "
			postEvent LJ_USER LJ_PASSWORD body "" JOURNAL
		]
	]
	remove inbox
	clear inbox
	close inbox
]

forever [
	getMails POP3_HOST POP3_USER POP3_PASS
]