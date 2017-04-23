REBOL [
    Title: "Send Message to GSM Cellphone"
    Date: 16-Jun-2000
    File: %cellphone.r
    Author: "Graham Chiu"
    Usage: {
    just run this script after changing the placeholders below
    You have to register at www.mtnsms.com to use their service which is free.

    Then change the details of 
        myusername ( should be your email address )
        mypassword ( the one you gave MTN )
        myfavs ( eg. "Bloggs, Joe" - where this person appears in the drop
            down menu when you use a browser to access www.mtmsms.com/sms )
        mynumber ( telephone number eg. +642112345678 )
        mymsg ( The short text message of less than about 140 chars )

        You'll also have to change the hidden variable values of LenXSig to whatever yours
    turn out to be.  Just look at the source of the web page at their send message page.
    }
    Purpose: {
        To post a message via MTN's SMS gateway to a GSM phone
    }
    Email: gchiu@compkarori.co.nz
    Notes: "^/    Gotta write something here.^/    "
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'web 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
] 

do %cookies-client.r

tmp: http-post http://www.mtnsms.com/session.asp [ "returl" "/" "username" "myusername" "password" "mypassword" "logon" "  login   "  "akey" "yes" ]

; the session cookie is now sitting in cookie-data, and persistent cookie in tmp/set-cookie

parse tmp/set-cookie [ copy cookie-data2 to " "  ] ; copies tmp/set-cookie to cookie-data2 as req. by http-postc

tmp: http-post-cookie http://www.mtnsms.com/sms/sms.asp [  "favs" "myfavs" "msgTo" "mynumber" "msgText" "mymsg" "msgCL" "0" "msgSig" "0" "send" "  send   " "lenSSig" "7" "lenLSig" "12" "lenSysSig" "11"  ]

