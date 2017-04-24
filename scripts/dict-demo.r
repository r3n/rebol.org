REBOL [
    Title: "using dict protocol from dict.org"
    Date: 17-Jul-2007
    File: %dict-demo.r
    Author: "Brian Tiffin"
    Comment: "Based on work by Jeff Kreis"
    Purpose: {Some usage words for dict:// protocol based on RFC2229}
    Version: 0.9.3
    Rights: "Copyright (c) 2007 Brian Tiffin"
    History: [
        0.9.0 17-Jul-2007 btiffin "First cut - mistakes non-zero probable"
        0.9.1 17-Jul-2007 btiffin "Added demo, inclusion may be overkill"
        0.9.2 18-Jul-2007 btiffin "moved demo out of scheme, lean mean"
        0.9.3 27-Feb-2008 btiffin "corrected soundex and regexp arg handler"
    ]
    Library: [
        level: 'advanced
        platform: 'all
        type: [demo how-to tool]
        domain: [text-processing scheme]
        tested-under: [
            view 1.3.2.4.2 and 2.7.5.4.2
            core 2.6.2.4.2 and 2.7.5.4.2
            Debian GNU/Linux 4.0
        ]
        support: none
        license: 'MIT
        see-also: {http://www.dict.org
                   ftp://ftp.dict.org/pub/dict/contrib/dict.rebol}
    ]
    Usage:   {
        The url scheme defined in RFC2229 is:

        dict://<user>;<auth>@<host>:<port>/d:<word>:<database>
        dict://<user>;<auth>@<host>:<port>/m:<word>:<database>:<strat>

        For instance:

            read dict://dict.org/d:rebel

        returns definitions of "rebel" or:

            read dict://dict.org/m:reb

        returns words that may match "reb", in the same manner as a
        spell-checker. Other strategies can be specified. See the RFC
        for details, or use strat: as the query type for a list.

            read dict://dict.org/

        returns the available databases.

        This port handler will also accept urls of this form:

            read dict://dict.org/word

        which will return definitions for the word in question.

        Some port handler "extensions" from the RFC
        This handler is coded to return a block! of string!
           or a block! of blocks for definitions

        Also:
            default host is set to all.dict.org, See http://www.dict.org
            read dict:///d:word or
            read dict:///define:word for definitions
            read dict:///m:word or
            read dict:///match:word for matches and translations
            read dict:///help: will return a block of help
            read dict:///strat: will return the strategies for all.dict.org
            read dict:///info:db for database source and copyright info
            read dict:///server: system administrator server information
            read dict:///status: server status and timings
        without the colon, they are just words for definition

        Demo: To try out the samples, instead of just do %dict-scheme.r
           Use dict: do %dict-scheme.r  as the information hiding context
           is returned by do.  Then you can evaluate dict/demo
    }
]

comment {
This code is based on the work of Jeff Kreis,
held at ftp://ftp.dict.org/pub/dict/contrib/dict.rebol
Jeff has coded his handler for direct port access, didn't
work properly under 2.7.5.4.2
REBOL [
    Title:  "REBOL dict Protocol $Revision: 1.0 $"
    Date:   19-Aug-1999
    File:   %dict.r
    Author: "Jeff Kreis"
    Email:  jeff@rebol.com
    Purpose: {
        Implements the dict protocol as per RFC2229.
        See www.dict.org for details.
    }
    ...
]
}
;; Load in the scheme
if none? in system/schemes 'dict [
    either value? 'do-thru [
        do-thru http://www.rebol.org/library/scripts/dict-scheme.r
    ][
        do read http://www.rebol.org/library/scripts/dict-scheme.r
    ]
]
;;
;; Demo code, little regard for global namespace, well some
;;
demo: has [showtell code tell out dp] [
    showtell: func [str] [
        tell/text: str  show tell
        out/text: do tell/text
        show out  print out/text
    ]
    either all [value? 'view?  view?] [
        view layout compose [
            style bt btn 100
            across
            h2 "dict:// port handler, see"
            h1 "http://dict.org" h2 "for details"
            below
            tell: field 426
            out: area 426x140
            across
            bt "Show DB" [showtell "read dict:///"]
            bt "Match Strategies" [showtell "read dict:///strat:"]
            bt "foldoc Info" [showtell "read dict:///info:foldoc"]
            bt "Server Summary" [showtell "read dict:///server:"]
            return
            bt "Define TCPIP" [showtell "read dict://dict.org/d:tcpip"]
            bt "Translate SERVER" [
                showtell "read dict://dict.org/d:server:trans"
            ]
            bt "re Match c?rl$" [
                showtell "read dict:///match:c?rl$:*:re"
            ]
            bt red "Canada" [showtell "read dict:///d:Canada:world95"]
            return
            btn "Close" [unview/all]
            btn "dict.org" [browse http://dict.org]
        ]
    ][  ;; no view tricks, just a sample
        do code: {
            print read dict:///match:hello:trans
            print read dict:///define:oxygen:elements
            print read dict:///define:corpus:bouvier
            print read dict:///match:Noah:hitchcock
            print read dict:///info:easton
            print read dict://dict.org/d:AI:jargon
            print read [
               scheme: 'dict  host: "dict.org" target: "define:UTF:foldoc"
            ]
            trace/net on
            print read dict:///server:
            print read [scheme: 'dict target: {match:^^^^c[a|u]rl$:*:re}]
            trace/net off
        }
        print ["Those queries look like this:" newline code]
        print ["Fun with words and the internet"
            newline "Please visit http://dict.org"]
    ]
]
;; Short blurb about what's included
print ["You can now try: demo, def, thes, spell, soundex, regexp, trans, cia"
    newline "For demo and how-to...not thoroughly tested, maybe untrue"]
;;
;; Console utility words...these are all coded differently to demonstrate
;;
def: func ["Look up a definition"
    'str [word! string!] "Word to look up"
    /host 'server [word! string!] "The host, default all.dict.org"
    /database 'db [word! string!] "The database to use"
    /local url value
][
    ;; while read url is nice and short, allow for weirdness
    url: rejoin [dict:// any [all [host server] "all.dict.org"]
        "/d:" str ":"
        any [all [database db] ""]
    ]
    if error? value: try [read url] [
        print mold disarm value
        ;; try with block! url-parse may have kakked
        value: read compose [
            scheme: 'dict
            host: (any [all [host server] "all.dict.org"])
            target: (rejoin ["d:" str ":" any [all [database db] ""]])
        ]
    ]
    print value
]

thes: func ["Look in thesaurus"
    'str [word! string!] "Word to look up"
    /host 'server [word! string!] "The host, default all.dict.org"
    /local url
][
    ;; simple form, but may fail on actual url for 'word word' etc
    url: rejoin [dict:// any [all [host server] "all.dict.org"]
        "/d:" str ":moby-thes"
    ]
    print read url
]

spell: func ["Look for matches"
    'str [word! string!] "Word to look up, may be regex"
    /host 'server [word! string!] "The host, default all.dict.org"
    /database 'db [word! string!] "The database to use"
    /strategy 'strat [word! string!] "The strategy; prefix is default"
    /local value
][
    value: read compose [
        scheme: 'dict
        host: (any [all [host server] "all.dict.org"])
        target: (rejoin ["m:" str ":" any [all [database db] "*"]
            ":" any [all [strategy strat] "prefix"]])
    ]
    attempt [print extract/index parse first value none 2 2]
]
soundex: func ['str] [spell/strategy :str "soundex"]
regexp: func ['str] [spell/strategy :str "re"]
endsinvowels: does [regexp "[a|e|i|o|u]{4}$"]

trans: func ["Translate"
    'str [word! string!] "Word to translate"
    /host 'server [word! string!] "The host, default all.dict.org"
    /local url value split
][
    ;; simple form, but may fail on actual url for 'word word' etc
    url: rejoin [dict:// any [all [host server] "all.dict.org"]
        "/d:" str ":trans"
    ]
    ;; may not pull out correct fields, etc...
    value: read url
    print [length? value "translations for" str]
    foreach item value [
        split: parse first item none
        print [split/2 split/4 split/5]
    ]
]

cia: func ["WorldFacts"
    'str [word! string!] "Country to look up"
    /host 'server [word! string!] "The host, default all.dict.org"
    /local url
][
    ;; simple form, but may fail on actual url for 'word word' etc
    url: rejoin [dict:// any [all [host server] "all.dict.org"]
        "/d:" str ":world95"
    ]
    ;; display 1995 facts
    print read url

    ;; Worldfacts 2002 out as well, for comparison
    url: rejoin [dict:// any [all [host server] "all.dict.org"]
        "/d:" str ":world02"
    ]
    ;; return this value
    read url
]
