rebol [
     file: %skimp-my-altme.r
    title: "Altme world search"
  purpose: "Indexes and searches Altme worlds"
     date: 21-may-2007
  version: 0.0.2

    Library: [
        level: 'intermediate
        platform: 'all
        type: [package tool function]
        domain: [database text text-processing]
        tested-under: [win linux]
        support: none
        license: none
        see-also: [%skimp.r]
        ]
    history: [
        [0.0.1 20-apr-2007 "experimental first release"]
        [0.0.2 21-may-2007 "better API for integrators"]
       ]
]


;; skimp-my-altme.r
;; ================
;; API for indexing and searching Altme Worlds.

;; Record prefix cheat sheet
;; =========================
;;
;;  acr -- altme chat record
;; acsf -- altme chat status file [chat/chatNN file for current user]
;; acsr -- altme chat status record (entry in acsf]
;;  agr -- altme group record: the whole user.set
;;  agh -- altme group header: a line from the altme user set
;;   wr -- world record: from our sma-config.r
;;  cwr -- current world record: the one we are working on
;; sodr -- skimp owner data record: where we hold our config info
;; sigh -- skimp indexed-group's header -- entry in the sodr for groups



if not value? 'tsn-api [do %tsn.r]
if not value? 'extend-an-object [do %extend-an-object.r]
if not value? 'rse-ids [do %rse-ids.r]
if not value? 'skimp [do %skimp.r]




sma-api: make object! [


;; ===========================================
templates: make object! [

   agh: [             ;; altme group header
       "group-id" none
       "group-name" "description"
      ]

 acsr: [              ;; altme chat state record
        "group-id"
        none
        "apid-latest"   ;; latest altme post id
        ]

sigh: [              ;; skimp indexed-group's header
    "agid"           ;; Altme group-id for this sigh
    "apid-indexed"   ;; latest altme post-id indexed
    "spid-last"      ;; latest skimp post-id
    ]

]


  world-template: make object! [
              name: "Unknown"
         user-name: "guest"
         user-agid: 0       ;; altme group-id for user
            active: true
              path: what-dir
      index-folder: what-dir
  index-signatures: copy []
    updates-needed: copy/deep [ [] [] [] [] []]  ;; new, old/changed, dead, old/same ignored
       last-action: copy []
       groups-list: copy []
            search: make object! [
              raw-target: copy ""
            actual-target: copy []
           raw-hits-count: 0
           results-window: 1x200
                 raw-hits: copy []
              actual-hits: copy []
          ]
       ]

;; ===========================================


;; Global parameters
;; =================
;; Usually, the current world and
;; its details....saves having
;; to always pass to all functions
;; --------------------------------

      cwr: none    ;; current world record
      agr: none    ;; current altme group record
     sodr: none    ;; current skimp owner data record
     acsf: none    ;; current altme chat status file

clear-globals: does [
      cwr: none
      agr: none
     sodr: none
     acsf: none
  ]

config: none


;; Caches
;; ==================================
;; Allows us quick access to records
;; we may otherwise read many times

groups-cache: copy []
chat-record-cache: copy []

;; ==================================

;; Functions to action all worlds
;; ==============================
;; ie to drive lower level stuff
;; for each world that is active
;; =============================

aaw: make object! [



   get-updates-needed: func [
;; ===========================================
   world-list [block!]
  /local
][


;; Clear the caches so we read fresh data
;; --------------------------------------

 clear groups-cache
 clear chat-record-cache

 foreach world world-list [
    if world/active [
       cwr: world
       agr: get-groups             ;; altme groups
       sodr: get-skimp-owner-data  ;; index header
       acsf: get-altme-chat-state  ;; chat status
       sma-api/get-updates-needed
       update-last-action "get updates needed"
      ]
  ]
 clear-globals
 return true

]



   get-groups-list: func [
;; ================================================
   world-list [block!]
  /local
][


 foreach world world-list [
    if world/active [
       cwr: world
       agr: get-groups             ;; altme groups
       sma-api/get-groups-list
       update-last-action "get updates needed"
      ]
  ]
 clear-globals
 return true

]





   update-index: func [
;; ================================================
   world-list [block!]
   /new-groups
   /old-groups
   /dead-groups
   /local
   iuas
   result-block
   updated?
][


 result-block: copy []
 foreach world world-list [
    updated: false
    if world/active [
        cwr: world
        agr: get-groups             ;; altme groups
        sodr: get-skimp-owner-data  ;; index header
        acsf: get-altme-chat-state  ;; chat status

        actions: copy []
        append result-block world/name
        if all [new-groups 0 <> length? world/updates-needed/1] [
           create-new-groups/defer world/updates-needed/1
           update-last-action "new groups added"
           updated?: true
          ]
        if all [old-groups 0 <> length? world/updates-needed/2] [
           update-old-groups/defer world/updates-needed/2
           update-last-action "old groups updated"
           updated?: true
          ]
        if all [dead-groups 0 <> length? world/updates-needed/3][
           remove-dead-groups/defer world/updates-needed/3
           update-last-action "dead groups removed"
           updated?: true
          ]
        if updated? [
            append/only result-block actions
            write-skimp-cache cwr
            ]
   ]
]
 clear-globals
 return result-block

]



   search: func [
;; ======================================
  world-list [block!]
  target [string! block!]
  /window results-window
][

 if not pair? results-window [results-window: 1x200]
 either window [
    results-window/1: maximum 1 results-window/1  ;;ensure in sensible range
    results-window/2: maximum 1 results-window/2
    if results-window/2 < results-window/1 [
       results-window: to-pair reduce [results-window/2 results-window/1]
       ]
   ][
    results-window: 1x200
  ]


 foreach world world-list [
    if world/active [
        cwr: world
        sodr: get-skimp-owner-data  ;; index header
        cwr/search/results-window: results-window
        sma-api/search target
        update-last-action rejoin ["searched for " mold target]
       ]
   ]
 clear-globals
 return true
]




   convert-raw-hits: func [
;; ======================================
  world-list [block!]
  /flat
  /local
   temp
][

 foreach world world-list [
    if world/active [
        cwr: world
        sodr: get-skimp-owner-data  ;; index header
        world/search/actual-hits: sma-api/convert-raw-hits world/search/raw-hits

        either flat [
           sort/compare/skip world/search/actual-hits [1 2] 2
          ][
           world/search/actual-hits: convert-to-grouped-by-group world/search/actual-hits
          ]
        update-last-action "converted hits "
       ]
   ]
 clear-globals
 return true
]





   create-results-html: func [
;; ====================================================
  world-list [block!]
  /context cont
  /local
   acr
   html
][

 if not value? 'sma-api-html [do %skimp-my-altme-html.r]

 if not pair? cont [cont: 0x0]
 sma-api-html/create-results-html/context world-list cont

]



   search-and-display: func [
;; ================================================
  world-list [block!]
  target [string! block!]
  /window results-window
  /context cont
][

print [now/precise "searching...."]

sma-api/aaw/search/window world-list target results-window

print [now/precise "converting...."]
sma-api/aaw/convert-raw-hits world-list

print [now/precise "generating html...."]
sma-api/aaw/create-results-html/context world-list cont
print [now/precise "done"]
return true
]



]  ;; end of aaw (action all worlds) object











   create-object: func [
;; ===============================================
     target [block!]
   template [block!]
   /in-place
  /local
   new-obj
][
  ;; Create object
  ;; =============
  ;;  ----data---  +  ---template----   ==> --------- object ------------
  ;;  ["a" 55 -4]  +  ["zz" none "mm"]  ==> make object! [zz: "a" mm: -4]
  ;; Useful way of not having to use index numbers for things in a block

  new-obj: make object! []
  for nn 1 length? template 1 [
      if string? template/:nn [
         new-obj: make new-obj compose [(to-set-word template/:nn) target/:nn]
         ]
  ]

  if not in-place [return new-obj]

  clear target
  insert target new-obj
  return true

]




   create-block: func [
;; ===============================================
     target [object!]
   template [block!]
   /in-place
  /local
   new-block
][
  ;; Create object
  ;; =============
  ;;  --------- object ------------ +  ---template----   ==> -----data----
  ;;  make object! [zz: "a" mm: -4] +  ["zz" none "mm"]  ==> ["a" none -4]
  ;; Useful way of not having to use index numbers for things in a block

new-block: copy []
foreach item reduce template [
  either none? item [
     append new-block none
   ][
     append new-block get in target to-word item
    ]
  ]

 return new-block

]




   group-by: func [
;; ==============================================
   key
   item
   block [block!]
  /local
   ptr
][
 if ptr: find block key [
    insert first next block item
    return true
   ]

 insert/only block reduce [item]
 insert block key
 return true
]




   convert-to-grouped-by-group: func [
;; ===================================================
   data[block!]
   /local
    temp
    grouped-data
 ][

 temp: copy data
 grouped-data: copy []
 sort/compare/skip/reverse temp [1 2] 2
 foreach [group-id post-id] temp [
     group-by group-id post-id grouped-data
    ]
 return grouped-data
 ]






   get-worlds: func [
;; ===============================================
  /local
   worlds-list
   names-seen
][

  ;; get the config too:
  ;; ------------------

  config: make object! [
     results-file: %sma-results.html
     ]

   error? try [
      config: extend-an-object config first reduce load %sma-config.r
      ]


   worlds-list: copy []
   names-seen: copy []

   foreach world reduce first load/all %sma-worlds.r [
      world: extend-an-object world world-template
      either find names-seen world/name [
         print ["sma-100: world ignored: duplicate name: " world/name]
      ][
         update-last-action/world "opened" world

            ;; Call set-world-status for an active
            ;; world, as this triggers some start-up
            ;; actions
         if world/active [
            set-world-status world 'active
            ]

         world/user-agid: get-user-group-id world
         cwr: world
         either error? try [get-altme-chat-state][
             print ["sma-101: world ignored: user record not found: " world/name  world/user-name]
            ][
             append worlds-list world
             append names-seen world/name
            ]
      ]
    ]
  sort/compare worlds-list func [a b] [return a/name < b/name]
  cwr: none
  return worlds-list


]




   save-worlds: func [
;; ===============================================
   worlds-list [block!]
  /local
   file-source
   temp
][

 file-source: copy ""
 append file-source rejoin [";; Skimp-my-altme worlds" newline]
 append file-source rejoin [";; =====================" newline]

 append file-source rejoin ["" newline newline "[" newline newline]

 foreach world worlds-list [
    if object? world  [    ;; lets drop any weirdness right now
        temp: make object! copy/deep third world
        clear temp/groups-list  ;; too big and volatile to save
       ]
      append file-source mold temp
      append file-source rejoin ["" newline newline]
    ]

 append file-source rejoin ["" newline newline "]" newline]

 write %sma-worlds.r file-source


 return true

]



   get-user-group-id: func [
;; ===============================================
    world [object!]
  /local
   agid
][

 cwr: world
 agr: get-groups

agid: 2    ;; default is guest
foreach agh next agr [  ;; skips header
   if agh/3 = world/user-name [
        agid: agh/1
        break
      ]
  ]

 cwr: none
 agr: none
 return agid

]




   set-world-status: func [
;; ==============================================
   world [object!]
   status [string! word!]
][
  if not string? status [status: form status]


         ;; check-world and create-index
         ;; may override the status of
         ;; active if they find problems
         ;; with the folder paths
  if status = "active" [
     world/active: true
     check-world  world    ;; see the path points to an altme world
     create-index world    ;; provide it does not already exist
     return true
     ]


  if status = "inactive" [
     world/active: false
     skimp/flush-cache get-index-name world
     clear groups-cache       ;; overkill: only need to do so...
     clear chat-record-cache  ;; overkill: ...for current world. To be fixed!
     return true
     ]

  return "set-world-status: bad status value"

]





   update-last-action: func [
;; ===============================================
   action [string!]
  /world
   world-rec [object!]
  /local
   target
][
 target: cwr
 if world [target: world-rec]

 append target/last-action rejoin [action " // " now]
 while [25 < length? target/last-action][
     target/last-action: skip target/last-action 1
     ]
 return true

]





   get-groups: func [
;; ===============================================
   /local
    ptr
][

 ptr: select groups-cache cwr/name
 if not none? ptr [return ptr]

 append groups-cache cwr/name
 append/only groups-cache reduce load join cwr/path "users.set"
 return last groups-cache
]







   get-groups-list: func [
;; ===============================================
   /local
   agr-map
][

  agr-map: copy []
  foreach item next agr [
     append agr-map item/1               ;; group id (integer)
     append agr-map second next item      ;; group id (name)
     append/only agr-map next item  ;; other group details
     ]

  sort/skip agr-map 3
  cwr/groups-list: to-hash agr-map
  clear agr-map
  return true

]





   get-altme-chat-state: func [
;; ===============================================
  /local

][
 return reduce load read rejoin [cwr/path "chat/chat" cwr/user-agid]

]






   get-altme-group-header: func [
;; ===============================================
   agr [block!]
   target [integer!]
][
  ;; spins through an altme group record to
  ;; find the target group-id
 foreach agh next agr [
     if agh/1 = target [return agh]
     ]
 return none
]





   get-chat-record: func [
;; ===============================================
       cwr  [object!]
   chat-id [integer!]
   /local
    chat-rec-name
    chat-rec
][
 chat-rec-name:  rejoin [cwr/path "chat/" chat-id ".set"]

 chat-rec: select chat-record-cache chat-rec-name
 if block? chat-rec [return chat-rec]

 if not exists? chat-rec-name [return none]

 chat-rec: load/all read chat-rec-name
 insert/only chat-record-cache chat-rec
 insert chat-record-cache chat-rec-name
 return chat-rec


]





   get-user-details: func [
;; ==============================================
   user-id [integer!]
  /name
  /color
  /local
  user-rec
   user-name
][

 user-rec: find cwr/groups-list user-id

 if none? user-rec [return "unknown"]
  user-rec: first next next user-rec

 if name [return user-rec/2]

 if color [
    error? try [return last user-rec/5]
    ]

 return "unknown(2)"
]






   get-updates-needed: func [
;; ===============================================
  /local
   activity-rec
   active-list
   sigh
   agh
   to-be-indexed?
][
  ;; get-activity-set
  ;; ================
  ;; Analyses the Altme Chat Status File
  ;; and the Skimp Index Group Header
  ;; to work out what groups need updating


active-list: copy []
cwr/updates-needed: copy/deep [ [] [] [] [] []]   ;; new, old, dead, unchanged, ignored

foreach acsr  acsf [
   acsr: create-object acsr templates/acsr
   agh: sma-api/get-altme-group-header agr acsr/group-id

   to-be-indexed?: false
   error? try [
      foreach sig cwr/index-signatures [
          if find agh/4 sig [to-be-indexed?: true]
          ]
       if 0 = length? cwr/index-signatures [to-be-indexed?: true]
      ]

   if not to-be-indexed? [append cwr/updates-needed/5 acsr/group-id]

   if all [to-be-indexed? acsr/apid-latest > 0] [
      sigh: select/skip sodr/sigh acsr/group-id 2
      either none? sigh [
         append cwr/updates-needed/1 acsr/group-id       ;; new group
       ][
          sigh: create-object first sigh templates/sigh
          append active-list acsr/group-id
          either acsr/apid-latest > sigh/apid-indexed [
              append cwr/updates-needed/2 acsr/group-id  ;; old group in need of change
             ][
              append cwr/updates-needed/4 acsr/group-id  ;; old group with no changed needed
          ]
       ]
    ]
  ]

;; Find groups that are deleted
;; ----------------------------

append cwr/updates-needed/3 difference active-list extract sodr/sigh 2

return true
]






   get-index-name: func [
;; ===============================================
   cwr [object!]
][

   return rejoin [
       cwr/index-folder
       "sma-index-"
       cwr/name
      ]
]







   check-world: func [
;; ===============================================
     cwr [object!]
   /local
][


if any [
    not exists? cwr/path
    not exists? join cwr/path "users.set" ][
      update-last-action/world rejoin ["altme world not found: " cwr/path] cwr
      cwr/active: false
   ]

 return true
]





   create-index: func [
;; ===============================================
     cwr [object!]
   /local
    sodr
][

    ;; only create if not already there
if skimp/index-exists? get-index-name cwr [return true]

    ;; create folder if needed
if not exists? cwr/index-folder [
   make-dir/deep cwr/index-folder
   update-last-action/world rejoin ["index folder created: " cwr/index-folder] cwr
   ]



sodr: make object! [
               world-name: cwr/name
                  created: now
             last-updated: 1-jan-1900  ;; before altme was created!
                     sigh: copy []     ;; skimp indexed-groups header
                     tsn: tsn-api/make-new-set ;; tsn control
    ]

 skimp/set-owner-data get-index-name cwr sodr

 skimp/set-config get-index-name cwr
    make object! [integer-document-names: true]

update-last-action/world "skimp index created" cwr
 return true
]







   get-skimp-owner-data: func [
;; ===============================================
][
 return get in skimp/get-index-information get-index-name cwr 'owner-data
]






   create-new-groups: func [
;; ===============================================
    new-group-ids [block!]
   /defer
   /local
    agh
][

 foreach ngi new-group-ids [
    agh: get-altme-group-header agr ngi
    if not none? agh [
       create-new-group ngi agh
       ]
   ]

  skimp/set-owner-data/defer get-index-name cwr sodr
 if not defer [write-skimp-cache  cw]
 return true

]






   create-new-group: func [
;; ===============================================
   ngi  [integer!]
   agh [block!]
  /local
   sigh
   acr
][
  acr: get-chat-record cwr ngi
  if none? acr [acr: copy []]  ;; empty chat record
  sigh: create-object [] templates/sigh
  agh: create-object agh templates/agh

  sigh/agid: ngi
  sigh/spid-last: 0

  sigh/apid-indexed: 0 ;; none indexed as yet
  sigh/spid-last: 1


    ;; Handle case where group is empty --
    ;; i.e. never been any posts. We add it to
    ;; our header so we don't keep showing it
    ;; as a new group. +-----------------------
    ;; ----------------+

  if any [none? acr all [block? acr (length? acr) < 2]][
     sigh/last-updated: now/precise
     append sodr/sigh ngi   ;; group number
     append/only sodr/sigh create-block sigh templates/sigh ;; empty sigh header
     return true
     ]

   ;; Handle case of new group which looks
   ;; like it has messages that need
   ;; indexing +--------------------------
   ;; ---------+


        ;; find first message to index
        ;; ---------------------------

  forever [
      acr: next acr
      if 0 = length? acr [break]   ;; no new messages to index
      if sigh/apid-indexed < acr/1/1 [break]  ; first one to index
     ]

  if 0 <> length? acr [
     index-new-posts ngi sigh acr
     ]

  append sodr/sigh ngi   ;; group number
  append/only sodr/sigh create-block sigh templates/sigh ;; empty sigh header
  return true

]





   update-old-groups: func [
;; ======================================================
    old-group-ids [block!]
   /defer
   /local
    agh
][

 foreach ngi old-group-ids [
    agh: get-altme-group-header agr ngi
     update-old-group ngi agh
   ]

skimp/set-owner-data/defer get-index-name cwr sodr
if not defer [write-skimp-cache  cw]
 return true

]






   update-old-group: func [
;; ===============================================
   ogi [integer!]
   agh [block!]
  /local
   sigh
   acr
   ptr
][
  acr: get-chat-record cwr ogi
  if none? acr [acr: copy []]  ;; empty chat record

  ptr: find sodr/sigh ogi
  if none? ptr [return true]  ;; should not happen!
  sigh: create-object first next ptr templates/sigh

        ;; find first message to index
        ;; ---------------------------

  forever [
      acr: next acr
      if 0 = length? acr [break]   ;; no new messages to index
      if sigh/apid-indexed > acr/1/1 [break] ;; new message
     ]

  if 0 <> length? acr [
     index-new-posts ogi sigh acr
     ]

poke sodr/sigh  1 + index? ptr create-block sigh templates/sigh

  return true

]






   remove-dead-groups: func [
;; ====================================
    ex-group-ids [block!]
   /defer
   /local
    agh
][

 foreach xgi ex-group-ids [
    remove-dead-group xgi
   ]
 skimp/set-owner-data/defer get-index-name cwr sodr
 if not defer [write-skimp-cache  cw]
 return true

]





   remove-dead-group: func [
;; ====================================
    xgi   [integer!]
   /local
    ptr
    skimp-doc-list
][
if not report-progress reduce [
    join "removing group " [xgi " -- may take some time"]] [
    return false]  ;; been cancelled

  ;; step 1: remove all skimped words
  ;; --------------------------------
     skimp-doc-list: tsn-api/get-all-tsns-for-cat sodr/tsn xgi
     if  not none? skimp-doc-list [
        skimp/remove-documents/defer get-index-name cwr skimp-doc-list
        ]


  ;; step 2: release tsn
  ;; -------------------
     tsn-api/remove-category sodr/tsn xgi

  ;; step 3: remove group details
  ;; ----------------------------

 ptr: find sodr/sigh xgi
 if not none? ptr [
    remove ptr
    remove ptr
    ]


return true
]





   index-new-posts: func [
;; ===============================================
   agid [integer!]
   sigh [object!]
   posts [block!]
  /local
  bulk-set
  bulk-text-size
  post
  agh
  group-name
][

if 0 = length? posts [return true]

bulk-set: copy []
bulk-text-size: 0


 agh: sma-api/get-altme-group-header agr agid
 group-name: copy ""
 error? try [append group-name join agh/3 ": "]
 error? try [append group-name agh/4]

if not report-progress reduce [
        join "Indexing group "
            [
            agid
            " "
            group-name
            ]
           ][
   return false]  ;; been cancelled


for nn 1 length? posts 1 [
    post: posts/:nn
    if post/1 > sigh/apid-indexed [
       get-next-spid sigh  ;; updates spid-last
       append bulk-set sigh/spid-last
       append bulk-set last post
       bulk-text-size: bulk-text-size + length? last post

       if any [  ;;true ;; for testing
               10 = length? bulk-set
               bulk-text-size > 4096 ][

          if not report-progress reduce [
               nn
               length? posts
                 ]
              [return false]  ;; been cancelled
          skimp/add-bulk-words/defer get-index-name cwr bulk-set
          bulk-set: copy []
          bulk-text-size: 0
          ]
       sigh/apid-indexed: post/1
       ]
    ]

  skimp/add-bulk-words/defer get-index-name cwr bulk-set
 clear bulk-set
 return true

]




   get-next-spid: func [
;; ===============================================
   sigh [object!]
  /local
   seq
][

 sigh/spid-last: third tsn-api/get-tsn sodr/tsn sigh/agid

return true
]






   search: func [
;; ==================================================
  target [string! block!]
 /local
][
 cwr/search/raw-target: copy target
either block? target [
    cwr/search/actual-target: unique copy target
   ][
    cwr/search/actual-target: skimp/extract-words-from-string/for-search get-index-name cwr target
   ]

cwr/search/raw-hits: skimp/find-words get-index-name cwr cwr/search/actual-target

cwr/search/raw-hits-count: length? cwr/search/raw-hits

;;  Clip results to results window
;;  ==============================
cwr/search/raw-hits: skip cwr/search/raw-hits cwr/search/results-window/1 - 1
cwr/search/raw-hits: copy/part cwr/search/raw-hits (1 + cwr/search/results-window/2 - cwr/search/results-window/1)


return true
]






   convert-raw-hits: func [
;; ==================================================
   tsns [block!]
   /grouped
  /local
   temp
   new-block
][

 new-block: make block! length? tsns
 foreach tsn tsns [
    temp: tsn-api/get-cat-id sodr/tsn tsn
    if none? temp [temp: copy [0 0] ]
     append new-block temp/1  ;; group-id
     append new-block temp/2  ;; post-id
   ]


return new-block
]






   get-posts: func [
;; =================================================
   world [object!]
   targets [block!]
   /context cont [pair!]
   /local
   temp
   posts-in-group
   matching-posts

][

 if 0 = length? targets [return copy [] ]   ;; nothing to do!

      ;; clip context to 15x15 maximum
      ;; ---------------------------
 if not context [cont: 0x0]
 cont/1: minimum maximum cont/1 0 15
 cont/2: minimum maximum cont/2 0 15


 cwr: world
 agr: get-groups             ;; altme groups
 sodr: get-skimp-owner-data  ;; index header


 ;; Handle the main loop whether
 ;; the data is grouped or not
 ;; ----------------------------

  matching-posts: copy []
  posts-in-group: copy []
  either block? targets/2 [
    foreach [group-id post-ids] targets [
       append matching-posts group-id
       posts-in-group: copy []
       foreach post-id copy expand-context post-ids cont [
          temp: get-post group-id post-id post-ids
          if block? temp [append/only posts-in-group next temp]
       ]
       append/only matching-posts copy posts-in-group
    ]
 ][

      ;; TODO this does not handle context
      ;; =================================
   foreach [group-id post-id] targets [
      temp: get-post group-id post-id targets
       if block? temp [append matching-posts temp]
   ]
 ]

 clear posts-in-group
 return matching-posts
]






   get-post: func [
;; =================================================
   group-id [integer!]
   post-id [integer!]
   posts-list [block!]
   /local
   post
   post-details
   post-text
   post-timestamp
   acr
][

 post-details: copy []
 append post-details group-id
 append post-details post-id

 acr: get-chat-record cwr group-id

  if error? try [
     post: pick acr post-id + 1
     post-text: last post
     post-timestamp: post/2
     ][return none]   ;; no such post / group

 append post-details post-timestamp


 append post-details post/4

 append post-details
        either find posts-list post-id ["h"] ["c"]  ;; hit or context

 append post-details post-text

 return post-details

]





   expand-context: func [
;; =================================================
   data [block!]
   context [pair!]
  /local
   expanded-data
   temp
][

;; eg data: [3 5 7 30]
;; context: 4x3   ;; means 4 before and 3 after
;; results: [1 2 3 4 5 6 7 8 9 10   26 27 28 29 30 31 32 33]
;; We weed zeroes, negatives and duplicates. But it can leave
;; numbers that are too high -- if the last post-id in the
;; group in question is 31, then the above example has returned
;; two impossible numbers (32, 33). That's for the caller
;; to sort out.

 if context = 0x0 [return data]

 expanded-data: copy []
 foreach item data [
    for nn context/1 1 -1 [
       temp: item - nn
       if temp > 0 [append expanded-data temp]
     ]
    append expanded-data item
    for nn 1 context/2 1 [append expanded-data item + nn]
    ]

  return unique expanded-data

]




   write-skimp-cache: func [
;; ==================================================
   world [object!]
   /local temp
][

  temp: report-progress reduce [join "Saving index for world " world/name]

  skimp/write-cache get-index-name world
  return temp
]



   report-progress: func [
;; ==================================================
   info [block!]
   /local
   prin-string
][


if function? get in sma-api 'sma-callback [
  return sma-callback cwr info
  ]


if 1 = length? info [
  print ""
  prin-string:  copy/part trim/lines copy mold info/1 60
  ]

if 2 = length? info [
   prin-string: join " ... " [
       copy/part mold (100 * info/1 / info/2) 5
       "% complete"
     ]
  ]

while [(length? prin-string) < 75][append prin-string " "]
error? try [insert prin-string join cwr/name " -- "]
insert prin-string cr
append prin-string cr
if 1 = length? info [append prin-string lf]

prin prin-string

return true
return random/only reduce [true false]

]


;; =============================================================
   sma-callback: none   ;;; replace with own function, if needed
;; ==============================================================


] ;; skimp-my-altme end




