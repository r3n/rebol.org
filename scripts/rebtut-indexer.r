rebol [
	File: %rebtut-indexer.r
	Date: 14-12-2009 
	Author: "Gerard Cote"
        Version: 0.0.1
	Title: "A keyword based search engine for the Rebtutorial articles index page" 
	Purpose: {Was tired looking up visually the index page for any article containing a specific keyword.
			  
			  For now the script loads and parses the original articles' index page duirectly from the Rebtutorial.com web site, 
			  splitting URL links apart from their descriptions, and while counting them it appends them to a block 
			  that can be searched by keyword. 
			  
			  Every occurence is itself appended into a list that displays itself when the verbose mode is set to 'true. 
			  
			  Furthermore, for the time being, you'll have to manually delete the many comments included here
			  for documentation and exploration of another auto-doc selective help system, inspired by the comments section of
			  the dynamic dictionary (%word-browser.r script) found in the RebWorld - Tools folder.
			  
			  See the EXAMPLES section for more info and the look I originally plan to have.
			  Every suggestion is welcome and appreciated. Eventually I would prefer to develop a RSpec like product
			  for keeping executables specs in sync with Unit tests (%rUnit.r) of the xUnit family.
			 }  	
	library: [ 	level: 'beginner 
				platform: 'all 
				type: [tutorial tool] 
				domain: [parse util text] 
				tested-under: [view 2.7.6.3.1 on "Windows Vista Home Premium"] 
				support: "gerardcote (at) gmail (dot) com" 
				license: "Open source" 
				see-also: "refs inside comments"
	] 
]

{
Notes:
 
Patterns found from the analysis of the "Rebtutorial Articles index"       (http://reboltutorial.com/articles/)
====================================================================

0- The articles section delimiting pattern	(used to delimit and isolate only the articles from the entire page)
------------------------------------------

<div class="azindex">					; This is the mark that precedes all the articles' links-descriptions
...										;   <--- Articles are placed here
<div style="clear:both;">				; This the mark that follows all the articles'


1- The section-name href="#" pattern	(used to identify the section names preceding each group of links)
------------------------------------
<li><h2><a href="#">       				; part preceding the char ([) or the letter (A-Z) identifying each section 
					 "<"			    ; part following this char or letter 
				    ^					; position of the char or letter to grab during the parsing process
				    |                   ;   (one of  [, A, B, C, ... , Z )
				    v
<li><h2><a href="#">[</a></h2></li>   	; 1st section - the section appearing before the one for the letter A
<li><h2><a href="#">A</a></h2></li>   	; 2nd section (Letter A)
<li><h2><a href="#">B</a></h2></li>   	; 3rd section (Letter B)

...									  	; Not every section has to be present


2- The URL link "href=" pattern    		(used to detect each link-description in a group of URLs)
-------------------------------
"<li><a href="							; part preceding each URL link 
					       ">"		  	; part ending each URL link 
			    ^						; position of the URL to grab during the parsing process
				|   	                   
				v
"<li><a href="http://...   ">"			; Every link has the form http://...
										; and is followed on the next line by this <span class="head"> tag


3- The URL desc <span...> pattern    	(used to detect each link-description in a group of URLs)
----------------------------------

<span class="head">						; part preceding the description part of each URL link
										; The positioning is implemented using 2 subcommands "<span class=" and [7 skip]
					 	   "<"			; part ending each URL link description
					 ^
					 |
					 v
<span class="head">Why ... </span></a></li> ; Example of a real link description
					 					
====================================================================
}


; ==================================
; trial #5 functional
; ==================================
;
; -- Extracts, counts, displays and keeps each section name with
; -- each hyperlink URL and description parts. This permits the subsequent search
;

; ==================================
; -- Getting the index page 
; ==================================
;
page: read http://reboltutorial.com/articles/

; ====================================
; -- Extracting only the articles part
; ====================================
;
parse page [thru <div class="azindex">  copy text to <div style="clear:both;"> to end]

extract-articles: does [

; ==================================
; -- Global vars 
; ==================================
;
	links: copy []
	sections: copy []
	c1-1: 0   	; # Sections
	c1-2: 0		; # Descriptions et liens

; ==============================================
; -- Extracting URLs and descriptions from links
; ==============================================
;

	parse text [some [
					 [	
						  thru <li><h2><a href="#"> copy nom-section  to "<" thru </li> (
				     		c1-1: c1-1 + 1
			     			section: "#"
			     			append sections rejoin [section " - " nom-section]
				 			probe entete-section: copy rejoin [c1-1 " =========== " section " - " nom-section " ============="]
						  )
					 ]
					 
					|
										   
				     [
				    		thru "<li><a href=" skip copy lien to ">" thru "<span class=" [ 7 skip] copy desc to "<" thru </li> (
				     			c1-2: c1-2 + 1
				     			lien: copy/part lien ((length? lien) - 1)
				     			append links to-block remold [c1-2 lien to-string desc]
					 			probe entete-lien: copy rejoin [c1-2 " == " lien " -- " desc " =="]
					 
					  		)
					  	  
					 ]
					
				 ]
			 to end
			]
]

; =================================================
; -- Searching for a word in every link description
; =================================================
;
search: func [
{Search for the presence of a word in each one of an articles' descriptions block stored in web page
  and returns the number, URL and corresponding description of each found occurence in a resulting block.
	
EXAMPLES : 	
			; extracted sample data is used below 
			;
			; -- For getting complete links, use ALL the above cmds (reproduced below)
			;
			; page: read http://reboltutorial.com/articles/
			; parse page [thru <div class="azindex">  copy text to <div style="clear:both;"> to end]
			; define and run the extract-articles function defined above
			;
			links: [
				[ 1 
				  "http://reboltutorial.com/blog/create-dsl/" 
				  {[Hot!] Create your own Domain Specific Language [DSL] in 15 minutes [part 1]}
				][
				  2 
				  "http://reboltutorial.com/blog/dzone-protocol/" 
				  {[Hot!] How to create a dzone:// protocol (like http://) or an Asynchronous Protocol Handler}
				][
				  3 
				  {http://reboltutorial.com/blog/try-the-easy-yuml-domain-specific-language-online-without-downloading-rebol/} 
				  {[HOT!] Try the Easy yUML Domain Specific Language Online without downloading Rebol!}
				][
				  4
				  {http://reboltutorial.com/blog/rebol-twitter-update/} 
				  {[Hot] How to tweet from Rebol in One line (using Twitter API)!}
				][
				  5 
				  {http://reboltutorial.com/blog/map-reduce-functions-in-rebol-towards-massive-parallel-functional-programming-part-i/}
				  {[Hot] Map Reduce Functions in Rebol: towards Massive Parallel Functional Programming (part I)}
				]
				
				...   (There are many more! When written 99 articles were listed)
			]
			
			>>search links "functional"					--> returns list of articles where "functional" is found
			---------------------------					--> Here a single link is returned
			== [5 http://reboltutorial.com/blog/map-reduce-functions-in-rebol-towards-massive-parallel-functional-programming-part-i/ 
			{[Hot] Ma...   }
			>>	    


			>>search/verbose links "functional" true 	--> verbose mode adds some details about found lines
			----------------------------------------	
            "functional was found 1 fois."
			It is on line : 5
			in the article : [Hot] Map Reduce Functions in Rebol: towards Massive Parallel Functional Programming (part I)
			The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/

			== [5 http://reboltutorial.com/blog/map-reduce-functions-in-rebol-towards-massive-parallel-functional-programming-part-i/ 
			{[Hot] Ma... }
			>>  
			

			>>search/verbose links "language" true		--> returns list of articles where "language" is found
			--------------------------------------		--> Here many links (7) are displayed 
															(since I used the full 99 articles indexd available at this moment)
            "language was found 7 time(s)."
            It is on line : 1
            in the article : [Hot!] Create your own Domain Specific Language [DSL] in 15 minutes [part 1]
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            on line : 3
            in the article : [HOT!] Try the Easy yUML Domain Specific Language Online without downloading Rebol!
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            on line : 25
            in the article : Creating an OOP Class-Based Language with an Homoiconic / Prototype-Based OOP Language
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            on line : 53
            in the article : How to create an XML Document with the Easy ML Domain Specific Language (Youtube Video at the end)
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            on line : 76
            in the article : Rebol and the Grand Unification Theory of Programming Languages
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            on line : 82
            in the article : Rebol is a Prototype-Based OOP Language
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            on line : 88
            in the article : Rebol's Reflection based on its Language Homoiconicity Property (Code-Data duality property)
            The refering link is : http://reboltutorial.com/blog/why-carl-sassenrath-one-of-30-most-influential-people-in-programming/
            
            == [1 http://reboltutorial.com/blog/create-dsl/ 
            {[Hot!] Create your own Domain Specific Language [DSL] in 15 minutes [part 1]} 
            3 ht...]
            >>
            
            >> length? found-lines				--> where are stored the lines found with their numbers, description and links 
			== 21
			>>
			
}
	'links-list [word!] 
	search-word [string!] 
	/verbose verbose? [logic!]
	
][

	if not verbose [
		set 'verbose? false
	]
	
	links-list: get links-list
	found-lines: copy []
	trouve: false
	c-trouve: 0

	foreach [line] links-list [
		;probe "-----------"
		line-num: first line  ;probe line-num
		lien: to-url second line  ;probe lien
		desc: third line ;probe desc
		
		if find desc search-word [
			c-trouve: c-trouve + 1
			if not trouve [
				trouve: true
			]	
			append found-lines reduce [line-num lien desc]
		]
			
	]
	
	either not trouve [
		probe rejoin [search-word " was not found in " links-list]
		return none
	][
		if verbose? = true [
			probe rejoin [search-word " was found "  c-trouve " time(s)."] 
			prin ["It is "]
		
			foreach [line link descr] found-lines [
					print rejoin [
							  "on line : " line newline
							  "in the article : " descr newline 
							  "The refering link is : " lien newline
						  ]						 
			]
		]
		return found-lines
			
	]
]

;
; ===================================== TESTS ==============================================
;
extract-articles

print newline
probe "search for knowledge without verbose mode"
probe " - no output displayed only a value is returned for further processing"
print newline

result1: search links "knowledge"	

print newline
probe "search for knowledge with verbose mode"
probe "everything is displayed"
print newline

result2: search/verbose links "knowledge" true

print newline
probe "search for language without verbose mode"
probe " - no output displayed only a value is returned for further processing"
print newline

result3: search links "language"	

print newline
probe "search for language with verbose mode"
probe "everything is displayed"
print newline

result4: search/verbose links "language" true

print newline
probe "display the stored result following a search for the word (language)"
probe " - verbose mode doesn't affect the stored return result"
print newline

foreach item result3 [print item]

halt

; browse search links "knowledge"	; In the original version only the first occurence of the searched word was returned
									;  and then I could directly browse from the hyperlink found in the articles
									; For the next step - the returned list of links could be put in a list to be selected by the user 
									;  which then would choose the one link of interest to him for browsing.
									;  I will have to do it soon for my first small project using REBOL and GLayout from Maxim



; ===================================== OTHER STUFF From which I started this project ==============================================

; Extract from Carl (extracted from script %word-browser.r)
;
search-words: func [text /local words tmp got] [
	unselect-lists
	words: clear []
	foreach [word def] ref [
		if find tmp: form word text [
			if tmp = text [got: word]
			append words word
		]
	]
	filter-words/list none words
	got
]



{   Extrait de REbTut qui a servi d'idée et de base de travail

content: read http://reboltutorial.com/articles/

raw-list: parse/all content {" #" " : , ' / . #"{" #"}" - ; ~}

parse-begin: <div class="azindex">
parse-end: <div style="clear:both;">

exclude-list: [
	"http" "" "" "www" "com" "^/" "The" "of" "and" "was" "it" "" "on" "that" "to" "the" 
	"Then" "html^/" "for" "In" "my" "which" "I" "I" "was" "a" "over" "years" "but" "by" 
	"C" "soon" "they" "it" "no" "html^/" "I" "the" "at" "The" "such" "that" "is" "an" 
	"^/^/http" "html"
]

my-index: exclude raw-list exclude-list

search-for: func ['dict 'word][
	
; ========================================================================================	
6 - Save web page text to a file

remove-each tag page: load/markup http://www.rebol.com [tag? tag] write %page.txt page

    Summary: This line reads a web page, strips all its tags (leaving just the text) and writes it to a file called page.txt. Note: requires newer releases of REBOL.
    Author(s): Carl Sassenrath
    Length: 87 characters 

}
