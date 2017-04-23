REBOL [
	Title: "HTML calendar"
	Date: 3-Dec-2003
	Author: "Bohdan Lechnowsky"
	File: %html-calendar.r
	Purpose: {
		Creates an HTML file containing the current calendar month and displays it in
		the browser
	}
	Library: [
		level: 'intermediate
		platform: 'all
		type: []
		domain: [html web]
		tested-under: none
		support: none
		license: none
		see-also: none
	]
]

date: now/date
colwidth: 100
dayrowcol: "806080"
daytextcol: "FFFFFF"
wkendcol: "FFCCCC"
wkdaycol: "FFFFFF"
notthismonthcol: "808080"
outfilename: %month.html

html: copy rejoin [{<HTML><TABLE border=1><TR><TD colspan=7 align=center><FONT size="+2">} pick system/locale/months date/month { } date/year {</FONT></TD></TR><TR>}]

days: head remove back tail insert head copy system/locale/days last system/locale/days

foreach day days [
	append html rejoin [{<TD bgcolor="#} dayrowcol {" align=center width=} colwidth {><FONT face="courier new,courier" color="} daytextcol {" size="+1">} copy/part day 3 {</FONT></TD>}]
]

append html {</TR><TR>}

sdate: date
sdate/day: 0

loop sdate/weekday // 7 + 1 [append html {<TD bgcolor=gray></TD>}]

while [sdate/day: sdate/day + 1 sdate/month = date/month][
	append html rejoin [
		{<TD bgcolor="#}
		either find [6 7] sdate/weekday [wkendcol][wkdaycol]
		{">} sdate/day {</TD>}
	]
	if sdate/weekday = 6 [append html {</TR><TR>}]
]

loop 7 - sdate/weekday [append html rejoin [{<TD bgcolor="#} notthismonthcol {"></TD>}]]

append html {</TR></TABLE></HTML>}

write outfilename html
browse outfilename
