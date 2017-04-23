REBOL[
	Title: "Yubnub search"
	Version: 1.0.0
	Copyright: "Philippe Le Goff-2007"
    Author: {"Philippe Le Goff"}
	File: %yubnub-searches.r
	Date: 3-Jan-2007
	Purpose: {
		Just a tool to play with Yubnub service - Yubnub.org.
    }
	Usage: {
		Select a search engine with rotary btn.
                Type the word(s) to search. Click "search" button.
	}
	Library: [
		level: 'beginner
		platform: 'all
		type: [tool]
		domain: [web html]
		tested-under: winXP
		support: none
		license: 'BSD
		see-also: none
	]
]

rot-datas: sort extract metas: [ 
"Google" "g "
"Google News" "gnews "
"Yahoo!" "y "
"Wikipedia" "wp "
"Technorati" "tec "
"Amazon" "am "
"CNN" "cnn "
"Weather for zip code" "weather "
"eBay" "ebay "
"AllMusic.com" "allmusic "
"del.icio.us tag" "deli "
"Flickr" "flk "
"ESPN" "espn "
"Yahoo! Stock Quote" "stock "
"Dictionary (Answers.com)" "a "
 ] 2 
 

lay: [
key (escape) [quit]
backeffect  [ gradient 0x1 148.148.148 22.22.22 ]
rt: rotary brick 150 data rot-datas font [size: 10 name: "Courrier New"]
fld: field 150x20 
pad 0x20
across
btn-cancel 50x20 "Quit" [quit] font [color: white style: 'bold]
pad 20x0
btn-help 70x20 "Search !"  [ browse to-url rejoin ["http://yubnub.org/parser/parse?command=" select metas rt/data/1  fld/text] ]
return
below
pad 15x20
txt gray " © Philippe Le Goff-2007" font [size: 9]
]

view layout lay 

