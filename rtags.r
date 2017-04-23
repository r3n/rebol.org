REBOL [
    Title: "REBOL tagfile generator"
    Date: 1-Jan-2002
    Version: 1.1.0
    File: %rtags.r
    Author: "Ernie van der Meer"
    Purpose: {Generates a tagfile that can be used with vi/emacs to quickly locate set-words in your code}
    Email: eavdmeer@itr.ing.nl
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: 'cgi 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

tagger: context
[
  tagfile-header: rejoin [
    "!_TAG_FILE_FORMAT" tab "2" tab "/extended format/" newline
    "!_TAG_FILE_SORTED" tab "0" tab "/0=unsorted, 1=sorted/" newline
    "!_TAG_PROGRAM_AUTHOR" tab "Ernie van der Meer" tab
    "/e.a.vdmeer@net.hcc.nl/" newline
    "!_TAG_PROGRAM_NAME" tab "REBOL Rtags" tab "//" newline
  ]
  tagfile-line: [ tagname tab tagfile tab "/" tagpattern {/;"} newline ]

  taglist: none
  tag-current-file: none

  ctxwordset: [ "set" whitespace "in" whitespace
    [ path | identifier ] whitespace copy sw litword
    [ rcomment | newline | tab | " " ]
    (append/only taglist reduce [ next sw tag-current-file "cws" ] ) ]
  wordset: [ "set" whitespace copy sw litword
    [ rcomment | newline | tab | " " ]
    (append/only taglist reduce [ next sw tag-current-file "ws" ] ) ]
  litword: [ "'" identifier ]
  setword: [ copy sw [ path | identifier ] ":"
    [ rcomment | newline | tab | " " ]
    (append/only taglist reduce [ sw tag-current-file "sw" ] ) ]
  path: [ identifier some [ "/" identifier ] ]
  identifier: [ startchar any legalchar ]
  startchar: [ letter | capital ]
  legalchar: [ letter | capital | numeric | special ]
  lit-docs: [ "^"" thru "^"" ]
  docs: [ "{" thru "}" ]
  rcomment: [ ";" thru newline ]
  whitespace: [ some [ tab | " " ] ]
  letter: charset "abcdefghijklmnopqrstuvwxyz"
  capital: charset "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  numeric: charset "0123456789"
  special: charset "-_?"

  get-tags: func
  [
    f [file! string! word! path!]
  ]
  [
    print join {Getting tags for: } to string! f
    taglist: copy []
    tag-current-file: to string! :f

    parse/all read either file? :f [ f ][ to file! :f ]
      [ some [ rcomment | docs | lit-docs | setword |
        wordset | ctxwordset | skip ] ]
    return taglist
  ]

  tag: func
  [
    bl [block!]
    /dest-file file [string!] {Send output to an alternative file.}
    /local entry tlist content
  ]
  [
    tlist: copy []
    repeat entry bl
    [
      append tlist get-tags :entry
    ]
    print rejoin [ length? tlist " tags found" ]
    print "Sorting tag list"
    tlist: sort unique tlist
    print rejoin [ "Have " length? tlist " unique tag entries" ]

    print "Creating tag file content"
    content: copy tagfile-header
    repeat entry tlist
    [
      tagname: replace entry/1 "system/words/" ""
      tagfile: entry/2
      tagpattern: switch entry/3
      [
        "sw"  [ rejoin [ "\<" tagname ":" ]]
        "ws"  [ rejoin [ "set\.\*'" tagname ]]
        "cws" [ rejoin [ "set\.\*in\.\*'" tagname ]]
      ]

      append content reduce tagfile-line
    ]

    either dest-file
    [
      either file = "-"
      [
        print content
      ]
      [
        print rejoin [ "Writing output to " file newline ]
        write to file! file content
      ]
    ]
    [
      print rejoin [ "Writing output to ./tags" newline ]
      write %tags content
    ]
  ]

  usage: func []
  [
    print rejoin [
      "Rebol tag generator ala ctags." newline newline
      "Command line usage:" newline newline
      "    rtags [options] [file(s)]" newline newline
      "Supported options:" newline newline
      "    -o file  Output tags to the specified file (default is 'tags')."
      newline
      "             If specified as '-', tags are written to standard output."
      newline
    ]
  ]
]

args: either system/script/args [parse system/script/args none][[]]

option: select args "-o"

either option
[
  args: skip args 2

  either 0 < length? args
  [
    tagger/tag/dest-file args option
  ]
  [
    tagger/usage
  ]
]
[
  either 0 < length? args
  [
    tagger/tag args
  ]
  [
    tagger/usage
  ]
]
                                                                                                                                                          