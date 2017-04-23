REBOL [
	Title: "RRD"
	Date: 20-Jul-2008
	Name: 'RRD
	Version: 1.0.0
	File: %rrd.r
	Author: "Roger McIlmoyle"
	Purpose: { Create, Manager, and Use simplified RRD DB }
	Usage: { Internal list of functions:
		make-rrd-array : create series that holds intervals and data
		update-rrd: update / insert values into an rrd db
		get-rrd-value: retrieve values from the rrd db for an interval
		dump-rrd: debugging function to display the data in the rrd db
	}
	History: {
		1.0.0 first version, lots to add built for an instrumentation package I'm working on that can be deployed to test links for connectivity, capacity, and jitter
	}
]
row: make object! [
	cnt: make integer! 0
	max: make decimal! 0.0
	min: make decimal! 0.0
	avg: make decimal! 0.0
	last: make decimal! 0.0
]

make-rrd-array: func [ 
	"Build a simple rrd table with a specified number of table entries each with a specific interval in seconds. The rrd table never grows in size. As entries are updated it rolls forward to always retain the same overall interval size"
	start [date!] "Start date/time of data"
	steps [integer!] "how many nodes" 
	resolution [integer!] "how many seconds represents the interval per node" 
][
	rrd: []
	node: start
	loop steps [
		append rrd node ; Date Index
		append rrd make row [] ; object containing values
		node/time: node/time + resolution 
	] 
	head rrd
]

in-interval: func [
	"Test to see if the time is within the interval"
	node1 [date!] "Interval start time"
	node2 [date!] "date / time to test"
	interval [integer!] "Size of interval in seconds"
][
	node3: node1
	node3/time: node3/time + interval
	either all [ node1 < node2 node3 > node2 ] [ true ][ false ]
]

get-rrd-range: func [
	"Return a series that has two values starting and ending "
	rrd [series!] "RRD DB to use"
	/last "Last actual node rather than the implied end"
][
	start: first head rrd
	end: first skip rrd length? rrd -2
	either last [ [ start end ] ][
		;Determine the interval
		start2: second head rrd
		interval: to-integer start2/time - start/time
		end/time: end/time + interval - 1
		[ start end ]
	]
]

get-rrd-value: func [
	"Return a specified value from the RRD"
	data-time [date!] "Desired time"
	rrd [series!] "RRD Series to use"
	/max "Return Maximum"
	/min "Return Minimum"
	/avg "Return Average"
	/last "Return Last"
	/cnt "Return Coung"
][
	value: 0	
	rrd: head rrd
	interval1: first rrd
	interval2: third rrd
	interval: to-integer interval2/time - interval1/time
	while [ all [ data-time >= interval1 not tail? rrd] ][
		node: first rrd
		data: second rrd
		if in-interval node data-time interval [
			either any [ max min avg cnt ][
				if max [ value: data/max ]
				if min [ value: data/min ]
				if avg [ value: data/avg ]
				if cnt [ value: data/cnt ]
			][
				value: data/last
			]
			break
		]
		rrd: skip rrd 2
	]
	value 
]

dump-rrd: func [
	"Display supplied RRD DB"
	rrd [series!] ;"RRD DB to display"
	][
		foreach node rrd [
			either date? node [ node-date: node ][
				print [ node-date node/cnt node/min node/max node/avg node/last ]
			]
		]
]

update-rrd: func [
	"Insert/Update a statistic within the RRD"
	data-time [date!] "Exact time value was collected"
	value [decimal!] "Value collect"
	rrd [series!] "RRD Series"
][
	return: False
	rrd: head rrd
	trim: 0
	node: first rrd
	nextnode: third rrd
	interval: to-integer nextnode/time - node/time
	while [ all [ data-time >= node not tail? rrd] ][
		node: first rrd
		if in-interval node data-time interval [
			;Within this interval
			rrd-data: second rrd
			rrd-data/cnt: rrd-data/cnt + 1
			rrd-data/last: value
			either lesser-or-equal? rrd-data/cnt 1 [
				rrd-data/max: value
				rrd-data/min: value
				rrd-data/avg: value
			][
				if greater? value rrd-data/max [ rrd-data/max: value ]
				if greater? rrd-data/min value [ rrd-data/min: value ]
				rrd-data/avg: rrd-data/avg + (( value - rrd-data/avg ) / rrd-data/cnt)
			]
			return: True
			break
		]
		if tail? skip rrd 2 [
			next-interval: first rrd
			next-interval/time: next-interval/time + interval
			append rrd next-interval
			append rrd make row [cnt: 0 min: 0 max: 0 last: 0 avg: 0]
			next-interval/time: next-interval/time + interval
			append rrd next-interval
			append rrd make row [cnt: 0 min: 0 max: 0 last: 0 avg: 0]
			trim: trim + 1
		]
		rrd: skip rrd 2
	]
	rrd: head rrd
	if trim > 0 [ remove/part rrd ( trim * 2 ) ]
	return
]


