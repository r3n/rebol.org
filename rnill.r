REBOL [
    Title:  "RNILL - REBOL Non Intelligent Language Learner"
    Author: "Allen Kamp"
    Email:  rebol@optushome.com.au
    Date:   22-Jun-2000
    File:  %rnill.r
    Version: 1.0.4
    History: [1.0.2 [
        22-Jun-2000 {Cleaned up, fixed local declarations, hopefully more GC freindly} 
        "Allen K" ]
        1.0.3 [23-Jun-2000 {Found Hash Crash bug in Rebol and added work around} "Allen K" ]
        1.0.4 [7-Jul-2000 {For absolute safety removed all use of Hash!} "Allen K" ]
    ]
    Purpose: {
        RNILL a REBOL implementation of a non intelligent language learner
        inspired by NIALL (Non Intelligent Amos Language Learner by
        Mathew Peck 1990).
    }
  Library: [
     level: 'intermediate
     platform: 'all
     type: [demo]
     domain: [ai]
     tested-under: none
     support: none
     license: none
     see-also: none
   ]

    Comment: {
    RNILL is a fun chatter-bot:
    Just type what ever comes into your head, RNILL learns sentence structure
    from what you type. RNILL starts off knowing nothing (unlike Melissa
    or Eliza), so at first he may just repeat your sentences.
    Type in jokes, stories, obscure comments, whatever you like, or use the
    'read' command to read in texts.
    But be warned sometimes RNILL's replies will be spookily accurate.
    }
    Category: [games]   
]

;---Constants and Switches
data-file: %RNILLData.txt

;---Turn on or off welcome text and getting user name.
welcome-on: true 

Preformatted-Words: [
"I" "I'll" "I'd" "I'm" "I've" "RNILL" "REBOL" "PC" "UNIX" "Amiga" "HTML"
"Australia" "UK" "USA" "Japan"
]

;---End Constants and Switches


;---Init Tables
Dictionary: make block! 1000
Stats: make block! 1000 
Relations: make block! 1000 

;---now called stats, relationships and dictionary

;---Load Tables
if exists? %RNILLData.txt [
    last-chat: modified? data-file
    Data: load %RNILLData.txt
    Dictionary: to-block copy Data/1
    Stats: copy Data/2
    Relations: copy Data/3
    unset 'data
]

welcome-user: func [
    /local sentence
][
    ;---Welcoming sentences, also fed into RNILL learning process.
    user: ask {Hello my name RNILL, what is your name? }
    append preformatted-words copy user ; retain name formatting.
    user-prompt: rejoin [user " > "] 
    sentence: rejoin ["Hello " user]
    print ["RNILL >" sentence]          
    ;---may as well learn this sentence too
    RNILL-learns sentence 

    either not exists? data-file [
        sentence: {Please tell me something about yourself}
    ][
        sentence: {It is good to talk to someone again}
    ]  

    print ["RNILL >" sentence]
    ;---may as well learn this sentence too
    RNILL-learns sentence
]

input-loop: func [/local sentence data] [

    while [true] [
            sentence: ask user-prompt
        switch/default sentence [
            "Quit" [
                ;Save RNILL Data on exit
                print ["^/Goodbye" User 
            {it has been nice chatting with you.}]
                statistics/RNILL-info/stats-only
                data: copy []
                insert/only tail data dictionary
                insert/only tail data stats
                insert/only tail data relations 
                save data-file data 
                break ;quit out of loop/end program
            ]
            "?" [statistics/RNILL-info]
            "Read" [
                file: to-file ask {> Read Filename ? }
                try [either exists? file [sentence: read file]
            [Print "Read File Error..." sentence: ""]]
                if (sentence <> "") [
                Prin {Reading File...}
            RNILL-Learns sentence
            Print "Done"
                ] 
            ]
        ][
        ;---Default evaluate and build dictionary
            RNILL-Learns sentence 
            prin "RNILL > "
            prin reply/create-quote
            prin newline
       ]
    ]
    exit
]

;---Process Sentences

RNILL-Learns: func [
    paragraph [string!] {Sentence string to learn from}
    /local words
][
    words: copy []
    ;---Prepare Block of Ordered Words 
    ;---Paragraph -> Block of Sentences -> Block of words
   foreach sentence parse/all paragraph {.?!}[
        trim/with sentence "," ;remove commas
        trim sentence ; remove beginning or trailing spaces
        ;---Add Sentence Begin Marker 
        sentence: join "|- " [sentence]
        words: parse sentence none
        ;--- Assess Word block
        build-dictionary words
        build-relationships words
   ]
    exit
]

build-dictionary: func [
sentence-blk
/local word-id counter found

] [

    foreach word sentence-blk [
        either found? found: find Dictionary word [
            ;---Update Known word, increment # times used 
            word-id: index? found
            counter: pick Stats word-id
            poke Stats word-id (counter + 1)
        ][
            ;---Add New Word
            append Dictionary format-word word
            append Stats 1 ; Word Usage Count
            ;---Insert empty series, to be 
            ;---filled later by build-relations
            insert/only tail Relations make block! []
        ] 
    ]
    exit
]


build-relationships: func [
   sentence
   /local i count preword postword preword-id postword-id found relation-blk  relation-stat
][
    relation-blk: copy []
    repeat i length? sentence [
        preword: pick sentence i
        postword: pick sentence (i + 1)
       ;---Use index as ID
        preword-ID: index? found: find dictionary preword
      ;---find relations entry block for preword
       relation-blk: pick relations preword-ID 
 
        either postword <> none [
        ;---Get PostWord-ID
            postword-ID: index? found: find dictionary postword 
        ][
            postword-ID: -1  ; End of Sentence ID
        ] 

     either found? relation-stat: select relation-blk postword-ID [
            ;---Increment Relation count 
            count: relation-stat/1
            change relation-stat (count + 1)
        ][
            ;---Add New Relation Entry
            append relation-blk Postword-ID ; relation entry id
            ;---Set Relation Count to 1
            insert/only tail relation-blk make block! [1] 
        ]
    ] 
    Exit
]

; Rewritten after errors found in v2.2
format-word: func [
    string [any-string!]
    /local pre-formatted result
][
    result: copy ""
    pre-formatted: copy ""

    either found? pre-formatted: find preformatted-words string [
        result: copy first pre-formatted
    ] [
        result: lowercase copy string
    ]
    return result
]
;---End Process Sentences


;--RNILL Reply Functions

reply: make object! [ 
    rnd: func [
        {Return a random integer between min and max values inclusive}
        min-val [integer!]
        max-val [integer!]
    ][
        min-val - 1 + random (max-val - min-val + 1)
    ]
    
    fill-line: func [
        {Fills reply-blk with a sentence ready for formatting}
        word-Id [integer!]
        reply-blk [block!]
        /local relation-blk weight goal-weight chosen-word-id word-str
    ][
        relation-blk: copy []
        word-str: copy []
        weight: 0
        chosen-word-id: -1  ; End of Sentence as default.

        ;--goal-weight: random word usage count
        goal-weight: random stats/:word-id
 
        foreach [relation frequency] relations/:word-id [
            weight: weight + first frequency
            if (weight >= goal-weight) [
                chosen-word-id: relation
                break
            ]
        ]      
        either chosen-word-id <> -1 [
            word-str: copy pick dictionary chosen-word-id
            ;---Capitalise first-letter-first-word. 
            if word-id = 1 [uppercase/part word-str 1]
            append reply-blk copy word-str
            fill-line chosen-word-id reply-blk ;recurse
        ][
           exit
        ]    
    ]

    format-reply: func [
        words-min [integer!] {Min words in sentence}
        words-max [integer!] {Max words in sentence}
        lines-min [integer!] {Min lines in reply}
        lines-max [integer!] {Max lines reply}
        /term line-term [string!]  {What to terminate the line with e.g "^/". Default is ". "}
        /local out line-length line count lines
    ][
        if not term [line-term: copy ". "]
        count: 0
        lines: rnd lines-min lines-max
        out: copy []

        while [count < lines][
            line: copy []
            fill-line 1 line
            line-length: length? line 
            if all [line-length >= words-min line-length <= words-max][
                append out copy join line [line-term]
                count: count + 1
            ]
        ]
        return out
    ]

    create-quote: func [/local reply][
        form format-reply/term 4 12 1 1 "^H. "
    ]
]


;--RNILL Stat Functions 
statistics: make object! [
    count-words: func [
        {Returns the total number of words in RNILL's dictionary}
        /local count
    ][
        ;---Remove start sentence maker from count
        count: (length? stats) - 1
        if count < 0 [count: 0]
        return count
    ]

    count-sentences: func [
        {Returns the total number of sentences RNILL has analysed}
        /local count
    ][
        count: pick stats 1
        if count = none [count: 0]
        return count
    ]

    count-relationships: func [
        {Returns the total number of word relationships in RNILL's dictionary}
        /local count
    ][
        count: 0
        foreach stat stats [count: count + stat]
        return count
    ]

    RNILL-info: func [{Shows RNILL Info}
        /stats-only {Shows only Stats part of the info}
    ][
        ;---Header
        if not stats-only [
        
        ;prin "^(page)"
            print ""
            print {+------------------------------------------------------+}
            print {|  RNILL - The REBOL Non-Intelligent Language Learner  |}
            print {+------------------------------------------------------+}
        ]   
    
        ;---Stats
        print ""
        print {======================Statistics=======================+}
        print [{                Sentences |} count-sentences]
        print [{                    Words |} count-words]
        print [{            Relationships |} count-relationships]
        print {+------------------------------------------------------+}
        print ""
    
        ;---Footer
        if not stats-only [
            print {+------------------------------------------------------+}
            print {| To Exit: enter Quit     |     To View Stats: enter ? |}
            print {|                         |                            |}
            print {| To learn a text file: enter Read (and follow prompt) |}
            print {+------------------------------------------------------+}
       ]
    ]
]
;--End RNILL stat Functions

;---Begin---
random/seed now
prin "^(page)"
statistics/RNILL-info
either welcome-on [welcome-user] [user-prompt: {User > } user: ""]
input-loop
halt

