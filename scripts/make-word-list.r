REBOL[
  Title: "make-word-list"
  Version: 1.0.0
  Date: 2-Apr-2007
  Author: Peter W A Wood
  Copyright: {Copyright© PWA Wood 2007}
  File: %make-word-list.r
  Purpose: {Makes a list of words from a string}
  License: 'mit
  Library: [
    level: 'beginner
    platform: [all]
    type: [package function tool]
    domain: [files markup database]
    tested-under: [win mac]
    support: none
    license: [mit]
  ]
]

make-word-list: function
[
  {Makes a list of words from a string}
  config [object! none!]
    {Configuration options to be used instead of the default ones}
  content [string!]
    {The content from which the words are to be extracted}
  /for-search
    {The requested word list is being built to perform a search}
][
  word
    {An individual word from the content}
  word-list
    {The list of words for indexing}
  make-words-parse
    {A object in which to store the parse rules}
  ][
    
  make-words-parse: make object!
  [
    ;; default bitsets
    alpha: charset [#"a" - #"z" #"A" - #"Z"]
    digit: charset [#"0" - #"9"]
    alpha-or-digit: union alpha digit
    letter: union alpha-or-digit charset ["~"]
    no-character: charset []
    hex-digit: union digit charset [#"a" - #"f" #"A" - #"F"]
    hyphen: charset ["-_"]
    word-start: alpha
    word-letter: letter
    word-end: charset ["!" "?"]
    number: union digit charset [".,"]
    number-prefix: charset ["+-£$¢"]
    number-postfix: charset ["+-"]
    not-prefix: "~"
    
    ;; other default settings
    word-length: 1x40
    ignore-tags: false
    index-pairs: true
    stop-list: ["a" "is" "the"]
    word-list-length: 2000
    months: [ "jan" "feb" "mar" "apr" "may" "jun" 
              "jul" "aug" "sep" "oct" "nov" "dec"
    ]
    day-suffix: ["th" "st" "rd"]
    
    ;; apply supplied configuration changes
    if object! = type? config
    [
      foreach item next first config 
      [
        error? try
          [set in self to word! item get in config to word! item]
      ]
    ]
    
    ;; convert stop-list to a hash
    stop-list: to hash! stop-list
    
    ;; word definitions
    a-word: [word-start any word-letter opt word-end]
    a-hyphenated-word:
      [a-word hyphen some word-letter any [hyphen | word-letter]]
    either not-prefix
    [
      a-not-word: [not-prefix a-word]
    ][
      a-not-word: no-character              ;;effectively deactiviates the rule
    ]
    a-tag: ["<" thru ">"]
    a-closing-tag: ["</" thru ">"]
    a-number: [opt number-prefix digit any number opt number-postfix]
    a-hex-number: [[digit] any #"x" any hex-digit]
    a-tuple: [some digit #"." some digit #"." some digit]
    a-rebol-pair: [opt "-" some digit #"x" opt "-" some digit]
    a-dotted-word: [word-start any word-letter #"." 
                    word-start any [word-letter | #"."] ]                
    a-slashed-word: [word-start any word-letter #"/" 
                     word-start any [word-letter | #"/"]]
    a-back-slashed-word: [word-start any word-letter backslash
                          word-start any [word-letter | backslash]]
    a-rebol-binary-string: ["#{" thru "}"]
    a-rebol-base64-string: ["64#{" thru "}"]
    a-rebol-debase: ["debase" any [" " | newline] "{" thru "}"]
    an-html-escaped: ["&" thru ";"]
    eg: ["e.g" opt "." | "E.G" opt "."]
    a-scheme: [word-start any word-start "://" opt "www."]
    
    ;; specification of a web page address
    a-web-page-address:
    [
      a-dotted-word #"/" word-start 
      any [word-letter | #"/"]
      any [ #"." any word-letter]
    ]
    
    ;; specification of an email address
     an-email-address: [word-start any [word-letter | #"."]  #"@" 
               word-start any word-letter #"." any [word-letter | #"."]]
    
    ;; charsets to speed skipping over unwanted portions of the content
    start-chars: copy [#"<" #"#"]
    if not-prefix
      [append start-chars to-char not-prefix]
    if index-pairs
      [append start-chars #"-"]
    start-chars: charset start-chars
    start-chars: union start-chars union word-start digit
    not-start-char: complement start-chars
    skip-to-next-possible-word: [some not-start-char]
    
    ;; the specification of a date
    ;; first build the day suffix list
    either 0 = length? day-suffix
    [
      a-day-suffix: [""]                
    ][
      ;; build the block of day-suffixes
      a-day-suffix: copy []
      foreach abbr day-suffix
      [
        append a-day-suffix abbr
        append a-day-suffix to-word "|"
      ]
      remove back tail a-day-suffix           ;; remove extraneous | at the end
    ]
    
    ;; build a definition of month abbreviation
    a-month-abbr: copy []
    foreach month months
    [
      append a-month-abbr month
      append a-month-abbr to-word "|"
    ]
    remove back tail a-month-abbr           ;; remove extraneous | at the end
    
    a-date:
    [
      ;; rebol date with alpha month
      [ [1 2 digit] #"-" a-month-abbr [any letter] #"-" [2 4 digit] ]
      |
      ;; rebol date with numeric month
      [ [1 2 digit] #"-" [ 1 2 digit] #"-" [ 2 4 digit] ]
      | 
      ;; date with alpha month
      [ [1 2 digit] #" " a-month-abbr [any letter] #" " [2 4 digit] ]
      |
      ;; dd/mm/yyyy  mm/dd/yyyy (numeric)
      [ [1 2 digit] slash [1 2 digit] slash [1 4 digit] ]
      |  
      ;; yyyy/mm/dd (numeric)
      [ [1 4 digit] slash [1 2 digit] slash [1 2 digit] ]
      |
      ;; date of types 1st June 2000; 3rd June 2000 or 15th June
      ;; this rule will also add phrases such as 21st Century to the word list
      [ [1 2 digit] a-day-suffix #" " [3 letter any letter]
        any [#" " 2 4 digit] ]
    ]
    
    ;; a set of definitions and rule to try to create a rebol format date from
    ;; a date that meets the a-date definition
    a-year-first-date: [ copy yy [4 digit] skip copy mm [1 2 digit] skip 
                              copy dd [1 2 digit]
    ]
    
    a-year-last-date: [
      copy dd [1 2 digit] skip 
      [
        [copy mm [3 letter] [any letter]] | 
        [copy mm [ 1 2 digit] ]
      ] skip
      copy yy [2 4 digit]
    ]
    
    a-day-suffix-date: [
      copy dd [1 2 digit] a-day-suffix #" " copy mm [3 letter] [any letter]
      #" " copy yy [2 4 digit]
    ]
    
    make-rebol-date-rule: [
      [a-year-first-date | a-year-last-date | a-day-suffix-date]
      (
        ;; check to see if there is a match with alpha month abbr
        if mmm: find months lowercase mm
        [
          ;; convert the alpha to a month number
          mm: index? mmm
        ]
        
        if not error? try [mmm: to integer! mm] ;; genuine month?
        [
          if mmm > 12
          [
            ;; swap dd and mm
            swap: mm
            mm: dd
            dd: swap
          ]
          
          ;; try to create a Rebol date
          date-str: join dd ["-" mm "-" yy]
        
          if attempt [date-str: to date! date-str]
          [
            _xadd word-list lowercase to string! date-str
          ]
        ]
      )
    ]
    
    ;; word-in-date-rule
    word-in-date-rule:
    [
      any 
      [
        [1 2 digit] a-day-suffix   ;; this rule ignores 1st, 15th etc.
        |
        copy word-in-date a-word
        (
          _xadd word-list lowercase word-in-date
        )
        |
        skip
      ]
    ]
    
    ;; date rule
    date-rule: 
    [
      copy date a-date
      (
        ;; add the date to the list in its current form
        _xadd word-list lowercase date
        
        ;; try to create a rebol date as well
        parse/all date make-rebol-date-rule
       
        ;; add any words in the date
        parse/all date word-in-date-rule
      )
    ]
    
    ;; word-rule - add a genuine word to the word-list
    word-rule:
    [
      copy word a-word
      (
        _xadd word-list lowercase word
      )
    ]
    
    ;; not-word-rule - remove the "not prefix" from the start of a word 
    ;; unless the for-search refinement is set
    not-word-rule: 
    [
      copy not-word [a-not-word]
      (
        if not for-search [remove not-word]
        _xadd word-list lowercase not-word
      )
    ]
    
    ;; tag rule
    tag-rule:
    [
      copy word a-tag
      (
        if not ignore-tags
        [
          ;; strip off <
          remove word
          ;; strip off >
          remove back tail word
          ;; now re-parse the remaining content
          parse/all word rule
        ]
      )
    ]
    
    ;; dotted-word rule - used for domain names and qualified variable names
    dotted-word-rule:
    [
      copy dotted-word a-dotted-word
      (
        ;; add each "level" of the dotted-word to the list
        ;; eg www.rebol.com will result in the following being added :
        ;;  www.rebol.com
        ;;  rebol.com
        ;;  com
        
        ;; if the last character is a "." remove it
        while
        [
          #"." = last dotted-word
        ]
        [
          remove back tail dotted-word
        ]
        _add-word-hierarchy dotted-word "."
      )
    ]
    
    ;; slashed-word rule - used for domain names and qualified variable names
    slashed-word-rule:
    [
      copy slashed-word a-slashed-word
      (
        ;; add each "level" of the slashed-word to the list
        ;; eg apps/rebolcore/rebol will result in the following being added :
        ;;  apps/rebolcore/rebol
        ;;  rebolcore/rebol
        ;;  rebol
        
        ;; if the last character is a "/" remove it
        while 
        [
          #"/" = last slashed-word
        ]
        [
          remove back tail slashed-word
        ]
        _add-word-hierarchy/with-individual-words slashed-word "/"
      )
    ]
    
    ;; back-slashed-word rule - used for domain names and qualified variable names
    back-slashed-word-rule:
    [
      copy back-slashed-word a-back-slashed-word
      (
        ;; add each "level" of the back-slashed-word to the list
        ;; eg apps\rebolcore\rebol will result in the following being added :
        ;;  apps\rebolcore\rebol
        ;;  rebolcore\rebol
        ;;  rebol
        
        ;; if the last character is a backslash remove it
        while
        [
          backslash = last back-slashed-word
        ]
        [
          remove back tail back-slashed-word
        ]
        _add-word-hierarchy/with-individual-words back-slashed-word backslash
        
      )
    ]
    
    ;; hyphenated-word rule
    ;; add each level of the hyphenated word and all the sub-words (if they are
    ;; valid words)
    hyphenated-word-rule:
    [
      copy hyphenated-word a-hyphenated-word
      (
        ;; if the last characters are hyphens remove them
        while 
        [
          parse to string! last hyphenated-word [hyphen]
        ]
        [
          remove back tail hyphenated-word
        ]
        ;; use the first hyphen found as the separator
        parse hyphenated-word
        [
          copy this-hyphen [a-word hyphen]
         
          ;; add the different levels of hierarchy and the individual words to
          ;; the list
          
          (
            this-hyphen: last this-hyphen
            _add-word-hierarchy/with-individual-words hyphenated-word
                                                      this-hyphen
          )
        ]
      )
    ]
    
    web-page-address-rule:
    [
      copy web-words a-web-page-address
      (
        ;; add each "level" of the web-page to the list
        ;; eg www.rebol.com/downloads.html will result in 
        ;; the following being added :
        ;;  www.rebol.com/downloads.html
        ;;  rebol.com
        ;;  com
        ;;  downloads
        
        ;; split off the domain name and process it
        parse copy/part web-words find web-words "/" dotted-word-rule
        remove/part web-words find/tail web-words "/"
        
        ;; extract valid words from the remainder ingnoring part after dot
        parse web-words 
        [
          any
          [
            copy sub-word a-word
            (
              _xadd word-list lowercase copy sub-word
            )
            |
            "/"
            |
            ["." a-word]
          ]
        ]
      )
    ]
    
    ;; Rebol pair rule
    ;; include rebol pairs in the wordlist if the index-pairs is true in the 
    ;; configuration object
    either index-pairs
    [
      rebol-pair-rule:
      [
        ;; add rebol-pairs to word-list
        copy rp a-rebol-pair
        (
          parse/all rp 
          [
            copy reb-pair a-rebol-pair
            (_xadd word-list reb-pair)
          ]
        )
      ]
    ][
      ;; ignore rebol-pairs
      rebol-pair-rule: no-character           ;; nothing can be selected
    ]
  
    ;; prefix-word-rule - strip of specified prefix and the word to word-list
    prefix-word-rule: 
    [
      copy prefix-word a-prefix-word
      (
        _xadd word-list lowercase next prefix-word
      )
    ]
    
    ;; e.g. rule - adds e.g. and e.g. to the words-list
    eg-rule:
    [
      copy eg-word eg
      (
        _xadd word-list lowercase eg-word
      )
    ]
    
    ;; rebol debase rule - adds the word debase and ignores the binary string
    rebol-debase-rule:
    [
      a-rebol-debase
      (
        _xadd word-list "debase"
      )
    ]
    
    ;; the main rule
    rule: 
    [
      any
      [
        skip-to-next-possible-word
        |
        an-email-address                              ;; ignore email adresses
        |
        hyphenated-word-rule
        |
        a-scheme                                        ;; ignore http:// etc
        |
        web-page-address-rule
        |
        eg-rule
        |
        dotted-word-rule
        |
        slashed-word-rule
        |
        back-slashed-word-rule
        |
        rebol-debase-rule
        |
        word-rule
        |
        date-rule
        |
        rebol-pair-rule
        |
        a-rebol-base64-string                         ;; ignore Rebol base64
        |
        a-rebol-binary-string                         ;; ignore Rebol binary 
        |
        a-tuple                                       ;; ignore tuples
        |
        [digit a-word]                                ;; ignore words starting
        |                                             ;; with a numeric digit
        a-hex-number                                  ;; ignore hex numbers
        |
        a-number                                      ;; ignore complete numbers
        |
        a-closing-tag                                 ;; ignore closing tags
        |
        not-word-rule
        |
        tag-rule
        |
        an-html-escaped               ;; ignore "escaped" html
        |
        skip
      ]
    ]
  _xadd: function
    [
      {exclusive add - add an element if the block doesn't already contain it}
      hsh [hash!]
      element
    ][
      len                                     ;; the length of the element
    ][
      ;; don't add:
      if any
      [
        ;; duplicates
        find hsh element
        ;; words in the stop-list
        find stop-list element
        ;; words greater than the maximum length required
        (len: length? element) > second word-length
        ;; words shorter than the minimum length required
        len < first word-length
      ][
        return
      ]
          
      ;;add the element
      insert hsh element
     
    ]
  
    _add-word-hierarchy: function
    [
      {adds the words from a hierarchy of words, each level being identified by 
       a specified separator. E.g. www.rebol.com will result in the following 
       being added to the word-list:
          ;;  www.rebol.com
          ;;  rebol.com
          ;;  com
      }
      word-hier [string!]
      separator [char! string!]
      /with-individual-words
        {stores any valid individual word in the hierarchy}
    ][
      ind-word
       "An individual word in the hierarchy"
    ][
      _xadd word-list copy lowercase word-hier
      until
      [
        if with-individual-words
        [
          parse word-hier
          [
            copy ind-word a-word
            (_xadd word-list lowercase ind-word)
          ]
        ]
        ;; strip off the first part of the hierarchy
        remove/part word-hier find/tail word-hier separator
        ;; add the hierarchy if it's first char is a letter
        if true = parse to string! first word-hier [word-start]
        [
          _xadd word-list copy lowercase word-hier
        ]
        none = find word-hier separator
      ]
    ]    
  ] ;; end make-words-parse
  
  ;; create the ouput block
  word-list: make hash! make-words-parse/word-list-length
  
  ;; parse the content
  parse/all content make-words-parse/rule
  
  ;; finally sort the list
  return sort to-block word-list
  
]