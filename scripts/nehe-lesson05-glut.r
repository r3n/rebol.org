REBOL [
	Title:	"NeHe Lesson 5 for GLUT"
	file: %nehe-lesson05-glut.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 20-11-2011
	version: 1.1.0
	needs: [
		 %opengl-glu-glut-h.r
	]
	Purpose: "Example use of %opengl-glu-glut-h.r and OpenGL. Almost ripped from John Niclasen"
	History: [
		0.0.1 [08-11-2011 "First version"]
		1.1.0 [20-11-2011 "Translation completed"]
		1.2.0 [22-04-2013 "Reworked a little"]
	]
	Category: [graphics]
	library: [
		level: 'intermediate
		platform: 'win
		type: 'how-to
		domain: [graphics]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: none
		see-also: nehe.gamedev.net
	]
]

modul: any [
	attempt [do head clear back back tail load %opengl-glu-glut-h.r] ; remove example code and do script
	if confirm "File %opengl-glu-glut-h.r not found in current directory, download it?" [
		modul: attempt [do head clear back back tail load request-download/to http://www.rebol.org/download-a-script.r?script-name=opengl-glu-glut-h.r %opengl-glu-glut-h.r]
	]
]
if none? modul [alert "Unable to find or load %opengl-glu-glut-h.r, quitting" quit]

{*
 *		This Code Was Created By Jeff Molofee 2000
 *		A HUGE Thanks To Fredric Echols For Cleaning Up
 *		And Optimizing The Base Code, Making It More Flexible!
 *		If You've Found This Code Useful, Please Let Me Know.
 *		Visit My Site At nehe.gamedev.net
 *}

rtri: rquad: 0.0

InitGL: does [
	glShadeModel GL_SMOOTH			; Enable Smooth Shading
	glClearColor 0.0 0.0 0.0 0.0	; Black Background
	glClearDepth 1.0				; Depth Buffer Setup
	glEnable GL_DEPTH_TEST			; Enables Depth Testing
	glDepthFunc GL_LEQUAL			; The Type Of Depth Testing To Do
	glEnable GL_COLOR_MATERIAL 
	glHint GL_PERSPECTIVE_CORRECTION_HINT GL_NICEST
]

display: does [
	glClear GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT	; Clear The Screen And The Depth Buffer
	glLoadIdentity					; Reset The View
	glTranslatef -1.5 0.0 -6.0		; Move Left And Into The Screen
	glRotatef rtri 0.0 1.0 0.0		; Rotate The Pyramid On It's Y Axis

	glBegin GL_TRIANGLES			; Start Drawing The Pyramid

		glColor3f 1.0 0.0 0.0			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Front)
		glColor3f 0.0 1.0 0.0			; Green
		glVertex3f -1.0 -1.0  1.0		; Left Of Triangle (Front)
		glColor3f 0.0 0.0 1.0			; Blue
		glVertex3f  1.0 -1.0  1.0		; Right Of Triangle (Front)

		glColor3f 1.0 0.0 0.0			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Right)
		glColor3f 0.0 0.0 1.0			; Blue
		glVertex3f  1.0 -1.0  1.0		; Left Of Triangle (Right)
		glColor3f 0.0 1.0 0.0			; Green
		glVertex3f  1.0 -1.0  -1.0		; Right Of Triangle (Right)

		glColor3f 1.0 0.0 0.0			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Back)
		glColor3f 0.0 1.0 0.0			; Green
		glVertex3f  1.0 -1.0  -1.0		; Left Of Triangle (Back)
		glColor3f 0.0 0.0 1.0			; Blue
		glVertex3f -1.0 -1.0  -1.0		; Right Of Triangle (Back)

		glColor3f 1.0 0.0 0.0			; Red
		glVertex3f  0.0  1.0  0.0		; Top Of Triangle (Left)
		glColor3f 0.0 0.0 1.0			; Blue
		glVertex3f -1.0 -1.0 -1.0		; Left Of Triangle (Left)
		glColor3f 0.0 1.0 0.0			; Green
		glVertex3f -1.0 -1.0  1.0		; Right Of Triangle (Left)
	glEnd							; Done Drawing The Pyramid
	glLoadIdentity
	glTranslatef 1.5 0.0 -7.0		; Move Right And Into The Screen
	glRotatef rquad 1.0 1.0 1.0		; Rotate The Cube On X, Y & Z

	glBegin GL_QUADS				; Start Drawing The Cube

		glColor3f 0.0 1.0 0.0			; Set The Color To Green
		glVertex3f  1.0  1.0 -1.0		; Top Right Of The Quad (Top)
		glVertex3f -1.0  1.0 -1.0		; Top Left Of The Quad (Top)
		glVertex3f -1.0  1.0  1.0		; Bottom Left Of The Quad (Top)
		glVertex3f  1.0  1.0  1.0		; Bottom Right Of The Quad (Top

		glColor3f 1.0 0.5 0.0			; Set The Color To Orange
		glVertex3f  1.0 -1.0  1.0		; Top Right Of The Quad (Bottom)
		glVertex3f -1.0 -1.0  1.0		; Top Left Of The Quad (Bottom)
		glVertex3f -1.0 -1.0 -1.0		; Bottom Left Of The Quad (Bottom)
		glVertex3f  1.0 -1.0 -1.0		; Bottom Right Of The Quad (Bottom)

		glColor3f 1.0 0.0 0.0			; Set The Color To Red
		glVertex3f  1.0  1.0  1.0		; Top Right Of The Quad (Front)
		glVertex3f -1.0  1.0  1.0		; Top Left Of The Quad (Front)
		glVertex3f -1.0 -1.0  1.0		; Bottom Left Of The Quad (Front)
		glVertex3f  1.0 -1.0  1.0		; Bottom Right Of The Quad (Front)

		glColor3f 1.0 1.0 0.0			; Set The Color To Yellow
		glVertex3f  1.0 -1.0 -1.0		; Bottom Left Of The Quad (Back)
		glVertex3f -1.0 -1.0 -1.0		; Bottom Right Of The Quad (Back)
		glVertex3f -1.0  1.0 -1.0		; Top Right Of The Quad (Back)
		glVertex3f  1.0  1.0 -1.0		; Top Left Of The Quad (Back)

		glColor3f 0.0 0.0 1.0			; Set The Color To Blue
		glVertex3f -1.0  1.0  1.0		; Top Right Of The Quad (Left)
		glVertex3f -1.0  1.0 -1.0		; Top Left Of The Quad (Left)
		glVertex3f -1.0 -1.0 -1.0		; Bottom Left Of The Quad (Left)
		glVertex3f -1.0 -1.0  1.0		; Bottom Right Of The Quad (Left)

		glColor3f 1.0 0.0 1.0		; Set The Color To Violet
		glVertex3f  1.0  1.0 -1.0	; Top Right Of The Quad (Right)
		glVertex3f  1.0  1.0  1.0	; Top Left Of The Quad (Right)
		glVertex3f  1.0 -1.0  1.0	; Bottom Left Of The Quad (Right)
		glVertex3f  1.0 -1.0 -1.0	; Bottom Right Of The Quad (Right)
	glEnd							; Done Drawing The Quad

	rtri: rtri + 0.2				; Increase The Rotation Variable For The Triangle 
	rquad: rquad - 0.15				; Decrease The Rotation Variable For The Quad 

	glutSwapBuffers
]

reshape: func [Width Height] [
	if height = 0 [					; Prevent A Divide By Zero By
		height: 1					; Making Height Equal One
	]

	glViewport 0 0 width height		; Reset The Current Viewport

	glMatrixMode GL_PROJECTION		; Select The Projection Matrix
	glLoadIdentity					; Reset The Projection Matrix

	; Calculate The Aspect Ratio Of The Window
	gluPerspective 45.0 width / height 0.1 100.0

	glMatrixMode GL_MODELVIEW		; Select The Modelview Matrix
	glLoadIdentity
]

keyboard: func [key x y] [			; Create Keyboard Function
	switch key reduce [
		#"^(1b)" [						; When Escape Is Pressed...
			;halt						; Exit The Program
			quit
		]
	]
]

arrow_keys: func [a_keys x y] [		; Create Special Function (required for arrow keys)
	switch a_keys reduce [
		GLUT_KEY_UP [					; When Up Arrow Is Pressed...
			glutFullScreen				; Go Into Full Screen Mode
		]
		GLUT_KEY_DOWN [					; When Down Arrow Is Pressed...
			glutReshapeWindow 500 500	; Go Into A 500 By 500 Window
		]
	]
]

idle: does [glutPostRedisplay]
empty-func: does []

visible: func [vis] [
	either vis = GLUT_VISIBLE [
		glutIdleFunc :idle
	][
		glutIdleFunc :empty-func
	]
]

print "DO NOT CLOSE THE OpenGL WINDOW. PRESS <ESC> OR CLOSE THIS CONSOLE TO REALLY QUIT !"

glutInitDisplayMode GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH
glutInitWindowSize 500 500
glutInitWindowPosition 100 100
glutCreateWindow "NeHe's OpenGL Framework"

InitGL

glutDisplayFunc :display
glutIdleFunc :idle
glutReshapeFunc :reshape
glutKeyboardFunc :keyboard
glutSpecialFunc :arrow_keys
glutVisibilityFunc :visible

glutMainLoop				; The Main Loop

