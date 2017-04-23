REBOL [
    Title: "CGI Emailer Form (HTML Part)"
    Date: 20-Jul-1999
    File: %cgiemailhtml.r
    Purpose: {
        HTML form to go with CGI Emailer example (cgiemailer.r).
    }
    Notes: {
        Just DO this script to generate the file.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [cgi email markup other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

write %cgiemailer.html {
<HTML>

<HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html;CHARSET=iso-8859-1">
    <TITLE>untitled</TITLE>
</HEAD>

<BODY BGCOLOR="white">

<FORM ACTION="http://ops.rebol.net/cgi-bin/carl/cgiemailer.r" METHOD="GET">
<H2><FONT FACE="Arial, Helvetica">Send an Email Message:</FONT></H2>
<P>
<TABLE BORDER="1" CELLSPACING="1" WIDTH="75%" BGCOLOR="silver">
    <TR>
        <TD WIDTH="9%" BGCOLOR="#3C6F99">
            <P ALIGN="RIGHT"><B><FONT COLOR="white">To:</FONT></B>
        </TD>
        <TD><INPUT TYPE="TEXT" NAME="to" SIZE="40"></TD>
    </TR>
    <TR>
        <TD WIDTH="9%" BGCOLOR="#3C6F99">
            <P ALIGN="RIGHT"><B><FONT COLOR="white">From:</FONT></B>
        </TD>
        <TD><INPUT TYPE="TEXT" NAME="from" SIZE="40"></TD>
    </TR>
    <TR>
        <TD WIDTH="9%" BGCOLOR="#3C6F99">
            <P ALIGN="RIGHT"><B><FONT COLOR="white">Subject:</FONT></B>
        </TD>
        <TD><INPUT TYPE="TEXT" NAME="subject" SIZE="40"></TD>
    </TR>
    <TR>
        <TD WIDTH="9%" BGCOLOR="#3C6F99">
            <P ALIGN="RIGHT"><B><FONT COLOR="white">Message:</FONT></B>
        </TD>
        <TD><TEXTAREA NAME="content" ROWS="10" COLS="40"></TEXTAREA></TD>
    </TR>
</TABLE>
</P>

<P><INPUT TYPE="SUBMIT" NAME="Submit" VALUE="Send Message">
</FORM>

</BODY>

</HTML>
}
