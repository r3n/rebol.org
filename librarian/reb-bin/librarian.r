REBOL [
    Title:  "Librarian"
    File:   %librarian.r
    Author: ["Gregg" "Volker"]
    Type:   'link-app
    Version: 0.6.1
    Comments: {
        The display is dynamic, and consists of three types of elements:
            The main layout, incl. nav bar, etc.
            Static Layouts that are informational only.
            Dynamic layouts, e.g. result lists and tag editor.

        The main layout and static layouts are just simple LAYOUT spec blocks.

        Dynamic layouts are objects that *contain* a LAYOUT spec block, in
        addition to providing a namespace for words they use and a function
        (UPDATE-DISPLAY) the app can use to refresh the UI.
    }
    History: [
        0.6.0 [18-feb-2003 GSI
            {Added new-to-rebol and first-time static layouts. Cleaned others.}
            {Fixed some LIST rendering issues where dupe data showed for multiple
            items in "no available data" cases.}
        0.6.1 [20-jul-2005 Sunanda
               {Sort results by partial relevance}
              ]
        ]
    ]
]

admin-mode: link?   ; Enable admin features if run from IOS.
admin-mode: false   ; Sunanda: Nov 2003 (downloaded versions run under
										;			IOS don't have all the things they need.)

items: []           ; The list of results for a filter or search operation.
last-search-time:   ; How long did the last search take
cur-view-context:   ; The active dynamic layout context, if there is one.
    none

do %prefs.r
do join prefs/support-dir %librarian-lib.r

; Static layouts in the app will be processed by a tool to convert them
; to HTML pages for the web version of the library. It will parse the VID
; code so we don't have to do anything special. To be nice to the tool
; writer, and perhaps as a bit of helpful documentation, we'll include a
; list of the words that contain static layouts.
static-layouts: [   ; tells the static HTML generator what to use
    home-lay    ; was intro-lay
    about-lay
    term-lay
    help-lay
    first-time-lay
    new-to-rebol-lay
]

; TBD - This could be nicer. Maybe named values in a block or something.
;       Not so cryptic and magical in any case.
colors: reduce [(rebolor / 1.5) + (mint / 1.5) coal snow]
append colors ((colors/1 / 2.5) + (colors/3 / 1.5))
base-color: system/view/vid/vid-styles/face/color: colors/1


;; ===================================================
script-size: func [val /local d] [

  if val < 1024 [return join val " bytes"]
	val: form val / 1024
	if d: find/tail val #"." [clear next next d]
	if val/1 = #"." [insert val #"0"]
	append val " KB"
]
;; ====================================================



;=== Static Layouts

first-time-lay: [
    origin 0x0
    space 4x4

    style term H4  black 130
    style def text black 450 font-size 12
    style body text 600 black

    H2 {Getting Started}

    body {Please keep your hands and arms inside the tram at all times. The
    area to your left is the Navigation Bar; that's where you'll click to
    see different groups of items or information about REBOL and this
    application. You are reading this text in the main Document Area, which
    is also where you'll see lists of results as you click on various filters
    or run searches. Text that you can click on to trigger an action will
    change color when your mouse moves over it, so you can tell what's "active"
    and what's not.}

    H2 {Being Careful}

    body {There is lots of code here and, while we do our best,
    it's always possible that someone could slip something malicious in here.
    REBOL plays nicely in a sandbox by default, but if you give it permission,
    it can do anything you want - including what someone else wants that you
    don't. If you do happen to find a bit of code, or an entry, that you think
    is questionable or suspcious, PLEASE bring it to our attention! We don't
    anticipate any problems, but better safe than sorry.}

    pad 0x15
    H2 {Major Groupings}
    pad 0x5

    across

    term "New and Updated - "
        def {This is where you'll find things that have been added to the
        library, or updated, most recently - probably within the past month
        or two.} return
    term "Applications - "
        def {These are things you can click on, and they do something visible,
        or helpful, or both.} return
    term "Reference - "
        def {If something is oriented more toward answering a question, or
        explaining a concept, this is where you'll probably find it.} return
    term "Code - "
        def {The real deal. Why you're probably here. We'll be tweaking the
        filter rules and categories, so don't be shy about telling us how the
        filtering choices work for you. There's all kinds of stuff here, from
        little example tidbits, to functions, modules, even full blown dialects
        and protocols that you can use.} return

    pad 10x15
    body {See the Terms screen for notes about some of the minor groupings.}
]

new-to-rebol-lay: [
    origin 0x0
    space 4x4

    style hdr H3 black
    style body text 600 black

    hdr {If you know <language X>, but are new to REBOL...}

    body {Free your mind. REBOL will have many familiar concepts, or what look
    like familiar concepts, but it is quite different from most other languages
    you may have worked with. Yeah, I know you've heard that a million
    times before, and you're not going to believe me no matter what I say, so
    just dig in and decide for yourself.}

    body {Check out some demos. You should be pleasantly surprised at how little
    code it takes to build GUIs. There's a full 24-bit compositing engine under
    the hood and a cool graphics pipeline to boot. If you do text processing,
    it's great for that too; no reg-ex's, but it has something better (the PARSE
    function). Net stuff? you bet. Lots of protocols built in.}

    body {Look at the code here, check out the one-liners. Hit rebol.com, rebol.org,
    and the mailing list too.}

    hdr {If you know nothing about programming, but want to learn...}

    body {REBOL is a great place to start. It has a nice shallow learning curve,
    so you can start doing things quickly, but you won't outgrow it anytime soon
    because it also has amazing depth. You may find that you get comfortable with
    the basic concepts very quickly and then feel like it seems like things get
    harder, instead of easier, for a while; that's normal. REBOL conceals its
    power very well but, as you dig in more, you'll start finding that there is a
    lot going on that you haven't bothered to learn about yet, and maybe never will.
    Lots of non-programmers enjoy tinkering with REBOL and creating things for
    themselves and friends, like people used to do with BASIC. REBOL is human friendly.}

    body {If you're trying to learn other languages at the same time as REBOL,
    be aware that it is quite different from languages like Java, C++, and Visual
    Basic. It's also different than Perl, Python, and Ruby. It is similar in ways
    to Lisp, Scheme, Forth, and Logo, but is neither a purely functional, symbolic,
    or object-oriented language. It is all those things and more. While that
    description might make you think that REBOL is a bit schizophrenic, don't worry,
    it is a very simple and elegant language with some amazing tricks up its sleeve.}

    hdr {If you know nothing about programming, and don't want to learn...}

    body {You're probably here because some programmer you manage wants to use
    REBOL for a project or two and you need to see what all the fuss is about.
    You may want to visit the main REBOL site (www.rebol.com) to get more
    in-depth "consumer" information. There's plenty of technical stuff
    there as well. While you're here though, check out some of the demos and
    look at some code to get a feel for what REBOL looks like and what it can do.}
]

about-lay: [
    origin 0x0
    space 4x4

    style role H4 150
    style def text black 400 font-size 12
    style body text 600 black

    H2 {What is the Library Project?}

    body {The library project was started to see if the REBOL community could
    rise to the challenge of improving upon the existing REBOL script library
    and taking it into the future. We knew going into it that volunteer
    projects can be tough to organize and difficult to impel, but with more
    than 400 entries in the existing library, and the community clamoring for
    updates to it, we forged ahead.}

    body {It took us longer than we had hoped to get out a first release, but
    we made it! We spent a lot of time discussing design alternatives, building,
    and planning, yet we're already thinking about how our simple
    little design probably won't work for some of the features we want to add
    in the future. We had to start somewhere, and that's where we are.}

    pad 0x10  box 580x3 colors/1  pad 0x10

    H2 {Who are the mysterious "Library People?"}

    ;text 600 black {The library team is made up of people from the REBOL community,
    ;with some very special support.}

    across

    pad 10x10
    guide
;     role "Executive Producer" def "Carl Sassenrath" return
;     role "Asst. Producer / Tools" def "Gregg Irwin" return
;     role "Organizational Lead" def "Sunanda" return
;     role "Tool Lead" def "Volker Nitsch" return
;     role "Web Lead" def "Andrew Martin" return

;     role "Executive Producer" def "Carl Sassenrath" return
;     role "Sunanda" def "as Himself" return
;     role "Volker Nitsch" def "as Himself" return
;     role "Andrew Martin" def "as Himself" return
;     role "Gregg Irwin" def "as Himself" return

;     role "Carl Sassenrath" def "Executive Producer"  return
;     role "Sunanda" def "Organization Lead, Web Stuff" return
;     role "Gregg Irwin" def "Asst. Producer, Tools" return
;     role "Volker Nitsch" def "Tools" return
;     role "Andrew Martin" def "Web Stuff" return

    role "Team" def {Sunanda, Volker Nitsch, Gregg Irwin} return
    role "Bootstrap Team" def {Andrew Martin, Ingo Hohmann, Anton Rolls -
    Many thanks for their assistance in getting things rolling and hashing
    out initial design ideas.} return
    role "Special Thanks" def {The team at REBOL Technologies for creating
    REBOL and IOS - which is how we all collaborate from our homes around the
    world, Robert M. Muench for make-doc-pro, Chris Ross-Gill for his great graphic
    design work, Reichart and the crew at Prolific for creating AltME - which we
    use to stay in touch with the outside world, and REBOLers everywhere
    for their motivation and support.} return

    pad 0x50
    text black "Library Project History..." [show-history]
]

term-lay: [
    ;offset 195x75
    origin 0x0
    space 4x4
    across

    style term H3 130
    style def text black 450 font-size 12

    H2 "Terminology" return
    term "Demos - "
        def {These are written to show REBOL off in some way. Yes, you may
        learn something from their code, but their goal is to just look cool
        and show off. All demos will have a display of some kind, even if
        it's just a console.} return
    term "Games - "
        def {Games are games. If you can play it, it's a game.} return
    term "Tools - "
        def {Tools provide some kind of useful functionality.} return
    box 580x3  colors/1 return
    term "Idioms - "
        def {These are the little nuggets that show you the inner "zen" of REBOL.} return
    box 580x3  colors/1 return
    term "One-liners - "
        def {If it fits on one line, it qualifies. You'd be surpised how much
        some of them do.} return
    term "Functions - "
        def {A function or a set of functions that can be called
        or included in other scripts.} return
    term "Modules - "
        def {A set of related functions, and perhaps data, that generally would
        define a context/namespace to avoid collisions.} return
    term "Protocols - "
        def {REBOL protocols, not network protocols} return
    term "Dialects - "
        def {a.k.a. Domain Specific Languages; where REBOL really shines.} return
    ;term "Math - " return
    term "UI / GUI - "
        def {(Graphical) User Interfaces} return
    term "Internet - "
        def {Web stuff, HTTP, CGI, TC, email, etc.} return
    ;term "Database - " return
    ;term "File Handling - " return
    term "Text Processing - "
        def {Includes markup (e.g. HTML, XML) related processing.} return
    ;term "Markup - " return
    term "Patches - "
        def {A patch is an updated version of a mezzanine that ships with a
        standard REBOL distribution. Some of them will come from RT and others
        will come from users.} return
    term "Miscellaneous -"
        def {Stuff that doesn't have it's own home yet. E.g. Printing,
        encryption, compression, win-api, shell, etc.} return
    term "Broken - "
        def {Items listed here are known to have issues under one or more REBOL
        releases. They are included here so that people can fix them if they
        feel so inclined, and they may still have something to offer in any case.} return
]

home-lay: [
    origin 0x0
    space 4x4

    style body text 600 black

    H2 "Welcome!"

    body {This is a resource library for REBOL developers. Generally that
    means software developers of some kind - so you'll find information targeted
    mainly at that audience - but REBOL can be used by anybody, for many different
    purposes. If you're not a software geek, or if you're familiar with other computer
    languages but haven't looked at REBOL before, you'll probably want to look at
    'First time here?' and 'New to REBOL?'.}

    body {This library is a main resource repository for REBOL developers.
    It contains scripts, tools, demos, documenation, tutorials, and more. The library
    project is in its early stages, but we hope it will become more than the sum of
    its parts. Please let us know if you have any suggestions or comments.}

    text black as-is "^- -- Happy REBOLing!"

    pad 0x10  box 580x3 colors/1  pad 0x10

    H2 "What's New?"

    body {This is the first release of the new library system. We like
    to call it "Phase I". Our goal for this release was just to clean up the
    existing library, come up with plans for the future, and put some of the
    infrastructure pieces in place to support that. Phase I is kind of a "read only"
    release. The old script submission utilities will still submit your entries to
    the original script library, not this one. Yes, we do plan to offer tools for
    this library system as well, but we have to focus on one thing at a time. If we
    built all those tools now, and then found out nobody likes the basic idea, we'd
    just end up throwing them all away. This release provides you the opportunity to
    give us feedback about the interface and organization, which is something we
    need and want. It's a starting point.}

    pad 0x10  box 580x3 colors/1  pad 0x10

    H4 "General Disclaimer"

    body brick {The scripts kept in this archive are not heavily monitored by any
    person or persons and therefore could contain harmful data. Some precautions have
    been taken but all downloaded scripts should be examined before execution to ensure
    that they are not malicious in intent. Executing new scripts in the REBOL interpreter
    with security turned on is always a good idea in order to monitor what the script is
    doing.}


    ;pad 0x10
    text 600 black center "REBOL is a registered trademark of REBOL Technologies" [
        view/new center-face/with layout [
            text 600 {THE SOFTWARE AND DOCUMENTATION ARE PROVIDED ON AN "AS IS" BASIS,
            WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR STATUTORY INCLUDING WITHOUT
            LIMITATION ANY IMPLIED WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT OR FITNESS
            FOR PARTICULAR USE OR PURPOSE.}

            text 600 {IN NO EVENT SHALL REBOL OR ITS SUPPLIERS OR RESELLERS BE LIABLE TO YOU OR ANY OTHER PERSON FOR ANY INDIRECT,
            SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES OF ANY KIND INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS
            OR DATA, ARISING OUT OF THIS AGREEMENT OR USE OF THE SOFTWARE. IN NO EVENT WILL REBOL BE LIABLE FOR (a) ANY DAMAGES
            IN EXCESS OF THE AMOUNT REBOL RECEIVED FROM YOU FOR A LICENSE TO THE SOFTWARE, EVEN IF REBOL HAS BEEN ADVISED OF
            THE POSSIBILITY OF SUCH DAMAGES AND NOTWITHSTANDING THE FAILURE OF ESSENTIAL PURPOSE OF ANY REMEDY, OR (b) FOR
            ANY CLAIM BY ANY THIRD PARTY.}
        ] main-lay
    ]
]

help-lay: [
    origin 0x0
    space 4x4

    style body text 600 black

    H2 {Basic Usage}

;     text 600 black {It couldn't be easier. Just click on the category you're
;     interested in and those items will be displayed. The only thing that might
;     not be clear is how those items are found, which may lead to some confusion
;     if you get results you do not expect (or agree with).}

    body {Each library entry is tagged, internally, with values that
    identify what kind of entry it is, what domain(s) it is related to, etc.
    Each filter (the items you click in the navigation area) has one or more
    rules attached to it, much like a standard database query, which searches
    for items. You can sort columns by clicking on the column headers.}

    H2 {Searching}

    body {If you find the pre-defined filters don't produce the results
    you want, you can use the FIND field at the top of the screen to search for
    items yourself. If you type in some simple text, the engine will do a
    text search of each library entry to see if the words you entered are found.
    We have a text indexing engine behind this, so let us know how it works for
    you.}

    H3 {Searching in specific fields}

    body {You can tell the search engine to look in a specific index
    field for a value by using a few special keywords (IN, IS, and CONTAINS).
    IN and CONTAINS search for matching sub-strings, IS compares for equality.
    Wildcards ( * and ? ) are supported.}

    here: at
    across
    pad 10x0
    guide
    space 0x5
    style ex-lead H4 colors/2 "Find"
    style ex text black 240 font-size 12

    pad 0x5

    ex-lead ex {<data> IN <field>}  ex-lead ex {<field> IS <data>} return
    ex-lead ex {Sunanda in author}   ex-lead ex {author is Volker} return
    ex-lead ex {"Gregg Irwin" in author} ex-lead ex {author is "Volker Nitsch"} return
    box 250x2 colors/1   pad 20x0   box 250x2 colors/1  return
    ex-lead ex {<field> CONTAINS <data>} return
    ex-lead ex {author contains Carl} return
    ex-lead ex {author contains "Carl Sassenrath"} return
    ;box 250x2 colors/1 return
    pad 0x5

    H4 {Searchable Field Names:}
    text black font-size 14 {file size title author date version purpose} return
    H4 {Additional operators:}
    text black font-size 14 {= < > <= >= <>} return

]

;=== Dynamic Layouts

dynamic-layout: make object! [
    lay:            ; The layout spec
    update-display: ; The function used to refresh the display when the
                    ; list of results is sorted or viewed.
    visible-rows:   ; How many result items are visible at one time.
        none
]

one-liners: make dynamic-layout [
    num-found-hdr: main-lst: sld:
    t-title: t-version: t-size: t-date: t-file: t-purpose: t-author:
    t-do-script: t-edit-tags: t-source: itm:
        none
    count: 0        ; The index of the current item being fetched for display
                    ; in the result LIST.
    ml-cnt: 0       ; Used to track the result list slider value.
    visible-rows: 5 ; How many result items are visible at one time.

    update-display: does [
        sld/data: count: ml-cnt: 0
        num-found-hdr/text: rejoin ["Found " length? items " matches in " last-search-time]
        sld/redrag divide visible-rows max 1 length? items
        sld/step: max .001 divide 1 max 1 length? items
        sld/page: sld/step * visible-rows
        t-title/text: t-version/text: t-size/text: t-date/text: none
        t-file/text: t-purpose/text: t-author/text: t-source/text: none
        show [main-lst num-found-hdr sld]
    ]

    lay: [
        origin 5x5
        space 0
        across
        num-found-hdr: H2 550 "Found 0 matches" return

        ;style tlab text center white black with compose/deep [
        ;    font/colors: [(black) (colors/4)]
        ;]
    	style tlab text center white black
    	;return
        tlab 225 left "Title" bold [sort-list 'title]
        ;pad -20x0
        ;img-sort-flag: image 20x20 effect [arrow 255.255.255 flip 0x1]
        tlab  75 "Version" [sort-list 'version]
        tlab  75 "Size"    [sort-list 'size]
        tlab 100 "Date"    [sort-list 'date]
        tlab 115 "File"    [sort-list 'file]
        return
    	main-lst: list 574x450 [
     		across space 1x0 origin 0x0
     		backcolor snow
            style tb text 50x20 black 208.221.202 center middle ; colors/1 or 208.221.202 or 227.233.226
     		;style tb text 50x20 black 208.221.202 center middle effect compose [gradient 0x1 208.221.202 (208.221.202 - 100)]; colors/1 or 208.221.202 or 227.233.226
            t-title: tb 225 left bold
            t-version: tb 75
            t-size: tb 75
            t-date: tb 100
            t-file: tb 115 left
            return
            t-purpose: text 375x30 font-size 11 black snow ;375x46
            text 100 center navy "Copy" [copy-item itm]
            text 100 center navy "View" [view-item itm]
            return
            pad 20x0
            t-source: text 550x20 font-name font-fixed coal ; [][write clipboard:// face/text]
            return
            t-author: text 275x16 font-size 11 gray italic
            pad 100x0
            t-do-script: text 100 center bold brick "Do" [do-item itm]
            t-edit-tags: text bold brick "Edit Tags" [edit-item itm]
            return  ; pads the layout vertically
            ;box 0x2 ; pads the layout vertically
     	] supply [
            count: count + ml-cnt
            itm: pick items count
            either itm [
                attempt [
                    switch index [
                        1 [t-title/text:    copy/part itm/title 32]
                        2 [t-version/text:  either itm/version <> 'none  [itm/version][""]]
                        ;3 [t-size/text:     itm/size]
                        3 [t-size/text:     join length? script-source itm " bytes"]
                        4 [t-date/text:     itm/date/date]
                        5 [t-file/text:     itm/file]
                        6 [t-purpose/text:  trim itm/purpose]
                        7 [t-source/text:   script-source itm]
                        ;8
                        ;9
                        ;10 [t-author/text:   join "Author: " form itm/author]
                        11 [t-do-script/show?: admin-mode]
                        12 [t-edit-tags/show?: admin-mode]
                    ]
                ]
            ][
                t-title/text: t-version/text: t-size/text: t-date/text:
                t-file/text: t-purpose/text: t-author/text: none
            ]
     	]
    	sld: scroller 16x450 [
    		if ml-cnt <> (val: to-integer value * subtract length? items visible-rows) [
    			ml-cnt: val
    			show main-lst
    		]
    	]
    ]
]

std-results-lay: make dynamic-layout [
    num-found-hdr: main-lst: sld:
    t-title: t-version: t-size: t-date: t-file: t-purpose: t-author:
    t-do-script: t-edit-tags: itm:
        none
    count: 0        ; The index of the current item being fetched for display
                    ; in the result LIST.
    ml-cnt: 0       ; Used to track the result list slider value.
    visible-rows: 5 ; How many result items are visible at one time.

    update-display: does [
        sld/data: count: ml-cnt: 0
        num-found-hdr/text: rejoin ["Found " length? items " matches in " last-search-time]
        sld/redrag divide visible-rows max 1 length? items
        sld/step: max .001 divide 1 max 1 length? items
        sld/page: sld/step * visible-rows
        t-title/text: t-version/text: t-size/text: t-date/text: none
        t-file/text: t-purpose/text: t-author/text: none
        show [main-lst num-found-hdr sld]
    ]

    lay: [
        origin 5x5
        space 0
        across
        num-found-hdr: H2 550 "Found 0 matches" return

        ;style tlab text center white black with compose/deep [
        ;    font/colors: [(black) (colors/4)]
        ;]
    	style tlab text center white black
    	;return
        tlab 225 left "Title" bold [sort-list 'title]
        ;pad -20x0
        ;img-sort-flag: image 20x20 effect [arrow 255.255.255 flip 0x1]
        tlab  75 "Version" [sort-list 'version]
        tlab  75 "Size"    [sort-list 'size]
        tlab 100 "Date"    [sort-list 'date]
        tlab 115 "File"    [sort-list 'file]
        return
    	main-lst: list 574x450 [
     		across space 1x0 origin 0x0
     		backcolor snow
            style tb text 50x20 black 208.221.202 center middle ; colors/1 or 208.221.202 or 227.233.226
     		;style tb text 50x20 black 208.221.202 center middle effect compose [gradient 0x1 208.221.202 (208.221.202 - 100)]; colors/1 or 208.221.202 or 227.233.226
            t-title: tb 225 left bold
            t-version: tb 75
            t-size: tb 75
            t-date: tb 100
            t-file: tb 115 left
            return
            t-purpose: text 375x46 black font-size 11
            ;text 100 center navy "Download" [download-item itm]
            pad 100x0
            text 100 center navy "View"     [view-item itm]
            return
            t-author: text 275 gray italic
            pad 100x0
            t-do-script: text 100 center bold brick "Do" [do-item itm]
            pad 20x0
            t-edit-tags: text bold brick "Edit Tags" [edit-item itm]
            return  ; pads the layout vertically
            box 0x4 ; pads the layout vertically
     	] supply [
            count: count + ml-cnt
            itm: pick items count
            either itm [
                ;attempt [
                    ;?? Do we prefer SWITCH, DO/PICK, or DO/PICK+SWITCH ?
                    ; I think it depends on what we're supplying - Gregg
;                     either index < 12 [
        				face/text: do pick [
                            [copy/part itm/title 32]
                            [either itm/version <> 'none  [itm/version][""]]
                            [either integer? itm/size [script-size itm/size][""]]
                            [itm/date/date]
                            [itm/file]
                            [either string? itm/purpose [trim itm/purpose][""]]
                            ;["Download"]
                            ["View"]
                            [join "Author: " form itm/author]
                            [t-do-script/show?: admin-mode "Do"]
                            [t-edit-tags/show?: admin-mode "Edit Tags"]
    					] index
;     				][
;                         switch index [
;                             1 [t-title/text:    copy/part itm/title 32]
;                             2 [t-version/text:  either itm/version <> 'none  [itm/version][""]]
;                             ;3 [t-size/text:     itm/size]
;                             ;3 [t-size/text:     join round/places divide itm/size 1024 1 " KB"]
;                             3 [t-size/text:     kb-size itm/size]
;                             4 [t-date/text:     itm/date/date]
;                             5 [t-file/text:     itm/file]
;                             6 [t-purpose/text:  trim itm/purpose]
;                             ;7
;                             ;8
;                             9 [t-author/text:   join "Author: " form itm/author]
;                            10 [t-do-script/show?: admin-mode]
;                            11 [t-edit-tags/show?: admin-mode]
;                         ]
;                     ]
                ;]
            ][
                t-title/text: t-version/text: t-size/text: t-date/text:
                t-file/text: t-purpose/text: t-author/text: none
            ]
     	]
    	sld: scroller 16x450 [
    		if ml-cnt <> (val: to-integer value * subtract length? items visible-rows) [
    			ml-cnt: val
    			show main-lst
    		]
    	]
    ]
]

;=== Main Layout

main-lay: layout [

    origin 0x0
    ;size 800x600
    ;backcolor colors/3
    ;backdrop ((colors/1 / 2.5) + (colors/3 / 1.5))

    ; Bottom border bar
    ;at 175x573 box 625x4  effect compose [gradient 0x1 (colors/2) (colors/1)]
    ;at 175x577 text 625x23 black center colors/1 "All scripts are provided AS IS without warranty and without liability to the author or to REBOL Technologies"
    at 175x577 text 625x23 black center "All scripts are provided AS IS without warranty and without liability to the author or to REBOL Technologies"

    ; Left border bar
    at 0x45  box 175x555 water + 75 ;((colors/1 / 2) + (colors/2)) ;pewter
    at 175x45 box 4x555 black effect compose [gradient 1x0 (water + 75) coal] ; [gradient 1x0 (colors/1) (colors/2) ]

    ; mid border
    at 0x45  box 800x4  effect compose [gradient 0x1 (colors/2) (colors/1)]
    at 0x49  box 800x18 colors/1
    at 0x67  box 800x4  effect compose [gradient 0x1 (colors/1) (colors/2)]

    ;at 0x0 image gfx-dir/reb-logo.gif effect compose [contrast -30 invert gradcol 0x-1 (colors/1 - 40) (colors/1 / 2) alphamul 64]
    at 0x0 image prefs/graphics-dir/reb-logo.gif effect compose [contrast -30 invert gradcol 0x-1 (water + 75) (water - 25)]

    at 190x-2 text 600 gray {It's a messaging language – 'rebel' not 'ree-ball' –
    code is data and data is code – CGI? Yes – 40+ platforms – only 250K-500K –
    console or GUI – Yes, just a single file – commercial versions = same core + ODBC, SSL, and more -
    shallow learning curve, amazing depth – keep IT simple – if you liked "The Matrix"...
    }
    ;— – -
    ; it's all about communication
    ; open your mind
    ; there is a certain 'zen' and elegance to it

    at 0x530 image prefs/graphics-dir/pwr-rebol.png effect compose [contrast -30 emboss invert gradcol 0x1 (water + 75) (water - 25)] ;(colors/1 - 40) (colors/1 / 2)

;     at 190x75
;     guide

    style lnk text with compose/deep [font/colors: [(black) (blue)]]
    style H3 H3 with compose/deep [font/colors: [(black) (blue)]]
    style bullet text bold "·"
    style separator box 165x2 black

    space 4x2
    across
    at 6x50 ;630x50
    lnk "Home"     [change-view-to home-lay] bullet
    lnk "About"    [change-view-to about-lay] bullet
    lnk "Contact"  [browse mailto:library@rebol.org] bullet
    lnk "Refresh"  [do %refresh.r] bullet
    lnk "Quit"     [quit]

    at 420x49
    lnk "Find:"
    pad 0x-1
    space 1x0
    fld-find: field 300x20 with [edge/size: 1x1] [run-search face/text]
    tgl-search-in: toggle 40x20 "All" "List" with [edge/size: 1x1] colors/1 font [style: none colors: [0.0.0 0.0.0] shadow: none]

    space 1x2
    at 5x75 guide
    ;pad 10x0
    guide

    H3 "First time here?" [change-view-to first-time-lay] return
    ;lnk "Intro" [alert "TBD!"] bullet
    lnk "Terms" [change-view-to term-lay]  bullet
    lnk "Help"  [change-view-to help-lay]  return

    H3 "New to REBOL?" [change-view-to new-to-rebol-lay] return

    ;H3 "New and Updated!" [run-search rejoin ["date >= " now - 60]] return
    H3 "New and Updated!" [run-special-filter/recent] return

    H3 "Applications" [run-filter 'Programs] return
    lnk "Demos" [run-filter 'Demos] bullet
    lnk "Games" [run-filter 'Games] bullet
    lnk "Tools" [run-filter 'Tools] return

    H3 "Reference"  [run-filter 'Docs] return
    lnk "How-to"    [run-filter 'How-To] bullet
    lnk "FAQ"       [run-filter 'FAQ] bullet
    lnk "Articles"  [run-filter 'Article] return
    lnk "Tutorials" [run-filter 'Tutorial] bullet
    lnk "Idioms"    [run-filter 'Idiom] return

    H3 "Code" [run-filter 'Code] return
	text "1-liners" [run-filter/with 'Type-One-Liner one-liners] bullet
	text "func's"   [run-filter 'Type-Function] bullet
	text "modules"  [run-filter 'Type-Module] return
    lnk "internet" [run-filter 'Internet] bullet
    lnk "CGI"      [run-filter 'Domain-CGI] bullet
    lnk "FTP"      [run-filter 'Domain-FTP] bullet
    lnk "mail"     [run-filter 'Domain-email] return
    lnk "UI / GUI" [run-filter 'GUI] bullet
    lnk "database" [run-filter 'Database] bullet
    lnk "files"    [run-filter 'Files] return
    lnk "text"     [run-filter 'Text] bullet
    lnk "markup"   [run-filter 'Domain-Markup] bullet
    lnk "HTML"     [run-filter 'Domain-HTML] return
    ;text "XML"      [run-filter 'Domain-XML] return
    lnk "protocols" [run-filter 'Type-Protocol] bullet
	text "dialects" [run-filter 'Type-Dialect] bullet
    lnk "math"     [run-filter 'Math] return
    lnk "game-related" [run-filter 'Domain-Game] bullet
    lnk "patches"  [run-filter 'Patches] return
    lnk "misc"     [run-filter 'Misc] bullet
    lnk "broken"   [run-filter 'Broken] bullet
    lnk "grab bag" [run-special-filter/grab-bag] return
    pad 0x5  separator return  pad 0x5
    lnk "All Scripts"  [run-filter 'all] bullet
    lnk "Beginner"     [run-filter 'level-beginner] return
    lnk "Intermediate" [run-filter 'level-intermediate] bullet
    lnk "Advanced"     [run-filter 'level-advanced] return

    pad 0x5  separator return  pad 0x5

    text 160 bold center (join total-script-count " entries and counting!")
    return

    at 190x75 out-box: box 600x500

]


;----------------------------------------------------------------
;
; The result lists have a number of elements that may use these
; common actions to access a script.
;

view-item: func [
    {Display the entire script, header and all.}
    item
    /local file-data new-lay
] [
    if item [
        file-data: either string? item [item][read join prefs/script-dir item/file]
        new-lay: layout [
            origin 0
            space 0x0
            across
            text-1: text as-is 640x500 para [origin: 4x4] file-data with [
                color: snow
                font: [name: font-fixed]
                feel: make feel [redraw: none]
                ;edge: [size: 2x2 color: svvc/bevel effect: 'ibevel]
            ]
            v-sld: scroller 16x500 [
        		size: size-text text-1
        		text-1/para/origin/y: v-sld/data - 1 * (negate size/y) - size/y + 2
                show text-1
        	]
        	at (text-1/offset + 0x500) h-sld: scroller 640x16 [
        		size: size-text text-1
        		text-1/para/origin/x: h-sld/data - 1 * (negate size/x) - size/x + 2
        		text-1/line-list: none
                show text-1
        	]
        	at 560x0
        	box gray 1x500
        ]
        new-lay/color: colors/1
        view/new center-face/with new-lay main-lay
    ]
]

download-item: func [item] [
    if item [alert join "Download " join prefs/script-dir item/file]
]

edit-item: func [item] [
    ;STUB - if item [alert join "Edit " join prefs/script-dir item/file]
    if not value? 'tag-editor [do %tag-editor.r]
    tag-editor/edit-tags/with join prefs/script-dir item/file main-lay
]

copy-item: func [item /local hdr src] [
    ;if item [alert join "Copy " item/file]
    if error? try [
        set [hdr src] load/header/next join prefs/script-dir item/file
    ][
        alert "Error loading data to copy"
        return
    ]
    write clipboard:// trim src
]

do-item: func [item /local temp-dir orig-dir] [
    if error? set/any 'err try [
        if item [
            do join prefs/script-dir item/file
            ;temp-dir: join what-dir %temp/
            ;write/binary
            ;    join temp-dir item/file
            ;    read/binary join prefs/script-dir item/file
            ;orig-dir: what-dir
            ;change-dir temp-dir
            ;call item/file
            ;change-dir orig-dir
        ]
    ][
        alert rejoin ["Error running script: " mold disarm err]
    ]
]

;----------------------------------------------------------------

bring-to-front: func [face] [
    remove find face/parent-face/pane face
    append face/parent-face/pane face
    show face
]

send-to-back: func [face] [
    remove find face/parent-face/pane face
    insert head face/parent-face/pane face
    show face/parent-face
]

show-history: does [alert "History"]

script-source: func [
    {Returns the source code for an item, minus the header.}
    item    "Script index entry"
    /local hdr src
] [
    if error? try [
        set [hdr src] load/header/next join prefs/script-dir item/file
    ][
        return "Unable to load source for display"
    ]
    trim form src
]

change-view-to: func [new-view /local pane] [
    if new-view = active-pane [return]
    if active-pane [hide active-pane]
    pane: either block? new-view [layout/offset new-view 0x0][new-view]
    pane/color: none
    if active-pane: out-box/pane: pane [show [out-box pane]]
]

sort-list: func [field] [
    sort-by/auto-reverse items field
    cur-view-context/update-display
]

run-special-filter: func [
    {Special filters are those we build in to fill specific needs. Technically
    we could implement anything in rule files, and we may...but not right now.}
    /grab-bag
    /recent
] [
    _pre-filter
    start-time: now/time/precise

    if grab-bag [items: random-selection]
    if recent   [items: find-new-and-updated]

    last-search-time: now/time/precise - start-time
    _post-filter std-results-lay
    items
]

run-filter: func [
    id
    /with   "Change to a dynamic layout other than the default result view"
        dyna-lay
    /local start-time
] [
    _pre-filter
    start-time: now/time/precise
    items: do-filter id
    last-search-time: now/time/precise - start-time
    _post-filter either with [dyna-lay][std-results-lay]
    items
]

run-search: func [spec [string! block!] /local start-time] [
    _pre-filter
    start-time: now/time/precise
    items: run-user-search/index spec either tgl-search-in/data [items][script-index]

    if error? try [get rank-utils] [do %rank-utils.r]
    items: rank-utils/rank-by-relevance items  spec
    last-search-time: now/time/precise - start-time
    _post-filter std-results-lay
    items
]


_pre-filter: func [
    {This is the stuff to do before a filter has executed. It is called
    from routines like RUN-FILTER, RUN-SEARCH, etc. which need to update
    the display to show the results they got.}
    dyna-lay "The dynamic-layout object being used."
] [
    ; Everything's shifted out of here at the moment
]

_post-filter: func [
    {This is the stuff to do after a filter has executed. It is called
    from routines like RUN-FILTER, RUN-SEARCH, etc. which need to update
    the display to show the results they got.}
    dyna-lay "The dynamic-layout object being used."
] [
    cur-view-context: dyna-lay
    change-view-to dyna-lay/lay
    dyna-lay/update-display
]

;----------------------------------------------------------------


; If we store the result of LAYOUT back into the LAY value of
; a dynamic layout object, it's like caching that layout so it
; doesn't have to be re-rendered (i.e. run through LAYOUT again)
; each time it's displayed.
std-results-lay/lay: layout/offset std-results-lay/lay 0x0
main-lay/color:  colors/4 ;((colors/1 / 2.5) + (colors/3 / 1.5))
out-box/pane: active-pane: intro-pane: layout/offset home-lay 0x0
out-box/pane/color: none


; Fire it up
unview/all
view main-lay
do-events
