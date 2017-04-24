rebol[Title:   "XML to HTML node parser"
   Library: [
     level: 'intermediate
     platform: 'all
     type: 'tool
     domain: [xml html markup ]
     tested-under: windows
     support: none
     license: none
     see-also: none
   ]
   Date:    1-Jan-2001
   Name:    'QuickParser
   Version: 0.0.2
   File: %quickparser.r
   Home:    http://www.rebol.com/
   Author:  "daniel murrill"
   Email:   drebol@mindspring.com
   Owner:   "daniel murrill"
   Rights:  "Copyright (C) daniel murrill 2000"
   Language: 'English
   Charset: 'ANSI
   Purpose: {
      To parse xml, xhtml, css, and html
      so you can search and update, remove, 
      or add to your markup quickly.
      
   }

   Comment: {
      The purpose for this script is to 
     parse  xml, xhtml, css, and html.  
     These xml parse functions are
     concurrent with the W3C standards.
     This script has been taken from a larger
     portion that's used in a Rebol browser.  

     }
]
var: func [xmlname xmldata][
set xmlname xmldata xml: copy xmldata
]
var 'xmlblock {<root>
<personel_Info>
<name first="yes">Madirth</name>
<address second="no">
<resort>Balam </resort> 
<resort>Na  Resort</resort> 
<resort er="jk" ver="kote">Balam  Resort</resort>
</address> 
<address second="no">
<resort>Balam qwerty</resort> 
<resort>Na  Resort</resort> 

</address> 
 <TR>"names" "Cabo" "Baja"</TR> 
<resort>Resort Balam </resort> 
<birth>  "24" "1968"</birth>
</personel_Info>
<popper>
<pop meetrow="fat">back</pop>
</popper>
<good wild="one">jump</good>
 <textbar> 
<button>
     <btn1><color>gray</color></btn1>
</button>

 <button>
      <btn1><color>green</color></btn1>
</button>
<button>
      <btn1><font color="green">green</font></btn1>
</button>
 <button>
     <btn2><color>gray</color></btn2>
  </button>
</textbar> 
</root>
}
cleantag: does [heads: ""
tails: ""
text: ""
node: ""
]
 getnodename: func [tag] 
[
cleantag
heads: to-string copy tag insert heads "<"
        findtail: parse/all tag " " tails: findtail/1
        tails: to-tag join "/" tails
        parse/all xml 
[
to heads copy nodename to ">" (heads: to-string reduce [nodename ">"])
            thru ">" copy text to tails (text: to-string text)
            (parse nodename 
[
some [thru " " copy attname to "=" thru "=" copy attvalue to ">"
] skip
]node: to-string reduce [heads text tails] 
                print [heads text tails])
]
]

selectnodes: func [nodename childnode nodevalue  ]
[ 
cleantag
getchildnodes: [] childnode: join "<" childnode text: copy nodevalue
        heads: to-string reduce ["<" nodename]
        tails: to-string reduce ["</" nodename ">"]
        nodelist: ""  clear getchildnodes
      parse xml[
          some [
          to heads copy nodeslist thru tails 
          (        getnode: find nodeslist nodename
                   gettails: find nodeslist tails 
                   node: find/part getnode nodevalue gettails
                   if find nodeslist childnode [

append getchildnodes nodeslist
])]skip

]print getchildnodes
]


    getnodevalue: func [txt] [
cleantag
parse/all xml 
[
                thru "<" copy htag to txt copy text to "</" (
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

        node: to-string reduce [heads text tails]
        print node)
]
]
    getattribute: func [attrv] 
[
        
        parse/all xml [any
[
to "<" copy heads to attrv
            copy attribute to "=" thru {="} copy attvalue 
to ">" (attvalue: parse/all attvalue {"} attvalue: attvalue/1) thru ">" copy text 
to "</"
]skip
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
        node: to-string reduce [heads text tails]
        either find heads attrv [print node][print reduce [attrv {not found...}]] 
]

    getattvalue: func [attval] 
[
        parse/all xml [any
[
to "<" copy heads to attval copy attvalue 
to ">" (attvalue: parse/all attvalue {"} attvalue: attvalue/1) thru ">" copy text 
to "</"
]skip
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
        node: to-string reduce [heads text tails]
        print node
]

setnode: func [newhead] 
[
newhead: to-string copy newhead 
        insert newhead "<"
        findtail: parse/all newhead " " 
        settail: copy findtail/1 
        remove settail settail/1
        newtail: to-tag to-string reduce ["/" settail]
parse xml [to heads copy oldhead thru text to "</"]
oldhead: find/last oldhead "<"
size: parse/all heads " "
parse xml 
[
to oldhead mark: (replace mark size/1 ""
mark: insert mark newhead) :mark
to tails mark: (replace mark tails ""
mark: insert mark newtail) :mark
]
parse xml 
[
to newhead copy heads to text
]
            parse newhead 
[
thru " " copy attname to "=" thru "=" copy attvalue to end
]clear newhead
]

    setnodevalue: func [newtext] 
[
size: length? text  
parse/all xml [some
[
to heads thru heads to text mark:
             (remove/part mark size 
             mark: insert mark newtext) :mark
(text: mark)]skip
]
]
   setattribute: func [attrvar attrvalue] 
[
findhead: parse/all heads " " 
thishead: to-string findhead/1
        parse xml 
[
to thishead thru thishead
to attname mark: (replace mark attname ""
mark: insert mark attrvar) :mark
to attvalue mark: (replace mark attvalue ""
mark: insert mark attrvalue) :mark
]

        attname: attrvar
        attvalue: attrvalue
]

    getchildnode: func [] [

parse xml 
[
to heads copy childnode to tails (
                replace childnode heads ""
                remove childnode ">"
                replace childnode tails ""
                parse childnode 
[
to "<" copy heads to ">" (tails: parse/all heads " " 
                                        tails: form tails replace tails "<" "</") 
thru ">" copy text to tails (text: to-string text)
]
                replace text heads "" 
                hds: parse/all heads " " gettail: to-string hds/1
                gettail: remove head gettail
                tails: to-tag copy gettail insert tails "/"
                node: to-string reduce [heads ">" text tails]
                print node)]
    ]


     getnextsibling: func [] [
gethead: replace heads ">" ""
gethead: parse/all gethead " "
gethead: to-string gethead/1
oldnode: copy/part (find xml text) (find/last xml "</")
        either find oldnode gethead [
            parse oldnode 
[
thru tails to gethead copy heads thru ">" copy text to tails
]
            parse heads 
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

    appendnode: func [newnode] 
[
tailnode: newnode
endnode: find/last xml "</" 

        parse xml 
[
objtail: to endnode 
objhead: (append objtail reduce [newnode newline] :objhead 
parse endnode [to "</" copy lastnode thru ">"]
replace xml lastnode ""
append xml lastnode) 
(parse newnode [thru ">" copy text to "</" (getnodevalue text)])
]
]

    removenode: func []
    [either find xml node [
        replace xml node "    "
        replace xml "^/^/" "^/"
    ][
       print "Node not found"
   ] 
   ]


{a simple example of xmlnode parse functions....}


thisxml: copy xml

xmldom:  
make object! [
    var: 'xmldom
    xml: copy thisxml  
    objnode:
    make object! [
        heads: none
        text: none
        tails: none
        
    ]
        nodeType: none 
        parentNode: none 
        childNodes: none
        firstChild: none  
        lastChild: none  
        previousSibling: none  
        nextSibling: none
        attributes: none 

    documentElement:
    make object! [
        appendchild: func [this][
            parse xmldom/xml [thru "<" copy opendoc to ">"]
            getnodename opendoc root: copy form tails size: length? root
            parse xmldom/xml [to root mark: (remove/part mark size)]
            set in xmldom 'xml to-string reduce [xmldom/xml this newline root]
  ]
       
    ]
insertBefore: func [position newnode][xmldom/getnodename position
        parse xml [to "<" copy xmlhead nodehead: to heads objnewnode: (change/part nodehead
 reduce [  xmlhead newnode newline] :objnewnode)]]
    getnodename: func [element][xml: copy to-string xmldom/xml
        if find xml element [heads: to-string copy element insert heads "<"
            tails: to-string copy element
            insert tails "/" tails: trim/all to-tag tails
            parse xml [to heads copy node thru tails]  
            this: copy node print [node]]
        objnode/heads: heads objnode/text: text objnode/tails: tails
    ]

setnode: func [newhead][ 
findhead:  to-string copy newhead insert  findhead "<"
 size: length? tail findtail: parse/all findhead " " 
       settail: copy findtail/1 remove settail settail/1
       insert settail "/" newtail:  to-tag settail  
parse xml [ 
  to heads  mark:(remove/part mark size 
  mark: insert mark findhead) :mark 
]
  replace xmldom/xml tails newtail 
parse xml [
  to mark copy node thru tails
] this: copy node
]

    getnodevalue: func [value][xml: copy to-string xmldom/xml
        if find xml value [parse xml [
                thru "<" copy htag to value copy text thru value to "</"]
            findtag: copy htag
            setag: find/last findtag "<"
            parse setag [thru "<" copy gethead to ">"]
            sethead: copy gethead
            heads: to-tag sethead
            gettail: parse/all sethead " " 
            gettail: to-string gettail/1
            tails: to-tag copy gettail
            node: copy/part (find/case xml head) (find/case xml text)
            print [trim/auto heads text tails]]
        objnode/heads: heads objnode/text: text objnode/tails: tails
    ]
    createnode: func [nodename][
        heads: copy nodename 
        setail: parse/all heads " "  
        tails: to-string reduce ["</" setail/1 ">"]
        heads: to-tag heads
    ]
    createtextnode: func [nodevalue][text: copy form nodevalue
    ]
    ]
appendchild: func [data][set 'this reduce [me data tails] 
]
removenode: func[][size: length? this
            parse xmldom/xml [to this mark: (remove/part mark size)]
]
removetextnode: func[][size: length? text
            parse xmldom/xml [to text mark: (remove/part mark size)]
]
call: func [data][set 'me reduce data 
]
createobject: func [data][copy data  do data ]

;Why use a xmldom? So you can work with different 
;files of xml, markup,css,etc. set to different Words.
;you can get a file... var 'xmlblock load %load-some-file.r

;This coding was chosen because its very close to the 
;MSXMLparser, and therefore a rebol function can clean
;it up and add this code automatically to your html page.

set 'x createobject("xmldom")
set 'xmldoc x/documentElement

tagname: x/createnode("PROPERTIES")
txt: x/createtextnode({
SIZE=300X400
BACKCOLOR=RED
NOICONS=TRUE
})

;You must set the called nodename to => this.
call(tagname)appendchild(txt) tagname: this

;You must append this new childnode to the document.
xmldoc/appendchild(tagname)

;The xmlDOM's xml is only a copy of the xmlblock's xml
;If you want changes to the xmlDOM's xml in the xmlblock,
;just do this... var 'xmlblock x/xml.

;var 'xmlblock x/xml

{Function: selectnodes 
This is an E4X function: ECMAscript for xml function

  It's the same as getElementsByTagName function, just shorter 
to write.  The selectnodes func. creates a nodelist of all nodes of
the same name with a childnode that has the requested value.


}



