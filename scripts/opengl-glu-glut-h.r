REBOL [
	title: "OpenGL library interface"
	file: %opengl-glu-glut-h.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 22-04-2013
	version: 0.7.2
	needs: {
		- opengl, glu, glut shared libraries
	}
	comment: {ONLY A FEW FUNCTIONs TESTED !!!! Use example code to test others.
		See REBOL-NOTEs in example code at the end for rebol-specific implementation issues.
		Rebol specific functions start with gl- or glut- .
		Some functions "inspired" by John Niclasen and Cal Dixon
		Example code taken from OpenGL.R Test (c) 2003 Cal Dixon
		Example needs Windows or Linux.
	}
	Purpose: "Code to bind OpenGL, GLU, GLUT shared libraries to Rebol."
	History: [
		0.0.1 [08-11-2011 "First version"]
		0.5.0 [19-11-2011 "Example completed"]
		0.6.0 [22-11-2011 "Added some and improved others glut- functions"]
		0.6.1 [25-11-2011 "Bug fixed event-func"]
		0.6.2 [03-12-2011 "Minor retouches,fixes and additions"]
		0.6.3 [08-12-2011 "Minor retouches"]
		0.6.4 [13-02-2012 "Bug fixed wait time"]
		0.6.5 [05-05-2012 "Fixed double buffer flag"]
		0.6.6 [10-06-2012 "Partially fixed full-screen"]
		0.6.7 [15-09-2012 "Fixed library names (thanks Kaj)"]
		0.7.0 [18-09-2012 "Added custom glut on Linux"]
		0.7.1 [21-09-2012 "Various fixes on Linux"]
		0.7.2 [22-04-2013 "Fixed GLUT callbacks"]
	]
	Category: [library graphics]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'module
		domain: [graphics external-library]
		tested-under: [View 2.7.8.3.1 2.7.8.4.3]
		support: none
		license: none
		see-also: none
	]
]

	;;;
	;;;REBOL-NOTE: use this function to access pointers
	;;;
	int-ptr: does [make struct! [value [integer!]] none]
	dbl-ptr: does [make struct! [value [double]] none]
	coords-ptr: does [make struct! [x [float] y [float] z [float] w [float]] none]
	
	*int: make struct! [[save] ptr [struct! [value [integer!]]]] none
	addr: func [ptr [binary! string!]] [third make struct! [s [string!]] reduce [ptr]]
	get&: func [ptr] [change third *int addr ptr *int/ptr/value]
	&: func [ptr] [ptr: addr ptr to-integer either 'little = get-modes system:// 'endian [head reverse copy ptr][ptr]]

	;;;
	;;;REBOL-NOTE: use this function to map data to a struct!
	;;;
	addr-to-struct: func [
		"returns the given struct! initialized with content of given address"
		addr [integer! ] struct [struct!] /local int-ptr tstruct
		][
		int-ptr: make struct! [value [integer!]] reduce [addr]
		tstruct: make struct! compose/deep/only [ptr [struct! (first struct)]] none
		change third tstruct third int-ptr
		change third struct third tstruct/ptr
		struct
	]

	;;;
	;;;REBOL-NOTE: use this function to convert a block to an initialized struct! (and use eg. as: probe third block-to-struct/floats [1.5 3])
	;;;
	block-to-struct: func [
		"Construct a struct! and initialize it based on given block"
		block [block!] /floats /local spec type n
		] [
		block: copy block
		replace/all block 'none 0
		spec: copy []
		n: 1
		forall block [
			append spec compose/deep/only [(to-word join '. n) [(
				type: type?/word first block
				either all [equal? type 'decimal! floats]['float][type]
			)]]
			n: n + 1
		]
		make struct! spec block
	]

	assign-struct: func [
		"Assign src struct data to dst"
		dst [struct!] src [struct!]
		] [
		change third dst third src
	]


{************************************************************
************************************************************}

	lib: switch/default System/version/4 [
		2 [%libGL.dylib]	;OSX
		3 [%opengl32.dll]	;Windows
	] [%libGL.so.1]

	if not attempt [opengl-lib: load/library lib] [alert rejoin ["" lib " library not found. Quit"] quit]

{************************************************************
**  gl.h
************************************************************}

	GLvoid: integer! ;void             
	GLchar: char! ;char             
	GLenum: integer! ;unsigned int     
	GLboolean: char! ;unsigned char    
	GLbitfield: integer! ;unsigned int     
	GLbyte: char! ;khronos_int8_t   
	;GLshort: short ;short            
	GLint: integer! ;int              
	GLsizei: integer! ;int              
	GLubyte: char! ;khronos_uint8_t  
	;GLushort; short ;unsigned short   
	GLuint: integer! ;unsigned int     
	;GLfloat: float ;khronos_float_t  
	;GLclampf: float ;khronos_float_t  
	;GLfixed: integer! ;khronos_int32_t  
	;GLclampx: integer! ;khronos_int32_t  
	GLclampd: decimal! 
	GLdouble: decimal! 

	{***********************************************************}

	{***********************************************************}

	{ Version }
	GL_VERSION_1_1:                    1

	{ AccumOp }
	GL_ACCUM:                          256
	GL_LOAD:                           257
	GL_RETURN:                         258
	GL_MULT:                           259
	GL_ADD:                            260

	{ AlphaFunction }
	GL_NEVER:                          512
	GL_LESS:                           513
	GL_EQUAL:                          514
	GL_LEQUAL:                         515
	GL_GREATER:                        516
	GL_NOTEQUAL:                       517
	GL_GEQUAL:                         518
	GL_ALWAYS:                         519

	{ AttribMask }
	GL_CURRENT_BIT:                    1
	GL_POINT_BIT:                      2
	GL_LINE_BIT:                       4
	GL_POLYGON_BIT:                    8
	GL_POLYGON_STIPPLE_BIT:            16
	GL_PIXEL_MODE_BIT:                 32
	GL_LIGHTING_BIT:                   64
	GL_FOG_BIT:                        128
	GL_DEPTH_BUFFER_BIT:               256
	GL_ACCUM_BUFFER_BIT:               512
	GL_STENCIL_BUFFER_BIT:             1024
	GL_VIEWPORT_BIT:                   2048
	GL_TRANSFORM_BIT:                  4096
	GL_ENABLE_BIT:                     8192
	GL_COLOR_BUFFER_BIT:               16384
	GL_HINT_BIT:                       32768
	GL_EVAL_BIT:                       65536
	GL_LIST_BIT:                       131072
	GL_TEXTURE_BIT:                    262144
	GL_SCISSOR_BIT:                    524288
	GL_ALL_ATTRIB_BITS:                1048575

	{ BeginMode }
	GL_POINTS:                         0
	GL_LINES:                          1
	GL_LINE_LOOP:                      2
	GL_LINE_STRIP:                     3
	GL_TRIANGLES:                      4
	GL_TRIANGLE_STRIP:                 5
	GL_TRIANGLE_FAN:                   6
	GL_QUADS:                          7
	GL_QUAD_STRIP:                     8
	GL_POLYGON:                        9

	{ BlendingFactorDest }
	GL_ZERO:                           0
	GL_ONE:                            1
	GL_SRC_COLOR:                      768
	GL_ONE_MINUS_SRC_COLOR:            769
	GL_SRC_ALPHA:                      770
	GL_ONE_MINUS_SRC_ALPHA:            771
	GL_DST_ALPHA:                      772
	GL_ONE_MINUS_DST_ALPHA:            773

	{ BlendingFactorSrc }
	{      GL_ZERO }
	{      GL_ONE }
	GL_DST_COLOR:                      774
	GL_ONE_MINUS_DST_COLOR:            775
	GL_SRC_ALPHA_SATURATE:             776
	{      GL_SRC_ALPHA }
	{      GL_ONE_MINUS_SRC_ALPHA }
	{      GL_DST_ALPHA }
	{      GL_ONE_MINUS_DST_ALPHA }

	{ Boolean }
	GL_TRUE:                           1
	GL_FALSE:                          0

	{ ClearBufferMask }
	{      GL_COLOR_BUFFER_BIT }
	{      GL_ACCUM_BUFFER_BIT }
	{      GL_STENCIL_BUFFER_BIT }
	{      GL_DEPTH_BUFFER_BIT }

	{ ClientArrayType }
	{      GL_VERTEX_ARRAY }
	{      GL_NORMAL_ARRAY }
	{      GL_COLOR_ARRAY }
	{      GL_INDEX_ARRAY }
	{      GL_TEXTURE_COORD_ARRAY }
	{      GL_EDGE_FLAG_ARRAY }

	{ ClipPlaneName }
	GL_CLIP_PLANE0:                    12288
	GL_CLIP_PLANE1:                    12289
	GL_CLIP_PLANE2:                    12290
	GL_CLIP_PLANE3:                    12291
	GL_CLIP_PLANE4:                    12292
	GL_CLIP_PLANE5:                    12293

	{ ColorMaterialFace }
	{      GL_FRONT }
	{      GL_BACK }
	{      GL_FRONT_AND_BACK }

	{ ColorMaterialParameter }
	{      GL_AMBIENT }
	{      GL_DIFFUSE }
	{      GL_SPECULAR }
	{      GL_EMISSION }
	{      GL_AMBIENT_AND_DIFFUSE }

	{ ColorPointerType }
	{      GL_BYTE }
	{      GL_UNSIGNED_BYTE }
	{      GL_SHORT }
	{      GL_UNSIGNED_SHORT }
	{      GL_INT }
	{      GL_UNSIGNED_INT }
	{      GL_FLOAT }
	{      GL_DOUBLE }

	{ CullFaceMode }
	{      GL_FRONT }
	{      GL_BACK }
	{      GL_FRONT_AND_BACK }

	{ DataType }
	GL_BYTE:                           5120
	GL_UNSIGNED_BYTE:                  5121
	GL_SHORT:                          5122
	GL_UNSIGNED_SHORT:                 5123
	GL_INT:                            5124
	GL_UNSIGNED_INT:                   5125
	GL_FLOAT:                          5126
	GL_2_BYTES:                        5127
	GL_3_BYTES:                        5128
	GL_4_BYTES:                        5129
	GL_DOUBLE:                         5130

	{ DepthFunction }
	{      GL_NEVER }
	{      GL_LESS }
	{      GL_EQUAL }
	{      GL_LEQUAL }
	{      GL_GREATER }
	{      GL_NOTEQUAL }
	{      GL_GEQUAL }
	{      GL_ALWAYS }

	{ DrawBufferMode }
	GL_NONE:                           0
	GL_FRONT_LEFT:                     1024
	GL_FRONT_RIGHT:                    1025
	GL_BACK_LEFT:                      1026
	GL_BACK_RIGHT:                     1027
	GL_FRONT:                          1028
	GL_BACK:                           1029
	GL_LEFT:                           1030
	GL_RIGHT:                          1031
	GL_FRONT_AND_BACK:                 1032
	GL_AUX0:                           1033
	GL_AUX1:                           1034
	GL_AUX2:                           1035
	GL_AUX3:                           1036

	{ Enable }
	{      GL_FOG }
	{      GL_LIGHTING }
	{      GL_TEXTURE_1D }
	{      GL_TEXTURE_2D }
	{      GL_LINE_STIPPLE }
	{      GL_POLYGON_STIPPLE }
	{      GL_CULL_FACE }
	{      GL_ALPHA_TEST }
	{      GL_BLEND }
	{      GL_INDEX_LOGIC_OP }
	{      GL_COLOR_LOGIC_OP }
	{      GL_DITHER }
	{      GL_STENCIL_TEST }
	{      GL_DEPTH_TEST }
	{      GL_CLIP_PLANE0 }
	{      GL_CLIP_PLANE1 }
	{      GL_CLIP_PLANE2 }
	{      GL_CLIP_PLANE3 }
	{      GL_CLIP_PLANE4 }
	{      GL_CLIP_PLANE5 }
	{      GL_LIGHT0 }
	{      GL_LIGHT1 }
	{      GL_LIGHT2 }
	{      GL_LIGHT3 }
	{      GL_LIGHT4 }
	{      GL_LIGHT5 }
	{      GL_LIGHT6 }
	{      GL_LIGHT7 }
	{      GL_TEXTURE_GEN_S }
	{      GL_TEXTURE_GEN_T }
	{      GL_TEXTURE_GEN_R }
	{      GL_TEXTURE_GEN_Q }
	{      GL_MAP1_VERTEX_3 }
	{      GL_MAP1_VERTEX_4 }
	{      GL_MAP1_COLOR_4 }
	{      GL_MAP1_INDEX }
	{      GL_MAP1_NORMAL }
	{      GL_MAP1_TEXTURE_COORD_1 }
	{      GL_MAP1_TEXTURE_COORD_2 }
	{      GL_MAP1_TEXTURE_COORD_3 }
	{      GL_MAP1_TEXTURE_COORD_4 }
	{      GL_MAP2_VERTEX_3 }
	{      GL_MAP2_VERTEX_4 }
	{      GL_MAP2_COLOR_4 }
	{      GL_MAP2_INDEX }
	{      GL_MAP2_NORMAL }
	{      GL_MAP2_TEXTURE_COORD_1 }
	{      GL_MAP2_TEXTURE_COORD_2 }
	{      GL_MAP2_TEXTURE_COORD_3 }
	{      GL_MAP2_TEXTURE_COORD_4 }
	{      GL_POINT_SMOOTH }
	{      GL_LINE_SMOOTH }
	{      GL_POLYGON_SMOOTH }
	{      GL_SCISSOR_TEST }
	{      GL_COLOR_MATERIAL }
	{      GL_NORMALIZE }
	{      GL_AUTO_NORMAL }
	{      GL_VERTEX_ARRAY }
	{      GL_NORMAL_ARRAY }
	{      GL_COLOR_ARRAY }
	{      GL_INDEX_ARRAY }
	{      GL_TEXTURE_COORD_ARRAY }
	{      GL_EDGE_FLAG_ARRAY }
	{      GL_POLYGON_OFFSET_POINT }
	{      GL_POLYGON_OFFSET_LINE }
	{      GL_POLYGON_OFFSET_FILL }

	{ ErrorCode }
	GL_NO_ERROR:                       0
	GL_INVALID_ENUM:                   1280
	GL_INVALID_VALUE:                  1281
	GL_INVALID_OPERATION:              1282
	GL_STACK_OVERFLOW:                 1283
	GL_STACK_UNDERFLOW:                1284
	GL_OUT_OF_MEMORY:                  1285

	{ FeedBackMode }
	GL_2D:                             1536
	GL_3D:                             1537
	GL_3D_COLOR:                       1538
	GL_3D_COLOR_TEXTURE:               1539
	GL_4D_COLOR_TEXTURE:               1540

	{ FeedBackToken }
	GL_PASS_THROUGH_TOKEN:             1792
	GL_POINT_TOKEN:                    1793
	GL_LINE_TOKEN:                     1794
	GL_POLYGON_TOKEN:                  1795
	GL_BITMAP_TOKEN:                   1796
	GL_DRAW_PIXEL_TOKEN:               1797
	GL_COPY_PIXEL_TOKEN:               1798
	GL_LINE_RESET_TOKEN:               1799

	{ FogMode }
	{      GL_LINEAR }
	GL_EXP:                            2048
	GL_EXP2:                           2049


	{ FogParameter }
	{      GL_FOG_COLOR }
	{      GL_FOG_DENSITY }
	{      GL_FOG_END }
	{      GL_FOG_INDEX }
	{      GL_FOG_MODE }
	{      GL_FOG_START }

	{ FrontFaceDirection }
	GL_CW:                             2304
	GL_CCW:                            2305

	{ GetMapTarget }
	GL_COEFF:                          2560
	GL_ORDER:                          2561
	GL_DOMAIN:                         2562

	{ GetPixelMap }
	{      GL_PIXEL_MAP_I_TO_I }
	{      GL_PIXEL_MAP_S_TO_S }
	{      GL_PIXEL_MAP_I_TO_R }
	{      GL_PIXEL_MAP_I_TO_G }
	{      GL_PIXEL_MAP_I_TO_B }
	{      GL_PIXEL_MAP_I_TO_A }
	{      GL_PIXEL_MAP_R_TO_R }
	{      GL_PIXEL_MAP_G_TO_G }
	{      GL_PIXEL_MAP_B_TO_B }
	{      GL_PIXEL_MAP_A_TO_A }

	{ GetPointerTarget }
	{      GL_VERTEX_ARRAY_POINTER }
	{      GL_NORMAL_ARRAY_POINTER }
	{      GL_COLOR_ARRAY_POINTER }
	{      GL_INDEX_ARRAY_POINTER }
	{      GL_TEXTURE_COORD_ARRAY_POINTER }
	{      GL_EDGE_FLAG_ARRAY_POINTER }

	{ GetTarget }
	GL_CURRENT_COLOR:                  2816
	GL_CURRENT_INDEX:                  2817
	GL_CURRENT_NORMAL:                 2818
	GL_CURRENT_TEXTURE_COORDS:         2819
	GL_CURRENT_RASTER_COLOR:           2820
	GL_CURRENT_RASTER_INDEX:           2821
	GL_CURRENT_RASTER_TEXTURE_COORDS:  2822
	GL_CURRENT_RASTER_POSITION:        2823
	GL_CURRENT_RASTER_POSITION_VALID:  2824
	GL_CURRENT_RASTER_DISTANCE:        2825
	GL_POINT_SMOOTH:                   2832
	GL_POINT_SIZE:                     2833
	GL_POINT_SIZE_RANGE:               2834
	GL_POINT_SIZE_GRANULARITY:         2835
	GL_LINE_SMOOTH:                    2848
	GL_LINE_WIDTH:                     2849
	GL_LINE_WIDTH_RANGE:               2850
	GL_LINE_WIDTH_GRANULARITY:         2851
	GL_LINE_STIPPLE:                   2852
	GL_LINE_STIPPLE_PATTERN:           2853
	GL_LINE_STIPPLE_REPEAT:            2854
	GL_LIST_MODE:                      2864
	GL_MAX_LIST_NESTING:               2865
	GL_LIST_BASE:                      2866
	GL_LIST_INDEX:                     2867
	GL_POLYGON_MODE:                   2880
	GL_POLYGON_SMOOTH:                 2881
	GL_POLYGON_STIPPLE:                2882
	GL_EDGE_FLAG:                      2883
	GL_CULL_FACE:                      2884
	GL_CULL_FACE_MODE:                 2885
	GL_FRONT_FACE:                     2886
	GL_LIGHTING:                       2896
	GL_LIGHT_MODEL_LOCAL_VIEWER:       2897
	GL_LIGHT_MODEL_TWO_SIDE:           2898
	GL_LIGHT_MODEL_AMBIENT:            2899
	GL_SHADE_MODEL:                    2900
	GL_COLOR_MATERIAL_FACE:            2901
	GL_COLOR_MATERIAL_PARAMETER:       2902
	GL_COLOR_MATERIAL:                 2903
	GL_FOG:                            2912
	GL_FOG_INDEX:                      2913
	GL_FOG_DENSITY:                    2914
	GL_FOG_START:                      2915
	GL_FOG_END:                        2916
	GL_FOG_MODE:                       2917
	GL_FOG_COLOR:                      2918
	GL_DEPTH_RANGE:                    2928
	GL_DEPTH_TEST:                     2929
	GL_DEPTH_WRITEMASK:                2930
	GL_DEPTH_CLEAR_VALUE:              2931
	GL_DEPTH_FUNC:                     2932
	GL_ACCUM_CLEAR_VALUE:              2944
	GL_STENCIL_TEST:                   2960
	GL_STENCIL_CLEAR_VALUE:            2961
	GL_STENCIL_FUNC:                   2962
	GL_STENCIL_VALUE_MASK:             2963
	GL_STENCIL_FAIL:                   2964
	GL_STENCIL_PASS_DEPTH_FAIL:        2965
	GL_STENCIL_PASS_DEPTH_PASS:        2966
	GL_STENCIL_REF:                    2967
	GL_STENCIL_WRITEMASK:              2968
	GL_MATRIX_MODE:                    2976
	GL_NORMALIZE:                      2977
	GL_VIEWPORT:                       2978
	GL_MODELVIEW_STACK_DEPTH:          2979
	GL_PROJECTION_STACK_DEPTH:         2980
	GL_TEXTURE_STACK_DEPTH:            2981
	GL_MODELVIEW_MATRIX:               2982
	GL_PROJECTION_MATRIX:              2983
	GL_TEXTURE_MATRIX:                 2984
	GL_ATTRIB_STACK_DEPTH:             2992
	GL_CLIENT_ATTRIB_STACK_DEPTH:      2993
	GL_ALPHA_TEST:                     3008
	GL_ALPHA_TEST_FUNC:                3009
	GL_ALPHA_TEST_REF:                 3010
	GL_DITHER:                         3024
	GL_BLEND_DST:                      3040
	GL_BLEND_SRC:                      3041
	GL_BLEND:                          3042
	GL_LOGIC_OP_MODE:                  3056
	GL_INDEX_LOGIC_OP:                 3057
	GL_COLOR_LOGIC_OP:                 3058
	GL_AUX_BUFFERS:                    3072
	GL_DRAW_BUFFER:                    3073
	GL_READ_BUFFER:                    3074
	GL_SCISSOR_BOX:                    3088
	GL_SCISSOR_TEST:                   3089
	GL_INDEX_CLEAR_VALUE:              3104
	GL_INDEX_WRITEMASK:                3105
	GL_COLOR_CLEAR_VALUE:              3106
	GL_COLOR_WRITEMASK:                3107
	GL_INDEX_MODE:                     3120
	GL_RGBA_MODE:                      3121
	GL_DOUBLEBUFFER:                   3122
	GL_STEREO:                         3123
	GL_RENDER_MODE:                    3136
	GL_PERSPECTIVE_CORRECTION_HINT:    3152
	GL_POINT_SMOOTH_HINT:              3153
	GL_LINE_SMOOTH_HINT:               3154
	GL_POLYGON_SMOOTH_HINT:            3155
	GL_FOG_HINT:                       3156
	GL_TEXTURE_GEN_S:                  3168
	GL_TEXTURE_GEN_T:                  3169
	GL_TEXTURE_GEN_R:                  3170
	GL_TEXTURE_GEN_Q:                  3171
	GL_PIXEL_MAP_I_TO_I:               3184
	GL_PIXEL_MAP_S_TO_S:               3185
	GL_PIXEL_MAP_I_TO_R:               3186
	GL_PIXEL_MAP_I_TO_G:               3187
	GL_PIXEL_MAP_I_TO_B:               3188
	GL_PIXEL_MAP_I_TO_A:               3189
	GL_PIXEL_MAP_R_TO_R:               3190
	GL_PIXEL_MAP_G_TO_G:               3191
	GL_PIXEL_MAP_B_TO_B:               3192
	GL_PIXEL_MAP_A_TO_A:               3193
	GL_PIXEL_MAP_I_TO_I_SIZE:          3248
	GL_PIXEL_MAP_S_TO_S_SIZE:          3249
	GL_PIXEL_MAP_I_TO_R_SIZE:          3250
	GL_PIXEL_MAP_I_TO_G_SIZE:          3251
	GL_PIXEL_MAP_I_TO_B_SIZE:          3252
	GL_PIXEL_MAP_I_TO_A_SIZE:          3253
	GL_PIXEL_MAP_R_TO_R_SIZE:          3254
	GL_PIXEL_MAP_G_TO_G_SIZE:          3255
	GL_PIXEL_MAP_B_TO_B_SIZE:          3256
	GL_PIXEL_MAP_A_TO_A_SIZE:          3257
	GL_UNPACK_SWAP_BYTES:              3312
	GL_UNPACK_LSB_FIRST:               3313
	GL_UNPACK_ROW_LENGTH:              3314
	GL_UNPACK_SKIP_ROWS:               3315
	GL_UNPACK_SKIP_PIXELS:             3316
	GL_UNPACK_ALIGNMENT:               3317
	GL_PACK_SWAP_BYTES:                3328
	GL_PACK_LSB_FIRST:                 3329
	GL_PACK_ROW_LENGTH:                3330
	GL_PACK_SKIP_ROWS:                 3331
	GL_PACK_SKIP_PIXELS:               3332
	GL_PACK_ALIGNMENT:                 3333
	GL_MAP_COLOR:                      3344
	GL_MAP_STENCIL:                    3345
	GL_INDEX_SHIFT:                    3346
	GL_INDEX_OFFSET:                   3347
	GL_RED_SCALE:                      3348
	GL_RED_BIAS:                       3349
	GL_ZOOM_X:                         3350
	GL_ZOOM_Y:                         3351
	GL_GREEN_SCALE:                    3352
	GL_GREEN_BIAS:                     3353
	GL_BLUE_SCALE:                     3354
	GL_BLUE_BIAS:                      3355
	GL_ALPHA_SCALE:                    3356
	GL_ALPHA_BIAS:                     3357
	GL_DEPTH_SCALE:                    3358
	GL_DEPTH_BIAS:                     3359
	GL_MAX_EVAL_ORDER:                 3376
	GL_MAX_LIGHTS:                     3377
	GL_MAX_CLIP_PLANES:                3378
	GL_MAX_TEXTURE_SIZE:               3379
	GL_MAX_PIXEL_MAP_TABLE:            3380
	GL_MAX_ATTRIB_STACK_DEPTH:         3381
	GL_MAX_MODELVIEW_STACK_DEPTH:      3382
	GL_MAX_NAME_STACK_DEPTH:           3383
	GL_MAX_PROJECTION_STACK_DEPTH:     3384
	GL_MAX_TEXTURE_STACK_DEPTH:        3385
	GL_MAX_VIEWPORT_DIMS:              3386
	GL_MAX_CLIENT_ATTRIB_STACK_DEPTH:  3387
	GL_SUBPIXEL_BITS:                  3408
	GL_INDEX_BITS:                     3409
	GL_RED_BITS:                       3410
	GL_GREEN_BITS:                     3411
	GL_BLUE_BITS:                      3412
	GL_ALPHA_BITS:                     3413
	GL_DEPTH_BITS:                     3414
	GL_STENCIL_BITS:                   3415
	GL_ACCUM_RED_BITS:                 3416
	GL_ACCUM_GREEN_BITS:               3417
	GL_ACCUM_BLUE_BITS:                3418
	GL_ACCUM_ALPHA_BITS:               3419
	GL_NAME_STACK_DEPTH:               3440
	GL_AUTO_NORMAL:                    3456
	GL_MAP1_COLOR_4:                   3472
	GL_MAP1_INDEX:                     3473
	GL_MAP1_NORMAL:                    3474
	GL_MAP1_TEXTURE_COORD_1:           3475
	GL_MAP1_TEXTURE_COORD_2:           3476
	GL_MAP1_TEXTURE_COORD_3:           3477
	GL_MAP1_TEXTURE_COORD_4:           3478
	GL_MAP1_VERTEX_3:                  3479
	GL_MAP1_VERTEX_4:                  3480
	GL_MAP2_COLOR_4:                   3504
	GL_MAP2_INDEX:                     3505
	GL_MAP2_NORMAL:                    3506
	GL_MAP2_TEXTURE_COORD_1:           3507
	GL_MAP2_TEXTURE_COORD_2:           3508
	GL_MAP2_TEXTURE_COORD_3:           3509
	GL_MAP2_TEXTURE_COORD_4:           3510
	GL_MAP2_VERTEX_3:                  3511
	GL_MAP2_VERTEX_4:                  3512
	GL_MAP1_GRID_DOMAIN:               3536
	GL_MAP1_GRID_SEGMENTS:             3537
	GL_MAP2_GRID_DOMAIN:               3538
	GL_MAP2_GRID_SEGMENTS:             3539
	GL_TEXTURE_1D:                     3552
	GL_TEXTURE_2D:                     3553
	GL_FEEDBACK_BUFFER_POINTER:        3568
	GL_FEEDBACK_BUFFER_SIZE:           3569
	GL_FEEDBACK_BUFFER_TYPE:           3570
	GL_SELECTION_BUFFER_POINTER:       3571
	GL_SELECTION_BUFFER_SIZE:          3572
	{      GL_TEXTURE_BINDING_1D }
	{      GL_TEXTURE_BINDING_2D }
	{      GL_VERTEX_ARRAY }
	{      GL_NORMAL_ARRAY }
	{      GL_COLOR_ARRAY }
	{      GL_INDEX_ARRAY }
	{      GL_TEXTURE_COORD_ARRAY }
	{      GL_EDGE_FLAG_ARRAY }
	{      GL_VERTEX_ARRAY_SIZE }
	{      GL_VERTEX_ARRAY_TYPE }
	{      GL_VERTEX_ARRAY_STRIDE }
	{      GL_NORMAL_ARRAY_TYPE }
	{      GL_NORMAL_ARRAY_STRIDE }
	{      GL_COLOR_ARRAY_SIZE }
	{      GL_COLOR_ARRAY_TYPE }
	{      GL_COLOR_ARRAY_STRIDE }
	{      GL_INDEX_ARRAY_TYPE }
	{      GL_INDEX_ARRAY_STRIDE }
	{      GL_TEXTURE_COORD_ARRAY_SIZE }
	{      GL_TEXTURE_COORD_ARRAY_TYPE }
	{      GL_TEXTURE_COORD_ARRAY_STRIDE }
	{      GL_EDGE_FLAG_ARRAY_STRIDE }
	{      GL_POLYGON_OFFSET_FACTOR }
	{      GL_POLYGON_OFFSET_UNITS }

	{ GetTextureParameter }
	{      GL_TEXTURE_MAG_FILTER }
	{      GL_TEXTURE_MIN_FILTER }
	{      GL_TEXTURE_WRAP_S }
	{      GL_TEXTURE_WRAP_T }
	GL_TEXTURE_WIDTH:                  4096
	GL_TEXTURE_HEIGHT:                 4097
	GL_TEXTURE_INTERNAL_FORMAT:        4099
	GL_TEXTURE_BORDER_COLOR:           4100
	GL_TEXTURE_BORDER:                 4101
	{      GL_TEXTURE_RED_SIZE }
	{      GL_TEXTURE_GREEN_SIZE }
	{      GL_TEXTURE_BLUE_SIZE }
	{      GL_TEXTURE_ALPHA_SIZE }
	{      GL_TEXTURE_LUMINANCE_SIZE }
	{      GL_TEXTURE_INTENSITY_SIZE }
	{      GL_TEXTURE_PRIORITY }
	{      GL_TEXTURE_RESIDENT }

	{ HintMode }
	GL_DONT_CARE:                      4352
	GL_FASTEST:                        4353
	GL_NICEST:                         4354

	{ HintTarget }
	{      GL_PERSPECTIVE_CORRECTION_HINT }
	{      GL_POINT_SMOOTH_HINT }
	{      GL_LINE_SMOOTH_HINT }
	{      GL_POLYGON_SMOOTH_HINT }
	{      GL_FOG_HINT }
	{      GL_PHONG_HINT }

	{ IndexPointerType }
	{      GL_SHORT }
	{      GL_INT }
	{      GL_FLOAT }
	{      GL_DOUBLE }

	{ LightModelParameter }
	{      GL_LIGHT_MODEL_AMBIENT }
	{      GL_LIGHT_MODEL_LOCAL_VIEWER }
	{      GL_LIGHT_MODEL_TWO_SIDE }

	{ LightName }
	GL_LIGHT0:                         16384
	GL_LIGHT1:                         16385
	GL_LIGHT2:                         16386
	GL_LIGHT3:                         16387
	GL_LIGHT4:                         16388
	GL_LIGHT5:                         16389
	GL_LIGHT6:                         16390
	GL_LIGHT7:                         16391

	{ LightParameter }
	GL_AMBIENT:                        4608
	GL_DIFFUSE:                        4609
	GL_SPECULAR:                       4610
	GL_POSITION:                       4611
	GL_SPOT_DIRECTION:                 4612
	GL_SPOT_EXPONENT:                  4613
	GL_SPOT_CUTOFF:                    4614
	GL_CONSTANT_ATTENUATION:           4615
	GL_LINEAR_ATTENUATION:             4616
	GL_QUADRATIC_ATTENUATION:          4617

	{ InterleavedArrays }
	{      GL_V2F }
	{      GL_V3F }
	{      GL_C4UB_V2F }
	{      GL_C4UB_V3F }
	{      GL_C3F_V3F }
	{      GL_N3F_V3F }
	{      GL_C4F_N3F_V3F }
	{      GL_T2F_V3F }
	{      GL_T4F_V4F }
	{      GL_T2F_C4UB_V3F }
	{      GL_T2F_C3F_V3F }
	{      GL_T2F_N3F_V3F }
	{      GL_T2F_C4F_N3F_V3F }
	{      GL_T4F_C4F_N3F_V4F }

	{ ListMode }
	GL_COMPILE:                        4864
	GL_COMPILE_AND_EXECUTE:            4865

	{ ListNameType }
	{      GL_BYTE }
	{      GL_UNSIGNED_BYTE }
	{      GL_SHORT }
	{      GL_UNSIGNED_SHORT }
	{      GL_INT }
	{      GL_UNSIGNED_INT }
	{      GL_FLOAT }
	{      GL_2_BYTES }
	{      GL_3_BYTES }
	{      GL_4_BYTES }

	{ LogicOp }
	GL_CLEAR:                          5376
	GL_AND:                            5377
	GL_AND_REVERSE:                    5378
	GL_COPY:                           5379
	GL_AND_INVERTED:                   5380
	GL_NOOP:                           5381
	GL_XOR:                            5382
	GL_OR:                             5383
	GL_NOR:                            5384
	GL_EQUIV:                          5385
	GL_INVERT:                         5386
	GL_OR_REVERSE:                     5387
	GL_COPY_INVERTED:                  5388
	GL_OR_INVERTED:                    5389
	GL_NAND:                           5390
	GL_SET:                            5391

	{ MapTarget }
	{      GL_MAP1_COLOR_4 }
	{      GL_MAP1_INDEX }
	{      GL_MAP1_NORMAL }
	{      GL_MAP1_TEXTURE_COORD_1 }
	{      GL_MAP1_TEXTURE_COORD_2 }
	{      GL_MAP1_TEXTURE_COORD_3 }
	{      GL_MAP1_TEXTURE_COORD_4 }
	{      GL_MAP1_VERTEX_3 }
	{      GL_MAP1_VERTEX_4 }
	{      GL_MAP2_COLOR_4 }
	{      GL_MAP2_INDEX }
	{      GL_MAP2_NORMAL }
	{      GL_MAP2_TEXTURE_COORD_1 }
	{      GL_MAP2_TEXTURE_COORD_2 }
	{      GL_MAP2_TEXTURE_COORD_3 }
	{      GL_MAP2_TEXTURE_COORD_4 }
	{      GL_MAP2_VERTEX_3 }
	{      GL_MAP2_VERTEX_4 }

	{ MaterialFace }
	{      GL_FRONT }
	{      GL_BACK }
	{      GL_FRONT_AND_BACK }

	{ MaterialParameter }
	GL_EMISSION:                       5632
	GL_SHININESS:                      5633
	GL_AMBIENT_AND_DIFFUSE:            5634
	GL_COLOR_INDEXES:                  5635
	{      GL_AMBIENT }
	{      GL_DIFFUSE }
	{      GL_SPECULAR }

	{ MatrixMode }
	GL_MODELVIEW:                      5888
	GL_PROJECTION:                     5889
	GL_TEXTURE:                        5890

	{ MeshMode1 }
	{      GL_POINT }
	{      GL_LINE }

	{ MeshMode2 }
	{      GL_POINT }
	{      GL_LINE }
	{      GL_FILL }

	{ NormalPointerType }
	{      GL_BYTE }
	{      GL_SHORT }
	{      GL_INT }
	{      GL_FLOAT }
	{      GL_DOUBLE }

	{ PixelCopyType }
	GL_COLOR:                          6144
	GL_DEPTH:                          6145
	GL_STENCIL:                        6146

	{ PixelFormat }
	GL_COLOR_INDEX:                    6400
	GL_STENCIL_INDEX:                  6401
	GL_DEPTH_COMPONENT:                6402
	GL_RED:                            6403
	GL_GREEN:                          6404
	GL_BLUE:                           6405
	GL_ALPHA:                          6406
	GL_RGB:                            6407
	GL_RGBA:                           6408
	GL_LUMINANCE:                      6409
	GL_LUMINANCE_ALPHA:                6410

	{ PixelMap }
	{      GL_PIXEL_MAP_I_TO_I }
	{      GL_PIXEL_MAP_S_TO_S }
	{      GL_PIXEL_MAP_I_TO_R }
	{      GL_PIXEL_MAP_I_TO_G }
	{      GL_PIXEL_MAP_I_TO_B }
	{      GL_PIXEL_MAP_I_TO_A }
	{      GL_PIXEL_MAP_R_TO_R }
	{      GL_PIXEL_MAP_G_TO_G }
	{      GL_PIXEL_MAP_B_TO_B }
	{      GL_PIXEL_MAP_A_TO_A }

	{ PixelStore }
	{      GL_UNPACK_SWAP_BYTES }
	{      GL_UNPACK_LSB_FIRST }
	{      GL_UNPACK_ROW_LENGTH }
	{      GL_UNPACK_SKIP_ROWS }
	{      GL_UNPACK_SKIP_PIXELS }
	{      GL_UNPACK_ALIGNMENT }
	{      GL_PACK_SWAP_BYTES }
	{      GL_PACK_LSB_FIRST }
	{      GL_PACK_ROW_LENGTH }
	{      GL_PACK_SKIP_ROWS }
	{      GL_PACK_SKIP_PIXELS }
	{      GL_PACK_ALIGNMENT }

	{ PixelTransfer }
	{      GL_MAP_COLOR }
	{      GL_MAP_STENCIL }
	{      GL_INDEX_SHIFT }
	{      GL_INDEX_OFFSET }
	{      GL_RED_SCALE }
	{      GL_RED_BIAS }
	{      GL_GREEN_SCALE }
	{      GL_GREEN_BIAS }
	{      GL_BLUE_SCALE }
	{      GL_BLUE_BIAS }
	{      GL_ALPHA_SCALE }
	{      GL_ALPHA_BIAS }
	{      GL_DEPTH_SCALE }
	{      GL_DEPTH_BIAS }

	{ PixelType }
	GL_BITMAP:                         6656
	{      GL_BYTE }
	{      GL_UNSIGNED_BYTE }
	{      GL_SHORT }
	{      GL_UNSIGNED_SHORT }
	{      GL_INT }
	{      GL_UNSIGNED_INT }
	{      GL_FLOAT }

	{ PolygonMode }
	GL_POINT:                          6912
	GL_LINE:                           6913
	GL_FILL:                           6914

	{ ReadBufferMode }
	{      GL_FRONT_LEFT }
	{      GL_FRONT_RIGHT }
	{      GL_BACK_LEFT }
	{      GL_BACK_RIGHT }
	{      GL_FRONT }
	{      GL_BACK }
	{      GL_LEFT }
	{      GL_RIGHT }
	{      GL_AUX0 }
	{      GL_AUX1 }
	{      GL_AUX2 }
	{      GL_AUX3 }

	{ RenderingMode }
	GL_RENDER:                         7168
	GL_FEEDBACK:                       7169
	GL_SELECT:                         7170

	{ ShadingModel }
	GL_FLAT:                           7424
	GL_SMOOTH:                         7425


	{ StencilFunction }
	{      GL_NEVER }
	{      GL_LESS }
	{      GL_EQUAL }
	{      GL_LEQUAL }
	{      GL_GREATER }
	{      GL_NOTEQUAL }
	{      GL_GEQUAL }
	{      GL_ALWAYS }

	{ StencilOp }
	{      GL_ZERO }
	GL_KEEP:                           7680
	GL_REPLACE:                        7681
	GL_INCR:                           7682
	GL_DECR:                           7683
	{      GL_INVERT }

	{ StringName }
	GL_VENDOR:                         7936
	GL_RENDERER:                       7937
	GL_VERSION:                        7938
	GL_EXTENSIONS:                     7939

	{ TextureCoordName }
	GL_S:                              8192
	GL_T:                              8193
	GL_R:                              8194
	GL_Q:                              8195

	{ TexCoordPointerType }
	{      GL_SHORT }
	{      GL_INT }
	{      GL_FLOAT }
	{      GL_DOUBLE }

	{ TextureEnvMode }
	GL_MODULATE:                       8448
	GL_DECAL:                          8449
	{      GL_BLEND }
	{      GL_REPLACE }

	{ TextureEnvParameter }
	GL_TEXTURE_ENV_MODE:               8704
	GL_TEXTURE_ENV_COLOR:              8705

	{ TextureEnvTarget }
	GL_TEXTURE_ENV:                    8960

	{ TextureGenMode }
	GL_EYE_LINEAR:                     9216
	GL_OBJECT_LINEAR:                  9217
	GL_SPHERE_MAP:                     9218

	{ TextureGenParameter }
	GL_TEXTURE_GEN_MODE:               9472
	GL_OBJECT_PLANE:                   9473
	GL_EYE_PLANE:                      9474

	{ TextureMagFilter }
	GL_NEAREST:                        9728
	GL_LINEAR:                         9729

	{ TextureMinFilter }
	{      GL_NEAREST }
	{      GL_LINEAR }
	GL_NEAREST_MIPMAP_NEAREST:         9984
	GL_LINEAR_MIPMAP_NEAREST:          9985
	GL_NEAREST_MIPMAP_LINEAR:          9986
	GL_LINEAR_MIPMAP_LINEAR:           9987

	{ TextureParameterName }
	GL_TEXTURE_MAG_FILTER:             10240
	GL_TEXTURE_MIN_FILTER:             10241
	GL_TEXTURE_WRAP_S:                 10242
	GL_TEXTURE_WRAP_T:                 10243
	{      GL_TEXTURE_BORDER_COLOR }
	{      GL_TEXTURE_PRIORITY }

	{ TextureTarget }
	{      GL_TEXTURE_1D }
	{      GL_TEXTURE_2D }
	{      GL_PROXY_TEXTURE_1D }
	{      GL_PROXY_TEXTURE_2D }

	{ TextureWrapMode }
	GL_CLAMP:                          10496
	GL_REPEAT:                         10497

	{ VertexPointerType }
	{      GL_SHORT }
	{      GL_INT }
	{      GL_FLOAT }
	{      GL_DOUBLE }

	{ ClientAttribMask }
	GL_CLIENT_PIXEL_STORE_BIT:         1
	GL_CLIENT_VERTEX_ARRAY_BIT:        2
	GL_CLIENT_ALL_ATTRIB_BITS:         -1

	{ polygon_offset }
	GL_POLYGON_OFFSET_FACTOR:          32824
	GL_POLYGON_OFFSET_UNITS:           10752
	GL_POLYGON_OFFSET_POINT:           10753
	GL_POLYGON_OFFSET_LINE:            10754
	GL_POLYGON_OFFSET_FILL:            32823

	{ texture }
	GL_ALPHA4:                         32827
	GL_ALPHA8:                         32828
	GL_ALPHA12:                        32829
	GL_ALPHA16:                        32830
	GL_LUMINANCE4:                     32831
	GL_LUMINANCE8:                     32832
	GL_LUMINANCE12:                    32833
	GL_LUMINANCE16:                    32834
	GL_LUMINANCE4_ALPHA4:              32835
	GL_LUMINANCE6_ALPHA2:              32836
	GL_LUMINANCE8_ALPHA8:              32837
	GL_LUMINANCE12_ALPHA4:             32838
	GL_LUMINANCE12_ALPHA12:            32839
	GL_LUMINANCE16_ALPHA16:            32840
	GL_INTENSITY:                      32841
	GL_INTENSITY4:                     32842
	GL_INTENSITY8:                     32843
	GL_INTENSITY12:                    32844
	GL_INTENSITY16:                    32845
	GL_R3_G3_B2:                       10768
	GL_RGB4:                           32847
	GL_RGB5:                           32848
	GL_RGB8:                           32849
	GL_RGB10:                          32850
	GL_RGB12:                          32851
	GL_RGB16:                          32852
	GL_RGBA2:                          32853
	GL_RGBA4:                          32854
	GL_RGB5_A1:                        32855
	GL_RGBA8:                          32856
	GL_RGB10_A2:                       32857
	GL_RGBA12:                         32858
	GL_RGBA16:                         32859
	GL_TEXTURE_RED_SIZE:               32860
	GL_TEXTURE_GREEN_SIZE:             32861
	GL_TEXTURE_BLUE_SIZE:              32862
	GL_TEXTURE_ALPHA_SIZE:             32863
	GL_TEXTURE_LUMINANCE_SIZE:         32864
	GL_TEXTURE_INTENSITY_SIZE:         32865
	GL_PROXY_TEXTURE_1D:               32867
	GL_PROXY_TEXTURE_2D:               32868

	{ texture_object }
	GL_TEXTURE_PRIORITY:               32870
	GL_TEXTURE_RESIDENT:               32871
	GL_TEXTURE_BINDING_1D:             32872
	GL_TEXTURE_BINDING_2D:             32873

	{ vertex_array }
	GL_VERTEX_ARRAY:                   32884
	GL_NORMAL_ARRAY:                   32885
	GL_COLOR_ARRAY:                    32886
	GL_INDEX_ARRAY:                    32887
	GL_TEXTURE_COORD_ARRAY:            32888
	GL_EDGE_FLAG_ARRAY:                32889
	GL_VERTEX_ARRAY_SIZE:              32890
	GL_VERTEX_ARRAY_TYPE:              32891
	GL_VERTEX_ARRAY_STRIDE:            32892
	GL_NORMAL_ARRAY_TYPE:              32894
	GL_NORMAL_ARRAY_STRIDE:            32895
	GL_COLOR_ARRAY_SIZE:               32897
	GL_COLOR_ARRAY_TYPE:               32898
	GL_COLOR_ARRAY_STRIDE:             32899
	GL_INDEX_ARRAY_TYPE:               32901
	GL_INDEX_ARRAY_STRIDE:             32902
	GL_TEXTURE_COORD_ARRAY_SIZE:       32904
	GL_TEXTURE_COORD_ARRAY_TYPE:       32905
	GL_TEXTURE_COORD_ARRAY_STRIDE:     32906
	GL_EDGE_FLAG_ARRAY_STRIDE:         32908
	GL_VERTEX_ARRAY_POINTER:           32910
	GL_NORMAL_ARRAY_POINTER:           32911
	GL_COLOR_ARRAY_POINTER:            32912
	GL_INDEX_ARRAY_POINTER:            32913
	GL_TEXTURE_COORD_ARRAY_POINTER:    32914
	GL_EDGE_FLAG_ARRAY_POINTER:        32915
	GL_V2F:                            10784
	GL_V3F:                            10785
	GL_C4UB_V2F:                       10786
	GL_C4UB_V3F:                       10787
	GL_C3F_V3F:                        10788
	GL_N3F_V3F:                        10789
	GL_C4F_N3F_V3F:                    10790
	GL_T2F_V3F:                        10791
	GL_T4F_V4F:                        10792
	GL_T2F_C4UB_V3F:                   10793
	GL_T2F_C3F_V3F:                    10794
	GL_T2F_N3F_V3F:                    10795
	GL_T2F_C4F_N3F_V3F:                10796
	GL_T4F_C4F_N3F_V4F:                10797

	{ Extensions }
	GL_EXT_vertex_array:               1
	GL_EXT_bgra:                       1
	GL_EXT_paletted_texture:           1
	GL_WIN_swap_hint:                  1
	GL_WIN_draw_range_elements:        1
	; GL_WIN_phong_shading:              1
	; GL_WIN_specular_fog:               1

	{ EXT_vertex_array }
	GL_VERTEX_ARRAY_EXT:               32884
	GL_NORMAL_ARRAY_EXT:               32885
	GL_COLOR_ARRAY_EXT:                32886
	GL_INDEX_ARRAY_EXT:                32887
	GL_TEXTURE_COORD_ARRAY_EXT:        32888
	GL_EDGE_FLAG_ARRAY_EXT:            32889
	GL_VERTEX_ARRAY_SIZE_EXT:          32890
	GL_VERTEX_ARRAY_TYPE_EXT:          32891
	GL_VERTEX_ARRAY_STRIDE_EXT:        32892
	GL_VERTEX_ARRAY_COUNT_EXT:         32893
	GL_NORMAL_ARRAY_TYPE_EXT:          32894
	GL_NORMAL_ARRAY_STRIDE_EXT:        32895
	GL_NORMAL_ARRAY_COUNT_EXT:         32896
	GL_COLOR_ARRAY_SIZE_EXT:           32897
	GL_COLOR_ARRAY_TYPE_EXT:           32898
	GL_COLOR_ARRAY_STRIDE_EXT:         32899
	GL_COLOR_ARRAY_COUNT_EXT:          32900
	GL_INDEX_ARRAY_TYPE_EXT:           32901
	GL_INDEX_ARRAY_STRIDE_EXT:         32902
	GL_INDEX_ARRAY_COUNT_EXT:          32903
	GL_TEXTURE_COORD_ARRAY_SIZE_EXT:   32904
	GL_TEXTURE_COORD_ARRAY_TYPE_EXT:   32905
	GL_TEXTURE_COORD_ARRAY_STRIDE_EXT: 32906
	GL_TEXTURE_COORD_ARRAY_COUNT_EXT:  32907
	GL_EDGE_FLAG_ARRAY_STRIDE_EXT:     32908
	GL_EDGE_FLAG_ARRAY_COUNT_EXT:      32909
	GL_VERTEX_ARRAY_POINTER_EXT:       32910
	GL_NORMAL_ARRAY_POINTER_EXT:       32911
	GL_COLOR_ARRAY_POINTER_EXT:        32912
	GL_INDEX_ARRAY_POINTER_EXT:        32913
	GL_TEXTURE_COORD_ARRAY_POINTER_EXT: 32914
	GL_EDGE_FLAG_ARRAY_POINTER_EXT:    32915
	GL_DOUBLE_EXT:                     GL_DOUBLE

	{ EXT_bgra }
	GL_BGR_EXT:                        32992
	GL_BGRA_EXT:                       32993

	{ EXT_paletted_texture }

	{ These must match the GL_COLOR_TABLE_*_SGI enumerants }
	GL_COLOR_TABLE_FORMAT_EXT:         32984
	GL_COLOR_TABLE_WIDTH_EXT:          32985
	GL_COLOR_TABLE_RED_SIZE_EXT:       32986
	GL_COLOR_TABLE_GREEN_SIZE_EXT:     32987
	GL_COLOR_TABLE_BLUE_SIZE_EXT:      32988
	GL_COLOR_TABLE_ALPHA_SIZE_EXT:     32989
	GL_COLOR_TABLE_LUMINANCE_SIZE_EXT: 32990
	GL_COLOR_TABLE_INTENSITY_SIZE_EXT: 32991

	GL_COLOR_INDEX1_EXT:               32994
	GL_COLOR_INDEX2_EXT:               32995
	GL_COLOR_INDEX4_EXT:               32996
	GL_COLOR_INDEX8_EXT:               32997
	GL_COLOR_INDEX12_EXT:              32998
	GL_COLOR_INDEX16_EXT:              32999

	{ WIN_draw_range_elements }
	GL_MAX_ELEMENTS_VERTICES_WIN:      33000
	GL_MAX_ELEMENTS_INDICES_WIN:       33001

	{ WIN_phong_shading }
	GL_PHONG_WIN:                      33002 
	GL_PHONG_HINT_WIN:                 33003 

	{ WIN_specular_fog }
	GL_FOG_SPECULAR_TEXTURE_WIN:       33004

	{ For compatibility with OpenGL v1.0 }
	GL_LOGIC_OP: GL_INDEX_LOGIC_OP
	GL_TEXTURE_COMPONENTS: GL_TEXTURE_INTERNAL_FORMAT

	{***********************************************************}

	glAccum: make routine! [ op [GLenum] value [float] ] opengl-lib "glAccum" 
	glAlphaFunc: make routine! [ func [GLenum] ref [float] ] opengl-lib "glAlphaFunc" 
	glAreTexturesResident: make routine! [ n [GLsizei] textures [integer!] residences [integer!] return: [GLboolean] ] opengl-lib "glAreTexturesResident" 
	glArrayElement: make routine! [ i [GLint] ] opengl-lib "glArrayElement" 
	glBegin: make routine! [ mode [GLenum] ] opengl-lib "glBegin" 
	glBindTexture: make routine! [ target [GLenum] texture [binary!] ] opengl-lib "glBindTexture" 
	glBitmap: make routine! [ width [GLsizei] height [GLsizei] xorig [float] yorig [float] xmove [float] ymove [float] bitmap [binary!] ] opengl-lib "glBitmap" 
	glBlendFunc: make routine! [ sfactor [GLenum] dfactor [GLenum] ] opengl-lib "glBlendFunc" 
	glCallList: make routine! [ list [GLuint] ] opengl-lib "glCallList" 
	glCallLists: make routine! [ n [GLsizei] type [GLenum] lists [integer!] ] opengl-lib "glCallLists" 
	glClear: make routine! [ mask [GLbitfield] ] opengl-lib "glClear" 
	glClearAccum: make routine! [ red [float] green [float] blue [float] alpha [float] ] opengl-lib "glClearAccum" 
	glClearColor: make routine! [ red [float] green [float] blue [float] alpha [float] ] opengl-lib "glClearColor" 
	glClearDepth: make routine! [ depth [GLclampd] ] opengl-lib "glClearDepth" 
	glClearIndex: make routine! [ c [float] ] opengl-lib "glClearIndex" 
	glClearStencil: make routine! [ s [GLint] ] opengl-lib "glClearStencil" 
	glClipPlane: make routine! [ plane [GLenum] equation [binary!] ] opengl-lib "glClipPlane" 
	gl-ClipPlane: func [ plane [GLenum] equation [block!] /local bin] [
		bin: third block-to-struct equation ;MUST assing to a local variable on Linux (!?)
		glClipPlane plane bin
	]

	;gl-Color: func [color [tuple!]] [either color/4 [glColor4ub to-char color/1 to-char color/2 to-char color/3 to-char color/4] [glColor3ub to-char color/1 to-char color/2 to-char color/3]]
	gl-Color: func [color [tuple!]] [either color/4 [glColor4ubv to-binary color] [glColor3ubv to-binary color]]

	glColor3: glColor3d: make routine! [ red [GLdouble] green [GLdouble] blue [GLdouble] ] opengl-lib "glColor3d" 
	glColor3f: make routine! [ red [float] green [float] blue [float] ] opengl-lib "glColor3f" 
	glColor3ub: make routine! [ red [GLubyte] green [GLubyte] blue [GLubyte] ] opengl-lib "glColor3ub" 
	glColor3ubv: make routine! [ v [binary!] ] opengl-lib "glColor3ubv" 
	glColor4: glColor4d: make routine! [ red [GLdouble] green [GLdouble] blue [GLdouble] alpha [GLdouble] ] opengl-lib "glColor4d" 
	glColor4f: make routine! [ red [float] green [float] blue [float] alpha [float] ] opengl-lib "glColor4f" 
	glColor4ub: make routine! [ red [GLubyte] green [GLubyte] blue [GLubyte] alpha [GLubyte] ] opengl-lib "glColor4ub" 
	glColor4ubv: make routine! [ v [binary!] ] opengl-lib "glColor4ubv" 
	{
	glColor3b: make routine! [ red [GLbyte] green [GLbyte] blue [GLbyte] ] opengl-lib "glColor3b" 
	glColor3bv: make routine! [ v [binary!] ] opengl-lib "glColor3bv" 
	glColor3dv: make routine! [ v [integer!] ] opengl-lib "glColor3dv" 
	glColor3fv: make routine! [ v [integer!] ] opengl-lib "glColor3fv" 
	glColor3i: make routine! [ red [GLint] green [GLint] blue [GLint] ] opengl-lib "glColor3i" 
	glColor3iv: make routine! [ v [integer!] ] opengl-lib "glColor3iv" 
	glColor3s: make routine! [ red [short] green [short] blue [short] ] opengl-lib "glColor3s" 
	glColor3sv: make routine! [ v [integer!] ] opengl-lib "glColor3sv" 
	glColor3ui: make routine! [ red [GLuint] green [GLuint] blue [GLuint] ] opengl-lib "glColor3ui" 
	glColor3uiv: make routine! [ v [integer!] ] opengl-lib "glColor3uiv" 
	glColor3us: make routine! [ red [short] green [short] blue [short] ] opengl-lib "glColor3us" 
	glColor3usv: make routine! [ v [integer!] ] opengl-lib "glColor3usv" 
	glColor4b: make routine! [ red [GLbyte] green [GLbyte] blue [GLbyte] alpha [GLbyte] ] opengl-lib "glColor4b" 
	glColor4bv: make routine! [ v [integer!] ] opengl-lib "glColor4bv" 
	glColor4dv: make routine! [ v [integer!] ] opengl-lib "glColor4dv" 
	glColor4fv: make routine! [ v [integer!] ] opengl-lib "glColor4fv" 
	glColor4i: make routine! [ red [GLint] green [GLint] blue [GLint] alpha [GLint] ] opengl-lib "glColor4i" 
	glColor4iv: make routine! [ v [integer!] ] opengl-lib "glColor4iv" 
	glColor4s: make routine! [ red [short] green [short] blue [short] alpha [short] ] opengl-lib "glColor4s" 
	glColor4sv: make routine! [ v [integer!] ] opengl-lib "glColor4sv" 
	glColor4ui: make routine! [ red [GLuint] green [GLuint] blue [GLuint] alpha [GLuint] ] opengl-lib "glColor4ui" 
	glColor4uiv: make routine! [ v [integer!] ] opengl-lib "glColor4uiv" 
	glColor4us: make routine! [ red [short] green [short] blue [short] alpha [short] ] opengl-lib "glColor4us" 
	glColor4usv: make routine! [ v [integer!] ] opengl-lib "glColor4usv" 
	}
	glColorMask: make routine! [ red [GLboolean] green [GLboolean] blue [GLboolean] alpha [GLboolean] ] opengl-lib "glColorMask" 
	glColorMaterial: make routine! [ face [GLenum] mode [GLenum] ] opengl-lib "glColorMaterial" 
	glColorPointer: make routine! [ size [GLint] type [GLenum] stride [GLsizei] pointer [integer!] ] opengl-lib "glColorPointer" 
	glCopyPixels: make routine! [ x [GLint] y [GLint] width [GLsizei] height [GLsizei] type [GLenum] ] opengl-lib "glCopyPixels" 
	glCopyTexImage1D: make routine! [ target [GLenum] level [GLint] internalFormat [GLenum] x [GLint] y [GLint] width [GLsizei] border [GLint] ] opengl-lib "glCopyTexImage1D" 
	glCopyTexImage2D: make routine! [ target [GLenum] level [GLint] internalFormat [GLenum] x [GLint] y [GLint] width [GLsizei] height [GLsizei] border [GLint] ] opengl-lib "glCopyTexImage2D" 
	glCopyTexSubImage1D: make routine! [ target [GLenum] level [GLint] xoffset [GLint] x [GLint] y [GLint] width [GLsizei] ] opengl-lib "glCopyTexSubImage1D" 
	glCopyTexSubImage2D: make routine! [ target [GLenum] level [GLint] xoffset [GLint] yoffset [GLint] x [GLint] y [GLint] width [GLsizei] height [GLsizei] ] opengl-lib "glCopyTexSubImage2D" 
	glCullFace: make routine! [ mode [GLenum] ] opengl-lib "glCullFace" 
	glDeleteLists: make routine! [ list [GLuint] range [GLsizei] ] opengl-lib "glDeleteLists" 
	glDeleteTextures: make routine! [ n [GLsizei] textures [integer!] ] opengl-lib "glDeleteTextures" 
	glDepthFunc: make routine! [ func [GLenum] ] opengl-lib "glDepthFunc" 
	glDepthMask: make routine! [ flag [GLboolean] ] opengl-lib "glDepthMask" 
	glDepthRange: make routine! [ zNear [GLclampd] zFar [GLclampd] ] opengl-lib "glDepthRange" 
	glDisable: make routine! [ cap [GLenum] ] opengl-lib "glDisable" 
	gl-Disable: func [/cull_face /fog /lighting /alpha_test /depth_test /blend] [
		case/all [
			cull_face [glDisable GL_CULL_FACE]
			fog [glDisable GL_FOG]
			lighting [glDisable GL_LIGHTING]
			alpha_test [glDisable GL_ALPHA_TEST]
			depth_test [glDisable GL_DEPTH_TEST]
			blend [glDisable GL_BLEND]
		]
	]
	glDisableClientState: make routine! [ array [GLenum] ] opengl-lib "glDisableClientState" 
	glDrawArrays: make routine! [ mode [GLenum] first [GLint] count [GLsizei] ] opengl-lib "glDrawArrays" 
	glDrawBuffer: make routine! [ mode [GLenum] ] opengl-lib "glDrawBuffer" 
	glDrawElements: make routine! [ mode [GLenum] count [GLsizei] type [GLenum] indices [binary!] ] opengl-lib "glDrawElements" 
	gl-DrawElements: func [ mode [GLenum] count [GLsizei] indices [block!] /local bin] [
		bin: third block-to-struct/floats indices ;MUST assing to a local variable in Linux (!?)
		glDrawElements mode count GL_UNSIGNED_INT bin
	]
	glDrawPixels: make routine! [ width [GLsizei] height [GLsizei] format [GLenum] type [GLenum] pixels [binary!] ] opengl-lib "glDrawPixels" 
	glEdgeFlag: make routine! [ flag [GLboolean] ] opengl-lib "glEdgeFlag" 
	glEdgeFlagPointer: make routine! [ stride [GLsizei] pointer [integer!] ] opengl-lib "glEdgeFlagPointer" 
	glEdgeFlagv: make routine! [ flag [integer!] ] opengl-lib "glEdgeFlagv" 
	glEnable: make routine! [ cap [GLenum] ] opengl-lib "glEnable" 
	gl-Enable: func [/cull_face /fog /lighting /alpha_test /depth_test /blend] [
		case/all [
			cull_face [glEnable GL_CULL_FACE]
			fog [glEnable GL_FOG]
			lighting [glEnable GL_LIGHTING]
			alpha_test [glEnable GL_ALPHA_TEST]
			depth_test [glEnable GL_DEPTH_TEST]
			blend [glEnable GL_BLEND]
		]
	]
	glEnableClientState: make routine! [ array [GLenum] ] opengl-lib "glEnableClientState" 
	glEnd: make routine! [ ] opengl-lib "glEnd" 
	glEndList: make routine! [ ] opengl-lib "glEndList" 
	glEvalCoord1d: make routine! [ u [GLdouble] ] opengl-lib "glEvalCoord1d" 
	glEvalCoord1dv: make routine! [ u [integer!] ] opengl-lib "glEvalCoord1dv" 
	glEvalCoord1f: make routine! [ u [float] ] opengl-lib "glEvalCoord1f" 
	glEvalCoord1fv: make routine! [ u [integer!] ] opengl-lib "glEvalCoord1fv" 
	glEvalCoord2d: make routine! [ u [GLdouble] v [GLdouble] ] opengl-lib "glEvalCoord2d" 
	glEvalCoord2dv: make routine! [ u [integer!] ] opengl-lib "glEvalCoord2dv" 
	glEvalCoord2f: make routine! [ u [float] v [float] ] opengl-lib "glEvalCoord2f" 
	glEvalCoord2fv: make routine! [ u [integer!] ] opengl-lib "glEvalCoord2fv" 
	glEvalMesh1: make routine! [ mode [GLenum] i1 [GLint] i2 [GLint] ] opengl-lib "glEvalMesh1" 
	glEvalMesh2: make routine! [ mode [GLenum] i1 [GLint] i2 [GLint] j1 [GLint] j2 [GLint] ] opengl-lib "glEvalMesh2" 
	glEvalPoint1: make routine! [ i [GLint] ] opengl-lib "glEvalPoint1" 
	glEvalPoint2: make routine! [ i [GLint] j [GLint] ] opengl-lib "glEvalPoint2" 
	glFeedbackBuffer: make routine! [ size [GLsizei] type [GLenum] buffer [integer!] ] opengl-lib "glFeedbackBuffer" 
	glFinish: make routine! [ ] opengl-lib "glFinish" 
	glFlush: make routine! [ ] opengl-lib "glFlush" 
	glFogf: make routine! [ pname [GLenum] param [float] ] opengl-lib "glFogf" 
	glFogfv: make routine! [ pname [GLenum] params [integer!] ] opengl-lib "glFogfv" 
	glFogi: make routine! [ pname [GLenum] param [GLint] ] opengl-lib "glFogi" 
	glFogiv: make routine! [ pname [GLenum] params [integer!] ] opengl-lib "glFogiv" 
	glFrontFace: make routine! [ mode [GLenum] ] opengl-lib "glFrontFace" 
	glFrustum: make routine! [ left [GLdouble] right [GLdouble] bottom [GLdouble] top [GLdouble] zNear [GLdouble] zFar [GLdouble] ] opengl-lib "glFrustum" 
	glGenLists: make routine! [ range [GLsizei] return: [GLuint] ] opengl-lib "glGenLists" 
	glGenTextures: make routine! [ n [GLsizei] textures [binary!] ] opengl-lib "glGenTextures" 
	glGetBooleanv: make routine! [ pname [GLenum] params [integer!] ] opengl-lib "glGetBooleanv" 
	glGetClipPlane: make routine! [ plane [GLenum] equation [integer!] ] opengl-lib "glGetClipPlane" 
	glGetDoublev: make routine! [ pname [GLenum] params [struct! []] ] opengl-lib "glGetDoublev" 
	glGetError: make routine! [ return: [GLenum] ] opengl-lib "glGetError" 
	glGetFloatv: make routine! [ pname [GLenum] params [struct! []] ] opengl-lib "glGetFloatv" 
	glGetIntegerv: make routine! [ pname [GLenum] params [struct! []] ] opengl-lib "glGetIntegerv" 
	glGetLightfv: make routine! [ light [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetLightfv" 
	glGetLightiv: make routine! [ light [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetLightiv" 
	glGetMapdv: make routine! [ target [GLenum] query [GLenum] v [integer!] ] opengl-lib "glGetMapdv" 
	glGetMapfv: make routine! [ target [GLenum] query [GLenum] v [integer!] ] opengl-lib "glGetMapfv" 
	glGetMapiv: make routine! [ target [GLenum] query [GLenum] v [integer!] ] opengl-lib "glGetMapiv" 
	glGetMaterialfv: make routine! [ face [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetMaterialfv" 
	glGetMaterialiv: make routine! [ face [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetMaterialiv" 
	glGetPixelMapfv: make routine! [ map [GLenum] values [integer!] ] opengl-lib "glGetPixelMapfv" 
	glGetPixelMapuiv: make routine! [ map [GLenum] values [integer!] ] opengl-lib "glGetPixelMapuiv" 
	glGetPixelMapusv: make routine! [ map [GLenum] values [integer!] ] opengl-lib "glGetPixelMapusv" 
	glGetPointerv: make routine! [ pname [GLenum] params [struct! []] ] opengl-lib "glGetPointerv" 
	glGetPolygonStipple: make routine! [ mask [integer!] ] opengl-lib "glGetPolygonStipple" 
	glGetString: make routine! [ name [GLenum] return: [string!] ] opengl-lib "glGetString" 
	glGetTexEnvfv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexEnvfv" 
	glGetTexEnviv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexEnviv" 
	glGetTexGendv: make routine! [ coord [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexGendv" 
	glGetTexGenfv: make routine! [ coord [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexGenfv" 
	glGetTexGeniv: make routine! [ coord [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexGeniv" 
	glGetTexImage: make routine! [ target [GLenum] level [GLint] format [GLenum] type [GLenum] pixels [integer!] ] opengl-lib "glGetTexImage" 
	glGetTexLevelParameterfv: make routine! [ target [GLenum] level [GLint] pname [GLenum] params [integer!] ] opengl-lib "glGetTexLevelParameterfv" 
	glGetTexLevelParameteriv: make routine! [ target [GLenum] level [GLint] pname [GLenum] params [integer!] ] opengl-lib "glGetTexLevelParameteriv" 
	glGetTexParameterfv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexParameterfv" 
	glGetTexParameteriv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glGetTexParameteriv" 
	glHint: make routine! [ target [GLenum] mode [GLenum] ] opengl-lib "glHint" 
	glIndexMask: make routine! [ mask [GLuint] ] opengl-lib "glIndexMask" 
	glIndexPointer: make routine! [ type [GLenum] stride [GLsizei] pointer [integer!] ] opengl-lib "glIndexPointer" 
	glIndexd: make routine! [ c [GLdouble] ] opengl-lib "glIndexd" 
	glIndexdv: make routine! [ c [integer!] ] opengl-lib "glIndexdv" 
	glIndexf: make routine! [ c [float] ] opengl-lib "glIndexf" 
	glIndexfv: make routine! [ c [integer!] ] opengl-lib "glIndexfv" 
	glIndexi: make routine! [ c [GLint] ] opengl-lib "glIndexi" 
	glIndexiv: make routine! [ c [integer!] ] opengl-lib "glIndexiv" 
	glIndexs: make routine! [ c [short] ] opengl-lib "glIndexs" 
	glIndexsv: make routine! [ c [integer!] ] opengl-lib "glIndexsv" 
	glIndexub: make routine! [ c [GLubyte] ] opengl-lib "glIndexub" 
	glIndexubv: make routine! [ c [integer!] ] opengl-lib "glIndexubv" 
	glInitNames: make routine! [ ] opengl-lib "glInitNames" 
	glInterleavedArrays: make routine! [ format [GLenum] stride [GLsizei] pointer [integer!] ] opengl-lib "glInterleavedArrays" 
	glIsEnabled: make routine! [ cap [GLenum] return: [GLboolean] ] opengl-lib "glIsEnabled" 
	glIsList: make routine! [ list [GLuint] return: [GLboolean] ] opengl-lib "glIsList" 
	glIsTexture: make routine! [ texture [GLuint] return: [GLboolean] ] opengl-lib "glIsTexture" 
	glLightModelf: make routine! [ pname [GLenum] param [float] ] opengl-lib "glLightModelf" 
	glLightModelfv: make routine! [ pname [GLenum] params [integer!] ] opengl-lib "glLightModelfv" 
	glLightModeli: make routine! [ pname [GLenum] param [GLint] ] opengl-lib "glLightModeli" 
	glLightModeliv: make routine! [ pname [GLenum] params [integer!] ] opengl-lib "glLightModeliv" 
	glLightf: make routine! [ light [GLenum] pname [GLenum] param [float] ] opengl-lib "glLightf" 
	glLightfv: make routine! [ light [integer!] pname [integer!] params [binary!] ] opengl-lib "glLightfv" 
	gl-Lightfv: func [ light [integer!] pname [integer!] params [block!] /local bin] [
		bin: third block-to-struct/floats params ;MUST assing to a local variable in Linux (!?)
		glLightfv light pname bin
	]
	glLighti: make routine! [ light [GLenum] pname [GLenum] param [GLint] ] opengl-lib "glLighti" 
	glLightiv: make routine! [ light [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glLightiv" 
	glLineStipple: make routine! [ factor [GLint] pattern [short] ] opengl-lib "glLineStipple" 
	glLineWidth: make routine! [ width [float] ] opengl-lib "glLineWidth" 
	glListBase: make routine! [ base [GLuint] ] opengl-lib "glListBase" 
	glLoadIdentity: make routine! [ ] opengl-lib "glLoadIdentity" 
	glLoadMatrixd: make routine! [ m [integer!] ] opengl-lib "glLoadMatrixd" 
	glLoadMatrixf: make routine! [ m [integer!] ] opengl-lib "glLoadMatrixf" 
	glLoadName: make routine! [ name [GLuint] ] opengl-lib "glLoadName" 
	glLogicOp: make routine! [ opcode [GLenum] ] opengl-lib "glLogicOp" 
	glMap1d: make routine! [ target [GLenum] u1 [GLdouble] u2 [GLdouble] stride [GLint] order [GLint] points [integer!] ] opengl-lib "glMap1d" 
	glMap1f: make routine! [ target [GLenum] u1 [float] u2 [float] stride [GLint] order [GLint] points [integer!] ] opengl-lib "glMap1f" 
	glMap2d: make routine! [ target [GLenum] u1 [GLdouble] u2 [GLdouble] ustride [GLint] uorder [GLint] v1 [GLdouble] v2 [GLdouble] vstride [GLint] vorder [GLint] points [integer!] ] opengl-lib "glMap2d" 
	glMap2f: make routine! [ target [GLenum] u1 [float] u2 [float] ustride [GLint] uorder [GLint] v1 [float] v2 [float] vstride [GLint] vorder [GLint] points [integer!] ] opengl-lib "glMap2f" 
	glMapGrid1d: make routine! [ un [GLint] u1 [GLdouble] u2 [GLdouble] ] opengl-lib "glMapGrid1d" 
	glMapGrid1f: make routine! [ un [GLint] u1 [float] u2 [float] ] opengl-lib "glMapGrid1f" 
	glMapGrid2d: make routine! [ un [GLint] u1 [GLdouble] u2 [GLdouble] vn [GLint] v1 [GLdouble] v2 [GLdouble] ] opengl-lib "glMapGrid2d" 
	glMapGrid2f: make routine! [ un [GLint] u1 [float] u2 [float] vn [GLint] v1 [float] v2 [float] ] opengl-lib "glMapGrid2f" 
	glMaterialf: make routine! [ face [GLenum] pname [GLenum] param [float] ] opengl-lib "glMaterialf" 
	glMaterialfv: make routine! [ face [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glMaterialfv" 
	glMateriali: make routine! [ face [GLenum] pname [GLenum] param [GLint] ] opengl-lib "glMateriali" 
	glMaterialiv: make routine! [ face [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glMaterialiv" 
	glMatrixMode: make routine! [ mode [GLenum] ] opengl-lib "glMatrixMode" 
	glMultMatrixd: make routine! [ m [integer!] ] opengl-lib "glMultMatrixd" 
	glMultMatrixf: make routine! [ m [integer!] ] opengl-lib "glMultMatrixf" 
	glNewList: make routine! [ list [GLuint] mode [GLenum] ] opengl-lib "glNewList" 
	glNormal3b: make routine! [ nx [GLbyte] ny [GLbyte] nz [GLbyte] ] opengl-lib "glNormal3b" 
	glNormal3bv: make routine! [ v [integer!] ] opengl-lib "glNormal3bv" 
	glNormal3d: make routine! [ nx [GLdouble] ny [GLdouble] nz [GLdouble] ] opengl-lib "glNormal3d" 
	glNormal3dv: make routine! [ v [integer!] ] opengl-lib "glNormal3dv" 
	glNormal3f: make routine! [ nx [float] ny [float] nz [float] ] opengl-lib "glNormal3f" 
	glNormal3fv: make routine! [ v [integer!] ] opengl-lib "glNormal3fv" 
	glNormal3i: make routine! [ nx [GLint] ny [GLint] nz [GLint] ] opengl-lib "glNormal3i" 
	glNormal3iv: make routine! [ v [integer!] ] opengl-lib "glNormal3iv" 
	glNormal3s: make routine! [ nx [short] ny [short] nz [short] ] opengl-lib "glNormal3s" 
	glNormal3sv: make routine! [ v [integer!] ] opengl-lib "glNormal3sv" 
	glNormalPointer: make routine! [ type [GLenum] stride [GLsizei] pointer [integer!] ] opengl-lib "glNormalPointer" 
	glOrtho: make routine! [ left [GLdouble] right [GLdouble] bottom [GLdouble] top [GLdouble] zNear [GLdouble] zFar [GLdouble] ] opengl-lib "glOrtho" 
	glPassThrough: make routine! [ token [float] ] opengl-lib "glPassThrough" 
	glPixelMapfv: make routine! [ map [GLenum] mapsize [GLsizei] values [integer!] ] opengl-lib "glPixelMapfv" 
	glPixelMapuiv: make routine! [ map [GLenum] mapsize [GLsizei] values [integer!] ] opengl-lib "glPixelMapuiv" 
	glPixelMapusv: make routine! [ map [GLenum] mapsize [GLsizei] values [integer!] ] opengl-lib "glPixelMapusv" 
	glPixelStoref: make routine! [ pname [GLenum] param [float] ] opengl-lib "glPixelStoref" 
	glPixelStorei: make routine! [ pname [GLenum] param [GLint] ] opengl-lib "glPixelStorei" 
	glPixelTransferf: make routine! [ pname [GLenum] param [float] ] opengl-lib "glPixelTransferf" 
	glPixelTransferi: make routine! [ pname [GLenum] param [GLint] ] opengl-lib "glPixelTransferi" 
	glPixelZoom: make routine! [ xfactor [float] yfactor [float] ] opengl-lib "glPixelZoom" 
	glPointSize: make routine! [ size [float] ] opengl-lib "glPointSize" 
	glPolygonMode: make routine! [ face [GLenum] mode [GLenum] ] opengl-lib "glPolygonMode" 
	glPolygonOffset: make routine! [ factor [float] units [float] ] opengl-lib "glPolygonOffset" 
	glPolygonStipple: make routine! [ mask [integer!] ] opengl-lib "glPolygonStipple" 
	glPopAttrib: make routine! [ ] opengl-lib "glPopAttrib" 
	glPopClientAttrib: make routine! [ ] opengl-lib "glPopClientAttrib" 
	glPopMatrix: make routine! [ ] opengl-lib "glPopMatrix" 
	glPopName: make routine! [ ] opengl-lib "glPopName" 
	glPrioritizeTextures: make routine! [ n [GLsizei] textures [integer!] priorities [integer!] ] opengl-lib "glPrioritizeTextures" 
	glPushAttrib: make routine! [ mask [GLbitfield] ] opengl-lib "glPushAttrib" 
	glPushClientAttrib: make routine! [ mask [GLbitfield] ] opengl-lib "glPushClientAttrib" 
	glPushMatrix: make routine! [ ] opengl-lib "glPushMatrix" 
	glPushName: make routine! [ name [GLuint] ] opengl-lib "glPushName" 
	glRasterPos2d: make routine! [ x [GLdouble] y [GLdouble] ] opengl-lib "glRasterPos2d" 
	glRasterPos2dv: make routine! [ v [integer!] ] opengl-lib "glRasterPos2dv" 
	glRasterPos2f: make routine! [ x [float] y [float] ] opengl-lib "glRasterPos2f" 
	glRasterPos2fv: make routine! [ v [integer!] ] opengl-lib "glRasterPos2fv" 
	glRasterPos2i: make routine! [ x [GLint] y [GLint] ] opengl-lib "glRasterPos2i" 
	glRasterPos2iv: make routine! [ v [integer!] ] opengl-lib "glRasterPos2iv" 
	glRasterPos2s: make routine! [ x [short] y [short] ] opengl-lib "glRasterPos2s" 
	glRasterPos2sv: make routine! [ v [integer!] ] opengl-lib "glRasterPos2sv" 
	glRasterPos3d: make routine! [ x [GLdouble] y [GLdouble] z [GLdouble] ] opengl-lib "glRasterPos3d" 
	glRasterPos3dv: make routine! [ v [integer!] ] opengl-lib "glRasterPos3dv" 
	glRasterPos3f: make routine! [ x [float] y [float] z [float] ] opengl-lib "glRasterPos3f" 
	glRasterPos3fv: make routine! [ v [integer!] ] opengl-lib "glRasterPos3fv" 
	glRasterPos3i: make routine! [ x [GLint] y [GLint] z [GLint] ] opengl-lib "glRasterPos3i" 
	glRasterPos3iv: make routine! [ v [integer!] ] opengl-lib "glRasterPos3iv" 
	glRasterPos3s: make routine! [ x [short] y [short] z [short] ] opengl-lib "glRasterPos3s" 
	glRasterPos3sv: make routine! [ v [integer!] ] opengl-lib "glRasterPos3sv" 
	glRasterPos4d: make routine! [ x [GLdouble] y [GLdouble] z [GLdouble] w [GLdouble] ] opengl-lib "glRasterPos4d" 
	glRasterPos4dv: make routine! [ v [integer!] ] opengl-lib "glRasterPos4dv" 
	glRasterPos4f: make routine! [ x [float] y [float] z [float] w [float] ] opengl-lib "glRasterPos4f" 
	glRasterPos4fv: make routine! [ v [integer!] ] opengl-lib "glRasterPos4fv" 
	glRasterPos4i: make routine! [ x [GLint] y [GLint] z [GLint] w [GLint] ] opengl-lib "glRasterPos4i" 
	glRasterPos4iv: make routine! [ v [integer!] ] opengl-lib "glRasterPos4iv" 
	glRasterPos4s: make routine! [ x [short] y [short] z [short] w [short] ] opengl-lib "glRasterPos4s" 
	glRasterPos4sv: make routine! [ v [integer!] ] opengl-lib "glRasterPos4sv" 
	glReadBuffer: make routine! [ mode [GLenum] ] opengl-lib "glReadBuffer" 
	glReadPixels: make routine! [ x [GLint] y [GLint] width [GLsizei] height [GLsizei] format [GLenum] type [GLenum] pixels [binary!] ] opengl-lib "glReadPixels" 
	glRect: glRectd: make routine! [ x1 [GLdouble] y1 [GLdouble] x2 [GLdouble] y2 [GLdouble] ] opengl-lib "glRectd" 
	glRectdv: make routine! [ v1 [integer!] v2 [integer!] ] opengl-lib "glRectdv" 
	glRectf: make routine! [ x1 [float] y1 [float] x2 [float] y2 [float] ] opengl-lib "glRectf" 
	glRectfv: make routine! [ v1 [integer!] v2 [integer!] ] opengl-lib "glRectfv" 
	glRecti: make routine! [ x1 [GLint] y1 [GLint] x2 [GLint] y2 [GLint] ] opengl-lib "glRecti" 
	glRectiv: make routine! [ v1 [integer!] v2 [integer!] ] opengl-lib "glRectiv" 
	glRects: make routine! [ x1 [short] y1 [short] x2 [short] y2 [short] ] opengl-lib "glRects" 
	glRectsv: make routine! [ v1 [integer!] v2 [integer!] ] opengl-lib "glRectsv" 
	glRenderMode: make routine! [ mode [GLenum] return: [GLint] ] opengl-lib "glRenderMode" 
	glRotate: glRotated: make routine! [ angle [GLdouble] x [GLdouble] y [GLdouble] z [GLdouble] ] opengl-lib "glRotated" 
	glRotatef: make routine! [ angle [float] x [float] y [float] z [float] ] opengl-lib "glRotatef" 
	glScale: glScaled: make routine! [ x [GLdouble] y [GLdouble] z [GLdouble] ] opengl-lib "glScaled" 
	glScalef: make routine! [ x [float] y [float] z [float] ] opengl-lib "glScalef" 
	glScissor: make routine! [ x [GLint] y [GLint] width [GLsizei] height [GLsizei] ] opengl-lib "glScissor" 
	glSelectBuffer: make routine! [ size [GLsizei] buffer [integer!] ] opengl-lib "glSelectBuffer" 
	glShadeModel: make routine! [ mode [GLenum] ] opengl-lib "glShadeModel" 
	glStencilFunc: make routine! [ func [GLenum] ref [GLint] mask [GLuint] ] opengl-lib "glStencilFunc" 
	glStencilMask: make routine! [ mask [GLuint] ] opengl-lib "glStencilMask" 
	glStencilOp: make routine! [ fail [GLenum] zfail [GLenum] zpass [GLenum] ] opengl-lib "glStencilOp" 
	glTexCoord1d: make routine! [ s [GLdouble] ] opengl-lib "glTexCoord1d" 
	glTexCoord1dv: make routine! [ v [integer!] ] opengl-lib "glTexCoord1dv" 
	glTexCoord1f: make routine! [ s [float] ] opengl-lib "glTexCoord1f" 
	glTexCoord1fv: make routine! [ v [integer!] ] opengl-lib "glTexCoord1fv" 
	glTexCoord1i: make routine! [ s [GLint] ] opengl-lib "glTexCoord1i" 
	glTexCoord1iv: make routine! [ v [integer!] ] opengl-lib "glTexCoord1iv" 
	glTexCoord1s: make routine! [ s [short] ] opengl-lib "glTexCoord1s" 
	glTexCoord1sv: make routine! [ v [integer!] ] opengl-lib "glTexCoord1sv" 
	glTexCoord2d: make routine! [ s [GLdouble] t [GLdouble] ] opengl-lib "glTexCoord2d" 
	glTexCoord2dv: make routine! [ v [integer!] ] opengl-lib "glTexCoord2dv" 
	glTexCoord2f: make routine! [ s [float] t [float] ] opengl-lib "glTexCoord2f" 
	glTexCoord2fv: make routine! [ v [integer!] ] opengl-lib "glTexCoord2fv" 
	glTexCoord2i: make routine! [ s [GLint] t [GLint] ] opengl-lib "glTexCoord2i" 
	glTexCoord2iv: make routine! [ v [integer!] ] opengl-lib "glTexCoord2iv" 
	glTexCoord2s: make routine! [ s [short] t [short] ] opengl-lib "glTexCoord2s" 
	glTexCoord2sv: make routine! [ v [integer!] ] opengl-lib "glTexCoord2sv" 
	glTexCoord3d: make routine! [ s [GLdouble] t [GLdouble] r [GLdouble] ] opengl-lib "glTexCoord3d" 
	glTexCoord3dv: make routine! [ v [integer!] ] opengl-lib "glTexCoord3dv" 
	glTexCoord3f: make routine! [ s [float] t [float] r [float] ] opengl-lib "glTexCoord3f" 
	glTexCoord3fv: make routine! [ v [integer!] ] opengl-lib "glTexCoord3fv" 
	glTexCoord3i: make routine! [ s [GLint] t [GLint] r [GLint] ] opengl-lib "glTexCoord3i" 
	glTexCoord3iv: make routine! [ v [integer!] ] opengl-lib "glTexCoord3iv" 
	glTexCoord3s: make routine! [ s [short] t [short] r [short] ] opengl-lib "glTexCoord3s" 
	glTexCoord3sv: make routine! [ v [integer!] ] opengl-lib "glTexCoord3sv" 
	glTexCoord4d: make routine! [ s [GLdouble] t [GLdouble] r [GLdouble] q [GLdouble] ] opengl-lib "glTexCoord4d" 
	glTexCoord4dv: make routine! [ v [integer!] ] opengl-lib "glTexCoord4dv" 
	glTexCoord4f: make routine! [ s [float] t [float] r [float] q [float] ] opengl-lib "glTexCoord4f" 
	glTexCoord4fv: make routine! [ v [integer!] ] opengl-lib "glTexCoord4fv" 
	glTexCoord4i: make routine! [ s [GLint] t [GLint] r [GLint] q [GLint] ] opengl-lib "glTexCoord4i" 
	glTexCoord4iv: make routine! [ v [integer!] ] opengl-lib "glTexCoord4iv" 
	glTexCoord4s: make routine! [ s [short] t [short] r [short] q [short] ] opengl-lib "glTexCoord4s" 
	glTexCoord4sv: make routine! [ v [integer!] ] opengl-lib "glTexCoord4sv" 
	glTexCoordPointer: make routine! [ size [GLint] type [GLenum] stride [GLsizei] pointer [integer!] ] opengl-lib "glTexCoordPointer" 
	glTexEnvf: make routine! [ target [GLenum] pname [GLenum] param [float] ] opengl-lib "glTexEnvf" 
	glTexEnvfv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexEnvfv" 
	glTexEnvi: make routine! [ target [GLenum] pname [GLenum] param [GLint] ] opengl-lib "glTexEnvi" 
	glTexEnviv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexEnviv" 
	glTexGend: make routine! [ coord [GLenum] pname [GLenum] param [GLdouble] ] opengl-lib "glTexGend" 
	glTexGendv: make routine! [ coord [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexGendv" 
	glTexGenf: make routine! [ coord [GLenum] pname [GLenum] param [float] ] opengl-lib "glTexGenf" 
	glTexGenfv: make routine! [ coord [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexGenfv" 
	glTexGeni: make routine! [ coord [GLenum] pname [GLenum] param [GLint] ] opengl-lib "glTexGeni" 
	glTexGeniv: make routine! [ coord [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexGeniv" 
	glTexImage1D: make routine! [ target [GLenum] level [GLint] internalformat [GLint] width [GLsizei] border [GLint] format [GLenum] type [GLenum] pixels [binary!] ] opengl-lib "glTexImage1D" 
	glTexImage2D: make routine! [ target [GLenum] level [GLint] internalformat [GLint] width [GLsizei] height [GLsizei] border [GLint] format [GLenum] type [GLenum] pixels [binary!] ] opengl-lib "glTexImage2D" 
	glTexParameterf: make routine! [ target [GLenum] pname [GLenum] param [float] ] opengl-lib "glTexParameterf" 
	glTexParameterfv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexParameterfv" 
	glTexParameteri: make routine! [ target [GLenum] pname [GLenum] param [GLint] ] opengl-lib "glTexParameteri" 
	glTexParameteriv: make routine! [ target [GLenum] pname [GLenum] params [integer!] ] opengl-lib "glTexParameteriv" 
	glTexSubImage1D: make routine! [ target [GLenum] level [GLint] xoffset [GLint] width [GLsizei] format [GLenum] type [GLenum] pixels [integer!] ] opengl-lib "glTexSubImage1D" 
	glTexSubImage2D: make routine! [ target [GLenum] level [GLint] xoffset [GLint] yoffset [GLint] width [GLsizei] height [GLsizei] format [GLenum] type [GLenum] pixels [integer!] ] opengl-lib "glTexSubImage2D" 
	glTranslate: glTranslated: make routine! [ x [GLdouble] y [GLdouble] z [GLdouble] ] opengl-lib "glTranslated" 
	glTranslatef: make routine! [ x [float] y [float] z [float] ] opengl-lib "glTranslatef" 
	glVertex2d: make routine! [ x [GLdouble] y [GLdouble] ] opengl-lib "glVertex2d" 
	glVertex2dv: make routine! [ v [integer!] ] opengl-lib "glVertex2dv" 
	glVertex2f: make routine! [ x [float] y [float] ] opengl-lib "glVertex2f" 
	glVertex2fv: make routine! [ v [integer!] ] opengl-lib "glVertex2fv" 
	glVertex2i: make routine! [ x [GLint] y [GLint] ] opengl-lib "glVertex2i" 
	glVertex2iv: make routine! [ v [integer!] ] opengl-lib "glVertex2iv" 
	glVertex2s: make routine! [ x [short] y [short] ] opengl-lib "glVertex2s" 
	glVertex2sv: make routine! [ v [integer!] ] opengl-lib "glVertex2sv" 
	glVertex3: glVertex3d: make routine! [ x [GLdouble] y [GLdouble] z [GLdouble] ] opengl-lib "glVertex3d" 
	glVertex3dv: make routine! [ v [integer!] ] opengl-lib "glVertex3dv" 
	glVertex3f: make routine! [ x [float] y [float] z [float] ] opengl-lib "glVertex3f" 
	glVertex3fv: make routine! [ v [integer!] ] opengl-lib "glVertex3fv" 
	glVertex3i: make routine! [ x [GLint] y [GLint] z [GLint] ] opengl-lib "glVertex3i" 
	glVertex3iv: make routine! [ v [integer!] ] opengl-lib "glVertex3iv" 
	glVertex3s: make routine! [ x [short] y [short] z [short] ] opengl-lib "glVertex3s" 
	glVertex3sv: make routine! [ v [integer!] ] opengl-lib "glVertex3sv" 
	glVertex4d: make routine! [ x [GLdouble] y [GLdouble] z [GLdouble] w [GLdouble] ] opengl-lib "glVertex4d" 
	glVertex4dv: make routine! [ v [integer!] ] opengl-lib "glVertex4dv" 
	glVertex4f: make routine! [ x [float] y [float] z [float] w [float] ] opengl-lib "glVertex4f" 
	glVertex4fv: make routine! [ v [integer!] ] opengl-lib "glVertex4fv" 
	glVertex4i: make routine! [ x [GLint] y [GLint] z [GLint] w [GLint] ] opengl-lib "glVertex4i" 
	glVertex4iv: make routine! [ v [integer!] ] opengl-lib "glVertex4iv" 
	glVertex4s: make routine! [ x [short] y [short] z [short] w [short] ] opengl-lib "glVertex4s" 
	glVertex4sv: make routine! [ v [integer!] ] opengl-lib "glVertex4sv" 
	glVertexPointer: make routine! [ size [GLint] type [GLenum] stride [GLsizei] pointer [binary!] ] opengl-lib "glVertexPointer" 
	gl-VertexPointer: func [ size [GLint] stride [GLsizei] pointer [block!] /local bin] [
		bin: third block-to-struct pointer
		glVertexPointer size GL_DOUBLE stride bin
	]
	glViewport: make routine! [ x [GLint] y [GLint] width [GLsizei] height [GLsizei] ] opengl-lib "glViewport" 



{************************************************************
************************************************************}

	lib: switch/default System/version/4 [
		2 [%libGLU.dylib]	;OSX
		3 [%glu32.dll]	;Windows
	] [%libGLU.so.1]

	if not attempt [glu-lib: load/library lib] [alert rejoin ["" lib " library not found. Quit"] quit]

{************************************************************
**  glu.h
************************************************************}

	{
	** Return the error string associated with a particular error code.
	** This will return 0 for an invalid error code.
	**
	** The generic function prototype that can be compiled for ANSI or Unicode
	** is defined as follows:
	**
	** LPCTSTR APIENTRY gluErrorStringWIN (GLenum errCode);

	#ifdef UNICODE
	#define gluErrorStringWIN(errCode) ((LPCSTR)  gluErrorUnicodeStringEXT(errCode))
	#else
	}
	gluErrorStringWIN: func [errCode] [gluErrorString errCode  ]
	;#endif

	gluErrorString: make routine! [ errCode [GLenum] return: [string!] ] glu-lib "gluErrorString" 
	;gluErrorUnicodeStringEXT: make routine! [ errCode [GLenum] return: [integer!] ] glu-lib "gluErrorUnicodeStringEXT" 
	gluGetString: make routine! [
	 name [GLenum] return: [string!] ] glu-lib "gluGetString" 

	gluOrtho2D: make routine! [
	 left [GLdouble]
	 right [GLdouble]
	 bottom [GLdouble]
	 top [GLdouble] ] glu-lib "gluOrtho2D" 

	gluPerspective: make routine! [
	 fovy [GLdouble]
	 aspect [GLdouble]
	 zNear [GLdouble]
	 zFar [GLdouble] ] glu-lib "gluPerspective" 

	gluPickMatrix: make routine! [
	 x [GLdouble]
	 y [GLdouble]
	 width [GLdouble]
	 height [GLdouble]
	 viewport [GLint] ] glu-lib "gluPickMatrix"  {[4]);}

	gluLookAt: make routine! [
	 eyex [GLdouble]
	 eyey [GLdouble]
	 eyez [GLdouble]
	 centerx [GLdouble]
	 centery [GLdouble]
	 centerz [GLdouble]
	 upx [GLdouble]
	 upy [GLdouble]
	 upz [GLdouble] ] glu-lib "gluLookAt" 

	gluProject: make routine! [
	 objx [GLdouble]
	 objy [GLdouble]
	 objz [GLdouble]
	 modelMatrix [GLdouble] {[16],}
	 projMatrix [GLdouble] {[16],}
	 viewport [GLint] {[4],}
	 winx [integer!]
	 winy [integer!]
	 winz [integer!] return: [integer!] ] glu-lib "gluProject" 

	gluUnProject: make routine! [
	 winx [GLdouble]
	 winy [GLdouble]
	 winz [GLdouble]
	 modelMatrix [struct! []] {[16],}
	 projMatrix [struct! []] {[16],}
	 viewport [struct! []] {[4],}
	 objx [struct! []]
	 objy [struct! []]
	 objz [struct! []] return: [integer!] ] glu-lib "gluUnProject" 

	gluScaleImage: make routine! [
	 format [GLenum]
	 widthin [GLint]
	 heightin [GLint]
	 typein [GLenum]
	 datain [integer!]
	 widthout [GLint]
	 heightout [GLint]
	 typeout [GLenum]
	 dataout [integer!] return: [integer!] ] glu-lib "gluScaleImage" 

	gluBuild1DMipmaps: make routine! [
	 target [GLenum]
	 components [GLint]
	 width [GLint]
	 format [GLenum]
	 type [GLenum]
	 data [integer!] return: [integer!] ] glu-lib "gluBuild1DMipmaps" 

	gluBuild2DMipmaps: make routine! [
	 target [GLenum]
	 components [GLint]
	 width [GLint]
	 height [GLint]
	 format [GLenum]
	 type [GLenum]
	 data [integer!] return: [integer!] ] glu-lib "gluBuild2DMipmaps" 

	{
	typedef struct GLUnurbs GLUnurbs;
	typedef struct GLUquadric GLUquadric;
	typedef struct GLUtesselator GLUtesselator;
	}
	{ backwards compatibility: }
	{
	typedef struct GLUnurbs GLUnurbsObj;
	typedef struct GLUquadric GLUquadricObj;
	typedef struct GLUtesselator GLUtesselatorObj;
	typedef struct GLUtesselator GLUtriangulatorObj;
	}

	gluNewQuadric: make routine! [ return: [integer!] ] glu-lib "gluNewQuadric" 
	gluDeleteQuadric: make routine! [ state [integer!] ] glu-lib "gluDeleteQuadric" 
	gluQuadricNormals: make routine! [
	 quadObject [integer!]
	 normals [GLenum] ] glu-lib "gluQuadricNormals" 

	gluQuadricTexture: make routine! [
	 quadObject [integer!]
	 textureCoords [GLboolean] ] glu-lib "gluQuadricTexture" 

	gluQuadricOrientation: make routine! [
	 quadObject [integer!]
	 orientation [GLenum] ] glu-lib "gluQuadricOrientation" 

	gluQuadricDrawStyle: make routine! [
	 quadObject [integer!]
	 drawStyle [GLenum] ] glu-lib "gluQuadricDrawStyle" 

	gluCylinder: make routine! [
	 qobj [integer!]
	 baseRadius [GLdouble]
	 topRadius [GLdouble]
	 height [GLdouble]
	 slices [GLint]
	 stacks [GLint] ] glu-lib "gluCylinder" 

	gluDisk: make routine! [
	 qobj [integer!]
	 innerRadius [GLdouble]
	 outerRadius [GLdouble]
	 slices [GLint]
	 loops [GLint] ] glu-lib "gluDisk" 

	gluPartialDisk: make routine! [
	 qobj [integer!]
	 innerRadius [GLdouble]
	 outerRadius [GLdouble]
	 slices [GLint]
	 loops [GLint]
	 startAngle [GLdouble]
	 sweepAngle [GLdouble] ] glu-lib "gluPartialDisk" 

	gluSphere: make routine! [
	 qobj [integer!]
	 radius [GLdouble]
	 slices [GLint]
	 stacks [GLint] ] glu-lib "gluSphere" 

	gluQuadricCallback: make routine! [
	 qobj [integer!]
	 which [GLenum]
	 fn [integer!] ] glu-lib "gluQuadricCallback"  {(CALLBACK *fn)());}

	gluNewTess: make routine! [ ] glu-lib "gluNewTess" 
	gluDeleteTess: make routine! [ tess [integer!] ] glu-lib "gluDeleteTess" 
	gluTessBeginPolygon: make routine! [
	 tess [integer!]
	 polygon_data [integer!] ] glu-lib "gluTessBeginPolygon" 

	gluTessBeginContour: make routine! [ tess [integer!] ] glu-lib "gluTessBeginContour" 
	gluTessVertex: make routine! [
	 tess [integer!]
	 coords [GLdouble] {[3],}
	 data [integer!] ] glu-lib "gluTessVertex" 

	gluTessEndContour: make routine! [ tess [integer!] ] glu-lib "gluTessEndContour" 
	gluTessEndPolygon: make routine! [ tess [integer!] ] glu-lib "gluTessEndPolygon" 
	gluTessProperty: make routine! [
	 tess [integer!]
	 which [GLenum]
	 value [GLdouble] ] glu-lib "gluTessProperty" 

	gluTessNormal: make routine! [
	 tess [integer!]
	 x [GLdouble]
	 y [GLdouble]
	 z [GLdouble] ] glu-lib "gluTessNormal" 

	gluTessCallback: make routine! [
	 tess [integer!]
	 which [GLenum]
	 fn [integer!] ] glu-lib "gluTessCallback"  {(CALLBACK *fn)());}

	gluGetTessProperty: make routine! [
	 tess [integer!]
	 which [GLenum]
	 value [integer!] ] glu-lib "gluGetTessProperty" 

	gluNewNurbsRenderer: make routine! [ return: [integer!] ] glu-lib "gluNewNurbsRenderer" 
	gluDeleteNurbsRenderer: make routine! [ nobj [integer!] ] glu-lib "gluDeleteNurbsRenderer" 
	gluBeginSurface: make routine! [ nobj [integer!] ] glu-lib "gluBeginSurface" 
	gluBeginCurve: make routine! [ nobj [integer!] ] glu-lib "gluBeginCurve" 
	gluEndCurve: make routine! [ nobj [integer!] ] glu-lib "gluEndCurve" 
	gluEndSurface: make routine! [ nobj [integer!] ] glu-lib "gluEndSurface" 
	gluBeginTrim: make routine! [ nobj [integer!] ] glu-lib "gluBeginTrim" 
	gluEndTrim: make routine! [ nobj [integer!] ] glu-lib "gluEndTrim" 
	gluPwlCurve: make routine! [
	 nobj [integer!]
	 count [GLint]
	 array [integer!]
	 stride [GLint]
	 type [GLenum] ] glu-lib "gluPwlCurve" 

	gluNurbsCurve: make routine! [
	 nobj [integer!]
	 nknots [GLint]
	 knot [integer!]
	 stride [GLint]
	 ctlarray [integer!]
	 order [GLint]
	 type [GLenum] ] glu-lib "gluNurbsCurve" 

	gluNurbsSurface: make routine! [
	 nobj [integer!]
	 sknot_count [GLint]
	 sknot [integer!]
	 tknot_count [GLint]
	 tknot [integer!]
	 s_stride [GLint]
	 t_stride [GLint]
	 ctlarray [integer!]
	 sorder [GLint]
	 torder [GLint]
	 type [GLenum] ] glu-lib "gluNurbsSurface" 

	gluLoadSamplingMatrices: make routine! [
	 nobj [integer!]
	 modelMatrix [float] {[16],}
	 projMatrix [float] {[16],}
	 viewport [GLint] ] glu-lib "gluLoadSamplingMatrices"  {[4] );}

	gluNurbsProperty: make routine! [
	 nobj [integer!]
	 property [GLenum]
	 value [float] ] glu-lib "gluNurbsProperty" 

	gluGetNurbsProperty: make routine! [
	 nobj [integer!]
	 property [GLenum]
	 value [integer!] ] glu-lib "gluGetNurbsProperty" 

	gluNurbsCallback: make routine! [
	 nobj [integer!]
	 which [GLenum]
	 fn [integer!] ] glu-lib "gluNurbsCallback"  {(CALLBACK *fn)());}

	{** *          Callback function prototypes    ***}

	{gluQuadricCallback }
	{
	typedef void (CALLBACK *GLUquadricErrorProc) (GLenum);
	}
	{gluTessCallback }
	{
	typedef void (CALLBACK *GLUtessBeginProc)        (GLenum);
	typedef void (CALLBACK *GLUtessEdgeFlagProc)     (GLboolean);
	typedef void (CALLBACK *GLUtessVertexProc)       (void *);
	typedef void (CALLBACK *GLUtessEndProc)          (void);
	typedef void (CALLBACK *GLUtessErrorProc)        (GLenum);
	typedef void (CALLBACK *GLUtessCombineProc)      (GLdouble[3],
	                                                  void*[4], 
	                                                  float[4],
	                                                  void* *);
	typedef void (CALLBACK *GLUtessBeginDataProc)    (GLenum, void *);
	typedef void (CALLBACK *GLUtessEdgeFlagDataProc) (GLboolean, void *);
	typedef void (CALLBACK *GLUtessVertexDataProc)   (void *, void *);
	typedef void (CALLBACK *GLUtessEndDataProc)      (void *);
	typedef void (CALLBACK *GLUtessErrorDataProc)    (GLenum, void *);
	typedef void (CALLBACK *GLUtessCombineDataProc)  (GLdouble[3],
	                                                  void*[4], 
	                                                  float[4],
	                                                  void**,
	                                                  void *);
	}
	{gluNurbsCallback }
	{
	typedef void (CALLBACK *GLUnurbsErrorProc)   (GLenum);
	}

	{***           Generic constants               ***}

	{ Version }
	GLU_VERSION_1_1:                 1
	GLU_VERSION_1_2:                 1

	{ Errors: (return value 0 = no error) }
	GLU_INVALID_ENUM:        100900
	GLU_INVALID_VALUE:       100901
	GLU_OUT_OF_MEMORY:       100902
	GLU_INCOMPATIBLE_GL_VERSION:     100903

	{ StringName }
	GLU_VERSION:             100800
	GLU_EXTENSIONS:          100801

	{ Boolean }
	GLU_TRUE:                GL_TRUE
	GLU_FALSE:               GL_FALSE

	{***           Quadric constants               ***}

	{ QuadricNormal }
	GLU_SMOOTH:              100000
	GLU_FLAT:                100001
	GLU_NONE:                100002

	{ QuadricDrawStyle }
	GLU_POINT:               100010
	GLU_LINE:                100011
	GLU_FILL:                100012
	GLU_SILHOUETTE:          100013

	{ QuadricOrientation }
	GLU_OUTSIDE:             100020
	GLU_INSIDE:              100021

	{ Callback types: }
	{      GLU_ERROR               100103 }

	{***           Tesselation constants           ***}
	{
	#define GLU_TESS_MAX_COORD              1.0e150
	}
	{ TessProperty }
	GLU_TESS_WINDING_RULE:           100140
	GLU_TESS_BOUNDARY_ONLY:          100141
	GLU_TESS_TOLERANCE:              100142

	{ TessWinding }
	GLU_TESS_WINDING_ODD:            100130
	GLU_TESS_WINDING_NONZERO:        100131
	GLU_TESS_WINDING_POSITIVE:       100132
	GLU_TESS_WINDING_NEGATIVE:       100133
	GLU_TESS_WINDING_ABS_GEQ_TWO:    100134

	{ TessCallback }
	GLU_TESS_BEGIN:          100100  { void (CALLBACK*)(GLenum    type)  }
	GLU_TESS_VERTEX:         100101  { void (CALLBACK*)(void      *data) }
	GLU_TESS_END:            100102  { void (CALLBACK*)(void)            }
	GLU_TESS_ERROR:          100103  { void (CALLBACK*)(GLenum    errno) }
	GLU_TESS_EDGE_FLAG:      100104  { void (CALLBACK*)(GLboolean boundaryEdge)  }
	GLU_TESS_COMBINE:        100105  { void (CALLBACK*)(GLdouble  coords[3],
	                                                            void      *data[4],
	                                                            float   weight[4],
	                                                            void      **dataOut)     }
	GLU_TESS_BEGIN_DATA:     100106  { void (CALLBACK*)(GLenum    type,  
	                                                            void      *polygon_data) }
	GLU_TESS_VERTEX_DATA:    100107  { void (CALLBACK*)(void      *data, 
	                                                            void      *polygon_data) }
	GLU_TESS_END_DATA:       100108  { void (CALLBACK*)(void      *polygon_data) }
	GLU_TESS_ERROR_DATA:     100109  { void (CALLBACK*)(GLenum    errno, 
	                                                            void      *polygon_data) }
	GLU_TESS_EDGE_FLAG_DATA: 100110  { void (CALLBACK*)(GLboolean boundaryEdge,
	                                                            void      *polygon_data) }
	GLU_TESS_COMBINE_DATA:   100111  { void (CALLBACK*)(GLdouble  coords[3],
	                                                            void      *data[4],
	                                                            float   weight[4],
	                                                            void      **dataOut,
	                                                            void      *polygon_data) }

	{ TessError }
	GLU_TESS_ERROR1:     100151
	GLU_TESS_ERROR2:     100152
	GLU_TESS_ERROR3:     100153
	GLU_TESS_ERROR4:     100154
	GLU_TESS_ERROR5:     100155
	GLU_TESS_ERROR6:     100156
	GLU_TESS_ERROR7:     100157
	GLU_TESS_ERROR8:     100158

	GLU_TESS_MISSING_BEGIN_POLYGON:  GLU_TESS_ERROR1
	GLU_TESS_MISSING_BEGIN_CONTOUR:  GLU_TESS_ERROR2
	GLU_TESS_MISSING_END_POLYGON:    GLU_TESS_ERROR3
	GLU_TESS_MISSING_END_CONTOUR:    GLU_TESS_ERROR4
	GLU_TESS_COORD_TOO_LARGE:        GLU_TESS_ERROR5
	GLU_TESS_NEED_COMBINE_CALLBACK:  GLU_TESS_ERROR6

	{***           NURBS constants                 ***}

	{ NurbsProperty }
	GLU_AUTO_LOAD_MATRIX:    100200
	GLU_CULLING:             100201
	GLU_SAMPLING_TOLERANCE:  100203
	GLU_DISPLAY_MODE:        100204
	GLU_PARAMETRIC_TOLERANCE:        100202
	GLU_SAMPLING_METHOD:             100205
	GLU_U_STEP:                      100206
	GLU_V_STEP:                      100207

	{ NurbsSampling }
	GLU_PATH_LENGTH:                 100215
	GLU_PARAMETRIC_ERROR:            100216
	GLU_DOMAIN_DISTANCE:             100217

	{ NurbsTrim }
	GLU_MAP1_TRIM_2:         100210
	GLU_MAP1_TRIM_3:         100211

	{ NurbsDisplay }
	{      GLU_FILL                100012 }
	GLU_OUTLINE_POLYGON:     100240
	GLU_OUTLINE_PATCH:       100241

	{ NurbsCallback }
	{      GLU_ERROR               100103 }

	{ NurbsErrors }
	GLU_NURBS_ERROR1:        100251
	GLU_NURBS_ERROR2:        100252
	GLU_NURBS_ERROR3:        100253
	GLU_NURBS_ERROR4:        100254
	GLU_NURBS_ERROR5:        100255
	GLU_NURBS_ERROR6:        100256
	GLU_NURBS_ERROR7:        100257
	GLU_NURBS_ERROR8:        100258
	GLU_NURBS_ERROR9:        100259
	GLU_NURBS_ERROR10:       100260
	GLU_NURBS_ERROR11:       100261
	GLU_NURBS_ERROR12:       100262
	GLU_NURBS_ERROR13:       100263
	GLU_NURBS_ERROR14:       100264
	GLU_NURBS_ERROR15:       100265
	GLU_NURBS_ERROR16:       100266
	GLU_NURBS_ERROR17:       100267
	GLU_NURBS_ERROR18:       100268
	GLU_NURBS_ERROR19:       100269
	GLU_NURBS_ERROR20:       100270
	GLU_NURBS_ERROR21:       100271
	GLU_NURBS_ERROR22:       100272
	GLU_NURBS_ERROR23:       100273
	GLU_NURBS_ERROR24:       100274
	GLU_NURBS_ERROR25:       100275
	GLU_NURBS_ERROR26:       100276
	GLU_NURBS_ERROR27:       100277
	GLU_NURBS_ERROR28:       100278
	GLU_NURBS_ERROR29:       100279
	GLU_NURBS_ERROR30:       100280
	GLU_NURBS_ERROR31:       100281
	GLU_NURBS_ERROR32:       100282
	GLU_NURBS_ERROR33:       100283
	GLU_NURBS_ERROR34:       100284
	GLU_NURBS_ERROR35:       100285
	GLU_NURBS_ERROR36:       100286
	GLU_NURBS_ERROR37:       100287

	{***           Backwards compatibility for old tesselator           ***}

	gluBeginPolygon: make routine! [ tess [integer!] ] glu-lib "gluBeginPolygon" 
	gluNextContour: make routine! [ tess [integer!] type [GLenum] ] glu-lib "gluNextContour" 
	gluEndPolygon: make routine! [ tess [integer!] ] glu-lib "gluEndPolygon" 

	{ Contours types -- obsolete! }
	GLU_CW:          100120
	GLU_CCW:         100121
	GLU_INTERIOR:    100122
	GLU_EXTERIOR:    100123
	GLU_UNKNOWN:     100124

	{ Names without "TESS_" prefix }
	GLU_BEGIN:       GLU_TESS_BEGIN
	GLU_VERTEX:      GLU_TESS_VERTEX
	GLU_END:         GLU_TESS_END
	GLU_ERROR:       GLU_TESS_ERROR
	GLU_EDGE_FLAG:   GLU_TESS_EDGE_FLAG

{************************************************************
************************************************************}

	lib: switch/default System/version/4 [
		2 [%libGLUT.dylib]	;OSX
		3 [%glut32.dll]	;Windows
	] [%libGLUT.so.1]

	if not attempt [glut-lib: load/library lib] [glut-lib: none];alert rejoin ["" lib " library not found. Quit"]]

{************************************************************
**  glut.h
************************************************************}

	{ Copyright (c) Mark J. Kilgard, 1994, 1995, 1996, 1998. }

	{*
	 GLUT API revision history:
	 
	 GLUT_API_VERSION is updated to reflect incompatible GLUT
	 API changes (interface changes, semantic changes, deletions,
	 or additions). 
	 GLUT_API_VERSION=1  First public release of GLUT.  11/29/94
	 GLUT_API_VERSION=2  Added support for OpenGL/GLX multisampling,
	 extension.  Supports new input devices like tablet, dial and button
	 box, and Spaceball.  Easy to query OpenGL extensions.
	 GLUT_API_VERSION=3  glutMenuStatus added.
	 GLUT_API_VERSION=4  glutInitDisplayString, glutWarpPointer,
	 glutBitmapLength, glutStrokeLength, glutWindowStatusFunc, dynamic
	 video resize subAPI, glutPostWindowRedisplay, glutKeyboardUpFunc,
	 glutSpecialUpFunc, glutIgnoreKeyRepeat, glutSetKeyRepeat,
	 glutJoystickFunc, glutForceJoystickFunc (NOT FINALIZED!).
	*}

	GLUT_API_VERSION:		3

	{*
	 GLUT implementation revision history:
	 
	 GLUT_XLIB_IMPLEMENTATION is updated to reflect both GLUT
	 API revisions and implementation revisions (ie, bug fixes).
	 GLUT_XLIB_IMPLEMENTATION=1  mjk's first public release of
	 GLUT Xlib-based implementation.  11/29/94
	 GLUT_XLIB_IMPLEMENTATION=2  mjk's second public release of
	 GLUT Xlib-based implementation providing GLUT version 2 
	 interfaces.
	 GLUT_XLIB_IMPLEMENTATION=3  mjk's GLUT 2.2 images. 4/17/95
	 GLUT_XLIB_IMPLEMENTATION=4  mjk's GLUT 2.3 images. 6/?/95
	 GLUT_XLIB_IMPLEMENTATION=5  mjk's GLUT 3.0 images. 10/?/95
	 GLUT_XLIB_IMPLEMENTATION=7  mjk's GLUT 3.1+ with glutWarpPoitner.  7/24/96
	 GLUT_XLIB_IMPLEMENTATION=8  mjk's GLUT 3.1+ with glutWarpPoitner
	 and video resize.  1/3/97
	 GLUT_XLIB_IMPLEMENTATION=9 mjk's GLUT 3.4 release with early GLUT 4 routines.
	 GLUT_XLIB_IMPLEMENTATION=11 Mesa 2.5's GLUT 3.6 release.
	 GLUT_XLIB_IMPLEMENTATION=12 mjk's GLUT 3.6 release with early GLUT 4 routines + signal handling.
	 GLUT_XLIB_IMPLEMENTATION=13 mjk's GLUT 3.7 beta with GameGLUT support.
	 GLUT_XLIB_IMPLEMENTATION=14 mjk's GLUT 3.7 beta with f90gl friend interface.
	 GLUT_XLIB_IMPLEMENTATION=15 mjk's GLUT 3.7 beta sync'ed with Mesa <GL/glut.h>
	*}

	GLUT_XLIB_IMPLEMENTATION:	15

	{ Display mode bit masks. }
	GLUT_RGB:			0
	GLUT_RGBA:			GLUT_RGB
	GLUT_INDEX:			1
	GLUT_SINGLE:			0
	GLUT_DOUBLE:			2
	GLUT_ACCUM:			4
	GLUT_ALPHA:			8
	GLUT_DEPTH:			16
	GLUT_STENCIL:			32
	GLUT_MULTISAMPLE:		128
	GLUT_STEREO:			256
	GLUT_LUMINANCE:			512

	{ Mouse buttons. }
	GLUT_LEFT_BUTTON:		0
	GLUT_MIDDLE_BUTTON:		1
	GLUT_RIGHT_BUTTON:		2

	{ Mouse button  state. }
	GLUT_DOWN:			0
	GLUT_UP:				1

	{ function keys }
	GLUT_KEY_F1:			1
	GLUT_KEY_F2:			2
	GLUT_KEY_F3:			3
	GLUT_KEY_F4:			4
	GLUT_KEY_F5:			5
	GLUT_KEY_F6:			6
	GLUT_KEY_F7:			7
	GLUT_KEY_F8:			8
	GLUT_KEY_F9:			9
	GLUT_KEY_F10:			10
	GLUT_KEY_F11:			11
	GLUT_KEY_F12:			12
	{ directional keys }
	GLUT_KEY_LEFT:			100
	GLUT_KEY_UP:			101
	GLUT_KEY_RIGHT:			102
	GLUT_KEY_DOWN:			103
	GLUT_KEY_PAGE_UP:		104
	GLUT_KEY_PAGE_DOWN:		105
	GLUT_KEY_HOME:			106
	GLUT_KEY_END:			107
	GLUT_KEY_INSERT:			108

	{ Entry/exit  state. }
	GLUT_LEFT:			0
	GLUT_ENTERED:			1

	{ Menu usage  state. }
	GLUT_MENU_NOT_IN_USE:		0
	GLUT_MENU_IN_USE:		1

	{ Visibility  state. }
	GLUT_NOT_VISIBLE:		0
	GLUT_VISIBLE:			1

	{ Window status  state. }
	GLUT_HIDDEN:			0
	GLUT_FULLY_RETAINED:		1
	GLUT_PARTIALLY_RETAINED:		2
	GLUT_FULLY_COVERED:		3

	{ Color index component selection values. }
	GLUT_RED:			0
	GLUT_GREEN:			1
	GLUT_BLUE:			2

	{#if defined(_WIN32)}
	{ Stroke font constants (use these in GLUT program). }
	GLUT_STROKE_ROMAN:		   0 
	GLUT_STROKE_MONO_ROMAN:		   1 

	{ Bitmap font constants (use these in GLUT program). }
	GLUT_BITMAP_9_BY_15:		   2 
	GLUT_BITMAP_8_BY_13:		   3 
	GLUT_BITMAP_TIMES_ROMAN_10:	   4 
	GLUT_BITMAP_TIMES_ROMAN_24:	   5 
	GLUT_BITMAP_HELVETICA_10:	   6 
	GLUT_BITMAP_HELVETICA_12:	   7 
	GLUT_BITMAP_HELVETICA_18:	   8 

	{#else}

	{ Stroke font opaque addresses (use constants instead in source code). }
	{
	GLUTAPI void *glutStrokeRoman;
	GLUTAPI void *glutStrokeMonoRoman;
	}
	{ Stroke font constants (use these in GLUT program). }
	{
	#define GLUT_STROKE_ROMAN		(&glutStrokeRoman)
	#define GLUT_STROKE_MONO_ROMAN		(&glutStrokeMonoRoman)
	}
	{ Bitmap font opaque addresses (use constants instead in source code). }
	{
	GLUTAPI void *glutBitmap9By15;
	GLUTAPI void *glutBitmap8By13;
	GLUTAPI void *glutBitmapTimesRoman10;
	GLUTAPI void *glutBitmapTimesRoman24;
	GLUTAPI void *glutBitmapHelvetica10;
	GLUTAPI void *glutBitmapHelvetica12;
	GLUTAPI void *glutBitmapHelvetica18;
	}
	{ Bitmap font constants (use these in GLUT program). }
	{
	#define GLUT_BITMAP_9_BY_15		(&glutBitmap9By15)
	#define GLUT_BITMAP_8_BY_13		(&glutBitmap8By13)
	#define GLUT_BITMAP_TIMES_ROMAN_10	(&glutBitmapTimesRoman10)
	#define GLUT_BITMAP_TIMES_ROMAN_24	(&glutBitmapTimesRoman24)
	#define GLUT_BITMAP_HELVETICA_10	(&glutBitmapHelvetica10)
	#define GLUT_BITMAP_HELVETICA_12	(&glutBitmapHelvetica12)
	#define GLUT_BITMAP_HELVETICA_18	(&glutBitmapHelvetica18)
	}
	{#endif}

	{ glutGet parameters. }
	GLUT_WINDOW_X:			  100 
	GLUT_WINDOW_Y:			  101 
	GLUT_WINDOW_WIDTH:		  102 
	GLUT_WINDOW_HEIGHT:		  103 
	GLUT_WINDOW_BUFFER_SIZE:		  104 
	GLUT_WINDOW_STENCIL_SIZE:	  105 
	GLUT_WINDOW_DEPTH_SIZE:		  106 
	GLUT_WINDOW_RED_SIZE:		  107 
	GLUT_WINDOW_GREEN_SIZE:		  108 
	GLUT_WINDOW_BLUE_SIZE:		  109 
	GLUT_WINDOW_ALPHA_SIZE:		  110 
	GLUT_WINDOW_ACCUM_RED_SIZE:	  111 
	GLUT_WINDOW_ACCUM_GREEN_SIZE:	  112 
	GLUT_WINDOW_ACCUM_BLUE_SIZE:	  113 
	GLUT_WINDOW_ACCUM_ALPHA_SIZE:	  114 
	GLUT_WINDOW_DOUBLEBUFFER:	  115 
	GLUT_WINDOW_RGBA:		  116 
	GLUT_WINDOW_PARENT:		  117 
	GLUT_WINDOW_NUM_CHILDREN:	  118 
	GLUT_WINDOW_COLORMAP_SIZE:	  119  
	GLUT_WINDOW_NUM_SAMPLES:		  120 
	GLUT_WINDOW_STEREO:		  121  
	GLUT_WINDOW_CURSOR:		  122 

	GLUT_SCREEN_WIDTH:		  200 
	GLUT_SCREEN_HEIGHT:		  201 
	GLUT_SCREEN_WIDTH_MM:		  202 
	GLUT_SCREEN_HEIGHT_MM:		  203 
	GLUT_MENU_NUM_ITEMS:		  300 
	GLUT_DISPLAY_MODE_POSSIBLE:	  400 
	GLUT_INIT_WINDOW_X:		  500 
	GLUT_INIT_WINDOW_Y:		  501 
	GLUT_INIT_WINDOW_WIDTH:		  502 
	GLUT_INIT_WINDOW_HEIGHT:		  503 
	GLUT_INIT_DISPLAY_MODE:		  504 
	 
	GLUT_ELAPSED_TIME:		  700 

	GLUT_WINDOW_FORMAT_ID:		  123 
	 
	{ glutDeviceGet parameters. }
	GLUT_HAS_KEYBOARD:		  600 
	GLUT_HAS_MOUSE:			  601 
	GLUT_HAS_SPACEBALL:		  602 
	GLUT_HAS_DIAL_AND_BUTTON_BOX:	  603 
	GLUT_HAS_TABLET:			  604 
	GLUT_NUM_MOUSE_BUTTONS:		  605 
	GLUT_NUM_SPACEBALL_BUTTONS:	  606 
	GLUT_NUM_BUTTON_BOX_BUTTONS:	  607 
	GLUT_NUM_DIALS:			  608 
	GLUT_NUM_TABLET_BUTTONS:		  609 
	 
	GLUT_DEVICE_IGNORE_KEY_REPEAT:     610 
	GLUT_DEVICE_KEY_REPEAT:            611 
	GLUT_HAS_JOYSTICK:		  612 
	GLUT_OWNS_JOYSTICK:		  613 
	GLUT_JOYSTICK_BUTTONS:		  614 
	GLUT_JOYSTICK_AXES:		  615 
	GLUT_JOYSTICK_POLL_RATE:		  616 
	 
	{ glutLayerGet parameters. }
	GLUT_OVERLAY_POSSIBLE:             800 
	GLUT_LAYER_IN_USE:		  801 
	GLUT_HAS_OVERLAY:		  802 
	GLUT_TRANSPARENT_INDEX:		  803 
	GLUT_NORMAL_DAMAGED:		  804 
	GLUT_OVERLAY_DAMAGED:		  805 
	 
	{ glutVideoResizeGet parameters. }
	GLUT_VIDEO_RESIZE_POSSIBLE:	  900 
	GLUT_VIDEO_RESIZE_IN_USE:	  901 
	GLUT_VIDEO_RESIZE_X_DELTA:	  902 
	GLUT_VIDEO_RESIZE_Y_DELTA:	  903 
	GLUT_VIDEO_RESIZE_WIDTH_DELTA:	  904 
	GLUT_VIDEO_RESIZE_HEIGHT_DELTA:	  905 
	GLUT_VIDEO_RESIZE_X:		  906 
	GLUT_VIDEO_RESIZE_Y:		  907 
	GLUT_VIDEO_RESIZE_WIDTH:		  908 
	GLUT_VIDEO_RESIZE_HEIGHT:	  909 

	{ glutUseLayer parameters. }
	GLUT_NORMAL:			  0 
	GLUT_OVERLAY:			  1 

	{ glutGetModifiers return mask. }
	GLUT_ACTIVE_SHIFT:               1
	GLUT_ACTIVE_CTRL:                2
	GLUT_ACTIVE_ALT:                 4

	{ glutSetCursor parameters. }
	{ Basic arrows. }
	GLUT_CURSOR_RIGHT_ARROW:		0
	GLUT_CURSOR_LEFT_ARROW:		1
	{ Symbolic cursor shapes. }
	GLUT_CURSOR_INFO:		2
	GLUT_CURSOR_DESTROY:		3
	GLUT_CURSOR_HELP:		4
	GLUT_CURSOR_CYCLE:		5
	GLUT_CURSOR_SPRAY:		6
	GLUT_CURSOR_WAIT:		7
	GLUT_CURSOR_TEXT:		8
	GLUT_CURSOR_CROSSHAIR:		9
	{ Directional cursors. }
	GLUT_CURSOR_UP_DOWN:		10
	GLUT_CURSOR_LEFT_RIGHT:		11
	{ Sizing cursors. }
	GLUT_CURSOR_TOP_SIDE:		12
	GLUT_CURSOR_BOTTOM_SIDE:		13
	GLUT_CURSOR_LEFT_SIDE:		14
	GLUT_CURSOR_RIGHT_SIDE:		15
	GLUT_CURSOR_TOP_LEFT_CORNER:	16
	GLUT_CURSOR_TOP_RIGHT_CORNER:	17
	GLUT_CURSOR_BOTTOM_RIGHT_CORNER:	18
	GLUT_CURSOR_BOTTOM_LEFT_CORNER:	19
	{ Inherit from parent window. }
	GLUT_CURSOR_INHERIT:		100
	{ Blank cursor. }
	GLUT_CURSOR_NONE:		101
	{ Fullscreen crosshair (if available). }
	GLUT_CURSOR_FULL_CROSSHAIR:	102

	{ GLUT device control sub-API. }
	{ glutSetKeyRepeat modes. }
	GLUT_KEY_REPEAT_OFF:		0
	GLUT_KEY_REPEAT_ON:		1
	GLUT_KEY_REPEAT_DEFAULT:		2

	{ Joystick button masks. }
	GLUT_JOYSTICK_BUTTON_A:		1
	GLUT_JOYSTICK_BUTTON_B:		2
	GLUT_JOYSTICK_BUTTON_C:		4
	GLUT_JOYSTICK_BUTTON_D:		8

	{ GLUT game mode sub-API. }
	{ glutGameModeGet. }
	GLUT_GAME_MODE_ACTIVE:             0 
	GLUT_GAME_MODE_POSSIBLE:           1 
	GLUT_GAME_MODE_WIDTH:              2 
	GLUT_GAME_MODE_HEIGHT:             3 
	GLUT_GAME_MODE_PIXEL_DEPTH:        4 
	GLUT_GAME_MODE_REFRESH_RATE:       5 
	GLUT_GAME_MODE_DISPLAY_CHANGED:    6 

	if glut-lib [

	{ GLUT initialization sub-API. }
	glutInit: make routine! [ argcp [integer!] argv [string!] ] glut-lib "glutInit" 
	{
	#if defined(_WIN32) && !defined(GLUT_DISABLE_ATEXIT_HACK)
	extern void APIENTRY __glutInitWithExit(int *argcp, char **argv, void (__cdecl *exitfunc)(int));
	#ifndef GLUT_BUILDING_LIB
	;static void APIENTRY glutInit_ATEXIT_HACK(int *argcp, char **argv) { __glutInitWithExit(argcp, argv, exit); }
	;#define glutInit glutInit_ATEXIT_HACK
	#endif
	#endif
	}
	glutInitDisplayMode: make routine! [ mode [integer!] ] glut-lib "glutInitDisplayMode" 
	glutInitDisplayString: make routine! [ string [string!] ] glut-lib "glutInitDisplayString" 
	glutInitWindowPosition: make routine! [ x [integer!] y [integer!] ] glut-lib "glutInitWindowPosition" 
	glutInitWindowSize: make routine! [ width [integer!] height [integer!] ] glut-lib "glutInitWindowSize" 
	glutMainLoop: make routine! [ ] glut-lib "glutMainLoop" 

	{ GLUT window sub-API. }
	glutCreateWindow: make routine! [ title [string!] return: [integer!] ] glut-lib "glutCreateWindow" 
	{
	#if defined(_WIN32) && !defined(GLUT_DISABLE_ATEXIT_HACK)
	extern int APIENTRY __glutCreateWindowWithExit(const char *title, void (__cdecl *exitfunc)(int));
	#ifndef GLUT_BUILDING_LIB
	static int APIENTRY glutCreateWindow_ATEXIT_HACK(const char *title) { return __glutCreateWindowWithExit(title, exit); }
	#define glutCreateWindow glutCreateWindow_ATEXIT_HACK
	#endif
	#endif
	}
	glutCreateSubWindow: make routine! [ win [integer!] x [integer!] y [integer!] width [integer!] height [integer!] return: [integer!] ] glut-lib "glutCreateSubWindow" 
	glutDestroyWindow: make routine! [ win [integer!] ] glut-lib "glutDestroyWindow" 
	glutPostRedisplay: make routine! [ ] glut-lib "glutPostRedisplay" 
	glutPostWindowRedisplay: make routine! [ win [integer!] ] glut-lib "glutPostWindowRedisplay" 
	glutSwapBuffers: make routine! [ ] glut-lib "glutSwapBuffers" 
	glutGetWindow: make routine! [ return: [integer!] ] glut-lib "glutGetWindow" 
	glutSetWindow: make routine! [ win [integer!] ] glut-lib "glutSetWindow" 
	glutSetWindowTitle: make routine! [ title [string!] ] glut-lib "glutSetWindowTitle" 
	glutSetIconTitle: make routine! [ title [string!] ] glut-lib "glutSetIconTitle" 
	glutPositionWindow: make routine! [ x [integer!] y [integer!] ] glut-lib "glutPositionWindow" 
	glutReshapeWindow: make routine! [ width [integer!] height [integer!] ] glut-lib "glutReshapeWindow" 
	glutPopWindow: make routine! [ ] glut-lib "glutPopWindow" 
	glutPushWindow: make routine! [ ] glut-lib "glutPushWindow" 
	glutIconifyWindow: make routine! [ ] glut-lib "glutIconifyWindow" 
	glutShowWindow: make routine! [ ] glut-lib "glutShowWindow" 
	glutHideWindow: make routine! [ ] glut-lib "glutHideWindow" 
	glutFullScreen: make routine! [ ] glut-lib "glutFullScreen" 
	glutSetCursor: make routine! [ cursor [integer!] ] glut-lib "glutSetCursor" 
	glutWarpPointer: make routine! [ x [integer!] y [integer!] ] glut-lib "glutWarpPointer" 

	{ GLUT overlay sub-API. }
	glutEstablishOverlay: make routine! [ ] glut-lib "glutEstablishOverlay" 
	glutRemoveOverlay: make routine! [ ] glut-lib "glutRemoveOverlay" 
	glutUseLayer: make routine! [ layer [GLenum] ] glut-lib "glutUseLayer" 
	glutPostOverlayRedisplay: make routine! [ ] glut-lib "glutPostOverlayRedisplay" 
	glutPostWindowOverlayRedisplay: make routine! [ win [integer!] ] glut-lib "glutPostWindowOverlayRedisplay" 
	glutShowOverlay: make routine! [ ] glut-lib "glutShowOverlay" 
	glutHideOverlay: make routine! [ ] glut-lib "glutHideOverlay" 

	{ GLUT menu sub-API. }
	glutCreateMenu: make routine! [ func [integer!] return: [integer!] ] glut-lib "glutCreateMenu"  {(GLUTCALLBACK *func)(int));}
	{
	#if defined(_WIN32) && !defined(GLUT_DISABLE_ATEXIT_HACK)
	extern int APIENTRY __glutCreateMenuWithExit(void (GLUTCALLBACK *func)(int), void (__cdecl *exitfunc)(int));
	#ifndef GLUT_BUILDING_LIB
	static int APIENTRY glutCreateMenu_ATEXIT_HACK(void (GLUTCALLBACK *func)(int)) { return __glutCreateMenuWithExit(func, exit); }
	#define glutCreateMenu glutCreateMenu_ATEXIT_HACK
	#endif
	#endif
	}
	glutDestroyMenu: make routine! [ menu [integer!] ] glut-lib "glutDestroyMenu" 
	glutGetMenu: make routine! [ return: [integer!] ] glut-lib "glutGetMenu" 
	glutSetMenu: make routine! [ menu [integer!] ] glut-lib "glutSetMenu" 
	glutAddMenuEntry: make routine! [ label [string!] value [integer!] ] glut-lib "glutAddMenuEntry" 
	glutAddSubMenu: make routine! [ label [string!] submenu [integer!] ] glut-lib "glutAddSubMenu" 
	glutChangeToMenuEntry: make routine! [ item [integer!] label [string!] value [integer!] ] glut-lib "glutChangeToMenuEntry" 
	glutChangeToSubMenu: make routine! [ item [integer!] label [string!] submenu [integer!] ] glut-lib "glutChangeToSubMenu" 
	glutRemoveMenuItem: make routine! [ item [integer!] ] glut-lib "glutRemoveMenuItem" 
	glutAttachMenu: make routine! [ button [integer!] ] glut-lib "glutAttachMenu" 
	glutDetachMenu: make routine! [ button [integer!] ] glut-lib "glutDetachMenu" 

	{ GLUT window callback sub-API. }

	;REBOL-NOTE: some routines commented only because otherwise REBOL gives "too many callbacks" error (if you use them you have to comment some others)

	glutDisplayFunc: make routine! [f [callback []]] glut-lib "glutDisplayFunc"
	glutReshapeFunc: make routine! [f [callback [int int]]] glut-lib "glutReshapeFunc"
	glutKeyboardFunc: make routine! [f [callback [char int int ]]] glut-lib "glutKeyboardFunc"
	glutMouseFunc: make routine! [f [callback [int int int int ]]] glut-lib "glutMouseFunc"
	glutMotionFunc: make routine! [f [callback [int int ]]] glut-lib "glutMotionFunc"
	;glutPassiveMotionFunc: make routine! [f [callback [int int y]]] glut-lib "glutPassiveMotionFunc"
	;glutEntryFunc: make routine! [f [callback [int]]] glut-lib "glutEntryFunc"
	glutVisibilityFunc: make routine! [f [callback [int]]] glut-lib "glutVisibilityFunc"
	glutIdleFunc: make routine! [f [callback []]] glut-lib "glutIdleFunc"
	glutTimerFunc: make routine! [millis [integer!] f [callback [int]] value [integer!]] glut-lib "glutReshapeFunc"
	glutMenuStateFunc: make routine! [f [callback [int]]] glut-lib "glutMenuStateFunc"
	glutSpecialFunc: make routine! [f [callback [int int int]]] glut-lib "glutSpecialFunc"
	;glutSpaceballMotionFunc: make routine! [f [callback [int int int]]] glut-lib "glutSpaceballMotionFunc"
	;glutSpaceballRotateFunc: make routine! [f [callback [int int int]]] glut-lib "glutSpaceballRotateFunc"
	;glutSpaceballButtonFunc: make routine! [f [callback [int int]]] glut-lib "glutSpaceballButtonFunc"
	;glutButtonBoxFunc: make routine! [f [callback [int int]]] glut-lib "glutButtonBoxFunc"
	;glutDialsFunc: make routine! [f [callback [int int]]] glut-lib "glutDialsFunc"
	;glutTabletMotionFunc: make routine! [f [callback [int int]]] glut-lib "glutTabletMotionFunc"
	;glutTabletButtonFunc: make routine! [f [callback [int int int int]]] glut-lib "glutTabletButtonFunc"
	glutMenuStatusFunc: make routine! [f [callback [int int int]]] glut-lib "glutMenuStatusFunc"
	;glutOverlayDisplayFunc: make routine! [f [callback []]] glut-lib "glutOverlayDisplayFunc"
	glutWindowStatusFunc: make routine! [f [callback [int]]] glut-lib "glutWindowStatusFunc"
	glutKeyboardUpFunc: make routine! [f [callback [char int int]]] glut-lib "glutKeyboardUpFunc"
	glutSpecialUpFunc: make routine! [f [callback [int int int]]] glut-lib "glutSpecialUpFunc"
	glutJoystickFunc: make routine! [f [callback [int int int int]] pollInterval [integer!]] glut-lib "glutJoystickFunc"
	

	{ GLUT color index sub-API. }
	glutSetColor: make routine! [ a [integer!] red [float] green [float] blue [float] ] glut-lib "glutSetColor" 
	glutGetColor: make routine! [ ndx [integer!] component [integer!] return: [float] ] glut-lib "glutGetColor" 
	glutCopyColormap: make routine! [ win [integer!] ] glut-lib "glutCopyColormap" 

	{ GLUT state retrieval sub-API. }
	glutGet: make routine! [ type [GLenum] return: [integer!] ] glut-lib "glutGet" 
	glutDeviceGet: make routine! [ type [GLenum] return: [integer!]  ] glut-lib "glutDeviceGet" 

	{ GLUT extension support sub-API }
	glutExtensionSupported: make routine! [ name [string!] return: [integer!] ] glut-lib "glutExtensionSupported" 
	glutGetModifiers: make routine! [ return: [integer!] ] glut-lib "glutGetModifiers" 
	glutLayerGet: make routine! [ type [GLenum] return: [integer!] ] glut-lib "glutLayerGet" 

	{ GLUT font sub-API }
	glutBitmapCharacter: make routine! [ font [integer!] character [char!] ] glut-lib "glutBitmapCharacter" 
	glutBitmapWidth: make routine! [ font [integer!] character [char!] return: [integer!] ] glut-lib "glutBitmapWidth" 
	glutStrokeCharacter: make routine! [ font [integer!] character [char!] return: [integer!] ] glut-lib "glutStrokeCharacter" 
	glutStrokeWidth: make routine! [ font [integer!] character [integer!] return: [integer!] ] glut-lib "glutStrokeWidth" 
	glutBitmapLength: make routine! [ font [integer!] string [string!] return: [integer!] ] glut-lib "glutBitmapLength" 
	glutStrokeLength: make routine! [ font [integer!] string [string!] return: [integer!] ] glut-lib "glutStrokeLength" 

	{ GLUT pre-built models sub-API }
	glutWireSphere: make routine! [ radius [GLdouble] slices [GLint] stacks [GLint] ] glut-lib "glutWireSphere" 
	glutSolidSphere: make routine! [ radius [GLdouble] slices [GLint] stacks [GLint] ] glut-lib "glutSolidSphere" 
	glutWireCone: make routine! [ base [GLdouble] height [GLdouble] slices [GLint] stacks [GLint] ] glut-lib "glutWireCone" 
	glutSolidCone: make routine! [ base [GLdouble] height [GLdouble] slices [GLint] stacks [GLint] ] glut-lib "glutSolidCone" 
	glutWireCube: make routine! [ size [GLdouble] ] glut-lib "glutWireCube" 
	glutSolidCube: make routine! [ size [GLdouble] ] glut-lib "glutSolidCube" 
	glutWireTorus: make routine! [ innerRadius [GLdouble] outerRadius [GLdouble] sides [GLint] rings [GLint] ] glut-lib "glutWireTorus" 
	glutSolidTorus: make routine! [ innerRadius [GLdouble] outerRadius [GLdouble] sides [GLint] rings [GLint] ] glut-lib "glutSolidTorus" 
	glutWireDodecahedron: make routine! [ ] glut-lib "glutWireDodecahedron" 
	glutSolidDodecahedron: make routine! [ ] glut-lib "glutSolidDodecahedron" 
	glutWireTeapot: make routine! [ size [GLdouble] ] glut-lib "glutWireTeapot" 
	glutSolidTeapot: make routine! [ size [GLdouble] ] glut-lib "glutSolidTeapot" 
	glutWireOctahedron: make routine! [ ] glut-lib "glutWireOctahedron" 
	glutSolidOctahedron: make routine! [ ] glut-lib "glutSolidOctahedron" 
	glutWireTetrahedron: make routine! [ ] glut-lib "glutWireTetrahedron" 
	glutSolidTetrahedron: make routine! [ ] glut-lib "glutSolidTetrahedron" 
	glutWireIcosahedron: make routine! [ ] glut-lib "glutWireIcosahedron" 
	glutSolidIcosahedron: make routine! [ ] glut-lib "glutSolidIcosahedron" 

	{ GLUT video resize sub-API. }
	glutVideoResizeGet: make routine! [ param [GLenum] return: [integer!] ] glut-lib "glutVideoResizeGet" 
	glutSetupVideoResizing: make routine! [ ] glut-lib "glutSetupVideoResizing" 
	glutStopVideoResizing: make routine! [ ] glut-lib "glutStopVideoResizing" 
	glutVideoResize: make routine! [ x [integer!] y [integer!] width [integer!] height [integer!] ] glut-lib "glutVideoResize" 
	glutVideoPan: make routine! [ x [integer!] y [integer!] width [integer!] height [integer!] ] glut-lib "glutVideoPan" 

	{ GLUT debugging sub-API. }
	glutReportErrors: make routine! [ ] glut-lib "glutReportErrors" 

	glutIgnoreKeyRepeat: make routine! [ ignore [integer!] ] glut-lib "glutIgnoreKeyRepeat" 
	glutSetKeyRepeat: make routine! [ repeatMode [integer!] ] glut-lib "glutSetKeyRepeat" 
	glutForceJoystickFunc: make routine! [ ] glut-lib "glutForceJoystickFunc" 

	glutGameModeString: make routine! [ string [string!] ] glut-lib "glutGameModeString" 
	glutEnterGameMode: make routine! [ return: [integer!] ] glut-lib "glutEnterGameMode" 
	glutLeaveGameMode: make routine! [ ] glut-lib "glutLeaveGameMode" 
	glutGameModeGet: make routine! [ mode [GLenum] return: [integer!] ] glut-lib "glutGameModeGet" 

	]; if glut-lib


{************************************************************
** Rebol specific re-implemented glut functions
************************************************************}
	opengl-lib-obj: make object! [
		loop: true
		moved:
		fullscreen: false
		title: ""
		mode:  GLUT_RGB or GLUT_DEPTH
		posx: 
		posy: none
		width: 200
		height: 200
		old-pos: none
		old-size: none
		window-num: 0
		face:
		window:
		windows:
		event-func:

		displayFunc:
		reshapeFunc:
		keyboardFunc:
		keyboardUpFunc:
		specialFunc:
		specialUpFunc:
		motionFunc:
		mouseFunc:
		passiveMotionFunc:
		idleFunc:
		timerFunc:
		visibilityFunc: none
		menuFunc: [none none none none none none none none]
		scrollFunc: none

		special-keys: reduce [
			'f1 GLUT_KEY_F1
			'f2 GLUT_KEY_F2
			'f3 GLUT_KEY_F3
			'f4 GLUT_KEY_F4
			'f5 GLUT_KEY_F5
			'f6 GLUT_KEY_F6
			'f7 GLUT_KEY_F7
			'f8 GLUT_KEY_F8
			'f9 GLUT_KEY_F9
			'f10 GLUT_KEY_F10
			'f11 GLUT_KEY_F11
			'f12 GLUT_KEY_F12
			'left GLUT_KEY_LEFT
			'up GLUT_KEY_UP
			'right GLUT_KEY_RIGHT
			'down GLUT_KEY_DOWN
			'page-up GLUT_KEY_PAGE_UP
			'page-down GLUT_KEY_PAGE_DOWN
			'home GLUT_KEY_HOME
			'end GLUT_KEY_END
			'insert GLUT_KEY_INSERT
		]
	]

	glut-DisplayFunc: 		func [name [word! none!]] [opengl-lib-obj/displayFunc: get name]
	glut-keyboardFunc: 		func [name [word! none!]] [opengl-lib-obj/keyboardFunc: get name]
	glut-keyboardUpFunc: 	func [name [word! none!]] [opengl-lib-obj/keyboardUpFunc: get name]
	glut-motionFunc: 		func [name [word! none!]] [opengl-lib-obj/motionFunc: get name]
	glut-mouseFunc: 		func [name [word! none!]] [opengl-lib-obj/mouseFunc: get name]
	glut-passiveMotionFunc:	func [name [word! none!]] [opengl-lib-obj/passiveMotionFunc: get name]
	glut-reshapeFunc: 		func [name [word! none!]] [opengl-lib-obj/reshapeFunc: get name]
	glut-specialFunc: 		func [name [word! none!]] [opengl-lib-obj/specialFunc: get name]
	glut-specialUpFunc: 	func [name [word! none!]] [opengl-lib-obj/specialUpFunc: get name]
	glut-idleFunc: 			func [name [word! none!]] [opengl-lib-obj/idleFunc: get name]
	glut-timerFunc: 		func [name [word! none!]] [opengl-lib-obj/timerFunc: get name]
	glut-visibilityFunc: 	func [name [word! none!]] [opengl-lib-obj/visibilityFunc: get name]
	glut-menuFunc: 			func [name [word! none!]] [opengl-lib-obj/menuFunc: get name]

	glut-scrollFunc:		func [name [word! none!]] [opengl-lib-obj/scrollFunc: get name]

	glut-MainLoop: does [
		if get in opengl-lib-obj 'ReshapeFunc [opengl-lib-obj/ReshapeFunc opengl-lib-obj/window/size/x opengl-lib-obj/window/size/y]
		opengl-lib-obj/displayFunc
		while [any [opengl-lib-obj/loop not empty? system/view/screen-face/pane]] [
			if get in opengl-lib-obj 'idleFunc [opengl-lib-obj/idleFunc]
			wait 0.001; REBOL-NOTE: let listen events
		]
		glut-CleanUp
	]
	glut-CleanUp: does [
		glut-unview/quit

		free opengl-lib
		free glu-lib
		attempt [free glut-lib]
		;quit
	]
	glut-DestroyWindow: does [glut-unview/quit]
	glut-IconifyWindow: does [opengl-lib-obj/window/changes: [minimize] show opengl-lib-obj/window]
	glut-SetWindowTitle: func [title [string!]] [opengl-lib-obj/window/text: title opengl-lib-obj/window/changes: [text] show opengl-lib-obj/window]
	glut-PositionWindow: func [ x [integer!] y [integer!] ] [opengl-lib-obj/window/offset: as-pair x y show opengl-lib-obj/window]
	glut-FullScreen: does [
		if not opengl-lib-obj/fullscreen [
			alter opengl-lib-obj/window/options 'no-title ; REBOL-NOTE: with this findwindow does not work :(
			alter opengl-lib-obj/window/options 'no-border
			alter opengl-lib-obj/window/options 'resize
			unview/only opengl-lib-obj/window
			opengl-lib-obj/old-pos: opengl-lib-obj/window/offset
			opengl-lib-obj/old-size: opengl-lib-obj/window/size
			opengl-lib-obj/window/offset: 0x0
			opengl-lib-obj/window/size: system/view/screen-face/size
			view/new opengl-lib-obj/window
			if get in opengl-lib-obj 'ReshapeFunc [opengl-lib-obj/ReshapeFunc system/view/screen-face/size/x system/view/screen-face/size/y]
			opengl-lib-obj/fullscreen: true
			glut-MainLoop
		]
	]
	glut-ReshapeWindow: func [Width Height] [
		if opengl-lib-obj/fullscreen [
			alter opengl-lib-obj/window/options 'no-title
			alter opengl-lib-obj/window/options 'no-border
			alter opengl-lib-obj/window/options 'resize
			opengl-lib-obj/window/offset: opengl-lib-obj/old-pos
			opengl-lib-obj/window/size: opengl-lib-obj/old-size
			opengl-lib-obj/fullscreen: false
		]
		opengl-lib-obj/window/size/x: Width
		opengl-lib-obj/window/size/y: Height
		unview/only opengl-lib-obj/window
		view/new opengl-lib-obj/window
		
		glut-MainLoop
	]
	glut-PostRedisplay: does [opengl-lib-obj/displayFunc]
	glut-InitDisplayMode: func [mode [integer!]] [opengl-lib-obj/mode: mode or GLUT_RGB or GLUT_DEPTH] 
	glut-InitWindowSize: func [w [integer!] h [integer!]] [opengl-lib-obj/width: w opengl-lib-obj/height: h]
	glut-InitWindowPosition: func [x [integer!] y [integer!]] [opengl-lib-obj/posx: x opengl-lib-obj/posy: y]
	glut-CreateWindow: func [title [string!]] [
		opengl-lib-obj/window-num: opengl-lib-obj/window-num + 1
		glut-view title layout [ size as-pair opengl-lib-obj/width opengl-lib-obj/height]
	]
	glut-BitmapString: func [ font [integer!] string [string!] ] [
		foreach char string [glutBitmapCharacter font char]
	]


	{************************************************************
	** Rebol specific functions
	************************************************************}

	glut-view: func [; taken from OpenGL.R Test (c) 2003 Cal Dixon
		title [string!] face [object!] /options opts [block!]
		/local
		PIXELFORMATDESCRIPTOR-def PIXELFORMATDESCRIPTOR pfd user32 gdi32 opengl oldhDC oldhRC hdc hRC
		display attrList-def attrList defs vinfo util_glctx winFocus
		] [

		opengl-lib-obj/title: title
		opengl-lib-obj/face: face
		opengl-lib-obj/posx: any [opengl-lib-obj/posx opengl-lib-obj/face/offset/x]
		opengl-lib-obj/posy: any [opengl-lib-obj/posy opengl-lib-obj/face/offset/y]
		face: view/new/title/offset/options make face [hDC: wdat: none] title as-pair opengl-lib-obj/posx opengl-lib-obj/posy any [opts [resize]]
		opengl-lib-obj/window: face
		;face/user-data: reduce ['size face/size]
		if not get in opengl-lib-obj 'event-func [
			opengl-lib-obj/event-func: insert-event-func func [face event] [
				if event/face = opengl-lib-obj/window [
				switch event/type [
					move [if get in opengl-lib-obj 'MotionFunc [opengl-lib-obj/MotionFunc event/offset/x event/offset/y]]
					key [
						either found? find opengl-lib-obj/special-keys event/key [
							if get in opengl-lib-obj 'specialFunc [opengl-lib-obj/specialFunc select opengl-lib-obj/special-keys event/key event/offset/x event/offset/y]
						] [
							if get in opengl-lib-obj 'keyboardFunc [opengl-lib-obj/keyboardFunc event/key event/offset/x event/offset/y]
						]
					]
					down [if get in opengl-lib-obj 'MouseFunc [opengl-lib-obj/MouseFunc GLUT_LEFT_BUTTON GLUT_DOWN event/offset/x event/offset/y]]
					up [if get in opengl-lib-obj 'MouseFunc [opengl-lib-obj/MouseFunc GLUT_LEFT_BUTTON GLUT_UP event/offset/x event/offset/y]]
					alt-down [if get in opengl-lib-obj 'MouseFunc [opengl-lib-obj/MouseFunc GLUT_RIGHT_BUTTON GLUT_DOWN event/offset/x event/offset/y]]
					alt-up [if get in opengl-lib-obj 'MouseFunc [opengl-lib-obj/MouseFunc GLUT_RIGHT_BUTTON GLUT_up event/offset/x event/offset/y]]
					resize [
						face: opengl-lib-obj/window
						;face/user-data/size: face/size          ; store new size
						if get in opengl-lib-obj 'ReshapeFunc [opengl-lib-obj/ReshapeFunc face/size/x face/size/y]
						opengl-lib-obj/displayFunc
					]
					offset [opengl-lib-obj/moved: true return event]
					active [
						if opengl-lib-obj/moved [ ; unminimized
							if get in opengl-lib-obj 'visibilityFunc [opengl-lib-obj/visibilityFunc GLUT_VISIBLE]
						]
						opengl-lib-obj/displayFunc
					]
					inactive [opengl-lib-obj/displayFunc]
					minimize [if get in opengl-lib-obj 'visibilityFunc [opengl-lib-obj/visibilityFunc GLUT_NOT_VISIBLE]]
					close [opengl-lib-obj/loop: false];glut-CleanUp] ; better let user handle this (or add closeFunc?)
					scroll-line [if get in opengl-lib-obj 'scrollFunc [opengl-lib-obj/scrollFunc event/offset/y]]
				]
				]
				opengl-lib-obj/moved: false
				event
			]
		]
		opengl-lib-obj/loop: true

		switch/default System/version/4 [
		3 [
			PIXELFORMATDESCRIPTOR-def: [
			   nSize [short]
			   nVersion [short]
			   dwFlags [integer!]
			   iPixelType [char!]
			   cColorBits [char!]
			   cRedBits [char!]
			   cRedShift [char!]
			   cGreenBits [char!] 
			   cGreenShift [char!] 
			   cBlueBits [char!] 
			   cBlueShift [char!] 
			   cAlphaBits [char!] 
			   cAlphaShift [char!] 
			   cAccumBits [char!] 
			   cAccumRedBits [char!] 
			   cAccumGreenBits [char!] 
			   cAccumBlueBits [char!] 
			   cAccumAlphaBits [char!] 
			   cDepthBits [char!] 
			   cStencilBits [char!] 
			   cAuxBuffers [char!] 
			   iLayerType [char!] 
			   bReserved [char!]
			   dwLayerMask [integer!]
			   dwVisibleMask [integer!]
			   dwDamageMask [integer!]
			]
			{pfd constants}
				PFD_DOUBLEBUFFER: 1
				PFD_STEREO: 2
				PFD_DRAW_TO_WINDOW: 4
				PFD_DRAW_TO_BITMAP: 8
				PFD_SUPPORT_GDI: 16
				PFD_SUPPORT_OPENGL: 32
				PFD_GENERIC_FORMAT: 64
				PFD_NEED_PALETTE: 128
				PFD_NEED_SYSTEM_PALETTE: 256
				PFD_SWAP_EXCHANGE: 512
				PFD_SWAP_COPY: 1024
				PFD_SWAP_LAYER_BUFFERS: 2048
				PFD_GENERIC_ACCELERATED: 4096
				PFD_SUPPORT_DIRECTDRAW: 8192
				PFD_TYPE_RGBA: to-char 0
				PFD_TYPE_COLORINDEX: to-char 1 
				PFD_MAIN_PLANE: to-char 0
				PFD_OVERLAY_PLANE: to-char 1
				PFD_UNDERLAY_PLANE: to-char 255

			pfd: make struct! PIXELFORMATDESCRIPTOR-def none

			pfd/nSize: length? third pfd
			pfd/nVersion: 1
			pfd/dwFlags: PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL
			if (opengl-lib-obj/mode and GLUT_DOUBLE) <> 0 [pfd/dwFlags: pfd/dwFlags or PFD_DOUBLEBUFFER]
			pfd/iPixelType: PFD_TYPE_RGBA
			pfd/cColorBits: to-char 24
			pfd/cDepthBits: to-char 32
			pfd/iLayerType: PFD_MAIN_PLANE

			user32: load/library %user32.dll
			gdi32: load/library %gdi32.dll
			;opengl: load/library %Opengl32.dll

			FindWindow: make routine! [class [string!] name [int] return: [int]] user32 "FindWindowA"
			GetDC: make routine! [hWnd [integer!] return: [integer!]] user32 "GetDC"
			ReleaseDC: make routine! [hWnd [integer!] hDC [integer!]] user32 "ReleaseDC"
			ChoosePixelFormat: make routine! compose/deep/only [hdc [integer!] ppfd [struct! (PIXELFORMATDESCRIPTOR-def)] return: [integer!]] gdi32 "ChoosePixelFormat"
			SetPixelFormat: make routine! compose/deep/only [hdc [integer!] iPixelFormat [integer!] ppfd [struct! (PIXELFORMATDESCRIPTOR-def)] return: [integer!]] gdi32 "SetPixelFormat"
			SwapBuffers: make routine! [hDC [integer!] return: [integer!]] gdi32 "SwapBuffers"
			wglCreateContext: make routine! [hDC [integer!] return: [integer!]] opengl-lib "wglCreateContext"
			wglMakeCurrent: make routine! [hDC [integer!] hRC [integer!]] opengl-lib "wglMakeCurrent"
			wglGetCurrentContext: make routine! [return: [integer!]] opengl-lib "wglGetCurrentContext"
			wglGetCurrentDC: make routine! [return: [integer!]] opengl-lib "wglGetCurrentDC"
			wglDeleteContext: make routine! [hRC [integer!]] opengl-lib "wglDeleteContext"

			face/hDC: hDC: GetDC FindWindow "REBOLWind" 0

			SetPixelFormat hDC ChoosePixelFormat hDC pfd pfd

			hRC: wglCreateContext hDC
			oldhRC: wglGetCurrentContext
			oldhDC: wglGetCurrentDC
			wglMakeCurrent hDC hRC
			
			face/wdat: reduce [user32 gdi32 opengl oldhDC oldhRC hDC hRC]
		]
		4 [

			{GLX constants}
			GLX_USE_GL:		1
			GLX_BUFFER_SIZE:		2
			GLX_LEVEL:		3
			GLX_RGBA:		4
			GLX_DOUBLEBUFFER:	5
			GLX_STEREO:		6
			GLX_AUX_BUFFERS:		7
			GLX_RED_SIZE:		8
			GLX_GREEN_SIZE:		9
			GLX_BLUE_SIZE:		10
			GLX_ALPHA_SIZE:		11
			GLX_DEPTH_SIZE:		12
			GLX_STENCIL_SIZE:	13
			GLX_ACCUM_RED_SIZE:	14
			GLX_ACCUM_GREEN_SIZE:	15
			GLX_ACCUM_BLUE_SIZE:	16
			GLX_ACCUM_ALPHA_SIZE:	17

			lib: %libX11.so.6
			if not attempt [libx11-lib: load/library lib] [alert rejoin ["" lib " library not found. Quit"] quit]

			XDefaultScreen: make routine! [ display [integer!] return: [integer!] ] libx11-lib "XDefaultScreen"
			XOpenDisplay: make routine! [ display_name [string!] return: [integer!] ] libx11-lib "XOpenDisplay"
			XCloseDisplay: make routine! [ display [integer!] return: [integer!] ] libx11-lib "XCloseDisplay"
			XGetInputFocus: make routine! [ display [integer!] winFocus [struct! []] revert [struct! []] return: [integer!] ] libx11-lib "XGetInputFocus"

			glXChooseVisual: make routine! [ dpy [integer!] screen [integer!] attribList [binary!] return: [integer!] ] opengl-lib "glXChooseVisual" 
			glXCreateContext: make routine! [ dpy [integer!] vis [integer!] shareList [integer!] direct [integer!] return: [integer!] ] opengl-lib "glXCreateContext" 
			glXDestroyContext: make routine! [ dpy [integer!] ctx [integer!] return: [integer!] ] opengl-lib "glXDestroyContext" 
			glXMakeCurrent: make routine! [ dpy [integer!] drawable [integer!] ctx [integer!] return: [integer!] ] opengl-lib "glXMakeCurrent" 
			glXSwapBuffers: make routine! [ dpy [integer!] drawable [integer!] return: [integer!] ] opengl-lib "glXSwapBuffers" 

			catch [
				if 0 = (display: XOpenDisplay "") [throw]

				attrList-def: reduce [GLX_USE_GL GLX_RGBA  GLX_DEPTH_SIZE 16 GLX_RED_SIZE 1 GLX_GREEN_SIZE 1 GLX_BLUE_SIZE 1 0]
				if (opengl-lib-obj/mode and GLUT_DOUBLE) <> 0  [insert attrList-def GLX_DOUBLEBUFFER]
				attrList: block-to-struct head attrList-def

				defs: XDefaultScreen display
				if 0 = vinfo: glXChooseVisual display  defs  third attrList [throw]
				if 0 = util_glctx: glXCreateContext display  vinfo  0  GL_TRUE [throw]

				; Find the window which has the current keyboard focus.
				winFocus: int-ptr
				XGetInputFocus display winFocus int-ptr

				if (0 = glXMakeCurrent display  winFocus/value  util_glctx) [throw]
				
				face/wdat: reduce [0 libx11-lib opengl-lib display util_glctx winFocus/value 0]
			]

		]
		][exit];switch
		face
	]

	glut-unview: func [/quit /local face [object!]] [
		if face: opengl-lib-obj/window [
			switch System/version/4 [
			3 [
				wglMakeCurrent face/wdat/4 face/wdat/5
				wglDeleteContext face/wdat/7
				releasedc 0 face/wdat/6
				if quit [
					free face/wdat/1
					free face/wdat/2
					;free face/wdat/3
				]
			]
			4 [
				if face/wdat/5 [glXMakeCurrent face/wdat/4 0 0]
				glXDestroyContext face/wdat/4 face/wdat/5
				XCloseDisplay face/wdat/4
				if quit [
					free face/wdat/2
				]
			]
			]
			remove-event-func get in opengl-lib-obj 'event-func
			unview/only face
			opengl-lib-obj/loop: false
			opengl-lib-obj/event-func: none
			opengl-lib-obj/window: none
		]
	]
	
	switch System/version/4 [
		3 [glut-SwapBuffers: does [SwapBuffers opengl-lib-obj/window/hDC]]
		4 [glut-SwapBuffers: does [glXSwapBuffers opengl-lib-obj/window/wdat/4 opengl-lib-obj/window/wdat/6]]
	]



{************************************************************
*** example
************************************************************}

;comment [ ;uncomment this and comment next line to comment example code
context [ ; taken from OpenGL.R Test (c) 2003 Cal Dixon
if any [(System/version/4 = 3) (System/version/4 = 4)] [
	print "Press any key while in the 3D window to quit.  Click and drag to move the cube."
	glut-InitDisplayMode GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH ; eneable double buffering since default is single
	glut-view "Test" layout [ size 512x512 origin 0x0
		control: box 512x512  feel [
			engage: func [f a e][
				if a = 'over [ transx: e/offset/x transy: 512.0 - e/offset/y ]
				if a = 'key [
					glut-unview
					quit
				]
				if a = 'alt-down [ thetabump: negate thetabump ]
				if a = 'alt-up [ thetabump: negate thetabump]
			]
		]
	]
	focus control ; REBOL-NOTE: necessary to hear key presses (if we do not use glut-keybordFunc)

	glEnable GL_DEPTH_TEST
	glEnable GL_CULL_FACE
	glEnable GL_TEXTURE_2D
  
	texturebin: to-binary to-image layout/size [at 0x0 image 128x128 logo.gif effect [fit flip 0x1] ] 128x128

	texptr: make binary! 4 * 1 ; REBOL-NOTE: allocate 4 bytes of memory (for 1 pointer)
	glGenTextures 1 texptr
	glBindTexture GL_TEXTURE_2D texptr
	glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT
	glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT
	glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR
	glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR
	glTexEnvf GL_TEXTURE_ENV GL_TEXTURE_ENV_MODE GL_MODULATE
	glTexImage2d GL_TEXTURE_2D 0 4 128 128 0 GL_BGRA_EXT GL_UNSIGNED_BYTE texturebin

	theta: 0.0
	thetabump: .10
	transx: 0.0
	transy: 0.0

	n: 0 t: now/time/precise

	display: does [
		glClearColor 0.0 0.0 0.0 0.0
		glClear GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT

		glPushMatrix
		glTranslated -1.0 + (transx / 256) -1.0 + (transy / 256) 0.0
		glRotate theta 1.0 1.0 1.0
		glBindTexture GL_TEXTURE_2D texptr
		glBegin GL_TRIANGLES

			; front / blue
			gl-color blue

			glTexCoord2d 0.0 0.0
			 glVertex3d 0.0 0.0 0.0
			glTexCoord2d 1.0 0.0
			 glVertex3d 0.5 0.0 0.0
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.0 0.5 0.0

			glTexCoord2d 1.0 1.0
			 glVertex3d 0.5 0.5 0.0
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.0 0.5 0.0
			glTexCoord2d 1.0 0.0
			 glVertex3d 0.5 0.0 0.0

			;left / red
			gl-Color red

			glTexCoord2d 0.0 0.0
			 glVertex3d 0.0 0.0 0.0
			glTexCoord2d 1.0 0.0
			 glVertex3d 0.0 0.5 0.0
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.0 0.0 0.5
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.0 0.5 0.5
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.0 0.0 0.5
			glTexCoord2d 1.0 0.0
			 glVertex3d 0.0 0.5 0.0

			;right / yellow
			gl-Color yellow

			glTexCoord2d 1.0 0.0
			 glVertex3d 0.5 0.0 0.0
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.5 0.0 0.5
			glTexCoord2d 0.0 0.0
			 glVertex3d 0.5 0.5 0.0
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.5 0.5 0.5
			glTexCoord2d 0.0 0.0
			 glVertex3d 0.5 0.5 0.0
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.5 0.0 0.5

			; back / green
			gl-Color green

			glTexCoord2d 1.0 0.0
			 glVertex3d 0.0 0.0 0.5
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.0 0.5 0.5
			glTexCoord2d 0.0 0.0
			 glVertex3d 0.5 0.0 0.5
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.5 0.5 0.5
			glTexCoord2d 0.0 0.0
			 glVertex3d 0.5 0.0 0.5
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.0 0.5 0.5

			; bottom / cyan
			gl-Color cyan

			glTexCoord2d 1.0 0.0
			 glVertex3d 0.0 0.0 0.0
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.0 0.0 0.5
			glTexCoord2d 0.0 0.0
			 glVertex3d 0.5 0.0 0.0
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.5 0.0 0.5
			glTexCoord2d 0.0 0.0
			 glVertex3d 0.5 0.0 0.0
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.0 0.0 0.5

			; top / purple
			gl-Color purple

			glTexCoord2d 0.0 0.0
			 glVertex3d 0.0 0.5 0.0
			glTexCoord2d 1.0 0.0
			 glVertex3d 0.5 0.5 0.0
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.0 0.5 0.5
			glTexCoord2d 1.0 1.0
			 glVertex3d 0.5 0.5 0.5
			glTexCoord2d 0.0 1.0
			 glVertex3d 0.0 0.5 0.5
			glTexCoord2d 1.0 0.0
			 glVertex3d 0.5 0.5 0.0

		glEnd
		glPopMatrix

		glut-SwapBuffers

		theta: theta + thetabump
		n: n + 1
		if n > 50 [
			t1: now/time/precise 
			if t1 = t [t1: t1 + 0.1]
			print rejoin ["" fps: to-integer n / to-decimal (t1 - t) " fps  "] prin "^(1B)[1A"
			n: 0 t: now/time/precise
			thetabump: 100 / fps * sign? thetabump
		]

	]

	glut-DisplayFunc 'display	;REBOL-NOTE: assign callbacks
	glut-IdleFunc 'display	;REBOL-NOTE: assign callbacks { Even if there are no events  redraw our gl scene. }

	glut-MainLoop				; The Main Loop

	halt
]
]
