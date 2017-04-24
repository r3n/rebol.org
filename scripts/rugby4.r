REBOL [
    Title: "Rugby"
    Date: 15-Aug-2001/15:34:57+2:00
    Version: 4.0.2
    File: %rugby4.r
    Author: "Maarten Koopmans"
    Needs: "Command 2.0+ , Core 2.5+ , View 1.1+"
    Purpose: {A high-performance, handler based, server framework and a rebol request broker...}
    Comment: {Many thanx to Ernie van der Meer for code scrubbing.
            Added touchdown and view integration.
^-^-^-^-^-^-Fixed non-blocking I/O bug in serve and poll-for-result.
^-^-^-^-^-^-Added trim/all to handle large binaries in decompose-msg.
           -Added deferred and oneway refinements to sexec
           -Added automated stub generation and rugbys ervice import (thanks Ernie!)
           -Added /no-stubs refinement to serve and secure-serve
           -Added get-rugby-service function
           -Removed poll-for-result
           -Added get-result function
           -Added result-ready? function
           -Added get-secure-result function
           -Added secure-result-ready? function
    }
    Email: m.koopmans2@chello.nl
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [GUI tcp other-net ldc] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

hipe-serv: make object!
[
  ; The list of ports we wait/all for in our main loop
  port-q: copy []
  ; Mapping of ports to objects containg additional info
  object-q: copy []
  ; Our main server port
  server-port: none
  ; The handler for server [ currently only rugby, you can imagine http etc...]
  my-handler: none
  ; Restricted server list
  restricted-server: make block! 20
  ; Server restrictions?
  restrict: no

  restrict-to: func
  [
    {Sets server restrictions. The server will only serve to machines with
     the IP-addresses found in the list.}
    r [any-block!] {List of IP-addresses to serve.}
  ]
  [
    restrict: yes
    append restricted-server r
  ]

  allow?: func
  [
    {Checks if a connection to the specified IP-address is allowed.}
    ip [tuple!] {IP-address to check.}
  ]
  [
    return found? find restricted-server ip
  ]

  port-q-delete: func
  [
    {Removes a port from our port list.}
    target [port!]
  ]
  [
    remove find port-q target
  ]

  port-q-insert: func
  [
    {Inserts a port into our port list.}
    target [port!]
  ]
  [
    append port-q target
  ]

  object-q-insert: func
  [
    {Inserts a port and its corresponding object into the object queue.}
    target [port!]
    /local o
  ]
  [
    append object-q target
    o: make object!  [port: target handler: :my-handler user-data: none]
    append object-q o
  ]

  object-q-delete: func
  [
    {Removes a port and its corresponding object from the object queue.}
    target [port!]
  ]
  [
    remove remove find object-q target
  ]

  start: func
  [
    {Initializes everything for a client connection on application level.}
    conn [port!]
  ]
  [
    set-modes conn [ no-wait: true ]
    port-q-insert conn
    object-q-insert conn
  ]


    stop: func
  [
    {cleans up after a client connection.}
    conn [port!]
    /local conn-object
  ]
  [
    port-q-delete conn
    error? try
    [
      conn-object: select object-q conn
      close conn-object/port
      object-q-delete conn
    ]
  ]

  init-conn-port: func
  [
    {Initializes everything on network level.}
    conn [port!]
  ]
  [
    either restrict
    [
      either allow? conn/remote-ip
      [
        start conn
        return
      ]
      [
        close conn
        return
      ]
    ]
    ; No restrictions
    [
      start conn
      return
    ]
  ]

  init-server-port: func
  [
    {Initializes our main server port.}
    p [port!]
    conn-handler [any-function!]
  ]
  [
    server-port: p

    append port-q server-port

    ; Increase the backlog for this server. 15 should be possible (default
    ; is 5)
    server-port/backlog: 15
    my-handler: :conn-handler
    open/direct/no-wait server-port
  ]

  process-ports: func
  [
    {Processes all ports that have events.}
    portz [block!] {The port list}
    /local temp-obj
  ]
  [
    foreach item portz
    [
      either (item = server-port)
      [
        init-conn-port first server-port
      ]
      [
        if item/scheme = 'tcp
        [
          temp-obj: select object-q item
          temp-obj/handler temp-obj
        ]
      ]
    ]
  ]

  serve: func
  [
    {Starts serving. Does a blocking wait until there are events.}
    /local portz
  ]
  [
    forever
    [
      portz: wait/all port-q
      process-ports portz
    ]
  ]
]


; This object implements the server side of a request broker.
rugby-server: make hipe-serv
[
  ; Block containg words that are allowed to be executed.
  exec-env: none

  ; Block containing generated stub code.
  stubs: none

  build-stubs: func
  [
    {Builds stub code that allows remote invocation of exposed functions
     asif they were local to the client.}
    expose-list [block!] {List of functions to expose.}
    /insecure            {Use rexec instead of sexec for remote execution.}
    /with port [port!]   {Port the server is listening on.}
    /local stub code args header elem
  ]
  [
    ; Generate code to open the correct port.
    stub: copy [__rugby-server-address: make port! rejoin ]
    append/only stub reduce [ tcp:// system/network/host-address ":"
      either with [port/port-id ][8001]]

    ; Generate a local function that calls sexec/rexec.
    append stub [__local-rexec: func [statement [block!]]]
    append/only stub either insecure
      [ [ return rexec/with statement __rugby-server-address ] ]
      [ [ return sexec/with statement __rugby-server-address ] ]

    ; Generate the server stub.
    foreach elem expose-list
    [
      ; Get the function header, with documentation, but strip the
      ; refinements, since we don't support those (yet?).
      parse third get/any elem [ copy header to refinement! |
                                 copy header to end ]

      ; Get the function header, without documentation, and with
      ; refinements stripped.
      parse first get/any elem [ copy args to refinement! |
                                 copy args to end ]

      ; Make sure we don't have headers and/or arguments that are none.
      if none? header [ header: copy []]
      if none? args [ args: copy []]

      ; Compose the stub function with documentation.
      code: reduce [ to-set-word elem 'func header]
      append/only code compose/deep 
        [return __local-rexec reduce [ (to-lit-word elem) (args) ]]

      ; Add this function to the rest of the stubs. Remove stray
      ; newlines that may have come from the original header.
      append stub do trim/lines mold code
    ]
    return stub
  ]

  get-stubs: func []
  [
    return stubs
  ]

  nargs: func
  [
    {Gets the number of function arguments.}
    f [any-function!]
  ]
  [
    -1 + index? any [find first :f refinement! tail first :f]
  ]

  fill-0: func
  [
    {Zero-extends a string number.}
    filly [string!]
    how-many [integer!]
    /local fills
  ]
  [
    loop how-many - length? filly [ insert filly "0" ]
    return filly
  ]

  compose-msg: func
  [
    {Creates a message for on the wire transmission.}
    msg [any-block!]
  ]
  [
    f-msg: reduce [checksum/secure mold do mold msg msg]
    return mold compress mold f-msg
  ]

    clear-buffer: func [ cleary [port!] /local msg size-read]
    [
        msg: copy {}
        until
        [
            size-read: read-io cleary msg 1
            1 = size-read
        ]
    ]

  decompose-msg: func
  [
    {Extracts a message that has been transmitted on the wire.}
    msg [any-string!]
  ]
  [
    return do decompress do trim/all msg
  ]

  check-msg: func
  [
    {Check message integrity.}
    msg [any-block!]
  ]
  [
    return (checksum/secure mold second msg) = first msg
  ]

  write-msg: func
  [
   {Does a low-level write of a message.}
    msg
    dest [port!]
    /local length
  ]
  [
        set-modes dest [ no-delay: true]
    ; We try to write at least 16000 bytes at a time
    either 16000 > length? msg
    [
      length: write-io dest msg length? msg

      ; Message written, we're done
      either length = length? msg
      [
                return true
      ]
      ; We're not done. Return what we have written
      [
        return length
      ]
    ]; either 16000 > first clause
    [
      length: write-io dest msg 16000
    ]
    ; We're done, port is closed
    if 0 > length [ return true]

    return length
  ]

  safe-exec: func
  [
    {Safely executes a message. Checks the exec-env variable for a list of
     valid commands to execute.}
    statement [any-block!]
    env [any-block!]
    /local n stm err
  ]
  [
    if found? (find env first statement)
    [
      n: nargs get to-get-word first statement
      stm: copy/part statement (n + 1)
      return do stm
    ]
    make error! rejoin [ "Rugby server error: Unsupported function: "
        mold statement ]
  ]

  do-message: func
  [
    {High-level 'do' of a message.}
    msg [any-string!]
    /local f-msg size-read
  ]
  [
    f-msg: decompose-msg msg
    either check-msg f-msg
    [
      return safe-exec pick f-msg 2 exec-env
    ]
    [
      make error! rejoin [ "Rugby server error: Message integrity check"
          " failed: " pick f-msg 2 ]
    ]
  ]

  do-handler: func
  [
    {The rugby server-handler (my-handler in hipe-serv).}
    o
    /local msg ret size size-read result
  ]
  [
    ; This handler does its work in 3 parts
    ; 1) Read the message size
    ; 2) Read the message
    ; 3) do the message
    ; 4) Return the result
    ; 1) and 2) and 4) may be done inmultiple steps because of the saync I/O

    ; First, we expect 8 bytes and use user-data initially to store that
    if (none? o/user-data)
    [
      o/user-data:  copy {}
    ]; if

    ; If we are not an object we are initialized to a string
    if (not object? o/user-data  )
    [
      error? try
      [
        ; Read the first 8 bytes that contain the total message size
        ; message size =< 99.999.999
        size: copy {}

        ; size-read: length? msg: copy o/port
        msg: copy/part o/port (8 - (length? o/user-data))

        size-read: length? msg
        either (size-read = ( 8 - (length? o/user-data)))
        [
          ; What's the total size
          size: copy o/user-data
          append size copy/part msg (8 - (length? o/user-data))
          remove/part msg (8 - (length? o/user-data))

          if (0 < (length? msg)) [ size: (to-integer size) - length? msg ]

          ; And make an object of our user-data
          o/user-data: context
            [
              task: copy msg
              rest: to-integer size
              ret-val: copy {}
              msg-read: false
              ret-val-written: false
              task-completed: false
              header-written: false
              header-length: copy "0"
            ]; context
        ]
        [
          o/user-data: append o/user-data msg
        ]; either
        unset 'size
      ]; try
      return
    ]; if not object?

    ; Read the actual message
    if (not o/user-data/msg-read)
    [
      ; Now try to read the rest of the message
      if (error? try
          [ msg: copy {}
            size-read: length? msg: copy/part o/port o/user-data/rest
          ])
      [ return]

      if 0 = size-read [return]
      o/user-data/task: append o/user-data/task msg
      o/user-data/rest: (o/user-data/rest - size-read)
      if (o/user-data/rest = 0) [ o/user-data/msg-read: true  ]
      return
    ]

    ; Do our task and compose our return message
    if not o/user-data/task-completed
    [
      ret: copy []
      if error? set/any 'result try [ do-message o/user-data/task ]
      [
        result: disarm result
      ]

            ;Do we have a return value at all?
      if not unset? get/any 'result
            [
                append/only ret result
            ]

      o/user-data/ret-val: compose-msg ret
      o/user-data/header-length: fill-0 to-string length? o/user-data/ret-val 8
      o/user-data/task-completed: true
    ]

    ; Write out the header (length of what follows)
    if not o/user-data/header-written
    [
      wr-res: write-msg o/user-data/header-length o/port
      either logic? wr-res
      [
        o/user-data/header-written: true
      ]
      [
        remove/part o/user-data/header-length wr-res
      ]; either
      return
    ]

    ; Write out our return message in batches
    if not o/user-data/ret-val-written
    [
      wr-res: write-msg o/user-data/ret-val o/port
            o/user-data/ret-val

            either logic? wr-res
      [
        o/user-data/ret-val-written: true
                clear-buffer o/port
        stop o/port
      ]
      [
        remove/part o/user-data/ret-val wr-res
      ]; either
      return
    ]
  ]; do-handler

  init-rugby: func
  [
    {Inits our server according to our server port-spec and with rugby's
     do-handler}
    port-spec [port!]
    x-env [any-block!]
  ]
  [
    exec-env: copy x-env

    ; Build the stubs and store them in our object variable.
    stubs: build-stubs/insecure/with x-env port-spec

    init-server-port port-spec :do-handler
  ]

  go: func
  [
    {Start serving.}
  ]
  [
    serve
  ]
]

set 'get-stubs get in rugby-server 'get-stubs

serve: func
[
  {Exposes a set of commands as a remote service}
  commands  [block!] {The commands to expose}
  /with {Expose on a different port than tcp://:8001} p [port! url!] {Other port}
  /restrict {Restrict access to a block of ip numbers} r [block!] {ip numbers}
  /nostubs {Don't provide access to stubs with get-stubs function.}
  /local local-commands dest
]
[
  local-commands: copy commands

  ; We only add a function to get at the stubs if we are asked to.
  if not nostubs
  [
    append local-commands [ get-stubs ]
  ]

  if restrict [ rugby-server/restrict-to r ]

  either with
  [
    either url? p
    [ 
      dest: make port! p
    ]
    [
      dest: p
    ]
    rugby-server/init-rugby dest local-commands
  ]
  [
    rugby-server/init-rugby make port! tcp://:8001 local-commands
  ]
  rugby-server/serve
]


;*** RUGBY CLIENT ***

; Rugby's client side
rugby-client: make object!
[
  ; List of ports for deferred requests
  deferred-ports: copy []

  deferred-index: 0

  fill-0: func
  [
    {Zero-extends a string number.}
    filly [string!]
    how-many [integer!]
    /local fills
  ]
  [
    loop how-many - length? filly [ insert filly "0" ]
    return filly
  ]

  compose-msg: func
  [
    {Creates a message for on the wire transmission.}
    msg [any-block!]
  ]
  [
    f-msg: reduce [checksum/secure mold do mold msg msg]
    return mold compress mold f-msg
  ]

  decompose-msg: func
  [
    {Extracts a message that has been transmitted on the wire.}
    msg [any-string!]
  ]
  [
    return do decompress do trim/all msg
  ]

  check-msg: func
  [
    {Check message integrity.}
    msg [any-block!]
  ]
  [
    return (checksum/secure mold second msg) = first msg
  ]

  write-msg: func
  [
    {Writes a message on the port.}
    msg [any-block!]
    dest [port!]
    /local length f-msg
  ]
  [
    f-msg: compose-msg msg
    length: fill-0 to-string length? f-msg 8
    write-io dest length 8
    write-io dest f-msg length? f-msg
    ;the xtra byte to keep the server i/o engine running
    write-io dest length 1
  ]

  rexec: func
  [
    {Does a high-level rexec.}
    msg [any-block!]
    /with p [port! url!]
    /oneway
    /deferred
    /local res dest holder err
  ]
  [
    ;Is there a port specified? Otherwise defaultto localhost:8001
    dest: either with 
    [ 
      ;Do we have a url or port?
      either url? p 
      [ 
        make port! p
      ]
      [
        p
      ]
    ] 
    [ 
      make port! tcp://127.0.0.1:8001 
    ]

    ; Open the destination port.
    open/no-wait/direct dest

    ; Write the command to the port.
    write-msg msg dest

    ; Create a holder object for the pending request and append it to
    ; the deffered ports list.
    holder: make object!
    [
      port: dest
      data: copy {}
      length: none
    ]
    deferred-index: 1 + deferred-index
    append deferred-ports deferred-index
    append deferred-ports holder

        deferred-ports
    ; Are we required to wait for the result?
    if not any [oneway deferred]
    [
      return wait-for-result deferred-index
    ]

    ; Deferred requests must return the index of the holder object.
    if deferred [ return deferred-index ]

    return true;
  ]

  result-available?: func 
  [
    {Determines whether a deferred port has results available.}
    index [integer!] {Deferred port to check.}
    /local dport msg size-read
  ] 
  [
    dport: select deferred-ports index 
    if not object? dport 
    [
      make error! rejoin [ "Rugby client error: result-available:"
        " Failed to locate deferred port object" ]
    ] 

    ; Bluntly try to read some more data from the port, even though we
    ; may already have everything.
    msg: make string! 512 
    size-read: read-io dport/port msg 512 
    if size-read  >= 0
    [
      append dport/data msg
    ] 

    either 8 <= length? dport/data 
    [
      dport/length: 8 + to-integer copy/part dport/data 8
      length? dport/data

      ; Check if we have all the return data available.
      either all [dport/length dport/length <= length? dport/data] 
      [
        return true
      ]
      
      [
        return false
      ]
    ]
    [
      return false
    ]
  ] 

  get-result: func
  [
    {Closes the deferred port and returns any results that are present
     in the port. Be careful not to call this function unless you are
     sure that the port has data available, or you may end up with
     partial results! Use result-available? to make sure that data is
     present}
    index [integer!]
    /local msg dport
  ]
  [
    if not result-available? index [ make error! "Rugby error: No result available yet." ]
    dport: select deferred-ports index 
    if not object? dport 
    [
      make error! rejoin [ "Rugby client error: get-result:"
        " Failed to locate deferred port object" ]
    ] 
    close dport/port 
    msg: decompose-msg skip dport/data 8 
    remove/part find deferred-ports index 2 
    either check-msg msg 
    [
      return do pick msg 2
    ] 
    [
      make error! rejoin [ "Rugby client error: Return message"
        " integrity check failed on" mold pick msg 2]
    ]
  ]

  wait-for-result: func 
  [
    index [integer!]
  ] 
  [
    until [ result-available? index ]
    return get-result index
  ]
  
  get-rugby-service: func [ target [url! port!] /secure-code /local dest]
  [
    either url? target
    [
      dest: make port! target
    ]
    [
      dest: target
    ]

    either secure-code
    [
      return rexec/with [ get-secure-stubs ] dest
    ]
    [
      return rexec/with [ get-stubs ] dest 
    ]
  ]

];context

; Some wrappers in the global environment
; Feature suggestion by Allen Kamp
set 'rexec get in rugby-client 'rexec
set 'wait-for-result get in rugby-client 'wait-for-result
set 'result-available? get in rugby-client 'result-available?
set 'get-result get in rugby-client 'get-result
set 'get-rugby-service get in rugby-client 'get-rugby-service
;*** TOUCHDOWN SERVER ***


touchdown-server: make object!
[
  key: none

  init-key: does
  [
    if not key
    [
      if any [ not exists? %tdserv.key
           error? try [ key: do read %tdserv.key ] ]
      [
        ; We either don't have the key file, or there was an error
        ; reading it. Let's generate a new one.
        key: rsa-make-key key 
        rsa-generate-key key 512 3
        error? try [write %tdserv.key mold key ]
      ]
    ]
  ] 

  get-public-key: does [ return key/n]

  get-session-key: func [ s-key [binary!] /local k]
  [

    k: rsa-encrypt/decrypt/private key s-key
    return k
  ]


  decrypt: func [ msg [binary!] k [binary!] /local res dec-port crypt-str]
  [

      crypt-str: 8 * length? k
      dec-port: open make port! [

        scheme: 'crypt
        algorithm: 'blowfish
        direction: 'decrypt
        strength: crypt-str
        key: k
        padding: true
      ]
      insert dec-port msg
      update dec-port
      res: copy dec-port
      close dec-port
      return to-string res
  ]

  encrypt: func [ msg [binary! string!] k [binary!] /local res enc-port crypt-str]
  [
      crypt-str: 8 * length? k
      enc-port: open make port! [

        scheme: 'crypt
        algorithm: 'blowfish
        direction: 'encrypt
        strength: crypt-str
        key: k
        padding: true
      ]
      insert enc-port msg
      update enc-port
      res: copy enc-port
      close enc-port
      return res
  ]


  get-message: func [ msg [binary!] dec-key [binary!] /local crypto-port crypto-strength answ]
  [

    answ: decrypt msg dec-key
    return answ
  ]

  get-return-message: func [  enc-key [binary!] /with r /local blok msg]
  [
    blok: copy []
    ;Insert only if we have a value
    if with
    [
      append/only blok r
    ]
    msg: encrypt mold blok enc-key
    return msg
  ]

  sexec-srv: func [ stm [block!] /local str-stm stm-blk ret ]
  [
    stm-blk: do get-message do pick stm 2 get-session-key do pick stm 1
    set/any 'ret rugby-server/safe-exec stm-blk rugby-server/exec-env

    either value? 'ret
    [    return get-return-message/with get-session-key do pick stm 1 ret]
    [    return get-return-message get-session-key do pick stm 1 ]
  ]

];touchdown-server

negotiate: does
[
  return append append copy [] crypt-strength? touchdown-server/get-public-key
]

get-secure-stubs: does
[
  return secure-stubs
]

set 'sexec-srv get in touchdown-server 'sexec-srv

secure-serve: func
[
  {Start a secure server.}
  statements [block!]
  /with {On a specific port} p  {The port spec.}[port! url!]
  /restrict {Limit access to specific IP addresses} rs {Block of allowed IP addresses} [block!]
  /nostubs {Don't provide access to stubs with get-secure-stubs function.}
  /local s-stm
]
[
  touchdown-server/init-key

  ; Block containing generated secure stub code
  secure-stubs: none

  s-stm: append copy statements [ negotiate sexec-srv ]
  ;Build our function call

  if not nostubs
  [
    ; Build the secure version of the stubs.
    either with
    [
      dest: either url? p [ make port! p ] [ p ]
      secure-stubs: rugby-server/build-stubs/with s-stm dest
    ]
    [
      secure-stubs: rugby-server/build-stubs s-stm
    ]

    ; And add a function to access them.
    append s-stm [ get-secure-stubs ]
  ]

  ; Call serve with the right refinements.
  either nostubs
  [
    if all [with restrict] [ serve/nostubs/with/restrict s-stm p rs ]
    if with [ serve/nostubs/with s-stm p ]
    if restrict [ serve/nostubs/restrict s-stm rs ]
    serve/nostubs s-stm
  ]
  [
    if all [with restrict] [ serve/with/restrict s-stm p rs ]
    if with [ serve/with s-stm p ]
    if restrict [ serve/restrict s-stm rs ]
    serve s-stm
  ]
]








;*** TOUCHDOWN CLIENT ***


touchdown-client: make object!
[

  key-cache: copy []
  deferred-keys: copy []
  
  decrypt: func [ {Generic decryption function}
                  msg [binary!]
                  k [binary!]
                  /local res dec-port crypt-str
                ]
  [

      crypt-str: 8 * length? k
      dec-port: open make port! [

        scheme: 'crypt
        algorithm: 'blowfish
        direction: 'decrypt
        strength: crypt-str
        key: k
        padding: true
      ]
      insert dec-port msg
      update dec-port
      res: copy dec-port
      close dec-port
      return to-string res
  ]

  encrypt: func [
                  msg [binary! string!]
                  k [binary!]
                  /local res enc-port crypt-st
                ]
  [
      crypt-str: 8 * length? k
      enc-port: open make port! [

        scheme: 'crypt
        algorithm: 'blowfish
        direction: 'encrypt
        strength: crypt-str
        key: k
        padding: true
      ]
      insert enc-port msg
      update enc-port
      res: copy enc-port
      close enc-port
      return res
  ]

  negotiate: func 
  [  {Negotiates a session strengh and public rsa keyi with a touchdown server.}
    dest [port!] /local serv-strength
  ]
  [
    if not found? find key-cache mold dest
    [
      serv-strength: rexec/with [negotiate] dest
      serv-strength
      if not none? serv-strength
      [
        append key-cache mold dest
        append key-cache serv-strength
      ]
      return serv-strength
    ]
    return select key-cache mold serv-strength
  ]

  generate-session-key: func [ {Idem.} crypt-str [integer!]]
  [
    return copy/part checksum/secure mold now 16
  ]

  secure-result-available?: func [ {Checks if a deferred result is available}
    index [integer!]
  ]
  [
    result-available? index
  ]

  get-secure-result: func [
    {Returns a secured result}
    index [integer!]
    /local s-key ret
  ]
  [
    if not secure-result-available? index [ make error! "Touchdown error: secure result not available"]
    s-key: select deferred-keys index
    
    if none? s-key [ make error! "Touchdown error: no such index for sexec"]

    ret: get-result index

    either object? ret
    [
      remove remove find deferred-keys index
      return ret
    ]
    [
      set/any 'ret do get-return-message ret s-key
      remove remove find deferred-keys index
      return get/any 'ret      
    ]
  ]
  
  wait-for-secure-result: func [ {Waits for a secured result} index [integer!]]
  [
    until [secure-result-available? index]
    get-secure-result index
  ]
        
  generate-message: func [ stm [block!] s-key [binary!] r-key [object!] /local str-stm blk-stm crypt-port p-blk ]
  [
    blk-stm: copy [ sexec-srv ]
    p-blk: copy []

    append p-blk rsa-encrypt r-key s-key
    append p-blk encrypt mold stm s-key
    append/only blk-stm p-blk
    return blk-stm
  ]

  get-return-message: func [ stm  s-key [binary!] /local ret ]
  [
    set/any 'ret do  decrypt stm s-key
    return get/any 'ret
  ]



  sexec: func [ {A secure exec facility a la rexec for /Pro and /COmmand users}
                stm [any-block!] /with dest [port! url!] /oneway /deferred
                /local port sst crypt-str r-key ps-key g-stm ret s-key def-index
              ]
  [
    ;determine existing info
    either with
    [
      port: either url? dest [ make port! dest] [ dest ]
    ]
    [
      port: make port! tcp://localhost:8001
    ]
    sst: negotiate port
    if none? sst [return none]

    either (crypt-strength? = 'full)
    [
      either (first sst) = 'full
      [
        crypt-str: 128
      ]
      [
        crypt-str: 56
      ]
    ]
    [
      crypt-str: 56
    ]

    ;generate our session-key
    s-key: generate-session-key crypt-str

    ;get and initialize an rsa-key from the server's public key (second sst)
    ps-key: second sst
    r-key: rsa-make-key
    r-key/n: ps-key
    r-key/e: 3

    ;generate our sexec message
    g-stm: generate-message stm s-key r-key
    ;rexec our sexec message
    if oneway 
    [
      return rexec/with/oneway g-stm port
    ]

    def-index: rexec/with/deferred g-stm port

    append deferred-keys def-index
    append deferred-keys s-key
      
    either deferred
    [
      return def-index
    ]
    [
      return wait-for-secure-result def-index
    ]
  ];sexec

];touchdown-client


set 'sexec get in touchdown-client 'sexec
set 'secure-result-available? get in touchdown-client 'secure-result-available?
set 'wait-for-secure-result get in touchdown-client 'wait-for-secure-result
set 'get-secure-result get in touchdown-client 'get-secure-result


;A function that can be used in conjunction with rugby and view.
;View any layout be4 starting to serve
rugby-view: func [
    "Displays a window face. Does not start the event loop."
    view-face [object!]
    /new "Creates a new window and returns immediately"
    /offset xy [pair!] "Offset of window on screen"
    /options opts [block! word!] "Window options [no-title no-border resize]"
    /title text [string!] "Window bar title"
    /local scr-face
][
    scr-face: system/view/screen-face
    if find scr-face/pane view-face [return view-face]
    either any [new empty? scr-face/pane] [
        view-face/text: any [
            view-face/text
            all [system/script/header system/script/title]
            copy ""
        ]
        new: all [not new empty? scr-face/pane]
        append scr-face/pane view-face
    ] [change scr-face/pane view-face]
    if offset [view-face/offset: xy]
    if options [view-face/options: opts]
    if title [view-face/text: text]
    show scr-face
    view-face
]



;A sample server test function
;Start serving with "serve [echo]"
echo: func [ e [string!]] [return e]

; Client test function. Shows how easy it is to do a remote exec
client-test: does [ rexec [echo "Rugby is great!"] ]







