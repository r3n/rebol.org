REBOL [
  date: 17/01/2011
  author: "nicolas"
  file: %download-page.r
  title: "Download page"
  version: 0.2.1
  purpose: {
    Download in a tmp directory all elements of a URL : 
    - CSS scripts
    - Javascript scripts
    - Images
    Return the page size.
  }
  comments: {
    This function do not handle cache like a webbrowser and parallel downloading of resources.
    Must simulate parallel programming : in further release make it work with 3 tiny servers
    - one for images downloading
    - one for css script downloading
    - one for javascript downloading
    And manage cache.
    Do not download others resources like Adobe Flash content.
  }
  category: [internet]
  library: [
    level: 'beginner
    platform: 'all
    type: [internet html]
    domain: [internet html]
    tested-under: [win]
    support: none
    license: 'public-domain
    see-also: none
  ]
  history [
    0.2.1 17/01/2011 "Secure downloading with attempt"
    0.2.0 15/01/2011 "Make a release on rebol.org"
    0.1.0 05/01/2011 "Creation of the script"
  ]
  usage: {
    >> url-page: to-url ask "URL ? "
    >> print ["Page size" download-page/temp-dir url-page %page1 "kb."]
  }
]

download-page: funct [url [url!] /temp-dir dir [file!]] [
  either temp-dir [tmp: copy dir][tmp: %tmp]
  kb?: funct [d] [
    t: type? d
    either any [t == file! t == url!] [
      i: info? d
      round/to i/size / 1024 .1
    ][
      round/to (length? d) / 1024 .1
    ]  
  ]
  remove-comments: funct [page] [
    foreach line page [
  	  t: mold first page
    	if not none? find t "<!--" [remove/part line (length? t) + 2] 
  	  page: next page
    ]
    page: head page
  ]
  page: load/markup url
  make-dir tmp
  old-dir: what-dir
  change-dir tmp
  delete/any %*
	write %page.html page	
	remove-comments page
	page: read %page.html
	image-list: copy []
	script-list: copy []
	css-list: copy []
	parse url [thru "http://" copy site-url to "/"]
	site-url: join "http://" site-url
	parse page [
		some [
			thru "<img" copy src-link to ">" (
				s: copy ""
				parse src-link [
					thru "src=^"" copy s to "^""
				]
				if s = "" [
					parse src-link [
						thru "src=" copy s to " " or end
					]					
				]
				replace/all s "&#xA;" ""
				replace/all s "&#x9;" ""
				trim s
				replace/all s "%09" ""
				append image-list to-url join site-url s
			)
	 	]
 	]
 	parse page [
 		some [
			thru "<script" copy src-link to ">" (
				s: copy ""
				parse src-link [
					thru "src=^"" copy s to "^""
				]
				if s = "" [
					parse src-link [
						thru "src=" copy s to " " or end
					]					
				]
				if s <> "" [
				  m: find/match s "/Combiner.axd"
				  either not none? m [
				    parse m [thru "r=" copy d to "&"]
				    parse m [thru "s=" copy src to end]
				    parse src ","
				    if pick d 1 <> "/" [d: join "/" d]
				    foreach l parse src "," [
  				    append script-list to-url rejoin [site-url d l]
			      ] 
		      ][
    				append script-list to-url join site-url s
  			  ]
				]
			)			
		]
	]
  parse page [
 		some [
			thru "<link" copy src-link to ">" (
				s: copy ""
				parse src-link [
					thru "href=^"" copy s to "^""
				]
				if s = "" [
					parse src-link [
						thru "href=" copy s to " " or end
					]					
				]
				if s <> "" [
				  m: find/match s "/Combiner.axd"
				  either not none? m [
				    parse m [thru "r=" copy d to "&"]
				    parse m [thru "s=" copy src to end]
				    parse src ","
				    replace/all d "%2F" "/"
				    if pick d 1 <> "/" [d: join "/" d]
				    foreach l parse src "," [
				      replace/all l "%2F" "/"
  				    append css-list to-url rejoin [site-url d l]
			      ] 
		      ][
    				append css-list to-url join site-url s
  			  ]
				]
			)			
		]
	]	
	size: kb? %page.html
  image-list: unique image-list  
	foreach img image-list [
	  set [path file] split-path img
	  attempt [
	    write/binary file read/binary img
	    size: size + kb? file
    ]
  ]
  script-list: unique script-list
	foreach scr script-list [
	  set [path file] split-path scr
	  attempt [
	    write file read scr
	    size: size + kb? file
    ]
	]
  css-list: unique css-list
	foreach css css-list [
	  set [path file] split-path css
	  attempt [
	    write file read css
	    size: size + kb? file
    ]
  ]	
  change-dir old-dir
  size
]