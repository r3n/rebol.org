REBOL [
  Title: "Unless"
  File: %unless.r
  Author: [ "HY" ]
  Date: 4-Nov-2004
  Library: [
    level: 'beginner
    domain: []
    license: none
    Platform: 'all
    Tested-under: none
    Type: [function one-liner]
    Support: none
  ]
  Purpose: {I'm used to writing 'unless in perl, so I wanted it in rebol as well. Easy.}
  Note: {It appears 'unless will be part of the view 1.3 release. I use this on Core 2.5.6.2.4.}
]

unless: func [condition then-block [block!]] [if not condition then-block]
