rebol [
   title: "SKIMP: Simple keyword index management program"
   author: "Sunanda"
   date: 23-apr-2007
   purpose: "Simple, fast way of indexing the text content of many documents"
   version: 0.0.2
   file: %skimp.r
   license: 'mit
   history: [
      [0.0.0 11-aug-2005 "Written"]
      [0.0.1  3-apr-2007 "Modified to use rse-ids.r and make-word-list.r"]
      [0.0.2 23-apr-2007 "Add flush-cache and flush-cache-all"]
   ]
   library: [
      level: 'intermediate
      platform: [all]
      type: [function tool package]
      domain: [files markup database]
      tested-under: [win unix mac]
      support: none
      license: [mit]
      see-also: [%rse-ids.r %make-word-list.r %skimp-tools.r]
      ]
   ]

if not value? 'rse-ids [do %rse-ids.r]  ;; Load rse-ids if not already there

skimp: make object!
[

;; =====================================
;; = Global settings                   =
;; = ---------------                   =
;; = Change the magic values here to   =
;; = alter skimp's over all settings   =
;; = ***                               =
;; = (to change behavior for a         =
;; =  specific index, use              =
;; =  skimp/set-config )               =
;; = ===================================

index-name-prefix: ""      ;; no prefix by default
index-name-suffix: ".sif"  ;; skimp index file

;; ===================================
;; = Public functions                =
;; = ----------------                =
;; = Call any or all of these to     =
;; = build or manage your index      =
;; ===================================

;; ========================================
index-exists?: func [
   index-name [file!]
][
  ;; An index exists:
  ;; * if it is in the cache
  ;;  (whether or not it has been ever
  ;;   written)
  ;; * Or the index header file exists
  ;;   on permanent storage.

   if find index-cache index-name [return true]
   return exists? to-file rejoin [index-name-prefix index-name index-name-suffix]
]



;; ========================================
get-index-information: func [
   index-name [file!]
   /document-list
   /local
   index-info
] [
   if not index-exists? index-name [return none] ;; no such index

   index-info: make object! [
      index-file: index-name
      top-index: copy []
      owner-data: none
      config: none
      word-parameters: none
      make-word-list: none
   ]

   _read-index-file index-name

   index-info/config: first reduce load/all mold cif/config
   index-info/owner-data: first reduce load/all mold cif/owner-data

   ;; Document list
   ;; -------------
   ;; Remembering to remove the "0" place-holders

   if document-list [
      index-info: make index-info [document-list: copy []]
      append index-info/document-list unique sort cif/document-list
      if find index-info/document-list 0 [alter index-info/document-list 0]
   ]

   ;; First letter list
   ;; -----------------
   ;; Create a block with all the
   ;; first letters of words indexed

   if 0 <> length? cif/word-index-block [
      foreach char cif/word-index-block/1 [
         append index-info/top-index to-string char
      ]
      sort index-info/top-index
   ]

   ;; Word parameter details
   ;; ----------------------
      index-info/word-parameters:  first reduce load/all mold cif/word-parameters
      index-info/make-word-list: get in cif 'make-word-list

   return index-info
]



;; ========================================
get-indexed-words: func [
   index-name [file!]
   index-char [char! string!]
   /document-list
   /local
    indexed-words
    current-word
    index-entry
] [
   if not index-exists? index-name [return none] ;; no such index
   if not string? index-char [index-char: to-string index-char]
   if 1 <> length? index-char [return none] ;; only one letter allowed

   indexed-words: copy []

   _read-index-file index-name

   if 0 = length? cif/word-index-block [return none] ;; no words indexed at all

   current-word: copy index-char
   lowercase current-word
   index-entry: find cif/word-index-block/1 current-word
   if not index-entry [return none] ;; no words with that one letter

   index-entry: 1 + index? index-entry

   _haul-in-entry cif/word-index-block index-entry current-word 1
   append indexed-words _extract-words current-word cif/word-index-block/:index-entry 1 document-list
   either document-list [
      sort/skip indexed-words 2
   ] [
      sort indexed-words
   ]
   return indexed-words

]


;; ========================================
get-indexed-words-for-document: func [
   index-name [file!]
   document-name [string! integer!]
   index-char [char! string!]
   /local
    doc-id
    current-word
    index-entry
] [
   if not index-exists? index-name [return none] ;; no such index
   if not string? index-char [index-char: to-string index-char]
   if 1 <> length? index-char [return none] ;; only one letter allowed

   indexed-words: copy []

   _read-index-file index-name

   if 0 = length? cif/word-index-block [return none] ;; no words indexed at all

   current-word: copy index-char
   lowercase current-word
   index-entry: find cif/word-index-block/1 current-word
   if not index-entry [return none] ;; no words with that one letter
   doc-id: _make-document-id/check document-name
   if not doc-id [return none]           ;; document is not in index

   index-entry: 1 + index? index-entry

   _haul-in-entry cif/word-index-block index-entry current-word 1
   append indexed-words _extract-words-for-document current-word cif/word-index-block/:index-entry 1 doc-id
   sort indexed-words

   return indexed-words

]







;; ========================================
get-indexed-document-names: func [
   index-name [file!]
   /local
    doc-list
][
   if not index-exists? index-name [return none] ;; no such index
   _read-index-file index-name

   doc-list: copy cif/document-list

   ;; Integer doc-names: simply
   ;; decompact the list
   ;; -------------------------

   if cif/config/integer-document-names [
      return _unpack-numset  doc-list
      ]

   ;; string doc-names: weed
   ;; out the zeroes first
   ;; ----------------------

   doc-list: unique sort doc-list
   if find doc-list 0 [alter doc-list 0]

   return doc-list

]





;; ========================================
write-cache: func [
   index-name [file!]
   /flush
   /local
   pointer
] [

   ;; Check we've got it first
   ;; ------------------------

   pointer: find index-cache index-name
   if none? pointer [return false] ;; not in memory, so nothing to do
   cif: first next pointer ;; make current item

   _write-index-file index-name

   if flush [
      remove pointer
      remove pointer
      cif: none
   ]
   return true ;; written back okay
]



;; ========================================
write-cache-all: func [
   /flush
] [
   ;; Writes *all* the indexes in the cache
   ;; -------------------------------------

   if flush [
      while [0 <> length? index-cache] [
         write-cache/flush index-cache/1
      ]
      cif: none
      recycle
      return true
   ]


   foreach [index-name index-file] index-cache [
      write-cache index-name
   ]
   return true
]




;; ========================================
flush-cache: func [
   index-name [file!]
   /flush
   /local
   pointer
] [

   ;; Check we've got it first
   ;; ------------------------

   pointer: find index-cache index-name
   if none? pointer [return false] ;; not in memory, so nothing to do

   cif: first next pointer ;; make current item
   remove pointer
   remove pointer
   cif: none

   return true ;; It's been flushed
]



;; ========================================
flush-cache-all: func [
   /flush
][
   ;; Flushes *all* the indexes in the cache
   ;; --------------------------------------
   cif: none
   recycle
   return true
]





;; ========================================
set-config: func [
   index-name [file!]
   con-set [object!]
   /defer
   /local
] [
   ;; Can only use if no words have been indexed
   ;; ------------------------------------------

   _read-index-file index-name

   if any [
      0 <> length? cif/document-list
      0 <> length? cif/word-index-block
   ] [
      make error! "SKIMP/set-config: cannot use on existing index"
      halt
   ]
   ;; =====================
   ;; TODO:  ADD VALIDATION
   ;; =====================
   foreach item next first con-set [
      error? try
      [set in cif/config to-word item get in con-set to-word item]
   ]

   ;; Set to working values, if crazy settings
   ;; ----------------------------------------
   ;; We'll do this until we add some proper validation

   if not integer? cif/config/index-levels [
      cif/config/index-levels: 3
   ]
   cif/config/index-levels: maximum 1 cif/config/index-levels
   if not logic? cif/config/integer-document-names [
        cif/config/integer-document-names: false
        ]
   if not logic? cif/config/one-file [
        cif/config/one-file: false
        ]

   if not defer [
      _write-index-file index-name
      ]

   return make object! third cif/config ;; ensure it's a copy not an updatable original

]



;; ========================================
set-owner-data: func [
   index-name [file!]
   owner-data-obj [object!]
   /defer
   /local
] [

   _read-index-file index-name

   cif/owner-data: first reduce load/all mold owner-data-obj

   if not defer [
      _write-index-file index-name
      ]

   return true

]






;; ======================================
set-word-definition: func [
    index-name [file!]
   /parameters parm-obj [object!]
   /make-word-list mwl [function! none! word!]
   /defer
   /local
    update-needed
  ][
    ;; set-word-defintions
    ;; ===================
    ;; Define or override the default
    ;; expectations of what a "word"
    ;; is.
    ;; Generally, this should be done
    ;; before adding any words to an index --
    ;; otherwise you may add things you cannot
    ;; later easily query.

   update-needed: false

   _read-index-file index-name


   if parameters [
          cif/word-parameters: make cif/word-parameters third parm-obj
          update-needed: true
         ]

   if make-word-list [
      cif/make-word-list: mwl
      either word? mwl [
           cif/make-word-list: get mwl
          ][
          if none? cif/make-word-list [  ;; minimal make-word-list function
             cif/make-word-list: get in skimp '_minimal-make-word-list
             ]
          ]

      update-needed: true
      ]

if all [update-needed not defer] [
   _write-index-file index-name ;; update the index
   ]

   return true
]

;; ======================================

find-word: func [
   index-name [file!]
   target [string!]
   /entry
   /local
   wb
   show-word
   tags
   short-tree
   res
   invert-needed?
] [


   invert-needed?: false
   if target/1 = #"~" [
      invert-needed?: true ;; we're doing a NOT search
      target: skip target 1 ;; slip past the tilde
   ]

   if 0 = length? target [return copy []] ;; find nothing


   _read-index-file index-name
   wb: cif/word-index-block

   set [short-word tags] _make-tags target



   for nn 1 length? tags 1 [
      set [short-tree wb] _find-tree-entry wb tags nn
      if short-tree [break]
      if none? wb [break]
   ]



   if none? wb [;; word not found
      return _map-to-doc-names _invert-list invert-needed? copy []
   ]

   res: select wb short-word
   if not block? res [res: reduce [res]]

   if entry [return _map-to-doc-names _invert-list invert-needed? res]

   if none? res [return _map-to-doc-names _invert-list invert-needed? copy []] ;; word not found

   return _map-to-doc-names _invert-list invert-needed? res
]



;; ==========================================
find-words: func [
   index-name [file!]
   targets [block!]
   /local
   hits
   seq
] [

   ;; -------------------------------
   ;; Finds all the words, assumed to
   ;; be connected by an AND
   ;; --------------------------------
   hits: copy []

   seq: 0
   foreach target targets [
      seq: seq + 1
      hits: _and-results hits
      find-word index-name target
      seq

   ]
   return unique hits

]



;; ==================================
remove-document: func [
   index-name [file!]
   document-name [string!]
   /defer ;; don't write back
   /local
   documents
] [
;; Just a courtesy wrapper for remove documents
;; --------------------------------------------
 documents: copy []
 append documents document-name
 either defer [
    remove-documents/defer index-name documents
   ][
    remove-documents index-name documents
   ]

return true
]



;; ==================================
remove-documents: func [
   index-name [file!]
   document-name-list [block!]
   /defer ;; don't write back
   /local
   temp
   doc-id-list
   starting-word-index
] [

   _read-index-file index-name

   doc-id-list: copy []
   foreach doc-name document-name-list [
        if  _make-document-id/check doc-name [
          append doc-id-list _make-document-id doc-name
          ]
       ]
   doc-id-list: sort unique doc-id-list


   if 0 = length? doc-id-list [return true] ;; we don't have those document-names on file
                                            ;; so there is nothing to remove

   if 0 = length? cif/word-index-block [   ;; no words indexed at all ...
                                    ;; ... not sure this can happen
      foreach doc-name doc-id-list [
         _remove-document-id doc-name
         ]
      return true
   ]


   ;; Capture starting word index
   ;; ---------------------------
   starting-word-index: copy cif/word-index-block/1


   ;; Make sure all top levels are hauled in
   ;; --------------------------------------

   for nn 1 length? cif/word-index-block/1 1 [
      _haul-in-entry cif/word-index-block nn + 1 to-string cif/word-index-block/1/:nn 1
   ]

   _remove-level cif/word-index-block 1 doc-id-list


   foreach doc-name document-name-list [
       _remove-document-id doc-name
      ]


   ;; design oversight here: we don't know
   ;; which of the subfiles we removed words
   ;; from....So set things so they are
   ;; all updated


   foreach letter unique join starting-word-index cif/word-index-block/1 [
      letter: to-string letter
      if not find cif/admin/dirty-tags letter [alter cif/admin/dirty-tags letter]
   ]


   if not defer [_write-index-file index-name]

   return true
]





;; ==================================
remove-index: func [
   index-name [file!]
][

;; Remove index
;; ============
;; Deletes an index entirely.
;; We're using a lazy/slow
;; method:
;; 1. set all index files to empty
;; 2. write the cache -- that will
;;    delete all files except the header
;; 3. delete the header file

if not index-exists? index-name [return true]  ;;  no such index

_read-index-file index-name

if not 0 = length? cif/word-index-block [
   foreach tag cif/word-index-block/1 [
     append cif/admin/dirty-tags to-string tag
     ]
   cif/admin/dirty-tags: unique cif/admin/dirty-tags
   cif/word-index-block/1: copy ""
   write-cache/flush index-name
  ]

delete to-file rejoin [index-name-prefix index-name index-name-suffix]
return true

]


;; ==================================
extract-words-from-string: func [
   index-name [file!]
   words [string! block!]
  /for-search
][
 ;; extract-words-from-string
 ;; =========================
 ;; An interface to the make-word-list
 ;; function saved in the index header
 ;; that changes strings into
 ;; a block of words.
 ;; Useful for testing, especially
 ;; if you write your own function

 if block? words [return words]  ;; nothing to do

_read-index-file index-name

either for-search [
    return do [cif/make-word-list/for-search cif/word-parameters words]
][
    return do [cif/make-word-list cif/word-parameters words]
]
]




;; ==================================
add-words: func [
   index-name [file!]
   document-name [string! integer!]
   words [block! string!]
   /defer ;; no index update at end
   /local
   add-list
   e-id
   new-word? ;; new word indexed for this document
] [

   _read-index-file index-name

   ;; Get the unique list of words
   ;; that we are going to add
   ;; ----------------------------

   either block? words [
      add-list: copy words  ;; block: their words are taken literally
   ][
      add-list: copy []
      append add-list do [cif/make-word-list cif/word-parameters words]
   ]

   add-list: unique add-list

   if find add-list copy "" [alter add-list copy ""] ;; can't index the null string
   if 0 = length? add-list [return true] ;; nothing to do

   ;; Let's go and add them
   ;; ---------------------

   doc-id: _make-document-id document-name

   foreach w add-list [
      _add-a-word w doc-id
   ]


   if not defer [_write-index-file index-name]

   return true
]

;; ==================================
add-bulk-words: func [
   index-name [file!]
   data-block [block!]
   /defer
   /local
   all-words
   inverted-list
   new-word? ;; new word indexed for this document
   temp
   doc-ids
   db
] [

   _read-index-file index-name

   ;; ensure all documents are in word format
   ;; ----------------------------------------
   ;; ie  ["doc-1" "this are my words" ...] becomes
   ;;     ["doc-1" ["these" "are" "my" "words"] ...]


   for nn 1 length? data-block 2 [
      if not block? pick data-block nn + 2 [
          poke data-block nn + 1 do [cif/make-word-list cif/word-parameters pick data-block nn + 1]
          ]
      ]

   ;; Strip out any empty word lists
   ;; ------------------------------

   db: make block! length? data-block
   foreach [file block] data-block [
      if 0 <> length? block [
         append db file
         append/only db block
      ]
   ]


   ;; Ensure each block entry is unique
   ;; --------------------------------
   temp: 0
   all-words: copy []
   for nn 2 length? db 2 [

      poke db nn sort unique db/:nn
      temp: temp + length? db/:nn
      append all-words db/:nn
   ]


   ;; Convert document names to their doc-ids
   ;; ---------------------------------------
   doc-ids: make block! length? db ;; could be half the length
   foreach [document-name words] db [
      append doc-ids _make-document-id document-name
   ]


   all-words: unique sort all-words

   ;; Now invert the list
   ;; -------------------
   inverted-list: make block! (2 * length? all-words)
   foreach w all-words [
      temp: copy []
      append inverted-list form w
      for nn 2 length? db 2 [
         if w = db/:nn/1 [
            insert temp pick doc-ids (nn / 2) ;; document id
            poke db nn next db/:nn
         ]
      ]
      append/only inverted-list temp
   ]


   ;; Sort inverted list so common words are first
   ;; --------------------------------------------

;;   error? try [;; fails on some earlier versions
;;      sort/skip/all/compare inverted-list 2
;;      func [a b] [
;;         if (length? a/2) > length? b/2 [return -1]
;;         if (length? a/2) < length? b/2 [return +1]
;;         if a/1 < b/1 [return 1]
;;         if a/1 > b/1 [return -1]
;;         return 0 ;; how did we get here?
;;      ]
;;  ]




   foreach [word document-list] inverted-list [
      if 0 <> length? word [;; can't index the null word
         _add-a-word word document-list
      ]
   ]



   if not defer [_write-index-file index-name]


   return true
]






;; ===================================
;; = Private stuff                   =
;; = ----------------                =
;; = DON'T call or mess with any of  =
;; = these, unless you are doing     =
;; = your own development            =
;; ===================================


;; ----------
;; data areas
;; ----------

cif: none ;; current index file
current-file-name: none
index-cache: copy []



;; =======================================================
_read-index-file: func [
   index-name [file!]
][

   ;; -------------------------------
   ;; Results in the index file being
   ;; in cif.
   ;; If the index file does not
   ;; exist, a new one is created.
   ;; -------------------------------

   current-file-name: copy index-name

   ;; Read from cache, if possible
   ;; ----------------------------
   cif: select index-cache index-name
   if not none? cif [return true]

   ;; Read from file, if possible
   ;; ---------------------------
   if not error? try [
       cif: first reduce load/all decompress
             read/binary to-file rejoin [index-name-prefix index-name index-name-suffix]
       ][
      insert index-cache cif
      insert index-cache index-name
      return true
   ]

   ;; Create a new one
   ;; ----------------
   ;; Note we don't write the empty file --
   ;; that's done after the first update
   ;; operation, or when a user use a
   ;; write-cache[-all]/flush operation.


   cif: make object! [
      owner-data: make object! []
      admin: make object! [
         last-updated: now/precise
         dirty-tags: copy [] ;; for multiple files: parts that have changed
      ]
      config: make object! [
         index-levels: 3 ;; number of higher-level index layers
         ;; (there will always be one bottom-level index layer)
         integer-document-names: false  ;; ie they are strings
         one-file: false ;; ie is multiple files
      ]

      word-parameters: make object! [
      alpha: charset [#"a" - #"z" #"A" - #"Z"]
      digit: charset [#"0" - #"9"]
      initial-letter: alpha
      letter: union alpha union digit charset ["~"]
      number: union digit charset [".,"]
      number-prefix: charset ["+-£$¢"]
      number-postfix: charset ["+-"]
      word-length: 1x40
      not-prefix: "~"
      stop-list: []
      ignore-tags: false
      index-pairs: true
      final-letter: charset ["!" "?"]
      hyphen: charset ["-_"]
    ]
      make-word-list: get-make-word-list


      document-list: copy []      ;; document-ids

      word-index-block: copy []          ;; indexed words / highest level index
   ]

   insert index-cache cif
   insert index-cache index-name
   return true

] ;; func





;; =======================================================
_write-index-file: func [
   index-name [file!]
   /local
    pointer
    temp-cif
    nn
    file-name
][
   cif: select index-cache index-name
   if none? cif [return false] ;; file is not current, so nothing to write

   cif/admin/last-updated: now/precise

   ;; add file if not in cache
   ;; ------------------------
   pointer: find index-cache index-name
   if none? pointer [
      insert index-cache cif
      insert index-cache index-name
      return true
   ]

   ;; Write it -- as a single file
   ;; ----------------------------

   if cif/config/one-file [
      cif/admin/dirty-tags: copy []
      write/binary to-file rejoin [index-name-prefix index-name index-name-suffix]
                   compress mold cif
      return true
   ]

   ;; Write it -- as a set of files
   ;; -----------------------------

   ;;    Empty file?
   ;;    -----------

   if 0 = length? cif/word-index-block [
      write/binary to-file rejoin [index-name-prefix index-name index-name-suffix]
                   compress mold cif
      return true
   ]

   ;;       Build a CIF that has everything except the
   ;;       word-index-block (we don't do a straight object
   ;;       clone on account of the potential size of
   ;;       the thing)

   temp-cif: make object! []
   foreach entry next first cif [
      if entry <> 'word-index-block [
         temp-cif: make temp-cif reduce [to-set-word entry none]
         set in temp-cif entry get in cif entry
      ]
      temp-cif: make temp-cif [word-index-block: none]
   ]
   temp-cif/word-index-block: copy []

   append temp-cif/word-index-block cif/word-index-block/1 ;; node index
   for nn 1 length? cif/word-index-block/1 1 [
      append temp-cif/word-index-block none] ;; entries
   if _has-leaf-node cif/word-index-block [
      append/only temp-cif/word-index-block last cif-word-index-block/1] ;; node, if there is one (shouldn't be at this level)



   ;; Write first-character files
   ;; ---------------------------

   foreach tag cif/admin/dirty-tags [
      file-name: to-file rejoin [index-name-prefix index-name "-" to-integer tag/1 index-name-suffix]
      either nn: find cif/word-index-block/1 tag [
         nn: 1 + index? nn
         write/binary file-name compress mold cif/word-index-block/:nn
      ] [
         error? try [delete file-name]
      ]
   ]

   temp-cif/admin/dirty-tags: copy []
   cif/admin/dirty-tags: copy []

   write/binary to-file rejoin [index-name-prefix index-name index-name-suffix]
                compress mold temp-cif
   return true

] ;; func



;; =================================================
_make-document-id: func [
   document-name [string! integer!]
   /check
   /local
   doc-id
   find-res
] [
   ;; ---------------------------
   ;; Returns the position of the
   ;; document name in the cif
   ;; ----------------------------

   if cif/config/integer-document-names  [
      ;; This is simple: we use the user's value directly
      ;; ------------------------------------------------
      ;; Though it must be a positive integer, or
      ;; things later will fail very badly

      if any [
         not integer? document-name
         document-name < 1
         ][
         make error! rejoin ["SKIMP: id must be a positive integer..." document-name]
         halt
         ]

      find-res: _find-packed cif/document-list document-name
      if all [check find-res] [return true] ;; it exists already
      if find-res [return document-name] ;; already exists
      if check [return false] ;; does not exist & is just a check


      ;; create a new entry
      ;; ------------------
      doc-id: document-name
      _insert-packed cif/document-list document-name
      return doc-id
   ]


   ;; Need (perhaps) to make a new one
   ;; --------------------------------

   doc-id: find cif/document-list form document-name
   if not none? doc-id [
      return index? doc-id ;; simple: it exists already
   ]


   ;; Just a check on existence?
   ;; --------------------------

   if check [return none] ;; not an existing document

   ;; document doesn't exist ....
   ;; --------------------------

   ;; reuse an empty slot
   ;; ------------------
   if doc-id: find cif/document-list 0 [
      doc-id/1: form document-name
      return index? doc-id
   ]



   ;; Let's make a new one
   ;; --------------------

   append cif/document-list form document-name ;; document-name
   return length? cif/document-list

]



;; =================================================
_remove-document-id: func [document-name [string! integer!]
   /local
   pointer
] [
   ;; ---------------------------
   ;; Deletes an existing
   ;; document name in the cif
   ;; ----------------------------


   ;; Deal with external-doc-id
   ;; ----------------------

   if cif/config/integer-document-names  [
      if find cif/document-list document-name [
         alter cif/document-list document-name
      ]
      return true
   ]

   ;; Deal with internal-doc-id
   ;; ----------------------

   pointer: find cif/document-list form document-name

   if none? pointer [;; doesn't exist already (shouldn't happen)
      return true
   ]

   pointer/1: 0 ;; doesn't exist any more

   ;; trim trailing zeroes
   ;; --------------------
   ;; trailing zeroes just waste space
   ;; on the document list while giving
   ;; us nothing of any use.

   while [
      all [0 <> length? cif/document-list
         0 = last cif/document-list
      ]
   ] [
      remove back tail cif/document-list
   ]
   return true
]




;; ==============================================
_make-word-block: func [word [string!]
   /local wb
   initial
   initial-offset
   wl-entry
   tags
   short-word
   short-tree
] [

   wb: cif/word-index-block
   set [short-word tags] _make-tags word

   for nn 1 length? tags 1 [
      set [short-tree wb] _make-tree-entry wb tags nn

      if short-tree [break]
      if none? tags/:nn [break]
   ]

   return reduce [short-word tags wb]

]


;; ==========================================
_make-tags: func [word [string!]
   /local
   tags
   tag
   shortened-word
] [
   ;; --------------------------------
   ;; The config/index-levels define a tree
   ;; structure. Means we don't have to
   ;; store those letters as they are
   ;; can be recovered.
   ;; eg if the config/index-levels is 3:
   ;; It means take the first letter,
   ;; three times.  So "AMEND" is
   ;; stored in a tree three deep,
   ;; and we only need to store the
   ;; "ND"
   ;; A --> M --> E  ["ND" [1x34]]

   tags: copy []
   shortened-word: copy word

   for nn 1 cif/config/index-levels 1 [
      tag: none
      error? try [tag: first shortened-word]

      shortened-word: copy next shortened-word
      if not none? tag [
         tag: to-string tag
      ]
      append tags tag
   ]

   return reduce [shortened-word tags]

]

;; ==========================================

_has-leaf-node: func [wb [block!]
] [
   if 0 = length? wb [return false]
   return (2 + length? wb/1) = length? wb
]


;; ==========================================
_find-tree-entry: func [
   wb [block!]
   tags [block!]
   nn [integer!]
   /local
   ti
   target
] [

   if 0 = length? wb [return reduce [true none]]

   ti: find wb/1 tags/:nn
   if not none? ti [
      _haul-in-entry wb (1 + index? ti) tags/1 nn
      return reduce [false first at wb (1 + index? ti)] ;; return existing entry
   ]

   if none? tags/:nn [
      if not _has-leaf-node wb [
         return reduce [true none]
      ]

      return reduce [true first at wb length? wb] ;; return existing leaf entry
   ]
   return reduce [true none]
]



;; ==========================================

_haul-in-entry: func [
   wb [block!]
   offset [integer!]
   tag [string!]
   level [integer!]
   /local
   index-segment
] [

   ;;     ------------------------------
   ;;     If the top level of an index
   ;;     is not in memory, haul it in
   ;;     ----------------------------


   if any [level <> 1 ;; only haul top levels
      'none <> wb/:offset ;; and only of none
   ] [
      return true ;; nothing to do
   ]

   index-segment: first reduce
           load/all decompress
               read/binary to-file rejoin [index-name-prefix current-file-name "-" to-integer tag/1 index-name-suffix]



   poke wb offset index-segment
   return true
]

;; ==========================================
_make-tree-entry: func [
   wb [block!]
   tags [block!]
   nn [integer!]
   /local
   ti
] [

   if 0 = length? wb [insert wb copy ""] ;; null level index

   ti: find wb/1 tags/:nn
   if not none? ti [
      _haul-in-entry wb (1 + index? ti) tags/1 nn
      return reduce [false first at wb (1 + index? ti)] ;; return existing entry
   ]

   if none? tags/:nn [
      if not _has-leaf-node wb
      [
         append/only wb copy []
      ]

      return reduce [true first at wb length? wb] ;; return existing leaf entry
   ]

   ;; New level tag
   ;; -------------

   append wb/1 tags/:nn
   insert/only at wb 1 + length? wb/1 copy []
   return reduce [false first at wb 1 + length? wb/1]

]


;; ==============================================
_add-a-word: func [
   word [string!]
   doc-id [integer! block!]
   /local
   w-block ;; word block
   w-entry ;; word entry
   short-word
   temp
   unpacked-doc-ids
   res
   tags

] [
   set [short-word tags w-block] _make-word-block lowercase word

   ;; We got the word block, ie w-block
   ;; is positioned at something like:
   ;; ["mile" [1 7 5] "mite" [668 433] "mitten" 55  ]


   ;; set the index entry as dirty, so it will be saved later
   ;; -------------------------------------------------------
   if not find cif/admin/dirty-tags tags/1 [alter cif/admin/dirty-tags tags/1]


   ;; Now we find the entry for the word we want
   ;; ------------------------------------------
   word-entry: find/skip w-block short-word 2
   if none? word-entry [
      ;; The entry we want does not exist
      ;; --------------------------------
      ;; We are either adding a single integer
      ;; for a new word, or a block of
      ;; integers:
      ;; "snickers" 45
      ;; "snickers" [30 12 49 26]

      append w-block short-word
      temp: copy []
      foreach e either block? doc-id [doc-id] [reduce [doc-id]] [_insert-packed temp e]
      append/only w-block temp
      return true ;; we've added a new word

   ]


   ;; We are now pointing at an existing word
   ;; entry, eg:
   ;;
   ;; ["snickers" [1 3x6 8x19]]

   temp: copy []
   foreach e either block? doc-id [doc-id] [reduce [doc-id]] [_insert-packed word-entry/2 e]
   return true ;; we've added a new word


]



;; ==========================================
_map-to-doc-names: func [
   doc-ids [block! integer! pair!]
   /local
   ent-block
] [
   if not block? doc-ids
   [doc-ids: reduce [doc-ids]]


   doc-ids: _unpack-numset doc-ids

   if cif/config/integer-document-names  [return doc-ids]

   ent-block: make block! length? doc-ids

   foreach e doc-ids [
      insert ent-block pick cif/document-list e
   ]

   return ent-block
]




;;    =======================================
_unpack-numset: func [
   doc-id-block [block!]
] [
   return rse-ids/decompact doc-id-block
]




;;  ==================================
_pack-numset: func [doc-id-block [block!]
] [
   return rse-ids/compact doc-id-block
]



;; ===============================================
_find-packed: func [
   blk [block!]
   target [integer!]
] [
   return rse-ids/find-compact blk target
]


;; ===================================================
_insert-packed: func [
   blk [block!]
   new-entry [integer!]
] [

   return rse-ids/insert-compact blk new-entry

]



;; ==================================
_remove-packed: func [
   entry [block!]
   doc-id [integer!]
   /local
   new-wb
] [
   rse-ids/remove-compact entry doc-id
   return entry
]


;; ===========================================

get-make-word-list: func [
  /local
][
    ;; Supply a minimal dummy function if we
    ;; have no access to make-word-list.r function
if not exists? %make-word-list.r [
   return get in skimp '_minimal-make-word-list
   ]

 do %make-word-list.r
 return :make-word-list
]


;; ===========================================

_minimal-make-word-list: func [
   parms        ;; could be any type -- we don't check
   string [string!]
  /for-search
][
;; Minimal function needed to parse a
;; string into a set of words
   return unique sort parse/all trim/lines copy string " "
]



;; ========================================
_extract-words: func [
   current-word [string!]
   wb [block!]
   level [integer!]
   document-list [logic! none!]
   /local
   word-list
   doc-list
][
  ;; Extract words
  ;; =============
  ;; Returns all the words in the index
  ;; that begin with the first letter
  ;; of the supplied current-word
  ;; Optionally (with document-list
  ;; parameter) also returns
  ;; the document names that
  ;; contain each word.

   word-list: copy []
   if document-list [doc-list: copy []]

   ;; Handle lowest-level index
   ;; -------------------------
   if level = cif/config/index-levels [
      foreach [word index] wb [
         append word-list join current-word word
         if document-list [append/only word-list sort _map-to-doc-names _unpack-numset index]
      ]
      return word-list
   ]


   ;; Handle higher-level indexes
   ;; ---------------------------

   for nn 1 length? wb/1 1 [
      append word-list
          _extract-words
           join current-word wb/1/:nn
           pick wb nn + 1
           level + 1
           document-list
   ]
   if _has-leaf-node wb [
      append word-list current-word
      if document-list [append/only word-list sort _map-to-doc-names _unpack-numset last last wb]
   ]
   return word-list
]


;; ========================================
_extract-words-for-document: func [
   current-word [string!]
   wb [block!]
   level [integer!]
   doc-id [integer!]
   /local
   word-list
][
  ;; Extract words-for-document
  ;; ==========================
  ;; Returns all the words in the index
  ;; that begin with the first letter
  ;; of the supplied current-word that
  ;; are indexed for the given doc-id

   word-list: copy []

   ;; Handle lowest-level index
   ;; -------------------------
   if level = cif/config/index-levels [
      foreach [word index] wb [
         if rse-ids/find-compact index doc-id [append word-list join current-word word]
      ]
      return word-list
   ]


   ;; Handle higher-level indexes
   ;; ---------------------------

   for nn 1 length? wb/1 1 [
      append word-list
          _extract-words-for-document
           join current-word wb/1/:nn
           pick wb nn + 1
           level + 1
           doc-id
   ]
   if _has-leaf-node wb [
      if rse-ids/find-compact first next last wb doc-id [append word-list current-word]

   ]
   return word-list
]



;; ===========================================================
_invert-list: func [
   invert-needed? [logic!]
   res [block!]
   /local
   all-doc-ids
] [
   if not invert-needed? [return res]



   ;; handle doc names are integers
   ;; -----------------------------

   if cif/config/integer-document-names  [
      return difference _unpack-numset res _unpack-numset cif/document-list
      ]


   ;; Handle doc names are strings
   ;; ----------------------------


   all-doc-ids: make block! length? cif/document-list
   repeat nn length? cif/document-list [
      if 0 <> cif/document-list/:nn [;; ignore deletion placeholders
         insert all-doc-ids nn
      ]
   ]
   return difference _unpack-numset res all-doc-ids
]


;; ===================================

_and-results: func [
   prev-hits [block!]
   new-hits [block!]
   seq [integer!]
] [

   ;; ANDs later results to the results set

   if seq = 1 [
      return copy new-hits
      return
   ]

   return intersect prev-hits new-hits

]




;; ==================================
_remove-level: func [
   wb [block!]
   level [integer!]
   doc-ids [block!]
   /local
   pointer
   removed
   temp
] [

   if 0 = length? wb [return true] ;; can this happen!?

   ;; Remove any leaf node entry
   ;; --------------------------


   if _has-leaf-node wb [
      temp: second last wb
      foreach doc-id doc-ids [_remove-packed temp doc-id]
      poke last wb 2 temp
      if ["" []] = last wb [  ;; empty leaf
         remove back tail wb
         if 1 = length? wb [
            clear wb
            return true
         ]
      ]
   ]


   ;; Recurse downwards to the bottom for most removal work
   ;; ------------------------------------------------------

   if level <> cif/config/index-levels [
      for nn 1 length? wb/1 1 [
         _remove-level first at wb (nn + 1) level + 1 doc-ids
      ]
      _remove-empties wb
      return true
   ]


   ;; Main removal job
   ;; ----------------

   ;; Step 1
   ;;
   ;; we're positioned on something like this:
   ;;   ["abc"
   ;;       ["ct" [3] "dd" [3 5] ]          "act" and "add"
   ;;       ["at" [3x6] "et" [3x2 89x2] ]   "bat" and "bet"
   ;;       ["am" [3] "og" [3] ]            "cam" and "cog"
   ;;   ]
   ;;
   ;; So, as the next step, we step through those inner blocks
   ;; and remove the doc-id.  If we are removing doc-id 3, then this
   ;; structure will become
   ;;
   ;;   ["abc"
   ;;       ["dd" [5] ]                  "act" gone
   ;;       ["at" [4x5] "et" [4 89x2] ]  "bat" and "bet"
   ;;       []                           "cam" and "cog" both gone
   ;;   ]

   ;;
   ;; See Step 2 for sorting out the empty block left by"cam" and "cog"



   for nn 1 length? wb/1 1
   [nn: nn + 1

      pointer: head wb/:nn
      loop (length? wb/:nn) / 2 [
         foreach doc-id doc-ids [_remove-packed pointer/2 doc-id]
         either all [block? pointer/2 0 = length? pointer/2] [
            remove pointer
            remove pointer
         ] [
            pointer: next next pointer
         ]
      ]

   ]



   ;; Step 2
   ;; ------
   ;; Something like:
   ;;   ["abc"
   ;;       [dd" [5] ]                   "add"
   ;;       ["at" 4x5 "et" [4 89x2] ]    "bat" and "bet"
   ;;       []                            empty c entry
   ;;   ]

   ;; Must become:
   ;;   ["ab"                            c gone
   ;;       [dd" [5] ]                   "add"
   ;;       ["at" [4x5] "et" [4 89x2] ]    "bat" and "bet"
   ;;   ]

   _remove-empties wb



   ;; Step 3
   ;; ------


   if 1 = length? wb [clear wb] ;; removes stray [""]

   if 0 = length? wb [return true]


   return true

]


;; ==================================
_remove-empties: func [
   wb [block!]
   /local removed
] [

   forever [
      removed: false
      for nn 1 length? wb/1 1 [

         nn: nn + 1
         if any [0 = length? wb/:nn
            all [1 = length? wb/:nn "" = wb/:nn/1]
         ] [
            removed: true
            remove at wb nn
            alter wb/1 to-string pick wb/1 nn - 1
            break ;; so the loop can restart
         ]
      ] ;; for
      if not removed [break] ;; no more forever loop
   ] ;; forever


   ;; Check if leaf node is empty
   ;; ===========================
   if all [_has-leaf-node wb
      0 = length? last wb] [
      remove at wb length? wb
   ]


   return true

]


] ;;  skimp object
