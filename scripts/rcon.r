REBOL [
   Title: "RCON protocol handler"
   Author: "Cal Dixon"
   Date: 13-Oct-2003
   Comment: {Tested with Half-Life 1.1.1.0 (protocol version 46), should work with old HL, QW, Q2, Q3 and RTCW.}
   File: %rcon.r
   Purpose: "Allow rebol scripts to perform remote server administration tasks for Half-life game servers"
   Library: [
        level: 'advanced
        platform: 'all
        type: [protocol tool game]
        domain: [game internet protocol]
        tested-under: none
        support: none
        license: 'PD
        see-also: none
      ]
   ]

make root-protocol [
   pre: #{ffffffff}
   eot: #{00}
   port-flags: system/standard/port-flags/pass-thru
   mode: 'HL ; other option is 'Q2
   open: func [port /local t][
      port/sub-port: system/words/open/binary/no-wait/direct rejoin [udp:// port/host ":" port/port-id]
      port/locals: context [sessionid: "" command: port/target]
      mode: 'HL
      if all [string? port/path not empty? port/path][
         mode: to-word replace port/path "/" ""
         ]
      if mode = 'HL [
         system/words/insert port/sub-port to-string to-binary rejoin [pre "challenge rcon" #{0A} eot]
         port/locals/sessionid: system/words/copy/part t: skip system/words/copy port/sub-port 19 find t "^/"
         ]
      if all [string? port/target not empty? port/target][
         either mode = 'HL [
            system/words/insert port/sub-port to-string to-binary rejoin [
               pre {rcon } port/locals/sessionid { "} port/pass {" } port/locals/command eot
               ]
            ][
            system/words/insert port/sub-port to-string to-binary rejoin [
               pre {rcon } port/pass { } port/locals/command #{0A} eot
               ]
            ]
         ]
      port/state/tail: 2000
      port/state/index: 0
      port/state/flags: port/state/flags or port-flags
      ]
   copy: func [port /local v][
      v: system/words/copy port/sub-port
      replace v #{FFFFFFFF6c} #{}
      replace v #{FFFFFFFF6e} #{}
      replace v #{FFFFFFFF} #{}
      replace v #{FEFFFFFF2E2E2E2E2E} #{}
      error? try [v: system/words/copy/part v find v #{00}]
      if all [ mode <> 'HL find v "Bad challenge.^/"] [ mode: 'HL ]
      either (to-char {"}) = system/words/pick v 1 [ last load v ][ v ]
      ]
   insert: func [port data][
      either mode = 'HL [
         system/words/insert port/sub-port to-string to-binary rejoin [
            pre {rcon } port/locals/sessionid { "} port/pass {" } data eot
            ]
         ][
         system/words/insert port/sub-port to-string to-binary rejoin [
            pre {rcon } port/pass { } data #{0A} eot
            ]
         ]
      ]
   close: func [port][system/words/close port/sub-port]
   net-utils/net-install rcon self 27015
   ]

comment {
probe read rcon://:yourrconpassword@localhost/admin_command admin_csay testing
a: open rcon://:yourrconpassword@localhost/
insert a "sv_gravity"
probe copy a
insert a "mp_bots"
probe copy a
close a
probe read rcon://:yourrconpassword@localhost/q2/status ; Quake example
probe read rcon://:yourrconpassword@localhost/hl/status ; Half-Life example
}
