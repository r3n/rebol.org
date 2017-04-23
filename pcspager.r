REBOL [
    Title: "Digital PCS Phone Pager"
    Date: 12-Jun-2000
    File: %pcspager.r
    Author: "Kevin McKinnon"
    Purpose: {
        Check e-mail account for messages, then process for
        paging to a Digital PCS phone. The processing includes
        chopping message/sender lengths and url-encoding. My
        cellular company wanted an extra $3/month just to give me
        an e-mail address that does what this script does.  (Can
        you believe that?  $3!) My PCS provider is Cantel AT&T in
        Canada.  You'll need to modify the script to work with
        your PCS carrier if you're not on Cantel.
    }
    Comment: {
        Bits of this script have been aquired and modified
        from the REBOL website and from code fragments posted
        to the REBOL User Mailing List.  Thanks to everyone
        who has contributed code! Logging directory per *nix
        standards. Tested under REBOL 2.0.4, and 2.1.0
    }
    Email: kev@insinc.ca
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'other-net 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

comment { Define constants for easy customization }
messagelength: 126
fromlength: 20
targetarea: 250
targetprefix: 442
targetnumber: 6111
pagerserver: tcp://sabre.cantelatt.com:80
pagerscript: "/cgi-bin/sendpcs.cgi"
eol: "^M^J"

comment { The url-encode function was appropriated from the REBOL website at
          www.rebol.com/library/urlencode.r   The original author was uncredited.
      The original code needed one change, the ^ needed to be escaped with another ^ }
url-encode: function [string] [punctuation encoding result f][
    punctuation: { !@#$%&()+=[]\{}|;':",/<>?`~^^}
    encoding: ["%20" "%21" "%40" "%23" "%24" "%25"
               "%26" "%28" "%29" "%2B" "%3D" "%5B" 
               "%5D" "%5C" "%7B" "%7D" "%7C" "%3B" 
               "%27" "%3A" "%22" "%2C" "%2F" "%3C" 
               "%3E" "%3F" "%60" "%7E" "%5E"
    ]
    result: copy ""
    foreach character string [
        insert tail result either f: find punctuation character 
               [pick encoding index? f]
               [character]
    ]
    return result
]

comment {Scan the mailbox and format each message for sending.}

mailbox: open pop://username:password@localhost

while [not tail? mailbox] [

  message: import-email first mailbox

  textmsg: copy message/content
  logmsg:  copy message/content
  while [ptr: find textmsg "^/"] [textmsg: insert (remove/part ptr (length? "^/")) " " ]
  textmsg: head textmsg
  textmsg: copy/part textmsg messagelength
  sender: copy/part message/from fromlength

  truelength: length? textmsg

  words: parse textmsg " "
  wordcount: length? words

  encodemessage: url-encode textmsg
  encodesender: url-encode make string! sender

comment {Log the entire message, just in case it gets lost in the transmission or
         someone doesn't know about the :messagelength limit on # of characters}
  logfile: open %/var/log/pcspager.log
  insert tail logfile join now [" " logmsg "^J"]
  close logfile

comment {Create the posting request.  I have to set the Referer (sic) field because
         Cantel uses this as a security feature to defeat attempts to post from other
         websites or scripts.}

  submit: join "" ["AREA_CODE=" targetarea "&PIN1=" targetprefix "&PIN2=" targetnumber
           "&emapnew--DESC--which=ORIG" "&SENDER=" encodesender
           "&PAGETEXT1=" encodemessage
           "&SIZEBOX=" truelength "&SIZEBOXW=" wordcount
           "&SUBMIT=Send+Message"]

  post: join "POST "[ pagerscript " HTTP/1.0" eol
             "Content-Type: application/x-www-form-urlencoded" eol
         "Referer: http://www.cantelatt.com/voice/amigo/message.html" eol
         "Content-Length: " length? submit eol
         eol
         submit eol
  ]

comment {Submit the message to Cantel's server}

  pcspage: open/binary pagerserver
  insert pcspage post

comment {If you want to retrieve the confirmation page, you need this bit from the REBOL
     mailing list.  Thanks Gabriele!}

  buffer: make string! 4096
  result: make string! 4096
  while [(read-io pcspage buffer 4096) <> 0] [
      append result buffer
      clear buffer
      wait pcspage
  ]

  close pcspage

comment { Uncomment this part if you want to log the returned code from
the webserver / DEBUG!}
  logfile: open %/var/log/pcspager.log
  insert tail logfile join result ["^J"]
  close logfile

  remove mailbox
]

close mailbox
