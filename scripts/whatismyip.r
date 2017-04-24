REBOL [
    Title: "What is my IP"
    File: %whatismyip.r
    Author: "Endo"
    Date: 2010-12-13
    Version: 0.0.0
    Purpose: {Prints your IP address to Console}
    Library: [
        level: 'beginner
        platform: 'all
        type: [function one-liner]
        domain: [network]
        tested-under: [view 2.7.7.3.1 Windows XP] 
        support: none
        license: 'public-domain
        see-also: none
    ]
    Note: "deprecated"
]

;
; whatismyip.com web site removed free automation access.
; http://automation.whatismyip.com/n09230945.asp redirects to http://www.whatismyip.com/membership-options/
; You need to register to use the site. So this script is useless.
;

what-is-my-ip: does [write clipboard:// probe read http://automation.whatismyip.com/n09230945.asp]
