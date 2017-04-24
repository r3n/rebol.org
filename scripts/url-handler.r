#!/usr/local/bin/rebol -cs

REBOL [
  Title: "URL Handler"
  File: %url-handler.r
  Author: [ "HY" ]
  Purpose: { A script to handle URLs as objects. Rebol's built-in 'decode-url function
             returns an object, but no methods to manipulate it. This script includes
             functions that make it possible to manipulate the URL as you please.

             CGI parameters are parsed into an alphabetized block for ease of comparison
             of URLs.
           }
  Date: 16-Aug-2003
  History: [
             30-Jan-2009 {Fixed a bug in block (non-existant!) sorting.}
             17-Jun-2007 {Moved the decode-cgi-query function out of the context.
                          Added a check for relative URLs when host or protocol field is empty.
                          Fixed a bug that would cause lacking slashes in URLs with "../" sequences.}
             30-May-2007 {Removed a bug that caused URLs with more than one occurance of «://» to be
                          parsed wrongly in 'init (although decent URLs would escape that sequence).}
             03-Jan-2006 {Added /from-path-only refinement to 'as-string.}
             20-Apr-2005 {Trying make error! instead of throw...}
             04-Nov-2004 {Bug removed from alphabetization of CGI parameters.}
             28-Oct-2004 {Yet another bug removed in Carl's CGI parsing (colon related).}
             27-Oct-2004 {Added comparison function. For some reason, simple '= comparison didn't
                          function correctly.}
             26-Oct-2004 {Added CGI parameter parsing.}
             16-Oct-2004 {Removed a bug that caused absolute URLs starting with other protocols than
                          http and ftp to be parsed as relative URLs. The URL-handler now accepts
                          other protocols again. It is reasonable to accept all protocols, but as I
                          use only free rebol versions, I have no https protocol, and so I have to
                          check this elsewhere.}
             25-Sep-2004 "Added the library header"
             04-May-2004 {Removed a bug that caused CGI parameters to be lost from the string used
                          to construct the object. This bug found its way in on one of the two
                          previous updates.}
             22-Mar-2004 {Removed a bug that caused a crash when a URL ended with
                          no trailing slash after the host name, but a line break instead.}
             26-Mar-2004 {Now accepts only ftp:// and http:// protocols. Also fixed a bug that would cause
                          "http://some/redirect?http://www.url.com/" to be parsed erroneously.}
             22-Mar-2004 "Added protocols that we don't wish to support"
             19-Mar-2004 "Added a few examples and forbid relative URLs with no protcol and/or host"
             13-Jan-2004 "Fixed a bug in handling of relative (section) links"
             16-Aug-2003 "Seems this is the date I first made the script."
           ]
  Examples: {
    site: url-handler "http://www.rebol.com"
    print site/url ; == http://www.rebol.com/
    site/move-to "docs.html"
    site/move-to "http://www.rebol.com/docs/core23/rebolcore-1.html"
    site/move-to "#sect1"
    print site/protocol ; == "http://"
    print site/host ; == "www.rebol.com"
    print site/path ; == "/docs/core23/"
    print site/file ; == "rebolcore-1.html"
    print site/query-part ; == ""
    print site/section ; == "#sect1"
    print site/canonical ; == "http://www.rebol.com:80/docs/core23/rebolcore-1.html#sect1"
    print site/as-string/from-path-only ; == "/docs/core23/rebolcore-1.html"
    site: url-handler "http://dummy.com/index.html?zz=b&hj=d&e=5&f=a b&sid=5&nothing=&re=bol#s3"
    probe site/query-part ; == "?zz=b&hj=d&e=5&f=a b&sid=5&nothing=&re=bol"
    probe site/query-block ; == [e: "5" f: "a b" hj: "d" nothing: none re: "bol" sid: "5" zz: "b"]
    site2: url-handler "http://dummy.com/index.html?zz=b&hj=d&e=5&f=a b&sid=5&nothing=&re=bol#s3"
    print site2/equal?/regard-cgi-order/regard-section site ; == true
  }
  TODO: { Handle URLs like this one:
          http://agora-dev.org//forums/index.php?site }
  Library: [
    level: 'intermediate
    domain: [http file-handling other-net cgi]
    license: none
    Platform: 'all
    Tested-under: none
    Type: [module]
    Support: none
  ]
]

decode-cgi-query: func [
    ; function copied from http://www.rebol.org/cgi-bin/cgiwrap/rebol/view-script.r?color=yes&script=cgidecode.r
    ; slightly modified (to remove a few small bugs). Because of colons, spaces and percent signs appearing
    ; wherever they want in URLs, loading values is impossible. And since I don't need the values as such, but
    ; only store them for comparison, I just keep them as strings.
    ; line 109 (4th in function) was:
    ;          (append list either find val ":" [to-string load val] [to-string load head insert val "%"])]
    ; But alas, not even that was CGI-fool proof
    ; Otherwise: thanks, Carl.
    "Convert CGI argument string to a list of words and value strings"
    args [any-string!] "Starts at first argument word"
    /local list equate value name val
][
    list: make block! 8
    equate: [copy name to "=" "=" (append list to-set-word to-string name) value]
    value: [["&" | end] (append list none) | [copy val to "&" "&" | copy val to end]
         (append list to-string val)]
    parse/all args [some equate | none]
    ; then alphabethize the block:
    other-list: copy []
    forskip list 2 [
      inserted?: no
      forskip other-list 2 [
        if < first list first other-list [insert other-list reduce [first list second list] inserted?: yes break]
      ]
      if not inserted? [insert other-list reduce [first list second list]]
      other-list: head other-list
    ]
    head other-list
]

url-handler-object: context [

  ; 'context should automatically pick up set-words
  ; and bind them to the new local context, so:
  protocol: ""
  host: ""
  user-name: ""
  password: ""
  port: 80 ; default
  path: ""
  file: ""
  query-part: ""
  query-block: []
  section: ""
  rest: ""
  url: ""


  init: func [ /local relative? ] [

    ; Escape rebol escape character (^):
    replace/all url "^^" "%5E"


    rest: trim/lines url
    if 0 = length? rest [
      make error! join  "No URL to parse: " mold url
    ]

    if all [#"#" = first url any ["" = protocol "" = host]] [
      make error! join "Can't initialize relative url " join url " when host or protocol field is empty!"
    ]

    relative?: all [#"#" = first url "" <> protocol "" <> host]

    either section: find rest "#"    [ section: copy section
                                       rest: head remove/part find rest "#" length? section ]
                                     [ section: "" ]

    if 0 = length? rest [
      either relative? [ rejoin-it return ] [ make error! join "No URL to parse: " mold url]
    ]

    either query-part: find rest "?" [ query-part: copy query-part
                                       rest: head remove/part find rest "?" length? query-part
                                       query-block: decode-cgi-query remove copy query-part
                                       sort/skip query-block 2
                                     ]
                                     [ query-part: "" ]

    relative?: not find/match/any/part url "*://" 8 ; works only for first eight characters...

    if all [relative? any ["" = protocol "" = host]] [
      make error! join "Unsupported or lacking protocol and/or host information: " url
    ]

    ;if any [ find/match url "mailto:"
    ;         find/match url "javascript:"
    ;         find/match url "file://"
    ;         find/match url "https://" ; irritating this is
    ;         find/match url "whois://"
    ;         find/match url "news://"
    ;         find/match url "irc://"
    ;         find/match url "pop://"
    ;         find/match url "tcp://"
    ;         find/match url "mysql://"
    ;         find/match url "web://"
    ;         find/match url "dns://"
    ;         find/match url "rtsp://"
    ;         find/match url "serial://"
    ;         find/match url "simple://"
    ;         find/match url "pnm://"
    ;         find/match url "nntp://" ; added 2005-08-14
    ;       ] [ make error! join  "Unsupported protocol: " url ]

    either relative? [

      ; protocol and host supposedly known.
      if any ["" = protocol "" = host] [make error! join "Lacking protocol and/or host information: " url " (how could this happen?)"]

      if "" = rest [
        rejoin-it
        return
      ]

      ; if rest starts with a slash, the whole path is to be replaced, else simply attach:
      path: either #"/" = first rest [ copy rest ] [ join path rest ]

      if not any [none? path "" = path] [
        file: either #"/" = last path [ "" ] [ last parse path "/" ]
      ]

      if not any [none? file "" = file] [
        path: copy/part path (index? find path file) - 1
      ]

    ] [
      ; not relative. Must have protocol and host information
      if any [none? rest "" = rest] [ make error! join  "No protocol specified: " url]

      ; protocol must be the first thing in the url string.

      ;rest: any [find/match url "ftp://" find/match url "http://"]
      rest: find/match/any/part url "*://" 8 ; noen ganger kommer det "//" om igjen senere i en url
                                      ; (ved en feil!), og da krasjer vi like under her.
                                      ; (6.11.04:) Det må jo være "://" for at det skal krasje??

      protocol: copy/part head rest (index? rest) - 1

      if any [none? rest "" = rest] [ make error! join  "No host specified: " url]

      phost: first parse rest "/" ; don't need parse/all, because no spaces are allowed in URLs
                                 ; (and if there were spaces in a url, it most certainly is _not_
                                 ; in the host part anyway)

      host: parse phost "@"
      if 2 = length? host [
        phost: second host
        host: parse first host ":"
        user-name: first host
        if 2 = length? host [
          password: second host
        ]
      ]

      host: parse phost ":"
      if 2 = length? host [
        if error? try [ port: to-integer second host  ] [ make error! join  "Port number is not an integer: " url]
      ]
      if 0 = length? host [ make error! join "Imparsible (?) host name in input url: " url ]
      ;probe rest halt
      host: first host

      rest: find/tail rest phost
      path: either any [none? rest 0 = length? rest] [ "/" ] [ copy rest ]

      if not any [none? path "" = path] [
        file: either #"/" = last path [ "" ] [ last parse path "/" ]
      ]

      if not any [none? file "" = file] [
        path: copy/part path (index? find path file) - 1
      ]

    ] ; end either relative?

    rejoin-it

  ] ; end init


  rejoin-it: func [] [
    ; first remove ../ sequences:
    if find path "../" [
      parts: parse/all path "/"
      while [i: find parts ".."] [remove remove back i]
      while [i: find parts ""] [remove i]
      forall parts [ insert parts "/" parts: next parts ]
      append parts "/"
      path: rejoin head parts
      if 0 = length? path [path: "/"]
    ]

    ; then remove ./ sequences:
    if find path "./" [
      parts: parse/all path "/"
      while [i: find parts "."] [remove i]
      while [i: find parts ""] [remove i]
      forall parts [ insert parts "/" parts: next parts ]
      append parts "/"
      path: rejoin head parts
      if 0 = length? path [path: "/"]
    ]

    ; then rejoin:
    url: either port = 80 [
      either user-name = "" [
        rejoin [protocol host path file query-part section]
      ] [
        either password = "" [
          rejoin [protocol user-name "@" host path file query-part section]
        ] [
          rejoin [protocol user-name ":" password "@" host path file query-part section]
        ]
      ]
    ] [
      either user-name = "" [
        rejoin [protocol host ":" port path file query-part section]
      ] [
        either password = "" [
          rejoin [protocol user-name "@" host ":" port path file query-part section]
        ] [
          rejoin [protocol user-name ":" password "@" host ":" port path file query-part section]
        ]
      ]
    ]
  ] ; end rejoin-it

  canonical: func [] [
    either user-name = "" [
      rejoin [protocol host ":" port path file query-part section]
    ] [
      either password = "" [
        rejoin [protocol user-name "@" host ":" port path file query-part section]
      ] [
        rejoin [protocol user-name ":" password "@" host ":" port path file query-part section]
      ]
    ]
  ] ; end canonical

  as-string: func [/regard-section /regard-cgi-order /from-path-only] [
    trew: rejoin either regard-cgi-order [
      either from-path-only [ [ path file query-part ] ]    [ [ protocol host path file query-part ] ]
    ] [
      trs: copy "?"
      forskip query-block 2 [
        append trs join first query-block join "=" join either none? second query-block [""] [second query-block] "&"
      ]
      remove back tail trs
      query-block: head query-block
      either from-path-only [ [ path file trs ] ]           [ [ protocol host path file trs ] ]
    ]
    if regard-section [append trew section]
    trew
  ] ; end as-string

  move-to: func [ target ] [
    url: copy target
    init
    as-string ; just to return something.
  ] ; end move-to

  equal?: func [ other-url /regard-section /regard-cgi-order] [
    section-ok?: either regard-section [section = other-url/section] [yes]
    query-part-ok?: either regard-cgi-order [query-part = other-url/query-part]
                                            [query-block = other-url/query-block]
    return either all [
                  user-name = other-url/user-name
                  protocol = other-url/protocol
                  host = other-url/host
                  port = other-url/port
                  path = other-url/path
                  file = other-url/file
                  query-part-ok?
                  section-ok?
               ]
          [ true ] [ false ]
  ] ; end equal?

] ; end url-handler-object



; shortcut:
url-handler: func [ st [string!] /local s] [
  s: make url-handler-object [ url: copy st ]
  s/init
  return s
]
