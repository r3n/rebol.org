REBOL [
   Title: "FF3 ZSNES Saved state editor"
   File: %ff3edit.r
   Author: "Cal Dixon"
   Date: 21-Dec-2002
   Purpose: {A tool to edit saved state files for Final Fantasy 3 as created by the ZSNES emulator}
   Library: [
      level: 'intermediate
      platform: [all windows]
      type: 'tool
      domain: [file-handling game vid]
      tested-under: [view 1.2.10.3.1 on [W2K] by "Cal"]
      license: 'PD
      support: none
      ]
   ]

to-cstring: func [ str bufsize ] [
   head change (head insert/dup (make binary! bufsize) #{00} bufsize) to-binary str
   ]

unsignedint32: func [ n ] [
   reduce [
      to-char ((n / 65536) / 256) to-char ((n / 65536) // 256)
      to-char ((n // 65536) / 256) to-char ((n // 65536) // 256)
      ]
   ]

signedint32: func [ n ] [
   n: either n < 0 [
      xor~ #{ffffffff} to-binary rejoin unsignedint32 ((n * -1) - 1)
      ][
      unsignedint32 n
      ]
   reduce [ to-char first n to-char second n to-char third n to-char fourth n ]
   ]

to-binary-int: func [ n /unsigned /short /intel ] [
   n: either unsigned [ unsignedint32 n ] [ signedint32 n ]
   to-binary rejoin either intel [
      either short [ [fourth n third n] ] [ head reverse n ]
      ][
      either short [ [third n fourth n] ] [ n ]
      ]
   ]

items: [
#{00} "Dirk" #{01} "MithrilKnife" #{02} "Guardian" #{03} "Air Lancet" #{04} "ThiefKnife" #{05} "Assassin"
#{06} "Man Eater" #{07} "SwordBreaker" #{08} "Graedus" #{09} "ValiantKnife" #{0A} "MithrilBlade"
#{0B} "RegalCutlass" #{0C} "Rune Edge" #{0D} "Flame Sabre" #{0E} "Blizzard" #{0F} "ThunderBlade" 
#{10} "Epee" #{11} "Break Blade" #{12} "Drainer" #{13} "Enhancer" #{14} "Crystal" #{15} "Falchion"
#{16} "Soul Sabre" #{17} "Ogre Nix" #{18} "Excalibur" #{19} "Scimiter" #{1A} "Illumina" #{1B} "Ragnarok"
#{1C} "Atma Weapon" #{1D} "Mithril Pike" #{1E} "Trident" #{1F} "Stout Spear" #{20} "Partisan" #{21} "Pearl Lance"
#{22} "Gold Lance" #{23} "Aura Lance" #{24} "Imp Halberd" #{25} "Imperial" #{26} "Kodachi" #{27} "Blossom" 
#{28} "Hardened" #{29} "Striker" #{2A} "Stunner" #{2B} "Ashura" #{2C} "Kotetsu" #{2D} "Forged" #{2E} "Tempest" 
#{2F} "Murasame" #{30} "Aura" #{31} "Strato" #{32} "Sky Render" #{33} "Heal Rod" #{34} "Mithril Rod" 
#{35} "Fire Rod" #{36} "Ice Rod" #{37} "Thunder Rod" #{38} "Poison Rod" #{39} "Pearl Rod" #{3A} "Gravity Rod" 
#{3B} "Punisher" #{3C} "Magus Rod" #{3D} "Chocobo Brsh" #{3E} "DaVinci Brsh" #{3F} "Magical Brsh" 
#{40} "Rainbow Brsh" #{41} "Shuriken" #{42} "Ninja Star" #{43} "Tack Star" #{44} "Flail" #{45} "Full Moon" 
#{46} "Morning Star" #{47} "Boomerang" #{48} "Rising Sun" #{49} "Hawk Eye" #{4A} "Bone Club" #{4B} "Sniper" 
#{4C} "Wing Edge" #{4D} "Cards" #{4E} "Darts" #{4F} "Doom Darts" #{50} "Trump" #{51} "Dice" #{52} "Fixed Dice" 
#{53} "MetalKnuckle" #{54} "Mithril Claw" #{55} "Kaiser" #{56} "Poison Claw" #{57} "Fire Knuckle" 
#{58} "Dragon Claw" #{59} "Tiger Fangs" #{5A} "Buckler" #{5B} "Heavy Shld" #{5C} "Mithril Shld" #{5D} "Gold Shld"
#{5E} "Aegis Shld" #{5F} "Diamond Shld" #{60} "Flame Shld" #{61} "Ice Shld" #{62} "Thunder Shld" 
#{63} "Crystal Shld" #{64} "Genji Shld" #{65} "TortoiseShld" #{66} "Cursed Shld" #{67} "Paladin Shld" 
#{68} "Force Shld" #{69} "Leather Hat" #{6A} "Hair Band" #{6B} "Plumed Hat" #{6C} "Beret" #{6D} "Magus Hat" 
#{6E} "Bandana" #{6F} "Iron Helmet" #{70} "Coronet" #{71} "Bard's Hat" #{72} "Green Beret" #{73} "Head Band" 
#{74} "Mithril Helm" #{75} "Tiara" #{76} "Gold Helmet" #{77} "Tiger Mask" #{78} "Red Hat" #{79} "Mystery Veil" 
#{7A} "Circlet" #{7B} "Regal Crown" #{7C} "Diamond Helm" #{7D} "Dark Hood" #{7E} "Crystal Helm" #{7F} "Oath Veil"
#{80} "Cat Hood" #{81} "Genji Helmet" #{82} "Thornlet" #{83} "Titanium" #{84} "LeatherArmor" #{85} "Cotton Robe"
#{86} "Kung Fu Suit" #{87} "Iron Armor" #{88} "Silk Robe" #{89} "Mithril Vest" #{8A} "Ninja Gear" 
#{8B} "White Dress" #{8C} "Mithril Mail" #{8D} "Gaia Gear" #{8E} "Mirage Dress" #{8F} "Gold Armor" 
#{90} "Power Sash" #{91} "Light Robe" #{92} "Diamond Vest" #{93} "Red Jacket" #{94} "Force Armor" 
#{95} "DiamondArmor" #{96} "Dark Gear" #{97} "Tao Robe" #{98} "Crystal Mail" #{99} "Czarina Gown" 
#{9A} "Genji Armor" #{9B} "Imp's Armor" #{9C} "Minerva" #{9D} "Tabby Suit" #{9E} "Chocobo Suit" #{9F} "Moogle Suit"
#{A0} "Nutkin Suit" #{A1} "BehemethSuit" #{A2} "Snow Muffler" #{A3} "NoiseBlaster" #{A4} "Bio Blaster" 
#{A5} "Flash" #{A6} "Chain Saw" #{A7} "Debilitator" #{A8} "Drill" #{A9} "Air Anchor" #{AA} "AutoCrossbow" 
#{AB} "Fire Skean" #{AC} "Water Edge" #{AD} "Bolt Edge" #{AE} "Inviz Edge" #{AF} "Shadow Edge" #{B0} "Goggles" 
#{B1} "Star Pendant" #{B2} "Peace Ring" #{B3} "Amulet" #{B4} "White Cape" #{B5} "Jewel Ring" #{B6} "Fair Ring" 
#{B7} "Barrier Ring" #{B8} "MithrilGlove" #{B9} "Guard Ring" #{BA} "RunningShoes" #{BB} "Wall Ring" 
#{BC} "Cherub Down" #{BD} "Cure Ring" #{BE} "True Knight" #{BF} "DragoonBoots" #{C0} "Zephyr Cape" 
#{C1} "Czarina Ring" #{C2} "Cursed Cing" #{C3} "Earrings" #{C4} "Atlas Armlet" #{C5} "BlizzardRing" 
#{C6} "Rage Ring" #{C7} "Sneak Ring" #{C8} "Pod Bracelet" #{C9} "Hero Ring" #{CA} "Ribbon" #{CB} "Muscle Belt" 
#{CC} "Crystal Orb" #{CD} "Gold Hairpin" #{CE} "Economizer" #{CF} "Thief Glove" #{D0} "Gauntlet" 
#{D1} "Genji Glove" #{D2} "Hyper Wrist" #{D3} "Offering" #{D4} "Beads" #{D5} "Black Belt" #{D6} "Coin Toss" 
#{D7} "FakeMustache" #{D8} "Gem Box" #{D9} "Dragon Horn" #{DA} "Merit Award" #{DB} "Momento Ring" 
#{DC} "Safety Bit" #{DD} "Relic Ring" #{DE} "Moogle Charm" #{DF} "Charm Bangle" #{E0} "Marvel Shoes" 
#{E1} "Back Gaurd" #{E2} "Gale Hairpin" #{E3} "Sniper Sight" #{E4} "Exp. Egg" #{E5} "Tintinabar" 
#{E6} "Sprint Shoes" #{E7} "Rename Card" #{E8} "Tonic" #{E9} "Potion" #{EA} "X Potion" #{EB} "Tincture" 
#{EC} "Ether" #{ED} "X Ether" #{EE} "Elixir" #{EF} "Megalixir" #{F0} "Fenix Down" #{F1} "Revivify" 
#{F2} "Antidote" #{F3} "Eydrop" #{F4} "Soft" #{F5} "Remedy" #{F6} "Sleeping Bag" #{F7} "Tent" #{F8} "Green Cherry"
#{F9} "Magicite" #{FA} "Super Ball" #{FB} "Echo Screen" #{FC} "Smoke Bomb" #{FD} "Warp Stone" #{FE} "Dried Meat"
#{FF} "Nothing"
]
espernames: [
[
Ramuh
Ifrit
Shiva
Siren
Terrato
Maduin
Shoat
Bismark
]
[
Stray
Palidor
Tritoch
Odin
Raiden 
Bahamut
Alexandr
Crusader
]
[
Ragnarok
Kirin 
Zoneseek
Carbunkl
Phantom
Sraphim
Golem
Unicorn
]
[
Fenrir
Startlet
Phoenix
]
]

bits: [
#{01}
#{02}
#{04}
#{08}
#{10}
#{20}
#{40}
#{80}
]

item-code-to-name: func [ code ][
   if integer? code [ code: to-binary to-char code ]
   any [select items hex2bin code "Nothing"]
   ]

item-name-to-code: func [ name ][
   first to-block any [back any [find items name [#{FF}]] [#{FF}]]
   ]

hex2bin: func [hex][
   if binary? hex [ return hex ]
   if string? hex [ return load rejoin ["#{" hex "}"] ]
   if issue? hex [ return hex2bin to-string hex ]
   to-binary hex
   ]

o-itemtype: to-integer hex2bin #247C
o-itemcount: to-integer hex2bin #257C

load-game: func [][
flash "Loading"
data: read/binary request-file/file/only/filter %Final_Fantasy_III_official.zs1 ["*.zs?"]
unview
inv-scroll-n: 0

decode-game: func [data /local inventory gold esperbits names byte bytenum i][
   inventory: make block! 256
   for n 0 255 1 [
      item: copy/part skip data (o-itemtype + n) 1
      count: copy/part skip data (o-itemcount + n) 1
      if all [item <> #{FF} count <> #{00}][
         ;print [ to-integer count item-code-to-name item " in slot " n ]
         append inventory reduce [to-integer item to-integer count]
         ]
      ]
   gold: to-integer head reverse copy/part skip data to-integer #{2473} 3
   esperbits: copy/part skip data to-integer #{267C} 4
   for bytenum 1 4 1 [
      names: pick espernames bytenum
      byte: to-binary to-char pick esperbits bytenum
      for i 1 8 1 [
         if all [pick names i #{00} <> ((pick bits i) and byte)] [
            print to-string pick names i
            ]
         ]
      ]
   return reduce [inventory gold]
]

set [inventory gold] decode-game data
]

load-game

view center-face layout [
   across
   text "Gold:" gold-field: field form gold [
      gold: to-integer value
      ]
   return
   text 150 "All items:" pad 100 text "Inventory:" return
   item-sel: text-list 250x400 data extract/index items 2 2
   space 0
   inv-sel: list 250x400 [
      across
      name: text 200x16 with [n: 256] feel [
         engage: func [f a e i][
            ; probe f/text
            if e/type = 'up [
               nt: number: request-text/title/default
                  item-code-to-name pick inventory ((f/n - 1) * 2) + 1 form pick inventory ((f/n - 1) * 2) + 2
               item-code: pick inventory ((f/n - 1) * 2) + 1 
               if none? nt [return]
               number: any [attempt [to-integer number] pick inventory ((f/n - 1) * 2) + 2 ]
               either number = 0 [
                  remove/part skip inventory ((f/n - 1) * 2) 2
                  ][
                  change/part skip inventory ((f/n - 1) * 2) reduce [ item-code number ] 2
                  ]
               show inv-sel
               ]
            ]
         ]
      quantity: text 50x16
      ] supply [
      count: count + inv-scroll-n
      set [id num] skip inventory ((count - 1) * 2)
	name/n: any [count 256]
      name/text: if integer? id [item-code-to-name id]
      quantity/text: if integer? id [form num]
      ]
   inv-scroll: slider 16x400 [
      inv-scroll-n: to-integer max 0 inv-scroll/data * (-24 + (.5 * length? inventory)) show inv-sel
      ]
   return
   button "Add" [
      ;print [item-sel/picked item-name-to-code item-sel/picked]
      if all [item-sel/picked not empty? item-sel/picked][
         insert tail inventory reduce [to-integer item-name-to-code first item-sel/picked 1]
         show inv-sel
         ]
      ]
   tab button "Save" [
      change/part skip data to-integer #{2473} copy/part to-binary-int/intel gold 3 3
      n: 0
      for n 0 255 1 [ poke data o-itemtype + n to-char 255 poke data o-itemcount + n to-char 0 ]
      foreach [item-type number] inventory [
         poke data o-itemtype + n to-char to-integer item-type
         poke data o-itemcount + n to-char to-integer number
         n: n + 1
         ]
      write/binary request-file/file/only/save %Final_Fantasy_III_official.zs2 data
      ]
   tab button "Quit" [quit]
   ]
