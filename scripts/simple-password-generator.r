REBOL [
    title:"Simple password generator"
    date: 19-09-2014
    file: %simple-password-generator.r
    Purpose: {This program allows you to create passwords
     setting two parametres:
     1) The length
     2) The type (numbers, alphabet ...)
     }
     Author: "Caridorc"
     License: "GNU"
         library: [
        level: 'beginner
        platform: 'all
        type: [tool]
        domain: none
        tested-under: Windows
        support: all
        license: GNU
        see-also: none
    ]


    ]

random/seed now/precise

make-password: func[length chars] [
    password: copy ""
	loop length [append password (pick chars random (length? chars))]
	password
	]

password-stuff: func[length chars] [
    password: make-password length chars
    write clipboard:// password
	alert password
	]
	
view layout [
    text "Just paste: the password is automatically copied to your clipboard"
    field "Length" [length: to-integer value]
	across
	button "Numbers" [chars: "0123456789" password-stuff length chars]
	button "Alphabet" [chars: "qwertyuiopasdfghjklzxcvbnm" password-stuff length chars]
	button "Alphabet and numbers" 180x24 [chars: "1234567890qwertyuiopasdfghjklzxcvbnm" password-stuff length chars]
	button "All characters" [chars: "1234567890qwertyuiopasdfghjklzxcvbnm|!£$%&/()=?^[]@#{}" password-stuff length chars]
	]
