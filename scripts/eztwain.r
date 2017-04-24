REBOL [
   Title: "Eztwain Support"
   Author: "Graham Chiu"
   Company: "SynapseDirect.com"
   Date: 6-May-2006
   File: %eztwain.r
   Purpose: "Support image grabs from webcam using commercial eztwain library."
   Library: [
        level: 'intermediate 
        platform: 'windows 
        type: [demo module]
        domain: [animation external-library graphics]
        tested-under: [view/pro 1.3.2.3.1 http://www.dosadi.com/pub/eztw1.zip %eztwain3.dll]
        license: 'MIT
        support: none
        see-also: none
      ]
]

twainlib: load/library %eztwain3.dll

TWAIN_SetAutoScan: make routine! [
    "Use the default twain source"
    flag [integer!]
    return: [integer!]
] twainlib "TWAIN_SetAutoScan"

TWAIN_OpenDefaultSource: make routine! [
    "opens the default twain source"
    return: [integer!]
] twainlib "TWAIN_OpenDefaultSource"

twain_logfile: make routine! [
	"Set the log file on or off"
	flag [integer!]
] twainlib "TWAIN_LogFile"

twain_sethideui: make routine! [
	"Hide the UI"
	flag [integer!]
] twainlib "TWAIN_SetHideUI"

TWAIN_SetFileAppendFlag: make routine! [
	"what's this for?"
	flag [integer!]
] twainlib "TWAIN_SetFileAppendFlag"

TWAIN_SetJpegQuality: make routine! [
	"Set Jpeg quality"
	flag [integer!]
] twainlib "TWAIN_SetJpegQuality"

TWAIN_OpenSource: make routine! [
	"Set twain source"
	name [string!]
	return: [integer!]
] twainlib "TWAIN_OpenSource"	

TWAIN_SetXferCount: make routine! [
	"Set the number of images to get"
	flag [integer!]
] twainlib "TWAIN_SetXferCount"

TWAIN_AcquireToFilename: make routine! [
	"Get image to file"
	handle [integer!]
	file [string!]
] twainlib "TWAIN_AcquireToFilename"

TWAIN_LastErrorCode: make routine! [
	"Get the last error code"
	return: [integer!]
] twainlib "TWAIN_LastErrorCode"

TWAIN_ReportLastError: make routine! [
	"make a log entry"
	entry [string!]
] twainlib "TWAIN_ReportLastError"

TWAIN_SelectImageSource: make routine! [
	"Get the default twain source"
	flag [integer!]
] twainlib "TWAIN_SelectImageSource"

halt

; demo follows

	scanlo: layout [ scannedimage: box 200x200 ]

    Twain_logfile 1
    TWAIN_SetHideUI 1
    TWAIN_SetFileAppendFlag 0
    TWAIN_SetJpegQuality 75
    if 0 <> TWAIN_OpenDefaultSource [
	    TWAIN_SetXferCount 1
        if 0 = TWAIN_SetAutoScan 0 [
            alert "Twain source can not single scan"
            return
        ]
	    TWAIN_AcquireToFilename 0 "c:\image.jpg"
    ]
    if TWAIN_LastErrorCode <> 0 [
	    TWAIN_ReportLastError "Unable to scan"
    ]
    scannedimage/image: load %/c/image.jpg
    
    view scanlo

