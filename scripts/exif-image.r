REBOL [ 
  Title: "REBOL::EXIF::IMAGE"
  Description: "REBOL to EXIF interface"
  Date: 2003/12/21
  Version: 1.2
  Id: "$Id: exif-image.r,v 1.2 2003/12/21 17:48:57 narg Exp $"
  Author: "Piotr Gapinski"
  Email: news@rowery.olsztyn.pl
  File: %exif-image.r
  Purpose: "obsluga plikow JPEG/EXIF"
  Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
  License: "GNU Lesser General Public License (Version 2.1)"
  Example: { ;; simple demo program (show thumbnail image)
    either all [
      not none file: request-file 
      good-file?/debug first file 
      image? img: jpeg-thumbnail file ]
    [ view center-face layout [across label 80 right "thumbnail:" image img edge [size: 2x2 color: black]]]
    [ print [(first file) CRLF "EXIF not found"] halt ]
  }
  library: [
    level: 'intermediate
    platform: 'all
    type: [module tool]
    domain: [files graphics]
    tested-under: [
      view 1.2.1 on [linux Win2K amiga]
      view 1.2.8 on [linux winxp]
    ] 
   support: none
    license: 'LGPL
  ]
]

do %exif-core.r

jpeg-datetime: func [
 "Zwraca date! wykonania zdjecia zwart&#261; w strukturze EXIF (lub none!)."
 [catch]
  file-name [file! string!] "nazwa pliku zdjecia"
 /local date time] [

  ;; jezeli plik nie ma danych EXIF to zwroc none!

  if not good-file? to-file file-name [return none]
  if error? try [
    set [date time] parse/all trim exif-tag #{0132} " " ;; "DateTime Tag"
    return to-date rejoin [replace/all date ":" "-" "/" time] ;; "+" now/zone] ;; mozliwo&#347;c dodania strefy czasowej
  ] [return none] ;; w przypadku bledu zwroc none!
]

jpeg-thumbnail: func [
 "Zwraca image! miniaturki zdjecia z pliku EXIF lub none! (obsluguje tylko JPEG EXIF)."
 [catch]
  file-name [file! string!] "nazwa pliku zdjecia"
 /binary "Zwraca zdjecie w formacie binary! (JPEG)"
 /local compression location size thumb] [

  ;; jezeli plik nie ma danych EXIF to zwroc none!

  if not good-file? to-file file-name [return none]
  if error? try [
    set [compression location size] exif-tag [#{0103} #{0201} #{0202}] ;; Compression, Size, OffsetTag
    if compression = 6 [
      ;; 6 oznacza iz mamy do czynienia z miniaturk&#261; zdjecia w formacie JPEG
      thumb: exif-ctx/get-content location size
      return either binary [thumb] [load thumb]
    ]
  ] [return none] ;; w przypadku bledu zwroc none!
]

jpeg-size: func [
 "Zwraca pair! rozdzielczo&#347;ci zdjecia EXIF lub none!"
 [catch]
  file-name [file! string!] "nazwa pliku zdjecia"] [

  ;; jezeli plik nie ma danych EXIF to zwroc none!

  if not good-file? to-file file-name [return none]
  if error? try [return to-pair exif-tag [#{a002} #{a003}]] [return none] ;; w przypadku bledu zwroc none!
]

jpeg-reduce: func [
 "Usuwa zbedne chunki z pliku JPEG/EXIF, zwraca image!"
  file-name [file! string!] "nazwa pliku zdjecia"
 /binary "zwraca zdjecie w formacie binary! (JPEG)"
 /custom "usuwa tylko wybrane chunki" chunk [binary! block!] "binary! id chunka do usuniecia lub block!"
 /local chunk-position chunk-size rc dat tags] [

  ;; jezeli plik nie ma danych EXIF to zwroc none!

  if not good-file? to-file file-name [return false]
  dat: read/binary/direct to-file file

  tags: reduce either (custom)
    [either (block? chunk) [chunk] [ [chunk] ]]
    [ [EXIF-APP0 EXIF-APP1 EXIF-APP2 EXIF-CMT] ]

  foreach tag tags [
    rc: all [
      not zero? chunk-position: to-integer exif-ctx/read-traverse/position file-name tag
      not zero? chunk-size: 2 + to-integer exif-ctx/range/custom (pos + 2) 2 dat ;; wielko&#347;c danych w chunk + dwa bajty na sam znacznik
    ]
    ;; if not none? rc [print ["znaleziono chunk" tag "offset" chunk-position "wielko&#347;c" chunk-size]]
    if not none? rc [remove/part (skip dat chunk-position) chunk-size] ;; usun chunk
  ]
  return either binary [dat][load dat]
]

jpeg-comment: func [
 "Zwraca tekt komentarza lub false!"
  file-name [file! string!] "nazwa pliku zdjecia"
 /binary "Zwraca komentarz w formacie binary!"
 /local dat] [

  ;; jezeli plik nie ma danych EXIF to zwroc none!

  if not good-file? to-file file-name [return false]
  dat: exif-ctx/read-traverse file-name EXIF-CMT
  if none? dat [return false]
  dat: skip dat 4
  return either binary [dat][to-string dat]
]
