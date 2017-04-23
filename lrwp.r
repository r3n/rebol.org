REBOL [
    Title: "LRWP interface to Xitami"
    Date: 4-Oct-2001/13:01:29+2:00
    Version: 1.0.0
    File: %lrwp.r
    Author: "Maarten Koopmans"
    Purpose: {LRWP is a FastCGI like interface for Xitami. This implementation is provided by Robert Muench and Maarten Koopmans. Enjoy....}
    Email: m.koopmans2@chello.nl
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [cgi tcp web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


lrwp: context
[
  ;----------------
  ; Special values
  ;----------------
  xitami-endl: make char! 255

  ; Connection to Xitami web-server is unbuffered
  xitami-port: open/direct lrwp-agent-url
  set-modes xitami-port [ keep-alive: true ]
  
  hex-decode: func [val [string!]]
  [
    replace/all val "%40" "@"
    replace/all val "%20" " "
    return val
  ]
  
  register-peer: func [peer-name]
  [
    ; Build startup string
    xitami-startup: rejoin [peer-name xitami-endl xitami-endl ]

    ; Send startup string to the web-server
    print "Sending startup-string"
    insert xitami-port xitami-startup

    ; read answer
    reply: make string! 256
    read-io xitami-port reply 256

    ; and check if everything went OK
    either (length? reply) <> 2
    [
      print "Can't connect to Xitami Web-Server" halt
    ]
    [
      print rejoin ["Connected to " lrwp-agent-url]
    ]
  ]

  wait-for-action: has
  [ get-data reply size data variables post post-size nv-pair new-words ]
  [
  
    wait xitami-port

    
    ; Wait for web-server to give us something to do, read in the size (0 padded 9 digit number) 
    ; of the string Xitami is going to send us and convert it to an integer
    
    ;Initialize in case ther is no data
    new-words: copy []
    variables: copy []
    
    ; read-io xitami-port reply
    reply: copy/part xitami-port 9
    
    size: to-integer reply

    if size > 0
    [
      ; now read the environment information all at once and remove the seperators
      data: copy/part xitami-port size
      get-data: copy {}

      ; split the information, only extract the GET data (if any)
      parse/all data [ thru "QUERY_STRING=" copy get-data to "^@CGI_URL" ]     
      
      variables: copy parse/all get-data "&"
      
      ;Re-initialize for the if / foreach context!!! Bug?
      new-words: copy []
      
      ; and introduce a variable into Rebol script
      foreach variable variables
      [
        ; filter zero content
        if (length? variable) <> 0
        [
          ; parse name pair value and introduce a new variable
          nv-pair: copy parse variable "="
          append new-words to-set-word nv-pair/1 
          append new-words hex-decode nv-pair/2
        ]
      ] 
    
    ]

    ; Do we have post data? Again given as 0 padded 9 digit number
    clear reply
    reply: copy/part xitami-port 9
    post-size: to-integer reply

    if post-size > 0
    [
      post: copy/part xitami-port post-size
      variables: copy parse/all post "&"

      ;Re-initialize for the if / foreach context!!! Bug?
      new-words: copy []

      foreach variable variables
      [
        if (length? variable) <> 0
        [
          nv-pair: copy parse variable "="
          append new-words to-set-word nv-pair/1
          append new-words hex-decode either nv-pair/2 [ nv-pair/2] [copy {}]
        ]
      ]
      
    ]
    ;Put all data in an object, ctx-data
    return new-words
  ]

  padd-number: func [value]
  [
    text: to-string value

    insert/dup text "0" (9 - length? text)

    return text
  ]

  respond: func [text]
  [
    ; send an answer to the server
    write-io xitami-port padd-number length? text 9
    write-io xitami-port text length? text
  ]
]

;The sample:

;The Xitami lrwp agent url
;lrwp-agent-url: tcp://localhost:81
;Register the process for the app "sometest"
;lrwp/register-peer "sometest"
;Get the data
;cgi-data: lrwp/wait-for-action
;cgi-data now contains a block of values that you can use, posted or
;getted, you don't care
;for example make object! cgi-data

;print your result out using
;lrwp/respond my-content
                                                                                                                                                                