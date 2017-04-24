Rebol [
  Author: "Gordon Raboud"
  File: %hide-email-addresses.r
  Date: 3-June-2005
  Title: "Hide E-Mail Addresses by using Javascript"
  Purpose: {This will take a web page and find all the "mailto:aaa@bbb" and
             convert the addresses to variables for use in Javascript.  This
             effectively 'hides' the addressess from webbot e-mail address
             harvesters.
             Note: This script expects the opening tag (<a href="mailto:...">)
             and the closing tag (</a>) to be on one or at most two lines. }
  Library: [
    Level: 'beginner
    Platform: [all]
    Type: [tool]
    Domain: 'text
    Tested-under: 'W2K
    Support: none
    License: none
  ]
  Version: 1.0
]

QtStr: to-char 34
SearchStr: join "<a href=" [QtStr "Mailto:"]

FileName: Request-file/title/filter "Please select INPUT file to process" "Okay" [*.php *.html *.htm]
If none? Filename [quit]
FileName: to-file FileName
OutFile: Request-file/title/filter "Please select OUTPUT filename" "Okay" [*.php *.html *.htm]
If none? OutFile [quit]
OutFile: to-file OutFile
Open/new OutFile

WebPageText: read/lines Filename

Forall WebPageText [
   SearchLine: first WebPageText
   MailToPos: find SearchLine SearchStr
   If/else MailToPos [
      CloseTag: find SearchLine "</a>"
      If not CloseTag [
         WebPageText: next WebPageText
         SearchLine: join SearchLine [first WebPageText]
      ]
      SearchLine: join SearchLine ["~~~~"]
      parse/all SearchLine [copy IndentStr some " " copy FirstPart to SearchStr SearchStr copy MTName
         to "@" "@" copy MTDomain to "." "." copy MTExt to QtStr thru ">"
         copy VisibleName to "</a>" "</a>" copy LastPart to "~~~~"
      ]
      FirstPart: join IndentStr [FirstPart]
      Write/append/lines OutFile FirstPart
      print join MTName ["@" MTDomain "." MTExt " - " VisibleName]
      NewMailTo: join IndentStr ["<SCRIPT LANGUAGE=" QtStr "javascript" QTStr
            " type=" QTStr "text/JavaScript" QtStr ">" newline
         IndentStr "   var first = 'ma'; var second = 'il'; var third = 'to:';"
            newline
         IndentStr "   var address = '" MTName "'; var domain = '" MTDomain
            "'; var ext = '" MTExt "';" newline
         IndentStr "   document.write('<a href=" QtStr
            "'+first+second+third+address+'@');" newline
         IndentStr "   document.write(domain+'.'+ext+'" QtStr
            ">'+'" VisibleName "</a>');" newline
         IndentStr "   </script>"
         ]
      Write/append OutFile NewMailTo
      Write/append/lines OutFile LastPart
   ]
   [
      Write/append/lines OutFile SearchLine
   ]
]