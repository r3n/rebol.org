REBOL[
  
  Title: "Best File Fit"
  Date: 18/06/2004
  Name: Best File Fit
  Version: 1.0.0
  File: %bestfit.r
  Author: "Mauro Fontana"
  Owner: "M&F Soft"
  Copyright: "Copyright (C) M&F Soft 2004"
  Tabs: 2
  Purpose: {
    List the files that best fill up the available space.
    Use predefined strings or insert the available space in KB (= 1000 byte).
    Useful for selecting files to best fill up a CD/DVD.
  }
  Language: English
  Email: the.optimizer@tiscali.it
  Category: [files]
  Need: 2.5
  Library: [
	  Level: 'beginner
	  Platform: 'all
	  Type: [tool]
	  Application: 'tool
	  Domain: [files]
	  Tested-under: [Core 2.5.6.3.1 (Windows)]
	  License: "public-domain"
	  Support: "Mauro Fontana - the.optimizer@tiscali.it"
	  See-also: ""
	 ]
]

arg-space: either block? system/script/args [first system/script/args][ system/script/args]
print arg-space
print  system/options/script
print  system/options/do-arg
print  system/options/args

either none? arg-space [
  print "Using default value: CDR-74"
  available-space: 681984
][
  either not number? arg-space [
    if string? arg-space [
      switch/default arg-space [
        "FL-144" [available-space: 1470]
        "CDR-18" [available-space: 165888]
        "CDR-21" [available-space: 193536]
        "CDR-74" [available-space: 681984]
        "CDR-80" [available-space: 737280]
        "DVD-5"  [available-space: 4700000]
        "DVD-9"  [available-space: 9395000]
      ][
        print "Not a recognized type"
        halt
      ]
      
    ][
      print "Wrong parameter"
      halt
    ]
  ][
    either not positive? total-space [
      print "Use a positive value"
      halt
    ][
      available-space: to-integer arg-space
    ]
  ]
]

pack-list: make block! 10

to-dir: func [file [file!]][
  file-text: form file
  if not equal? at file-text length? file-text "/" [
    append file-text "/"
  ]
  to-file file-text
]

read-dir: func[dir [file!] depth /local indent pack lsize][
  lsize: 0
  count: 0
  indent: make string! 12
  insert/dup indent " " (depth * 2)
  file-list: read dir
  foreach f file-list [
    file-path: copy dir
    append file-path f
    count: count + 1
    either dir? file-path [
      print [indent file-path "... "]
      lsize: lsize + read-dir file-path depth + 1
      
    ][
      lsize: lsize + size? file-path
      either depth = 0 [
        print rejoin ["* " file-path " : " lsize]
        print "-----------------------------------------------"
        ; Add this file as a pack
        pack: reduce [file-path lsize false]
        append/only pack-list pack
        lsize: 0
      ][
        print [indent file-path]
      ]
    ]
  ]
  
  ; Add the basic dirs as unique elements to the available packs
  if depth = 1 [
    print reduce ["-----------------------------------------------" newline "* " dir " : " lsize newline "-----------------------------------------------"]
    pack: reduce [dir lsize false]
    append/only pack-list pack
    lsize: 0
  ]
  
  lsize
]


find-biggest: func ["Fill space by starting from bigger packs" available-space [integer!] /local best-pack] [
  best-pack: make block! [0 0]
  ksize: 0
  
  use [diff  left-space count] [
    count: 0
    foreach pack pack-list [
      count: count + 1
      ksize: to-integer (pack/2 / 1000)
      if not pack/3 [
        ;find the pack whose size best fits the available space
        diff: available-space - ksize
        if all [(positive? diff) (greater? ksize best-pack/2)] [
          best-pack/1: count
          best-pack/2: ksize
        ]
      ]
    ]
    ; we have the pack that best fits the available space
    best-pack
  ]
]

fill-tab: func [text [string!] max [integer!] fill [string!] /local trails len] [
  trails: make string! max
  len: max - length? text
  if any [negative? len equal? len 0] [text]
  insert/dup trails fill len
  append text trails
  text
]

right-align: func [text [string!] max[integer!] /local trails len] [
  trails: make string! max
  len: max - length? text
  if any [negative? len equal? len 0] [text]
  insert/dup text " " len
  text
]

;----------------------------------------------------------
; BEGIN
;----------------------------------------------------------
prin "Insert the root dir: "
ret: 0
until [
  until [not error? dir-path: input]
  if equal? dir-path "" [dir-path: "."]
  if not file? dir-path [
    dir-path: to-file to-block dir-path
  ]
  dir? dir-path
]

dir-path: to-dir dir-path

print "-----------------------------------------------"
prin "Root path: "
print dir-path
print "Calculating pack sizes"
print "-----------------------------------------------"

read-dir dir-path 0
; we have the complete list of dir (packs) and their relative size we can choose from
index-max-len: length? form length? pack-list

print "-----------------------------------------------"
print ["Total available space:" available-space "KB"]
print "-----------------------------------------------"


fill-list: []
count: 0
size: 0
print "-----------------------------------------------"
print "Selected packs"
print "-----------------------------------------------"
while [available-space] [
  count: count + 1
  use [pack-index pack][
    pack-index: find-biggest available-space
    pack: pick pack-list pack-index/1
    either not none? pack [
      available-space: available-space - to-integer (pack/2 / 1000)
      size: size + pack/2
      pack/3: true
      append/only fill-list pack
      print [join right-align form count index-max-len ")" fill-tab right-align form pack/2 10 14 "." pack/1]
    ][
      break
    ]
  ]
]
print [join right-align "*" index-max-len ")" right-align form size 10 "bytes in used space"]

print "-----------------------------------------------"
print "Remaining packs"
print "-----------------------------------------------"
count: 0
size: 0
foreach pack pack-list [
  if not pack/3 [
    count: count + 1
    size: size + pack/2
    print [join right-align form count index-max-len ")" fill-tab right-align form pack/2 10 14 "." pack/1]
  ]
]
print [join right-align "*" index-max-len ")" right-align form size 10 "bytes in remaining space"]


