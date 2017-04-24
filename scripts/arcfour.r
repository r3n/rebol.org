REBOL [
   Title: "ARCFOUR and CipherSaber"
   Date: 17-Jan-2004
   File: %arcfour.r
   Author: "Cal Dixon"
   Purpose: {Provides encryption and decryption using the ARCFOUR algorithm}
   Note: {this implementation can decrypt data at about 40KB/s on my 1Ghz AMD Duron system with Rebol/View 1.2.10.3.1}
   Library: [
      level: 'advanced
      platform: 'all
      type: [function module protocol]
      domain: [encryption scheme]
      tested-under: [view 1.2.10.3.1 on [W2K] by "Cal"]
      license: 'PD
      support: none
      ]
   ]

;ARCFOUR specification: http://www.mozilla.org/projects/security/pki/nss/draft-kaukonen-cipher-arcfour-03.txt
;CipherSabre specification: http://ciphersaber.gurus.com/faq.html#getrc4

arcfour-short: func [key [string! binary!] stream [binary! string!] /mix n /local state i j output swap addmod sz][
   swap: func [a b s /local][ local: sz s a poke s a + 1 to-char sz s b poke s b + 1 to-char local ]
   addmod: func [ a b ][ a + b // 256 ]
   sz: func [ s a ][ pick s a + 1 ]
   state: make binary! 256 repeat var 256 [ insert tail state to-char var - 1 ]
   j: 0 loop any [ n 1 ] [ i: 0 loop 256 [ swap i j: addmod j add sz state i sz key i // length? key state i: i + 1] ]
   i: j: 0 output: make binary! length? stream
   repeat byte stream [
      swap i: addmod i 1 j: addmod j sz state i state
      insert tail output to-char xor~ byte to-char sz state addmod (sz state i) (sz state j)
      ]
   clear state
   return output
   ] 

make root-protocol [
   addmod: addmod: func [ a b ][ a + b // 256 ]
   sz: func [ s a ][ pick s a + 1 ]
   swap: func [a b s /local][ local: sz s a poke s a + 1 to-char sz s b poke s b + 1 to-char local ]
   ins: get in system/words 'insert
   i: 0 j: 0
   open: func [port][
      port/state/tail: 2000
      port/state/index: 0
      port/state/flags: port/state/flags or port-flags
      port/locals: context [ inbuffer: make binary! 40000 state: make binary! 256]
      use [key n i j] [
         key: port/key
         n: port/strength
         repeat var 256 [ ins tail port/locals/state to-char var - 1 ]
         j: 0 loop any [ n 1 ] [
            i: 0 loop 256 [
               swap i j: addmod j add sz port/locals/state i sz key i // length? key port/locals/state i: i + 1
               ]
            ]
         ]
      i: j: 0
      ]
   insert: func [port data][
      system/words/insert tail port/locals/inbuffer data do []
      ]
   copy: func [port /local output][
      output: make binary! local: length? port/locals/inbuffer
      loop local [
         swap i: addmod i 1 j: addmod j sz port/locals/state i port/locals/state
         ins tail output to-char sz port/locals/state addmod (sz port/locals/state i) (sz port/locals/state j)
         ]
      local: xor~ output port/locals/inbuffer
      clear port/locals/inbuffer
      local
      ]
   close: func [port][ clear port/locals/inbuffer clear port/locals/state clear port/url clear port/key]
   port-flags: system/standard/port-flags/pass-thru
   net-utils/net-install arcfour self 0
   ]

arcfour: func [key stream /mix n /local port][
   port: open compose [scheme: 'arcfour key: (key) strength: (n)]
   insert port stream
   local: copy port
   close port
   return local
   ]

; CipherSaber is an ARCFOUR stream prepended with 10 bytes of random key data
ciphersaber: func [ key stream /v2 n ][
   arcfour/mix join key copy/part stream 10 skip stream 10 either v2 [ any [ n 42 ] ][ 1 ]
   ]

comment [
; Tests
probe to-string ciphersaber "asdfg" #{6F6D0BABF3AA6719031530EDB677CA74E0089DD0e7b8854356bb1448e37cdbefe7f3a84f4f5fb3fd}
#{7494C2E7104B0879} = arcfour to-string #{0123456789ABCDEF} #{0000000000000000}
#{f13829c9de} = arcfour to-string #{618a63d2fb} #{dcee4cf92c}
probe to-string ciphersaber/v2 "asdfg" #{ba9ab4cffb7700e618e382e8fcc5ab9813b1abc436ba7d5cdea1a31fb72fb5763c44cfc2ac77afee19ad} 10
i: load ciphersaber "ThomasJefferson" read/binary http://ciphersaber.gurus.com/cknight.cs1 view layout [image i]
]
