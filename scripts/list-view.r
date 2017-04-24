REBOL [
  Title: "VID LIST-VIEW Face"
  File: %list-view.r
  Author: ["Henrik Mikael Kristensen"]
  Copyright: "2005, 2006 - HMK Design"
  Created: 2005-12-29
  Date: 2006-01-21
  Version: 0.0.28
  License: {
    BSD (www.opensource.org/licenses/bsd-license.php)
    Use at your own risk.
  }
  Purpose: {General purpose listview with many features for use in VID.}
  Note: {
    This file is available at:
    http://www.hmkdesign.dk/rebol/list-view/list-view.r
    Demo and testcases available at:
    http://www.hmkdesign.dk/rebol/list-view/list-demo.r
    Docs are available in makedoc2 format at:
    http://www.hmkdesign.dk/rebol/list-view/list-view.txt
    http://www.hmkdesign.dk/rebol/list-view/list-view.html
    http://www.hmkdesign.dk/rebol/list-view/list-view-history.txt
    http://www.hmkdesign.dk/rebol/list-view/list-view-history.html
  }
  History: [
    See: http://www.hmkdesign.dk/rebol/list-view/list-view-history.html
  ]
library: [ level: 'intermidiate 
platform: 'all 
type: [ tool] 
domain: [gui  graphics] 
tested-under: [windows linux] 
support: none 
license: [bsd] 
see-also: none 
] 
]

stylize/master [
  list-field: BOX with [
    size: 0x20
    edge: make edge [size: 1x1 effect: 'ibevel color: 240.240.240]
    color: 240.240.240
    font: none
    para: make para [wrap?: false]
    flags: [field tabbed return on-unfocus input]
    feel: make ctx-text/edit bind [
      redraw: func [face act pos][
        if all [in face 'colors block? face/colors] [
          face/color: pick face/colors face <> focal-face
        ]
      ]
      detect: none
      over: none
      engage: func [face act event][
        lv: get in f: face/parent-face/parent-face 'parent-face
        switch act [
          down [
            either equal? face view*/focal-face [unlight-text] [
              focus/no-show face]
              view*/caret: offset-to-caret face event/offset
              show face
          ]
          over [
            if not-equal? view*/caret offset-to-caret face event/offset [
              if not view*/highlight-start [view*/highlight-start: view*/caret]
                view*/highlight-end: view*/caret:
                  offset-to-caret face event/offset
                show face
            ]
          ]
          key [
            edit-text face event get in face 'action
            if event/key = #"^-" [
              either equal?
                index? find face/parent-face/pane face
                length? face/parent-face/pane [
                do f/finish-edit-action
              ][
                do f/tab-edit-action
              ]
            ]
          ]
        ]
      ]
    ] in ctx-text 'self
  ]
  list-text: BOX with [
    size: 0x20
    font: make font [
      size: 11 shadow: none style: none align: 'left color: black
    ]
    para: make para [wrap?: false]
    flags: [text]
    truncated?: false
    range: func [pair1 pair2 /local r p1 p2] [
      p1: min pair1 pair2
      p2: max pair1 pair2
      r: copy []
      for x p1/1 p2/1 1 [
        for y p1/2 p2/2 1 [insert tail r as-pair x y]
      ] r
    ]
    full-text: none
    pane: none
    feel: make feel [
      over: func [face ovr /local f lv pos] [
        lv: get in f: face/parent-face/parent-face 'parent-face
        if ovr [
          lv/over-cell-text: face/full-text
          all [lv/over-row-action do bind lv/over-row-action lv]
          if face/truncated? [
            ; Show tool tip
          ]
        ]
;        either all [
;          ovr lv/ovr-cnt <> face/data; long-enough
;        ][
;          lv/ovr: true
;          f/parent-face/ovr-cnt: face/data
;          ; delay-show f
;        ][lv/ovr: none]
      ]
      engage: func [face act evt /local f lv p1 p2 r fd] [
        lv: get in f: face/parent-face/parent-face 'parent-face
        if all [
          lv/lock-list = false
          any [act = 'down act = 'alt-down]
          face
        ][
          if lv/editable? [lv/hide-edit]
          if fd: face/data [
            pos: as-pair index? find face/parent-face/pane face face/data
            either all [
              evt/shift
              any [lv/select-mode = 'multi lv/select-mode = 'multi-row]
              lv/sel-cnt
              lv/selected-column
            ] [
              lv/range: copy reduce switch lv/select-mode [
                multi [[
                  as-pair
                    index? find lv/viewed-columns lv/selected-column lv/sel-cnt
                    pos
                ]]
                multi-row [[
                  as-pair 1 lv/sel-cnt as-pair
                    length? lv/viewed-columns
                    face/data
                ]]
              ]
              p1: min lv/range/1 lv/range/2
              p2: max lv/range/1 lv/range/2
              lv/range: copy []
              r: copy sort reduce [
                index? find lv/sort-index p1/2
                index? find lv/sort-index p2/2
              ]
              for x p1/1 p2/1 1 [
                for y r/1 r/2 1 [
                  insert tail lv/range as-pair x lv/sort-index/:y
                ]
              ]
            ][
; possibility to select a row or a column by setting the coordinate to zero
; a row would have the x set to zero, such as 0x6
; a column would have the y set to zero, such as 3x0
; this would eliminate the need for sel-cnt
; and base selections solely on coordinates and ranges
; this should be a future version...
; requires rewrite of the face iteration routine
              lv/range: copy []
              lv/selected-column: pick lv/viewed-columns pos/1
              lv/old-sel-cnt: lv/sel-cnt
              lv/sel-cnt: face/data
            ]
            switch act [
              down [all [lv/list-action do bind lv/list-action lv]]
              alt-down [all [lv/alt-list-action do bind lv/alt-list-action lv]]
            ]
            show f
          ]
          if act = 'up [row: face/row]
          if evt/double-click [
            if lv/lock-list = false [
              all [
                lv/doubleclick-list-action
                do bind lv/doubleclick-list-action lv
              ]
              if all [fd lv/editable?] [lv/show-edit]
            ]
          ]
        ]
      ]
    ]
    data: 0
    row: 0
  ]
  list-view: FACE with [
    hdr: hdr-btn: hdr-fill-btn: hdr-corner-btn: lst: lst-fld: scr: edt: none
    size: 300x200
    dirty?: fill: true
    click: none
    edge: make edge [size: 0x0 color: 140.140.140 effect: 'ibevel]
    ; even, odd, select, background
    colors: [240.240.240 220.230.220 180.200.180 140.140.140]
    color: does [either fill [first colors][last colors]]
    spacing-color: third colors
    old-data-columns: copy data-columns: copy indices: copy conditions: []
    old-viewed-columns: viewed-columns: header-columns: none
    old-widths: widths: px-widths: none
    old-fonts: fonts: none
    over-cell-text: none
    types: none
    truncate: false
    drag: false
    fit: true
    scroller-width: row-height: 20
    col-widths: h-fill: 0
    spacing: 0x0
    range: copy data: []
    resize-column: selected-column: sort-column: none
    editable?: false
    last-edit: none
    h-scroll: false
    sort-index: []
    sort-modes: [asc desc nosort]
    select-modes: [single multi row multi-row column]
    select-mode: third select-modes
    drag-modes: [drag-select drag-move]
    drag-mode: first drag-modes
    sort-direction: first sort-modes
    tri-state-sort: true
    paint-columns: false
    ovr-cnt: old-sel-cnt: sel-cnt: none
    cnt: ovr: 0
    idx: 1
    lock-list: false
    follow?: true
    row-face: none
    standard-font: make system/standard/face/font [
      size: 11 shadow: none style: none align: 'left color: black
    ]
    acquire-func: []
    import: func [data [object!]] [
    ]
    export: does [
      make object! third self
    ]
    list-size: value-size: 0
    resize: func [sz] [size: sz update]
    follow: does [either follow? [scroll-here][show lst]]
    list-action: over-row-action: alt-list-action: doubleclick-list-action:
      finish-edit-action: tab-edit-action: none

    block-data?: does [not all [not empty? data not block? first data]]

    ; navigation functions

    first-cnt: does [
      either empty? filter-string [sel-cnt: 1][
        all [sel-cnt sel-cnt: sort-index/1]
      ] follow
    ]
    prev-page-cnt: does [prev-cnt/skip-size list-size]
    prev-cnt: func [/skip-size size /local sz] [
      sz: either skip-size [size][1]
      all [sel-cnt sel-cnt:
        either empty? filter-string [
          max 1 sel-cnt - sz
        ][first skip find sort-index sel-cnt negate list-size]
      ] follow
    ]
    next-cnt: func [/skip-size size /local sz] [
      sz: either skip-size [size][1]
      all [sel-cnt sel-cnt:
        either empty? filter-string [
          min length? sort-index sel-cnt + sz
        ][
          either tail? skip find sort-index sel-cnt sz [
            last sort-index
          ][
            first skip find sort-index sel-cnt sz
          ]
        ]
      ] follow
    ]
    next-page-cnt: does [next-cnt/skip-size list-size]
    last-cnt: does [
      either empty? sort-index [sel-cnt: none][
        sel-cnt: either empty? filter-string [
          length? sort-index
        ][
          last sort-index
        ] follow
      ]
    ]
    limit-sel-cnt: does [
      if all [sel-cnt not found? find sort-index sel-cnt] [last-cnt]
    ]
    selected?: does [not none? sel-cnt]

    ; filtering functions

    old-filter-string: copy filter-string: copy ""
    filter-pos: func [pos] [attempt [index? find sort-index pos]]
    filter-sel-cnt: does [all [sel-cnt filter-pos sel-cnt]]
    filter-index: copy sort-index: copy []

; in the future there should be the possibility of chaining filters and making them column specific

    filter: has [default-i i w string result g-length] [
      filter-index: copy []
      either not none? data [
        g-length: length? g: parse to-string filter-string none
        either g-length > 0 [
          ; the size of the bitset must be multipliable by 8
          result: copy i: copy
            default-i: make bitset! (g-length + 8 - (g-length // 8))
          w: 1
          until [
            insert result w
            w: w + 1
            w > g-length
          ]
          ; handle index skipping here
          repeat j length? data [
            string: mold data/:j
            ; handle column distinction here
            repeat num g-length [if find string g/:num [insert i num]]
            if i = result [
              i: copy default-i ; clear i causes a bug!
              insert tail filter-index j
            ]
          ] filter-index
        ][copy []]
      ][copy []]
    ]

    scrolling?: none
    list-sort: has [i vals] [
      sort-index: either not empty? data [
        head repeat i length? data [insert tail [] i]
      ][copy []]
      vals: copy []
      either sort-column [
        i: index? find data-columns sort-column
        repeat j length? data [
          insert tail vals reduce [data/:j/:i j copy data/:j]
        ]
        sort-index: extract/index either sort-direction = 'asc [
          sort/skip vals 3
        ][
          sort/skip/reverse vals 3
        ] 3 2
      ][sort-index]
    ]
    reset-sort: does [
      sort-column: none
      sort-direction: 'nosort
      list-sort
      foreach p hdr/pane [if p/style = 'hdr-btn [p/effect: none]]
      update
      follow
    ]
    filter-list: has [/no-show] [
      sort-index: either empty? filter [
        either any [dirty? empty? filter-string] [dirty?: false list-sort][[]]
      ][
        if any [dirty? old-filter-string <> filter-string] [
          cnt: 0
          old-filter-string: copy filter-string
          list-sort
        ]
        intersect sort-index filter-index
      ]
      if not no-show [set-scr]
    ]
    set-filter: func [string] [
      filter-string: copy string
      update
    ]
    reset-filter: does [
      old-filter-string: copy filter-string: copy ""
      update
    ]
    scroll-here: has [sl] [
      if all [
        sel-cnt
        not empty? sort-index
        select-mode <> 'column
        select-mode <> 'multi
        select-mode <> 'multi-row
      ] [
        limit-sel-cnt
        sl: index? find sort-index sel-cnt
        cnt: min sl - 1 cnt
        cnt: (max sl cnt + list-size) - list-size
        if list-size < length? sort-index [
          cnt: (min cnt + list-size value-size) - list-size
        ]
        set-scr
      ]
    ]
    set-scr: does [
      scr/redrag list-size / max 1 value-size
      scr/data: either value-size = list-size [0][
        cnt / (value-size - list-size)]
      show self
    ]

    ; data retrieval functions

    get-id: func [pos rpos h r /inserting] [
      either r [rpos][either h [filter-pos pos][
        either sel-cnt [sel-cnt][1]]]
    ]
    row: does [
      make object! insert tail foreach c data-columns [
        insert tail [] either block-data? [to-set-word c][
          to-set-word first parse c none]
      ] reduce ['copy copy ""]
    ]
    get-row: func [/over /here pos /raw rpos /keys /local id] [
      id: get-id pos rpos here raw
      if all [id select-mode <> 'multi select-mode <> 'multi-row] [
        either keys [
          obj: make row [] set obj pick data id obj][pick data id]
      ]
    ]
    find-row: func [value /col colname /local i fnd?] [
      i: 0
      fnd?: false
      either empty? data [none][
        either col [
          c: col-idx colname
          until [
            i: i + 1
            any [
              all [i = length? data data/:i/:c value <> data/:i/:c]
              all [data/:i/:c value = data/:i/:c fnd?: true]
            ]
          ]
        ][
          until [
            i: i + 1
            any [
              all [i = length? data value <> pick data i]
              all [value = pick data i fnd?: true]
            ]
          ]
        ]
        either fnd? [sel-cnt: i follow get-row][none]
      ]
    ]
    get-cell: func [cell [integer! word!] /here pos /raw rpos /local id] [
      id: get-id pos rpos here raw
      if all [id not empty? data-columns not empty? data] [
        attempt [
          pick get-row/raw id
            either word? cell [index? find data-columns cell][cell]
        ]
      ]
    ]
    get-block: has [ar r] [
      if all [not empty? range] [
        ar: 1 + abs subtract first range last range
        ar-blk: array/initial ar/2 array/initial ar/1 copy ""
        r: range/1 - 1
        repeat i length? range [
          poke pick ar-blk range/:i/2 - r/2 range/:i/1 - r/1
            pick pick data range/:i/2 range/:i/1
        ] ar-blk
      ] copy []
    ]
    unique-values: func [column [word!]] [get-block as-pair col-idx column 0]

    ; data manipulation functions

;when starting to append empty rows, the size of the list is not known

    unkey: func [vals] [
      copy/deep either all [block? vals find vals set-word!] [
        extract/index vals 2 2][vals]
    ]
    col-idx: func [word] [index? find data-columns word]
    clear: does [data: copy [] dirty?: true filter-list]
    insert-row: func [
      /here pos [integer!] /raw rpos [integer!] /values vals /local id
    ] [
      id: get-id pos rpos here raw
      either empty? data [
        insert/only data either values [unkey vals][make-row]
      ][
        all [
          id data/:id insert/only at data id
            either values [unkey vals][make-row]
        ]
      ]
      dirty?: true
      filter-list
      get-row/raw id
    ]
    insert-block: func [pos [integer!] vals] [
      all [pos data/:pos insert at data pos vals filter-list]
    ]
    append-row: func [/values vals /no-select] [
      insert/only tail data either values [unkey vals][make-row]
      dirty?: true
      filter-list/no-show if not no-select [last-cnt] show lst
      get-row/raw length? data
    ]
    append-block: func [vals][
      insert tail data vals
      dirty?: true
      filter-list/no-show last-cnt show lst
    ]
    remove-row: func [/here pos [integer!] /raw rpos [integer!] /local id] [
      id: get-id pos rpos here raw
      all [id data/:id remove at data id dirty?: true filter-list]
    ]
    remove-block: func [pos range] [
      for i pos range 1 [remove at data pick sort-index i]
      dirty?: true
      filter-list
    ]
    remove-block-here: func [range] [remove-block range filter-sel-cnt]
    change-row: func [
      vals /here pos [integer!] /raw rpos [integer!] /top /local id tmp
    ] [
      id: get-id pos rpos here raw
      all [id data/:id change/only at data id unkey vals]
      if top [
        tmp: copy get-row/raw id
        remove-row/raw id
        insert-row/values/raw tmp 1
        first-cnt
      ]
      dirty?: true
      filter-list
      get-row/raw id
    ]
    change-block: func [pos [integer! pair!] vals [block!]] [
      either pair? pos [][
        for i sel-cnt length? vals 1 [change at data pick sort-index i]
      ]
      dirty?: true
      filter-list
    ]
    change-block-here: func [vals [block!]] [
      switch select-mode [
        single [change-block as-pair sel-cnt col-idx selected-column vals]
        row [change-block sel-cnt reduce [vals]]
        multi [change-block range/1 vals]
        multi-row [change-block range/1 vals]
        column [change-block range/1 vals]
      ]
    ]
    change-cell: func [
      col val /here pos [integer!] /raw rpos [integer!] /top /local id tmp
    ] [
      id: get-id pos rpos here raw
      if all [id data/:id] [
        change at pick data id col-idx col val filter-list
        if top [
          tmp: copy data/:id
          remove at data id
          data/1: tmp
        ]
        get-row/raw id
      ]
    ]
    make-row: does [
      either block-data? [array/initial length? data-columns copy ""][copy ""]
    ]
    acquire: does [
      if not empty? acquire-func [append-row/values do acquire-func]
    ]

    ; visual editing functions

    show-edit: func [/column col /local vals] [
      if sel-cnt [
        edt/offset/y:
          (lst/subface/size/y) * filter-sel-cnt
        vals: get-row
        repeat i length? viewed-columns [
          edt/pane/:i/text: edt/pane/:i/data: pick vals indices/:i
        ]
        show edt
        if not selected-column [selected-column: first viewed-columns]
        focus pick edt/pane index? find viewed-columns
          either column [col][selected-column]
      ]
    ]
    hide-edit: has [vals] [
      last-edit: either edt/show? [
        vals: copy get-row
        repeat i length? edt/pane [
          change/only at vals indices/:i get in pick edt/pane i 'text
        ]
        change-row vals
        hide edt
        get-row
      ][none]
    ]

    ; initialization

    init-code: has [o-set e-size val resize-column-index no-header-columns] [
      if none? data [data: copy []]
      if empty? data-columns [
        data-columns: either empty? data [
          copy [column1]
        ][
          either block-data? [
            foreach d first data [
              append [] either attempt [to-integer d]['Number][to-word d]
            ]
          ][copy [column1]]
        ]
      ]
      if none? viewed-columns [viewed-columns: copy data-columns]
      no-header-columns: false
      if none? header-columns [
        no-header-columns: true header-columns: copy data-columns]
      if all [fit none? resize-column] [resize-column: first viewed-columns]
      if none? types [types: copy array/initial length? data-columns 'text]

      indices: copy []
      either empty? viewed-columns [
        repeat i length? data-columns [insert tail indices i]
      ][
        foreach f viewed-columns [
          all [val: find data-columns f insert tail indices index? val]
        ]
      ]

      ; set panes up here
      hdr: make face [
        edge: none
        size: 0x20
        pane: copy []
      ]
      hdr-fill-btn: make face [
        style: hdr-fill-btn
        color: 120.120.120
        var: none
        edge: make edge [size: 0x1 color: 140.140.140 effect: 'bevel]
      ]
      hdr-btn: make face [
        edge: none
        style: 'hdr-btn
        size: 20x20
        color: 140.140.140
        var: none
        eff-blk: copy/deep [draw [
          pen none fill-pen white polygon 3x5 7x14 11x5] flip
        ]
        show-sort-hdr: func [face] [
          if all [sort-column face/var = sort-column] [
            face/effect: switch sort-direction [
              asc [head insert tail copy eff-blk 1x1]
              desc [head insert tail copy eff-blk 1x0]
            ][none]
          ]
        ]
        corner: none
        font: make font [align: 'left shadow: 0x1 color: white]
        feel: make feel [
          engage: func [face act evt][
            if editable? [hide-edit]
            switch act [
              down [
                foreach h hdr/pane [all [h/style = 'hdr-btn h/effect: none]]
                either face/corner [sort-column: none][
                  sort-column: face/var
                  either tri-state-sort [
                    sort-modes: either tail? next sort-modes [
                      head sort-modes][next sort-modes]
                    if 'nosort = sort-direction: first sort-modes [
                      sort-column: none
                    ]
                    show-sort-hdr face
                  ][
                    sort-direction:
                      either sort-direction = 'asc ['desc]['asc]
                    face/effect: head insert tail copy eff-blk
                      either sort-direction = 'asc [1x1][1x0]
                  ]
                ]
              ]
              alt-down [
                foreach h hdr/pane [all [h/style = 'hdr-btn h/effect: none]]
                sort-column: none
              ]
            ]
            either any [act = 'down act = 'alt-down][
              face/edge/effect: 'ibevel
              list-sort
              if not empty? filter [
                sort-index: intersect sort-index filter-index
              ]
              follow
            ][face/edge/effect: 'bevel]
            show face/parent-face/parent-face
          ]
        ]
      ]
      hdr-corner-btn: make face [
        edge: none
        style: 'hdr-corner-btn
        size: 20x20
        color: 140.140.140
        effect: none
        var: none
        feel: make feel [
          engage: func [face act evt][
            if editable? [hide-edit]
            either any [act = 'down act = 'alt-down] [
              face/edge/effect: 'ibevel
              repeat i subtract length? hdr/pane 1 [hdr/pane/:i/effect: none]
              sort-column: none
              sort-direction: 'nosort
              list-sort
              follow
            ][face/edge/effect: 'bevel]
            show face/parent-face/parent-face
          ]
        ]
      ]
      lst: make face [
        edge: none
        size: 100x100
        subface: none
        feel: make feel [
          over: func [face ovr /local f lv] [
          ]
        ]
      ]
      scr: make-face get-style 'scroller
      hscr: make-face get-style 'scroller
      edt: make face [
        edge: none
        text: ""
        pane: none
        show?: false
      ]
 
      ; initialize widths, cols and fonts

      if any [
        none? px-widths
        old-widths <> widths
        old-size <> size
        old-viewed-columns <> viewed-columns
      ] [
        if any [
          none? widths
          all [old-viewed-columns old-viewed-columns <> viewed-columns]
        ] [
          widths: array/initial
            length? viewed-columns to-decimal 1 / length? viewed-columns
        ]
        px-widths: copy widths
        ; Calculate this properly!
        repeat i length? widths [
          if decimal? widths/:i [
            px-widths/:i: to-integer widths/:i * (size/x - scr/size/x)
          ]
        ]
        if any [
          none? fonts
          all [old-fonts old-fonts <> fonts]
        ] [
          fonts: array/initial length? viewed-columns make standard-font []
        ]
        old-viewed-columns: copy viewed-columns
        old-widths: copy widths
      ]

      e-size: size - (2 * edge/size)
      hdr/size/x: e-size/x
      scr/resize/x scroller-width
      lst/size: as-pair
        e-size/x - scr/size/x
        e-size/y - add
          either h-scroll [scroller-width][0]
          lst/offset/y: either empty? header-columns [0][hdr/size/y] 

      scr/resize/y lst/size/y
      col-widths: do replace/all trim/with mold px-widths "[]" " " " + "
      either h-scroll [
        hscr/offset/y: lst/size/y + lst/offset/y
        hscr/axis: 'x
        hscr/resize as-pair lst/size/x either h-scroll [scroller-width][0]
        hscr/redrag divide (size/x - scroller-width) col-widths
;        hscr/redrag lst/size/x / (size/x - scroller-width)
      ][hscr/size: 0x0]
      scr/offset: as-pair lst/size/x lst/offset/y

      either fit [
        resize-column-index: any [
          attempt [index? find viewed-columns resize-column] 1]
        sz: lst/size/x
        repeat i length? px-widths [
          all [resize-column-index <> i sz: sz - px-widths/:i]
        ]
        if resize-column-index [px-widths/:resize-column-index: sz]
      ][
        if col-widths < lst/size/x [h-fill: lst/size/x - col-widths]
      ]
      
      lst-lo: has [lo edt-lo f sp] [
        lst/subface: layout/tight either row-face [row-face][
          lo: copy compose [across space 0 pad (as-pair 0 spacing/y)]
          repeat i length? viewed-columns [
            sp: either i = length? viewed-columns [0][spacing/x]
            insert tail lo compose [
              list-text (as-pair px-widths/:i - sp row-height)
              pad (as-pair sp 0)
            ]
          ]
          if h-fill > 0 [
            insert insert tail lo 'list-text as-pair h-fill row-height
          ]
          lo
        ]
        either row-face [row-height: lst/subface/size/y][
          fonts: reduce fonts
          repeat i length? lst/subface/pane [
            f: either i > length? fonts [last fonts][fonts/:i]
            lst/subface/pane/:i/font: make standard-font f
          ]
        ]
        lst/subface/color: spacing-color
      ]

      if not empty? viewed-columns [lst-lo]
      pane: reduce [hdr lst scr edt hscr]

      ; list initialization

      lst/subface/size/x: lst/size/x
      list-size: does [
      ; have a look at this... it seems that it doesn't adhere to row-spacing
        to-integer lst/size/y / lst/subface/size/y
      ]
      value-size: does [
        length? either empty? filter-string [data][
          either empty? filter-index [[]][sort-index]]
      ]
      scr/action: has [value] [
        scrolling?: true
        value: to-integer scr/data * max 0 value-size - list-size
        if all [cnt <> value][
          cnt: value
          show lst
        ]
      ]
      hscr/action: has [value] [
        scrolling?: true
        value: do replace/all trim/with mold px-widths "[]" " " " + "
        hdr/offset/x: lst/offset/x: negate (value - lst/size/x) * hscr/data
        show self
      ]

      edt/pane: get in layout/tight either row-face [row-face][
        edt-lo: copy [across space 0]
        repeat i length? viewed-columns [
          insert tail edt-lo compose [
            list-field (lst/subface/pane/:i/size - 0x1)
          ]
          insert/only tail edt-lo
            either i = length? viewed-columns [[hide-edit]][[]]
          insert tail edt-lo reduce ['pad spacing/x]
        ] edt-lo
      ] 'pane
      foreach e edt/pane [e/font: make standard-font []]

      edt/size: lst/subface/size

      set-scr
      filter-list
      cell?: []
      row?: []

      lst/color: either fill [
        either even? list-size [second colors][first colors]
      ][last colors]
      
      ; supply list with data

      lst/pane: func [face index /local c-index j k s o-set t col sp][

; in here we need to manage how to make conditions.
; we need to create objects from rows either precalced or on the fly


        col: attempt [index? find viewed-columns selected-column]
        either integer? index [
          c-index: index + cnt
          if all [index <= list-size any [fill sort-index/:c-index]] [
            o-set: k: 0
            repeat i length? lst/subface/pane [
              sp: either i = length? lst/subface/pane [0][spacing/x]
              s: lst/subface
              j: s/pane/:i
              s/offset/y: (index - 1 * s/size/y) - spacing/y
              if not scrolling? [
                if not row-face [j/offset/x: o-set]
                o-set: o-set + j/size/x + sp
                if all [not row-face resize-column = data-columns/:i] [
                  j/size/x: px-widths/:i - sp
                ]
              ]
              j/color: either
                switch select-mode [
                  single [
                    all [
                      sort-index/:c-index
                      sel-cnt = sort-index/:c-index
                      col = i
                    ]
                  ]
                  row [
                    all [sort-index/:c-index sel-cnt = sort-index/:c-index]]
                  column [all [sort-index/:c-index col = i]]
                  multi [
                    all [
                      col
                      sort-index/:c-index
                      any [
                        all [
                          sel-cnt = sort-index/:c-index
                          col = i
                        ]
                        found? find range as-pair i sort-index/:c-index
                      ]
                    ]
                  ]
                  multi-row [
                    all [
                      col
                      sort-index/:c-index
                      any [
                        all [sort-index/:c-index sel-cnt = sort-index/:c-index]
                        found? find range as-pair i sort-index/:c-index
                      ]
                    ]
                  ]
                ] [third colors][pick colors c-index // 2 + 1]
              if all [not row-face h-fill > 0 i = length? lst/subface/pane] [
                j/color: j/color * 0.9
              ]
              if flag-face? j 'text [
                k: k + 1
                j/data: sort-index/:c-index
                j/row: index
                j/text: j/full-text: attempt [either block-data? [
                  pick pick data sort-index/:c-index indices/:k 
                ][
                  pick data sort-index/:c-index
                ]]
                either image? j/text [
                  j/effect: compose/deep [
                    draw [
                      translate ((j/size - j/text/size) / 2)
                      image (j/text)
                    ]
                  ]
                  j/text: none
                ][
                  j/effect: none
                  either all [
                    j/text
                    truncate
                    not empty? j/text
                    (t: index? offset-to-caret j as-pair j/size/x 15) <= 
                      length? to-string j/text
                  ] [
                    j/truncated?: true
                    j/text: join copy/part to-string j/text t - 3 "..."
                  ][j/truncated?: false]
                ]
              ]
            ]
            s/size/y: row-height + spacing/y +
              either index = list-size [spacing/y][0]
            return s
          ]
        ][return to-integer index/y / lst/subface/size/y + 1]
      ]

      ; header initialization

      if not empty? header-columns [
        o-set: o-size: 0
        repeat i min length? header-columns length? viewed-columns [
          insert tail hdr/pane make hdr-btn compose [
            corner: none
            edge: (make edge [size: 1x1 color: 140.140.140 effect: 'bevel])
            offset: (as-pair o-set 0)
            text: (
              to-string to-word pick header-columns
                either all [no-header-columns not empty? indices] [
                  indices/:i][i]
            )
            var: (
              either all [sort-column 1 = length? viewed-columns] [
                to-lit-word sort-column][to-lit-word viewed-columns/:i]
            )
            size: (as-pair
              o-size: either 1 = length? header-columns [
                either any [not fit h-scroll] [px-widths/:i][lst/size/x]
              ][px-widths/:i] hdr/size/y
            )
            related: 'hdr-btns
          ]
          o-set: o-set + o-size
        ]
        if h-fill > 0 [
          insert tail hdr/pane make hdr-fill-btn compose [
            size: (as-pair h-fill hdr/size/y)
            offset: (as-pair o-set 0)
          ] o-set: o-set + h-fill
        ]
        glyph-scale: (min scroller-width hdr/size/y) / 3
        glyph-adjust: as-pair
          scroller-width / 2 - 1
          hdr/size/y / 2 - 1
        insert tail hdr/pane make hdr-corner-btn compose/deep [
;          corner: true
          offset: (as-pair o-set 0)
          color: 140.140.140
          edge: (make edge [size: 1x1 color: 140.140.140 effect: 'bevel])
          size: (as-pair scr/size/x hdr/size/y)
          effect: [
            draw [
              anti-alias off
              pen none fill-pen 200.200.200 polygon
              (0x-1 * glyph-scale + glyph-adjust)
              (1x0 * glyph-scale + glyph-adjust)
              (0x1 * glyph-scale + glyph-adjust)
              (-1x0 * glyph-scale + glyph-adjust)
            ]
          ]
        ]

        hdr/pane: reduce hdr/pane
        hdr/size/x: size/x
        foreach h hdr/pane [all [h/style = 'hdr-btn h/show-sort-hdr h]]
      ]
    ]
    init: [init-code]
    update: func [/force] [
;      dirty?: true
      scrolling?: false
      either force [init-code][
        either size <> old-size [init-code][filter-list]]
      if all [self/parent-face show?] [show self]
    ]
  ]
]
