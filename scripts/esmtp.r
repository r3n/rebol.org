REBOL [
    Title: "esmtp scheme"
    Author: "RT, G. Scott Jones"
    Email: gjones05@m...
    Date: 21-Apr-2001
    File: %esmtp.r
    Version: 0.1.0
    Purpose: "A modified, extended version of smtp scheme"
    History: [
        0.1.0 [21-Apr-2001 "Modified RT 'system/schemes/smtp" "GSJ"]
    ]
    Comment: {The bulk of this code is simply a copy
  of Rebol Technolgies' code in /Core 2.5.0.3.1.
  The only changes I made are as follows.  I changed the name
  of the scheme to 'esmtp, which was an arbitrary choice. I
  added additional check pairs in the open-check block to
  handle Microsoft's Exchange Server's SMTP authentication
  scheme. On first use, I added prompts requesting for the
  authenticating username and password.  These are stored in
  memory for current session only for subsequent use.  These
  are passed to smtp server using base 64 encoding. I chose
  to use separate function name and scheme inorder to avoid
  incompatibilty or confusion with Rebol Techologies' current
  or future implementations.  This version is known to work
  with Microsoft Exchange Server 5.5, using base 64 encoded
  authentication.
  --Scott Jones (21-Apr-2001)
 }
    Usage: {Place this file in your REBOL directory, along with a
  copy of esend.r.  At either the interpreter prompt or the
  user.r file, type:
   do %esmtp.r
   do %esend.r ;separate file
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

system/schemes: make system/schemes [
 ESMTP:
 make object! [
  scheme: 'ESMTP
  host: none
  port-id: 25
  user: none
  pass: none
  target: none
  path: none
  proxy:
  make object! [
   host: none
   port-id: none
   user: none
   pass: none
   type: none
   bypass: none
  ]
  access: none
  allow: none
  buffer-size: none
  limit: none
  handler:
  make object! [
   port-flags: 524288
;added additional pairs
   open-check: [none "220" ["EHLO" system/network/host] "250" "AUTH LOGIN"
"334" (enbase/base port/user 64) "334" (enbase/base port/pass 64) "235"]
   close-check: ["QUIT" "221"]
   write-check: [none "250"]
   init: func [
    "Parse URL and/or check the port spec object"
    port "Unopened port spec"
    spec {Argument passed to open or make (a URL or port-spec)}
    /local scheme
   ][
    if url? spec [net-utils/url-parser/parse-url port spec]
    scheme: port/scheme
    port/url: spec
    if none? port/host [
     net-error reform ["No network server for" scheme "is specified"]
    ]
    if none? port/port-id [
     net-error reform ["No port address for" scheme "is specified"]
    ]
   ]
   open: func [
    {Open the socket connection and confirm server response.}
    port "Initalized port spec"
    /locals sub-port data in-bypass find-bypass bp
   ][
    net-utils/net-log ["Opening tcp for" port/scheme]
    if not system/options/quiet [print ["connecting to:" port/host]]
    find-bypass: func [host bypass /local x] [
     if found? host [
      foreach item bypass [
       if all [x: find/match/any host item tail? x] [return true]
      ]
     ]
     false
    ]
    in-bypass: func [host bypass /local item x] [
     if any [none? bypass empty? bypass] [return false]
     if not tuple? load host [host: form system/words/read join dns:// host]
     either find-bypass host bypass [
      true
     ] [
      host: system/words/read join dns:// host
      find-bypass host bypass
     ]
    ]
    either all [port/proxy/host bp: not in-bypass port/host
port/proxy/bypass find [socks4 socks5 socks] port/proxy/type] [
     port/sub-port: net-utils/connect-proxy port 'connect
    ] [
     sub-port: system/words/open/lines [
      scheme: 'tcp
      host: either all [port/proxy/type = 'generic bp] [port/proxy/host]
[port/proxy/host: none port/host]
      user: port/user
      pass: port/pass
      port-id: either all [port/proxy/type = 'generic bp]
[port/proxy/port-id] [port/port-id]
     ]
     port/sub-port: sub-port
    ]
    port/sub-port/timeout: port/timeout
;added prompts to obtain authenticated username and password and store
    either user = none [
     user: port/user: ask "Enter SMTP authentication username: "
    ][
     port/user: user
    ]
    either pass = none [
     pass: port/pass: ask "Enter SMTP authentication password: "
    ][
     port/pass: pass
    ]
    port/sub-port/user: port/user
    port/sub-port/pass: port/pass
    port/sub-port/path: port/path
    port/sub-port/target: port/target
    net-utils/confirm/multiline port/sub-port open-check
    port/state/flags: port/state/flags or port-flags
   ]
   open-proto: func [
    {Open the socket connection and confirm server response.}
    port "Initalized port spec"
    /locals sub-port data in-bypass find-bypass bp
   ][
    net-utils/net-log ["Opening tcp for" port/scheme]
    if not system/options/quiet [print ["connecting to:" port/host]]
    find-bypass: func [host bypass /local x] [
     if found? host [
      foreach item bypass [
       if all [x: find/match/any host item tail? x] [return true]
      ]
     ]
     false
    ]
    in-bypass: func [host bypass /local item x] [
     if any [none? bypass empty? bypass] [return false]
     if not tuple? load host [host: form system/words/read join dns:// host]
     either find-bypass host bypass [
      true
     ] [
      host: system/words/read join dns:// host
      find-bypass host bypass
     ]
    ]
    either all [port/proxy/host bp: not in-bypass port/host
port/proxy/bypass find [socks4 socks5 socks] port/proxy/type] [
     port/sub-port: net-utils/connect-proxy port 'connect
    ] [
     sub-port: system/words/open/lines [
      scheme: 'tcp
      host: either all [port/proxy/type = 'generic bp] [port/proxy/host]
[port/proxy/host: none port/host]
      user: port/user
      pass: port/pass
      port-id: either all [port/proxy/type = 'generic bp]
[port/proxy/port-id] [port/port-id]
     ]
     port/sub-port: sub-port
    ]
    port/sub-port/timeout: port/timeout
    port/sub-port/user: port/user
    port/sub-port/pass: port/pass
    port/sub-port/path: port/path
    port/sub-port/target: port/target
    net-utils/confirm/multiline port/sub-port open-check
    port/state/flags: port/state/flags or port-flags
   ]
   close: func [
    {Quit server, confirm and close the socket connection}
    port "An open port spec"
   ][
    port: port/sub-port
    net-utils/confirm port close-check
    system/words/close port
   ]
   write: func [
    {Default write operation is a command, so check handshake.}
    port "An open port spec"
    data "Data to write"
    /local here
   ][
    port: port/sub-port
    either here: find/match data "DATA" [
     net-utils/confirm port data-check
     insert port here
     insert port "."
    ] [
     net-utils/net-log data
     insert port data
    ]
    net-utils/confirm port write-check
   ]
   read: func [
    port "An open port spec"
    data "A buffer to use for the read"
   ][
    net-utils/net-log ["low level read of " port/state/num "bytes"]
    read-io port/sub-port data port/state/num
   ]
   get-sub-port: func [
    port "An open port spec"
   ][
    port/sub-port
   ]
   awake: func [
    prot "An open port spec"
   ][
    none
   ]
   get-modes: func [
    port "An open port spec"
    modes "A mode block"
   ][
    system/words/get-modes port/sub-port modes
   ]
   set-modes: func [
    port "An open port spec"
    modes "A mode block"
   ][
    system/words/set-modes port/sub-port modes
   ]
   data-check: ["DATA" "354"]
  ]
  status: none
  size: none
  date: none
  url: none
  sub-port: none
  locals: none
  state: none
  timeout: none
  local-ip: none
  local-service: none
  remote-service: none
  last-remote-service: none
  direction: none
  key: none
  strength: none
  algorithm: none
  block-chaining: none
  init-vector: none
  padding: none
  async-modes: none
  remote-ip: none
  local-port: none
  remote-port: none
  backlog: none
  device: none
  speed: none
  data-bits: none
  parity: none
  stop-bits: none
  rts-cts: true
  user-data: none
  awake: none
  passive: none
  cache-size: 5
 ]
]
