REBOL [
    Title: "Email Blaster"
    Date: 22-Jun-2000
    File: %blast.r
    Purpose: {Send an email to everyone on a spreadsheet of email addresses. Personalize the greeting for each. Keep a log of who was been sent the message.}
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'email 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

letter-file: %letter.txt
names-file: %names.txt
date-stamp: now

;-- Who the email is FROM:
from-email: who@domain.com

;-- Who the email should be replied to:
reply-email: who@domain.com

;-- Subject line of email:
subj: "Message title"

;-- Organization line of email:
org: "Your org"

;-- Read form letter:
letter: read letter-file

;-- Read Excel spreadsheet:  col1: email, col2: name
csv: read/lines names-file
targets: make block! length? csv
foreach line csv [append/only targets parse/all line ","]

;-- Verify data format:
foreach item targets [
    if not all [
        not error? try [item/1: load item/1]
        email? item/1
        string? item/2
    ][
        print ["Invalid target:" mold item]
        err-flag: true
    ]
]
if value? 'err-flag [halt]

;-- Create log file:
log-file: join %blast- [date-stamp/date "-" date-stamp/time/hour ".txt"]
print ["Log file is:" log-file]
write log-file reduce [date-stamp newline]

;-- Compose email header:
header: make system/standard/email [
    subject: subj
    from: from-email
    reply: reply-email
    Organization: org
    date: to-idate date-stamp
]

;-- Compose and send each letter:
foreach item targets [
    set [to-addr name] item
    contents: rejoin ["Dear " name ";" newline newline letter]
    send/header copy to-addr contents make header [to: to-addr]
    print [to-addr "sent"]
    write/append log-file reduce [to-addr newline]
]

halt





