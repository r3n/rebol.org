rebol [
	file: %myskype.r
        title: {myskype.r}
	date: 20-aug-2010
	purpose: {Controls the audio settings on my skype client.}
	usage: {***This Will NOT most likely work out of the box!***
		You'll have to change the strings for each setting to what your Skype client knows or you will get an error when you click a button.
		To do this, select tools/options and then Audio Settings. The Microphone and Speakers will have a drop down list. Use these as your strings.
		Then change the values of the strings:
			putvalue [oSettings ".AudioOut = %s"  "Realtek HD Audio output"] 
			becomes
			putvalue [oSettings ".AudioOut = %s"  "Sony superduper audio output"] 
		Do this for all the values you need to set.
		
		
	}
	comments: {
		Requires Anton's comlib.r - I am using 1.1.9
		Also requires the Skype4com.dll (tested with 1.0.33) to be registered on your system. Download from Skype Dev section if you needed.
		And of course Skype Client (I used Version 5.50.124)
		Note: I have had weird behaviour with Skype4com.dll 1.0.36 - At times it seems to work then sometimes you can't create the oSettings object.
		Thanks to Anton and Graham for doing the hard part. See Graham's Skype.r script for more.
	}
	library: [ 
		level: 'Intermediate
		platform: [win]
		type: [tool] 
		domain: [external-library win-api] 
		tested-under: [view 2.7.8.3.1 on WXP] 
		support: none 
		license: 'BSD 
		see-also: none 
	]	
	
]

do/args %comlib.r [

	main: layout [
		backdrop effect [gradient 1x1 198.223.255 140.190.255]
		across
		title "MySkype"
		return
		myinfo: info ""
		return
		btn "Speakers" [audio/speakers]
		btn "Plantronics" [audio/headset]
		btn "Headphones" [audio/headphones]
		return
		btn "Quit" [unview cleanup quit]
	]
	
	cleanup: does [
	
		release oSkype
		release oSettings
	
	]
	
	audio: func [ /speakers /headset /headphones /local ][
		
		myinfo/text: getString [oSettings ".AudioOut"  ]
		show myinfo
		
		if speakers [
			putvalue [oSettings ".AudioOut = %s"  "Realtek HD Audio output"]
			audio
		]
	
	
	
		if headset [
			putvalue [oSettings ".AudioOut = %s"  "Plantronics Calisto Pro Series"]
			putvalue [oSettings ".AudioIn = %s"  "Plantronics Calisto Pro Series"]
			audio
		]
		if headphones [
			putvalue [oSettings ".AudioOut = %s"  "Logitech USB Headset"]
			putvalue [oSettings ".AudioIn = %s"  "Logitech USB Headset"]
			audio
		]	
	
	]
	oSkype: CreateObject "Skype4COM.skype"
	oSettings: getobject [oSkype ".Settings^(00)" ""]	
	;test here - uncomment
	;probe mold oskype
	;probe mold oSettings
	;probe getString [oSettings ".AudioOut"  ]

	
	audio ;call once just to set the view "myinfo" info field
	view main

]

