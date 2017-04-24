REBOL [
  Author: "Shadwolf - Alphé Salas-Schumann"
  File: %wallp.r
  Date: 16-01-2011
  Title: "Gnome Evolving Wallpaper"
  Purpose: {change every hours to three hours your 
  gnome's desktop wallpaper with an image of planet Earth real time enlightenment.
This script is a one-liner splited for reading purpose }
  Type:  [ tool one-liner ]
  Domain: [ gui shell]
  Licence: public-domain 
  Os: "linux mint gnome 10"
  tested-under: [ view 2.7.8.4.2 ]
]

comment { 
The goal is to have a evolving wallpapper for our gnome desktop

works with a crontab that goes with it :
in shell type: $>  contrab -e 
then:  
5 */3 * * * rebol -q -s /usr/local/bin/wallp.r
or for hourly check
5 * * * * rebol -q -s /usr/local/bin/wallp.r
then verify the crontab is installed with
crontab -l 
of course you should adapt path in crontab and in the second call line
to reflect your hown storage for this file and the dowloaded wallpapper
I recommand you to add rebol -q -s /usr/local/bin/wallp.r in a launcher on your desktop. 
and to add this line  in the startup applications.
}

write/binary %wallpaper.jpg read/binary http://static.die.net/earth/mercator/1600.jpg
wait 3
call "gconftool-2 -t str -s /desktop/gnome/background/picture_options scaled"
call "gconftool-2 -t str -s /desktop/gnome/background/picture_filename /usr/local/bin/wallpaper.jpg"