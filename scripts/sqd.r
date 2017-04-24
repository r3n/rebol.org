rebol[
  date: 1-oct-2005
  file: %sqd.r
  title: "Stack, queue and deque functions"
  author: "Sunanda"
  purpose: "Implement stack, queue and deque data structures"
  version: 0.0.1
  library: [
    platform: [all]
    type: [function tool]
    level: 'intermediate
    domain: [math scientific]
    license: 'bsd
    tested-under: 'win
    support: "ask me!"
	]
]

;; -----------------------------------------------------------------------
;; Stack: LIFO: last in, first out: add to top, remove from top
;; Queue: FIFO: first in, first out: add to top, remove from bottom
;; Deque: add/remove from either end

;; For documentation:
;; http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=sqd.r
;; -----------------------------------------------------------------------


sqd: make object! [

;; =----------------------=
;;  redefine words we need
;; =----------------------=
_make:    get in system/words 'make
_length?: get in system/words 'length?
_type?:   get in system/words 'type?



;; =----=
;;  make
;; =----=

make: func [
    /items p-items [integer!]
][
  if not items [p-items: 100]
  return _make object! [
      type: "stack"
      data: _make block! p-items
      ]
]



;; =-------=
;;  length?
;; =-------=

length?: func [stack-name [object!]
][
 return _length? stack-name/data
]



;; =-----=
;;  type?
;; =-----=

type?: func [stack-name [object!]
][
 return copy stack-name/type
]



;; =-----=
;;  probe
;; =-----=


probe: func [stack-name [object!]
][
 return copy/deep stack-name/data
]



;; =--------=
;;  to-stack
;; =--------=

to-stack: func [stack-name [object!]
][
  stack-name/type: "stack"
  return true
]



;; =--------=
;;  to-queue
;; =--------=

to-queue: func [stack-name [object!]
][
  stack-name/type: "queue"
  return true
]



;; =--------=
;;  to-deque
;; =--------=

to-deque: func [stack-name [object!]
][
  stack-name/type: "deque"
  return true
]



;; =----=
;;  push
;; =----=

push: func [stack-name [object!]
            item
 /bottom
][
 either all [stack-name/type = "deque" bottom]
   [
    either block? item  [append/only stack-name/data item]
                        [append stack-name/data item]
   ]
   [
    either block? item  [insert/only stack-name/data item]
                        [insert stack-name/data item]
   ]
 return item
]



;; =---=
;;  pop
;; =---=

pop: func [stack-name [object!]
 /bottom
 /local
  pop-item
][
 if any [stack-name/type = "stack"
         all [stack-name/type = "deque" not bottom]
        ]
    [
     pop-item: stack-name/data/1
     stack-name/data: next stack-name/data
     return pop-item
    ]


;; queue or deque with /bottom
    if 0 = _length? stack-name/data [return none]
    pop-item: last stack-name/data
    remove back tail stack-name/data
    return pop-item
]



;; =----=
;;  peek
;; =----=

peek: func [stack-name [object!]
 /bottom
 /local
  pop-item
][
 if any [stack-name/type = "stack"
         all [stack-name/type = "deque" not bottom]
        ]
    [
     pop-item: stack-name/data/1
     return pop-item
    ]


;; queue or deque with /bottom
    if 0 = _length? stack-name/data [return none]
    pop-item: last stack-name/data
    return pop-item
]



;; =------=
;;  rotate
;; =------=

rotate: func [stack-name [object!]
 /bottom
 /local
  item1
  item2
][

 if (_length? stack-name/data) < 2
       [return false] ;; not enough items to rotate

 if any [stack-name/type = "stack"
         all [stack-name/type = "deque" not bottom]
        ]
    [
        ;; swap top two items
        ;; ------------------
     insert stack-name/data stack-name/data/2
     remove at stack-name/data 3
     return true
    ]

 if stack-name/type = "queue"
   [
    ;; swap top and bottom
    ;; -------------------
     insert stack-name/data last stack-name/data
     append stack-name/data stack-name/data/2
     remove at stack-name/data 2
     remove at stack-name/data (-1 + _length? stack-name/data)
     return true
    ]

 ;; Must be a /bottom deque -- so
 ;; swap bottom and its predeccessor
 ;; --------------------------------

 append stack-name/data pick stack-name/data (-1 + _length? stack-name/data)
 remove at stack-name/data (-2 + _length? stack-name/data)
 return true
]


]  ;; object



