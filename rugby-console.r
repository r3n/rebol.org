REBOL [
    Title: "The rugby mobile code console"
    Date: 22-Aug-2001/14:14:44+2:00
    Version: 1.0.0
    File: %rugby-console.r
    Author: "maarten koopmans"
    Purpose: "A P2P console for Rebol/Rugby"
    Comment: {
  An example of a very simple console emulator that integrates with a rugby server.
  Original console emulator by Jeff Kreis on the mailing list.
  No fancy stuff such as auto-complete, arrows, or tabs (all throw errors).
  
  The console is started with the rugby server that exposes one function
  'do-block. This allows remote execution on a running console!

  You can add functions and remove functions with expose-function and hide-function.
  Exposed? gives a list of all currently exposed functions.
  restrict-to restricts acces to a given block of IP numbers
  no-restrict drops all restrictions.

  refresh-stubs regenerates the stubs that other clients can import. Don't forget to call
  this after expose-function o hide-function

  Type ? for any of these commands to get a more detailed overview.
}
    Email: m.koopmans2@chello.nl
    TODO: { - Add a real console emulator! Anyone???
          - Integrate with p2p presence provider on reboltech a la RIM, to provide a world wide console}
    library: [
        level: 'advanced 
        platform: 'all 
        type: 'Tool 
        domain: [ldc other-net tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

do read http://www.reboltech.com/library/scripts/rugby4.r

ctx-console: context
[

  cursor: func [parm [string!]][join "^(1B)[" parm]

  buf: copy ""
  con: open/binary/direct [
      scheme: 'console
      awake: func [port /local c r][
          prin c: to-char first port
          either find "^M^J" c [
              either error? set/any 'r try [ do buf ]
              [
                print mold disarm r  
              ]
              [
                if value? 'r
                [  print [newline "==" copy/part mold get/any 'r 20 " ... "]]
              ]
              prin ">> "
              clear buf
          ][
              ;-- basic editing
              either c = #"^h" [
                  prin [ cursor "P" ]
                  remove back tail buf
              ][append buf c]
          ]
          ;if find c "^[[B" [prin "curs detected"]
      ]
  ]
]
print ">> Press a key 4 the console. No history, tabs, or arrows implemented. "
print ">> Welcome to the P2P Rebol console, by m.koopmans2@chello.nl"
prin  ">> "

append system/ports/wait-list ctx-console/con


expose-function: func [{Expose a function as a service} w [word!]]
[
  append rugby-server/exec-env w
]

hide-function: func [ {Remove a service} w [word!]]
[
  until
  [
    either found? find rugby-server/exec-env w 
    [
      remove find rugby-server/exec-env w
      false
    ]
    [
      true
    ]
  ]  
]
   
exposed?: func [{Returns a list of exposed functions.}] [ return copy rugby-server/exec-env ]

set/any 'restrict-to get in rugby-server 'restrict-to

no-restrict: func [{Allow anyone to connect}] [ rugby-server/restrict: no ]

;Set the security settings!!!
secure  [net allow file [allow read ask write ask execute]]    

do-block: func [ b [block!] ] [ do b ]

refresh-stubs: func
[
  {Refreshes our stubs, used by other clients get-rugby-service}
  /with port-spec [url!] {The port we listening on, if different than tcp://:8001 (the default)}
  /secure
  /local dest
]
[
  either with
  [
    dest: make port! port-spec
  ]
  [ 
    dest: make port! tcp://:8001
  ]
  either secure
  [
    ; Build the stubs and store them in our object variable.
    rugby-server/stubs: rugby-server/build-stubs/with exposed? dest
  ]
  [
    ; Build the stubs and store them in our object variable.
    rugby-server/stubs: rugby-server/build-stubs/insecure/with exposed? dest
  ]
]

serve [do-block]







