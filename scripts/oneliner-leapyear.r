Rebol [
    Title: "Test if leap year"
    Date: 20-Jul-2003
    File: %oneliner-leapyear.r
    Purpose: {'Leapyear? returns 'true for date values that are leapyears. For example:
>> leapyear? 1/1/2001
== none
>> leapyear? 1/1/2000
== true}
    One-liner-length: 132
    Version: 1.0.0
    Author: "Andrew Martin"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner function]
        domain: [math]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
Leapyear?: function[Date[date!]][Year][Year: Date/year any[all[0 = remainder Year 4 0 <> remainder Year 100]0 = remainder Year 400]]
