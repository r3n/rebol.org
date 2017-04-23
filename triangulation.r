REBOL [
	Title: "Triangulation Example"
	Date:	12-May-2005
	File: %triangulation.r
	Author: "Bohdan Lechnowsky"
	Email: LTC@sonic.net
	Purpose: {To demonstrate how to calculate the location of a robot based on response times from three known beacons in a right triangle configuration}

	Library: [
		level: 'intermediate
		platform: 'all
		type: [demo how-to tutorial]
		domain: [gui math scientific]
		tested-under: none
		support: none
		license: 'pd
		see-also: none
	]
]

triangulate: func [
	{Finds unique point based on ping response times from three beacons
		Beacon #1 is at the origin on the coordinate plane
		Beacon #2 is on the x-axis d units from Beacon #1
		Beacon #3 is on the y-axis d units from Beacon #1
	Beacons #2 and #3 should be at right angles to each other

	Technically, Beacons #2 and #3 do not need to be equidistant from Beacon #1, but this function assumes they are}
	d "Distance in units between beacon baselines"
	r1 "Distance from beacon #1 (measured by ping response delay)"
	r2 "Distance from beacon #2"
	r3 "Distance from beacon #3"
	/local
	x "x-axis location"
	y "y-axis location"
][
	y: (1 / d) * square-root((0 - d + r1 - r2) * (0 - d - r1 + r2) * (0 - d + r1 + r2) * (d + r1 + r2))
	x: (1 / d) * square-root((0 - d + r1 - r3) * (0 - d - r1 + r3) * (0 - d + r1 + r3) * (d + r1 + r3))

	comment {
		The physical coordinates are actually half of the calculated values above
		"reduce" evaluates the items in the block "[ ]" and this value is the return value of this function
	}
	reduce [x / 2 y / 2]
]

ping-response: func [
	{Simulates ping response times that would be received in a real-world application
	The real-world application would need to convert the response times to the same units used to measure the distances between the beacons}
	beacon-object "The beacon object from the graphical layout"
	robot-coord "x-y coordinate pair of robot's physical location"
	beacon-coord "x-y coordinate pair of beacon's physical location"
	/local answer starttm
][
	beacon-object/color: red
	lay/effect: compose/deep [draw [pen black line (beacon-object/offset) (robot/offset)]]
	show lay
	starttm: now/time/precise

	comment {This is Pythagorean's Theorem in action}
	answer: square-root(((robot-coord/x - beacon-coord/x) ** 2) + ((robot-coord/y - beacon-coord/y) ** 2))

	comment {
		Comment out the following line if you want to test the full speed of your computer
		This line simply slows down the computer so you can see the simulated response time from each beacon
	}
	while [now/time/precise < (starttm + .1)][wait .001]

	beacon-object/color: green
	lay/effect: copy []
	show lay

	answer
]

robot-control: func [
	{This function handles the random movements of the robot and outputs the verification data
	Occasionally, slight discrepancies between the calculated position and the actual position may be noticed due to floating point rounding errors}
	f a e
	/local
	d-b1
	d-b2
	d-b3
	tc
][
	comment {Every time a "time" event is generated, perform the following...}
	if a = 'time [
		print ["^/" now/time/precise] ;prints a blank line and the precise time (as a marker)

		comment {Move the robot in the x and y directions (pseudo)randomly}
		robot/offset/x: robot/offset/x + (random 5) - 2.5
		robot/offset/y: robot/offset/y + (random 5) - 2.5

		comment {Update the robot's position on the display}
		show robot

		comment {Calculate the three beacons' simulated response times based on the actual position of the robot}
		d-b1: ping-response b1 robot/offset b1/offset
		d-b2: ping-response b2 robot/offset b2/offset
		d-b3: ping-response b3 robot/offset b3/offset
		print ["Response times from Beacons #1, #2 & #3:" d-b1 d-b2 d-b3]

		comment {
			Calculate the robot's coordinates based off these response times
			"b2/offset/x - b1/offset/x" figures the distance between the beacons so you don’t have to
		}
		tc: triangulate b2/offset/x - b1/offset/x d-b1 d-b2 d-b3
		print [
			"Triangulation coordinates derived from beacon response times:"
			to-pair tc
		]

		print [
			"Actual coordinates:" robot/offset
		]
	]
]

comment {Draw the graphical output area -- this is also the main event loop}
view lay: layout [
	at 0x0 ;place Beacon #1 at the "origin"
	b1: box "1" 20x20 green

	at 400x0 ;place Beacon #2 400 units away from Beacon #1 on the x-axis
	b2: box "2" 20x20 green

	at 0x400 ;place Beacon #3 400 units away from Beacon #1 on the y-axis
	b3: box "3" 20x20 green

	at 200x200 ;place the robot equidistant from all three beacons as a starting point
	robot: box "R" 20x20 blue with [
		rate: 0:0:01	;Make the robot move every x hours:minutes:seconds
		comment {
			If you want to see how fast your computer can move the robot
			  and process the location, set this value to 0:0:00 :-)
			Be sure to also comment out the line in the ping-response
			  function above
			If your computer wasn’t updating the graphics, it would
			  additionally be much faster.
		}

		comment {Initialize the robot’s movement function}
		feel: make feel [engage: :robot-control]
	]
]