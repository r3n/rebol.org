REBOL [
  Title: "DOS Style CD."
  Purpose: "How to use MSDOS style CD."
  File: %cd.r
  Version: 1.0.0
  Date: 2009-09-18
  Author: "Endo"
  Usage: {
    cd %/c/windows
    cd "c:\windows"
    cd ;this will show current dir.
}
    library: [
        level: 'beginner
        platform: 'all
        type: 'one-liner
        domain: 'files
        tested-under: none
        support: none
        license: 'public-domain
        see-also: none
    ]
]
cd: func ["Dos style CD." dir [string! url! file! unset!]][either value? 'dir [either file? dir [change-dir dir] [change-dir to-rebol-file to-string dir]] [what-dir]]
