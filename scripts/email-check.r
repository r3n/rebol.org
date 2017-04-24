Rebol [
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: 'email
        tested-under: 1.3.1.3.1
        support: none
        license: 'BSD
        see-also: {dig.r}
        ]

	title: "SMTP challenger"
	file: %email-check.r
	author: "Graham Chiu"
	rights: 'BSD
	date: 27-Nov-2005
	needs: {dig.r from the rebol.org library}
	purpose: {
		Issues an smtp challenge to see if recipient email address exists.
		Some mail servers will respond okay anyway to protect users from spammers.	
	}
]

do %dig.r

get-mx-ip: func [ 
	"Returns the ip address of the lowest MX record"
	nameserver [tuple!] domain [string!]
	/local ans result
][
	result: copy []
	ans: read to-url rejoin [ "dig://" nameserver "/MX/" domain ]
	foreach rec ans/answers [ 
	 	repend result [ rec/rdata/preference rec/rdata/exchange ]
	]
	; get the lowest preference for the MX record
	result: second sort/skip result 2
	foreach rec ans/additionals [
		if rec/name = result [
			return rec/rdata/ip
		]	
	]
	; return read join dns:// result
	result
]

emails: [ carl@rebol.com cyphre@rebol.com holger@rebol.com compkarori@gmail.com ]

name-server: 203.96.152.4 { use your own DNS server for this! }

foreach email emails [
	prin [ "Email: " email " " ]
	set-net reduce [ "<>" get-mx-ip name-server form find/tail email "@" ] 
	smtp-port: open [ scheme: 'smtp ]
	if error? try [
		insert smtp-port {MAIL FROM: <>}
		insert smtp-port rejoin [ {RCPT TO: <} email {>} ]
		print "OK"
	][
		print "Error"
	]
	attempt [ close smtp-port ]
]
 