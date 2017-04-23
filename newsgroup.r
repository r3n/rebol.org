REBOL [
    Title: "AIOE Newsgroup Test"
    Date: 08-Mar-2008
    Version: 1.0.0
    File: %newsgroup.r
    Author: "R.v.d.Zee"
    Owner: "R.v.d.Zee"
    Rights: "Copyright (C) R. v.d.Zee 2008 All Rights Reserved"

    Usage: {- script assumes an active Internet connection 
            - see Aioe.org usage policy}

    Purpose: {- an application of NNTP protocol
              - and an introduction AIOE.org}
        
    Notes:  {One of the oldest protocols NNTP is still has many uses, 
            for example: group discussions, bulletin boards and perhaps
            even as a disaster services bulletin board.

             This example script is very small, so it:
                 -  can be run on minimal equipment, 
                 -  is easily transmitted on limited bandwidth,
                 -  can be rapidly distributed,
                 -  needs no set-up or user training
                 -  and normally needs no changes to  routers or firewalls,
                    a feature not commonly enjoyed in current computer to
                    computer communication.
                    
             A local search from data downloaded at intervals would increase
             search times.

             The method used for reading posts differs slightly from the
             Network Protocols chapter of the REBOL Manual. 

             This script is provided "as is", without warranty of any kind,
             expressed or implied, including but not limited to the warranties
             of merchantability, fitness for a particular purpose and non
             infringement. In no event shall the author or copyright holder(s)
             be liable for any claim, damages or other liability, whether in
             an action of contract, tort or otherwise, arising from, out of or
             in connection with the software or the use or other dealings in
             this script.

             It seems there are very few true free public newsgroup servers.}   

    History:   [08-Mar-2008 "Posted To Library"]

    Library: [
        level: 'beginner
        platform: 'all
        type: [demo how-to]
        domain: [other-net testing]
        support: none
        tested-under: ["View 1.3.2.3.1 Windows"]
        license: none
    ]

]

;    transfer the script to it's own folder, if not already done

if all [
    not exists? %rebol-nntp/
    not exists? %../rebol-nntp/newsgroup.r
][
    make-dir %rebol-nntp/    
    write join %rebol-nntp/ last split-path script read script 
    delete script
    change-dir %rebol-nntp/
]

;    make-id provides a unique identification to the header of each post

make-id: does [
    rejoin [
        "<"
        checksum form now
        "$"
        random 999999
        "@"
        "nntp.aioe.org"
        ">"
    ]
]

;    The newsgroup is aioe.test, provided by AIOE for testing purposes.
;    New newsgroups can be established, read the AIOE site.

news-header: make object! [
    Path: "nntp.aioe.org!not-for-mail"
    From: rebol-test@test.com.au
    Subject: "A REBOL Script Test"
    Newsgroups: "aioe.test"
    Message-ID: make-id
    Organization: "Aioe.org NNTP Server"
    Date:  to-string rejoin [now/date "  " now/time]
]
;    change REBOL date & time formats for the news server
replace/all news-header/date "-" " "
send-time: to-string now/time

;    this function for the repetitive text display procedure

show-text: func [text] [
    reset-face reads
    reset-face scroll-reads     
    reads/text: text
    show reads
]

;    post-counter monitors the number of  posts in the last
;    24 hour time interval, posts are limited

post-counter: [
    either not exists? %posts-24hrs.txt [
        save %posts-24hrs.txt reduce [(now + 24:00:00) 0]
    ][
        posts-24hrs: load %posts-24hrs.txt
        ;    if now is outside the 24 hr time-frame then
        ;    make another 24 hr time-frame
        if now > first posts-24hrs [
            save %posts-24hrs.txt reduce [(now + 24:00:00) 0]
        ]
    ]
    posts-24hrs: load %posts-24hrs.txt
    posts-remaining: 25 - posts-24hrs/2

limits: rejoin [
        (25 - posts-24hrs/2) 
        " Posts Remaining In This 24 Hour Period Ending " 
        posts-24hrs/1/date " " posts-24hrs/1/time
    ] 
]
do post-counter


news: layout [
    size 600x480
    ;    backdrop effect made with the "Pattern Generator", see Viewtop/Rebol/Tools
    backdrop effect [
        gradient 0x1 255.255.255 190.190.190 draw [
            pen none 
            fill-pen conic 937x1094 0 246 288 7 2 40.100.130.179 0.48.0.145
            255.255.0.160 72.72.16.157 255.164.200.135 255.255.0.156
            240.240.240.157 255.205.40.143 192.192.192.142 240.240.240.183
            76.26.0.200 0.255.0.193 160.82.45.138 0.128.128.194
            255.205.40.154 128.0.0.136
            box 0x0 600x480
        ]
    ]
    origin 40x40
    across
    space 0
    return
    reads: info  450x250 166.175.195 166.175.195 font-color coffee wrap with [
        para/margin: 10x10 para/origin: 10x10
    ]
    scroll-reads: scroller 15x250 127.144.158 - 30 127.144.158 - 60 [
        scroll-para reads scroll-reads
    ]
    return
    pad 1x10
    writes: area 450x100 wrap 166.175.195  166.175.195 + 30 font-color coffee
    scroll-writes: scroller 15x100 127.144.158 - 30 127.144.158 - 60 15x100 [
        scroll-para writes scroll-writes
    ]
    return
    pad 0x4

    btn "AIOE Policy" snow - 30 [show-text info]
    btn "AIOE.ORG" snow - 30 [browse http://news.aioe.org]
    pad 4
    btn "Script" snow - 30 [show-text read %newsgroup.r]
    btn "Script - Comments" snow - 30[
        lines: read/lines %newsgroup.r
        no-comments: make string! (length? lines) * 400
        foreach line lines [
            if not find line ";   " [
                append no-comments join line "^/"
            ]
        ]
        show-text no-comments
    ]

    pad 36

    btn "Post" snow [
        write nntp://nntp.aioe.org rejoin [
            net-utils/export news-header
            newline newline
            writes/text
        ]
        posts-24hrs/2: posts-24hrs/2 + 1
        save %posts-24hrs.txt posts-24hrs
        do post-counter
        limit-counter/text: limits
        show limit-counter
        reset-face writes
        reset-face scroll-writes   
    ]

    btn "Read" snow [
        inbox: make block! 5
        reset-face reads
        reset-face scroll-reads
        reads/text: "Connecting To AIOE.ORG..."
        show reads
        group: open nntp://nntp.aioe.org/aioe.test
        ;    departing from the REBOL manual to establish the series
        establish: copy first group
        group: skip group (length? group) - 1
        count: 1
        ;    restrict the read to the last 10 posts, otherwise...long time!
        loop 10 [
            reads/text: rejoin ["Reading Message " count " Of Last 10 Messages"]
            show reads
            count: count + 1
            read-post: copy first group
            if (find form read-post "A REBOL Script Test") [
                append reads/text "^/ - Found A REBOL Message"
                show reads
                append inbox read-post
                wait 2
            ] 
            group: back group
        ]
        close group
        reads/text: {
            Last 10 Posts Reviewed
            AIOE.ORG Connection Closed
        }
        show reads
        wait 3
        either not empty? inbox [
            foreach post-in inbox [
                append reads/text rejoin [
                    newline 
                    "                                                     *************"
                    newline
                    newline
                    post-in
                ] 
            ]
            show reads
        ][
            alert "No REBOL Posts Were Found - Post A Message First!"
        ]
    ]
    
    btn "Quit" snow [quit]
    return
    pad 3x10

    limit-counter: h3 550 coffee font-size 10 limits
    pad 300
    at 430x450 image 219.200.202 50x12 logo.gif 
] 

info: {
                 Copied from Italy's Aioe.org website 4:25 PM 3/3/2008


Aioe.org is an open source based project which offers a public news server, a large dictionary, web forums and a 
mail server.

Aioe.org hosts a public news server, an USENET (NNTP) site that is intentionally kept open for all IP addresses 
without requiring any kind of authentication. This site is especially designed for those who wish a simple and 
quick way to read the USENET news without needing to post an huge amount of articles.

In order to keep low the number of abuses, there're various  limits to the users' access rights, notably in the 
number of articles per day that each IP address is authorized to post  (25) and in the amount of connections that 
each client is able to establish (600) in a day before being banned. All informations about the rules that the 
users are enforced to strictly observe are shown in the QuickStart Guide and in the Posting Policy that all people 
should read before starting to use this service.

In order to protect the users' privacy, each article sent through this host to every USENET group doesn't reveal 
the sender's IP address. However, this information is kept in the system logs for 6 months before being deleted as 
enforced by the Italian law. More informations about the log data retention are available in the Privacy Policy.

This site supports the SSL encrypted connections in order to increase the users' protection: all clients should 
enable it if their news agent supports this feature. Those who need help should read the section in the site that 
explain how to configure the most common newsreaders. A detailed list of all hosts and ports that are used by the 
servers is available in this  page. 


1. General Posting Rules

Each IP address --- whether it’s your client, or your whole network --- has the right to post no more than 25 
messages per day ; accepted and rejected messages are counted together. If an IP sends more than 5 articles that 
are rejected by the server, it looses the right to post for the next 24 hours. This server does not allow users to 
post multiple copies of the same message (idest multipost). Every article which is very similar to a previously 
post is rejected.


2. Stylistic rules

Each posted article must be smaller than 32KiB. Aioe.org does not carry binary groups so this limit is very 
reasonable for probably all text articles. Headers must be smaller than 2KiB ; large headers are useless and waste 
system resources. We strongly recommend our users to avoid the X-Faces header.

Articles which include a Content-type header which is not "text/plain" are refused, so HTML and multipart posts 
are forbidden. Those who need to sign their messages with a GPG/PGP key have to include the digital sign in the 
body of the article without adding a special multipart section.

Each body line of an article must be shorter than 160 characters. Quoted, blank and empty lines must be less than 
80% of total article. A quoted line begins with ">" or "|", a blank line contains only spaces an empty one 
includes only a single newline ("\n") character. The argument of the Date header must be correct. Often spammers 
send messages with a future date in order to become visible in the top of article list on clients which sort their 
groups by date; this implies that your system clock has to be properly configured.


3. Crosspost and followup

Articles can be posted to no more than 10 groups. There are weak reasons to post to more than 10 groups at once 
and this is often done by spammers, so I don’t allow. Articles that do not have a follow-up-to header cannot be 
posted to more than 3 groups. Articles that do have a follow-up-to header cannot have more than 3 groups in the 
follow-up-to header. This is usually a problem for trollers, not for you.


4. Flood

Every IP address that sends more than 5 rejected articles in a day loses the right to post for the next 24 hours. 
The ones who are accessing this server through a gateway may suffer from this limit; in this case, please send us 
a report.

Every IP may post up to 10 messages at every 10 minutes.  Both accepted and rejected posts are counted together 
and all exceeding articles are rejected.

In order to reduce the danger of being flooded by users, the server bans for a day any IP address which tries to 
open more than 12 connections every 10 seconds ; those who make use of some automatic news downloader should keep this barrier in mind.


5. Content-Related Rules

Our rules are simple :

    * No Spam. You may find useful information here about spam.
    * No Nazism. Minds, like parachutes, function better when open.
    * Likewise, racism, sexism and homophobia are not welcome.
    * Paedophilia is a crime. Do not spread this kind of content.
    * Respect netiquette.


6. Technical rules

In order to avoid abuses, there’re a few technical rules that the users need to respect :

* Control articles are forbidden because many people use them as an easy way to damage the server.
* Cancel articles are forbidden. If you think before you post, you don’t need to cancel. Sporadic accidents are 
   usually tolerated by people; no need to cancel.
* HTML articles of any sort are forbidden even if sent to groups that allow the users to post HTML articles; the 
   restriction is on this server.
* The ’From’ header must include a syntactically correct email address (user@domain.tld).  It’s not mandatory to 
   use a real name or email address.


Printable version
Last modify 2007-12-21 16:31:05}

reads/text: info
view news