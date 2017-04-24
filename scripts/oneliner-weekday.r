Rebol [
    Title: "Day of week"
    Date: 20-Jul-2003
    File: %oneliner-weekday.r
    Purpose: {Returns the weekday of the date. Use 'Weekday? like:
Weekday? 25/Dec/2002
; == "Wednesday"}
    One-liner-length: 65
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
Weekday?: func[Date[date!]][pick system/locale/days Date/weekday]
