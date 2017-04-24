#!/usr/local/bin/rebol -cs

REBOL [
  Title: "Server object handler script"
  File: %server.r
  Author: [ "HY" ]
  Purpose: { This script will parse robot.txt files and store
             a hash! of forbidden paths. This is very useful for
             webbots or spiders of any kind (at least if obeying
             robot exclusion standards is desirable).

             I looked at the ht://dig package (http://www.htdig.org/)
             script that does the same thing as this script to see if I
             had overlooked something, and thereby fixed a few bugs.
           }
  Date: 16-Aug-2003
  Examples: {
     politebot: server "PoliteBot"
     politebot/add reduce ["www.netscape.com" read http://www.netscape.com/robots.txt
                   "www.google.com" read http://www.google.com/robots.txt ]
     print politebot/forbidden? http://www.google.com/search?q=rebol&ie=UTF-8&oe=UTF-8&hl=no
     print politebot/forbidden? http://www.netscape.com/
  }
  History: [
             19-Oct-2004 {Removed a bug that caused this path: /rebol/index.html
                          to be forbidden if robots.txt had Disallow: /i
                          I should do something about port numbers in URLs as well.}
             23-Sep-2004 {Added the library header}
             22-Apr-2004 {Removed a bug that modified an incoming variable
                          (from other scripts) directly.}
           ]
  Library: [
    level: 'intermediate
    domain: [parse http text-processing web]
    license: none
    Platform: 'all
    Tested-under: none
    Type: [module]
    Support: none
  ]
]

server-handler-object: context [

  ; 'context should automatically pick up set-words
  ; and bind them to the new local context, so:
  bot-name: ""
  patterns: make hash! copy []

  add: func [ block [block!] /local seen-my-name? pay-attention? my-patterns] [

    foreach [ host robots-file ] block [
      seen-my-name?: false
      pay-attention?: false
      my-patterns: copy []

      if none? robots-file [robots-file: ""]

      lines: parse/all robots-file "^/"

      forall lines [
        line: first lines
        if hash: find line "#" [ line: head remove/part find line "#" length? hash ]

        if all [0 < length? line #"#" = first line] [
          line: ""
        ]

        parsed: parse/all line ":"
        if not 0 = length? parsed [

          name: trim first parsed
          either 1 < length? parsed [
            rest: trim first next parsed
          ] [
            rest: ""
          ]


          if all [name = "user-agent"] [
            either all [rest = "*" not seen-my-name?] [
              pay-attention?: true
            ] [
              either rest = bot-name [
                either not seen-my-name? [
                  seen-my-name?: true
                  pay-attention?: true
                  clear my-patterns ; ignore previous messages for "*"
                ] [
                  pay-attention?: false ; only take first section with our name
                ]
              ] [
                pay-attention?: false ; none of our business
              ] ; end either rest = bot-name
            ] ; end either rest is * and not seen my name
          ] ; end name = user-agent

          if all [pay-attention? name = "disallow"] [
            if not 0 = length? rest [
              append my-patterns rest
            ]
          ] ; end pay attention and name is disallow

        ] ; end length? parsed not 0

      ] ; end forall lines

      append patterns reduce [host my-patterns]
    ]

  ] ; end add

  got-robots-file?: func [
                      "Tells whether or not we have the robots.txt file for a given host"
                      host [string!] "The hostname to look for"
                    ] [
    find patterns host
  ]

  forbidden?: func [
               "Tells whether or not a given URL is forbidden by the robots.txt file"
               in-url [object! string! url!]
               {The URL to check. This must be a complete URL. If this is an
               object, it is assumed to be a url-handler object
               (http://www.oops-as.no/roy/rebol-scripts/url-handler.r).
              }
                    ] [

    url: copy in-url ; don't modify incoming variable!

    if url? url [url: to-string url ]

    if string? url [

      if "" = url [return false] ; this might be just a bit too quick ...

      ; assume this is a complete url:
      url: url-handler url

    ]

    ; allowing objects, but assuming they are url-handler objects
    ; (http://www.rebol.org/cgi-bin/cgiwrap/rebol/view-script.r?color=yes&script=url-handler.r)
    path: find/match url/plain join url/protocol url/host

    pattern: select patterns url/host
    if none? pattern [return false] ; Maybe load robots.txt instead, to check for real?

    foreach p pattern [
      if found? find/part path p length? p [
        return true
      ]
    ]

    false

  ]

]

; shortcut:
server: func [
               "Shorthand for make server-handler-object [ bot-name: name ]"
               name [string!
               "The bot's name. This is the name that we will look for in the robots.txt files."]
             ] [

  return make server-handler-object [ bot-name: name ]

]

