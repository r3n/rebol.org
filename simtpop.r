REBOL [
  Title: "SiMTPop Simulate SMTP & POP"
  Author: "Ingo Hohmann"
  date: 2003-10-03
  File: %simtpop.r
  purpose: {To simulate SMTP and POP services on a single user PC,
    works with Outlook 98, but is broken for later Versions}
  VersionInfo: {Incorporates a fix by Matt McDonald
    to work with later Versions of MS Outlook, and other programs
    who use EHLO}
  library: [
    level: 'intermediate
    platform: 'all
    type: [ tool]
    domain: [email dialects internet tcp]
    tested-under: [core view win linux]
    support: none
    license: none
 ]

]

smtp: open/no-wait tcp://:8025
pop3: open/no-wait tcp://:8110

trace/net on

line: none

get-data-rule: copy [
  (either not none? conn [
    append line copy conn
  ][
    get-or-end: copy end-rule
  ])
]

end-rule: [thru end]

smtp-rule: [
  (
    get-or-end: copy get-data-rule
    data-started: false
  )
  some [
    here:
    [
      "HELO" thru newline
                (answer "250 SiMTPop") |
      "EHLO" thru newline
	        (print "1" answer "250 SiMTPop") |
      "MAIL" thru newline
                (answer "250 Ok MAIL FROM") |
      "RCPT" [thru "<" | thru ": " ] copy name to "@" thru newline
                (answer "250 Ok RCPT TO") |
      "DATA" thru newline
                (if not data-started [answer "354 start mail input"] data-started: true)
           copy mail thru "^/.^/"
                (save-mail name mail
                 data-started: false
                 answer "250 OK Mail recieved") |
      "RSET" thru newline
                (answer "250 OK RSET" data-started: false) |
      "QUIT" thru newline
                (answer "221 Good Bye" close conn get-or-end: copy end-rule) |
      :here get-or-end
    ]
  ]
]

pop3-dialog: reduce [
  "USER"  func [a][
            parse a [thru "USER " copy name to newline to end]
            if not find mail-boxes name [
              append/only append mail-boxes name copy []
            ]
            answer "+OK User name accepted"
          ]
  "PASS"  func [a][answer "+OK Password Ok"]
  "STAT"  func [a /local ans len][
            len: 0
            ans: rejoin [
              "+OK " length? mail-texts: select mail-boxes name " "
            ]
            forall mail-texts [len: len + length? first mail-texts]
            append ans form len
            answer ans
          ]
  "LIST"  func [a /local ans][
            ans: rejoin [
              "+OK " length? mail-texts: select mail-boxes name " messages ("
            ]
            len: 0
            forall mail-texts [len: len + length? first mail-texts]
            mail-texts: head mail-texts
            append ans rejoin [ "" len ") octets" newline]
            forall mail-texts [
              append ans rejoin [index? mail-texts " " length? first mail-texts newline]
            ]
            append ans ".^/"
            answer ans
          ]
  "RETR"  func [a][
            parse a [thru "RETR " copy num to newline to end]
            num: to-integer num
            either num <= length? mail-boxes/:name [
              answer "+OK sending mail"
              answer pick select mail-boxes name num
            ] [
              answer "-ERR no such message"
            ]
          ]
  "DELE"  func [a][
            answer "+OK deleted"
          ]
  "RSET"  func [a][
            answer "+OK RSET"
          ]
  "NOOP"  func [a] [answer "+OK NOOP"]
  "QUIT"  func [a][
            answer "+OK bye"
            close conn
            done: true
            clear select mail-boxes name
          ]
]

mail-boxes: copy []

save-mail: func [name mail][
  either mail-box: find mail-boxes name [
    append mail-box/2 mail
  ] [
    append mail-boxes name
    append/only mail-boxes compose [(mail)]
  ]
]

answer: func [text][
  print ["-->" text]
  either (last text) = newline [
    insert conn text
  ][
    insert conn join text newline
  ]
]

recieve: func [/to end-marker /local line ret][
  if not to [ end-marker: "^/" ]
  line: copy ""
  until [
    data: copy conn
    append line data
    find line end-marker
  ]
  print ["<--" copy/part line (length? line) - 1]
  line
]

dispatch [
  smtp [
    print "+++ SMTP connection +++"
    conn: first smtp
    answer "220 SiMTPop Ready"
    wait [conn]
    line: copy ""
    parse line smtp-rule
  ] ; smtp

  pop3 [
    print "+++ POP3 connection +++"
    conn: first pop3
    answer "+OK POP3 server ready <SiMTPop>"
    wait [conn]
    done: false
    while [not done] [
      line: recieve
      command: copy/part line 4
      if error? try [
        pop3-dialog/:command line
      ][
        answer "-ERR command not implemented"
      ]
    ] ; while
  ] ; pop3
] ; dispatch
