REBOL [
    Title: "Document Generator"
    Date: 19-Jul-1999
    File: %generate-doc.r
    Author: "Daan Oosterveld"
    Usage: {
        <file name="filename.html> makes a html file... </file>
        <document name="title"> makes a document </document>
        <chaper> <section> <sub-section> are parts of documents </...>
        <example> is a example.
        <toc> inserts a toc with the content docs and chapters </toc>
    }
    Purpose: "XMLish doc generator using parse-XML"
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [markup file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

; Foreach label there is a 'function'
label-functions: [
    file [
        ; throws contents in a named file.
        ; Returns a html with a link to that file
        ; This then can be thrown into another file
        print [".file" select attributes "name"]
        write to-file select attributes "name" reform [
            newline gathercontent content newline 
        ]
        either not none? select attributes "link" [
            rejoin [{<a href="} select attributes "name" {">} select attributes "link" {</a>}]
        ][
            ""
        ]
    ]
    document [
        print [".document" select attributes "name"]
        name: select attributes "name"
        rejoin [
            {<center><h1><a name="} name {">}
            name {</a></h1></center>}
            gathercontent content
        ]
    ]
    chapter [
        print [".chapter" select attributes "name"]
        name: select attributes "name"
        either ((select attributes "indent") = "no") [
            rejoin [
                {<a name="} name {"><h2>} name {</h2></a>}
                gathercontent content
            ]
        ][
            rejoin [
                {<a name="} name {"><h2>} name {</h2></a>}
                "<blockquote>" gathercontent content "</blockquote>"
            ]
        ]
    ]
    section [
        print [".section" select attributes "name"]
        name: select attributes "name"
        rejoin [
            {<a name="} name {"><h3>} select attributes "name" {</h3></a>}
            gathercontent content
        ]
    ]
    subsection [
        print [".sub-section" select attributes "name"]
        name: select attributes "name"
        rejoin [
            {<a name="} name {"><h4>} select attributes "name" {</h4></a>}
            gathercontent content
        ]
    ]
    example [
        print [".example"]
        rejoin [
           {<blockquote>}
           {<table BORDER=0 CELLSPACING=2 CELLPADDING=10><tr valign="top">}
           {<td bgcolor="#eeeeee"><font size=-1><pre>}
           gathercontent content
           {</pre></font></td></tr></table>}
           {</blockquote>}
        ]
    ]
    toc [
        ; the toc filters the contents twice.
        print [",toc"]
        rejoin ["<blockquote>" gathertoc content "</blockquote>^/^/" 
                gathercontent content]]
    history [
        ; history.
        print [".history"]
        temp: make string! 100
        append temp "<center><table BORDER=0 CELLSPACING=2 CELLPADDING=2>"
        foreach entry content [
            set [label attributes contents] entry
            if block? entry [ append temp reform [
                    <tr valign="top">
                    <td BGCOLOR="#eeeeee"> select attributes "version" </td>
                    <td BGCOLOR="#eeeeee"> to-date select attributes "date" </td>
                    <td BGCOLOR="#eeeeee"> select attributes "author" </td> 
                    <td BGCOLOR="#eeeeee"> gathercontent contents  </td></tr> 
                ]
            ]
        ]
        append temp </table></center>
        temp
    ]

   ; if you want to add some html functions then do it here... 
   ; notivy me to add your change...
   br ["<br>"]
   p  ["<p>"]
   hr ["<hr>"]
]
; generate the functions..
forskip label-functions 2 [ 
    change next label-functions func [attributes content] 
        second label-functions 
]
label-functions: head label-functions

; gathers the information for the doc..
gathercontent: function [parsed-xml][temp label attributes content stringed-content][
    stringed-content: make string! 100
    foreach entry parsed-xml [
        do select [
            string! [ append stringed-content entry ]
            block! [
                temp: select label-functions to-word first 
                    set [label attributes content] entry
                ; don't be confused. This is a 'temponary' function call
                append stringed-content temp attributes content
            ]
        ] type?/word entry
    ]
    stringed-content
]

; Gathers the information for the toc and generates the HTML
gathertoc: func [
    parsed-xml 
    /local localtemp label attributes content 
    stringed-toc chapter section subsection
][
    set [chapter section subsection] 0
    stringed-toc: make string! 100
    foreach entry parsed-xml [
        do select [
            string! []
            block! [
                set [label attributes content] entry
                if not none? temp: select [
                    "document" [
                        {<a href="#} name {"><font size="+3">}
                        name {</font></a><br>}]
                    "chapter" [
                        {<a href="#} name {"><font size="+2">}
                        name {</font></a><br>}]
                    "section" [
                        {<a href="#} name {"><font size="+1">}
                        name {</font></a><br>}]
                    "subsection" [
                        {<a href="#} name {"><font size="+0">}
                        name {</font></a><br>}]
                    ] label [
                    name: select attributes "name"
                    append stringed-toc rejoin temp 
                    if not empty? temp: gathertoc content [
                        append stringed-toc reform [
                            <blockquote> gathertoc content </blockquote>
                        ]
                    ]
                ]
                if label = "file" [
                    name: select attributes "name"
                    if found? find attributes "toc" [
                        append stringed-toc rejoin [
                            {<a href="} name {"><font size="+0">}
                            select attributes "toc" #</font></a><br>
                        ]
                    ]
                ]
            ]
        ] type?/word entry
    ]
    stringed-toc
]

; Above is the script, the rest is a simple example, maybe to long for
; simplicity but the above is quite simpel for a doc generator like
; this.

either not exists? %DocGen.html [
    ; Making the standart example docs...
    Print ["Generating the usage docs for this script...^/"
           "After generating, open GenDoc.html in a browser.^/"
           "The next time you run this, you will be prompted"
           "for your own generation file.^/"
           "Press return"]
    input
    parsed: parse-XML {
<file name="DocGen.html">
<document name="How to use DocGen.r">
<history>
        <entry version="1.0.0" date="17-7-1999" author="Daan Oosterveld">
                Made this document for the contest to show how to use docgen.<br/>
                I'm currently using it to write another doc.
        </entry>                
</history>
<chapter name="Content" indent="no">
<toc>

<chapter name="Why a docgeneration program">
        I've written this docgenerator to have a the same style everywhere in a
        document. I also had to have a program that could generate TOCs and more
        files at once. Resulting is a doc generator that can generate docs with
        more html pages which are interlinked by a TOC. Also more documents fit
        into one file, as with this file.
</chapter>

<chapter name="Tags used to define a document">
        I asume you wnat to create one now, this makes explaining easier.
        <section name="&lt;file> tag.">
        Open a text file. Then insert a file tag like XML like this:
        <example>
&lt;File name="Doc.html">
&lt;/File></example>

        The name is the file name where the generated html document should be
        saved. All tags between the file tags will be saved into this file.<p/>
        Each tag generated pure html. The file tag gathers this information
        and rejoins or appends this information into one string. Then this
        is saved to disk.<p/>
        This is the bare bone of the document. After this we can put in text and
        parts.
        </section>

        <section name="&lt;document> tag">
        This tag makes the title of the document. Nicely centered. We will need
        this if we want to make a document. So added to the .rml it will look like
        this:
        <example>
&lt;File name="Doc.html">
 &lt;Document name="A Document title">
 &lt;/Document>
&lt;/File>
        </example>
        The name is the title, it will become a centered H1 in the html. Again all
        between the tags is gathered by the document and passed back to the file
        tag.
        </section>

        <section name="&lt;history> tag">
        The history tag makes a table with four columns where the writter can fill in
        when where and who has written the document. Since this is the first version only
        one history will be added.
        <example>
&lt;File name="Doc.html">
 &lt;Document name="A Document title">
  &lt;History>
   &lt;Entry version="1.0.0" date="18-7-1999" author="You">
    More information on the history can be placed between the tags.&lt;br/>
    You don't have to place the history at the beginning.
   &lt;/Entry>
  &lt;/History>
 &lt;/Document>
&lt;/File>
        </example>
        The history table is to standarize the history. The fields explain
        theirself. Also notice the &lt;br/>, it works like the normal &lt;br>
        in html. &lt;p/> and &lt;hr/> also work like this. If you generate the history it will look like this:

  <p/><History>
   <Entry version="1.0.0" date="18-7-1999" author="You">
    More information on the history can be placed between the tags.<br/>
    You don't have to place the history at the beginning.
   </Entry>
  </History>

        </section>

        <section name="&lt;Chapter> &lt;Section> and &lt;SubSection> tags">
        These tags define a text as a chapter or (sub)section.
        They are simple to use. The name is again the title of the chapter
        or (sub)section. The next example has a simple layout of some chapters
        and (sub)sections.

<example>
&lt;File name="Doc.html">
 &lt;Document name="A Document title">
  &lt;History>
   &lt;Entry version="1.0.0" date="18-7-1999" author="You">
    More information on the history can be placed between the tags.&lt;br/>
    You don't have to place the history at the beginning.
   &lt;/Entry>
  &lt;/History>

  &lt;Chapter name="Chapter1">
   This is chapter #1
  &lt;/Chapter>

  &lt;Chapter name="Chapter2">
   This is chapter #2
   &lt;Section name="Section2.1">
    This is section 2.1
    &lt;SubSection name="SubSection2.1.1">
     This is subsection 2.1.1
    &lt;/SubSection>
    &lt;SubSection name="SubSection2.1.2">
     This is subsection 2.1.2
    &lt;/SubSection>
   &lt;/Section>
   &lt;Section name="Section2.2">
    This is section 2.2
   &lt;/Section>
  &lt;/Chapter>

 &lt;/Document>
&lt;/File>
</example>

        Notice that text can always be inserted. Like html. The structure is important
        for the generating the TOC, more on that is with the &lt;toc> tag.
        </section>

        <section name="&lt;toc> tag">
        This is the tag that generated a Table Of Content, TOC for short. Every Document, Chapter
        Section and SubSection defined between the &lt;Toc> and &lt;/Toc> tags will get an entry
        in the toc. The TOC generates two pieces and then glues these two together. First the
        TOC and then the content between the tags. To make a toc in our document we'll have to
        insert the toc tags around the chapters. To make it even better we insert a extra chapter for
        the TOC. This will be done outside the TOC tags so it will not be listed. We will use Chapter,
        the problem now is that chapters indents all contents, thats why there is a indent="no" option.
        Your Document.rml will look like this:

<example>
&lt;File name="Doc.html">
 &lt;Document name="A Document title">
  &lt;History>
   &lt;Entry version="1.0.0" date="18-7-1999" author="You">
    More information on the history can be placed between the tags.&lt;br/>
    You don't have to place the history at the beginning.
   &lt;/Entry>
  &lt;/History>


&lt;Chapter name="Content" indent="no">
&lt;Toc>


  &lt;Chapter name="Chapter1">
   This is chapter #1
  &lt;/Chapter>

  &lt;Chapter name="Chapter2">
   This is chapter #2
   &lt;Section name="Section2.1">
    This is section 2.1
    &lt;SubSection name="SubSection2.1.1">
     This is subsection 2.1.1
    &lt;/SubSection>
    &lt;SubSection name="SubSection2.1.2">
     This is subsection 2.1.2
    &lt;/SubSection>
   &lt;/Section>
   &lt;Section name="Section2.2">
    This is section 2.2
   &lt;/Section>
  &lt;/Chapter>


&lt;/Toc>
&lt;/Chapter>


 &lt;/Document>
&lt;/File>
</example>

        With all this you will be able to generate a document with a toc and a good layout.
        One thing still has to be explained. The grey example blocks.
        </section>

        <section name="&lt;example> tag">
        It works like the chapter and section tags, it will make a grey block with a fixed size font.
        It made to put sources in. Like a rebol script. It works fine. Beneath is a example block
        which explains how to make a example block.

        <example>
&lt;Example>
REBOL []
Print "This is a example block..."
&lt;/Example></example>
        </section>

        The next chapter will show your document so far.
</chapter>

<chapter name="An example: doc.html">

The nice thing is that if you look at the rml of this document, you will see
that the example document we have created earlier is just placed in the middle
of this chapter. It is generated in this chapter and the file tag profides
a link to the other document. You give the name of the link by setting the
attribute link="Link to your generated document". The link to open your document
should be behind this: 

<File name="Doc.html" link="This is the link to your generated document" toc="Your Document">
 <Document name="A Document title">
  <History>
   <Entry version="1.0.0" date="18-7-1999" author="You">
    More information on the history can be placed between the tags.<br/>
    You don't have to place the history at the beginning.
   </Entry>
  </History>


<Chapter name="Content" indent="no">
<Toc>


  <Chapter name="Chapter1">
   This is chapter #1
   <example>
REBOL []
Print "This is a rebol example block..."
</example>
  </Chapter>

  <Chapter name="Chapter2">
   This is chapter #2
   <Section name="Section2.1">
    This is section 2.1
    <SubSection name="SubSection2.1.1">
     This is subsection 2.1.1
    </SubSection>
    <SubSection name="SubSection2.1.2">
     This is subsection 2.1.2
    </SubSection>
   </Section>
   <Section name="Section2.2">
    This is section 2.2
   </Section>
  </Chapter>


</Toc>
</Chapter>


 </Document>
</File>

        . <p/> There is also a attribute toc="Name in toc" which puts the file into the toc.
        I've added this to the example, notice the top of this document, in the toc there
        is a link to your document again. You can choose to insert it into the text and/or
        insert it into the toc. toc="Your Document" was added to the &lt;file> tag.<p/>
        The whole document source is in the script inself, take a look.
<example>
</example>

</chapter>

</toc>
</chapter>
</document>
</file>
        }
][
    ; The user has to type in a file
    parsed: parse-XML read to-file ask "rml file: "
]

; The statement that makes starts the generating
gathercontent third parsed

