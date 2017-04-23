REBOL [
   Title: "Skype Wrapper"
   Author: "Graham Chiu"
   Company: "SynapseDirect.com"
   Date: 23-May-2006
   File: %skype.r
   Purpose: "make a cheap phone call!"
   Library: [
        level: 'intermediate 
        platform: 'windows 
        type: [demo module]
        domain: [external-library ]
        tested-under: 1.3.2.3.1
        license: 'MIT
        support: none
        see-also: none
	needs: {
                Rebol/Pro or /Command

                Benjamin's comlib.r
		http://www.geocities.com/benjaminmaggi/doc/comlib.html
                http://www.geocities.com/benjaminmaggi/data/
		
		Skype Com documentation is here
		https://developer.skype.com/Docs/Skype4COM
	}

      ]
]

do %comlib.r

initDipsHelper 1

; Create a Skype4COM object
oSkype: createObject "Skype4COM.Skype"
; Start the Skype client
if zero? getNumber oSkype "Client.IsRunning" make string! copy "" [
	objectMethod oSkype "Client.Start()"
]

; Declare the following Skype constants
cUserStatus_Offline: getNumber oSkype ".Convert.TextToUserStatus(%s)" "Offline"
cUserStatus_Online: getNumber oSkype ".Convert.TextToUserStatus(%s)" "ONLINE"
cCallStatus_Ringing: getNumber oSkype ".Convert.TextToCallStatus(%s)" "RINGING"
cCallStatus_Inprogress: getNumber oSkype ".Convert.TextToCallStatus(%s)" "INPROGRESS"
cCallStatus_Failed: getNumber oSkype ".Convert.TextToCallStatus(%s)" "FAILED"
cCallStatus_Refused: getNumber oSkype ".Convert.TextToCallStatus(%s)" "REFUSED"
cCallStatus_Cancelled: getNumber oSkype ".Convert.TextToCallStatus(%s)" "CANCELLED"
cCallStatus_Finished: getNumber oSkype ".Convert.TextToCallStatus(%s)" "FINISHED" 
cCallStatus_Busy: getNumber oSkype ".Convert.TextToCallStatus(%s)" "BUSY"
cAttachmentStatus_Available: getNumber oSkype ".Convert.TextToAttachmentStatus(%s)" "AVAILABLE"

; The PlaceCall command will fail if the user is offline. To avoid failure, check user status and change to online if necessary

If cUserStatus_Offline = getNumber oSkype "CurrentUserStatus" make string! copy "" [
	ObjectMethod oSkype "ChangeUserStatus(%d)" cUserStatus_Online 
]

; Create a user object:
oUser: retrieveObject oSkype ".User(%s)" "echo123" ; << user you want to call!

Handle: getText oUser ".Handle" ""

; dial away
oCall: retrieveObject oSkype ".PlaceCall(%s)" Handle


