REBOL[
    Title: "Environment"
    Version: 0.1.0
    Date: 24-12-2006
    Author: "Peter WA Wood"
    Copyright: "Peter WA Wood"
    File: %environ.r
    Purpose: {Provides five functions that decode system/version:
              os? which returns a string indicating operating system
              nix? which returns true under a unix-type operating system
              win32? which returns true under a windows 32 bit os
              win?  which returns true under a windows os
              cpu? which returns a string indicating the CPU class
              
              The source of the underlying information was taken from:
              http://www.rebol.com/releases.html}
              History:  {0.1.0 21-12-2006 Initial version}
    Library: [
        level: 'beginner
        type: [package function]
        domain: [cgi shell win-api]
        platform: 'all
        tested-under: [ core 2.6.2.2.4 "Mac OS X 10.2.8"]
        support: none
        license: cc-by 
        {see http://www.rebol.org/cgi-bin/cgiwrap/rebol/license-help.r}
    ]
]

environ: make object! [
  os?: func [{returns the operating system in the form of a string:
              "win32", "mac", "linux", 'bsd", "netbsd", "openbsd", "solaris",
              "hp-ux", "wince", "aix", "other"}
  ][
    switch/default fourth system/version
    [
       2 [either 4 = fifth system/version 
          [return "mac"]
          [return "other"]
       ]
       3 [either 1 = fifth system/version
          [return "win32"]
          [return "other"]
       ]
       4 [return "linux"]
       6 [return "bsd"]
       7 [return "freebsd"]
       8 [return "netbsd"]
       9 [return "openbsd"]
      10 [return "solaris"]
      12 [return "hp-ux"]
      15 [either find [1 2 3 5 6] fifth system/version
          [return "wince"]
          [return "other"]
      ]
      17 [return "aix"]
    ][
      return "other"
    ]
  ]

  nix?: func [{returns true when run under a unix-style os}] 
  [
    either find ["mac" "linux" "bsd" "freebsd" "netbsd" "openbsd" "solaris"
                 "hp-ux" "aix"] os?
      [return true]
      [return false]
  ]

  win32?: func [{returns true when run under a windows 32 bit os}]
  [
    either os? = "win32" 
      [return true]
      [return false]
  ]

  win?: func [{returns true when run under a windows os}]
  [
    either find ["win32" "wince"] os?
      [return true]
      [return false]
  ]

  cpu?: func [{returns the type of cpu in the form of a string:
               "ppc", "x86", "sparc", "other"}
  ][
    switch/default os?
    [
      "mac" [return "ppc"]
      "win32" [return "x86"]
      "linux" [switch/default fifth system/version 
        [
          1 [return "x86"]
          2 [return "x86"]
          4 [return "ppc"]
          6 [return "sparc"]
          7 [return "ultrasparc"]
          8 [return "strongarm"]
        ][return "other"]
      ]
      "bsd" [return "x86"]
      "freebsd" [return "x86"]
      "netbsd" [switch/default fifth system/version 
        [
          1 [return "x86"]
          2 [return "ppc"]
          5 [return "sparc"]
        ][return "other"]
      ]
      "openbsd" [switch/default fifth system/version 
        [
          1 [return "x86"]
          2 [return "x86"]
          5 [return "sparc"]
        ][return "other"]
      ]
      "solaris" [switch/default fifth system/version 
        [
          1 [return "sparc"]
          2 [return "x86"]
        ][return "other"]
      ]
      "aix" [return "ppc"]
      "wince" [switch/default fifth system/version 
        [
          2 [return "mips"]
          3 [return "ppc"]
          5 [return "strongarm"]
        ][return "other"]
      ]
    ][
      return "other"
    ]
  ]
] ;; end of make environ
