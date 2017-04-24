REBOL [
    Title: "Email Group Sender"
    Date: 10-Sep-1999
    File: %mailsendgroup.r
    Purpose: "A very simple way to send email to a group."
    Note: {
        The TRIM function below is used to remove the blank
        lines from the head of the email, so that the first
        line of text gets used as the subject.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: none 
        domain: [email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

friends: [luke@rebol.com jan@ban.dom fredericka@nab.dom]

send friends trim {

Hi there.

Just wanted to send you an email message from REBOL.

-Friend
}
