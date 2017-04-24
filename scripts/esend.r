REBOL [
    Title: "esend - smtp client"
    Author: "RT, G. Scott Jones"
    Email: gjones05@m...
    Date: 21-Apr-2001
    File: %esend.r
    Version: 0.1.0
    Purpose: "A modified version of 'send for ESMTP"
    History: [
        0.1.0 [21-Apr-2001 "Modified RT 'send" "GSJ"]
    ]
    Comment: {The bulk of this code is simply a copy
  of Rebol Technolgies' code in /Core 2.5.0.3.1.
  The only changes I made are as follows.  I changed
  the name of the function in order to distinquish this
  version of 'send that uses an extended smtp scheme from
  the original.  The additional change is that 'esend uses
  'esmtp scheme, which is located in a separate file.  I
  chose to use separate function name and scheme inorder
  to avoid incompatibilty or confusion with Rebol
  Techologies' current or future implementations.  This
  version is known to work with Microsoft Exchange Server
  5.5, using base 64 encoded authentication.
  --Scott Jones (21-Apr-2001)
 }
    Usage: {Place this file in your REBOL directory, along with a
  copy of esmtp.r.  At either the interpreter prompt or the
  user.r file, type:
   do %esmtp.r ;separate file
   do %esend.r
  Then use 'esend as you would use 'send.  The first time
  the function is used, you will be prompted for the smtp
  authentication username and password.  These values are
  stored in clear text in the current REBOL session for
  later usage, but the values are not saved to disk for
  security reasons.
 }
    library: [
        level: none 
        platform: none 
        type: 'protocol 
        domain: [email protocol] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

esend: func [
 {Send a message to an address (or block of addresses)}
 address [email! block!] "An address or block of addresses"
 message "Text of message. First line is subject."
 /only "Send only one message to multiple addresses"
 /header "Supply your own custom header"
 header-obj [object!] "The header to use"
/local smtp-port content do-send
][
 do-send: func [port data] [
  foreach item reduce data [
   if string? item [replace/all item "^/." "^/.."]]
   insert port reduce data
 ]
 smtp-port: open [scheme: 'esmtp]
 if email? address [address: reduce [address]]
 message: content: either string? message [copy message] [mold message]
 if not header [
  header-obj: make system/standard/email [
   subject: copy/part message any [find message newline 50]
  ]
 ]
 if none? header-obj/from [
  if none? header-obj/from: system/user/email [net-error "Email header not set: no from address"]
 ]
 if none? header-obj/to [header-obj/to: make string! 20]
 if none? header-obj/date [header-obj/date: to-idate now]
 either only [
  do-send smtp-port ["MAIL FROM: <" header-obj/from ">"]
  foreach addr address [
   if email? addr [
    do-send smtp-port ["RCPT TO: <" addr ">"]
   ]
  ]
  insert insert message net-utils/export header-obj newline
  do-send smtp-port ["DATA" message]
 ][
  foreach addr address [
   if email? addr [
    do-send smtp-port ["MAIL FROM: <" header-obj/from ">"]
    do-send smtp-port ["RCPT TO: <" addr ">"]
    head insert clear header-obj/to addr
    remove/part message content
    content: insert message net-utils/export header-obj
    content: insert content newline
    do-send smtp-port ["DATA" message]
   ]
  ]
 ]
 close smtp-port
]

