REBOL [
   Title: "OpenGL Test"
   Author: "Cal Dixon"
   Date: 11-Mar-2003
   File: %opengl.r
   Purpose: "Demonstrate the use of OpenGL in View/Pro on Windows"
   Library: [
        level: 'advanced
        platform: 'windows
        type: [demo script module]
        domain: [animation external-library graphics win-api]
        tested-under: [view 1.2.10.3.1 W2K]
        support: none
        license: 'MIT
        see-also: none
      ]
   ]

;
; OpenGL.R Test (c) 2003 Cal Dixon.
;

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

to-ieee: func [d /local exp fractionbits mantissa m a b c][
   exp: log-2 abs d
   exp: to-integer exp
   fractionbits: max 0 (23 - exp)
   mantissa: (abs d) / (2 ** exp)
   m: to-integer mantissa * (2 ** fractionbits)
   a: join to-binary to-char either negative? d [128][0] #{000000}
   b: to-binary to-char exp + 127 #{000000}
   c: to-binary-int m
   a or b or c
   ]

intel-integer-passthru-ieee: func [d][
   to-integer to-binary-int/intel to-integer to-ieee d
   ]

to-bin-array: func [ type block /local out value ][
   out: make binary! 4 * length? block
   foreach value block [
      insert tail out third make struct! compose/deep [ a [(type)] ] reduce [value]
      ]
   out
   ]

int-pointer-to-integer: func [data][
   to-integer head reverse copy/part data 4
   ]

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
PIXELFORMATDESCRIPTOR: make struct! PIXELFORMATDESCRIPTOR-def none

PFD_DOUBLEBUFFER: to-integer #{00000001}
PFD_STEREO: to-integer #{00000002}
PFD_DRAW_TO_WINDOW: to-integer #{00000004}
PFD_DRAW_TO_BITMAP: to-integer #{00000008}
PFD_SUPPORT_GDI: to-integer #{00000010}
PFD_SUPPORT_OPENGL: to-integer #{00000020}
PFD_GENERIC_FORMAT: to-integer #{00000040}
PFD_NEED_PALETTE: to-integer #{00000080}
PFD_NEED_SYSTEM_PALETTE: to-integer #{00000100}
PFD_SWAP_EXCHANGE: to-integer #{00000200}
PFD_SWAP_COPY: to-integer #{00000400}
PFD_SWAP_LAYER_BUFFERS: to-integer #{00000800}
PFD_GENERIC_ACCELERATED: to-integer #{00001000}
PFD_SUPPORT_DIRECTDRAW: to-integer #{00002000} 
PFD_TYPE_RGBA: to-char 0
PFD_TYPE_COLORINDEX: to-char 1 
PFD_MAIN_PLANE: to-char 0
PFD_OVERLAY_PLANE: to-char 1
PFD_UNDERLAY_PLANE: to-char 255
GL_TRIANGLES: 4
GL_CURRENT_BIT: to-integer #{00000001}
GL_POINT_BIT: to-integer #{00000002}
GL_LINE_BIT: to-integer #{00000004}
GL_POLYGON_BIT: to-integer #{00000008}
GL_POLYGON_STIPPLE_BIT: to-integer #{00000010}
GL_PIXEL_MODE_BIT: to-integer #{00000020}
GL_LIGHTING_BIT: to-integer #{00000040}
GL_FOG_BIT: to-integer #{00000080}
GL_DEPTH_BUFFER_BIT: to-integer #{00000100}
GL_ACCUM_BUFFER_BIT: to-integer #{00000200}
GL_STENCIL_BUFFER_BIT: to-integer #{00000400}
GL_VIEWPORT_BIT: to-integer #{00000800}
GL_TRANSFORM_BIT: to-integer #{00001000}
GL_ENABLE_BIT: to-integer #{00002000}
GL_COLOR_BUFFER_BIT: to-integer #{00004000}
GL_HINT_BIT: to-integer #{00008000}
GL_EVAL_BIT: to-integer #{00010000}
GL_LIST_BIT: to-integer #{00020000}
GL_TEXTURE_BIT: to-integer #{00040000}
GL_SCISSOR_BIT: to-integer #{00080000}
GL_ALL_ATTRIB_BITS: to-integer #{000fffff}

GL_COLOR_INDEX: to-integer #{1900}
GL_STENCIL_INDEX: to-integer #{1901}
GL_DEPTH_COMPONENT: to-integer #{1902}
GL_RED: to-integer #{1903}
GL_GREEN: to-integer #{1904}
GL_BLUE: to-integer #{1905}
GL_ALPHA: to-integer #{1906}
GL_RGB: to-integer #{1907}
GL_RGBA: to-integer #{1908}
GL_LUMINANCE: to-integer #{1909}
GL_LUMINANCE_ALPHA: to-integer #{190A}
GL_BGR_EXT: to-integer #{80E0}
GL_BGRA_EXT: to-integer #{80E1}
GL_BYTE: to-integer #{1400}
GL_UNSIGNED_BYTE: to-integer #{1401}
GL_SHORT: to-integer #{1402}
GL_UNSIGNED_SHORT: to-integer #{1403}
GL_INT: to-integer #{1404}
GL_UNSIGNED_INT: to-integer #{1405}
GL_FLOAT: to-integer #{1406}
GL_2_BYTES: to-integer #{1407}
GL_3_BYTES: to-integer #{1408}
GL_4_BYTES: to-integer #{1409}
GL_DOUBLE: to-integer #{140A}
GL_CURRENT_COLOR: to-integer #{0B00}
GL_CURRENT_INDEX: to-integer #{0B01}
GL_CURRENT_NORMAL: to-integer #{0B02}
GL_CURRENT_TEXTURE_COORDS: to-integer #{0B03}
GL_CURRENT_RASTER_COLOR: to-integer #{0B04}
GL_CURRENT_RASTER_INDEX: to-integer #{0B05}
GL_CURRENT_RASTER_TEXTURE_COORDS: to-integer #{0B06}
GL_CURRENT_RASTER_POSITION: to-integer #{0B07}
GL_CURRENT_RASTER_POSITION_VALID: to-integer #{0B08}
GL_CURRENT_RASTER_DISTANCE: to-integer #{0B09}
GL_POINT_SMOOTH: to-integer #{0B10}
GL_POINT_SIZE: to-integer #{0B11}
GL_POINT_SIZE_RANGE: to-integer #{0B12}
GL_POINT_SIZE_GRANULARITY: to-integer #{0B13}
GL_LINE_SMOOTH: to-integer #{0B20}
GL_LINE_WIDTH: to-integer #{0B21}
GL_LINE_WIDTH_RANGE: to-integer #{0B22}
GL_LINE_WIDTH_GRANULARITY: to-integer #{0B23}
GL_LINE_STIPPLE: to-integer #{0B24}
GL_LINE_STIPPLE_PATTERN: to-integer #{0B25}
GL_LINE_STIPPLE_REPEAT: to-integer #{0B26}
GL_LIST_MODE: to-integer #{0B30}
GL_MAX_LIST_NESTING: to-integer #{0B31}
GL_LIST_BASE: to-integer #{0B32}
GL_LIST_INDEX: to-integer #{0B33}
GL_POLYGON_MODE: to-integer #{0B40}
GL_POLYGON_SMOOTH: to-integer #{0B41}
GL_POLYGON_STIPPLE: to-integer #{0B42}
GL_EDGE_FLAG: to-integer #{0B43}
GL_CULL_FACE: to-integer #{0B44}
GL_CULL_FACE_MODE: to-integer #{0B45}
GL_FRONT_FACE: to-integer #{0B46}
GL_LIGHTING: to-integer #{0B50}
GL_LIGHT_MODEL_LOCAL_VIEWER: to-integer #{0B51}
GL_LIGHT_MODEL_TWO_SIDE: to-integer #{0B52}
GL_LIGHT_MODEL_AMBIENT: to-integer #{0B53}
GL_SHADE_MODEL: to-integer #{0B54}
GL_COLOR_MATERIAL_FACE: to-integer #{0B55}
GL_COLOR_MATERIAL_PARAMETER: to-integer #{0B56}
GL_COLOR_MATERIAL: to-integer #{0B57}
GL_FOG: to-integer #{0B60}
GL_FOG_INDEX: to-integer #{0B61}
GL_FOG_DENSITY: to-integer #{0B62}
GL_FOG_START: to-integer #{0B63}
GL_FOG_END: to-integer #{0B64}
GL_FOG_MODE: to-integer #{0B65}
GL_FOG_COLOR: to-integer #{0B66}
GL_DEPTH_RANGE: to-integer #{0B70}
GL_DEPTH_TEST: to-integer #{0B71}
GL_DEPTH_WRITEMASK: to-integer #{0B72}
GL_DEPTH_CLEAR_VALUE: to-integer #{0B73}
GL_DEPTH_FUNC: to-integer #{0B74}
GL_ACCUM_CLEAR_VALUE: to-integer #{0B80}
GL_STENCIL_TEST: to-integer #{0B90}
GL_STENCIL_CLEAR_VALUE: to-integer #{0B91}
GL_STENCIL_FUNC: to-integer #{0B92}
GL_STENCIL_VALUE_MASK: to-integer #{0B93}
GL_STENCIL_FAIL: to-integer #{0B94}
GL_STENCIL_PASS_DEPTH_FAIL: to-integer #{0B95}
GL_STENCIL_PASS_DEPTH_PASS: to-integer #{0B96}
GL_STENCIL_REF: to-integer #{0B97}
GL_STENCIL_WRITEMASK: to-integer #{0B98}
GL_MATRIX_MODE: to-integer #{0BA0}
GL_NORMALIZE: to-integer #{0BA1}
GL_VIEWPORT: to-integer #{0BA2}
GL_MODELVIEW_STACK_DEPTH: to-integer #{0BA3}
GL_PROJECTION_STACK_DEPTH: to-integer #{0BA4}
GL_TEXTURE_STACK_DEPTH: to-integer #{0BA5}
GL_MODELVIEW_MATRIX: to-integer #{0BA6}
GL_PROJECTION_MATRIX: to-integer #{0BA7}
GL_TEXTURE_MATRIX: to-integer #{0BA8}
GL_ATTRIB_STACK_DEPTH: to-integer #{0BB0}
GL_CLIENT_ATTRIB_STACK_DEPTH: to-integer #{0BB1}
GL_ALPHA_TEST: to-integer #{0BC0}
GL_ALPHA_TEST_FUNC: to-integer #{0BC1}
GL_ALPHA_TEST_REF: to-integer #{0BC2}
GL_DITHER: to-integer #{0BD0}
GL_BLEND_DST: to-integer #{0BE0}
GL_BLEND_SRC: to-integer #{0BE1}
GL_BLEND: to-integer #{0BE2}
GL_LOGIC_OP_MODE: to-integer #{0BF0}
GL_INDEX_LOGIC_OP: to-integer #{0BF1}
GL_COLOR_LOGIC_OP: to-integer #{0BF2}
GL_AUX_BUFFERS: to-integer #{0C00}
GL_DRAW_BUFFER: to-integer #{0C01}
GL_READ_BUFFER: to-integer #{0C02}
GL_SCISSOR_BOX: to-integer #{0C10}
GL_SCISSOR_TEST: to-integer #{0C11}
GL_INDEX_CLEAR_VALUE: to-integer #{0C20}
GL_INDEX_WRITEMASK: to-integer #{0C21}
GL_COLOR_CLEAR_VALUE: to-integer #{0C22}
GL_COLOR_WRITEMASK: to-integer #{0C23}
GL_INDEX_MODE: to-integer #{0C30}
GL_RGBA_MODE: to-integer #{0C31}
GL_DOUBLEBUFFER: to-integer #{0C32}
GL_STEREO: to-integer #{0C33}
GL_RENDER_MODE: to-integer #{0C40}
GL_PERSPECTIVE_CORRECTION_HINT: to-integer #{0C50}
GL_POINT_SMOOTH_HINT: to-integer #{0C51}
GL_LINE_SMOOTH_HINT: to-integer #{0C52}
GL_POLYGON_SMOOTH_HINT: to-integer #{0C53}
GL_FOG_HINT: to-integer #{0C54}
GL_TEXTURE_GEN_S: to-integer #{0C60}
GL_TEXTURE_GEN_T: to-integer #{0C61}
GL_TEXTURE_GEN_R: to-integer #{0C62}
GL_TEXTURE_GEN_Q: to-integer #{0C63}
GL_PIXEL_MAP_I_TO_I: to-integer #{0C70}
GL_PIXEL_MAP_S_TO_S: to-integer #{0C71}
GL_PIXEL_MAP_I_TO_R: to-integer #{0C72}
GL_PIXEL_MAP_I_TO_G: to-integer #{0C73}
GL_PIXEL_MAP_I_TO_B: to-integer #{0C74}
GL_PIXEL_MAP_I_TO_A: to-integer #{0C75}
GL_PIXEL_MAP_R_TO_R: to-integer #{0C76}
GL_PIXEL_MAP_G_TO_G: to-integer #{0C77}
GL_PIXEL_MAP_B_TO_B: to-integer #{0C78}
GL_PIXEL_MAP_A_TO_A: to-integer #{0C79}
GL_PIXEL_MAP_I_TO_I_SIZE: to-integer #{0CB0}
GL_PIXEL_MAP_S_TO_S_SIZE: to-integer #{0CB1}
GL_PIXEL_MAP_I_TO_R_SIZE: to-integer #{0CB2}
GL_PIXEL_MAP_I_TO_G_SIZE: to-integer #{0CB3}
GL_PIXEL_MAP_I_TO_B_SIZE: to-integer #{0CB4}
GL_PIXEL_MAP_I_TO_A_SIZE: to-integer #{0CB5}
GL_PIXEL_MAP_R_TO_R_SIZE: to-integer #{0CB6}
GL_PIXEL_MAP_G_TO_G_SIZE: to-integer #{0CB7}
GL_PIXEL_MAP_B_TO_B_SIZE: to-integer #{0CB8}
GL_PIXEL_MAP_A_TO_A_SIZE: to-integer #{0CB9}
GL_UNPACK_SWAP_BYTES: to-integer #{0CF0}
GL_UNPACK_LSB_FIRST: to-integer #{0CF1}
GL_UNPACK_ROW_LENGTH: to-integer #{0CF2}
GL_UNPACK_SKIP_ROWS: to-integer #{0CF3}
GL_UNPACK_SKIP_PIXELS: to-integer #{0CF4}
GL_UNPACK_ALIGNMENT: to-integer #{0CF5}
GL_PACK_SWAP_BYTES: to-integer #{0D00}
GL_PACK_LSB_FIRST: to-integer #{0D01}
GL_PACK_ROW_LENGTH: to-integer #{0D02}
GL_PACK_SKIP_ROWS: to-integer #{0D03}
GL_PACK_SKIP_PIXELS: to-integer #{0D04}
GL_PACK_ALIGNMENT: to-integer #{0D05}
GL_MAP_COLOR: to-integer #{0D10}
GL_MAP_STENCIL: to-integer #{0D11}
GL_INDEX_SHIFT: to-integer #{0D12}
GL_INDEX_OFFSET: to-integer #{0D13}
GL_RED_SCALE: to-integer #{0D14}
GL_RED_BIAS: to-integer #{0D15}
GL_ZOOM_X: to-integer #{0D16}
GL_ZOOM_Y: to-integer #{0D17}
GL_GREEN_SCALE: to-integer #{0D18}
GL_GREEN_BIAS: to-integer #{0D19}
GL_BLUE_SCALE: to-integer #{0D1A}
GL_BLUE_BIAS: to-integer #{0D1B}
GL_ALPHA_SCALE: to-integer #{0D1C}
GL_ALPHA_BIAS: to-integer #{0D1D}
GL_DEPTH_SCALE: to-integer #{0D1E}
GL_DEPTH_BIAS: to-integer #{0D1F}
GL_MAX_EVAL_ORDER: to-integer #{0D30}
GL_MAX_LIGHTS: to-integer #{0D31}
GL_MAX_CLIP_PLANES: to-integer #{0D32}
GL_MAX_TEXTURE_SIZE: to-integer #{0D33}
GL_MAX_PIXEL_MAP_TABLE: to-integer #{0D34}
GL_MAX_ATTRIB_STACK_DEPTH: to-integer #{0D35}
GL_MAX_MODELVIEW_STACK_DEPTH: to-integer #{0D36}
GL_MAX_NAME_STACK_DEPTH: to-integer #{0D37}
GL_MAX_PROJECTION_STACK_DEPTH: to-integer #{0D38}
GL_MAX_TEXTURE_STACK_DEPTH: to-integer #{0D39}
GL_MAX_VIEWPORT_DIMS: to-integer #{0D3A}
GL_MAX_CLIENT_ATTRIB_STACK_DEPTH: to-integer #{0D3B}
GL_SUBPIXEL_BITS: to-integer #{0D50}
GL_INDEX_BITS: to-integer #{0D51}
GL_RED_BITS: to-integer #{0D52}
GL_GREEN_BITS: to-integer #{0D53}
GL_BLUE_BITS: to-integer #{0D54}
GL_ALPHA_BITS: to-integer #{0D55}
GL_DEPTH_BITS: to-integer #{0D56}
GL_STENCIL_BITS: to-integer #{0D57}
GL_ACCUM_RED_BITS: to-integer #{0D58}
GL_ACCUM_GREEN_BITS: to-integer #{0D59}
GL_ACCUM_BLUE_BITS: to-integer #{0D5A}
GL_ACCUM_ALPHA_BITS: to-integer #{0D5B}
GL_NAME_STACK_DEPTH: to-integer #{0D70}
GL_AUTO_NORMAL: to-integer #{0D80}
GL_MAP1_COLOR_4: to-integer #{0D90}
GL_MAP1_INDEX: to-integer #{0D91}
GL_MAP1_NORMAL: to-integer #{0D92}
GL_MAP1_TEXTURE_COORD_1: to-integer #{0D93}
GL_MAP1_TEXTURE_COORD_2: to-integer #{0D94}
GL_MAP1_TEXTURE_COORD_3: to-integer #{0D95}
GL_MAP1_TEXTURE_COORD_4: to-integer #{0D96}
GL_MAP1_VERTEX_3: to-integer #{0D97}
GL_MAP1_VERTEX_4: to-integer #{0D98}
GL_MAP2_COLOR_4: to-integer #{0DB0}
GL_MAP2_INDEX: to-integer #{0DB1}
GL_MAP2_NORMAL: to-integer #{0DB2}
GL_MAP2_TEXTURE_COORD_1: to-integer #{0DB3}
GL_MAP2_TEXTURE_COORD_2: to-integer #{0DB4}
GL_MAP2_TEXTURE_COORD_3: to-integer #{0DB5}
GL_MAP2_TEXTURE_COORD_4: to-integer #{0DB6}
GL_MAP2_VERTEX_3: to-integer #{0DB7}
GL_MAP2_VERTEX_4: to-integer #{0DB8}
GL_MAP1_GRID_DOMAIN: to-integer #{0DD0}
GL_MAP1_GRID_SEGMENTS: to-integer #{0DD1}
GL_MAP2_GRID_DOMAIN: to-integer #{0DD2}
GL_MAP2_GRID_SEGMENTS: to-integer #{0DD3}
GL_TEXTURE_1D: to-integer #{0DE0}
GL_TEXTURE_2D: to-integer #{0DE1}
GL_FEEDBACK_BUFFER_POINTER: to-integer #{0DF0}
GL_FEEDBACK_BUFFER_SIZE: to-integer #{0DF1}
GL_FEEDBACK_BUFFER_TYPE: to-integer #{0DF2}
GL_SELECTION_BUFFER_POINTER: to-integer #{0DF3}
GL_SELECTION_BUFFER_SIZE: to-integer #{0DF4}
GL_S: to-integer #{2000}
GL_T: to-integer #{2001}
GL_R: to-integer #{2002}
GL_Q: to-integer #{2003}
GL_MODULATE: to-integer #{2100}
GL_DECAL: to-integer #{2101}
GL_TEXTURE_ENV_MODE: to-integer #{2200}
GL_TEXTURE_ENV_COLOR: to-integer #{2201}
GL_TEXTURE_ENV: to-integer #{2300}
GL_NEAREST: to-integer #{2600}
GL_LINEAR: to-integer #{2601}
GL_NEAREST_MIPMAP_NEAREST: to-integer #{2700}
GL_LINEAR_MIPMAP_NEAREST: to-integer #{2701}
GL_NEAREST_MIPMAP_LINEAR: to-integer #{2702}
GL_LINEAR_MIPMAP_LINEAR: to-integer #{2703}
GL_TEXTURE_MAG_FILTER: to-integer #{2800}
GL_TEXTURE_MIN_FILTER: to-integer #{2801}
GL_TEXTURE_WRAP_S: to-integer #{2802}
GL_TEXTURE_WRAP_T: to-integer #{2803}
GL_CLAMP: to-integer #{2900}
GL_REPEAT: to-integer #{2901}

user32: load/library %user32.dll
gdi32: load/library %gdi32.dll
opengl: load/library %Opengl32.dll

findwindow: make routine! [class [int] name [string!] return: [int]] user32 "FindWindowA"

GetDC: make routine! [
   hWnd [integer!]
   return: [integer!]
   ] user32 "GetDC"

ReleaseDC: make routine! [
   hWnd [integer!]
   hDC [integer!]
   ] user32 "ReleaseDC"

ValidateRect: make routine! [
   hWnd [integer!]
   rect [integer!] ; really a (RECT *), but can be passed NULL
   return: [integer!] ; really a (BOOL)
   ] user32 "ValidateRect"

ChoosePixelFormat: make routine! compose/deep/only [
   hdc [integer!]
   ppfd [struct! (PIXELFORMATDESCRIPTOR-def)]
   return: [integer!]
   ] gdi32 "ChoosePixelFormat"

SetPixelFormat: make routine! compose/deep/only [
   hdc [integer!]
   iPixelFormat [integer!]
   ppfd [struct! (PIXELFORMATDESCRIPTOR-def)]
   return: [integer!]
   ] gdi32 "SetPixelFormat"

SwapBuffers: make routine! [
   hDC [integer!]
   return: [integer!]
   ] gdi32 "SwapBuffers"

wglCreateContext: make routine! [
   hDC [integer!]
   return: [integer!]
   ] opengl "wglCreateContext"

wglMakeCurrent: make routine! [
   hDC [integer!]
   hRC [integer!]
   ] opengl "wglMakeCurrent"

wglGetCurrentContext: make routine! [
   return: [integer!]
   ] opengl "wglGetCurrentContext"

wglGetCurrentDC: make routine! [
   return: [integer!]
   ] opengl "wglGetCurrentDC"

wglDeleteContext: make routine! [
   hRC [integer!]
   ] opengl "wglDeleteContext"

glPushMatrix: make routine! [] opengl "glPushMatrix"

glPopMatrix: make routine! [] opengl "glPopMatrix"

glClearColor: make routine! [
   red [float]
   green [float]
   blue  [float]
   alpha  [float]
   ] opengl "glClearColor"

glClear: make routine! [
   mask [integer!]
   ] opengl "glClear"

glEnable: make routine! [
   cap [integer!]
   ] opengl "glEnable"

glDisable: make routine! [
   cap [integer!]
   ] opengl "glDisable"

glOrtho: make routine! [
   left [decimal!]
   right [decimal!]
   bottom [decimal!]
   top [decimal!]
   near [decimal!]
   far [decimal!]
   ] opengl "glOrtho"

glFrustum: make routine! [
   left [decimal!]
   right [decimal!]
   bottom [decimal!]
   top [decimal!]
   near [decimal!]
   far [decimal!]
   ] opengl "glFrustum"

glRotate: make routine! [
   angle [decimal!]
   x [decimal!]
   y [decimal!]
   z [decimal!]
   ] opengl "glRotated"

glTranslated: make routine! [
   x [decimal!]
   y [decimal!]
   z [decimal!]
   ] opengl "glTranslated"

glColor3: make routine! [
   red [decimal!]
   green [decimal!]
   blue [decimal!]
   ] opengl "glColor3d"

glVertex2: make routine! [
   x [decimal!]
   y [decimal!]
   ] opengl "glVertex2d"

glVertex3d: make routine! [
   x [decimal!]
   y [decimal!]
   z [decimal!]
   ] opengl "glVertex3d"

glBegin: make routine! [
   mode [integer!]
   ] opengl "glBegin"

glDrawPixels:  make routine! [
   width [int]
   height [int]
   format [int]
   type [int]
   pixels [binary!]
   ] opengl "glDrawPixels"

glTexImage2D: make routine! [
   target [int]
   level [int]
   internalformat [int]
   width [int]
   height [int]
   border [int]
   format [int]
   type [int]
   pixels [binary!]
   ] opengl "glTexImage2D"

glTexCoord2d: make routine! [
   x [double]
   y [double]
   ] opengl "glTexCoord2d"
 
glGenTextures: make routine! [
   n [int]
   textures [binary!]
   ] opengl "glGenTextures"

glBindTexture: make routine! [
   target [int]
   texture [int]
   ] opengl "glBindTexture"

glTexEnvf: make routine! [
   target [int]
   pname [int]
   param [float]
   ] opengl "glTexEnvf"

glTexEnvi: make routine! [
   target [int]
   pname [int]
   param [int]
   ] opengl "glTexEnvi"

glTexParameteri: make routine! [
   target [int]
   pname [int]
   param [int]
   ] opengl "glTexParameteri"

glTexParameterf: make routine! [
   target [int]
   pname [int]
   param [float]
   ] opengl "glTexParameterf"

glRasterPos3d: make routine! [
   x [double]
   y [double]
   z [double]
   ] opengl "glRasterPos3d"

glEnd: make routine! [] opengl "glEnd"

picture: to-image layout/size [at 0x0 image 100x24 logo.gif effect [flip 0x1] ] logo.gif/size
imagebin: to-binary picture
texture: to-image layout/size [at 0x0 image 128x128 logo.gif effect [fit flip 0x1] ] 128x128
texturebin: to-binary texture

view/title/new layout [ size 512x512 at 0x0
   control: box 512x512 feel [
      engage: func [f a e][
         if a = 'over [ transx: e/offset/x transy: 512.0 - e/offset/y ]
         if a = 'key [
            wglMakeCurrent oldhDC oldhRC
            wglDeleteContext hRC
            releasedc 0 hdc
            free user32
            free gdi32
            free opengl
            quit
            ]
         if a = 'alt-down [ thetabump: -1.0 ]
         if a = 'alt-up [ thetabump: 1.0 ]
         ]
      ]
   ] "Test"

print "Press any key while in the 3D window to quit.  Click and drag to move the cube."
focus control

hWnd: findwindow 0 "REBOL - Test"
hdc: getdc hWnd
pfd: make struct! PIXELFORMATDESCRIPTOR none

   pfd/nSize: length? third pfd
   pfd/nVersion: 1
   pfd/dwFlags: PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
   pfd/iPixelType: PFD_TYPE_RGBA
   pfd/cColorBits: to-char 24
   pfd/cDepthBits: to-char 16
   pfd/iLayerType: PFD_MAIN_PLANE
   format: ChoosePixelFormat hDC pfd
   SetPixelFormat hDC format pfd

   hRC: wglCreateContext hDC
   oldhRC: wglGetCurrentContext
   oldhDC: wglGetCurrentDC
   wglMakeCurrent hDC hRC
   glEnable GL_DEPTH_TEST
   glEnable GL_CULL_FACE
   glEnable GL_TEXTURE_2D
texname: #{00000000}
glGenTextures 1 texname
texname: int-pointer-to-integer texname
glBindTexture GL_TEXTURE_2D texname
glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_REPEAT
glTexParameteri GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_REPEAT
glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR
glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR
glTexEnvf GL_TEXTURE_ENV GL_TEXTURE_ENV_MODE GL_MODULATE
glTexImage2d GL_TEXTURE_2D 0 4 128 128 0 GL_BGRA_EXT GL_UNSIGNED_BYTE texturebin

; --- insert code here ---
theta: 0.0
thetabump: 1.0
transx: 0.0
transy: 0.0

frames: 720
t: now/time/precise
n: 0
while [not empty? system/view/screen-face/pane] [
			glClearColor 0.0 0.0 0.0 0.0
			glClear GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT
			;glRasterPos3d 0 -1 0
			;glDrawPixels 100 24 GL_BGRA_EXT GL_UNSIGNED_BYTE imagebin

			glPushMatrix
			glTranslated -1.0 + (transx / 256) -1.0 + (transy / 256) 0.0
			glRotate theta 1.0 1.0 1.0
			glEnable GL_TEXTURE_2D
			glBindTexture GL_TEXTURE_2D texname
			glBegin GL_TRIANGLES
                  loop 1 [
			;glColor3 1.0 0.0 0.0 glVertex3d 0.0 1.0 0.0
			;glColor3 0.0 1.0 0.0 glVertex3d 0.87 -0.5 0.0
			;glColor3 0.0 0.0 1.0 glVertex3d -0.87 -0.5 0.0


; front / blue

glColor3 0.0 0.0 1.0

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
glColor3 1.0 0.0 0.0

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
glColor3 1.0 1.0 0.0

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
glColor3 0.0 1.0 0.0

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
glColor3 0.0 1.0 1.0

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
glColor3 1.0 0.0 1.0

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

                  ]
			glEnd
			glPopMatrix
			
			SwapBuffers hDC
			wait 0

			theta: theta + thetabump
                  n: n + 1
                  if n > 2000000000 [ n: 0 t: now/time/precise ]
wait 0
]
print rejoin ["" n / to-decimal (now/time/precise - t) " fps"]
; --- end app code ---

   wglMakeCurrent oldhDC oldhRC
   wglDeleteContext hRC

releasedc 0 hdc

free user32
free gdi32
free opengl
halt
quit


comment {
load a
out: copy "" foreach [dd word value] parse a none [
   append out reform [mold to-set-word word "to-integer" rejoin ["#{" skip value 2 "}" newline] ]
   ]
write clipboard:// out
}