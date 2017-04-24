rebol[
   Title:   "XML node parser"
   Date:    20-Jul-2003
   Version: 0.0.1
   File:    %RblxelParser.r
   Home:    http://www.rebol.com/
   Author:  "daniel murrill"
   Email:   drebol@mindspring.com
   Owner:   "daniel murrill"
   Rights:  "Copyright (C) daniel murrill 2000"
   Language: 'English
   Charset: 'ANSI
   Purpose: {
      To parse single xhtml & xml nodes
       for there values.

   }

   Comment: {
     The purpose for this script is to parse well
     formed xml or xhtml, but  can be
     used for css and html.  This is only the xml
     node functions (i.e. *xml node object).  This
     script has been taken from a larger
     portion thats used in a Rebol browser.

    If desired, you can email me a copy of these
    functions that have been better scripted
    or post to the Library, i'll see about swapping
    it for my rusty functions, but please base it off
    the existing functions.
    Be carefull, using *copy/part (find blah blah)(find blah blah)*
    does not behave all the time when putting *getnode... functions
    in larger that dynamically creates portions from itself.
    Or maybe it's just me.
   }

    Library: [
        level: 'beginner
        platform: none
        type: []
        domain: [dialects html markup parse xml]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
xml: {<root>

<personel_Info>
<name first="yes">Madirth</name>
<address second="no">1202 Madison</address>
<resort>Balam </resort>
<resort>Na  Resort</resort>
<resort>Balam  Resort</resort>
 <TR>"names" "Cabo" "Baja"</TR>
<resort>Resort Balam </resort>
<birth>  "24" "1968"</birth>
</personel_Info>
<pop>
<pop meetrow="fat">back</pop>
</pop>
<good>jump</good>
</root>
}
 getnodename: func [tag]
[
heads: to-string copy tag insert heads "<"
        findtail: parse/all tag " " tails: findtail/1
        tails: to-tag join "/" tails
        parse xml
[
to heads copy node to ">" (heads: to-string reduce [heads">"])
            thru ">" copy text to tails (text: to-string text)
            (parse node
[
some [thru " " copy attname to "=" thru "=" copy attvalue to ">"
] skip
]
                print [heads text tails])
]
]
    getnodevalue: func [txt] [
text: txt if find xml text
[
parse xml
[
                thru "<" copy htag to txt copy text thru txt to "</"
]
            findtag: copy htag
            setag: find/last findtag "<"
            parse setag [thru "<" copy gethead to ">"]
            sethead: copy gethead
            hds: parse/all sethead " " gettail: copy hds/1
            heads: copy setag
            tails: to-tag copy gettail insert tails "/"
            parse setag
[
thru " " copy attname to "=" thru "=" copy attvalue
to ">"
]
]
        node: to-string reduce [heads text tails]
        print node
    ]
    getattribute: func [attrv]
[
        parse xml
[
to "<" copy heads to attrv
            copy attribute to ">" thru ">" copy text to "<"
]
        hds: find/last heads "<"
parse xml
[
to hds copy heads thru ">"
]
        parse hds
[
thru "<" copy gettail to " " (trim/all gettail)
]
        tails: to-tag copy gettail insert tails "/"
        parse heads
[
thru " " copy attname to "=" thru "=" copy attvalue to end
]
        node: to-string reduce [heads text tails]
        print node
]
    setnode: func [newhead]
[
findhead: to-string copy newhead insert findhead
 "<"
        size: length? heads findtail: parse/all findhead " " settail: copy findtail/1
        remove settail settail/1
        insert settail "/" newtail: to-tag settail
        either heads = "" [] [parse xml [to heads mark:
                (remove/part mark size mark: insert mark findhead) :mark]
replace xml tails newtail
            parse newtail
[
some
[
thru " " copy attname to "=" thru "=" copy attvalue to end
] skip
]
]
]
    setnodevalue: func [newtext]
[
size: length? text parse xml
[
to text mark:
             (remove/part mark size
             mark: insert mark newtext) :mark
]
]
    setattribute: func [attrvar attrvalue]
[
        hds: copy heads
        replace hds attname attrvar
        replace hds attvalue attrvalue
        replace xml heads to-string reduce [hds ">"]
        attname: attrvar
        attname: attrvar
        attvalue: attrvalue
]
    getchildnode: func [] [parse xml
[
to heads copy childnode to tails (
                replace childnode heads ""
                remove childnode ">"
                replace childnode tails ""
                parse childnode
[
to "<" copy heads to ">" thru ">" copy text to "<" (text: to-string text)
]
                hds: parse/all heads " " gettail: to-string hds/1
                gettail: remove head gettail
                tails: to-tag copy gettail insert tails "/"
                node: to-string reduce [heads ">" text tails]
                print node)]
    ]
    getnextsibling: func [] [
oldnode: copy/part (find xml text) (find/last xml "</")
        either find oldnode heads [
            parse oldnode
[
thru text to heads copy nhead thru ">" copy text to "<"
]
            parse nhead
[
thru " " copy attributename to "=" thru "=" copy attributevalue to ">"
]
            node: to-string reduce [heads text tails]
            print node
]
[print reduce
[
heads "has no sibling...."
]
]
]
    createnode: func [newnode]
[
tailnode: newnode
        parse xml
[
to text thru text to tails thru tails objtail: to "<"
objtext: (change/part objtail reduce [newline newnode newline] :objtext)
(parse tailnode [some [thru ">" copy text to "</" (getnodevalue text)]])
]
]
    removenode: func []
    [
        un: copy node
        replace xml node "    "
        replace xml "^/^/" "^/"
    ]
    undo: func []
    [
        replace xml "    " un
    ]

{a simple example of xmlnode parse functions....}

getnodename "name"
getattribute attname
getnodevalue "Balam"
setnodevalue reduce [text "parks"]
getnodevalue "jump"
setnode {pops second="me"}
getattribute "second"
setattribute "firstone" {"them"}
getattribute "firstone"
setattribute "second" {"me"}
getattribute "second"

halt