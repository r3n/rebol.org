REBOL [
  Title: "HTML Dialect"
  Author: ["Henrik Mikael Kristensen"]
  Copyright: "2008 - HMK Design"
  File: %html.r
  Version: 0.0.7
  Type: 'script
  Created: 13-Apr-2008
  Date: 20-Aug-2008
  License: {
    BSD (www.opensource.org/licenses/bsd-license.php)
    Use at your own risk.
  }
  Purpose: {
    HTML dialect for simple generation of webpages with REBOL code.
  }
  Availability: {
    http://www.hmkdesign.dk/rebol/html-dialect/src/0.0.7/html.r
    http://www.hmkdesign.dk/rebol/html-dialect/docs/0.0.7/html-dialect.html
  }
  Notes: {
    Complex type sets in four places in the code.
    <script> is sometimes a single and sometimes a double tag.
    Cell-types results are not stackable
    Problems with nested traverse.
  }
  Future: [
    0.0.8 {
      TEXT-GEN to convert HTML dialect to pure text.
      Better practical use of the error log.
      Attributes for form elements.
      Automatic content highlighting functions.
      Thorough testing of the dialect using a testing framework.
    }
  ]
  History: [
    0.0.7 {
      Tag rules now allow cell-types instead of just words for ID.
      Multiple classes allowed now by any number of issue!s.
      PAGE command supports linking to RSS and ATOM feeds.
      === Now never produces single-tags.
      New FULL-TAG to forcibly produce tags with end-tags to fix ===.
      NEWLINE and CRLF added.
      Better binding system in nested loops.
      Different handling of TRAVERSE USING option, when it's empty.
      TRAVERSE bug fixed when not using the USING option.
      TRAVERSE supports more data input types.
      New format functions for TABLE: Even, odd, first, last, even-last, odd-last, any.
      Fixed bugs in TABLE that would prevent some block formats from working.
      Fixed bugs in AT that would prevent VARS from working.
    }
    0.0.6 {
      Set-word! is now used for simple templates.
      Added possibility of using table-row-rules without a block.
      Now allows CSS styles directly to be written in the webpage instead of having to be included as a separate file.
    }
    0.0.5 {
      SELECT now supports values in option tags.
      Full documentation available.
    }
    0.0.4 {
      Added OUTPUT-HTML function for direct HTML output to console.
      Code reorganized and cleaned up.
      Removed automatic formatting of links.
      Some testing of the dialect using a testing framework.
      Dynamic input allowed for all inputs (cell-types and href-types).
    }
    0.0.3 {
      Automatic formatting of links via internal site links using AT PAGE.
      Page list to manage internal site links.
      Many new cell-type, almost covering all REBOL datatypes.
      Simple error logging using LOG-ERROR.
      Form rules for simple form generation and filling.
      Improved generation of content for HEAD such as META and LINK tags.
      Sets end-slash for XHTML doctypes.
    }
    0.0.2 {
      Better separation of rules.
      Renamed HTML-PARSE to HTML-GEN.
      Direct support for more encompassing tags.
      Tracks the current doctype with DOC-TYPE.
      TAGs can be evaluated using the new EVAL-RULE.
      END-TAG to complement TAG.
    }
    0.0.1 "First version"
  ]
  Keywords: []
]

ctx-html: context [
  set 'out-buffer ""
  out: func [string] [insert tail out-buffer reduce string]
  url-vars: []
  url-var-string: make string! 1000
  class-str: make string! ""
  close-tag: func [word [word!]] [to-tag join "/" word]
  refresh-time: 5    ; The number of seconds before a redirect page refreshes.
  errors: []         ; All errors generated during html generation are stored here
  debug-table: 0     ; Sets whether a table is showing debug output or not. Value is 0 or 1.

  ; ---------- Words used in dialect
  start-tag: []      ; Content of the current tag including options
  end-tags: []       ; Track the historical use of end tags
  head-block: []
  eval-res: []
  vals: []
  val-ctx: []      ; The temporary context for values. If not used, it's empty.
  user-words: []     ; Contains user defined shortcut words for use in the dialect
  tables: []         ; Contains formatting contexts for nested tables
  table: none        ; Contains the last used table context

  tag-block: tag-idx: opts: content: class: style: end-tag: vars: var-block: val: cell-val: tag-vals: form-tags: res-tag: odd: even: words: values: none
  step: 1
  alt: off
  v: w: none

  form-object: none  ; Managing form input via object

  form-value: func [word] [
    case [
      not word? word [word]
      all [form-object in form-object word] [get in form-object word]
      value? word [get word]
      not value? word [log-error ["Word" word "does not exist."] ""]
    ]
  ]

  has-form-value: func [word [word!]] [
    case [
      all [form-object in form-object word]                     [true]
      all [value? word not none? get word not series? get word] [true]
      all [value? word series? get word]                        [not empty? get word]
      all [value? word none? word]                              [false]
      not value? word                                           [log-error ["Word" word "does not exist."] false]
    ]
  ]

  ; ---------- Misc Functions

  text-gen: func [str] [str] ; pass through for now

  log-error: func [str [string! block!]] [append errors text-gen reform str str]

  single-tags: [link meta img input frameset hr br]

  doc-type-list: [
    html-2.0-dtd           <!DOCTYPE html PUBLIC "-//IETF//DTD HTML 2.0//EN">
    html-3.2-dtd           <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
    html-4.01-strict       <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
    html-4.01-transitional <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    html-4.01-frameset     <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
    xhtml-1.0-strict       <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    xhtml-1.0-transitional <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    xhtml-1.0-frameset     <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
    xhtml-1.0-dtd          <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
    xhtml-basic-1.0-dtd    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">
    xhtml-basic-1.1-dtd    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd"
    mathml-1.01-dtd        <!DOCTYPE math SYSTEM "http://www.w3.org/Math/DTD/mathml1/mathml.dtd">
    xhtml-mathml-svg-dtd   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN" "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
    svg-1.0-dtd            <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
    svg-1.1-full-dtd       <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    svg-1.1-basic-dtd      <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1 Basic//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-basic.dtd">
    svg-1.1-tiny-dtd       <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1 Tiny//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11-tiny.dtd">
  ]

  doc-type: 'xhtml-1.0-strict ; default for now

  xhtml?: does [found? find to-string doc-type 'xhtml]

  ; ---------- Types and Input Parameters

  block-types: [block! | hash! | list!]

  value-types: [money! | binary! | number! | date! | time! | tuple! | url! | email! | file! | any-string! | char! | pair!] ; tag not allowed here

  cell-types: [
    ['do cell-val: block-types (cell-val: do cell-val/1)]
    | [set cell-val get-word! (cell-val: get cell-val)]
    | [set cell-val [value-types | block-types | datatype! | word! | lit-word! | path! | lit-path! | refinement! | logic!]]
  ]

  href-types: [['do href-val: block-types (href-val: do href-val/1)] | set href-val get-word! (href-val: get href-val) | set href-val [word! | url! | string! | path! | refinement!]]

  doc-types: []
  foreach [word tag] doc-type-list [repend doc-types [to-lit-word word '|]]
  remove back tail doc-types

  ; ---------- Small Rules

  set-val: [set val get-word!]
  set-class: [some [set val issue! (append class-str join val ", ")] (val: any [attempt [copy head clear find/reverse tail class-str ", "] as-string val] clear class-str)]
  set-opt-class: [set-class | (val: none)]

  verbatim-rules: [[value-types | tag! | lit-word! | path! | lit-path! | refinement! | datatype! | logic!] (out cmd/1)]

  eval-rules: [any [val: ['do block-types (append eval-res do val/2) | any-type! (append eval-res val/1)]]]

  base-rules: [
    '=== word! (tag-vals: "") opt ['opts block! (tag-vals: cmd/4)] cell-types (html-gen compose/deep [full-tag [(cmd/2) (tag-vals)] [(cell-val)] end-tag])
    | 'tag (clear eval-res) into eval-rules (res-tag: trim build-tag eval-res either find single-tags cmd/2/1 [if xhtml? [append res-tag " /"]][append end-tags cmd/2/1] out res-tag)
    | 'full-tag (clear eval-res) into eval-rules (res-tag: trim build-tag eval-res append end-tags cmd/2/1 out res-tag)
    | 'end-tag (out close-tag either block? last end-tags [first last end-tags][last end-tags] remove back tail end-tags)
    | block-types (html-gen cmd/1)
    | 'do block-types (html-gen do cmd/2)
    | ['newline | 'crlf] (html-gen [tag [br]])
  ]

  build-url: func [vars /local str w] [str: make string! "" parse vars [any [w: any-word! (repend str [w/1 "="]) any-type! (repend str [w/2 "&"])]] head remove back tail str]

  link-rules: [
    'at [
      set url cell-types (if get-word? url [url: get url]) cell-types (var-block: make block! []) any [
        'vars vars: [block-types (vars: vars/1) | object! (vars: third vars/1) | get-word! (vars: get vars/1)] (append var-block vars)
        | 'words [set words block! (parse words [any [set w word! (repend var-block [to-set-word w get w])]])] ; not sure the outer block here is needed
      ]
      (unless empty? var-block [url: rejoin [url "?" build-url third make object! var-block]] html-gen compose/deep [=== a opts [href (url)] [(cmd/3)]])
    ]
  ]

  image-rules: [
    'image cell-types (html-gen compose/deep [tag [img src (cell-val)]])
  ]

  ; ---------- HTML Dialect Table Rules

  tr: [(out <tr>)]
  tr': [(out </tr>)]

  format-rule: [(format-word: 'any) opt [set format-word ['first | 'even-last | 'odd-last | 'last | 'odd | 'even | 'any]]]

  table-rules: [
    'table (debug-table: 0) opt ['debug (debug-table: 1)]
      (append tables table: context [format: make block! [] values: none] tag-block: reduce ['table 'cellspacing debug-table 'cellpadding debug-table])
      [[set-class (insert next tag-block [class (val)]) | (none)] (out build-tag tag-block)]
      any [
        [
          'format any [format-rule set format block-types (either find table/format format-word [change/only next find table/format format-word format][repend table/format [format-word format]])]
          any ['rows [set-val (parse get val table-format-rules) | into table-format-rules | table-format-rules]]
        ]
        | ['rows [set-val (parse get val table-block-rules) | into table-row-rules | table-row-rules | into table-block-rules]]
      ]
      (out </table> remove back tail tables unless empty? tables [table: last tables])
  ]

  table-row-rules: [
    ; tbody rules here
    some [
      'row tr
      any [
        ['cell (end-tag: 'td) | 'header (end-tag: 'th)] (insert clear start-tag end-tag)
        ; cell formatting
        any [[set type ['colspan set val integer! | 'align set val word! | 'width set val integer! opt ['percent (val: join val "%")]] | set-class (type: 'class)] (repend start-tag [type val])]
        ; cell content
        [none! (out build-tag start-tag) | cell-types (out build-tag start-tag html-gen cell-val)] (out close-tag end-tag)
      ] tr'
    ]
  ]

  table-cell-rule: [val: cell-types (html-gen compose/deep [td [(val/1)]])]
  table-row-rule: [val: cell-types (html-gen compose/deep [tr td [(val/1)]])]

  format-type: func [block] [
    case [
      head? block                               ['first]
      all [even? index? block tail? next block] ['even-last]
      all [odd? index? block tail? next block]  ['odd-last]
      tail? next block                          ['last]
      odd? index? block                         ['odd]
      even? index? block                        ['even]
      true                                      ['any]
    ]
  ]

  table-format-rules: [
    any [
      val: object! (
        context [
          append val-ctx first val': val
          parse bind any [select table/format format-type val' table/format/2] val'/1 table-row-rules
          remove back tail val-ctx
        ]
      )
    | into [tr any table-cell-rule tr'] | table-row-rule]]

  table-block-rules: [any [val: object! tr (context [set val-ctx val': val foreach cell next first val'/1 [html-gen compose [td (get in val'/1 cell)]]]) tr' | into [tr any table-cell-rule tr'] | table-row-rule]]

  ; ---------- HTML Dialect Parse Rules

  tag-rule: [
    val: [
      'html | 'head | 'style | 'title | 'body | 'p | 'strong | 'em | 'b | 'i | 'u | 'tt | 'big | 'small
      | 'strike | 'del | 'pre | 'ul | 'il | 'li | 'sup | 'sub | 'samp | 'code | 'blockquote | 'q
      | 'kbd | 'var | 'cite | 'tr | 'th | 'td | 'table | 'a | 'div | 'span | 'dl | 'dt | 'dd
      | 'h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'h6
    ]
    (repend tag-idx ['=== val/1 'opts make block! [] make block! []] opts: tag-idx/4 content: tag-idx/5)
    opt [set-class (repend opts ['class val])]
    opt ['id val: cell-types (repend opts ['id val/1])] ; defective
    val: [(tag-idx: content) tag-rule | get-word! (append/only content get val/1) | cell-types (append/only content val/1) | ()]
  ]

  tag-rules: [(tag-block: tag-idx: make block! []) tag-rule (html-gen tag-block)]

  loop-rules: [
    'loop integer! set odd block-types (alt: off) opt [set alt 'alternate set even block-types] (
      context [
        alt': alt
        odd': odd
        even': even
        idx: none
        ; make bindings properly here with val-ctx
        repeat idx cmd/2 [html-gen bind either any [not alt' odd? idx] [odd'][even'] 'idx]
      ]
    )
    ; need to figure out why it falls apart when doing this recursively
    | 'traverse [set values block-types | 'do set values block-types (values: do values) | set values get-word! (values: get values)]
      (words: none) opt ['using [set words [lit-word! | word! | block-types] | set words get-word! (words: get words)]]
      set odd block-types (alt: off even: none)
      opt [set alt 'alternate set even block-types] (
        context [
          w: make block! []
          values': values
          words': all [words to-block words]
          if words' [append foreach wrd words' [append w to-set-word wrd] none]
          w: context w
          if words' [bind :words' w]
          odd': odd
          even': even
          alt': alt
          idx: none
          ; make bindings properly here with val-ctx
          case [
            object? values'/1    [repeat idx length? values' [html-gen bind bind either any [not alt' odd? idx] [odd'][even'] values/:idx 'idx]]
            any-block? values'/1 [repeat idx length? values' [set :words' values'/:idx html-gen bind bind either any [not alt' odd? idx] [odd'][even'] first words' 'idx]]
            empty? words'        [] ; should probably generate error here, if 'using block is empty, but it's empty for object blocks
            true                 [forskip values' length? :words' [idx: index? values' set :words' values' html-gen bind bind either any [not alt' odd? idx] [odd'][even'] first words' 'idx]]
          ]
        ]
      )
  ]

  text-format-rules: ['format word! cell-types (html-gen cmd/3)] ; these rules will be extensible later

  ; ---------- Form Functions and Rules

  set-check-indicator: does [append last form-tags either xhtml? [[checked checked]]['checked]]
  set-option-tag: func [block pos] [
    case [
      step = 1 [
        case [
          all [xhtml? same? block pos] [[=== option opts [selected selected] [(values/:step)]]]
          all [same? block pos] [[=== option opts [selected] [(values/:step)]]]
          true [[=== option [(values/:step)]]]
        ]
      ]
      step = 2 [
        case [
          all [xhtml? same? block pos] [[=== option opts [selected selected value (values/1)] [(values/:step)]]]
          all [same? block pos] [[=== option opts [selected value (values/1)] [(values/:step)]]]
          true [[=== option opts [value (values/1)] [(values/:step)]]]
        ]
      ]
    ]
  ]

  form-rules: [
    [
      'form cell-types
        opt [[get-word! (vars: get cmd/3) | ['vars [block! (vars: make object! cmd/3) | object! (vars: cmd/3)]]] (form-object: vars)]
        cell-types
        (form-tags: [=== form opts [action (cmd/2) method post] [(cell-val)]])                                                                               ; Testing
      | 'textarea word! (form-tags: [tag [textarea rows 10 cols 40 name (cmd/2)] (form-value cmd/2) end-tag])                                                ; Testing
      | ['field | 'hidden | 'password] word! (form-tags: [tag [input type (cmd/1) name (cmd/2) value (form-value cmd/2)]])                                   ; Testing
      | 'checkbox word! (form-tags: copy/deep [tag [input type checkbox name (cmd/2)]] if has-form-value cmd/2 [set-check-indicator])
      | 'radio word! cell-types (form-tags: copy/deep [tag [input type radio name (cmd/2) value (cmd/3)]] if cmd/3 = form-value cmd/2 [set-check-indicator]) ; Testing
      | 'select word! (form-tags: compose/deep [=== select opts [name (cmd/2)] []]) [
        ['values (step: 1) | 'key-values (step: 2) | (step: 1)]
        cell-types (values: head form-value cell-val forskip values step [append form-tags/5 compose/deep set-option-tag form-value cell-val values])
      ]                                                                                                                                                      ; Testing
      | 'button word! string! (form-tags: [tag [input type button name (cmd/2) value (cmd/3)]])                                                              ; Testing
      | ['submit | 'reset | 'button] string! (form-tags: [tag [input type (cmd/1) value (cmd/2)]])                                                           ; Testing
    ] (html-gen compose/deep form-tags)
  ]

  ; ---------- Other Higher Level Rules

  to-head-block: func [data] [append head-block compose/deep [tag [(compose/deep data)]]]

  page-rules: [
    ; clear out-buffer here?
    'page cell-types (clear head-block) any [
      val: [
        ['redirect | 'refresh] href-types integer! (to-head-block [meta http-equiv refresh content (rejoin [href-val "; url=" val/2])])
        | 'favicon href-types (to-head-block [link rel "shortcut icon" href (href-val)])
        | 'charset [string! | word!] (to-head-block [meta http-equiv content-type content (join "text/html; charset=" val/2)])
        | 'description string! (to-head-block [meta name description content (val/2)])
        | 'robots into [some ['noindex | 'index | 'nofollow | 'follow | 'noarchive | 'nosnippet | 'noodp | 'noydir]] (to-head-block [meta name robots content [(replace/all form val/2 " " ", ")]])
        | 'css href-types (to-head-block [link rel stylesheet href (href-val) type "text/css"])
        | 'rss href-types string! (if xhtml? [to-head-block [link rel alternate href (href-val) type "application/rss+xml" title (val/3)]])
        | 'atom href-types string! (if xhtml? [to-head-block [link rel alternate href (href-val) type "application/atom+xml" title (val/3)]])
        | 'script href-types (to-head-block [script src (href-val) type "text/javascript"])
        | 'style string! (append head-block compose/deep [style [(val/2)]])
        ; add more types here
        ; cookie handling here
      ]
      | 'meta ['name | 'http-equiv] 2 cell-types (to-head-block [meta (val/2) (val/3) content (cell-val)])
    ] val: block-types (
      html-gen compose/deep [
        xhtml-1.0-strict ; should be changable
        ;html-4.01-strict ; activate this line when testing non-XHTML mode
        html [head [(head-block) title [(cmd/2)]] body [(val/1)]]
      ]
    )
  ]

  error-rules: ['errors (print errors)]

  word-rules: [
    doc-types (out select doc-type-list doc-type: cmd/1)
    | set-word! [word! | value-types | block-types] (w: to-word cmd/1 either v: find/skip user-words w 2 [change/only next v cmd/2][repend user-words [w cmd/2]])
    | get-word! (html-gen get cmd/1)
    ; need to find the word here first
    | word! (either select/skip user-words cmd/1 2 [html-gen select/skip user-words cmd/1 2][out mold cmd/1])
  ]

  all-rules: [any [cmd: [verbatim-rules | base-rules | link-rules | image-rules | table-rules | tag-rules | loop-rules | text-format-rules | form-rules | page-rules | error-rules | word-rules]]]

  ; ---------- Public Functions

  set 'html-gen func [
    "Low level HTML dialect"
    data [none! object! char! string! binary! datatype! tag! file! url! email! number! money! time! date! pair! tuple! get-word! word! any-block!] ; Complex
    /local cmd blk header row-blk start-tag ; check these
  ] [
    if get-word? data [data: get data] ; problem here
    if all [word? data find user-words data] [html-gen select user-words data return true]
    if any [file? data url? data string? data binary? data datatype? data number? data money? data email? data word? data time? data date? data] [out data return true] ; Complex
    if none? data [return true]
    bind eval-rules 'data
    parse either empty? val-ctx [data][foreach ctx val-ctx [bind data ctx]] all-rules
  ]

  set 'output-html func [
    "Returns HTML directly"
    data
    /local buffer
  ] [
    clear out-buffer
    html-gen data
    buffer: copy out-buffer
    clear out-buffer
    buffer
  ]
]

