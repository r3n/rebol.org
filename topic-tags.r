REBOL
[   title:     "Topic Tags"
    name:      'topic-tags
    file:      %topic-tags.r
    author:    "Christian Ensel"
    email:     Christian.Ensel@GMX.de
    version:   0.2.1
    date:      15-05-2004
    library: [
        level: 'beginner
        platform: 'all
        type: [tool]
        domain: [text-processing html]
        tested-under: [View 1.2.46.3.1 on WinXP]
        support: none
        license: 'PD
        see-also: none
    ]
    
    purpose:
    {    Makes tagging the mailing list a little bit more comfortable.
    
         Lists all topic tags in a window which I like to have open while tagging.
         Clicking on any tag copies it into clipboard so I only have to paste it into browser.
    }
    
    usage:
    {   On startup you are asked whether to download all topic tags at once (on modem connections
        this may take a while). 
        If you don't download at start time, single letters are downloaded first time they are left-clicked.
        You can update each letter by right-clicking it later.
        Or you may later update all letters at once by right-clicking the "active-letter" button in the top left corner.

        For imported tags select one from the tag-list. This tag is copied to the clipboard.
        
        For nested tags you choose between flat and deep copying by selecting one
        of the toggles at the top of the window.
        The current content of the clipboard is highlighted yellow.
        
        By clicking again (and again) you toggle between tag with/without brackets.

        Simply try it out, you'll get the idea.
    }
        
    comments:
    {   - Beware of non-standard Joel-style intendation.
        - Script only tested under latest view/beta.
        - The script source is very messy.
        - If the window is to high you eventually want to lessen the HEIGHT word at top of the script.
    }    
]

HEIGHT: 700

debug?: no
debug: func [info] [if debug? [print info]]
topics: []
topic-index:
[   "0" "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l"
    "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
]
topics-selector:
[   style idx button 24x18 blue + silver font [size: 12 style: none shadow: none] no-wrap ;edge [size: 1x1 color: 0.0.0 effect: none]
    backdrop silver
    origin 1x1 space 1x1 below
    topics-letter: idx "A" red + gray 24x37
    [   update-topics to char! topics-letter/text]
    [   update-topics none]
]
use [char]
[   foreach index topic-index
    [   repend topics [char: first to string! index none]
        append topics-selector compose/deep
        [    idx (index) (char) [show-topics (char)] [update-topics (char)]]
]   ]
append topics-selector 
[   return
    flat-topic: toggle " " 200x18 left no-wrap silver + white yellow font [shadow: style: none colors: [0.0.0 0.0.0]]
        with [user-data: context [active?: no]]
    [   if flat-topic/user-data/active? [flat-topic/text: toggle-brackets flat-topic/text]
        write clipboard:// flat-topic/text 
        flat-topic/state: flat-topic/user-data/active?: yes
        deep-topic/state: deep-topic/user-data/active?: no 
        show flat-topic
        if deep-topic/user-data/visible? [show deep-topic]
    ]
    [   write clipboard:// flat-topic/text: toggle-brackets flat-topic/text
        flat-topic/state: flat-topic/user-data/active?: yes
        deep-topic/state: deep-topic/user-data/active?: no 
        show flat-topic
        if deep-topic/user-data/visible? [show deep-topic]
    ]
    deep-topic: toggle  " " 200x18 left no-wrap silver + white yellow font [shadow: style: none colors: [0.0.0 0.0.0]]
        with [user-data: context [active?: no visible?: yes]]
    [   if deep-topic/user-data/active? [deep-topic/text: toggle-brackets deep-topic/text]
        write clipboard:// deep-topic/text 
        flat-topic/state: flat-topic/user-data/active?: no
        deep-topic/state: deep-topic/user-data/active?: yes 
        show [flat-topic deep-topic]
    ]
    [   write clipboard:// deep-topic/text: toggle-brackets deep-topic/text
        flat-topic/state: flat-topic/user-data/active?: no
        deep-topic/state: deep-topic/user-data/active?: yes 
        show [flat-topic deep-topic]
    ]
    topics-list: text-list (0x1 * HEIGHT + 200x0) font [size: 12] ;edge [size: 1x1 color: 0.0.0 effect: none]
        with [update-slider: does [sn: 1 sld/redrag lc / max 1 length? head lines]]
        data ["Choose a letter from the index." "Right click on index button updates data."]
    [   select-topic]
    at 0x0 disable: box 0x0 effect [merge grayscale luma +33 blur blur]
    at 0x0 dialog:  box 0x0 edge [size: 2x2 effect: 'ibevel] 
        with
        [   pane: layout/offset 
            [   backdrop yellow origin 4x4
                text "Updating topics ..." bold font-size 12
                update: text no-wrap (reform [length? topic-index "moment(s) please."])
                progress-bar: progress blue red with [data: 0] ;edge [size: 1x1 color: 0.0.0 effect: none]
                return
            ] 0x0
]       ]


;-- toggle-brackets --
;
toggle-brackets: func
[   topic] 
[   any 
    [   if all [#"[" <> first topic #"]" <> last topic]
        [   rejoin ["[" topic "]"]]
        if all [#"[" = first topic #"]" = last topic]
        [   copy/part at topic 2 -2 + length? topic]
]   ]

;-- update-topics --
;
update-topics: func 
[   "Extract the topic tags for a given letter from rebol.org mailing list archive."
    letter [char! none!] "The letter to extract (none for all)"
/local
    page updated-topics topic depth uid rule
]
[   debug "UPDATE-TOPICS entered"
    
    either all
        [   none? letter
            request/confirm "Update all topics at once?"
        ]
    [   disable/size: topics-selector/size
        dialog/size: 2 * dialog/edge/size + dialog/pane/size
        center-face/with dialog topics-selector
        dialog/offset/y: 64
        show topics-selector
        for i 1 length? topic-index 1
        [   update-topics first to string! topic-index/:i
            progress-bar/data: i / length? topic-index
            update/text: reform [- i + length? topic-index "moment(s) please."]
            show [progress-bar update]
        ]
        disable/size: dialog/size: 0x0 
        show topics-selector
        return
    ]
    [   if none? letter [return]]
    
    append clear topics-list/data "Updating ..."
    topics-list/update-slider
    show topics-list
    
    forever
    [   either attempt 
            [   debug reform ["updating" letter " ..."]
                page: read join http://www.rebol.org/cgi-bin/cgiwrap/rebol/ml-topic-index.r?i=
                    either letter = #"0" [#"2"] [letter]
            ]
        [   debug "    ... okay"
            break
        ]
        [   debug "    ... error"
            if true <> request/type "Couldn't retrieve data.^/Try again?" 'alert
            [   debug "UPDATE-TOPICS exited"   
                return
    ]   ]   ]
    updated-topics: copy []
    depth:  0
    uid:    copy ""
    rule:
    [   <ul>
        (   depth: depth + 1)
        some
        [   <li>
            [   opt ["<a href" thru ">"]
                copy topic to "<" 
                (   append updated-topics head insert/dup append trim topic uid "    " depth - 1
                    append uid " "
                )
                opt [</a> to "<"]
                any rule 
            ]
            </li>
        ]
        </ul>
        (   depth: depth - 1)
    ]
    parse page [to <ul> any rule to end]
    if empty? updated-topics [append updated-topics copy "    (no topics)"]
    change/only next find topics letter updated-topics
    show-topics letter
    debug "UPDATE-TOPICS exited"
] 

;-- show-topics --
; 
show-topics: func
[   letter [char!]]
[   debug "SHOW-TOPICS entered"
    topics-letter/text: uppercase to string! letter
    show topics-letter
    either topics/:letter
    [   append clear topics-list/data select topics letter
        topics-list/update-slider
        show topics-list
    ]
    [   update-topics letter]
    
    debug "SHOW-TOPICS exited"
]

;-- select-topic --
;
select-topic: func
[   /local tag tags string topics topic deep letter]
[   flat-topic/text: rejoin ["[" trim copy topics-list/picked/1 "]"]
    deep-topic/state: not flat-topic/state: true
    write clipboard:// flat-topic/text
    
    deep: copy ""
    letter:   first trim copy topic: topics-list/picked/1
    
    hierachy: find topics-list/data topic
    
    forever
    [   insert deep rejoin ["//" trim copy topic: hierachy/1]
        if 0 = topic-level topic [break]
        until 
        [   hierachy: back hierachy 
            (topic-level hierachy/1) < topic-level topic
        ]
    ]
    deep-topic/text: rejoin ["[" next next deep "]"]
    
    deep-topic/user-data/active?: no
    show flat-topic
    either deep-topic/text = flat-topic/text
    [   deep-topic/user-data/visible?: no  hide deep-topic]
    [   deep-topic/user-data/visible?: yes show deep-topic]
    
]

topic-level: func [topic [string!] /local level] [level: 0 parse/all topic [some ["    " (level: level + 1)] to end] level]

topics-selector: view/new/offset layout topics-selector 2x28
topics-list/pane/edge: make system/standard/face/edge [size: 1x1 color: 0.0.0 effect: none]
topics-list/pane/pane/1/edge: make system/standard/face/edge [size: 1x1 color: 0.0.0 effect: none]
topics-list/pane/pane/2/edge: make system/standard/face/edge [size: 1x1 color: 0.0.0 effect: none]
update-topics none

do-events
