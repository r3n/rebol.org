REBOL [
    Title: "Data Entry Form"
    Date: 20-May-2000
    File: %entry-form.r
    Author: "Carl Sassenrath"
    Purpose: {
        A simple data entry form for an address book.
        Does not verify field data.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

form-styles: stylize [
    txt12: text  with [font: [color: black shadow: none]]
    txt16: txt12 with [font: [size: 16]]
    name:  txt12 with [size: 100x24 font: [align: 'right]]
    namv:  txt12 with [size: none]
    inp:   field with [size: 240x24]
]

address-form: layout [
    styles form-styles
    backdrop 200.190.170
    txt16 bold "Address Book Entry"
    box  460x4 168.168.168 across
    name "First Name:"     fn: inp 80x24
    namv "Last Name:"      ln: inp 165x24 return
    name "Street Address:" sa: inp 330x24 return
    name "City:"           ci: inp 100x24
    namv "State:"          st: inp 60x24
    namv "Zip:"           zip: inp 79x24  return
    box  460x4 168.168.168 return
    name "Home Phone:"     hp: inp return
    name "Work Phone:"     wp: inp return
    name "Email Address:"  ea: inp return
    name "Web Site:"       ws: inp return
    box  460x4 168.168.168 return
    indent 110
    button "Enter" [save-data]
    button "Cancel" [quit]
]

save-data: does [
    data: reduce [
        fn/text ln/text sa/text ci/text st/text zip/text
        hp/text wp/text ea/text ws/text
    ]
    print data
]

view address-form

