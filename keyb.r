REBOL [
    Title: "keyboard input sequencer"
    Date: 3-Aug-2002
    Version: 1.0.0
    File: %keyb.r
    Home: http://plain.at/vpavlu
    Author: "viktor pavlu"
    Purpose: {a replacement for the missing keyboard input sequences table in REBOL/Core User Guide Version 2.3, Appendix C-4}
    Email: vpavlu@plain.at
    Web: http://plain.at/vpavlu
    library: [
        level: 'intermediate 
        platform: none 
        type: [tool tutorial] 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

port: open/binary/no-wait [ scheme: 'console ]
system/console/break: no
seq: make string! 2
print "Keyboard Input Sequences"
until [
  wait port
  buf: copy port
  clear seq
  foreach char buf [ append seq rejoin [ "^^(" to-integer char ")" ] ]
  print rejoin [{(#"q" quits)>> escape-sequence: #"} seq {"} ]
  (buf = #{71})
]
close port                         