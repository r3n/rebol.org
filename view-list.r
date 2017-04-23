REBOL [
    Title: "View A List of Data"
    Date: 1-Jun-2000
    File: %view-list.r
    Purpose: {Example of how to display a simple
     block of data as fixed width columns in a window.
      Code is just one line.}
    library: [
        level: 'beginner
        platform: none
        type: [Demo one-liner]
        domain: 'GUI
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

names: [["John" 100] ["Joe" 200] ["Martin" 300]]

view layout [
	list blue 320x200 [across text white 200 text white 100] data names]

