REBOL [
    Title: "REBOL CGI Test Script"
    Version: 0.0.2
    Name: "CGI-Test"
    File: %test.r
    Date: 17-Jan-2005
    Author: "Dirk Weyand"
    E-Mail: "D.Weyand--TGD-Consulting--DE"
    Owner: "TGD-Consulting"
    Rights: "TGD-Consulting"
    Home: http://www.TGD-Consulting.DE
    Needs: "Serve-It! or any other webserver featuring REBOL CGI-Scripts."
    Purpose: "REBOL Test CGI-Script for Serve-It!"
    License: "Freeware as long as you give credit to the author"
    Library: [ 
         level: 'intermediate
         platform: 'all
         type: [tool]
         domain: [cgi html web]
         tested-under: [view 1.2.1.1.1 on "AmigaOS 68k"] 
         support: none
         license: 'PD 
         see-also: "Serve-It!, at http://www.TGD-Consulting.de/Download.html"
    ]
]

emit-tbl-row: func [
   {Prints HTML-table row to STDOUT.}
   type [string!] "text of first column."
   content [string!] "text of second column."
   colors [block! unset!] "Colors of the columns."
   /local row foo
][
   if error? try [unset? colors] [colors: copy []]
   row: copy {</TD></TR>}
   insert row content
   if none? foo: pick colors 2 [foo: {"white"}]
   insert row join {<TD BGCOLOR=} [foo ">"]
   if none? foo: pick colors 1 [foo: {"white"}]
   insert row join {<TR><TD NOWRAP BGCOLOR=} [foo {><B>} type {</B></TD>}]
   print row
]

; -- HTML-Document starts here ----------------------------------------------------------------------

print {<HTML>
<HEAD>
<STYLE TYPE="text/css">BODY, P, TD {Font-Family: Arial, Helvetica; Font-size: 9pt}</STYLE>
</HEAD>
<BODY BGCOLOR="gray">
<P ALIGN="CENTER">
<TABLE BORDER="0" CELLPADDING="4" CELLSPACING="1" BGCOLOR="black">}

; -- Header-Rows ------------------------------------------------------------------------------------

emit-tbl-row {<P ALIGN="CENTER"><A HREF="http://www.TGD-Consulting.DE/Download.html#reblets">Serve-It!</A> (<A HREF="http://www.TGD-Consulting.DE">© TGD-Consulting</A>)<BR><A HREF="http://www.rebol.com"><IMG SRC="http://www.TGD-Consulting.DE/Images/REBOL.gif" BORDER="0" ALIGN="middle"></A></P>} join {<B>Using: REBOL/} [system/product " " system/version "<BR>Built: " system/build "<BR>Script: " system/script/header/Version " " system/script/header/Date "</B>"] []
emit-tbl-row "Server Data/Time:" form now [{"#C0C060"}]
emit-tbl-row "Current Dir:" form what-dir [{"#C0C060"}]

; -- Base-Rows --------------------------------------------------------------------------------------

foo: third system/options/cgi ; Werte des CGI-Objektes 
until [ emit-tbl-row join form first foo ":" form second foo [{"#F0F080"}]
        lesser-or-equal? length? foo: skip foo 2 2 ]

; -- HTTP-Header Rows -------------------------------------------------------------------------------

either empty? foo: last foo [
  emit-tbl-row form "other-headers" form foo [{"#F0C080"}]
][
  headers: copy []
  until [ insert/only headers reduce [uppercase form pick foo 1 form pick foo 2]
          tail? foo: skip foo 2 ]
  sort headers
  foreach foo headers [
     emit-tbl-row join "HTTP_" [first foo ":"] second foo [{"#F0C080"}]
  ]
]

; -- End of HTML-Document ---------------------------------------------------------------------------

print {</TABLE>
</P>
</BODY>
</HTML>}

;halt