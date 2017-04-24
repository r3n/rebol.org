REBOL [
  Title: "UTC now"
  Version: 1.1.0
  Date: 14-Jul-2009
  Author: "Peter W A Wood"
  File: %utc-now.r
  Purpose: {
    Mimics the functions of the built-in now function adjusted to UTC.
  }
  library: [
    level: 'beginner
    platform: 'all
    type: [package tool]
    domain: [cgi utility]
    tested-under: [
      core 2.5.6 Mac OS X
      core 2.6.2 Mac OS X
      core 2.7.5 Mac OS X
    ]
    license: 'mits
  ]
]

utc-now: make function! [
  {Mimics the functions of the built-in now function adjusted to UTC.}
  /year       "Returns the year only."
  /month      "Returns the month only."
  /day        "Returns the day of the month only."
  /time       "Returns the time only."
  /zone       "Returns the time zone offset from GMT only."
  /date       "Returns date only."
  /weekday    "Returns day of the week as integer (Monday is day 1)."
  /yearday    "Returns day of the year (Julian)."
  /precise    "Use nanosecond precision."
  /local
    utc "now converted to utc time zone"
    first-jan "used to calculate the day of the year"
][
  
  utc: either precise [
    now/precise
  ][
    now
  ]
  utc: utc - utc/zone
  utc/zone: 0:00
  
  return case [
    year [utc/year]
    month [utc/month]
    day [utc/day]
    time [utc/time]
    zone [utc/zone]
    date [utc/date]
    weekday [utc/weekday]
    yearday [
      either system/version > 2.6.2 [   ;; no /yearday refinement before then
        utc/yearday
      ][
        first-jan: to date! join "01-01-" utc/year
        utc - first-jan + 1
      ]
    ]
    #[true] [utc]
  ]
  
]