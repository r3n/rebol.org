REBOL [
	Title: "Extract URLs"
	File: %extract-urls.r
	Version: 1.0.0
	Home: http://www.ross-gill.com/
	Date: 29-Nov-2009
	Purpose: "To identify and extract URIs from plain text"
	Author: "Christopher Ross-Gill"

	Library: [
		level: 'intermediate
		platform: 'all
		type: [function module]
		domain: [markup parse text text-processing web]
		tested-under: [view 2.7.6.2.4 view 2.100.95.2.5]
		support: none
		license: 'cc-by-sa
		see-also: http://daringfireball.net/2009/11/liberal_regex_for_matching_urls
	]
]

extract-urls: use [out rule word uri space punct chars][
	word: charset [#"_" #"0" - #"9" #"A" - #"Z" #"a" - #"z"] ; per regex
	space: charset "^/^- ()<>"
	punct: charset "!'#$%&`*+,-./:;=?@[/]^^{|}~" ; regex 'punct without ()<>
	chars: complement union space punct

	uri: [
		[some [word | "-"] ":/" opt "/" | "www."]
		some [opt [some punct] some chars opt "/"]
		opt [any punct "(" some word ")"]
	]

	rule: use [emit-link emit-text link text mk ex][
		emit-link: [(append out to-url link)]
		emit-text: [(unless mk = ex [append out copy/part mk ex])]

		[
			mk: any [
				ex: copy link uri emit-text emit-link mk:
				| some [chars | punct] some space ; non-uri words, line not required
				| skip
			]
			ex: emit-text
		]
	]

	func [
		"Separates URLs from plain text"
		txt [string!] "Text to be "
	][
		out: copy []
		if parse/all txt rule [out]
	]
]