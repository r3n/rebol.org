Rebol [title: "Mass mailer"
    version: 2.3.24
    author: "Massimiliano Vessi"
    date:  29/9/2009
    email: maxint@tiscali.it
     file: %massmailer.r
    Purpose: {"Mass emailng the world!"}
    ;following data are for www.rebol.org library
    ;you can find a lot of rebol script there
    library: [ 
        level: 'beginner 
        platform: 'all 
        type: [tutorial tool] 
        domain: [vid gui email ] 
        tested-under: [windows linux] 
        support: none 
        license: [gpl] 
        see-also: none 
        ] 
    ]

header-script: system/script/header

version: "Version: "

append version header-script/version

config: array 7
; the file %mass_mailer_conf.txt contains all configurations
; from 1-8 fields are settings
; 1 email adress from
; 2 smtp
; 3  user
; 4 password
; 5 email template file
; 6 email list
; 7 retard

;function to save all data in mass_mailer_conf.txt file
salvatutto: func [ config] [
	write %mass_mailer_conf.txt ""
	save  %mass_mailer_conf.txt	 config
	]
	
;check massmailer conf file existance
either exists? %mass_mailer_conf.txt [
    config:  load  %mass_mailer_conf.txt 
    ] [
    alert "You must set access data. Please fill in data in Settings panel."
    ritardo: 2
    ]


;Setting panel
configurazione_lay: layout [
    across
    title "Settings"
    return
    text "Your email:"
    email_fl: field  
    return
    text "SMTP server:"
    smtp_fl: field  
    return
    text "SMTP user:"
    smtpuser_fl: field
    return
    text "SMTP password:"
    smtppass_fl: field 
    return
    button "Save" [
        poke config 1  to-email email_fl/text    
        poke config 2  to-word smtp_fl/text
        poke config 3 to-string smtpuser_fl/text
        poke config 4  to-string smtppass_fl/text
	salvatutto config
        unview]
    button "Exit" [unview]  
    ]


;Help panel
aiuto_lay: layout [
    title "HELP"
    text 190 {This is a mass email, it permits to send any number of emails without problems. It will send an email each 2 seconds (or the time you choose). 
If you'll fill correctly settings panel, all will be alright. File loaded by Mass mailer must be in ASCII not in 
unicode. There is also a errors.log file with the last email sent, it's useful in case of interruption.
Now this software works with any email. If you have problems, please contact me:  }
text blue (rejoin ["maxint" "@" "tiscali.it"])
	]




;checking if the email list is  OK
controllo_emails: func [ lista] [
    lista_nera: copy []
    avvertire: false
    foreach indirizzo lista [
        temp2: length? parse indirizzo "@."
        if temp2 < 3 [  
            avvertire: true
            append lista_nera  indirizzo
            ]
        ]
    if avvertire = true [ alert reform ["The following addresses are NOT correct:" lista_nera ]]    
    ]






assemblaggio: func [ ] [
	;SET-NET is a function value.
	;ARGUMENTS:
	;settings -- [email-addr default-server pop-server proxy-server proxy-port-id proxy-type esmtp-user esmtp-pass] (Type: block)
	 set-net  reduce [ config/1  config/2  none none none none  config/3 config/4]
	;now we construct the header
	il_header: make object! [   
		X-REBOL: "View 2.7.8.3.1 http://WWW.REBOL.COM"
		Subject:  email/Subject
		From:   to-email config/1
		Return-Path: to-email config/1
		To: to-email config/1
		Date: to-idate now  ;we must set an correct RFC 822 standard format date or our emails will be identified as spam
		MIME-Version:  "1.0"
		Content-Type: email/Content-Type
		]
	]


leggi_email: func [ corpo_ind ] [
	a_lay/text: to-string corpo_ind
	show a_lay
	testo: read/string to-file corpo_ind
	email: import-email testo			
	led2/data: true
	show led2
	;probe email
	]


view layout [
	across
	title "Mass mailing"
	return
	btn-help [ view/new aiuto_lay]
	text  version
	return
	button "Settings" [
		email_fl/text: to-string config/1
		smtp_fl/text:  to-string config/2
		smtpuser_fl/text: to-string config/3
		smtppass_fl/text: to-string config/4
		show [email_fl  smtp_fl smtpuser_fl smtppass_fl ]
		view/new configurazione_lay
		]
	button "Reload last" [		
		b_lay/text: to-string config/6		
		ritardo/text: to-integer config/7
		db_mail2: read/lines to-file  config/6
		leggi_email config/5
		;debug
		;probe email		
		led3/data: true		
		show [ a_lay b_lay  led2  led3  ritardo]
		]
	return
		led2: led
	button "Email" [ 
		corpo_ind: request-file 
		either  (parse (to-string corpo_ind)  [thru ".eml" end]) [ leggi_email corpo_ind ] [ alert "It isn't a valid eml file!"]
		]

	a_lay: field "no text file loaded, html files are the best!"
	return
	led3: led
	button "Email list" [
		temp:  to-file request-file
		db_mail: read temp
		db_mail:  parse db_mail none
		sort db_mail 
		db_mail2: copy unique db_mail
		write/lines  temp db_mail2 ;scrive il file su hdd
		controllo_emails db_mail2
		b_lay/text: to-string temp
		show b_lay
		led3/data: true
		show led3
		]	
	b_lay: field "no email list file loaded"
	return    
	text "Retard:"
	button 22x22 "+" [temp: to-integer ritardo/text
		temp: temp + 1
		ritardo/text: to-string temp
		show ritardo
		]
	ritardo: field  40 "2"
	button 22x22 "-" [temp: to-integer ritardo/text
		temp: temp - 1
		if temp < 1 [temp: 1]
		ritardo/text: to-string temp
		show ritardo
		]
	return
	button red "MASS MAILING!" [
		counter: 0
		b: length? db_mail2
		a: confirm reform ["You are going to send" b "emails. I already deleted double entries. Do you want to proced?"]
		if a = true [
			;saving configurations
			poke config 5 to-file a_lay/text ; email file
			poke  config 6 to-file b_lay/text ; emails list
			poke  config 7 to-integer ritardo/text ; retard
			salvatutto config ;save configuration
			;sending emails
			foreach record db_mail2 [ 
				assemblaggio ;we now assemble the email
				il_header/To:  record
				counter: counter + 1
				sped_lay/text: reform ["Sending email n." counter]
				show sped_lay
				send/header     ( to-email record )    email/Content  il_header
				wait to-integer ritardo/text
				write %errors.log  reform ["Last sent email is: " record]
				]   
			alert reform ["Finished! You sent" counter "emails."]
			sped_lay/text: reform [ "Finished! You sent" counter "emails." ]
			show sped_lay           
			]
		]
	return
	sped_lay: text red "____________________________"
	]
