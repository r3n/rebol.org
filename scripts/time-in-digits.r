REBOL [
    Title: "Date and time in digits"
    Date: 12-Jun-2000
    Name: 'Time-in-Digits
    Version: 1
    File: %time-in-digits.r
    Author: "Ryan C. Christiansen"
    Owner: "Ryan C. Christiansen"
    Rights: "Copyright (C) Ryan C. Christiansen 2000"
    Tabs: 4
    Purpose: {
      Convert the date and time into a string of digits.
   }
    Comment: {
      Use this function to create a string of digits denoting
      the date and time. This is useful, especially with 'now
      to create a reference number as to when a file, object,
      etc., was created. If used with 'now to create a file
      name, the newest file will always appear at the end of
      a directory.
   }
    History: [
    1 [12-Jun-2000 "posted to rebol.com" "Ryan"]
]
    Language: 'English
    Email: norsepower@uswest.net
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

time-in-digits: func [
    "Convert the date and time from 'now' into a string of digits."
    sun-dial [date!] "The current date and time from 'now'"
][
    year: to-string sun-dial/year
    month: to-string sun-dial/month
    if (length? month) < 2 [insert month "0"]
    day: to-string sun-dial/day
    if (length? day) < 2 [insert day "0"]

    current-time: sun-dial/time
    hour: to-string current-time/hour
    if (length? hour) < 2 [insert hour "0"]
    minutes: to-string current-time/minute
    if (length? minutes) < 2 [insert minutes "0"]
    seconds: to-string current-time/second
    if (length? seconds) < 2 [insert seconds "0"]
    
    rejoin [year month day hour minutes seconds]
]