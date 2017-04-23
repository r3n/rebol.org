REBOL [
	Title:	"NeHe Lesson 5 SDL"
	file: %nehe-lesson05-sdl.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 21-09-2012
	version: 1.0.0
	needs: [
		 %opengl-glu-glut-h.r
		 %sdl-h.r
	]
	Purpose: "Example use of %opengl-glu-glut-h.r and %sdl-h.r"
	History: [
		0.0.1 [11-08-2012 "First version"]
		1.0.0 [21-09-2012 "Minor fixes"]
	]
	Category: [graphics]
	library: [
		level: 'intermediate
		platform: [win linux]
		type: 'how-to
		domain: [graphics]
		tested-under: [View 2.7.8.3.1 2.7.8.4.3]
		support: none
		license: none
		see-also: [http://nehe.gamedev.net %nehe-lesson05.r]
	]
]
{
 * This code was created by Jeff Molofee '99 
 * (ported to Linux/SDL by Ti Leggett '01)
 *
 * If you've found this code useful, please let me know.
 *
 * Visit Jeff at http:;nehe.gamedev.net/
 * 
 * or for port-specific comments, questions, bugreports etc. 
 * email to leggett@eecs.tulane.edu
}
;REBOL-NOTE: load libraries and their headers
modul: any [
	attempt [load %opengl-glu-glut-h.r]
	if not error? try [close open tcp://www.google.com:80] [ ;online?
		flash "Downloading OpenGL library header..."
		modul: load http://www.rebol.org/download-a-script.r?script-name=opengl-glu-glut-h.r ;load-thru does not work (!?)
		save %opengl-glu-glut-h.r modul
		unview
		modul
	]
]
if not modul [alert "Unable to download or find opengl-glu-glut-h.r, quitting" quit]
clear back back tail modul ; remove example code
do modul
modul: any [
	attempt [load %sdl-h.r]
	if not error? try [close open tcp://www.google.com:80] [ ;online?
		flash "Downloading SDL library header..."
		modul: load http://www.rebol.org/download-a-script.r?script-name=sdl-h.r ;load-thru does not work (!?)
		save %sdl-h.r modul
		unview
		modul
	]
]
if not modul [alert "Unable to download or find sdl-h.r, quitting" quit]
clear back back tail modul ; remove example code
do modul

{ screen  width, height, and bit depth }
SCREEN_WIDTH:  640
SCREEN_HEIGHT: 480
SCREEN_BPP:     16

{ Setup our booleans }
;TRUE:  1
;FALSE: 0

{ This is our SDL surface }
surface: none ;SDL_Surface *

{ function to release/destroy our resources and restoring the old desktop }
Quit*: func [returnCode ]
[
	SDL_VideoQuit
	{ clean up the window }
	;SDL_Quit

	;REBOL-NOTE: free SDL library
	free SDL-lib
	
	{ and exit appropriately }
	;quit/return returnCode
	halt	
]

{ function to reset our viewport after a window resize }
resizeWindow: func [width height /local ratio]
[
	{ Height / width ratio }
	ratio: 0.0

	{ Protect against a divide by zero }
	if ( height = 0 ) [height: 1]

	ratio:   width / height

	{ Setup our viewport. }
	glViewport 0 0 width height  

	{ change to the projection matrix and set our viewing volume. }
	glMatrixMode GL_PROJECTION  
	glLoadIdentity   

	{ Set our perspective }
	gluPerspective  45.0 ratio  0.1 100.0 

	{ Make sure we're changing the model view and not the projection }
	glMatrixMode  GL_MODELVIEW  

	{ Reset The View }
	glLoadIdentity   

	TRUE  
]

{ function to handle key press events }
handleKeyPress: func [ keysym ]
[
	switch ( keysym ) reduce
	[
	SDLK_ESCAPE [
		{ ESC key was pressed }
		Quit*  0
		]
	SDLK_F1 [
		{ F1 key was pressed
		 * this toggles fullscreen mode
		 }
		SDL_WM_ToggleFullScreen  surface
		]
	]
]

{ general OpenGL initialization function }
initGL: func []
[

	{ Enable smooth shading }
	glShadeModel  GL_SMOOTH  

	{ Set the background black }
	glClearColor  0.0 0.0 0.0 0.0 

	{ Depth buffer setup }
	glClearDepth  1.0 

	{ Enables Depth Testing }
	glEnable  GL_DEPTH_TEST  

	{ The Type Of Depth Test To Do }
	glDepthFunc  GL_LEQUAL  

	{ Really Nice Perspective Calculations }
	glHint  GL_PERSPECTIVE_CORRECTION_HINT  GL_NICEST  

	TRUE  
]

rtri: rquad: 0.0

{ These are to calculate our fps }
	T0: 0
	Frames: 0

{ Here goes our drawing code }
drawGLScene: func [/local t seconds fps]
[
	{ Clear The Screen And The Depth Buffer }
	glClear GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT 
	glEnable  GL_DEPTH_TEST  

	glLoadIdentity

	glTranslatef -1.5 0.0 -6.0		; Move Left And Into The Screen
	glRotatef rtri 0.0 1.0 0.0		; Rotate The Pyramid On It's Y Axis

	glBegin GL_TRIANGLES			; Start Drawing The Pyramid

		gl-color Red			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Front)
		gl-color Green			; Green
		glVertex3f -1.0 -1.0  1.0		; Left Of Triangle (Front)
		gl-color Blue			; Blue
		glVertex3f  1.0 -1.0  1.0		; Right Of Triangle (Front)

		gl-color Red			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Right)
		gl-color Blue			; Blue
		glVertex3f  1.0 -1.0  1.0		; Left Of Triangle (Right)
		gl-color Green			; Green
		glVertex3f  1.0 -1.0  -1.0		; Right Of Triangle (Right)

		gl-color Red			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Back)
		gl-color Green			; Green
		glVertex3f  1.0 -1.0  -1.0		; Left Of Triangle (Back)
		gl-color Blue			; Blue
		glVertex3f -1.0 -1.0  -1.0		; Right Of Triangle (Back)

		gl-color Red			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Left)
		gl-color Blue			; Blue
		glVertex3f -1.0 -1.0 -1.0		; Left Of Triangle (Left)
		gl-color Green			; Green
		glVertex3f -1.0 -1.0  1.0		; Right Of Triangle (Left)
	glEnd							; Done Drawing The Pyramid
	glLoadIdentity
	glTranslatef 1.5 0.0 -7.0		; Move Right And Into The Screen
	glRotatef rquad 1.0 1.0 1.0		; Rotate The Cube On X, Y & Z

	glBegin GL_QUADS				; Start Drawing The Cube

		gl-color Green			; Set The Color To Green
		glVertex3f  1.0  1.0 -1.0		; Top Right Of The Quad (Top)
		glVertex3f -1.0  1.0 -1.0		; Top Left Of The Quad (Top)
		glVertex3f -1.0  1.0  1.0		; Bottom Left Of The Quad (Top)
		glVertex3f  1.0  1.0  1.0		; Bottom Right Of The Quad (Top

		gl-color Orange			; Set The Color To Orange
		glVertex3f  1.0 -1.0  1.0		; Top Right Of The Quad (Bottom)
		glVertex3f -1.0 -1.0  1.0		; Top Left Of The Quad (Bottom)
		glVertex3f -1.0 -1.0 -1.0		; Bottom Left Of The Quad (Bottom)
		glVertex3f  1.0 -1.0 -1.0		; Bottom Right Of The Quad (Bottom)

		gl-color Red			; Set The Color To Red
		glVertex3f  1.0  1.0  1.0		; Top Right Of The Quad (Front)
		glVertex3f -1.0  1.0  1.0		; Top Left Of The Quad (Front)
		glVertex3f -1.0 -1.0  1.0		; Bottom Left Of The Quad (Front)
		glVertex3f  1.0 -1.0  1.0		; Bottom Right Of The Quad (Front)

		gl-color Yellow			; Set The Color To Yellow
		glVertex3f  1.0 -1.0 -1.0		; Bottom Left Of The Quad (Back)
		glVertex3f -1.0 -1.0 -1.0		; Bottom Right Of The Quad (Back)
		glVertex3f -1.0  1.0 -1.0		; Top Right Of The Quad (Back)
		glVertex3f  1.0  1.0 -1.0		; Top Left Of The Quad (Back)

		gl-color Blue			; Set The Color To Blue
		glVertex3f -1.0  1.0  1.0		; Top Right Of The Quad (Left)
		glVertex3f -1.0  1.0 -1.0		; Top Left Of The Quad (Left)
		glVertex3f -1.0 -1.0 -1.0		; Bottom Left Of The Quad (Left)
		glVertex3f -1.0 -1.0  1.0		; Bottom Right Of The Quad (Left)

		gl-color Violet		; Set The Color To Violet
		glVertex3f  1.0  1.0 -1.0	; Top Right Of The Quad (Right)
		glVertex3f  1.0  1.0  1.0	; Top Left Of The Quad (Right)
		glVertex3f  1.0 -1.0  1.0	; Bottom Left Of The Quad (Right)
		glVertex3f  1.0 -1.0 -1.0	; Bottom Right Of The Quad (Right)
	glEnd							; Done Drawing The Quad

	rtri: rtri + 0.2				; Increase The Rotation Variable For The Triangle 
	rquad: rquad - 0.15				; Decrease The Rotation Variable For The Quad 

	{ Draw it to the screen }
	SDL_GL_SwapBuffers

	{ Gather our frames per second }
	Frames: Frames + 1
	t: SDL_GetTicks
	if (t - T0) >= 5000 [
		seconds: (t - T0) / 1000.0
		fps: Frames / seconds
		print [Frames "frames in" seconds "seconds =" fps "FPS"]
		T0: t
		Frames: 0
	]

	TRUE
]
;REBOL-NOTE: make various structs to access SDL_Event(s), note the last underscore used to distinguish them
;from enumerated constants since REBOL is case insensitive
event-active: make struct! SDL_ActiveEvent_ none
event-resize: make struct! SDL_ResizeEvent_ none
event-key: make struct! SDL_KeyboardEvent_ none
assign-struct: func [dst [struct!] src [struct!]] [change third dst third src]


main: func [/local videoFlags done event videoInfo isActive]
[
	{ Flags to pass to SDL_SetVideoMode }
	videoFlags: 0
	{ main loop variable }
	done: false
	{ used to collect events }
	event: make struct! SDL_Event none
	{ this holds some info about our display }
	videoInfo: 0 ;const SDL_VideoInfo *
	{ whether or not the window is active }
	isActive: TRUE

	{ initialize SDL }
	if ( SDL_Init SDL_INIT_VIDEO ) < 0 
	[
		print ["Video initialization failed:" SDL_GetError ]
		Quit* 1 
	]

	{ Fetch the video info }
	videoInfo: SDL_GetVideoInfo

	if 0 = videoInfo
	[
		print ["Video query failed:" SDL_GetError ]
		Quit*  1  
	]
	;REBOL-NOTE: copy data to a rebol struct!
	videoInfo: addr-to-struct videoInfo SDL_VideoInfo

	{ the flags to pass to SDL_SetVideoMode }
	videoFlags: SDL_OPENGL          { Enable OpenGL in SDL }
	videoFlags: videoFlags or SDL_GL_DOUBLEBUFFER { Enable double buffering }
	videoFlags: videoFlags or SDL_HWPALETTE       { Store the palette in hardware }
	videoFlags: videoFlags or SDL_RESIZABLE       { Enable window resizing }

	{ This checks to see if surfaces can be stored in memory }
	either ( videoInfo/Bits and SDL_hw_available ) <> 0
		[videoFlags: videoFlags or SDL_HWSURFACE]
		[videoFlags: videoFlags or SDL_SWSURFACE]

	{ This checks if hardware blits can be done }
	if ( videoInfo/Bits and SDL_blit_hw ) <> 0
		[videoFlags: videoFlags or SDL_HWACCEL]

	{ Sets up OpenGL double buffering }
	SDL_GL_SetAttribute SDL_GL_DOUBLEBUFFER 1

	{ get a SDL surface }
	surface: SDL_SetVideoMode SCREEN_WIDTH SCREEN_HEIGHT SCREEN_BPP videoFlags 

	{ Verify there is a surface }
	if ( 0 = surface )
	[
		print ["Video mode set failed:" SDL_GetError ]
		Quit*  1  
	]

	{ initialize OpenGL }
	initGL

	{ Resize the initial window }
	resizeWindow  SCREEN_WIDTH  SCREEN_HEIGHT  

	drawGLScene ;REBOL-NOTE: start drawing immediatly
	print "Place mouse cursor inside window to activate it"

	{ wait for events }
	while [ not done ]
	[

		{ handle the events in the queue }

		while [ 0 <> SDL_PollEvent event ]
		[
			switch ( to-integer event/type ) reduce
			[
			SDL_ACTIVEEVENT [
				{ Something's happend with our focus
				 * If we lost focus or we are iconified, we
				 * shouldn't draw the screen
				 }
				assign-struct event-active event ;REBOL-NOTE: translate data to a Rebol struct!
				either ( 0 = to-integer event-active/gain )
					[isActive: FALSE]
					[isActive: TRUE]
				]
			SDL_VIDEORESIZE [
				{ handle resize event }
				assign-struct event-resize event
				surface: SDL_SetVideoMode event-resize/w event-resize/h SCREEN_BPP videoFlags
				if ( 0 = surface )
				[
					print ["Could not get a surface after resize:" SDL_GetError ]
					Quit* 1 
				]
				resizeWindow event-resize/w event-resize/h 
				]
			SDL_KEYDOWN [
				{ handle key presses }
				assign-struct event-key event
				handleKeyPress event-key/keysym-sym 
				]
			SDL_QUIT [
				{ handle quit requests }
				done: true
				]
			]
		]

		{ draw the scene }
		if ( isActive ) [drawGLScene ]  
	]

	{ clean ourselves up and exit }
	Quit*  0  

	{ Should never get here }
	0  
]

main
