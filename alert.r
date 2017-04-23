REBOL [
    Title: "a simple alert example"
    Date: 28-Aug-2001
    Version: 1.0.0
    File: %alert.r
    Author: "Viktor Pavlu"
    Purpose: "introduces alert to the beginner"
    Email: viktor_pavlu@hotmail.com
    Note: {
    alert [ 'string 'true 'false 'none ]
     -- pops up a message box with up to three buttons
  }
    library: [
        level: 'beginner 
        platform: none 
        type: 'How-to 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

button: alert [ system/script/header/note 'true 'false 'none ]

either button [
  alert "clicked true"
][
  either button = false [
    alert "clicked false"
  ][
    alert "clicked none"
  ]
]                         