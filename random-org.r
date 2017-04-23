REBOL[
    File: %random-org.r
    Date: 17-6-2008
    Title: "Random.org"
    Purpose: "Get really random numbers (come from atmospheric noise) from http://random.org"
    Library: [
        level: 'beginner
        platform: 'all
        type: [function tutorial tool]
        domain: [http parse scientific shell]
        tested-under: [View 1.3.2.3.1 on XP]
        support: none
        license: 'pd
        see-also: none
    ]
]

random-org: func [
	"Get block of random numbers from http://random.org"
	/size 	"Size of block (default = 100)"
		siz
	/interval	"Number interval (default = 1 - 100)"
		min max
	/base	"Numerical base - 2, 8, 10, 16 (default = 10)"
		base-num
][
	if not size [siz: 100]
	if not interval [min: 1 max: 100]
	if not base [base-num: 10]
	load read rejoin [http://random.org/integers/?num= siz "&min=" min "&max=" max "&col=1&base=" base-num "&format=plain&rnd=new"]
]