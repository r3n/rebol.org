REBOL [
   Title: "Half-life log parser"
   Author: "Cal Dixon"
   Date: 4-Mar-2004
   File: %hllogparser.r
   Purpose: "Allows a rebol script to parse server logs from the game: Half-life"
   Library: [
        level: 'intermediate
        platform: 'all
        type: [tool game function]
        domain: [game text-processing parse]
        tested-under: none
        support: none
        license: 'PD
        see-also: %rcon.r
      ]
   ]

logparser-ctx: context [
prefix: [ "L " copy tdate date " - " copy ttime time ": " ]

comment: [ "//" thru "^/" ]

tdate: copy ""
ttime: copy ""
tstring: copy ""
tuser: copy ""
tvictim: copy ""
tvalue: copy ""
tusername: copy ""
tuid: copy ""
twonid: copy ""
tteamid: copy ""
tprop: copy ""
tevent: copy []
tlog: copy []

month: [ digit digit ]
day: [ digit digit ]
year: [ digit digit digit digit ]
date: [ month "/" day "/" year ]
time: [ hour ":" minute ":" second ]
minute: [ digit digit ]
second: [ digit digit ]
hour: [ digit digit ]
digit: charset "0123456789"
nonquote: complement charset {"}
nonqb: complement charset {"<>}
nonlf: complement charset {^/}
propchar: complement charset " )"
string: [ copy tstring any nonquote ]
value: [ copy tvalue any nonquote ]
username: [ some nonqb ]
uid: [ "<" copy tuid [ some digit | "BOT" ] ">" ]
wonid: [ "<" copy twonid some nonqb ">" ]
teamid: [ "<" copy tteamid any nonqb ">" ]
user: [
   opt {"} copy tusername username uid wonid teamid opt {"}
   (tuser: reduce [tusername tuid twonid tteamid])
   ]
victim: [
   opt {"} copy tusername username uid wonid teamid opt {"}
   (tvictim: reduce [tusername tuid twonid tteamid])
   ]
forgiver: [ {"} some nonquote {" (WON ID : } some digit ")" ]
forgiven: [ {"} some nonquote {" (WON ID : } some digit ")" ]
propvalue: [ any nonquote ]
property: [ copy tprop [some propchar opt [{ "} propvalue {"}]] ]
logstart: [ "Log file started " thru "^/" ]
loadmap: [ {Loading map "} string {"^/} ]
cvar: [ {Server cvar "} string {" = "} value {"^/} ]
startmap: [ {Started map "} string {" (CRC "} value {")^/} ]
fileload: [ {"} string {" loaded^/} ] 
joingame: [ user " entered the game^/" ]
jointeam: [ user { joined team "} string {"^/} ]
changeteam: [ user { changed to team "} string {"^/} ]
selectweapon: [ user { selected weapon "} string {"^/} ]
acquireweapon: [ user { acquired weapon "} string {"^/} ]
say: [ user { say "} copy tstring to {"^/} {"^/} ]
connected: [ user { connected, address "} string {"^/} ]
attack: [ user " attacked " victim { with "} string {" (} property {)^/} ] 
landhard: [ user " landed...... hard^/" ]
kill: [ user " killed " victim { with "} string {"^/} ]
killself: [ user " killed self^/" ]
worldkill: [ user " killed by world^/" ]
tk: [ "**TeamKill by " user "^/"]
disconnect: [ user " disconnected^/" ]
forgivetk: [ forgiven "^/ was forgiven by ^/" forgiver " ^/" ]
rcon: [ {Rcon: "} rconcommand {" from "} string {"^/}]
badrcon: [ {Bad Rcon: "} rconcommand {" from "} string {"^/}]
rconcommand: [ realrconcommand | any nonquote ]
realrconcommand: [ "rcon " sessionid { "} password {" } realcommand ]
sessionid: [ some digit ]
password: [ any nonquote ]
realcommand: [ any nonquote ]
namechange: [ user { changed name to "} string {"^/} ]
worldaction: [ {World triggered "} string {"^/} ]
pmsg: [ user " tell " victim { "} string to {"^/} {"^/} ]
serversay: [ {Server say "} string to {"^/} {"^/} ]
metamodline: [ "[META] " copy tstring to "^/" "^/" ]
adminmodline: [ "[ADMIN] " copy tstring to "^/" "^/" ]
steamok: [ user { STEAM USERID validated^/} ]
kick: [ "Kick: " user { was kicked by "} string {"^/} ]

event: [
   logstart (insert tevent reduce [none 'LOGSTART none none]) |
   loadmap (insert tevent reduce [none 'LOADMAP none tstring]) |
   connected (insert tevent reduce [tuser 'CONNECTED none tstring]) |
   steamok (insert tevent reduce [tuser 'STEAMOK none none]) |
   "Server cvars start^/" |
   cvar |
   "Server cvars end^/" |
   startmap (insert tevent reduce [none 'STARTMAP none tstring]) |
   fileload |
   joingame (insert tevent reduce [tuser 'JOINGAME none none]) |
   jointeam (insert tevent reduce [tuser 'JOINTEAM none tstring]) |
   selectweapon (insert tevent reduce [tuser 'SELECTWEAPON none tstring]) |
   acquireweapon (insert tevent reduce [tuser 'ACQUIREWEAPON none tstring]) |
   say (insert tevent reduce [tuser 'SAY none tstring]) |
   attack (insert tevent reduce [tuser 'ATTACK tvictim reduce [tstring tprop]]) |
   landhard (insert tevent reduce [tuser 'LANDHARD none none]) |
   killself (insert tevent reduce [tuser 'KILLSELF none none]) |
   kill (insert tevent reduce [tuser 'KILL tvictim tstring]) |
   worldkill (insert tevent reduce [tuser 'WORLDKILL none none]) |
   tk (insert tevent reduce [tuser 'TEAMKILL none none]) |
   kick (insert tevent reduce [tuser 'KICKED none none]) |
   disconnect (insert tevent reduce [tuser 'DISCONNECT none none]) |
   forgivetk |
   rcon |
   badrcon |
   namechange (insert tevent reduce [tuser 'NAMECHANGE none tstring]) |
   worldaction (insert tevent reduce [none 'WORLDEVENT none tstring]) |
   pmsg (insert tevent reduce [tuser 'PRIVATEMSG tvictim tstring]) |
   serversay (insert tevent reduce [none 'SERVERSAY none tstring]) |
   metamodline (insert tevent reduce [none 'METAMOD none tstring]) |
   adminmodline (insert tevent reduce [none 'ADMINMOD none tstring]) |
   "Log file closed^/" (insert tevent reduce [none 'LOGEND none none]) |
   z: thru "^/" y: (copy/part z y)
   ]

logline: [ (clear tevent) "^/" | prefix comment | prefix event (if not empty? tevent [insert/only tail tlog copy tevent]) ]

logfile: [ any logline ]

set 'hl-parse-log-line func [line][
   line: replace/all copy line "^@" ""
   if line/1 <> #"L" [ line: copy skip line 8 ]
   if #"^/" <> last line [ line: join line "^/" ]
   parse/all line logline
   return tevent
   ]

set 'hl-parse-log-file func [file][
   if file? file [ file: read file ]
   parse/all file logfile
   return tlog
   ]
]
