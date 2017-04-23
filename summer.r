REBOL [
    Title: "Daylight Saving Time function based on North American rules"
    Date: 30-Mar-2004
    Author: "Bohdan Lechnowsky"
    File: %summer.r
    Purpose: {
        Calculates whether a given date is in Daylight Saving Time or not, based on North American rules.  Rules vary by country.
    }
  Library: [
     level: 'intermediate
     platform: 'all
     type: [function]
     domain: [scientific]
     tested-under: none
     support: none
     license: none
     see-also: none
   ]
]

summer?: func [
	{Figures out Daylight Saving Time based on North American rules}
	d [date!] {Date to check}
	t [time!] {Time to check - DST occurs at 2AM}
	/local start end
][
	start: to-date reduce [1 4 d/year]
	start: start + 7 - start/weekday
	end: to-date reduce [25 10 d/year]
	end: end + 7 - end/weekday
	found? any [
		all [
			d > start
			d < end
		]
		all [
			d = start
			t > 1:59:59
		]
		all [
			d = end
			t < 2:00:00
		]
	]
]
