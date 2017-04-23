rebol [
   title: "TSN: Tranched serial number server"
   author: "Sunanda"
   date: 30-apr-2007
   purpose: "Quick, safe way of allocating categorized unique serial numbers"
   version: 0.0.1
   file: %tsn.r
   license: 'mit
   history: [
      [0.0.0  3-jun-2004 "Written"]
      [0.0.1 30-apr-2007 "First public release"]
   ]
   library: [
      level: 'intermediate
      platform: [all]
      type: [function tool]
      domain: [files markup database]
      tested-under: [win unix mac]
      support: none
      license: [mit]
      see-also: [%rse-ids.r]
      ]
   ]


tsn-api: make object! [

if not value? 'rse-ids [do %rse-ids.r]  ;; need this utility


;; Define tsn-set template
;; =======================
tsn-template: make object! [
           next-tsn: 1
   smallest-tranche: 100
      growth-factor: 1.5
            cat-map: copy []
            tsn-map: copy []
    ]





   make-new-set: func [
;; ==================================================
   /local
][
 return make tsn-template []
]





   get-tsn: func [
;; ==================================================
   tsn-set [object!]
   cat-id [integer! string!]
  /local
  cm-ptr        ;; cat-map pointer
  ct-ptr        ;; current cat-map tranche pointer
  curr-tsn
  next-tsn
  cat-length
  cat-sid       ;; category serial id
][

cm-ptr: find/skip tsn-set/cat-map cat-id 2

;;  Handle new category
;;  ===================

if none? cm-ptr [
   append tsn-set/cat-map cat-id
   curr-tsn: tsn-set/next-tsn
   next-tsn: to-pair reduce [curr-tsn curr-tsn + tsn-set/smallest-tranche]
   append/only tsn-set/cat-map reduce [1 + length? tsn-set/tsn-map next-tsn + 1x0]

   append tsn-set/tsn-map to-pair reduce [curr-tsn tsn-set/smallest-tranche]
   append tsn-set/tsn-map -1 + length? tsn-set/cat-map

   tsn-set/next-tsn: tsn-set/next-tsn + tsn-set/smallest-tranche
   return reduce [cat-id 1 curr-tsn "nc"]
]


;; old cat: Handle unexhausted tranche
;; ===================================

ct-ptr: first next cm-ptr
if pair? last ct-ptr [
   curr-tsn: first last ct-ptr
   temp: to-pair reduce [1 + first last ct-ptr second last ct-ptr]
   either temp/2 = temp/1 [
       remove back tail ct-ptr
      ][
      poke ct-ptr length? ct-ptr temp
     ]
    cat-sid: _get-cat-sid tsn-set ct-ptr
    return reduce [cat-id cat-sid curr-tsn "ot"]
  ]


;; old cat: Handle extending latest tranche
;; ========================================
;; If the current category's final most recent
;; tranche is also the most recent tranche
;; issued, then we can just extend it by 1.

if all [1 + (last ct-ptr) = length? tsn-set/tsn-map
        tsn-set/next-tsn = ((first pick tsn-set/tsn-map -1 + length? tsn-set/tsn-map)
                          + (second pick tsn-set/tsn-map -1 + length? tsn-set/tsn-map))
        ][
    curr-tsn: tsn-set/next-tsn
    tsn-set/next-tsn: tsn-set/next-tsn + 1

    poke tsn-set/tsn-map -1 + length? tsn-set/tsn-map
         0x1 + pick tsn-set/tsn-map -1 + length? tsn-set/tsn-map
    cat-sid: _get-cat-sid tsn-set ct-ptr
    return reduce [cat-id cat-sid curr-tsn "et"]

  ]


;; Old cat: need a new tranche
;; ===========================


;; step 1: count cat length to get new tranche size
;; ------------------------------------------------

 cat-length: 0
 foreach tsn ct-ptr [
    cat-length: cat-length + second pick tsn-set/tsn-map tsn
   ]
   cat-length: to-integer (cat-length * tsn-set/growth-factor)
   cat-length: maximum cat-length tsn-set/smallest-tranche


;; step 2: allocate
;; ----------------

 curr-tsn: tsn-set/next-tsn
 tsn-set/next-tsn:  curr-tsn + cat-length


 append tsn-set/tsn-map to-pair reduce [curr-tsn  cat-length]
 append tsn-set/tsn-map index? cm-ptr

 append ct-ptr -1 + length? tsn-set/tsn-map
 append ct-ptr to-pair reduce [1 + curr-tsn curr-tsn + cat-length]
 cat-sid: _get-cat-sid tsn-set ct-ptr
 return reduce [cat-id cat-sid curr-tsn "nt"]
]




   remove-category: func [
;; ==================================================
   tsn-set [object!]
   cat-id [string! integer!]
  /local
   cm-ptr
   ct-ptr
   tsn-map-new
   cat-map-new
   removed indexes
   temp
][


cm-ptr: find/skip tsn-set/cat-map cat-id 2

if none? cm-ptr [return true]  ;; does not exist

tsn-map-new: copy []
removed-indexes: copy []
for nn 1 length? tsn-set/tsn-map 2 [
   either (pick tsn-set/tsn-map nn + 1) <> index? cm-ptr [
       append tsn-map-new pick tsn-set/tsn-map nn
       append tsn-map-new either
                    (pick tsn-set/tsn-map nn + 1) > index? cm-ptr
                        [-2 + pick tsn-set/tsn-map nn + 1]
                        [pick tsn-set/tsn-map nn + 1]
       ][
       insert removed-indexes nn
       ]
]

cat-map-new: copy []
foreach [cat tsns] tsn-set/cat-map [
    if cat <> cat-id [
       append cat-map-new cat
       temp: copy []
       foreach tsn-seq tsns [
           if integer? tsn-seq [
               foreach rem removed-indexes [
                  if rem < tsn-seq [tsn-seq: tsn-seq - 2]
                 ]
           ]
           append temp tsn-seq
       ]
       append/only cat-map-new temp
     ]
]

tsn-set/cat-map: copy cat-map-new
tsn-set/tsn-map: tsn-map-new

return true
]





   get-cat-id: func [
;; ==================================================
   tsn-set [object!]
   target-tsn [integer!]
  /local
   base-tsn
   cat-id
   cat-ptr
   tsns
   cat-sn
   cached-tsns
   decompacted-tsns
][
cached-tsns: []
decompacted-tsns: []
base-tsn: none
cat-id: none

foreach [t-pair c-id] tsn-set/tsn-map [
   if all [target-tsn >= t-pair/1
           target-tsn < (t-pair/1 + t-pair/2) ][
              base-tsn: t-pair
              cat-id: c-id
              break
      ]
]

if none? base-tsn [return none]    ;; not allocated

cat-ptr: pick tsn-set/cat-map cat-id + 1
cat-id: pick tsn-set/cat-map cat-id
tsns: _get-tsn-list tsn-set cat-ptr


;; Cheap and dirty way to do this:
;; ------------------------------
;; Should really code a quick
;; search to get the index position

either all [0 = length? decompacted-tsns
            0 = length? cached-tsns ][
    insert cached-tsns tsns
    insert decompacted-tsns rse-ids/decompact tsns
   ][
    if tsns <> cached-tsns [
       clear cached-tsns
       clear decompacted-tsns
       insert cached-tsns tsns
       insert decompacted-tsns rse-ids/decompact tsns
      ]
  ]


 cat-sn: find decompacted-tsns target-tsn
 if none? cat-sn [return none]

 return reduce [cat-id index? cat-sn target-tsn]
]






   get-all-categories: func [
;; ==================================================
   tsn-set [object!]
  /local
][
 return sort extract tsn-set/cat-map 2
]






   get-all-tsns-for-cat: func [
;; ==================================================
   tsn-set [object!]
   cat-id [integer! string!]
  /local
   cm-ptr
   ct-ptr
   tsns
][

cm-ptr: find/skip tsn-set/cat-map cat-id 2
if none? cm-ptr [return none]   ;; no such category

ct-ptr: first next cm-ptr
tsns: _get-tsn-list tsn-set ct-ptr
return rse-ids/decompact copy tsns
]



;; ===============================
;; Functions for internal use only
;; ===============================


   _get-tsn-list: func [
;; ==================================================
   tsn-set [object!]
   ct-ptr [block!]
   /local
    adjustment
    tsns
][

adjustment: 0x0
tsns: copy []
foreach entry ct-ptr [
   either integer? entry [
      append tsns pick tsn-set/tsn-map entry
      ][
      adjustment: entry
   ]
]

if adjustment <> 0x0 [
   poke tsns length? tsns to-pair reduce [first last tsns adjustment/1 - first last tsns]
   ]

return tsns
]






   _get-cat-sid: func [
;; ==================================================
   tsn-set [object!]
   ct-ptr [block!]
   /local
    cat-length
][
   cat-length: 0
   foreach entry _get-tsn-list tsn-set ct-ptr [
      cat-length: cat-length + second entry
      ]
 return cat-length
]


] ;; end of tsn object