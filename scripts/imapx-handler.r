REBOL [
   Title: "IMAP Handler"
   Author: ["RT & Ingo Hohmann"]
   Purpose: {Add some RFC3501 (full imap) behaviour to the imap scheme.}
   File: %imapx-handler.r
   Version: 0.0.2
   Date: 2006-03-03
    library: [
        level: 'intermediate
        platform: 'all
        type: [protocol]
        domain: [email]
        tested-under: [REBOL/View 1.3.2.3.1 5-Dec-2005 Core 2.6.3 WinXP ]
        support: none
        license: 'bsd
        see-also: none
    ]
   
   Known-Bugs: [
      {I am not able to name the correct license in the header. Should be something like "licensed by RT"}
      {uid handling not implemented}
      {umlaut escaping in mailbox names missing}
      {return values are not always meaningful}
      {internal advancing to the next message}
      {lots of imap commands not implemented}
      {missing documentation}
      {some junk still lying around}
   ]

   Usage: {
      i: open imapx://user:pass@server/

      insert i [help] ; prints out some (misleading) help

      insert i [fetches [subject: from: date:]]
      copy/part i ; only the header fields mentioned above are fetched from the server

      insert i [fetches [uid text 0x100]] ; only get the uid, and the first 100 bytes of the body text

      insert i [fetches [rfc822]] ; back to normal

      insert i [mailboxes] ; return a list of known mail folders
      insert i [mailboxes "G*"] ; return a list of known mail folders, starting with the letter "G"
      insert i [mailbox "SPAM"] ; switch to the SPAM folder
      insert i [mailbox] ; switch back to INBOX

      insert i [create "Junk"] ; create a folder named Junk
      insert i [examine "Junk"] ; open Junk folder read only
      insert i [delete "Junk"] ; delete Junk folder
      insert i [rename "Junk" "SPAM"] ; rename folder Junk to SPAM
      
   }
]

imap-client-handler: make object! [
   insert*: get in system/words 'insert
   
   port-flags: 4194304
   open-check: none
   close-check: ["Q1 LOGOUT" none]
   write-check: none
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
   open-proto: func [
      {Open the socket connection and confirm server response.}
      port "Initalized port spec"
      /sub-protocol subproto
      /secure
      /generic
      /locals sub-port data in-bypass find-bypass bp
   ][
      if not sub-protocol [subproto: 'tcp]
      net-utils/net-log reduce ["Opening" to-string subproto "for" to-string port/scheme]
      if not system/options/quiet [print ["connecting to:" port/host]]
      find-bypass: func [host bypass /local x] [
         if found? host [
            foreach item bypass [
               if any [
                  all [x: find/match/any host item tail? x]
               ] [return true]
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
      either all [
         port/proxy/host
         bp: not in-bypass port/host port/proxy/bypass
         find [socks4 socks5 socks] port/proxy/type
      ] [
         port/sub-port: net-utils/connect-proxy/sub-protocol port 'connect subproto
      ] [
         sub-port: system/words/open/lines compose [
            scheme: (to-lit-word subproto)
            host: either all [port/proxy/type = 'generic generic bp] [port/proxy/host] [port/proxy/host: none port/host]
            user: port/user
            pass: port/pass
            port-id: either all [port/proxy/type = 'generic generic bp] [port/proxy/port-id] [port/port-id]
         ]
         port/sub-port: sub-port
      ]
      if all [secure find [ssl tls] subproto] [system/words/set-modes port/sub-port [secure: true]]
      port/sub-port/timeout: port/timeout
      port/sub-port/user: port/user
      port/sub-port/pass: port/pass
      port/sub-port/path: port/path
      port/sub-port/target: port/target
      net-utils/confirm/multiline port/sub-port open-check
      port/state/flags: port/state/flags or port-flags
   ]
   open: func [port /local resp reqcap auth-done auth-mode auth-modes path select-block][
      resp: parse/all port/user ";"
      port/locals: make object! [
         last-id: 0
         capabilities: copy* []
         msg-uids: send-section: recv-section: uidvalidity: msg-num: msg: none
      ]
      if all [secure find [ssl tls] subproto] [system/words/set-modes port/sub-port [secure: true]]
      port/sub-port/timeout: port/timeout
      port/sub-port/user: port/user
      port/sub-port/pass: port/pass
      port/sub-port/path: port/path
      port/sub-port/target: port/target
      net-utils/confirm/multiline port/sub-port open-check
      port/state/flags: port/state/flags or port-flags
   ]
   open: func [port /local resp reqcap auth-done auth-mode auth-modes path select-block][
      resp: parse/all port/user ";"
      port/locals: make object! [
         last-id: 0
         capabilities: copy* []
         msg-uids: send-section: recv-section: uidvalidity: msg-num: msg: none
         list: copy* [] ; (iho) later it was just appended to it, so none didn't work ...
         user-name: system/words/pick resp 1
         ; (iho) add recent counter, and unseen index
         recent: 0
         unseen: 0
         temp-list: copy* []
         ; end (iho)
         flags: copy* []
         permanentflags: copy* []
         access: make object! [
            type: name: search: uidvalidity: uid: section: list: none
         ]
      ]
      open-proto port
      auth-mode: system/words/pick resp 2
      resp: imap-check port none none [ok preauth]
      auth-done: (second resp) = 'preauth
      reqcap: copy* []
      auth-modes: ["auth=login" "auth=cram-md5"]
      if not auth-done [
         append reqcap auth-modes
      ]
      if not empty? exclude reqcap port/locals/capabilities [
         imap-check port "CAPABILITY" none [ok]
      ]
      if all [not auth-done auth-mode (auth-mode <> "auth=*")] [
         port/locals/capabilities: exclude port/locals/capabilities exclude auth-modes auth-mode
      ]
      if all [not auth-done find port/locals/capabilities "auth=cram-md5"] [
         if not error? catch [
            imap-check port "AUTHENTICATE CRAM-MD5" [imap-do-cram-md5 port resp] [ok]
         ] [
            auth-done: true
         ]
      ]
      if not auth-done [
         if not error? catch [
            imap-check port reform ["LOGIN" port/locals/user-name port/pass] none [ok]
         ] [
            auth-done: true
         ]
      ]
      if not auth-done [
         net-error "No authentication method available"
      ]
      path: copy* any [port/path ""]
      if port/target [append path port/target]
      imap-url-parser/do-parse path port/locals/access
      if port/locals/access/name = "" [
         port/locals/access/name: either port/locals/access/type = 'list ["*"] ["INBOX"]
      ]
      ;;; FIXME: hardcoded BODY / BODY.PEEK
      ;;; seems this is never reached ???
      either port/locals/access/section [
         port/locals/send-section: rejoin ["BODY.PEEK[" uppercase port/locals/access/section "]"]
         port/locals/recv-section: rejoin ["BODY[" uppercase port/locals/access/section "]"]
      ] [
         port/locals/send-section: port/locals/recv-section: "RFC822"
      ]
      select-block: [imap-check port reform ["SELECT" imap-form-string port/locals/access/name] none [ok]]
      switch port/locals/access/type [
         list [
            port/locals/list: copy* []
            port/state/tail: 0
            imap-check port reform [uppercase port/locals/access/list {""}
               imap-form-string port/locals/access/name
            ] none [ok]
         ]
         box select-block
         iuid [
            do select-block
            port/state/tail: 1
         ]
         search [
            port/locals/msg-uids: copy* []
            do select-block
            imap-check port reform ["UID SEARCH" port/locals/access/search] none [ok]
            port/state/tail: length? port/locals/msg-uids
         ]
      ]
      if all [port/locals/uidvalidity port/locals/access/uidvalidity
         port/locals/uidvalidity <> port/locals/access/uidvalidity
      ] [
         net-error "Stale IMAP URL"
      ]
      port/state/index: 0
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
      "Default write operation called from buffer layer."
      port "An open port spec"
      data "Data to write"
   ][
      net-utils/net-log ["low level write of " port/state/num "bytes"]
      write-io port/sub-port data port/state/num
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
      port "An open port spec"
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
   
   imap-parser: make object! [
      ;;; ATTN:
      ;append*: :append
      app: get in system/words 'append
      ;append: func copy* first :app head system/words/insert copy* second :app [print ["STACK: " series ":" value]]
      space: make bitset! #{
0002000001000000000000000000000000000000000000000000000000000000
}
      text-char: make bitset! #{
FFFDFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
      string-char: make bitset! #{
FFFDFFFFFAFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
      atom-char: make bitset! #{
FFFDFFFFDAF8FFFFFFFFFFC7FFFFFFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
      flag-char: make bitset! #{
FFFDFFFFFAFCFFFFFFFFFFD7FFFFFFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
      tag-char: make bitset! #{
FFFDFFFFDAF0FFFFFFFFFFC7FFFFFFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
      int-char: make bitset! #{
000000000000FF03000000000000000000000000000000000000000000000000
}
      atom: [
         mark1: some atom-char ;(print ['mark1 mark1])
         ;["[" some atom-char "]" | none]
         ["[" thru "]" | none] ; to work with BODY[...]
         mark2: (append last stack copy*/part mark1 mark2)
      ]
      flag: [mark1: "\" some flag-char mark2: (append last stack copy*/part mark1 mark2)]
      tag: [mark1: some tag-char mark2: (append last stack copy*/part mark1 mark2)]
      string: [{"} mark1: any [string-char | ["\" skip]] mark2: {"} (
            tmp: copy*/part mark1 mark2
            forall tmp [if (first tmp) = #"\" [system/words/remove tmp]]
            append last stack head tmp
      )]
      literal: [mark1: "{" (
            tmp: load/next/all mark1
            append last stack first tmp
            mark1: skip mark1 ((length? mark1) - length? second tmp)
         ) :mark1
      ]
      text: [mark1: any text-char mark2: (append last stack copy*/part mark1 mark2)]
      integer: [mark1: some int-char mark2: (append last stack to-integer copy*/part mark1 mark2)]
      ;;; DONE: add body[...] parsing (item-list ...) => atom
      item-list: [[atom | flag | paren-set | string | literal] [some space item-list | none]]
      list-contents: [
         any space (tmp: copy* [] append/only last stack tmp append/only stack tmp)
         [item-list | none]
         (system/words/remove back tail stack)
         any space
      ]
      paren-set: ["(" list-contents ")"]
      resp-code: ["[" list-contents "]"]
      ;;; FIXME: add handling of "*" responses!
      untagged-response: [
         "*" (append last stack '*)
         some space
         [integer | atom]
         [[some space resp-code] | none (append last stack none)]
         [some space [item-list | text] | none (append last stack none)]
      ]
      tagged-response: [
         ;[tag | "*" (append last stack '*)]
         tag
         some space
         [integer | atom]
         ;(?? '.)
         [[some space resp-code] | none (append last stack none)]
         ;(?? '..)
         [some space [item-list | text] | none (append last stack none)]
         ;(?? '...)
         ;(probe stack)
      ]
      cont-response: [
         "+" (append last stack '+)
         some space
         [mark1: (append last stack copy* mark1) to end]
      ]
      ;;; FIXME: Problems with Hamster, noop response ending in ":-)"
      ; (iho) response: [[tagged-response | cont-response] any space]
      response: [[tagged-response | untagged-response | cont-response] to end]
      stack: none
      result: none
      mark1: none
      mark2: none
      tmp: none
      
      do-parse: func [str][
         stack: copy* [] ; stack will be handled in the forever loop in imap-transact
         result: copy* []
         append/only stack result
         if not parse/all str response [
            net-error "Parse error"
         ]
         result
      ]
   ]
   
   imap-url-parser: make object! [
      mailbox-char: make bitset! #{
FFFFFFFFFFFFFF77FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
      integer-char: make bitset! #{
000000000000FF03000000000000000000000000000000000000000000000000
}
      mailbox: [
         mark1: any mailbox-char mark2:
         (object/name: copy*/part mark1 mark2)
      ]
      integer: [some integer-char]
      search: ["?" mark1: (object/search: copy* mark1) to end]
      uidvalidity: [";UIDVALIDITY=" mark1: integer mark2:
         (object/uidvalidity: to-integer copy*/part mark1 mark2)
      ]
      iuid: [["/" | none] ";UID=" mark1: integer mark2:
         (object/uid: to-integer copy*/part mark1 mark2
            if all [0 < length? object/name #"/" = last object/name] [
               system/words/remove back tail object/name
            ]
         )
      ]
      isection: ["/;SECTION=" mark1: (object/section: copy* mark1) to end]
      list-input: [
         mailbox (object/type: 'list) ";TYPE=" mark1:
         ["LIST" | "LSUB"] mark2: (object/list: uppercase copy*/part mark1 mark2)
      ]
      search-input: [
         mailbox (object/type: 'search) [uidvalidity | none] search
      ]
      uid-input: [
         mailbox (object/type: 'iuid) [uidvalidity | none] iuid [isection | none]
      ]
      def-input: [
         mailbox (object/type: 'box) [uidvalidity | none]
      ]
      input: [list-input | search-input | uid-input | def-input]
      object: none
      do-parse: func [str obj /local mark1 mark2][
         object: obj
         if not parse/all str input [
            net-error "Invalid IMAP URL"
         ]
      ]
   ]
   imap-read-literal: func [port count /local result tmp len][
      result: make string! count
      while [count > 0] [
         len: read-io port tmp: make binary! count count
         if len <= 0 [
            net-error "Read error"
         ]
         append result tmp
         count: count - len
      ]
      result
   ]
   imap-read-line: func [port /local server-said tmp ix count][
      server-said: make string! 80
      forever [
         tmp: system/words/pick port 1
         if none? tmp [
            net-error "Server closed the connection"
         ]
         either (last tmp) = #"}" [
            if not ix: find/last tmp #"{" [
               net-error "Malformed server response"
            ]
            append server-said copy*/part tmp ix
            count: to-integer copy*/part next ix back tail tmp
            append server-said mold imap-read-literal port count
         ] [
            append server-said tmp
            net-utils/net-log join "S: " server-said
            return server-said
         ]
      ]
   ]
   imap-transact: func [port send-data cont-block /local resp data w list-block tmp tmp2][
      if send-data [
         port/locals/last-id: port/locals/last-id + 1
         resp: rejoin ["A" port/locals/last-id " " send-data]
         net-utils/net-log join "C: " resp
         insert* port/sub-port resp
      ]
      list-block: [
         ;;; FIXME: this assumes, that "/" is always the mailbox delimiter
         if all [(system/words/pick resp 5) = "/" tmp: system/words/pick resp 6] [
            ;insert clear port/locals/list unique append port/locals/list to-file tmp
            any [find port/locals/list to-file tmp append port/locals/list to-file tmp]
            append port/locals/temp-list to-file tmp
            port/state/tail: port/state/tail + 1
         ]
      ]
      forever [
         ;;; FIXME: add response handling ...
         ;;; resp is the returned stack from imap-parser
         resp: imap-parser/do-parse imap-read-line port/sub-port
         ;?? resp
         if block? tmp: system/words/pick resp 3 [
            ;probe tmp
            if find tmp "alert" [
               if not system/options/quiet [print ["IMAP Alert:" form at resp 4]]
            ]
            if tmp2: find tmp "uidvalidity" [
               error? try [port/locals/uidvalidity: to-integer second tmp2]
            ]
            if (first tmp) = "capability" [
               port/locals/capabilities: union port/locals/capabilities at tmp 2
            ]
            if "unseen" = first tmp [
               error? try [port/locals/unseen: to integer! second tmp]
            ]
            if "permanentflags" = first tmp [
               port/locals/permanentflags: copy* second tmp
            ]
         ]
         either (first resp) = '* [ ; untagged response
            either integer? w: second resp [
               switch fourth resp [
                  "exists" [
                     if port/locals/access/type = 'box [
                        port/state/tail: w
                     ]
                  ]
                  "recent" [
                     port/locals/recent: w
                  ]
                  "fetch" [
                     ;;; FIXME: HERE BE DRAGONS !!!
                     ;;; find the message text, when more than one message text may be present, e.g.
                     ;;; some header fields + text
                     if any [
                        all [port/locals/access/type = 'box w = port/locals/msg-num]
                        all [find [iuid search] port/locals/access/type
                           (select fifth resp "uid") = to-string port/locals/msg-num
                        ]
                     ] [
                        ; I can not be sure to find the msg ...
                        ;probe resp
                        either none? port/locals/msg: select fifth resp port/locals/recv-section [
                           tmp: port/locals/msg: fifth resp
                           to-sec-word: func [str /local ret][
                              case [
                                 find str "BODY[HEADER" [ret: 'header]
                                 find str "BODY[TEXT" [ret: 'text]
                                 "RFC822.SIZE" = str [ret: 'size]
                                 true [ret: to word! lowercase str]
                              ]
                              ret
                           ]
                           forskip tmp 2 [change tmp to-sec-word tmp/1 replace/all tmp/2 "^M" "" ]
                        ][
                           ;(print 'msg)
                           ;probe Port/locals/msg
                           replace/all port/locals/msg "^M" ""
                        ]
                     ]
                  ]
                  "expunge" [
                     port/state/tail: port/state/tail - 1
                  ]
               ]
            ] [
               switch w [
                  "capability" [
                     port/locals/capabilities: union port/locals/capabilities at resp 5
                  ]
                  "list" list-block
                  "lsub" list-block
                  "search" [
                     tmp: at resp 4
                     forall tmp [
                        all [first tmp append port/locals/msg-uids to-integer first tmp]
                     ]
                  ]
               ]
            ]
         ] [ ; tagged response, or continuation response
            either (first resp) = '+ [
               bind cont-block 'resp
               do cont-block
            ] [
               if (first resp) = rejoin ["A" port/locals/last-id] [
                  return resp
               ]
            ]
         ]
         if not send-data [return resp]
      ]
   ]
   imap-check: func [port send-data cont-block expected /local resp][
      resp: imap-transact port send-data cont-block
      if not find expected to-word second resp [
         net-error reform ["Server error: IMAP" resp]
      ]
      return resp
   ]
   imap-do-cram-md5: func [port server-data /local send-data][
      server-data: debase/base second server-data 64
      send-data: reform [port/locals/user-name
         lowercase enbase/base checksum/method/key server-data 'md5 port/pass 16
      ]
      send-data: enbase/base send-data 64
      net-utils/net-log join "C: " send-data
      insert* port/sub-port send-data
   ]
   imap-form-string: func [str /local res c][
      res: make string! 2 + length? str
      append res #"^""
      foreach c str [
         if find {"\} c [append res #"\"]
         append res c
      ]
      append res #"^""
      res
   ]
   imap-read-message: func [
      "Read a message from the IMAP server"
      port
      cmd
      n [integer!]
      /local buf line
   ][
      port/locals/msg-num: n
      imap-check port reform [cmd port/locals/msg-num port/locals/send-section] none [ok]
      port/locals/msg
   ]
   imap-pick-copy: func [port type /local msgs n][
      switch port/locals/access/type [
         box [
            either type = 'pick [
               imap-read-message port "FETCH" port/state/index + 1
            ] [
               msgs: make block! port/state/num
               repeat n port/state/num [
                  append msgs imap-read-message port "FETCH" port/state/index + n
               ]
               msgs
            ]
         ]
         iuid [
            either type = 'pick [
               imap-read-message port "UID FETCH" port/locals/access/uid
            ] [
               msgs: make block! 1
               append msgs imap-read-message port "UID FETCH" port/locals/access/uid
               msgs
            ]
         ]
         list [
            either type = 'pick [
               system/words/pick port/locals/list port/state/index + 1
            ] [
               msgs: make block! port/state/num
               repeat n port/state/num [
                  append msgs system/words/pick port/locals/list port/state/index + n
               ]
               msgs
            ]
         ]
         search [
            either type = 'pick [
               imap-read-message port "UID FETCH" system/words/pick port/locals/msg-uids port/state/index + 1
            ] [
               msgs: make block! port/state/num
               repeat n port/state/num [
                  append msgs imap-read-message port "UID FETCH" system/words/pick port/locals/msg-uids port/state/index + n
               ]
               msgs
            ]
         ]
      ]
   ]
   pick: func [
      "Read the Nth message from the POP port"
      port
   ][
      imap-pick-copy port 'pick
   ]
   copy: func [
      "Copy a set of messages into a block"
      port
   ][
      imap-pick-copy port 'copy
   ]
   remove: func [
      "Remove the current message"
      port
   ][
      switch port/locals/access/type [
         box [
            if port/state/num > 0 [
               imap-check port rejoin ["STORE " port/state/index + 1 ":"
                  port/state/index + port/state/num " +FLAGS.SILENT (\Deleted)"
               ] none [ok]
               imap-check port "EXPUNGE" none [ok]
               port/state/num: 0
            ]
         ]
         iuid [
            if port/state/num > 0 [
               imap-check port rejoin ["UID STORE " port/locals/access/uid
                  " +FLAGS.SILENT (\Deleted)"
               ] none [ok]
               imap-check port "EXPUNGE" none [ok]
               port/state/num: 0
            ]
         ]
         list [
            net-error "Removal of mailboxes not supported"
         ]
         search [
            while [port/state/num > 0] [
               imap-check port rejoin ["UID STORE " system/words/pick port/locals/msg-uids port/state/index + 1
                  " +FLAGS.SILENT (\Deleted)"
               ] none [ok]
               system/words/remove at port/locals/msg-uids port/state/index + 1
               port/state/num: port/state/num - 1
            ]
            imap-check port "EXPUNGE" none [ok]
         ]
      ]
      port
   ]
   
   help-on-insert: func [
      "parse insert rule, to give help on commands to be inserted"
      /local print-rule command action text type types param
   ][
      param: none
      print trim/auto {
            The following commands are currently allowed for the imap port,
            they are based on the imap protocol commands (rfc3501).

            usage is like:

               insert imap-port [select "MAILBOX"]

            
         }
      print-rule: [
         set action paren! (
            ;dbg/?? types
            if not string? text: first action [text: "not documented"]
            print [command mold to paren! types newline tab text newline]
            types: copy* []
         )
      ]
      param-rule: [
         some [
            'set set param word! set type any-type! (
               ;;; FIXME: got an error here ...
               attempt [insert* tail types reduce bind [param type] param]
            )
         ]
      ]
      bind param-rule 'param
      parse insert-rule [
         (types: copy* [])
         some [
            set command lit-word! [
               print-rule
               |
               into [
                  param-rule
                  print-rule
                  opt [ '| 'none print-rule]
               ]
               |
               param-rule
               print-rule
               |
               skip
            ]
            to lit-word!
         ]
      ]
   ]
   
   { ALL
         Macro equivalent to: (FLAGS INTERNALDATE RFC822.SIZE ENVELOPE)

      FAST
         Macro equivalent to: (FLAGS INTERNALDATE RFC822.SIZE)

      FULL
         Macro equivalent to: (FLAGS INTERNALDATE RFC822.SIZE ENVELOPE BODY)
}
   
   
   section-rule: [
      ; MACROS
      ALL
      FAST
      FULL
      ; MESSAGE PARTS
      BODY[]<>
      BODY.PEEK[]<>
      RFC822 .size .header .text
      BODYSTRUCTURE
      ENVELOPE
      FLAGS
      INTERNALDATE
   ]
   
   ;;; TODO: uid fetch/delete/copy
   ; this makes it possible to delete stored mails I guess its better than sequence ???
   
   appnd: func [str1 str2][
      append str1 rejoin [either #"(" = last str1 [""][" "] str2]
   ]
   
   insert-rule: [
      'fetch-section [
         ;(print '...............)
         ;;; FIXME: shoud I use a second parse?
         ; it's hard to remember to put together the string correctly
         set sections string! (
            "tell the server which part of the mail to send"
            port/locals/access/section: sections: uppercase sections
            ;port/locals/send-section: rejoin ["BODY.PEEK[" sections "]"]
            port/locals/send-section: rejoin [sections ]
            ;port/locals/recv-section: rejoin ["BODY[" sections "]"]
            port/locals/recv-section: rejoin [sections]
         )
         |
         none (
            "reset to fetch rfc822 body"
            port/locals/access/section: port/locals/send-section: port/locals/recv-section: "RFC822"
         )
      ]
      |
      'fetches into [
         (peek: ""
            headers: copy* ""
            text: false
            uid: false
            rfc822: false
            flags: false
            str: copy* "("
            size: none
         )
         some [
            ['peek (peek: ".PEEK")]
            | ['no-peek (peek: "")]
            | [ 'uid (appnd str "UID") ]
            | [ 'flags (appnd str "FLAGS")]
            | [ 'size (appnd str "RFC822.SIZE")]
            | [
               set header set-word!
               ( appnd str rejoin ["BODY" peek "[HEADER.FIELDS (" uppercase form header])
               any [
                  set header set-word!
                  (appnd str rejoin [uppercase form header])
               ]
               (append str ")]")
            ]
            | [ 'header (appnd str rejoin ["BODY" peek "[HEADER]"])]
            | [
               ['text | 'body | 'rfc822] opt [set size pair!]
               (appnd str rejoin ["BODY" peek "[TEXT]"
                     either size [rejoin ["<" size/x "." size/y ">"]][""]])
            ]
            | 'struct (appnd str "BODYSTRUCTURE")
         ]
         (
            append str ")"
            port/locals/access/section: sections: str
            port/locals/send-section: rejoin [sections]
            port/locals/recv-section: rejoin [sections]
            
         )
         
         ;(probe str)
         ; (
         ; [
         ; some [
         ; 'peek (peek: true)
         ; |
         ; 'text opt [set arg1 integer!] opt [set arg2 integer!]
         ; (text: true)
         ; |
         ; set header set-word!
         ; (repend headers [" " uppercase form header])
         ; |
         ; 'uid (uid: true)
         ; |
         ; 'flags (flags: true)
         ; |
         ;'rfc822 (rfc822: true)
         ; ]
         ; (
         ; str-start: either peek ["BODY.PEEK["]["BODY["]
         ; str: copy* either uid ["(UID "]["("]
         ; if "" <> headers [
         ; append str rejoin [str-start "HEADER.FIELDS (" trim/head headers ")]"]
         ; ]
         ; if text [append str rejoin [str-start "TEXT]"]]
         ; append str ")"
         ; ;probe str
         ; port/locals/access/section: sections: str
         ; port/locals/send-section: rejoin [sections]
         ; port/locals/recv-section: rejoin [sections]
         ; )
         ; ]
         ; )
      ]
      |
      'new? (
         "check mailbox for new mail or keepalive (IMAP: NOOP)"
         retval: imap-check port "NOOP" none [ok]
      )
      |
      'pos? ( "print current poition in mailbox"
         retval: port/state/index
      )
      |
      'pos [
         'skip set arg integer! (
            port/state/index: port/state/index + arg
         )
         |
         set arg integer! (
            port/state/index: arg
         )
      ]
      |
      ;;; FIXME: dependency between search & select
      ; after a select the server does no more use the last search command, so it doesn't
      ; send the list of uids - I have to reset it
      'view [
         set search string! (
            "IMAP search command"
            port/locals/msg-uids: copy* []
            port/locals/access/type: 'search
            port/locals/access/search: search
            retval: imap-check port reform ["UID SEARCH" port/locals/access/search] none [ok]
            port/state/tail: length? port/locals/msg-uids
         )
         |
         none (
            "reset to see all emails"
            port/locals/access/type: 'box
            port/locals/access/search: none
            ;;; FIXME: this seems to work ... would just reopening the mailbox be better?
            ; think about a 4000 mail account ...
            retval: imap-check port reform ["SEARCH ALL"] none [ok]
            port/state/tail: length? port/locals/msg-uids
         )
         
      ]
      |
      'mailbox [
         set name string! (
            "change to a different mailbox (IMAP: SELECT)"
            port/locals/access/type: 'box
            port/locals/access/search: none
            imap-check port trim/lines reform ["SELECT " name] none [OK]
            port/locals/access/name: name
            retval: name
         )
         |
         none (
            "select default mailbox INBOX"
            port/locals/access/type: 'box
            port/locals/access/search: none
            imap-check port "SELECT INBOX" none [OK]
            retval: "INBOX"
         )
      ]
      |
      'mailboxes
      (
         arg1: arg2: none
         clear port/locals/temp-list
      )
      opt [set arg1 string!]
      opt [set arg2 string!]
      (
         either none? arg1 [
            arg1: ""
            arg2: "*"
         ][
            if none? arg2 [
               arg2: arg1
               arg1: ""
            ]
         ]
         imap-check port reform ["LIST" mold arg1 mold arg2] none [OK]
         retval: port/locals/temp-list
      )
      |
      'help (
         "this help"
         help-on-insert
      )
      |
      'flags set action word! set flags string! (
         "change the current messages flags action: (add,del,change), flags: list of flags (without parens) (IMAP: STORE)"
         command: switch/default action [
            add ["+FLAGS.SILENT"]
            del ["-FLAGS.SILENT"]
            change ["FLAGS.SILENT"]
         ][throw make error! "use flags (add | del | change) string!"]
         if none? port/locals/msg-num [throw make error! "no current mail selected"]
         retval: imap-check port reform ["STORE " port/locals/msg-num command "(" flags ")" ] none [OK]
      )
      |
      'raw set imap-command string! (
         "send raw imap command"
         retval: imap-check port imap-command none [ok]
      )
      |
      'fetch
      |
      'uid-fetch
      |
      'uid-copy
      |
      'uid-store
      |
      ;
      ; MAILBOX level commands
      ;
      ; 'mailbox [
      'examine set name string! (
         "open a mailbox readonly"
         retval: imap-check port reform ["EXAMINE" mold name] none [OK]
      )
      |
      'create set name string! (
         "create a new mailbox"
         retval: imap-check port reform ["CREATE" mold name] none [OK]
      )
      |
      'delete set name string! (
         "delete the named mailbox"
         retval: imap-check port reform ["DELETE" mold name] none [OK]
      )
      |
      'rename set name string! set newname string! (
         "rename the mailbox"
         retval: imap-check port reform ["RENAME" mold name " " mold newname] none [OK]
      )
      |
      'subscribe set name string! (
         "add mailbox name to the list of subscribed mailboxes"
         retval: imap-check port reform ["SUBSCRIBE" mold name] none [OK]
      )
      |
      'unsubscribe set name string! (
         "remove mailbox name from the list of subscribed mailboxes"
         retval: imap-check port reform ["UNSUBSCRIBE" mold name] none [OK]
      )
      |
      ;;; FIXME: I am not catching the return values ...
      'list set val string! set val2 string! (
         "list mailboxes (imap list)"
         imap-check port reform ["LIST" mold val mold val2] none [OK]
         retval: port/locals/list
      )
      |
      'lsub set val string! set val2 string! (
         "(imap lsub)"
         retval: imap-check port reform ["LSUB" mold val mold val2] none [OK]
      )
      ; status ... ; do I need this?
      ; check ... ; internal housekeeping
      |
      ; mailbox, flags (LIST), date/time, message
      'append set name string! set flags string! set date-time string! set message string! (
         "append a mail to the mailbox"
         ; TODO:
      )
      |
      ;;; TODO:
      'copy set mailbox string! opt [set mail-numbers string!] (
         {copy mail(s) to mailbox mail-numbers: "1" | "3:5"}
         retval: imap-check port reform ["COPY" mail-numbers mailbox] none [ok]
      )
      |
      ;;; TODO:
      'uid (
         "switch to uid access for _all_ following 'insert actions"
         uid: "UID "
      )
      'seq (
         "switch to sequence number access for _all_ following 'insert actions"
         uid: ""
      )
      |
      'close (
         "remove deleted mail from the mailbox, and deselect the mailbox"
         retval: imap-check port "CLOSE" none [OK]
      )
      |
      'expunge (
         "remove deleted mail from the mailbox"
         retval: imap-check port "EXPUNGE" none [OK]
      )
      ;]
   ]
   
   insert: func [
      port
      data [block! string!] "A string will be send as is as a command, a block contains a dialect"
      /local val val2 name newname flags date-time message search sections retval
   ][
      ;print 'INSERT
      retval: 'ok
      insert-rule: bind insert-rule 'val
      if not parse data [some insert-rule] [throw make error! "unable to parse imap commands"]
      retval
   ]
   
   action: func [action[block!]][
      insert self action
   ]
]
net-utils/net-install IMAPX imap-client-handler 143

; some helpers
upcase: func [str][
   str: lowercase form str
   change str uppercase str/1
   str
]

'ok
