REBOL [
    Title: "Telnet Chat"
    Date: 28-Jan-2002
    Version: 1.0.0
    File: %telnetchat.r
    Author: "Tommy Giessing Pedersen"
    Purpose: "A chat-server you can telnet to! ;o)"
    Email: nite_dk@bigfoot.com
    library: [
        level: 'intermediate 
        platform: 'all 
        type: [Demo Tool Tutorial] 
        domain: [ldc other-net tcp web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

listen: open/no-wait tcp://:23
print [ system/script/title "started" now ]
maxclients: make integer! ask "Capacity: "
browse telnet://localhost:23

nicklist: func [ /local c l ] [
  l: make block! [ ]
  foreach c clients [
    append l second c
  ]
  sort l
  return l
]

send: func [ s /local c l ] [
  foreach c clients [
    if not equal? none second c [
      l: add 3 length? second c
      l: add l length? third c
      append first c make char! 13
      append first c s
      if greater? l length? s [
        loop ( l - length? s ) [ append first c " " ]
      ]
      append first c rejoin [ newline second c ": " third c ]
    ]
  ]
]

lines: func [ /local c l ] [
  l: make block! nicklist
  append l 0
  print make char! 12
  while [ greater? length? l 1 ] [
    foreach c clients [
      if equal? first l second c [
        print rejoin [ second c "> " third c ]
        remove head l
      ]
    ]
  ]
]


clients: make block! [ ] lastlines: now/time
forever [
  if not-equal? none wait [ listen 0 ] [
    either greater? maxclients length? clients [
      client: make block! [ ]
      append client first listen
      append client none
      append client ""
      append/only clients client
      append first client "Nickname: "
      send join make char! 7 "Knock knock!"
    ] [
      port: first listen
      append port "This room is full! Go away!^/"
      close port
    ]
  ]
  if greater? length? clients 0 [
    client: make block! first clients
    remove head clients
    port: first client
    nick: second client
    line: make string! third client
    input: copy port
    if equal? none input [
      port: ""
      input: ""
      send rejoin [ nick " left!" ]
    ]
    foreach k input [
      either greater? 32 make integer! k [
        if equal? k make char! 9 [
          if equal? last line #" " [
            line: trim/tail line
            append port rejoin [ make char! 13 nick ": " line ]
          ]
          c: make string! " "
          d: error? try [ c: last parse line " " ]
          d: make block! [ ]
          foreach n nicklist [
            if not-equal? none n [
              if equal? c copy/part n length? c [ append d copy skip n length? c ]
            ]
          ]
          either equal? length? d 1 [
            append line first d
            append port first d
          ] [
            append port make char! 7
          ]
        ]
        if equal? k make char! 8 [
          if greater? length? line 0 [
            line: copy/part line ( -1 + length? line )
            append port rejoin [ k " " k ]
          ]
        ]
        if equal? k newline [
          if greater? length? line 0 [
            either equal? nick none [
              c: make integer! 1
              nick: copy trim line
              while [ found? find nicklist nick ] [ c: add c 1 nick: join trim line c ]
              send rejoin [ make char! 7 nick " entered!" ]
              line: make string! ""
              append port rejoin [ "^/Welcome " nick "!^/" ]
              d: "Present: "
              foreach c nicklist [
                if not-equal? none c [
                  append port rejoin [ d c ]
                  d: ", "
                ]
              ]
              append port newline
            ] [
              send rejoin [ nick ": " line ]
              line: make string! ""
            ]
            append port rejoin [ newline nick ": " ]
          ]
        ]
      ] [
        append line k
        append port k
      ]
    ]
    if not equal? port "" [
      client: make block! [ ]
      append client port
      append client nick
      append client line
      append/only clients client
    ]
    if all [
      not-equal? now/time lastlines
      not-equal? input ""
    ] [
      lines lastlines: now/time
    ]
  ]
]


                                                                                                                                                              