REBOL [
   File: %leftstring.r
   Date: 28-Aug-2005
   Title: "leftString Function"
	 Version: 1.1
   Purpose: {A simple string function which returns the left most n characters.}
   Library: [
      level: 'beginner
      platform: 'all
      type: 'function
      domain: [text text-processing]
      tested-under: [REBOL/Core 2.5.6.3.1 "windows XP Professionsl"]
      support: none
      license: cc-by
      see-also: none
   ]
	 Copyright: {Copyright (C) 2005 - Digital Bear Consulting}
	 Author: {Dale K. Brearcliffe}    
]

leftString: function [
   "Returns the left most arg2 characters of string arg1."
   arg1 [string!]
	 arg2 [number!]
   ][
	 l
	 ][
   l: length? arg1
	 if (l <= arg2) [return arg1]
	 if (arg2 = 0) [return none]
	 if (arg2 < 0) [arg2: 0 - arg2]
	 return copy/part arg1 arg2
] 