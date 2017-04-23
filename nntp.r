REBOL [
    Title: "REBOL news Protocol $Revision: 1.8 $"
    Date: 16-Mar-2001/3:14:05
    Version: 1.8.0
    File: %nntp.r
    Author: "Jeff Kreis"
    Purpose: "Read and post news articles"
    Email: jeff@rebol.com
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [other-net web tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

net-watch: off

;-- Header for use to post -------------------------------------

generic-post-header: make object! [

    ;-- You'll have to answer host and email every 
    ;   time until they are defined in your user.r.  
    Path: reform [
        either found? system/schemes/default/host [
            system/schemes/default/host 
        ][
            system/schemes/default/host: ask "Please enter your host name:"
        ] "!" either found? system/user/email [
            system/user/email
        ][
            system/user/email: to-email ask "Please enter your email address:"
        ]
    ]
    Sender: Reply-to: from: system/user/email
    Subject: none    ;-- filled in with first line of post
    Newsgroups: none ;-- either user of protocol fills this in
    Message-ID: none ;-- filled in by protocol
    Organization: "REBOL-Usenet-service"
]

;-- other header fields include: --------------------------------
; Followup-To: Distribution: Keywords: 
;          Summary: Approved: 
; as well as all sorts of X-whatevers: 
;
; These may be included if someone clones
; one of the generic-post-headers.
;----------------------------------------------------------------

news-protocol: make Root-Protocol [
    "REBOL Network News Port."
    
    ;------ Internals -------------------------------------------

    scheme: 'news
    port-id: 119
    port-flags: system/standard/port-flags/pass-thru
    
    ;-- Checks
    open-check:      [none    "20"]  
    close-check:     ["QUIT" "205"]
    group-check:     [none   "211"]
    list-check:      ["LIST" "215"]
    listgroup-check: [none   "211"]
    head-check:      [none   "221"]
    body-check:      [none   "222"]
    article-check:   [none   "220"]
    post-check:      ["POST"   "3"]  
    done-post-check: ["."      "2"]
    authorize-check: [none    "28"]

    result: make block! 10000 ;-- all work done in buffers
    buf: make string! 10000  

    ;-- The states of the machine
    _HEAD:       1
    _BODY:       2
    _ARTICLES:   3
    _XHDR:       4
    _HEAD-BODY:  5
    _NEWSGROUPS: 6
    _POST:       7
    _COUNT:      8
    _OTHERWISE:  100

    ;-- Some common error messages
    sorry:  "I can only do one request at a time. Sorry"
    sorry2: "Conflicting directives.  Does not compute. Sorry."

    ;-- We'll need this for posting
    user-name: copy/part system/user/email find system/user/email "@"
    
    state: 0            ;-- initial state

    ; Info to keep track of
    noisy: zero-articles: cross-post: keep-M-ID: false   
    newsCaps: x-what: howdey: which-articles: 
    which-groups: find-content: to-post: post-header: none

    ;-- These are what get interpreted 
    ;   if present in the inserted block
    commands: [verbose post x-post of capabilities? 
               newsgroups articles from to help keep-ID

               headers bodies headers-bodies 
               with using please wouldya count] 

    ;---- Utility functions -------------------------------------

    reset-myself: func [
        "Things that need to be reset each time"
    ][
        ;-- some other internal values are
        ;-- also reset per function usage, such as
        ;-- zero-articles, the flag to signal an empty
        ;-- newsgroup.
        set in news-protocol 'state 0
        foreach item [which-articles which-groups x-what
                      find-content to-post post-header][
            set in news-protocol item none
        ]

        foreach item [noisy zero-articles cross-post keep-M-ID][
            set in news-protocol item false
        ]
        clear buf  ;-- also cleared in 'get-content and 'open
    ]

    error: func [
        "Something's fouled up.  Error message and exit"
        str [string! block!] "Error string/block"
    ][
        print form str
        reset-myself
        halt
    ]

    filtrate: func [
        { Return true (ie. go ahead and insert into result) 
          if we're not filtering or filter based on our search criteria }
        line [string!] "Possible search item"
    ][
        either found? find-content [
            foreach item find-content [
                if found? find line item [
                    return true
                ]
            ]
            return false
        ][true]
    ]

    smush-time: func [
        { Smush time makes a big number out of the current time.  
          Used for message-ID }
    ][
        rejoin [first now second now third now first fourth now 
                second fourth now third fourth now]
    ]

    add-commas-nls: func [
        "Add commas to the newsgroups line"
        string-block [block!] /local ix
    ][
        if (length? string-block) < 2 [string-block]
        forall string-block [ 
            either any[(ix: index? string-block) = 1 tail? string-block][][
                system/words/insert string-block "," 
                string-block: next string-block
                if (ix // 9) = 0 [ ;-- Five groups per line
                    system/words/insert string-block "^/ "
                    string-block: next string-block
                ]
            ]
        ]
        string-block: head string-block
    ]

    get-new-message-id: func [
        "Returns a new message ID"
    ][
        rejoin ["<" smush-time random 99999 "." user-name "@"
                system/schemes/default/host ">"]
    ]
    
    ;---- Dialect Functions -------------------------------------

    please: wouldya: none  ;-- just for fun
    
    help: func [
        "Returns the command dialect"
    ][
        state: _OTHERWISE
        print ["I know these words:" newline]
        for i 1 (length? commands) 1 [
            prin [form system/words/pick commands i " "]
            if (i // 5) = 0 [print ""]
        ]
    ]

    keep-ID: func [][
        keep-M-ID: true
    ]

    count: func [
        "count articles in a group"
    ][
        state: _COUNT
    ]

    capabilities?: func [
        "Return what help reports on server"
    ][
        state: _OTHERWISE
        append result newsCaps
    ]


    verbose: func [
        "Be annoyingly verbose"
    ][
        noisy: true
    ]

    xhdr: func [
        { If available, xhdr retrieves different header 
          fields  over a supplied range }
        what [string! block!]
    ][
        either state = 0 [
            either string? what [x-what: what][
                x-what: rejoin what
            ]
            state: _XHDR
        ][error sorry]
    ]

    articles: func [
        "Retrieve articles"
    ][
        either state = 0 [
            state: _ARTICLES
        ][error sorry]
    ]

    headers: func [
        "Retrieve headers"
    ][ 
        either state = 0 [
            state: _HEAD
        ][error sorry]
    ]

    bodies: func [
        "Retrieve bodies"
    ][
        either state = 0 [
            state: _BODY
        ][error sorry]
    ]

    headers-bodies: func [
        "Retrieve headers and bodies separately"
    ][
        either state = 0 [
            state: _HEAD-BODY
        ][error sorry]
    ]

    newsgroups: func [
        "Get newsgroup list"
    ][
        either state = 0 [
            state: _NEWSGROUPS
        ][error sorry]
    ]

    post: func [
        "Post a message"
        what [string!] "The article to post"
    ][
        either state = 0 [
            state: _POST
            to-post: what
        ][error sorry]
    ]

    x-post: func [
        "Cross post a message"
        what [string!] "The article to post"
    ][
        cross-post: true
        post what
    ]

    using: func [
        "Use a passed in header object to post"
        header-obj [object!] "The header object to use"
    ][
        post-header: header-obj
    ]

    of: func [
        "Use article numbers or message IDs"
        arts [block! string!] "This is the article numbers"
    ][
        either block? arts [which-articles: arts][
            which-articles: reduce [arts]
        ]
    ]
    
    to: from: func [
        "Set the newsgroup in question"
        where [block! string!] "This is the source"
    ][
        either block? where [which-groups: where][which-groups: reduce [where]]
    ]

    with: func [
        "Filter inquiry based on passed in content"
        what [block! string! object!] "this is search content"
    ][
        either object? what [using what][  ;-- must have meant 'using
            either block? what [find-content: what][
                find-content: reduce [what]
            ]
        ]
    ]
    
    ;--------- Interpreter --------------------------------------

    interpret: func [
        "Interpret the request based on the machine states"
        port [port!]
        /local x
    ][

        if state = 0 [error "Nothing asked to do."]
        if state = _OTHERWISE [exit] ;-- No interpretation necessary

        either state = _POST [
            either not found? which-groups [
                error "Don't know where to post."
            ][
                if noisy [
                    print ["Posting to:" newline which-groups 
                           newline "this message: " newline to-post ]
                    
                    if found? post-header [
                        print "Using passed in header object:"
                        print net-utils/export post-header
                    ]
                ]
            ]
            ;-- Post to multiple groups at once, or individually? 
            either cross-post [

                go-post port
            ][
                ;-- Make sure they really want to spam
                if all [(x: length? which-groups) > 15 not find/match ask [
                        "Are you sure you want to individually post to" 
                        x "newsgroups? "] "y"][
                    print "Whew! You might have been royally flamed!"
                    exit
                ]
                forall which-groups [
                    go-post port
                ]
            ]
        ][ ;-- Not posting so...

            either state = _NEWSGROUPS [
                if any [found? which-groups found? which-articles][
                    error sorry2
                ]
                get-groups port
            ][

                ;-- Getting a group count
                if state = _COUNT [
                    either found? which-groups [
                        foreach group which-groups [
                            if noisy [prin "."]
                            go-group port group
                        ]
                        exit
                     ][error "Which group do you want a count of?"]
                ]

                either found? which-groups [
                    foreach group which-groups [
                        go-group port group
                        get-data port
                    ]
                ][
                    either found? which-articles [
                        get-data port ][error "Not enough info to do that."]
                ]
            ]
        ]
    ]


    ;---- Public interface --------------------------------------

    open: func [
        port
        /local capstring auth
    ][
        howdey: open-proto port
        if any [port/user port/pass][
            authenticate port
            auth: on
        ]
        
        capstring: caps port/sub-port
        if find capstring "MODE" [
            clear buf howdey: mode-reader port 
            capstring: caps port/sub-port
        ]
        if find capstring "xhdr" [system/words/insert commands 'xhdr]
        
        port/state/flags: port/state/flags or port-flags
        clear buf ;-- buf was used up in caps
        
        
        if all [not auth none? find howdey "200"] [
            authenticate port
        ]
    ]

    insert: func [
        { Insert takes a block of a dialect the news 
          port and then has it interpreted and executed }
        port [port!] "The port"
        block [block!] "The news command block"
        /local tokens total-result temp-toke name
    ][ 
        reset-myself
        clear result ;-- last result sitting there.

        tokens: []
        clear tokens

        ;-- Here we look for pieces of the 
        ;   dialect, and make them meaningful if found.
        foreach item block [
            name: item
            either word? item [
                either found? find commands item [
                    if found? temp-toke: get in news-protocol item [
                        append tokens :temp-toke
                    ]
                ][
                    item: get item
                    either object? :item [
                        system/words/insert tail tokens item
                    ][
                        ;-- Now the 'got item may be a block or a string! 
                        either any [string? :item block? :item] [
                            system/words/insert/only tail tokens item
                        ][error reform ["I don't understand: " name]]
                    ]
                ]
            ][ 
                ;-- Item came in literal
                either any [string? item block? item] [
                    system/words/insert/only tail tokens item
                ][error reform ["I don't understand: " name]]
            ]
        ]
        do tokens 
        interpret port
        reset-myself
        clear tokens
        total-result: copy head result
        clear result
        total-result ;-- it's your memory now
    ]
    
    ;--------- NNTP Command functions ---------------------------

    caps: func [
        "Find out what the server can do."
        port
    ][
        system/words/insert port "HELP"
        read-message port buf 
        newsCaps: copy buf
    ]

    authenticate: func [
        "Authenticate ourselves to the server"
        port [port!] 
    ][
        if none? port/pass [
            net-error "Password required"
        ]

        system/words/insert port/sub-port rejoin [
            "AUTHINFO USER " port/user
        ]

        system/words/pick port/sub-port 1 ;-- gobble the more auth
        
        system/words/insert port/sub-port rejoin [
            "AUTHINFO PASS " port/pass
        ]

        net-utils/confirm port/sub-port authorize-check
    ]   

    mode-reader: func [
        "Some servers may require you to go mode reader first"
        port [port!]
    ][
        system/words/insert port/sub-port "MODE READER"
        net-utils/confirm port/sub-port open-check
    ]    

    read-message: func [
        "Read a message from the NEWS server"
        port [port!]
        buf [string!]
        /local line
    ][
        while [(line: system/words/pick port 1) <> "."] [
            system/words/insert tail buf line
            system/words/insert tail buf newline
        ]
        buf
    ]

    go-group: func [
        "Enter into a newsgroup"
        port name [string!] "The group's name" 
        /local response msg-cnt
    ][
        ;-- some memory saving functions
        group-command: "GROUP "
        group-string: func [value][
            append group-command value
            group-command
        ]
        group-reset: func [][
            remove/part skip group-command 6 tail group-command
        ]       
        zero-articles: false ;-- flag empty groups
        group-reset

        system/words/insert port/sub-port group-string name        
        response: load net-utils/confirm port/sub-port group-check
        if state = _COUNT [system/words/insert tail result copy 
                           reduce [response/2 response/3 response/4 
                                   form response/5]]

        if response/2 = 0 [zero-articles: true] 
        group-reset
    ]

    get-data: func [
        "Gets data from the server"
        port [port!] "The entire port, please"
        /local first-time prev-filt
    ][  
        if zero-articles [exit] ;-- No articles to get here...
        
        get-content: func [/wart article-number /local response prev-filt][
            cool-response: func [][none? find/match response "4"] ;-- 4's error
            if-filt-ins: func [][
                if all [any [filtrate buf prev-filt] cool-response][
                    system/words/insert tail result copy buf prev-filt: on]
            ]
            read-mpb: func [][read-message port/sub-port buf]
            with-other:    func [][either wart [article-number][
                    either found? x-what [x-what][""]]]
            respo:    func [][response: system/words/pick port/sub-port 1]
            keep-going?: func [str blk1 blk2][
                either find/match str "2" blk1 blk2
            ]

            ;-- if filtering head-body, include bodies for matches in head 
            prev-filt: off 

            either state <> _HEAD-BODY [
                system/words/insert port/sub-port append copy 
                    system/words/pick  [
                        "HEAD " "BODY " "ARTICLE " "XHDR "
                    ] state with-other
                keep-going? respo [read-mpb if-filt-ins clear buf][exit]
                not cool-response
            ][
                system/words/insert port/sub-port append copy "HEAD " 
                    with-other
                keep-going? respo [read-mpb if-filt-ins clear buf][exit]
                system/words/insert port/sub-port append copy "BODY " 
                    with-other
                keep-going? respo [read-mpb if-filt-ins clear buf][exit]
                not cool-response
            ]
        ]

        first-time: true

        ;-- we have a block of articles?
        either found? which-articles [
            foreach article which-articles [
                if noisy [prin "."]
                get-content/wart article
            ]
        ][
            ;-- we're xhdring? 
            either state = _XHDR [get-content][
                ;-- otherwise, start iterating through all articles!
                until [
                    either first-time [first-time: false get-content][
                        system/words/insert port/sub-port "NEXT"
                        response: system/words/pick port/sub-port 1
                        if noisy [prin "."]
                        either found? find/match response "4" [
                            true ][ get-content
                        ]
                    ]
                ]
            ]
        ]
    ]

    get-groups: func [
        "Retrieve the list of newsgroups"
        port [port!] "Entire port, please"
    ][
        net-utils/confirm port/sub-port list-check 
        while [(line: system/words/pick port/sub-port 1) <> "."] [
            if filtrate line [
                system/words/insert tail result first parse line none
            ]
        ] 
    ]

    go-post: func [
        "Post to Usenet"
        port
    ][

        either none? post-header [
            either none? which-groups [error "Where do you want to post?"][
                post-header: make generic-post-header [
                    newsgroups: either cross-post [
                        rejoin add-commas-nls copy which-groups][
                        first which-groups
                    ]
                    Message-ID: get-new-message-ID            
                    Subject: copy/part to-post any [find to-post newline 50]
                ]
            ]
        ][
            if found? which-groups [
                ;  This may overwrite what someone filled in 
                ;  in the newsgroups field.                  
                post-header/newsgroups: either cross-post [
                    rejoin add-commas-nls copy which-groups][
                    first which-groups]
            ]
            if none? post-header/Subject [
                post-header/Subject: copy/part to-post any [
                    find to-post newline 50
                ]
            ]

            if any [none? post-header/message-ID not keep-M-ID][
                post-header/message-ID: get-new-message-ID
            ]
        ]

        net-utils/confirm port/sub-port post-check

        system/words/insert system/words/insert to-post 
            net-utils/export post-header newline 

        system/words/insert port/sub-port to-post
        net-utils/confirm port/sub-port done-post-check
        if noisy [
            print ["Posted message titled: " post-header/subject newline
                   "to:" either cross-post [which-groups][first which-groups]
                   newline "with message-ID: " post-header/message-ID]
        ]
        append result post-header/message-ID
    ]

    ;--- Register ourselves. 
    net-utils/net-install news self 119
] 

;-- Thank you and have a pleasant time 
;   newsing around with REBOL/core 2.0! 
