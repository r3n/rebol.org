REBOL [
    Title: "Easy CGI Form (HTML Part)"
    Date: 19-Jul-1999
    File: %cgiformhtml.r
    Purpose: "HTML form to go with Easy CGI example (cgiform.r)."
    Notes: {
        Just DO this script to generate the file.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'cgi 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

write %cgiform.html {
<HTML>

<HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html;CHARSET=iso-8859-1">
    <TITLE>untitled</TITLE>
</HEAD>

<BODY BGCOLOR="white">

<FORM ACTION="http://your.server.com/cgi-bin/carl/cgiform.r" METHOD="GET">
<H2><FONT FACE="Arial, Helvetica">CGI Form Example</FONT></H2>
<P>
<TABLE BORDER="1" CELLSPACING="1" WIDTH="75%" BGCOLOR="silver">
    <TR>
        <TD WIDTH="9%" BGCOLOR="#66CCFF">
            <P ALIGN="RIGHT"><B>Name:</B>
        </TD>
        <TD><INPUT TYPE="TEXT" NAME="name" SIZE="40"></TD>
    </TR>
    <TR>
        <TD WIDTH="9%" BGCOLOR="#66CCFF">
            <P ALIGN="RIGHT"><B>Email:</B>
        </TD>
        <TD><INPUT TYPE="TEXT" NAME="email" SIZE="40"></TD>
    </TR>
    <TR>
        <TD WIDTH="9%" BGCOLOR="#66CCFF">
            <P ALIGN="RIGHT"><B>Phone:</B>
        </TD>
        <TD><INPUT TYPE="TEXT" NAME="phone" SIZE="20"></TD>
    </TR>
</TABLE>
</P>

<P><INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Submit">
</FORM>

</BODY>

</HTML>
}
