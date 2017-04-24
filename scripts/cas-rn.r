REBOL [
	name: 'CAS-RN
	title: "CAS Registry Number"
	file: %cas-rn.r
	home: none
	date: 2005-10-25
	version: 1.0.1
	home: none
	author: "Daniel Rybowski"
	email: HJWRKOJWLMJJ@spammotel.com ; Yes, this is a real email address!
	purpose: {The CAS Registry (http://www.cas.org/EO/regsys.html) is a widely
		used database of chemical substances. The CAS Registry Numbers are a "de
		facto" standard for the identification of chemical substances.

		This module contains helper functions to handle CAS Registry Numbers.}
	history: [
		"Daniel Rybowski" 1.0.1 2005-10-25 "Parse in func split uses a charset."
		"Daniel Rybowski" 1.0.0 2005-10-22 "Initial release."
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: [module function tool]
		domain: 'scientific
        tested-under: "View 1.3.1.3.1 on Windows XP"
        support: none
        license: 'cc-by-sa
        see-also: none
	]
]
cas-rn: context [
	exists?: func [
		{Returns TRUE if a CAS Registry Number is valid and has been allocated
		by the CAS.}
		cas-rn [issue!] "The CAS RN to verify."
		/local last-cas-rn cas-rn-1 last-cas-rn-1
	][
		found? all [
			valid? cas-rn
			parse read http://www.cas.org/cgi-bin/regreport.pl [
				thru "CAS RN"
				thru <B>
				copy last-cas-rn to </B>
				to end
			]
			cas-rn: split cas-rn
			last-cas-rn: split last-cas-rn
			cas-rn-1: to-integer first cas-rn
			last-cas-rn-1: to-integer first last-cas-rn
			any [
				cas-rn-1 < last-cas-rn-1
				all [
					cas-rn-1 = last-cas-rn-1
					lesser-or-equal?
						to-integer second cas-rn
						to-integer second last-cas-rn
				]
			]
		]
	]
	valid?: func [
		{Returns TRUE if a CAS Registry Number is valid. This does not
		necessarily mean that this Registry Number has been allocated by the
		CAS.}
		cas-rn [issue!] "The CAS RN to validate."
	][
		found? all [
			cas-rn: split cas-rn
			; For my purpose, leading zeroes must be disallowed in a CAS RN.
			; Comment out the following line to allow them.
			#"0" <> first first cas-rn
			; The first allocated CAS RN is #50-00-0.
			50 <= to-integer first cas-rn
			equal?
				compute-check-digit first cas-rn second cas-rn
				to-integer third cas-rn
		]
	]
	compute-check-digit: func [
		{Returns the check digit corresponding to a CAS Registry Number. Applies
		the algorithm specified at http://www.cas.org/EO/checkdig.html.}
		rn-1 [string!] "The first group of 2 to 6 digits of a CAS RN."
		rn-2 [string!] "The second group of 2 digits of a CAS RN."
		/local total
	][
		total: local: 0
		foreach digit reverse join rn-1 rn-2 [
			local: local + 1
			total: total + multiply local to-integer to-string digit
		]
		total // 10
	]
	split: func [
		{Splits a CAS Registry Number into its 3 groups of digits. Returns a
		block of 3 strings, or NONE if the CAS RN is malformed.}
		cas-rn [issue! string!] "The CAS RN to split."
		/local digits part-1 part-2 part-3
	][
		digits: charset "0123456789"
		if parse cas-rn [
			copy part-1 2 6 digits
			"-"
			copy part-2 2 digits
			"-"
			copy part-3 digits
			end
		][
			reduce [part-1 part-2 part-3]
		]
	]
]
comment [
    ; Usage examples
    cas-rn/exists? #107-07-3 ; == true

    cas-rn/valid? #0107-07-3 ; == false

    cas-rn/compute-check-digit "999999" "99" ; == 4
    cas-rn/valid? #999999-99-4 ; == true
    cas-rn/exists? #999999-99-4 ; == false

    cas-rn/split #123-45-6 ; == ["123" "45" "6"]
    cas-rn/split "123-45-6" ; == ["123" "45" "6"]
]
