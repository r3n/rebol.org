REBOL [
  Title: "Recursively scan directory"
  File: %scan-dir.r
  Date: 11-Oct-2007
  Author:  "Henrik Mikael Kristensen"
  Owner:   "HMK Design"
  Rights:  "Copyright (C) HMK Design 2005"
  Purpose: {
    Scans a directory recursively and returns path to all files in a block. Allows file matching and a callback function per file.
  }
  Library: [
    level: 'intermediate
    platform: 'all
    type: [tool]
    domain: [files]
    tested-under: [View 1.3.2.3.1 under WindowsXP REBOL 2.99.3.3.1 under WindowsXP]
    support: "See my website at http://www.hmkdesign.dk/rebol/ for more scripts and my R2/R3 blog"
    license: 'bsd
    see-also: none
  ]
]

scan-dir: func [
  "Scans a directory recursively and returns path to all files in a block"
  root-dir [file!]
  /match file-match [file! string! block!] "Matches only given files"
  /callback callback-func
    "Performs function on file. Current file is the argument"
  /absolute "Absolute path instead of relative"
  /local file-block match-func scan-func
] [
  unless all [exists? root-dir equal? #"/" last root-dir] [return none]
  file-block: make block! []
  match-func: func [file [file!] match-val [file! string! block!]] [
    switch to-word type? match-val [
      file! [file = match-val]
      string! [found? find file match-val]
      block! [
        foreach f match-val [if match-func file f [break/return true]]
      ]
    ]
  ]
  scan-func: func [dir /local files] [
    files: read dir
    foreach file files [
      either equal? #"/" last file [
        scan-func root-dir: root-dir/:file
      ][
        if any [
          not match
          all [
            match
            any [
              empty? file-match
              match-func file file-match
            ]
          ]
        ] [
          insert tail file-block either absolute [
            to-file reduce [what-dir root-dir file]
          ][
            root-dir/:file
          ]
        ]
        if callback [do :callback-func root-dir/:file]
      ]
    ]
    root-dir: first split-path root-dir
    file-block
  ]
  scan-func root-dir
]