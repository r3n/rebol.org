REBOL [
    Title: "tagit"
    Date: 16-Nov-2004
    Version: 1.0.0
    File: %tagit.r
    Author: "Nigel Salt"
    Purpose: {generate tagged HTML blocks}
    Email: none
    library: [
        level: beginner 
        platform: windows 
        type: 'tool 
        domain: [html markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

tagit: func [
  "Returns second argument enclosed in an html tag set using the first argument"
  tag [string!] "tag"
  text "content to be tagged"
] [
  join "<" [tag ">" text "</" tag ">"]
]

comment {
  Builds simplest possible html document using the tagit function
  tagit builds a tagged string using the first string argument as an HTML tag
  and the second string argument as the body to be enclosed between tags
}
pagetitle: "tagit test page"
titleblock: tagit "title" pagetitle
headblock: tagit "head" titleblock

bodyhead: tagit "h1" pagetitle
bodyp: tagit "p" "bodytext"
bodytext: join bodyhead [bodyp]
bodyblock: tagit "body" bodytext

doctext: join headblock [bodyblock]
docblock: tagit "html" doctext

print docblock



