REBOL [
  Title: "Garmin IMG decoder"
  Purpose: {
    Dekoduje pliki zakodowane funkcja XOR
    Skrypt moze byc wykorzystywany jedynie w celach edukacyjnych.
  }
  Date: 2003-11-14
  Version: 1.1.0
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  File: %gps-xor.r
  Url: http://www.rowery.olsztyn.pl/wspolpraca/rss/
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  License: "GNU General Public License (Version II)"
  Library: [
    level: 'intermediate
    platform: 'all
    type: [tool]
    domain: [files]
    tested-under: [
      view 1.2.1  on [Linux WinXP]
    ]
    support: none
    license: 'GPL
  ]
]

decode: func [
 "Dekoduje dane binarne przez XOR z maska"
  dat [binary!] "zakodowane dane binarne"][

  xor-mask: does [xor-mask: (copy/part (skip dat 10) 1) xor #{44}]
  mask: to-integer xor-mask
  buffer: copy #{}
  foreach byte dat [append buffer to-binary reduce [byte xor mask]]
  return buffer
]

if not none? files: request-file [
  file: first files
  xor-file: to-file rejoin [copy/part file index? (find/last file ".") "xor"]
  write/binary xor-file decode read/binary file
  print ["wynikowy plik jest zapisany tutaj:" CRLF xor-file]
]
