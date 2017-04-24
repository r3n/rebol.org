REBOL [
    Title: "National Geographic Image of the Day Downloader"
    Date: 11-Sept-2007
    Version: 1.2.5
    File: %ngbg2.r
    Author: "Gordon Raboud"
    History: [
		Date: 21-Sep-2001 
		Version: 1.0.0 
		Author: "Ian Monroe"
		Email: ul303seyj001@sneakemail.com
		Web: http://mlug.missouri.edu/~eean/projects.php

		Date: 17-Jan-2004
		Version: 1.1.1
		Author: "Charles Mougel"
		Email: charles.mougel@spinodo.com
		Web: http://www.spinodo.com
		Purpose: "Url updated"
    ]
    
    Library: [
       level: 'intermediate 
       platform: 'all
       type: [tool demo]
       domain: [markup text-processing web] 
       tested-under: 'W2K
       support: none
       License: none
    ]

    Purpose: { Downloads all the "Picture Of The Day" images (current and past)
	from the National Geographic website and saves it to a location of your choice.
	Revisions: 
	Version 1.2.5 Checked to see if the large wallpaper exists and if not to use the smaller
		wall paper image.		
	Version 1.2.4 Changed from "Viewing" the POTD to "Browsing" the POTD which then
		allows the user to go back to see other pictures that may have been missed.
	Version 1.2.3 Added displays for current file name download. Added slider to set
		the number of downloads for this run.
	Version 1.2.2 Added a stop (abort) button.
	Version 1.2.1 I didn't like the silent operation so I added a progress meter.
	Version 1.2.0 Modified to download all past POD (pictures of the day) images starting
	from 2001-04-21 to current date. Also modified to store each POD with a unique
	filename and also download the description of the picture and save it as an HTML file
	with links to Next and Previous pictures. Updated the help files and their display
	using the Request/OK function instead of the dump to console.  Added a directory
	requester for storing of files so users don't have to modify the code.  Added a 
	preferences file for storing this information as well as the maximum number of
	pictures per day to download.

	This version still uses the original NG website as it still works okay.  I have
	been able to download all images from 2001-04-21 to today, 2006-06-09.
	It will only download images which exist on the server but don't exist on your
	local drive in the path specified.  I put a 100 at a time limiter on the program
	because it seems that National Geographic has processes in place to limit
	the number of downloads or connections (possibly Denial Of Service attack
	blockers), because it seemed to hang when trying to download all of them at once.
	I tried again a few hours later and was able to download another 100.
	
	Like the version 1.0.0 it will download the large backdrop but it now gets the
	description from the original photo of the day page.
	
	It will display the current picture of the day and wait for the window to close
	before downloading the rest of the images.
	
	Version 1.1.0 by Charles Mougel: Used a different URL
	
	Version 1.0.0 by Ian Munroe: Downloads a single picture of the day - must be run 
	everyday.

	The argument "-p" causes a "print to console".
	These directions can be seen by adding a "-h" agrument.}
    
]

HelpString1: {This program downloads all the current picture of the days from 
	NationalGeographic.com and saves them to a location of your choice.
	You can run this program at any time because it will only download
	images which exist on the server but don't already exist on your local
	drive in the path specified.  Therefore, there are no worries about
	downloading the same picture twice and wasting time and bandwidth.  It
	will download the backdrop from the large wallpaper page, but gets the
	description for the HTML page that is created for each picture from
	the original photo of the day page.  ... Continue?}

HelpString2: {This program will display the current picture of the day, (if not already
	downloaded), while downloading the rest of the images.  The program will
	download about 100 images and this can be changed by using the slider or adjusting
	the second field in the NationalGeographicDownloadPrefs.txt file.  If it has
	difficulty connecting or downloading the program will just stop.  If this happens
	try the program again at a different time of day as the NatGeo site may be too
	busy. ... Continue?}

PrefsHelpString1: {The first time this is run it will prompt you for a location to store
	the images and html files.  It saves this in a prefs file so it won't
	ask you again. ... Continue?}

PrefsHelpString2: {The directory requester that comes up may not be familar to most
	users but is easy to learn.  Use the orange up arrow near the top right to
	move up a directory level and click on a directory name to display that directory's
	contents.  Once you are at the directory that you want to save the images and
	html files (today and other days) click the "Open". ...Continue?}

PrefsHelpString3: {A "Rebol - Security Check" window may open where you confirm that you
	want to browse your computer to find the directory to store the images.  Because
	you know that you have run this program (and not some unauthorized user) select
	"Allow all". ... Continue?}

ISO8601Date: func [Date [Date!]] [
   to-string join Date/year
   ["-" copy/part tail join "0" [Date/month] -2 "-" copy/part tail join "0" [Date/day] -2 ]
]


DateCntrStart: now/date
DateCntrEnd: to-date 2001-04-21
TotalImages: now/date - 2001/04/21
DownloadCntr: 0
DailyMax: 50  ; to limit downloads and avoid being blacklisted.

PreferencesFileName: "NationalGeographicDownloadPrefs.txt"
CurrentDir: What-dir
PrefsFullName: to-file join CurrentDir PreferencesFileName
BackdropPic: load-thru/binary http://raboud.ca/images/2001-05-14_NatGeo_POD_380x380.jpg

;  Get save directory from prefs file if prefs file exits
;  If prefs file does not exist or is empty, use requester to get save
;  directroy and write this information to the prefs file for next time.
Either exists? PrefsFullName [	
    Success: open PrefsFullName
	Preferences: read/lines PrefsFullName
	Either (length? Preferences) > 0 [
		FileNamePath: to-file first Preferences
		DailyMax: to-integer second Preferences
	] [
		FileNamePath: request-dir/title/keep
		"Select Directory/Folder to save Images and HTML pages"
		Either none? FileNamePath [
			quit
		] [
			; update the prefes file with directory location
			; and with the daily max limit
			write PrefsFullName reduce [FileNamePath newline DailyMax]
		]
	]
][
	Continue: Request HelpString1
	If not Continue [quit]
	Continue: Request HelpString2
	If not Continue [quit]
	Continue: Request PrefsHelpString1
	If not Continue [quit]
	Continue: Request PrefsHelpString2
	If not Continue [quit]
	Continue: Request PrefsHelpString3
	If not Continue [quit]
	open/new PrefsFullName
	FileNamePath: request-dir/title/keep
	"Select Directory/Folder to save Images and HTML pages"
	Either none? FileNamePath [
		quit
	] [
		; update the prefes file with directory location
		; and with the daily max limit
		write PrefsFullName reduce [FileNamePath Newline DailyMax]
	]
]

PrintStuff: false
; PrintStuff: True

if system/script/args = "-p"
[ PrintStuff: True ]

if system/script/args = "-h" [
	Continue: Request HelpString1
	If not Continue [quit]
	Continue: Request HelpString2
	If not Continue [quit]
]

if PrintStuff
[ print "Downloading National Geographic wallpaper.cgi web page..." ]

; Date format is ?month=mm&day=dd&year=yy (in any order of mm or dd or yy)

ProgressView: view Layout [	
	Size 380x380
	backdrop BackdropPic effect [blur]	
	Text at 20x10 vh2 Blue "Downloading National Geograhic Images"
	Text white {Change The Number of Downloads For This Run
		(Edit the "Prefs" file is you want more than 100 ...
		and then don't move the Slider)}
	indent 20
	DailyMaxSlider: Info with [size: 300x20 font/color: white font/size: 14]
	slider 300x20 with [data: (DailyMax / 100)] [
		DailyMax: to-integer value * 100
		DailyMaxSlider/text: DailyMax
		show DailyMaxSlider
		PrefsFullName: head PrefsFullName
		write PrefsFullName reduce [FileNamePath newline DailyMax]
	]
	DailyMaxSlider/text: DailyMax
	Indent -20
	Text white "Percentage Of All Available Files Downloaded"
	Indent 20
	AllFilesProgress: Progress 300x20
	DateCntrInfo: Info with [size: 300x20 font/color: 255.255.0 font/size: 14]
	Indent -20
	Text "Percentage of Completed Downloads For This Run"
	Indent 20
	DailyMaxProgress: Progress 300x20
	DLNameInfo: Info with [size: 300x20 font/color: 255.255.0 font/size: 14]
	across pad 100x10
	button 60x24 "Start" [
		For DateCntr DateCntrStart DateCntrEnd -1 [	
			DateCntrInfo/text: DateCntr
			Show DateCntrInfo
			Either DownloadCntr < DailyMax [
				wait .2 ; To give the system time for the "Stop" button to work
				; Start from most current date and work backwards to oldest date
				PODMonth: join "0" [trim to-string DateCntr/month]
				PODMonth: copy/part tail PODMonth -2
				PODDay: join "0" [trim to-string DateCntr/day]
				PODDay: copy/part tail PODDay -2
				PODYear: copy/part tail to-string DateCntr/year -2
				PODDateStr: join "?year=" [PODYear "&month=" PODMonth "&day=" PODDay]

				ngwebsite: join http://lava.nationalgeographic.com/cgi-bin/pod/enlarge.cgi [PODDateStr]
				PODDate: join "20" [PODYear "-" PODMonth "-" PODDay]
				Filename1: join FilenamePath [PODDate "_NatGeo_POD.jpg"]
				Filename2: join FilenamePath [PODDate "_NatGeo_POD_Desc.html"]
				PreviousDate: ISO8601Date DateCntr - 1
				PreviousFile: join to-string PreviousDate ["_NatGeo_POD_Desc.html"]
				CurrentFile: join PODDate ["_NatGeo_POD.jpg"]
				NextDate: ISO8601Date DateCntr + 1
				NextFile: join to-string NextDate ["_NatGeo_POD_Desc.html"]
				If not exists? Filename1 [
					If exists? ngwebsite [
						NGPage: read ngwebsite 
						if PrintStuff [
							prin join " parsing NGPage " PODDate
						]
		
						; Parse filename
						parse NGPage [thru "/pod/pictures/sm_wallpaper/" copy NameOfJpg to "^""]
						NameOfJpg: trim NameOfJpg
						If PrintStuff [
						   print join " - image name = " NameOfJpg
						]
						DLNameInfo/text: NameOfJpg
						show DLNameInfo
						imageloc: join http://lava.nationalgeographic.com/pod/pictures/lg_wallpaper/ NameOfJpg
						if not exists? imageloc [
							Comment: "Use small wall paper is large doesn't exist."
							imageloc: join http://lava.nationalgeographic.com/pod/pictures/sm_wallpaper/ NameOfJpg
						]
						; Parse Caption
						parse NGPage [thru "START caption and related" thru "place-photographer" thru "^">"
						   copy PODPlace to "<" thru "place-photographer-sub" thru "^">"
						   copy PODPhotographer to "<" thru "pod-caption" thru "^">"
						   copy PODCaption to "</div>"
						]
						HTMLStr: join "" [
							"<!DOCTYPE HTML PUBLIC ^"-//W3C//DTD HTML 4.01 Transitional//EN^">" newline
							"<html>" newline
							"<head></head>" newline
							"<body>" newline
							"<table style=^"width: 100%; text-align: left; margin-left: auto; margin-right: auto;^""
								newline "border=^"0^" cellpadding=^"2^" cellspacing=^"2^">" newline
							"<tbody>" newline
							"<tr>" newline
							"	  <td colspan=^"3^" rowspan=^"1^"><img style=^"width: 1024px; height: 768px;^"" newline
							"	  alt=^"" PODPlace "^"" newline
							"	  src=^"" CurrentFile "^"></td>" newline
							"</tr>" newline
							"<tr>"
							"   <td style=^"text-align: center;^">" newline
							"	  <a href=^"" PreviousFile "^">Previous</a></td>" newline
							"	  <td style=^"width: 80%;^"><br>" newline
							"<Center><h2>" PODPlace "</h2><br>" newline
								PODPhotographer "</center><br>" newline PODCaption
							"	  </td>" newline
							"	  <td style=^"text-align: center;^">" newline
							"	  <a href=^"" NextFile "^">Next</a></td>" newline
							"</tr>" newline
							"</tbody>" newline
							"</table>"
							"</body>" newline
							"</html>"
						]

						; Download and save Image
						If exists? imageloc [
						   if PrintStuff [ 
							  print ["Downloading " imageloc " ..."]
						   ]
						   image: read/binary imageloc
						   write/binary filename1 image
						   DownloadCntr: DownloadCntr + 1
						   if PrintStuff [
							  print [filename1 " saved"]
						   ]

						   ; Save description
						   write filename2 HTMLStr

						   If DateCntr = DateCntrStart [
							  browse filename2
						   ]
						]
					]
				]
				DailyMaxProgress/data: DownloadCntr / DailyMax
				Show DailyMaxProgress
			][
				wait 3
				quit
			]
			AllFilesProgress/data: 1 - ((DateCntr - DateCntrEnd) / TotalImages)
			Show AllFilesProgress
		]
		wait 3
		quit
	]
	button 60x24 "Stop" [quit]
]
If PrintStuff [halt]
