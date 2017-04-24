rebol [
   file: %application-sizer.r
   title: "Estimate size of a REBOL application"
   date: 6-dec-2008
   Author: "Sunanda"
   Version: 0.0.3
   History: [
        0.0.0 1-dec-2008 "initial release"
        0.0.1 3-dec-2008 "various improvements (see documentation)"
        0.0.2 4-dec-2008 "/csv and /config refinements (see documentation)"
        0.0.3 6-dec-2008 "/preprocess refinement (see documentation)"
        ]
   ]

;; Documentation is here:
;; ---------------------
   http://www.rebol.org/documentation.r?script=application-sizer.r

app-sizer: make object! [

    ;; configuration/installation options
    ;; ----------------------------------
 configuration: make object! [
         app-name: "No name"               ;; The name of your application
      app-version: "None"                  ;; The version of your application
      app-folders: %./                     ;; folders to search (use block if more than one)
    exclude-files: [%application-sizer.r]  ;; files to ignore
  source-suffixes: [%.r]                   ;; what's a script?
      add-header?: false                   ;; do they all have headers?
    minimal-chars: "{}[]"                  ;; lines with only these are ignored
    csv-file-name: %application-sizer.csv  ;; csv file name
    ]

  configuration-reset: construct/with [] configuration

  files-seen: copy []
    all-data: copy ""
    app-data: make object! [
        app-sizer-version: 0.0.2
                 run-date: now/date
                 app-name: configuration/app-name
              app-version: none
                  folders: 0
                    files: 0
                raw-bytes: 0.0
          compressed-size: 0.0
                raw-lines: 0.0
               code-lines: 0.0
                 elements: make object! [
                             string: [0 0.0]  ;; occurances + total length
                           datatype: [0 0.0]
                             number: [0 0.0]
                         refinement: [0 0.0]
                           function: [0 0.0]
                           operator: [0 0.0]
                             native: [0 0.0]
                             action: [0 0.0]
                             object: [0 0.0]
                              image: [0 0.0]
                            comment: [0 0.0]
                               body: [0 0.0]
                         whitespace: [0 0.0]
                     ]
      element-definitions: none            ;; inverted from color-code/colors
     ]

  init-app-data:  first reduce load mold app-data

  pp-func: none                           ;; preprocessing function


;; ============================================================
;; color-coder and color-code
;; --------------------------
;; adapted from Carl's color
;; coding script in the Library.
;; We use them to characterise
;; the parts of a script. Originals
;; are here:
;; http://www.rebol.org/view-script.r?script=color-code.r
;; ============================================================

color-coder: make object! [

    ; Set the color you want for each datatype:
    colors: sort/skip [
         char!          "string"
         date!          "datatype"
         decimal!       "number"
         email!         "string"
         file!          "string"
         integer!       "number"
         issue!         "datatype"
         money!         "datatype"
         pair!          "datatype"
         string!        "string"
         tag!           "string"
         time!          "datatype"
         tuple!         "datatype"
         url!           "string"
         refinement!    "refinement"
         cmt            "comment"

    ] 2
    out: copy []
    text: none

    emit: func [data] [repend out data]

    emit-color: func [value start stop /local color][
        either none? :value [color: select colors 'cmt][
            if path? :value [value: first :value]
            color: either word? :value [
                any [
                    all [value? :value image? get :value "image"]
                    all [value? :value action? get :value "action"]
                    all [value? :value op? get :value "operator"]
                    all [value? :value object? get :value "object"]
                    all [value? :value native? get :value "native"]
                    all [value? :value any-function? get :value "function"]
                    all [value? :value datatype? get :value "datatype"]
                ]
            ][
                any [select colors type?/word :value]
            ]
        ]
        text: copy/part start stop
        either color [
            emit [ to-word color text 'whitespace
                ]

        ][
            emit ['body text 'whitespace]    ;; something else
        ]
    ]



]


 color-code: func [
        "Return color source code as HTML."
        text [string!] "Source code text"
        /local str new value temp
    ][
        color-coder/out: copy []

        set [value text] load/next/header detab text
        color-coder/emit copy/part head text text
        spc: charset [#"^(1)" - #" "] ; treat like space
        parse/all text blk-rule: [
            some [
                str:
                some spc new: (color-coder/emit copy/part str new) |
                newline (color-coder/emit newline)|
                #";" [thru newline | to end] new:
                    (color-coder/emit-color none str new) |
                [#"[" | #"("] (color-coder/emit first str) blk-rule |
                [#"]" | #")"] (color-coder/emit first str) break |
                skip (
                    set [value new] load/next str

                   color-coder/emit-color :value str new
                ) :new
            ]
        ]
       return color-coder/out
    ]






   run: func [
;; ========================================
   /config user-config [object!]
   /csv
   /preprocess pp-function [function!]
   /local
   cap-err
][

          ;; Initialise the configuration object
          ;; -----------------------------------
 either config [
        configuration: construct/with third user-config configuration-reset
      ][
       configuration: construct/with [] configuration-reset
      ]

           ;; initialise the preprocessing function
           ;; -------------------------------------
 pp-func: func [        ;; do nothing function for default
     folder [file!]
       name [file!]
     scr [string!]
][
   return scr
 ]
 if preprocess [
     pp-func: :pp-function         ;; user supplied function
     ]

           ;; Initialise the app-data object
           ;; ------------------------------
 app-data: first reduce load mold init-app-data
 app-data/app-version: configuration/app-version
 app-data/app-name: configuration/app-name
 app-data/element-definitions: copy []
 foreach [element type] color-coder/colors [
   either none? ptr: select app-data/element-definitions type [
            insert/only app-data/element-definitions reduce [element]
            insert app-data/element-definitions type
        ][
            append ptr element
        ]
   ]
 sort/skip app-data/element-definitions 2

           ;; Reset other data areas
           ;; ----------------------
 all-data: make string! 512000
 files-seen: copy []



           ;; Count the files!
           ;; ----------------
 if not block? configuration/app-folders [
     configuration/app-folders: reduce [configuration/app-folders]
     ]

 foreach folder configuration/app-folders [
   app-data/folders: app-data/folders + 1
   foreach file read folder [
      if error? cap-err: try [
         handle-file folder file
         ][
          print ["app-sizer: problem with "
                 clean-path join folder file "..."
                 mold disarm cap-err
                ]
          ]
      ]
   ]

 app-data/compressed-size: length? compress trim/lines all-data
 all-data: none


    ;; Emit a CSV if requested
    ;; -----------------------
    ;; Header row written for new
    ;; file, otherwise we add a new
    ;; row for these results

 if csv [
   if not exists? configuration/csv-file-name [
      write-csv-header
      ]
    write-csv-data
  ]


 return app-data
]



   handle-file: func [
;; =========================================
    folder [file!]
      file [file!]
   /local
    target-file-name
    file-contents
    file-lines
    cs
    post-processed
    nn
][
    ;; Handles one file
    ;; ----------------
    ;; File may be expanded into more than one
    ;; by the preprocessing.

  target-file-name: join folder file

    ;; Ignore if not a proper target
    ;; -----------------------------
 if dir? target-file-name [return true]                                ;; no subfolder search, yet
 if not find configuration/source-suffixes suffix? file [return true]  ;; wrong suffix
 if find configuration/exclude-files file [return true]                ;; excluded file



 file-contents: read target-file-name

           ;; do not count if it is a duplicate file
           ;; --------------------------------------
  if find files-seen checksum/secure file-contents [return true]



           ;; Run preprocessing
           ;; -----------------
           ;; This may expand the file to more than one file
  post-processed: do reduce [pp-func folder file file-contents]

  if none? post-processed [return true]       ;; preprocess says ignore

           ;; Size each file
           ;; resulting from the
           ;; preprocessing
           ;; ---------------------

  if not block? post-processed [
      post-processed: reduce [post-processed]
      ]

  nn: 0
  foreach target-script post-processed [
     nn: nn + 1      ;; for error messages

            ;; ignore if already seen
            ;; ----------------------
     if not find files-seen cs: checksum/secure target-script [
         append files-seen cs

           ;; add a header if:
           ;; 1. needed
           ;; 2. add-header option is enabled
           ;; -------------------------------

         if configuration/add-header? [
            if error? try [load/header target-script] [
               insert target-script {REBOL [] ^/}
               print ["app-sizer: header added to [" nn "] " clean-path target-file-name]
               ]
            ]


           ;; count the file
           ;; --------------

         append all-data target-script
         file-lines: parse/all target-script to-string newline

         app-data/files: app-data/files + 1
         app-data/raw-bytes: app-data/raw-bytes + length? target-script
         app-data/raw-lines: app-data/raw-lines + length? file-lines

         count-code-lines file-lines
         count-elements target-script
      ]
   ]
 return true
]



   count-code-lines: func [
;; ====================================
   file-lines [block!]
][
           ;; bumps a count for lines
           ;; that are not blank, or minimal
           ;; ------------------------------

 foreach line file-lines [
    trim/all line
    if all [
         "" <> line                                        ;; ignore blank
         #";" <> line/1                                    ;; ignore comment
         "" <> exclude line configuration/minimal-chars    ;; ignore if only minimal chars
         not all [find configuration/minimal-chars line/1  ;; something like "] ;end of func"
              line/2 = #";"
             ]

         ][
          app-data/code-lines: app-data/code-lines + 1
          ]
   ]
 return true
]




   count-elements: func [
;; ====================================
   script [string!]
   /local
    latest-type
    target
][
           ;; uses color-code to
           ;; analyse the script and
           ;; count its various elements
           ;; ---------------------------

 latest-type: 'whitespace

 foreach item app-sizer/color-code script [
    either word? item [
      latest-type: item
      target: get in app-data/elements latest-type
      poke target 1 target/1 + 1                  ;; one more of this type
     ][
      if char? item [item: to-string item]
      target: get in app-data/elements latest-type
      poke target 2 target/2 + length? item       ;; total length of this type
      ]

    ]
  return true
]


   write-csv-header: func [
;; ==========================
   /local rec
][
 rec: copy ""
 foreach [label value] flatten-app-data-object [
    append rec mold label
    append rec ","
   ]
 rec: copy/part rec (length? rec) - 1
 write/lines configuration/csv-file-name rec
 return true
]


   write-csv-data: func [
;; ==========================
   /local rec
][
 rec: copy ""
 foreach [label value] flatten-app-data-object [
    append rec value
    append rec ","
   ]
 rec: copy/part rec (length? rec) - 1
 write/lines/append configuration/csv-file-name rec
 return true
]


  flatten-app-data-object: func [
;; =================================
   /recurs prefix target
   /local
    data
    item-value
][
 data: copy []
 either recurs [
    prefix: join prefix "-"
   ][
    prefix: copy ""
    target: app-data
    ]

 foreach item next first target [
    item-value: get in target item
    either object?  item-value [
       append data flatten-app-data-object/recurs form item item-value
   ][
      either block? item-value [
       for nn 1 length? item-value 1 [
          append data rejoin [prefix to-string item "-" nn]
          append data form item-value/:nn
          ]
      ][
       append data rejoin [prefix to-string item]
       append data form get in target item
      ]
    ]
 ]
 return data
]

]
