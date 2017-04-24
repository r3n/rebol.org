REBOL [
	title: "FMOD library interface"
	file: %fmod-h.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 05-11-2011
	version: 0.9.0
	needs: {
		- FMODEX shared library version 4.36.04 or newer in the same directory (or adjust first lines)
		- 3 sound samples to run the example at the end that you find in the FMOD distribution
	}
	comment: {ONLY A FEW FUNCTIONs TESTED !!!! Use example code to test others.
		See REBOL-NOTEs in example code at the end for rebol-specific implementation issues.
	}
	Purpose: "Code to bind FMOD shared library to Rebol."
	History: [
		0.0.1 [27-09-2011 "First version"]
		0.9.0 [05-11-2011 "Example completed"]
	]
	Category: [library music sound]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'module
		domain: [sound external-library]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: none
		see-also: none
	]
]

	;;;
	;;;REBOL-NOTE: use this function to access pointers
	;;;
	int-ptr: does [make struct! [value [integer!]] none]
	
	lib: switch/default System/version/4 [
		2 [%fmodex.dylib]	;OSX
		3 [%fmodex.dll]		;Windows
	] [%fmodex.so]

	if not fmod-lib: load/library lib [alert "FMOD library not found. Quit" quit]

{ ============================================================================================ }
{ FMOD Ex - Main C/C++ header file. Copyright (c), Firelight Technologies Pty, Ltd. 2004-2011. }
{                                                                                              }
{ This header is the base header for all other FMOD headers.  If you are programming in C      }
{ use this exclusively, or if you are programming C++ use this in conjunction with FMOD.HPP    }
{                                                                                              }
{ ============================================================================================ }

{
    FMOD version number.  Check this against FMOD::System::getVersion.
    0xaaaabbcc -> aaaa = major version number.  bb = minor version number.  cc = development version number.
}

FMOD_VERSION:    275972 ;#00043604

{
    Compiler specific settings.
}
{
#define F_CALLBACK F_STDCALL
}
{
    FMOD types.
}

FMOD_BOOL: integer!
{typedef struct FMOD_SYSTEM        FMOD_SYSTEM
typedef struct FMOD_SOUND         FMOD_SOUND
typedef struct FMOD_CHANNEL       FMOD_CHANNEL
typedef struct FMOD_CHANNELGROUP  FMOD_CHANNELGROUP
typedef struct FMOD_SOUNDGROUP    FMOD_SOUNDGROUP
typedef struct FMOD_REVERB        FMOD_REVERB
typedef struct FMOD_DSP           FMOD_DSP
typedef struct FMOD_DSPCONNECTION FMOD_DSPCONNECTION
typedef struct FMOD_POLYGON		  FMOD_POLYGON
typedef struct FMOD_GEOMETRY	  FMOD_GEOMETRY
typedef struct FMOD_SYNCPOINT	  FMOD_SYNCPOINT}
FMOD_MODE: integer!
FMOD_TIMEUNIT: integer!
FMOD_INITFLAGS: integer!
FMOD_CAPS: integer!
FMOD_DEBUGLEVEL: integer!
FMOD_MEMORY_TYPE: integer!

{
[ENUM]
[
    [DESCRIPTION]   
    error codes.  Returned from every function.

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
]
}
FMOD_Errors: reduce [
FMOD_OK: 0 { No errors. }
FMOD_ERR_ALREADYLOCKED: 1 { Tried to call lock a second time before unlock was called. }
FMOD_ERR_BADCOMMAND: 2 { Tried to call a function on a data type that does not allow this type of functionality (ie calling Sound::lock on a streaming sound). }
FMOD_ERR_CDDA_DRIVERS: 3 { Neither NTSCSI nor ASPI could be initialised. }
FMOD_ERR_CDDA_INIT: 4 { An error occurred while initialising the CDDA subsystem. }
FMOD_ERR_CDDA_INVALID_DEVICE: 5 { Couldn't find the specified device. }
FMOD_ERR_CDDA_NOAUDIO: 6 { No audio tracks on the specified disc. }
FMOD_ERR_CDDA_NODEVICES: 7 { No CD/DVD devices were found. }
FMOD_ERR_CDDA_NODISC: 8 { No disc present in the specified drive. }
FMOD_ERR_CDDA_READ: 9 { A CDDA read error occurred. }
FMOD_ERR_CHANNEL_ALLOC: 10 { Error trying to allocate a channel. }
FMOD_ERR_CHANNEL_STOLEN: 11 { The specified channel has been reused to play another sound. }
FMOD_ERR_COM: 12 { A Win32 COM related error occured. COM failed to initialize or a QueryInterface failed meaning a Windows codec or driver was not installed properly. }
FMOD_ERR_DMA: 13 { DMA Failure.  See debug output for more information. }
FMOD_ERR_DSP_CONNECTION: 14 { DSP connection error.  Connection possibly caused a cyclic dependancy.  Or tried to connect a tree too many units deep (more than 128). }
FMOD_ERR_DSP_FORMAT: 15 { DSP Format error.  A DSP unit may have attempted to connect to this network with the wrong format. }
FMOD_ERR_DSP_NOTFOUND: 16 { DSP connection error.  Couldn't find the DSP unit specified. }
FMOD_ERR_DSP_RUNNING: 17 { DSP error.  Cannot perform this operation while the network is in the middle of running.  This will most likely happen if a connection or disconnection is attempted in a DSP callback. }
FMOD_ERR_DSP_TOOMANYCONNECTIONS: 18 { DSP connection error.  The unit being connected to or disconnected should only have 1 input or output. }
FMOD_ERR_FILE_BAD: 19 { Error loading file. }
FMOD_ERR_FILE_COULDNOTSEEK: 20 { Couldn't perform seek operation.  This is a limitation of the medium (ie netstreams) or the file format. }
FMOD_ERR_FILE_DISKEJECTED: 21 { Media was ejected while reading. }
FMOD_ERR_FILE_EOF: 22 { End of file unexpectedly reached while trying to read essential data (truncated data?). }
FMOD_ERR_FILE_NOTFOUND: 23 { File not found. }
FMOD_ERR_FILE_UNWANTED: 24 { Unwanted file access occured. }
FMOD_ERR_FORMAT: 25 { Unsupported file or audio format. }
FMOD_ERR_HTTP: 26 { A HTTP error occurred. This is a catch-all for HTTP errors not listed elsewhere. }
FMOD_ERR_HTTP_ACCESS: 27 { The specified resource requires authentication or is forbidden. }
FMOD_ERR_HTTP_PROXY_AUTH: 28 { Proxy authentication is required to access the specified resource. }
FMOD_ERR_HTTP_SERVER_ERROR: 29 { A HTTP server error occurred. }
FMOD_ERR_HTTP_TIMEOUT: 30 { The HTTP request timed out. }
FMOD_ERR_INITIALIZATION: 31 { FMOD was not initialized correctly to support this function. }
FMOD_ERR_INITIALIZED: 32 { Cannot call this command after System::init. }
FMOD_ERR_INTERNAL: 33 { An error occured that wasn't supposed to.  Contact support. }
FMOD_ERR_INVALID_ADDRESS: 34 { On Xbox 360, this memory address passed to FMOD must be physical, (ie allocated with XPhysicalAlloc.) }
FMOD_ERR_INVALID_FLOAT: 35 { Value passed in was a NaN, Inf or denormalized float. }
FMOD_ERR_INVALID_HANDLE: 36 { An invalid object handle was used. }
FMOD_ERR_INVALID_PARAM: 37 { An invalid parameter was passed to this function. }
FMOD_ERR_INVALID_POSITION: 38 { An invalid seek position was passed to this function. }
FMOD_ERR_INVALID_SPEAKER: 39 { An invalid speaker was passed to this function based on the current speaker mode. }
FMOD_ERR_INVALID_SYNCPOINT: 40 { The syncpoint did not come from this sound handle. }
FMOD_ERR_INVALID_VECTOR: 41 { The vectors passed in are not unit length, or perpendicular. }
FMOD_ERR_MAXAUDIBLE: 42 { Reached maximum audible playback count for this sound's soundgroup. }
FMOD_ERR_MEMORY: 43 { Not enough memory or resources. }
FMOD_ERR_MEMORY_CANTPOINT: 44 { Can't use FMOD_OPENMEMORY_POINT on non PCM source data, or non mp3/xma/adpcm data if FMOD_CREATECOMPRESSEDSAMPLE was used. }
FMOD_ERR_MEMORY_SRAM: 45 { Not enough memory or resources on console sound ram. }
FMOD_ERR_NEEDS2D: 46 { Tried to call a command on a 3d sound when the command was meant for 2d sound. }
FMOD_ERR_NEEDS3D: 47 { Tried to call a command on a 2d sound when the command was meant for 3d sound. }
FMOD_ERR_NEEDSHARDWARE: 48 { Tried to use a feature that requires hardware support.  (ie trying to play a GCADPCM compressed sound in software on Wii). }
FMOD_ERR_NEEDSSOFTWARE: 49 { Tried to use a feature that requires the software engine.  Software engine has either been turned off, or command was executed on a hardware channel which does not support this feature. }
FMOD_ERR_NET_CONNECT: 50 { Couldn't connect to the specified host. }
FMOD_ERR_NET_SOCKET_ERROR: 51 { A socket error occurred.  This is a catch-all for socket-related errors not listed elsewhere. }
FMOD_ERR_NET_URL: 52 { The specified URL couldn't be resolved. }
FMOD_ERR_NET_WOULD_BLOCK: 53 { Operation on a non-blocking socket could not complete immediately. }
FMOD_ERR_NOTREADY: 54 { Operation could not be performed because specified sound/DSP connection is not ready. }
FMOD_ERR_OUTPUT_ALLOCATED: 55 { Error initializing output device, but more specifically, the output device is already in use and cannot be reused. }
FMOD_ERR_OUTPUT_CREATEBUFFER: 56 { Error creating hardware sound buffer. }
FMOD_ERR_OUTPUT_DRIVERCALL: 57 { A call to a standard soundcard driver failed, which could possibly mean a bug in the driver or resources were missing or exhausted. }
FMOD_ERR_OUTPUT_ENUMERATION: 58 { Error enumerating the available driver list. List may be inconsistent due to a recent device addition or removal. }
FMOD_ERR_OUTPUT_FORMAT: 59 { Soundcard does not support the minimum features needed for this soundsystem (16bit stereo output). }
FMOD_ERR_OUTPUT_INIT: 60 { Error initializing output device. }
FMOD_ERR_OUTPUT_NOHARDWARE: 61 { FMOD_HARDWARE was specified but the sound card does not have the resources necessary to play it. }
FMOD_ERR_OUTPUT_NOSOFTWARE: 62 { Attempted to create a software sound but no software channels were specified in System::init. }
FMOD_ERR_PAN: 63 { Panning only works with mono or stereo sound sources. }
FMOD_ERR_PLUGIN: 64 { An unspecified error has been returned from a 3rd party plugin. }
FMOD_ERR_PLUGIN_INSTANCES: 65 { The number of allowed instances of a plugin has been exceeded. }
FMOD_ERR_PLUGIN_MISSING: 66 { A requested output, dsp unit type or codec was not available. }
FMOD_ERR_PLUGIN_RESOURCE: 67 { A resource that the plugin requires cannot be found. (ie the DLS file for MIDI playback) }
FMOD_ERR_PRELOADED: 68 { The specified sound is still in use by the event system, call EventSystem::unloadFSB before trying to release it. }
FMOD_ERR_PROGRAMMERSOUND: 69 { The specified sound is still in use by the event system, wait for the event which is using it finish with it. }
FMOD_ERR_RECORD: 70 { An error occured trying to initialize the recording device. }
FMOD_ERR_REVERB_INSTANCE: 71 { Specified instance in FMOD_REVERB_PROPERTIES couldn't be set. Most likely because it is an invalid instance number or the reverb doesnt exist. }
FMOD_ERR_SUBSOUND_ALLOCATED: 72 { This subsound is already being used by another sound, you cannot have more than one parent to a sound.  Null out the other parent's entry first. }
FMOD_ERR_SUBSOUND_CANTMOVE: 73 { Shared subsounds cannot be replaced or moved from their parent stream, such as when the parent stream is an FSB file. }
FMOD_ERR_SUBSOUND_MODE: 74 { The subsound's mode bits do not match with the parent sound's mode bits.  See documentation for function that it was called with. }
FMOD_ERR_SUBSOUNDS: 75 { The error occured because the sound referenced contains subsounds when it shouldn't have, or it doesn't contain subsounds when it should have.  The operation may also not be able to be performed on a parent sound, or a parent sound was played without setting up a sentence first. }
FMOD_ERR_TAGNOTFOUND: 76 { The specified tag could not be found or there are no tags. }
FMOD_ERR_TOOMANYCHANNELS: 77 { The sound created exceeds the allowable input channel count.  This can be increased using the maxinputchannels parameter in System::setSoftwareFormat. }
FMOD_ERR_UNIMPLEMENTED: 78 { Something in FMOD hasn't been implemented when it should be! contact support! }
FMOD_ERR_UNINITIALIZED: 79 { This command failed because System::init or System::setDriver was not called. }
FMOD_ERR_UNSUPPORTED: 80 { A command issued was not supported by this object.  Possibly a plugin without certain callbacks specified. }
FMOD_ERR_UPDATE: 81 { An error caused by System::update occured. }
FMOD_ERR_VERSION: 82 { The version number of this file format is not supported. }

FMOD_ERR_EVENT_FAILED: 83 { An Event failed to be retrieved, most likely due to 'just fail' being specified as the max playbacks behavior. }
FMOD_ERR_EVENT_INFOONLY: 84 { Can't execute this command on an EVENT_INFOONLY event. }
FMOD_ERR_EVENT_INTERNAL: 85 { An error occured that wasn't supposed to.  See debug log for reason. }
FMOD_ERR_EVENT_MAXSTREAMS: 86 { Event failed because 'Max streams' was hit when FMOD_EVENT_INIT_FAIL_ON_MAXSTREAMS was specified. }
FMOD_ERR_EVENT_MISMATCH: 87 { FSB mismatches the FEV it was compiled with, the stream/sample mode it was meant to be created with was different, or the FEV was built for a different platform. }
FMOD_ERR_EVENT_NAMECONFLICT: 88 { A category with the same name already exists. }
FMOD_ERR_EVENT_NOTFOUND: 89 { The requested event, event group, event category or event property could not be found. }
FMOD_ERR_EVENT_NEEDSSIMPLE: 90 { Tried to call a function on a complex event that's only supported by simple events. }
FMOD_ERR_EVENT_GUIDCONFLICT: 91 { An event with the same GUID already exists. }
FMOD_ERR_EVENT_ALREADY_LOADED: 92 { The specified project has already been loaded. Having multiple copies of the same project loaded simultaneously is forbidden. }

FMOD_ERR_MUSIC_UNINITIALIZED: 93 { Music system is not initialized probably because no music data is loaded. }
FMOD_ERR_MUSIC_NOTFOUND: 94 { The requested music entity could not be found. }
FMOD_ERR_MUSIC_NOCALLBACK: 95 { The music callback is required, but it has not been set. }

FMOD_RESULT_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
]
FMOD_RESULT: integer!

FMOD_ErrorString: func [result] [select FMOD_Errors result]

{
[STRUCTURE] 
[
    [DESCRIPTION]   
    Structure describing a point in 3D space.

    [REMARKS]
    FMOD uses a left handed co-ordinate system by default.
    To use a right handed co-ordinate system specify FMOD_INIT_3D_RIGHTHANDED from FMOD_INITFLAGS in System::init.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    System::set3DListenerAttributes
    System::get3DListenerAttributes
    Channel::set3DAttributes
    Channel::get3DAttributes
    Channel::set3DCustomRolloff
    Channel::get3DCustomRolloff
    Sound::set3DCustomRolloff
    Sound::get3DCustomRolloff
    Geometry::addPolygon
    Geometry::setPolygonVertex
    Geometry::getPolygonVertex
    Geometry::setRotation
    Geometry::getRotation
    Geometry::setPosition
    Geometry::getPosition
    Geometry::setScale
    Geometry::getScale
    FMOD_INITFLAGS
]
}
FMOD_VECTOR: make struct! [
  x [float] { X co-ordinate in 3D space. }
  y [float] { Y co-ordinate in 3D space. }
  z [float] { Z co-ordinate in 3D space. }
] none 

{
[STRUCTURE] 
[
    [DESCRIPTION]   
    Structure describing a globally unique identifier.

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    System::getDriverInfo
]
}
FMOD_GUID: make struct! [
  Data1 [integer!] { Specifies the first 8 hexadecimal digits of the GUID }
  Data2 [short] { Specifies the first group of 4 hexadecimal digits.   }
  Data3 [short] { Specifies the second group of 4 hexadecimal digits.  }
  Data4 [double] { Array of 8 bytes. The first 2 bytes contain the third group of 4 hexadecimal digits. The remaining 6 bytes contain the final 12 hexadecimal digits. }
] none 

{
[STRUCTURE] 
[
    [DESCRIPTION]
    Structure that is passed into FMOD_FILE_ASYNCREADCALLBACK.  Use the information in this structure to perform

    [REMARKS]
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.
    
    Instructions: write to 'buffer', and 'bytesread' <b>BEFORE</b> setting 'result'.  
    As soon as result is set, FMOD will asynchronously continue internally using the data provided in this structure.
    
    Set 'result' to the result expected from a normal file read callback.
    If the read was successful, set it to FMOD_OK.
    If it read some data but hit the end of the file, set it to FMOD_ERR_FILE_EOF.
    If a bad error occurred, return FMOD_ERR_FILE_BAD
    If a disk was ejected, return FMOD_ERR_FILE_DISKEJECTED.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    FMOD_FILE_ASYNCREADCALLBACK
    FMOD_FILE_ASYNCCANCELCALLBACK
]
}
FMOD_ASYNCREADINFO: make struct! [
  handle [integer!] { [r] The file handle that was filled out in the open callback. }
  offset [integer!] { [r] Seek position, make sure you read from this file offset. }
  sizebytes [integer!] { [r] how many bytes requested for read. }
  priority [integer!] { [r] 0 = low importance.  100 = extremely important (ie 'must read now or stuttering may occur') }

  buffer [integer!] { [w] Buffer to read file data into. }
  bytesread [integer!] { [w] Fill this in before setting result code to tell FMOD how many bytes were read. }
  result [FMOD_RESULT] { [r/w] Result code, FMOD_OK tells the system it is ready to consume the data.  Set this last!  Default value = FMOD_ERR_NOTREADY. }

  userdata [integer!] { [r] User data pointer. }
] none 


{
[ENUM]
[
    [DESCRIPTION]   
    These output types are used with System::setOutput / System::getOutput, to choose which output method to use.
  
    [REMARKS]
    To pass information to the driver when initializing fmod use the extradriverdata parameter in System::init for the following reasons.
    - FMOD_OUTPUTTYPE_WAVWRITER - extradriverdata is a pointer to a char * filename that the wav writer will output to.
    - FMOD_OUTPUTTYPE_WAVWRITER_NRT - extradriverdata is a pointer to a char * filename that the wav writer will output to.
    - FMOD_OUTPUTTYPE_DSOUND - extradriverdata is a pointer to a HWND so that FMOD can set the focus on the audio for a particular window.
    - FMOD_OUTPUTTYPE_PS3 - extradriverdata is a pointer to a FMOD_PS3_EXTRADRIVERDATA struct. This can be found in fmodps3.h.
    - FMOD_OUTPUTTYPE_GC - extradriverdata is a pointer to a FMOD_GC_INFO struct. This can be found in fmodgc.h.
    - FMOD_OUTPUTTYPE_WII - extradriverdata is a pointer to a FMOD_WII_INFO struct. This can be found in fmodwii.h.
    - FMOD_OUTPUTTYPE_ALSA - extradriverdata is a pointer to a FMOD_LINUX_EXTRADRIVERDATA struct. This can be found in fmodlinux.h.
    
    Currently these are the only FMOD drivers that take extra information.  Other unknown plugins may have different requirements.
    
    Note! If FMOD_OUTPUTTYPE_WAVWRITER_NRT or FMOD_OUTPUTTYPE_NOSOUND_NRT are used, and if the System::update function is being called
    very quickly (ie for a non realtime decode) it may be being called too quickly for the FMOD streamer thread to respond to.  
    The result will be a skipping/stuttering output in the captured audio.
    
    To remedy this, disable the FMOD Ex streamer thread, and use FMOD_INIT_STREAM_FROM_UPDATE to avoid skipping in the output stream,
    as it will lock the mixer and the streamer together in the same thread.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    System::setOutput
    System::getOutput
    System::setSoftwareFormat
    System::getSoftwareFormat
    System::init
    System::update
    FMOD_INITFLAGS
]
}
FMOD_OUTPUTTYPE_AUTODETECT: 0 { Picks the best output mode for the platform.  This is the default. }

FMOD_OUTPUTTYPE_UNKNOWN: 1 { All             - 3rd party plugin, unknown.  This is for use with System::getOutput only. }
FMOD_OUTPUTTYPE_NOSOUND: 2 { All             - All calls in this mode succeed but make no sound. }
FMOD_OUTPUTTYPE_WAVWRITER: 3 { All             - Writes output to fmodoutput.wav by default.  Use the 'extradriverdata' parameter in System::init, by simply passing the filename as a string, to set the wav filename. }
FMOD_OUTPUTTYPE_NOSOUND_NRT: 4 { All             - Non-realtime version of FMOD_OUTPUTTYPE_NOSOUND.  User can drive mixer with System::update at whatever rate they want. }
FMOD_OUTPUTTYPE_WAVWRITER_NRT: 5 { All             - Non-realtime version of FMOD_OUTPUTTYPE_WAVWRITER.  User can drive mixer with System::update at whatever rate they want. }

FMOD_OUTPUTTYPE_DSOUND: 6 { Win32/Win64     - DirectSound output.                       (Default on Windows XP and below) }
FMOD_OUTPUTTYPE_WINMM: 7 { Win32/Win64     - Windows Multimedia output. }
FMOD_OUTPUTTYPE_WASAPI: 8 { Win32           - Windows Audio Session API.                (Default on Windows Vista and above) }
FMOD_OUTPUTTYPE_ASIO: 9 { Win32           - Low latency ASIO 2.0 driver. }
FMOD_OUTPUTTYPE_OSS: 10 { Linux/Linux64   - Open Sound System output.                 (Default on Linux, third preference) }
FMOD_OUTPUTTYPE_ALSA: 11 { Linux/Linux64   - Advanced Linux Sound Architecture output. (Default on Linux, second preference if available) }
FMOD_OUTPUTTYPE_ESD: 12 { Linux/Linux64   - Enlightment Sound Daemon output. }
FMOD_OUTPUTTYPE_PULSEAUDIO: 13 { Linux/Linux64   - PulseAudio output.                        (Default on Linux, first preference if available) }
FMOD_OUTPUTTYPE_COREAUDIO: 14 { Mac             - Macintosh CoreAudio output.               (Default on Mac) }
FMOD_OUTPUTTYPE_XBOX360: 15 { Xbox 360        - Native Xbox360 output.                    (Default on Xbox 360) }
FMOD_OUTPUTTYPE_PSP: 16 { PSP             - Native PSP output.                        (Default on PSP) }
FMOD_OUTPUTTYPE_PS3: 17 { PS3             - Native PS3 output.                        (Default on PS3) }
FMOD_OUTPUTTYPE_NGP: 18 { NGP             - Native NGP output.                        (Default on NGP) }
FMOD_OUTPUTTYPE_WII: 19 { Wii			    - Native Wii output.                        (Default on Wii) }
FMOD_OUTPUTTYPE_3DS: 20 { 3DS             - Native 3DS output                         (Default on 3DS) }
FMOD_OUTPUTTYPE_AUDIOTRACK: 21 { Android         - Java Audio Track output.                  (Default on Android 2.2 and below) }
FMOD_OUTPUTTYPE_OPENSL: 22 { Android         - OpenSL ES output.                         (Default on Android 2.3 and above) }

FMOD_OUTPUTTYPE_MAX: 23 { Maximum number of output types supported. }
FMOD_OUTPUTTYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_OUTPUTTYPE: integer!;


{
[DEFINE] 
[
    [NAME]
    FMOD_CAPS

    [DESCRIPTION]   
    Bit fields to use with System::getDriverCaps to determine the capabilities of a card / output device.

    [REMARKS]
    It is important to check FMOD_CAPS_HARDWARE_EMULATED on windows machines, to then adjust System::setDSPBufferSize to (1024, 10) to compensate for the higher latency.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::getDriverCaps
    System::setDSPBufferSize
]
}
FMOD_CAPS_NONE:                   0  { Device has no special capabilities. }
FMOD_CAPS_HARDWARE:               1  { Device supports hardware mixing. }
FMOD_CAPS_HARDWARE_EMULATED:      2  { User has device set to 'Hardware acceleration = off' in control panel, and now extra 200ms latency is incurred. }
FMOD_CAPS_OUTPUT_MULTICHANNEL:    4  { Device can do multichannel output, ie greater than 2 channels. }
FMOD_CAPS_OUTPUT_FORMAT_PCM8:     8  { Device can output to 8bit integer PCM. }
FMOD_CAPS_OUTPUT_FORMAT_PCM16:    16  { Device can output to 16bit integer PCM. }
FMOD_CAPS_OUTPUT_FORMAT_PCM24:    32  { Device can output to 24bit integer PCM. }
FMOD_CAPS_OUTPUT_FORMAT_PCM32:    64  { Device can output to 32bit integer PCM. }
FMOD_CAPS_OUTPUT_FORMAT_PCMFLOAT: 128  { Device can output to 32bit floating point PCM. }
FMOD_CAPS_REVERB_LIMITED:         8192  { Device supports some form of limited hardware reverb, maybe parameterless and only selectable by environment. }
{ [DEFINE_END] }

{
[DEFINE] 
[
    [NAME]
    FMOD_DEBUGLEVEL

    [DESCRIPTION]   
    Bit fields to use with FMOD::Debug_SetLevel / FMOD::Debug_GetLevel to control the level of tty debug output with logging versions of FMOD (fmodL).

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    Debug_SetLevel 
    Debug_GetLevel
]
}
FMOD_DEBUG_LEVEL_NONE:           0
FMOD_DEBUG_LEVEL_LOG:            1      { Will display generic logging messages. }
FMOD_DEBUG_LEVEL_ERROR:          2      { Will display errors. }
FMOD_DEBUG_LEVEL_WARNING:        4      { Will display warnings that are not fatal. }
FMOD_DEBUG_LEVEL_HINT:           8      { Will hint to you if there is something possibly better you could be doing. }
FMOD_DEBUG_LEVEL_ALL:            255    
FMOD_DEBUG_TYPE_MEMORY:          256      { Show FMOD memory related logging messages. }
FMOD_DEBUG_TYPE_THREAD:          512      { Show FMOD thread related logging messages. }
FMOD_DEBUG_TYPE_FILE:            1024      { Show FMOD file system related logging messages. }
FMOD_DEBUG_TYPE_NET:             2048      { Show FMOD network related logging messages. }
FMOD_DEBUG_TYPE_EVENT:           4096      { Show FMOD Event related logging messages. }
FMOD_DEBUG_TYPE_ALL:             65535                      
FMOD_DEBUG_DISPLAY_TIMESTAMPS:   16777216      { Display the timestamp of the log entry in milliseconds. }
FMOD_DEBUG_DISPLAY_LINENUMBERS:  33554432      { Display the FMOD Ex source code line numbers, for debugging purposes. }
FMOD_DEBUG_DISPLAY_COMPRESS:     67108864      { If a message is repeated more than 5 times it will stop displaying it and instead display the number of times the message was logged. }
FMOD_DEBUG_DISPLAY_THREAD:       134217728      { Display the thread ID of the calling function that caused this log entry to appear. }
FMOD_DEBUG_DISPLAY_ALL:          251658240
FMOD_DEBUG_ALL:                  -1
{ [DEFINE_END] }


{
[DEFINE] 
[
    [NAME]
    FMOD_MEMORY_TYPE

    [DESCRIPTION]   
    Bit fields for memory allocation type being passed into FMOD memory callbacks.

    [REMARKS]
    Remember this is a bitfield.  You may get more than 1 bit set (ie physical + persistent) so do not simply switch on the types!  You must check each bit individually or clear out the bits that you do not want within the callback.
    Bits can be excluded if you want during Memory_Initialize so that you never get them.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    FMOD_MEMORY_ALLOCCALLBACK
    FMOD_MEMORY_REALLOCCALLBACK
    FMOD_MEMORY_FREECALLBACK
    Memory_Initialize
    
]
}
FMOD_MEMORY_NORMAL:             0       { Standard memory. }
FMOD_MEMORY_STREAM_FILE:        1       { Stream file buffer, size controllable with System::setStreamBufferSize. }
FMOD_MEMORY_STREAM_DECODE:      2       { Stream decode buffer, size controllable with FMOD_CREATESOUNDEXINFO::decodebuffersize. }
FMOD_MEMORY_SAMPLEDATA:         4       { Sample data buffer.  Raw audio data, usually PCM/MPEG/ADPCM/XMA data. }
FMOD_MEMORY_DSP_OUTPUTBUFFER:   8       { DSP memory block allocated when more than 1 output exists on a DSP node. }
FMOD_MEMORY_XBOX360_PHYSICAL:   1048576       { Requires XPhysicalAlloc / XPhysicalFree. }
FMOD_MEMORY_PERSISTENT:         2097152       { Persistent memory. Memory will be freed when System::release is called. }
FMOD_MEMORY_SECONDARY:          4194304       { Secondary memory. Allocation should be in secondary memory. For example RSX on the PS3. }
FMOD_MEMORY_ALL:                -1
{ [DEFINE_END] }


{
[ENUM]
[
    [DESCRIPTION]   
    These are speaker types defined for use with the System::setSpeakerMode or System::getSpeakerMode command.

    [REMARKS]
    These are important notes on speaker modes in regards to sounds created with FMOD_SOFTWARE.
    Note below the phrase 'sound channels' is used.  These are the subchannels inside a sound, they are not related and 
    have nothing to do with the FMOD class "Channel".
    For example a mono sound has 1 sound channel, a stereo sound has 2 sound channels, and an AC3 or 6 channel wav file have 6 "sound channels".
    
    FMOD_SPEAKERMODE_RAW
    ---------------------
    This mode is for output devices that are not specifically mono/stereo/quad/surround/5.1 or 7.1, but are multichannel.
    Use System::setSoftwareFormat to specify the number of speakers you want to address, otherwise it will default to 2 (stereo).
    Sound channels map to speakers sequentially, so a mono sound maps to output speaker 0, stereo sound maps to output speaker 0 & 1.
    The user assumes knowledge of the speaker order.  FMOD_SPEAKER enumerations may not apply, so raw channel indices should be used.
    Multichannel sounds map input channels to output channels 1:1. 
    Channel::setPan and Channel::setSpeakerMix do not work.
    Speaker levels must be manually set with Channel::setSpeakerLevels.
    
    FMOD_SPEAKERMODE_MONO
    ---------------------
    This mode is for a 1 speaker arrangement.
    Panning does not work in this speaker mode.
    Mono, stereo and multichannel sounds have each sound channel played on the one speaker unity.
    Mix behavior for multichannel sounds can be set with Channel::setSpeakerLevels.
    Channel::setSpeakerMix does not work.
    
    FMOD_SPEAKERMODE_STEREO
    -----------------------
    This mode is for 2 speaker arrangements that have a left and right speaker.
    - Mono sounds default to an even distribution between left and right.  They can be panned with Channel::setPan.
    - Stereo sounds default to the middle, or full left in the left speaker and full right in the right speaker.  
    - They can be cross faded with Channel::setPan.
    - Multichannel sounds have each sound channel played on each speaker at unity.
    - Mix behavior for multichannel sounds can be set with Channel::setSpeakerLevels.
    - Channel::setSpeakerMix works but only front left and right parameters are used, the rest are ignored.
    
    FMOD_SPEAKERMODE_QUAD
    ------------------------
    This mode is for 4 speaker arrangements that have a front left, front right, rear left and a rear right speaker.
    - Mono sounds default to an even distribution between front left and front right.  They can be panned with Channel::setPan.
    - Stereo sounds default to the left sound channel played on the front left, and the right sound channel played on the front right.
    - They can be cross faded with Channel::setPan.
    - Multichannel sounds default to all of their sound channels being played on each speaker in order of input.
    - Mix behavior for multichannel sounds can be set with Channel::setSpeakerLevels.
    - Channel::setSpeakerMix works but side left, side right, center and lfe are ignored.
    
    FMOD_SPEAKERMODE_SURROUND
    ------------------------
    This mode is for 5 speaker arrangements that have a left/right/center/rear left/rear right.
    - Mono sounds default to the center speaker.  They can be panned with Channel::setPan.
    - Stereo sounds default to the left sound channel played on the front left, and the right sound channel played on the front right.  
    - They can be cross faded with Channel::setPan.
    - Multichannel sounds default to all of their sound channels being played on each speaker in order of input.  
    - Mix behavior for multichannel sounds can be set with Channel::setSpeakerLevels.
    - Channel::setSpeakerMix works but side left / side right are ignored.
    
    FMOD_SPEAKERMODE_5POINT1
    ------------------------
    This mode is for 5.1 speaker arrangements that have a left/right/center/rear left/rear right and a subwoofer speaker.
    - Mono sounds default to the center speaker.  They can be panned with Channel::setPan.
    - Stereo sounds default to the left sound channel played on the front left, and the right sound channel played on the front right.  
    - They can be cross faded with Channel::setPan.
    - Multichannel sounds default to all of their sound channels being played on each speaker in order of input.  
    - Mix behavior for multichannel sounds can be set with Channel::setSpeakerLevels.
    - Channel::setSpeakerMix works but side left / side right are ignored.
    
    FMOD_SPEAKERMODE_7POINT1
    ------------------------
    This mode is for 7.1 speaker arrangements that have a left/right/center/rear left/rear right/side left/side right 
    and a subwoofer speaker.
    - Mono sounds default to the center speaker.  They can be panned with Channel::setPan.
    - Stereo sounds default to the left sound channel played on the front left, and the right sound channel played on the front right.  
    - They can be cross faded with Channel::setPan.
    - Multichannel sounds default to all of their sound channels being played on each speaker in order of input.  
    - Mix behavior for multichannel sounds can be set with Channel::setSpeakerLevels.
    - Channel::setSpeakerMix works and every parameter is used to set the balance of a sound in any speaker.
    
    FMOD_SPEAKERMODE_PROLOGIC
    ------------------------------------------------------
    This mode is for mono, stereo, 5.1 and 7.1 speaker arrangements, as it is backwards and forwards compatible with stereo, 
    but to get a surround effect a Dolby Prologic or Prologic 2 hardware decoder / amplifier is needed.
    Pan behavior is the same as FMOD_SPEAKERMODE_5POINT1.
    
    If this function is called the numoutputchannels setting in System::setSoftwareFormat is overwritten.
    
    Output rate must be 44100, 48000 or 96000 for this to work otherwise FMOD_ERR_OUTPUT_INIT will be returned.

    FMOD_SPEAKERMODE_MYEARS
    ------------------------------------------------------
    This mode is for headphones.  This will attempt to load a MyEars profile (see myears.net.au) and use it to generate
    surround sound on headphones using a personalized HRTF algorithm, for realistic 3d sound.
    Pan behavior is the same as FMOD_SPEAKERMODE_7POINT1.
    MyEars speaker mode will automatically be set if the speakermode is FMOD_SPEAKERMODE_STEREO and the MyEars profile exists.
    If this mode is set explicitly, FMOD_INIT_DISABLE_MYEARS_AUTODETECT has no effect.
    If this mode is set explicitly and the MyEars profile does not exist, FMOD_ERR_OUTPUT_DRIVERCALL will be returned.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::setSpeakerMode
    System::getSpeakerMode
    System::getDriverCaps
    System::setSoftwareFormat
    Channel::setSpeakerLevels
]
}
FMOD_SPEAKERMODE_RAW: 0 { There is no specific speakermode.  Sound channels are mapped in order of input to output.  Use System::setSoftwareFormat to specify speaker count. See remarks for more information. }
FMOD_SPEAKERMODE_MONO: 1 { The speakers are monaural. }
FMOD_SPEAKERMODE_STEREO: 2 { The speakers are stereo (DEFAULT). }
FMOD_SPEAKERMODE_QUAD: 3 { 4 speaker setup.  This includes front left, front right, rear left, rear right.  }
FMOD_SPEAKERMODE_SURROUND: 4 { 5 speaker setup.  This includes front left, front right, center, rear left, rear right. }
FMOD_SPEAKERMODE_5POINT1: 5 { 5.1 speaker setup.  This includes front left, front right, center, rear left, rear right and a subwoofer. }
FMOD_SPEAKERMODE_7POINT1: 6 { 7.1 speaker setup.  This includes front left, front right, center, rear left, rear right, side left, side right and a subwoofer. }

FMOD_SPEAKERMODE_PROLOGIC: 7 { Stereo output, but data is encoded to be played on a Prologic 2 / CircleSurround decoder in 5.1 via an analog connection.  See remarks about limitations. }
FMOD_SPEAKERMODE_MYEARS: 8 { Stereo output, but data is encoded using personalized HRTF algorithms.  See myears.net.au }

FMOD_SPEAKERMODE_MAX: 9 { Maximum number of speaker modes supported. }
FMOD_SPEAKERMODE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_SPEAKERMODE: integer!


{
[ENUM]
[
    [DESCRIPTION]   
    These are speaker types defined for use with the Channel::setSpeakerLevels command.
    It can also be used for speaker placement in the System::set3DSpeakerPosition command.

    [REMARKS]
    If you are using FMOD_SPEAKERMODE_RAW and speaker assignments are meaningless, just cast a raw integer value to this type.
    For example (FMOD_SPEAKER)7 would use the 7th speaker (also the same as FMOD_SPEAKER_SIDE_RIGHT).
    Values higher than this can be used if an output system has more than 8 speaker types / output channels.  15 is the current maximum.
    
    NOTE: On Playstation 3 in 7.1, the extra 2 speakers are not side left/side right, they are 'surround back left'/'surround back right' which
    locate the speakers behind the listener instead of to the sides like on PC.  FMOD_SPEAKER_SBL/FMOD_SPEAKER_SBR are provided to make it 
    clearer what speaker is being addressed on that platform.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    FMOD_SPEAKERMODE
    Channel::setSpeakerLevels
    Channel::getSpeakerLevels
    System::set3DSpeakerPosition
    System::get3DSpeakerPosition
]
}
FMOD_SPEAKER_FRONT_LEFT: 0
FMOD_SPEAKER_FRONT_RIGHT: 1
FMOD_SPEAKER_FRONT_CENTER: 2
FMOD_SPEAKER_LOW_FREQUENCY: 3
FMOD_SPEAKER_BACK_LEFT: 4
FMOD_SPEAKER_BACK_RIGHT: 5
FMOD_SPEAKER_SIDE_LEFT: 6
FMOD_SPEAKER_SIDE_RIGHT: 7

FMOD_SPEAKER_MAX: 8 { Maximum number of speaker types supported. }
FMOD_SPEAKER_MONO: FMOD_SPEAKER_FRONT_LEFT { For use with FMOD_SPEAKERMODE_MONO and Channel::SetSpeakerLevels.  Mapped to same value as FMOD_SPEAKER_FRONT_LEFT. }
FMOD_SPEAKER_NULL: FMOD_SPEAKER_MAX { A non speaker.  Use this to send. }
FMOD_SPEAKER_SBL: FMOD_SPEAKER_SIDE_LEFT { For use with FMOD_SPEAKERMODE_7POINT1 on PS3 where the extra speakers are surround back inside of side speakers. }
FMOD_SPEAKER_SBR: FMOD_SPEAKER_SIDE_RIGHT { For use with FMOD_SPEAKERMODE_7POINT1 on PS3 where the extra speakers are surround back inside of side speakers. }
FMOD_SPEAKER_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_SPEAKER: integer!


{
[ENUM]
[
    [DESCRIPTION]   
    These are plugin types defined for use with the System::getNumPlugins, 
    System::getPluginInfo and System::unloadPlugin functions.

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::getNumPlugins
    System::getPluginInfo
    System::unloadPlugin
]
}

FMOD_PLUGINTYPE_OUTPUT: 0 { The plugin type is an output module.  FMOD mixed audio will play through one of these devices }
FMOD_PLUGINTYPE_CODEC: 1 { The plugin type is a file format codec.  FMOD will use these codecs to load file formats for playback. }
FMOD_PLUGINTYPE_DSP: 2 { The plugin type is a DSP unit.  FMOD will use these plugins as part of its DSP network to apply effects to output or generate sound in realtime. }

FMOD_PLUGINTYPE_MAX: 3 { Maximum number of plugin types supported. }
FMOD_PLUGINTYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_PLUGINTYPE: integer!


{
[DEFINE]
[
    [NAME]
    FMOD_INITFLAGS

    [DESCRIPTION]   
    Initialization flags.  Use them with System::init in the flags parameter to change various behavior.  

    [REMARKS]
    Use System::setAdvancedSettings to adjust settings for some of the features that are enabled by these flags.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::init
    System::update 
    System::setAdvancedSettings
    Channel::set3DOcclusion
]
}
FMOD_INIT_NORMAL:                     0 { All platforms - Initialize normally }
FMOD_INIT_STREAM_FROM_UPDATE:         1 { All platforms - No stream thread is created internally.  Streams are driven from System::update.  Mainly used with non-realtime outputs. }
FMOD_INIT_3D_RIGHTHANDED:             2 { All platforms - FMOD will treat +X as right, +Y as up and +Z as backwards (towards you). }
FMOD_INIT_SOFTWARE_DISABLE:           4 { All platforms - Disable software mixer to save memory.  Anything created with FMOD_SOFTWARE will fail and DSP will not work. }
FMOD_INIT_SOFTWARE_OCCLUSION:         8 { All platforms - All FMOD_SOFTWARE with FMOD_3D based voices will add a software lowpass filter effect into the DSP chain which is automatically used when Channel::set3DOcclusion is used or the geometry API. }
FMOD_INIT_SOFTWARE_HRTF:              16 { All platforms - All FMOD_SOFTWARE with FMOD_3D based voices will add a software lowpass filter effect into the DSP chain which causes sounds to sound duller when the sound goes behind the listener.  Use System::setAdvancedSettings to adjust cutoff frequency. }
FMOD_INIT_DISTANCE_FILTERING:         512 { All platforms - All FMOD_SOFTWARE with FMOD_3D based voices will add a software lowpass and highpass filter effect into the DSP chain which will act as a distance-automated bandpass filter. Use System::setAdvancedSettings to adjust the centre frequency. }
FMOD_INIT_SOFTWARE_REVERB_LOWMEM:     64 { All platforms - SFX reverb is run using 22/24khz delay buffers, halving the memory required. }
FMOD_INIT_ENABLE_PROFILE:             32 { All platforms - Enable TCP/IP based host which allows FMOD Designer or FMOD Profiler to connect to it, and view memory, CPU and the DSP network graph in real-time. }
FMOD_INIT_VOL0_BECOMES_VIRTUAL:       128 { All platforms - Any sounds that are 0 volume will go virtual and not be processed except for having their positions updated virtually.  Use System::setAdvancedSettings to adjust what volume besides zero to switch to virtual at. }
FMOD_INIT_WASAPI_EXCLUSIVE:           256 { Win32 Vista only - for WASAPI output - Enable exclusive access to hardware, lower latency at the expense of excluding other applications from accessing the audio hardware. }
FMOD_INIT_PS3_PREFERDTS:              8388608 { PS3 only - Prefer DTS over Dolby Digital if both are supported. Note: 8 and 6 channel LPCM is always preferred over both DTS and Dolby Digital. }
FMOD_INIT_PS3_FORCE2CHLPCM:           16777216 { PS3 only - Force PS3 system output mode to 2 channel LPCM. }
FMOD_INIT_DISABLEDOLBY:               1048576 { Wii / 3DS - Disable Dolby Pro Logic surround. Speakermode will be set to STEREO even if user has selected surround in the system settings. }
FMOD_INIT_SYSTEM_MUSICMUTENOTPAUSE:   2097152 { Xbox 360 / PS3 - The "music" channelgroup which by default pauses when custom 360 dashboard / PS3 BGM music is played, can be changed to mute (therefore continues playing) instead of pausing, by using this flag. }
FMOD_INIT_SYNCMIXERWITHUPDATE:        4194304 { Win32/Wii/PS3/Xbox/Xbox 360 - FMOD Mixer thread is woken up to do a mix when System::update is called rather than waking periodically on its own timer. }
FMOD_INIT_GEOMETRY_USECLOSEST:        67108864 { All platforms - With the geometry engine, only process the closest polygon rather than accumulating all polygons the sound to listener line intersects. }
FMOD_INIT_DISABLE_MYEARS_AUTODETECT:  134217728 { Win32 - Disables automatic setting of FMOD_SPEAKERMODE_STEREO to FMOD_SPEAKERMODE_MYEARS if the MyEars profile exists on the PC.  MyEars is HRTF 7.1 downmixing through headphones. }
{ [DEFINE_END] }


{
[ENUM]
[
    [DESCRIPTION]   
    These definitions describe the type of song being played.

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Sound::getFormat
]
}
FMOD_SOUND_TYPE_UNKNOWN: 0 { 3rd party / unknown plugin format. }
FMOD_SOUND_TYPE_AIFF: 1 { AIFF. }
FMOD_SOUND_TYPE_ASF: 2 { Microsoft Advanced Systems Format (ie WMA/ASF/WMV). }
FMOD_SOUND_TYPE_AT3: 3 { Sony ATRAC 3 format }
FMOD_SOUND_TYPE_CDDA: 4 { Digital CD audio. }
FMOD_SOUND_TYPE_DLS: 5 { Sound font / downloadable sound bank. }
FMOD_SOUND_TYPE_FLAC: 6 { FLAC lossless codec. }
FMOD_SOUND_TYPE_FSB: 7 { FMOD Sample Bank. }
FMOD_SOUND_TYPE_GCADPCM: 8 { Nintendo GameCube/Wii ADPCM }
FMOD_SOUND_TYPE_IT: 9 { Impulse Tracker. }
FMOD_SOUND_TYPE_MIDI: 10 { MIDI. extracodecdata is a pointer to an FMOD_MIDI_EXTRACODECDATA structure. }
FMOD_SOUND_TYPE_MOD: 11 { Protracker / Fasttracker MOD. }
FMOD_SOUND_TYPE_MPEG: 12 { MP2/MP3 MPEG. }
FMOD_SOUND_TYPE_OGGVORBIS: 13 { Ogg vorbis. }
FMOD_SOUND_TYPE_PLAYLIST: 14 { Information only from ASX/PLS/M3U/WAX playlists }
FMOD_SOUND_TYPE_RAW: 15 { Raw PCM data. }
FMOD_SOUND_TYPE_S3M: 16 { ScreamTracker 3. }
FMOD_SOUND_TYPE_SF2: 17 { Sound font 2 format. }
FMOD_SOUND_TYPE_USER: 18 { User created sound. }
FMOD_SOUND_TYPE_WAV: 19 { Microsoft WAV. }
FMOD_SOUND_TYPE_XM: 20 { FastTracker 2 XM. }
FMOD_SOUND_TYPE_XMA: 21 { Xbox360 XMA }
FMOD_SOUND_TYPE_VAG: 22 { PlayStation Portable ADPCM VAG format. }
FMOD_SOUND_TYPE_AUDIOQUEUE: 23 { iPhone hardware decoder, supports AAC, ALAC and MP3. extracodecdata is a pointer to an FMOD_AUDIOQUEUE_EXTRACODECDATA structure. }
FMOD_SOUND_TYPE_XWMA: 24 { Xbox360 XWMA }
FMOD_SOUND_TYPE_BCWAV: 25 { 3DS BCWAV container format for DSP ADPCM and PCM }
FMOD_SOUND_TYPE_AT9: 26 { NGP ATRAC 9 format }

FMOD_SOUND_TYPE_MAX: 27 { Maximum number of sound types supported. }
FMOD_SOUND_TYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_SOUND_TYPE: integer!


{
[ENUM]
[
    [DESCRIPTION]   
    These definitions describe the native format of the hardware or software buffer that will be used.

    [REMARKS]
    This is the format the native hardware or software buffer will be or is created in.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::createSound
    Sound::getFormat
]
}
FMOD_SOUND_FORMAT_NONE: 0 { Unitialized / unknown. }
FMOD_SOUND_FORMAT_PCM8: 1 { 8bit integer PCM data. }
FMOD_SOUND_FORMAT_PCM16: 2 { 16bit integer PCM data. }
FMOD_SOUND_FORMAT_PCM24: 3 { 24bit integer PCM data. }
FMOD_SOUND_FORMAT_PCM32: 4 { 32bit integer PCM data. }
FMOD_SOUND_FORMAT_PCMFLOAT: 5 { 32bit floating point PCM data. }
FMOD_SOUND_FORMAT_GCADPCM: 6 { Compressed Nintendo GameCube/Wii DSP data. }
FMOD_SOUND_FORMAT_IMAADPCM: 7 { Compressed IMA ADPCM / Xbox ADPCM data. }
FMOD_SOUND_FORMAT_VAG: 8 { Compressed PlayStation Portable ADPCM data. }
FMOD_SOUND_FORMAT_HEVAG: 9 { Compressed NGP ADPCM data. }
FMOD_SOUND_FORMAT_XMA: 10 { Compressed Xbox360 data. }
FMOD_SOUND_FORMAT_MPEG: 11 { Compressed MPEG layer 2 or 3 data. }
FMOD_SOUND_FORMAT_CELT: 12 { Compressed CELT data. }

FMOD_SOUND_FORMAT_MAX: 13 { Maximum number of sound formats supported. }
FMOD_SOUND_FORMAT_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_SOUND_FORMAT: integer!


{
[DEFINE]
[
    [NAME] 
    FMOD_MODE

    [DESCRIPTION]   
    Sound description bitfields, bitwise OR them together for loading and describing sounds.

    [REMARKS]
    By default a sound will open as a static sound that is decompressed fully into memory to PCM. (ie equivalent of FMOD_CREATESAMPLE)
    To have a sound stream instead, use FMOD_CREATESTREAM, or use the wrapper function System::createStream.
    Some opening modes (ie FMOD_OPENUSER, FMOD_OPENMEMORY, FMOD_OPENMEMORY_POINT, FMOD_OPENRAW) will need extra information.
    This can be provided using the FMOD_CREATESOUNDEXINFO structure.
    
    Specifying FMOD_OPENMEMORY_POINT will POINT to your memory rather allocating its own sound buffers and duplicating it internally.
    <b><u>This means you cannot free the memory while FMOD is using it, until after Sound::release is called.</b></u>
    With FMOD_OPENMEMORY_POINT, for PCM formats, only WAV, FSB, and RAW are supported.  For compressed formats, only those formats supported by FMOD_CREATECOMPRESSEDSAMPLE are supported.
    With FMOD_OPENMEMORY_POINT and FMOD_OPENRAW or PCM, if using them together, note that you must pad the data on each side by 16 bytes.  This is so fmod can modify the ends of the data for looping/interpolation/mixing purposes.  If a wav file, you will need to insert silence, and then reset loop points to stop the playback from playing that silence.
    With FMOD_OPENMEMORY_POINT, For Wii/PSP FMOD_HARDWARE supports this flag for the GCADPCM/VAG formats.  On other platforms FMOD_SOFTWARE must be used.
    
    <b>Xbox 360 memory</b> On Xbox 360 Specifying FMOD_OPENMEMORY_POINT to a virtual memory address will cause FMOD_ERR_INVALID_ADDRESS
    to be returned.  Use physical memory only for this functionality.
    
    FMOD_LOWMEM is used on a sound if you want to minimize the memory overhead, by having FMOD not allocate memory for certain 
    features that are not likely to be used in a game environment.  These are :
    1. Sound::getName functionality is removed.  256 bytes per sound is saved.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::createSound
    System::createStream
    Sound::setMode
    Sound::getMode
    Channel::setMode
    Channel::getMode
    Sound::set3DCustomRolloff
    Channel::set3DCustomRolloff
    Sound::getOpenState
]
}
FMOD_DEFAULT:                   0  { FMOD_DEFAULT is a default sound type.  Equivalent to all the defaults listed below.  FMOD_LOOP_OFF, FMOD_2D, FMOD_HARDWARE.  (Note - only Windows with a high spec soundcard, PSP, and Wii support FMOD_HARDWARE) }
FMOD_LOOP_OFF:                  1  { For non looping sounds. (DEFAULT).  Overrides FMOD_LOOP_NORMAL / FMOD_LOOP_BIDI. }
FMOD_LOOP_NORMAL:               2  { For forward looping sounds. }
FMOD_LOOP_BIDI:                 4  { For bidirectional looping sounds. (only works on software mixed static sounds). }
FMOD_2D:                        8  { Ignores any 3d processing. (DEFAULT). }
FMOD_3D:                        16  { Makes the sound positionable in 3D.  Overrides FMOD_2D. }
FMOD_HARDWARE:                  32  { Attempts to make sounds use hardware acceleration. (DEFAULT).  Note on platforms that don't support FMOD_HARDWARE (only Windows with a high spec soundcard, PSP, and Wii support FMOD_HARDWARE), this will be internally treated as FMOD_SOFTWARE. }
FMOD_SOFTWARE:                  64  { Makes the sound be mixed by the FMOD CPU based software mixer.  Overrides FMOD_HARDWARE.  Use this for FFT, DSP, compressed sample support, 2D multi-speaker support and other software related features. }
FMOD_CREATESTREAM:              128  { Decompress at runtime, streaming from the source provided (ie from disk).  Overrides FMOD_CREATESAMPLE and FMOD_CREATECOMPRESSEDSAMPLE.  Note a stream can only be played once at a time due to a stream only having 1 stream buffer and file handle.  Open multiple streams to have them play concurrently. }
FMOD_CREATESAMPLE:              256  { Decompress at loadtime, decompressing or decoding whole file into memory as the target sample format (ie PCM).  Fastest for FMOD_SOFTWARE based playback and most flexible.  }
FMOD_CREATECOMPRESSEDSAMPLE:    512  { Load MP2, MP3, IMAADPCM or XMA into memory and leave it compressed.  During playback the FMOD software mixer will decode it in realtime as a 'compressed sample'.  Can only be used in combination with FMOD_SOFTWARE.  Overrides FMOD_CREATESAMPLE.  If the sound data is not ADPCM, MPEG or XMA it will behave as if it was created with FMOD_CREATESAMPLE and decode the sound into PCM. }
FMOD_OPENUSER:                  1024  { Opens a user created static sample or stream. Use FMOD_CREATESOUNDEXINFO to specify format and/or read callbacks.  If a user created 'sample' is created with no read callback, the sample will be empty.  Use Sound::lock and Sound::unlock to place sound data into the sound if this is the case. }
FMOD_OPENMEMORY:                2048  { "name_or_data" will be interpreted as a pointer to memory instead of filename for creating sounds.  Use FMOD_CREATESOUNDEXINFO to specify length.  If used with FMOD_CREATESAMPLE or FMOD_CREATECOMPRESSEDSAMPLE, FMOD duplicates the memory into its own buffers.  Your own buffer can be freed after open.  If used with FMOD_CREATESTREAM, FMOD will stream out of the buffer whose pointer you passed in.  In this case, your own buffer should not be freed until you have finished with and released the stream.}
FMOD_OPENMEMORY_POINT:          268435456  { "name_or_data" will be interpreted as a pointer to memory instead of filename for creating sounds.  Use FMOD_CREATESOUNDEXINFO to specify length.  This differs to FMOD_OPENMEMORY in that it uses the memory as is, without duplicating the memory into its own buffers.  For Wii/PSP FMOD_HARDWARE supports this flag for the GCADPCM/VAG formats.  On other platforms FMOD_SOFTWARE must be used, as sound hardware on the other platforms (ie PC) cannot access main ram.  Cannot be freed after open, only after Sound::release.   Will not work if the data is compressed and FMOD_CREATECOMPRESSEDSAMPLE is not used. }
FMOD_OPENRAW:                   4096  { Will ignore file format and treat as raw pcm.  Use FMOD_CREATESOUNDEXINFO to specify format.  Requires at least defaultfrequency, numchannels and format to be specified before it will open.  Must be little endian data. }
FMOD_OPENONLY:                  8192  { Just open the file, dont prebuffer or read.  Good for fast opens for info, or when sound::readData is to be used. }
FMOD_ACCURATETIME:              16384  { For System::createSound - for accurate Sound::getLength/Channel::setPosition on VBR MP3, and MOD/S3M/XM/IT/MIDI files.  Scans file first, so takes longer to open. FMOD_OPENONLY does not affect this. }
FMOD_MPEGSEARCH:                32768  { For corrupted / bad MP3 files.  This will search all the way through the file until it hits a valid MPEG header.  Normally only searches for 4k. }
FMOD_NONBLOCKING:               65536  { For opening sounds and getting streamed subsounds (seeking) asyncronously.  Use Sound::getOpenState to poll the state of the sound as it opens or retrieves the subsound in the background. }
FMOD_UNIQUE:                    131072  { Unique sound, can only be played one at a time }
FMOD_3D_HEADRELATIVE:           262144  { Make the sound's position, velocity and orientation relative to the listener. }
FMOD_3D_WORLDRELATIVE:          524288  { Make the sound's position, velocity and orientation absolute (relative to the world). (DEFAULT) }
FMOD_3D_INVERSEROLLOFF:         1048576  { This sound will follow the inverse rolloff model where mindistance = full volume, maxdistance = where sound stops attenuating, and rolloff is fixed according to the global rolloff factor.  (DEFAULT) }
FMOD_3D_LINEARROLLOFF:          2097152  { This sound will follow a linear rolloff model where mindistance = full volume, maxdistance = silence.  Rolloffscale is ignored. }
FMOD_3D_LINEARSQUAREROLLOFF:    4194304  { This sound will follow a linear-square rolloff model where mindistance = full volume, maxdistance = silence.  Rolloffscale is ignored. }
FMOD_3D_CUSTOMROLLOFF:          67108864  { This sound will follow a rolloff model defined by Sound::set3DCustomRolloff / Channel::set3DCustomRolloff.  }
FMOD_3D_IGNOREGEOMETRY:         1073741824  { Is not affect by geometry occlusion.  If not specified in Sound::setMode, or Channel::setMode, the flag is cleared and it is affected by geometry again. }
FMOD_UNICODE:                   16777216  { Filename is double-byte unicode. }
FMOD_IGNORETAGS:                33554432  { Skips id3v2/asf/etc tag checks when opening a sound, to reduce seek/read overhead when opening files (helps with CD performance). }
FMOD_LOWMEM:                    134217728  { Removes some features from samples to give a lower memory overhead, like Sound::getName.  See remarks. }
FMOD_LOADSECONDARYRAM:          536870912  { Load sound into the secondary RAM of supported platform. On PS3, sounds will be loaded into RSX/VRAM. }
FMOD_VIRTUAL_PLAYFROMSTART:     -2147483648  { For sounds that start virtual (due to being quiet or low importance), instead of swapping back to audible, and playing at the correct offset according to time, this flag makes the sound play from the start. }

{ [DEFINE_END] }


{
[ENUM]
[
    [DESCRIPTION]   
    These values describe what state a sound is in after FMOD_NONBLOCKING has been used to open it.

    [REMARKS]
    With streams, if you are using FMOD_NONBLOCKING, note that if the user calls Sound::getSubSound, a stream will go into FMOD_OPENSTATE_SEEKING state and sound related commands will return FMOD_ERR_NOTREADY.
    With streams, if you are using FMOD_NONBLOCKING, note that if the user calls Channel::getPosition, a stream will go into FMOD_OPENSTATE_SETPOSITION state and sound related commands will return FMOD_ERR_NOTREADY.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    Sound::getOpenState
    FMOD_MODE
]
}
FMOD_OPENSTATE_READY: 0 { Opened and ready to play. }
FMOD_OPENSTATE_LOADING: 1 { Initial load in progress. }
FMOD_OPENSTATE_ERROR: 2 { Failed to open - file not found, out of memory etc.  See return value of Sound::getOpenState for what happened. }
FMOD_OPENSTATE_CONNECTING: 3 { Connecting to remote host (internet sounds only). }
FMOD_OPENSTATE_BUFFERING: 4 { Buffering data. }
FMOD_OPENSTATE_SEEKING: 5 { Seeking to subsound and re-flushing stream buffer. }
FMOD_OPENSTATE_PLAYING: 6 { Ready and playing, but not possible to release at this time without stalling the main thread. }
FMOD_OPENSTATE_SETPOSITION: 7 { Seeking within a stream to a different position. }

FMOD_OPENSTATE_MAX: 8 { Maximum number of open state types. }
FMOD_OPENSTATE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_OPENSTATE: integer!


{
[ENUM]
[
    [DESCRIPTION]   
    These flags are used with SoundGroup::setMaxAudibleBehavior to determine what happens when more sounds 
    are played than are specified with SoundGroup::setMaxAudible.

    [REMARKS]
    When using FMOD_SOUNDGROUP_BEHAVIOR_MUTE, SoundGroup::setMuteFadeSpeed can be used to stop a sudden transition.  
    Instead, the time specified will be used to cross fade between the sounds that go silent and the ones that become audible.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    SoundGroup::setMaxAudibleBehavior
    SoundGroup::getMaxAudibleBehavior
    SoundGroup::setMaxAudible
    SoundGroup::getMaxAudible
    SoundGroup::setMuteFadeSpeed
    SoundGroup::getMuteFadeSpeed
]
}
FMOD_SOUNDGROUP_BEHAVIOR_FAIL: 0 { Any sound played that puts the sound count over the SoundGroup::setMaxAudible setting, will simply fail during System::playSound. }
FMOD_SOUNDGROUP_BEHAVIOR_MUTE: 1 { Any sound played that puts the sound count over the SoundGroup::setMaxAudible setting, will be silent, then if another sound in the group stops the sound that was silent before becomes audible again. }
FMOD_SOUNDGROUP_BEHAVIOR_STEALLOWEST: 2 { Any sound played that puts the sound count over the SoundGroup::setMaxAudible setting, will steal the quietest / least important sound playing in the group. }

FMOD_SOUNDGROUP_BEHAVIOR_MAX: 3 { Maximum number of open state types. }
FMOD_SOUNDGROUP_BEHAVIOR_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_SOUNDGROUP_BEHAVIOR: integer!;


{
[ENUM]
[
    [DESCRIPTION]   
    These callback types are used with Channel::setCallback.

    [REMARKS]
    Each callback has commanddata parameters passed as int unique to the type of callback.
    See reference to FMOD_CHANNEL_CALLBACK to determine what they might mean for each type of callback.
    
    <b>Note!</b>  Currently the user must call System::update for these callbacks to trigger!

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Channel::setCallback
    FMOD_CHANNEL_CALLBACK
    System::update
]
}
FMOD_CHANNEL_CALLBACKTYPE_END: 0 { Called when a sound ends. }
FMOD_CHANNEL_CALLBACKTYPE_VIRTUALVOICE: 1 { Called when a voice is swapped out or swapped in. }
FMOD_CHANNEL_CALLBACKTYPE_SYNCPOINT: 2 { Called when a syncpoint is encountered.  Can be from wav file markers. }
FMOD_CHANNEL_CALLBACKTYPE_OCCLUSION: 3 { Called when the channel has its geometry occlusion value calculated.  Can be used to clamp or change the value. }

FMOD_CHANNEL_CALLBACKTYPE_MAX: 4 { Maximum number of callback types supported. }
FMOD_CHANNEL_CALLBACKTYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_CHANNEL_CALLBACKTYPE: integer!;


{
[ENUM]
[
    [DESCRIPTION]   
    These callback types are used with System::setCallback.

    [REMARKS]
    Each callback has commanddata parameters passed as void* unique to the type of callback.
    See reference to FMOD_SYSTEM_CALLBACK to determine what they might mean for each type of callback.
    
    <b>Note!</b> Using FMOD_SYSTEM_CALLBACKTYPE_DEVICELISTCHANGED (on Mac only) requires the application to be running an event loop which will allow external changes to device list to be detected by FMOD.
    
    <b>Note!</b> The 'system' object pointer will be null for FMOD_SYSTEM_CALLBACKTYPE_THREADCREATED and FMOD_SYSTEM_CALLBACKTYPE_MEMORYALLOCATIONFAILED callbacks.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    System::setCallback
    FMOD_SYSTEM_CALLBACK
    System::update
    DSP::addInput
]
}
FMOD_SYSTEM_CALLBACKTYPE_DEVICELISTCHANGED: 0 { Called from System::update when the enumerated list of devices has changed. }
FMOD_SYSTEM_CALLBACKTYPE_DEVICELOST: 1 { Called from System::update when an output device has been lost due to control panel parameter changes and FMOD cannot automatically recover. }
FMOD_SYSTEM_CALLBACKTYPE_MEMORYALLOCATIONFAILED: 2 { Called directly when a memory allocation fails somewhere in FMOD.  (NOTE - 'system' will be NULL in this callback type.)}
FMOD_SYSTEM_CALLBACKTYPE_THREADCREATED: 3 { Called directly when a thread is created. (NOTE - 'system' will be NULL in this callback type.) }
FMOD_SYSTEM_CALLBACKTYPE_BADDSPCONNECTION: 4 { Called when a bad connection was made with DSP::addInput. Usually called from mixer thread because that is where the connections are made.  }
FMOD_SYSTEM_CALLBACKTYPE_BADDSPLEVEL: 5 { Called when too many effects were added exceeding the maximum tree depth of 128.  This is most likely caused by accidentally adding too many DSP effects. Usually called from mixer thread because that is where the connections are made.  }

FMOD_SYSTEM_CALLBACKTYPE_MAX: 6 { Maximum number of callback types supported. }
FMOD_SYSTEM_CALLBACKTYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_SYSTEM_CALLBACKTYPE: integer!;


{ 
    FMOD Callbacks
}
{typedef FMOD_RESULT (F_CALLBACK *FMOD_SYSTEM_CALLBACK)       (FMOD_SYSTEM *system, FMOD_SYSTEM_CALLBACKTYPE type, void *commanddata1, void *commanddata2);

typedef FMOD_RESULT (F_CALLBACK *FMOD_CHANNEL_CALLBACK)      (FMOD_CHANNEL *channel, FMOD_CHANNEL_CALLBACKTYPE type, void *commanddata1, void *commanddata2);

typedef FMOD_RESULT (F_CALLBACK *FMOD_SOUND_NONBLOCKCALLBACK)(FMOD_SOUND *sound, FMOD_RESULT result);
typedef FMOD_RESULT (F_CALLBACK *FMOD_SOUND_PCMREADCALLBACK)(FMOD_SOUND *sound, void *data, unsigned int datalen);
typedef FMOD_RESULT (F_CALLBACK *FMOD_SOUND_PCMSETPOSCALLBACK)(FMOD_SOUND *sound, int subsound, unsigned int position, FMOD_TIMEUNIT postype);

typedef FMOD_RESULT (F_CALLBACK *FMOD_FILE_OPENCALLBACK)     (const char *name, int unicode, unsigned int *filesize, void **handle, void **userdata);
typedef FMOD_RESULT (F_CALLBACK *FMOD_FILE_CLOSECALLBACK)    (void *handle, void *userdata);
typedef FMOD_RESULT (F_CALLBACK *FMOD_FILE_READCALLBACK)     (void *handle, void *buffer, unsigned int sizebytes, unsigned int *bytesread, void *userdata);
typedef FMOD_RESULT (F_CALLBACK *FMOD_FILE_SEEKCALLBACK)     (void *handle, unsigned int pos, void *userdata);
typedef FMOD_RESULT (F_CALLBACK *FMOD_FILE_ASYNCREADCALLBACK)(FMOD_ASYNCREADINFO *info, void *userdata);
typedef FMOD_RESULT (F_CALLBACK *FMOD_FILE_ASYNCCANCELCALLBACK)(void *handle, void *userdata);

typedef void *      (F_CALLBACK *FMOD_MEMORY_ALLOCCALLBACK)  (unsigned int size, FMOD_MEMORY_TYPE type, const char *sourcestr);
typedef void *      (F_CALLBACK *FMOD_MEMORY_REALLOCCALLBACK)(void *ptr, unsigned int size, FMOD_MEMORY_TYPE type, const char *sourcestr);
typedef void        (F_CALLBACK *FMOD_MEMORY_FREECALLBACK)   (void *ptr, FMOD_MEMORY_TYPE type, const char *sourcestr);

typedef float       (F_CALLBACK *FMOD_3D_ROLLOFFCALLBACK)    (FMOD_CHANNEL *channel, float distance);
}
FMOD_SYSTEM_CALLBACK: integer!

FMOD_CHANNEL_CALLBACK: integer!

FMOD_SOUND_NONBLOCKCALLBACK: integer!
FMOD_SOUND_PCMREADCALLBACK: integer!
FMOD_SOUND_PCMSETPOSCALLBACK: integer!

FMOD_FILE_OPENCALLBACK: integer!
FMOD_FILE_CLOSECALLBACK: integer!
FMOD_FILE_READCALLBACK: integer!
FMOD_FILE_SEEKCALLBACK: integer!
FMOD_FILE_ASYNCREADCALLBACK: integer!
FMOD_FILE_ASYNCCANCELCALLBACK: integer!

FMOD_MEMORY_ALLOCCALLBACK: integer!
FMOD_MEMORY_REALLOCCALLBACK: integer!
FMOD_MEMORY_FREECALLBACK: integer!

FMOD_3D_ROLLOFFCALLBACK: integer!

{
[ENUM]
[
    [DESCRIPTION]   
    List of windowing methods used in spectrum analysis to reduce leakage / transient signals intefering with the analysis.
    This is a problem with analysis of continuous signals that only have a small portion of the signal sample (the fft window size).
    Windowing the signal with a curve or triangle tapers the sides of the fft window to help alleviate this problem.

    [REMARKS]
    Cyclic signals such as a sine wave that repeat their cycle in a multiple of the window size do not need windowing.
    I.e. If the sine wave repeats every 1024, 512, 256 etc samples and the FMOD fft window is 1024, then the signal would not need windowing.
    Not windowing is the same as FMOD_DSP_FFT_WINDOW_RECT, which is the default.
    If the cycle of the signal (ie the sine wave) is not a multiple of the window size, it will cause frequency abnormalities, so a different windowing method is needed.
    
    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    System::getSpectrum
    Channel::getSpectrum
]
}
FMOD_DSP_FFT_WINDOW_RECT: 0 { w[n] = 1.0                                                                                            }
FMOD_DSP_FFT_WINDOW_TRIANGLE: 1 { w[n] = TRI(2n/N)                                                                                      }
FMOD_DSP_FFT_WINDOW_HAMMING: 2 { w[n] = 0.54 - (0.46 * COS(n/N) )                                                                      }
FMOD_DSP_FFT_WINDOW_HANNING: 3 { w[n] = 0.5 *  (1.0  - COS(n/N) )                                                                      }
FMOD_DSP_FFT_WINDOW_BLACKMAN: 4 { w[n] = 0.42 - (0.5  * COS(n/N) ) + (0.08 * COS(2.0 * n/N) )                                           }
FMOD_DSP_FFT_WINDOW_BLACKMANHARRIS: 5 { w[n] = 0.35875 - (0.48829 * COS(1.0 * n/N)) + (0.14128 * COS(2.0 * n/N)) - (0.01168 * COS(3.0 * n/N)) }

FMOD_DSP_FFT_WINDOW_MAX: 6 { Maximum number of FFT window types supported. }
FMOD_DSP_FFT_WINDOW_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_DSP_FFT_WINDOW: integer!


{
[ENUM]
[
    [DESCRIPTION]   
    List of interpolation types that the FMOD Ex software mixer supports.  

    [REMARKS]
    The default resampler type is FMOD_DSP_RESAMPLER_LINEAR.
    Use System::setSoftwareFormat to tell FMOD the resampling quality you require for FMOD_SOFTWARE based sounds.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    System::setSoftwareFormat
    System::getSoftwareFormat
]
}
FMOD_DSP_RESAMPLER_NOINTERP: 0 { No interpolation.  High frequency aliasing hiss will be audible depending on the sample rate of the sound. }
FMOD_DSP_RESAMPLER_LINEAR: 1 { Linear interpolation (default method).  Fast and good quality, causes very slight lowpass effect on low frequency sounds. }
FMOD_DSP_RESAMPLER_CUBIC: 2 { Cubic interpolation.  Slower than linear interpolation but better quality. }
FMOD_DSP_RESAMPLER_SPLINE: 3 { 5 point spline interpolation.  Slowest resampling method but best quality. }

FMOD_DSP_RESAMPLER_MAX: 4 { Maximum number of resample methods supported. }
FMOD_DSP_RESAMPLER_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_DSP_RESAMPLER: integer!;


{
[ENUM]
[
    [DESCRIPTION]   
    List of tag types that could be stored within a sound.  These include id3 tags, metadata from netstreams and vorbis/asf data.

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Sound::getTag
]
}
FMOD_TAGTYPE_UNKNOWN: 0
FMOD_TAGTYPE_ID3V1: 1
FMOD_TAGTYPE_ID3V2: 2
FMOD_TAGTYPE_VORBISCOMMENT: 3
FMOD_TAGTYPE_SHOUTCAST: 4
FMOD_TAGTYPE_ICECAST: 5
FMOD_TAGTYPE_ASF: 6
FMOD_TAGTYPE_MIDI: 7
FMOD_TAGTYPE_PLAYLIST: 8
FMOD_TAGTYPE_FMOD: 9
FMOD_TAGTYPE_USER: 10

FMOD_TAGTYPE_MAX: 11 { Maximum number of tag types supported. }
FMOD_TAGTYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_TAGTYPE: integer!;


{
[ENUM]
[
    [DESCRIPTION]   
    List of data types that can be returned by Sound::getTag

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Sound::getTag
]
}
FMOD_TAGDATATYPE_BINARY: 0
FMOD_TAGDATATYPE_INT: 1
FMOD_TAGDATATYPE_FLOAT: 2
FMOD_TAGDATATYPE_STRING: 3
FMOD_TAGDATATYPE_STRING_UTF16: 4
FMOD_TAGDATATYPE_STRING_UTF16BE: 5
FMOD_TAGDATATYPE_STRING_UTF8: 6
FMOD_TAGDATATYPE_CDTOC: 7

FMOD_TAGDATATYPE_MAX: 8 { Maximum number of tag datatypes supported. }
FMOD_TAGDATATYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_TAGDATATYPE: integer!;


{
[ENUM]
[
    [DESCRIPTION]   
    Types of delay that can be used with Channel::setDelay / Channel::getDelay.

    [REMARKS]
    If you haven't called Channel::setDelay yet, if you call Channel::getDelay with FMOD_DELAYTYPE_DSPCLOCK_START it will return the 
    equivalent global DSP clock value to determine when a channel started, so that you can use it for other channels to sync against.
    
    Use System::getDSPClock to also get the current dspclock time, a base for future calls to Channel::setDelay.
    
    Use FMOD_64BIT_ADD or FMOD_64BIT_SUB to add a hi/lo combination together and cope with wraparound.
    
    If FMOD_DELAYTYPE_END_MS is specified, the value is not treated as a 64 bit number, just the delayhi value is used and it is treated as milliseconds.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Channel::setDelay
    Channel::getDelay
    System::getDSPClock
]
}
FMOD_DELAYTYPE_END_MS: 0 { Delay at the end of the sound in milliseconds.  Use delayhi only.   Channel::isPlaying will remain true until this delay has passed even though the sound itself has stopped playing.}
FMOD_DELAYTYPE_DSPCLOCK_START: 1 { Time the sound started if Channel::getDelay is used, or if Channel::setDelay is used, the sound will delay playing until this exact tick. }
FMOD_DELAYTYPE_DSPCLOCK_END: 2 { Time the sound should end. If this is non-zero, the channel will go silent at this exact tick. }
FMOD_DELAYTYPE_DSPCLOCK_PAUSE: 3 { Time the sound should pause. If this is non-zero, the channel will pause at this exact tick. }

FMOD_DELAYTYPE_MAX: 4 { Maximum number of tag datatypes supported. }
FMOD_DELAYTYPE_FORCEINT: 65536 { Makes sure this enum is signed 32bit. }
 { Makes sure this enum is signed 32bit. }
FMOD_DELAYTYPE: integer!;


{#define FMOD_64BIT_ADD(_hi1, _lo1, _hi2, _lo2) _hi1 += ((_hi2) + ((((_lo1) + (_lo2)) < (_lo1)) ? 1 : 0)); (_lo1) += (_lo2);
#define FMOD_64BIT_SUB(_hi1, _lo1, _hi2, _lo2) _hi1 -= ((_hi2) + ((((_lo1) - (_lo2)) > (_lo1)) ? 1 : 0)); (_lo1) -= (_lo2);}
FMOD_64BIT_ADD: func [_hi1  _lo1  _hi2  _lo2] [_hi1: _hi1 + (_hi2 + either (_lo1 + _lo2) < _lo1 [1] [0]) _lo1: _lo1 + _lo2]
FMOD_64BIT_SUB: func [_hi1  _lo1  _hi2  _lo2] [_hi1: _hi1 - (_hi2 + either (_lo1 - _lo2) > _lo1 [1] [0]) _lo1: _lo1 - _lo2]


{
[STRUCTURE] 
[
    [DESCRIPTION]   
    Structure describing a piece of tag data.

    [REMARKS]
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Sound::getTag
    FMOD_TAGTYPE
    FMOD_TAGDATATYPE
]
}
FMOD_TAG: make struct! [
  type [FMOD_TAGTYPE] { [r] The type of this tag. }
  datatype [FMOD_TAGDATATYPE] { [r] The type of data that this tag contains }
  name [string!] { [r] The name of this tag i.e. "TITLE", "ARTIST" etc. }
  data [integer!] { [r] Pointer to the tag data - its format is determined by the datatype member }
  datalen [integer!] { [r] Length of the data contained in this tag }
  updated [FMOD_BOOL] { [r] True if this tag has been updated since last being accessed with Sound::getTag }
] none ;


{
[STRUCTURE] 
[
    [DESCRIPTION]   
    Structure describing a CD/DVD table of contents

    [REMARKS]
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Sound::getTag
]
}
FMOD_CDTOC: make struct! [
  numtracks [integer!] { [r] The number of tracks on the CD }
  min [integer!] { [r] The start offset of each track in minutes }
  sec [integer!] { [r] The start offset of each track in seconds }
  frame [integer!] { [r] The start offset of each track in frames }
] none ;


{
[DEFINE]
[
    [NAME]
    FMOD_TIMEUNIT

    [DESCRIPTION]   
    List of time types that can be returned by Sound::getLength and used with Channel::setPosition or Channel::getPosition.

    [REMARKS]
    FMOD_TIMEUNIT_SENTENCE_MS, FMOD_TIMEUNIT_SENTENCE_PCM, FMOD_TIMEUNIT_SENTENCE_PCMBYTES, FMOD_TIMEUNIT_SENTENCE and FMOD_TIMEUNIT_SENTENCE_SUBSOUND are only supported by Channel functions.
    Do not combine flags except FMOD_TIMEUNIT_BUFFERED.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]      
    Sound::getLength
    Channel::setPosition
    Channel::getPosition
]
}
FMOD_TIMEUNIT_MS:                1  { Milliseconds. }
FMOD_TIMEUNIT_PCM:               2  { PCM samples, related to milliseconds * samplerate / 1000. }
FMOD_TIMEUNIT_PCMBYTES:          4  { Bytes, related to PCM samples * channels * datawidth (ie 16bit = 2 bytes). }
FMOD_TIMEUNIT_RAWBYTES:          8  { Raw file bytes of (compressed) sound data (does not include headers).  Only used by Sound::getLength and Channel::getPosition. }
FMOD_TIMEUNIT_PCMFRACTION:       16  { Fractions of 1 PCM sample.  Unsigned int range 0 to -1.  Used for sub-sample granularity for DSP purposes. }
FMOD_TIMEUNIT_MODORDER:          256  { MOD/S3M/XM/IT.  Order in a sequenced module format.  Use Sound::getFormat to determine the PCM format being decoded to. }
FMOD_TIMEUNIT_MODROW:            512  { MOD/S3M/XM/IT.  Current row in a sequenced module format.  Sound::getLength will return the number of rows in the currently playing or seeked to pattern. }
FMOD_TIMEUNIT_MODPATTERN:        1024  { MOD/S3M/XM/IT.  Current pattern in a sequenced module format.  Sound::getLength will return the number of patterns in the song and Channel::getPosition will return the currently playing pattern. }
FMOD_TIMEUNIT_SENTENCE_MS:       65536  { Currently playing subsound in a sentence time in milliseconds. }
FMOD_TIMEUNIT_SENTENCE_PCM:      131072  { Currently playing subsound in a sentence time in PCM Samples, related to milliseconds * samplerate / 1000. }
FMOD_TIMEUNIT_SENTENCE_PCMBYTES: 262144  { Currently playing subsound in a sentence time in bytes, related to PCM samples * channels * datawidth (ie 16bit = 2 bytes). }
FMOD_TIMEUNIT_SENTENCE:          524288  { Currently playing sentence index according to the channel. }
FMOD_TIMEUNIT_SENTENCE_SUBSOUND: 1048576  { Currently playing subsound index in a sentence. }
FMOD_TIMEUNIT_BUFFERED:          268435456  { Time value as seen by buffered stream.  This is always ahead of audible time, and is only used for processing. }
{ [DEFINE_END] }


{
[ENUM]
[
    [DESCRIPTION]
    When creating a multichannel sound, FMOD will pan them to their default speaker locations, for example a 6 channel sound will default to one channel per 5.1 output speaker.
    Another example is a stereo sound.  It will default to left = front left, right = front right.
    
    This is for sounds that are not 'default'.  For example you might have a sound that is 6 channels but actually made up of 3 stereo pairs, that should all be located in front left, front right only.

    [REMARKS]
    For full flexibility of speaker assignments, use Channel::setSpeakerLevels.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    FMOD_CREATESOUNDEXINFO
    Channel::setSpeakerLevels
]
}
FMOD_SPEAKERMAPTYPE_DEFAULT: 0 { This is the default, and just means FMOD decides which speakers it puts the source channels. }
FMOD_SPEAKERMAPTYPE_ALLMONO: 1 { This means the sound is made up of all mono sounds.  All voices will be panned to the front center by default in this case.  }
FMOD_SPEAKERMAPTYPE_ALLSTEREO: 2 { This means the sound is made up of all stereo sounds.  All voices will be panned to front left and front right alternating every second channel.  }
 { Map a 5.1 sound to use protools L C R Ls Rs LFE mapping.  Will return an error if not a 6 channel sound. }
FMOD_SPEAKERMAPTYPE_51_PROTOOLS: 3 { Map a 5.1 sound to use protools L C R Ls Rs LFE mapping.  Will return an error if not a 6 channel sound. }
 { Map a 5.1 sound to use protools L C R Ls Rs LFE mapping.  Will return an error if not a 6 channel sound. }
FMOD_SPEAKERMAPTYPE: integer!;


{
[STRUCTURE] 
[
    [DESCRIPTION]
    Use this structure with System::createSound when more control is needed over loading.
    The possible reasons to use this with System::createSound are:
    - Loading a file from memory.
    - Loading a file from within another larger (possibly wad/pak) file, by giving the loader an offset and length.
    - To create a user created / non file based sound.
    - To specify a starting subsound to seek to within a multi-sample sounds (ie FSB/DLS/SF2) when created as a stream.
    - To specify which subsounds to load for multi-sample sounds (ie FSB/DLS/SF2) so that memory is saved and only a subset is actually loaded/read from disk.
    - To specify 'piggyback' read and seek callbacks for capture of sound data as fmod reads and decodes it.  Useful for ripping decoded PCM data from sounds as they are loaded / played.
    - To specify a MIDI DLS/SF2 sample set file to load when opening a MIDI file.
    See below on what members to fill for each of the above types of sound you want to create.

    [REMARKS]
    This structure is optional!  Specify 0 or NULL in System::createSound if you don't need it!
    
    <u>Loading a file from memory.</u>
    - Create the sound using the FMOD_OPENMEMORY flag.
    - Mandatory.  Specify 'length' for the size of the memory block in bytes.
    - Other flags are optional.
    
    
    <u>Loading a file from within another larger (possibly wad/pak) file, by giving the loader an offset and length.</u>
    - Mandatory.  Specify 'fileoffset' and 'length'.
    - Other flags are optional.
    
    
    <u>To create a user created / non file based sound.</u>
    - Create the sound using the FMOD_OPENUSER flag.
    - Mandatory.  Specify 'defaultfrequency, 'numchannels' and 'format'.
    - Other flags are optional.
    
    
    <u>To specify a starting subsound to seek to and flush with, within a multi-sample stream (ie FSB/DLS/SF2).</u>
    
    - Mandatory.  Specify 'initialsubsound'.
    
    
    <u>To specify which subsounds to load for multi-sample sounds (ie FSB/DLS/SF2) so that memory is saved and only a subset is actually loaded/read from disk.</u>
    
    - Mandatory.  Specify 'inclusionlist' and 'inclusionlistnum'.
    
    
    <u>To specify 'piggyback' read and seek callbacks for capture of sound data as fmod reads and decodes it.  Useful for ripping decoded PCM data from sounds as they are loaded / played.</u>
    
    - Mandatory.  Specify 'pcmreadcallback' and 'pcmseekcallback'.
    
    
    <u>To specify a MIDI DLS/SF2 sample set file to load when opening a MIDI file.</u>
    
    - Mandatory.  Specify 'dlsname'.
    
    
    Setting the 'decodebuffersize' is for cpu intensive codecs that may be causing stuttering, not file intensive codecs (ie those from CD or netstreams) which are normally 
    altered with System::setStreamBufferSize.  As an example of cpu intensive codecs, an mp3 file will take more cpu to decode than a PCM wav file.
    If you have a stuttering effect, then it is using more cpu than the decode buffer playback rate can keep up with.  Increasing the decode buffersize will most likely solve this problem.
    
    
    FSB codec.  If inclusionlist and numsubsounds are used together, this will trigger a special mode where subsounds are shuffled down to save memory.  (useful for large FSB 
    files where you only want to load 1 sound).  There will be no gaps, ie no null subsounds.  As an example, if there are 10,000 subsounds and there is an inclusionlist with only 1 entry, 
    and numsubsounds = 1, then subsound 0 will be that entry, and there will only be the memory allocated for 1 subsound.  Previously there would still be 10,000 subsound pointers and other
    associated codec entries allocated along with it multiplied by 10,000.
    
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::createSound
    System::setStreamBufferSize
    FMOD_MODE
    FMOD_SOUND_FORMAT
    FMOD_SOUND_TYPE
    FMOD_SPEAKERMAPTYPE
]
}
FMOD_CREATESOUNDEXINFO: make struct! [
  cbsize [integer!] { [w] Size of this structure.  This is used so the structure can be expanded in the future and still work on older versions of FMOD Ex. }
  length [integer!] { [w] Optional. Specify 0 to ignore. Size in bytes of file to load, or sound to create (in this case only if FMOD_OPENUSER is used).  Required if loading from memory.  If 0 is specified, then it will use the size of the file (unless loading from memory then an error will be returned). }
  fileoffset [integer!] { [w] Optional. Specify 0 to ignore. Offset from start of the file to start loading from.  This is useful for loading files from inside big data files. }
  numchannels [integer!] { [w] Optional. Specify 0 to ignore. Number of channels in a sound mandatory if FMOD_OPENUSER or FMOD_OPENRAW is used. }
  defaultfrequency [integer!] { [w] Optional. Specify 0 to ignore. Default frequency of sound in a sound mandatory if FMOD_OPENUSER or FMOD_OPENRAW is used.  Other formats use the frequency determined by the file format. }
  format [FMOD_SOUND_FORMAT] { [w] Optional. Specify 0 or FMOD_SOUND_FORMAT_NONE to ignore. Format of the sound mandatory if FMOD_OPENUSER or FMOD_OPENRAW is used.  Other formats use the format determined by the file format.   }
  decodebuffersize [integer!] { [w] Optional. Specify 0 to ignore. For streams.  This determines the size of the double buffer (in PCM samples) that a stream uses.  Use this for user created streams if you want to determine the size of the callback buffer passed to you.  Specify 0 to use FMOD's default size which is currently equivalent to 400ms of the sound format created/loaded. }
  initialsubsound [integer!] { [w] Optional. Specify 0 to ignore. In a multi-sample file format such as .FSB/.DLS/.SF2, specify the initial subsound to seek to, only if FMOD_CREATESTREAM is used. }
  numsubsounds [integer!] { [w] Optional. Specify 0 to ignore or have no subsounds.  In a sound created with FMOD_OPENUSER, specify the number of subsounds that are accessable with Sound::getSubSound.  If not created with FMOD_OPENUSER, this will limit the number of subsounds loaded within a multi-subsound file.  If using FSB, then if FMOD_CREATESOUNDEXINFO::inclusionlist is used, this will shuffle subsounds down so that there are not any gaps.  It will mean that the indices of the sounds will be different. }
  inclusionlist [integer!] { [w] Optional. Specify 0 to ignore. In a multi-sample format such as .FSB/.DLS/.SF2 it may be desirable to specify only a subset of sounds to be loaded out of the whole file.  This is an array of subsound indices to load into memory when created. }
  inclusionlistnum [integer!] { [w] Optional. Specify 0 to ignore. This is the number of integers contained within the inclusionlist array. }
  pcmreadcallback [FMOD_SOUND_PCMREADCALLBACK] { [w] Optional. Specify 0 to ignore. Callback to 'piggyback' on FMOD's read functions and accept or even write PCM data while FMOD is opening the sound.  Used for user sounds created with FMOD_OPENUSER or for capturing decoded data as FMOD reads it. }
  pcmsetposcallback [FMOD_SOUND_PCMSETPOSCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for when the user calls a seeking function such as Channel::setTime or Channel::setPosition within a multi-sample sound, and for when it is opened.}
  nonblockcallback [FMOD_SOUND_NONBLOCKCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for successful completion, or error while loading a sound that used the FMOD_NONBLOCKING flag.}
  dlsname [string!] { [w] Optional. Specify 0 to ignore. Filename for a DLS or SF2 sample set when loading a MIDI file. If not specified, on Windows it will attempt to open /windows/system32/drivers/gm.dls or /windows/system32/drivers/etc/gm.dls, on Mac it will attempt to load /System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls, otherwise the MIDI will fail to open. Current DLS support is for level 1 of the specification. }
  encryptionkey [string!] { [w] Optional. Specify 0 to ignore. Key for encrypted FSB file.  Without this key an encrypted FSB file will not load. }
  maxpolyphony [integer!] { [w] Optional. Specify 0 to ignore. For sequenced formats with dynamic channel allocation such as .MID and .IT, this specifies the maximum voice count allowed while playing.  .IT defaults to 64.  .MID defaults to 32. }
  userdata [integer!] { [w] Optional. Specify 0 to ignore. This is user data to be attached to the sound during creation.  Access via Sound::getUserData.  Note: This is not passed to FMOD_FILE_OPENCALLBACK, that is a different userdata that is file specific. }
  suggestedsoundtype [FMOD_SOUND_TYPE] { [w] Optional. Specify 0 or FMOD_SOUND_TYPE_UNKNOWN to ignore.  Instead of scanning all codec types, use this to speed up loading by making it jump straight to this codec. }
  useropen [FMOD_FILE_OPENCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for opening this file. }
  userclose [FMOD_FILE_CLOSECALLBACK] { [w] Optional. Specify 0 to ignore. Callback for closing this file. }
  userread [FMOD_FILE_READCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for reading from this file. }
  userseek [FMOD_FILE_SEEKCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for seeking within this file. }
  userasyncread [FMOD_FILE_ASYNCREADCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for seeking within this file. }
  userasynccancel [FMOD_FILE_ASYNCCANCELCALLBACK] { [w] Optional. Specify 0 to ignore. Callback for seeking within this file. }
  speakermap [FMOD_SPEAKERMAPTYPE] { [w] Optional. Specify 0 to ignore. Use this to differ the way fmod maps multichannel sounds to speakers.  See FMOD_SPEAKERMAPTYPE for more. }
  initialsoundgroup [integer!] { [w] Optional. Specify 0 to ignore. Specify a sound group if required, to put sound in as it is created. }
  initialseekposition [integer!] { [w] Optional. Specify 0 to ignore. For streams. Specify an initial position to seek the stream to. }
  initialseekpostype [FMOD_TIMEUNIT] { [w] Optional. Specify 0 to ignore. For streams. Specify the time unit for the position set in initialseekposition. }
  ignoresetfilesystem [integer!] { [w] Optional. Specify 0 to ignore. Set to 1 to use fmod's built in file system. Ignores setFileSystem callbacks and also FMOD_CREATESOUNEXINFO file callbacks.  Useful for specific cases where you don't want to use your own file system but want to use fmod's file system (ie net streaming). }
  cddaforceaspi [integer!] { [w] Optional. Specify 0 to ignore. For CDDA sounds only - if non-zero use ASPI instead of NTSCSI to access the specified CD/DVD device. }
  audioqueuepolicy [integer!] { [w] Optional. Specify 0 or FMOD_AUDIOQUEUE_CODECPOLICY_DEFAULT to ignore. Policy used to determine whether hardware or software is used for decoding, see FMOD_AUDIOQUEUE_CODECPOLICY for options (iOS >= 3.0 required, otherwise only hardware is available) }
  minmidigranularity [integer!] { [w] Optional. Specify 0 to ignore. Allows you to set a minimum desired MIDI mixer granularity. Values smaller than 512 give greater than default accuracy at the cost of more CPU and vice versa. Specify 0 for default (512 samples). }
  nonblockthreadid [integer!] { [w] Optional. Specify 0 to ignore. Specifies a thread index to execute non blocking load on.  Allows for up to 5 threads to be used for loading at once.  This is to avoid one load blocking another.  Maximum value = 4. }
] none ;


{
[STRUCTURE] 
[
    [DESCRIPTION]
    Structure defining a reverb environment.

    [REMARKS]
    Note the default reverb properties are the same as the FMOD_PRESET_GENERIC preset.
    Note that integer values that typically range from -10,000 to 1000 are represented in 
    decibels, and are of a logarithmic scale, not linear, wheras float values are always linear.
    
    The numerical values listed below are the maximum, minimum and default values for each variable respectively.
    
    <b>SUPPORTED</b> next to each parameter means the platform the parameter can be set on.  Some platforms support all parameters and some don't.
    WII   means Nintendo Wii hardware reverb (must use FMOD_HARDWARE).
    PSP   means Playstation Portable hardware reverb (must use FMOD_HARDWARE).
    SFX   means FMOD SFX software reverb.  This works on any platform that uses FMOD_SOFTWARE for loading sounds.
    ---   means unsupported/deprecated.  Will either be removed or supported by SFX in the future.
    
    Nintendo Wii Notes:
    This structure supports only limited parameters, and maps them to the Wii hardware reverb as follows.
    DecayTime = 'time'
    ReverbDelay = 'predelay'
    ModulationDepth = 'damping'
    Reflections = 'coloration'
    EnvDiffusion = 'crosstalk'
    Room = 'mix'
    
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.
    Members marked with [r/w] are either read or write depending on if you are using System::setReverbProperties (w) or System::getReverbProperties (r).

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::setReverbProperties
    System::getReverbProperties
    FMOD_REVERB_PRESETS
    FMOD_REVERB_FLAGS
]
}
FMOD_REVERB_PROPERTIES: make struct! [
 {       MIN    MAX    DEFAULT DESCRIPTION }
  Instance [integer!] { [w]   0      3      0       Environment Instance.                                                 (SUPPORTED:SFX(4 instances) and Wii (3 instances)) }
  Environment [integer!] { [r/w] -1     25     -1      Sets all listener properties.  -1 = OFF.                              (SUPPORTED:SFX(-1 only)/PSP) }
  EnvDiffusion [float] { [r/w] 0.0    1.0    1.0     Environment diffusion                                                 (SUPPORTED:WII) }
  Room [integer!] { [r/w] -10000 0      -1000   Room effect level (at mid frequencies)                                (SUPPORTED:SFX/WII/PSP) }
  RoomHF [integer!] { [r/w] -10000 0      -100    Relative room effect level at high frequencies                        (SUPPORTED:SFX) }
  RoomLF [integer!] { [r/w] -10000 0      0       Relative room effect level at low frequencies                         (SUPPORTED:SFX) }
  DecayTime [float] { [r/w] 0.1    20.0   1.49    Reverberation decay time at mid frequencies                           (SUPPORTED:SFX/WII) }
  DecayHFRatio [float] { [r/w] 0.1    2.0    0.83    High-frequency to mid-frequency decay time ratio                      (SUPPORTED:SFX) }
  DecayLFRatio [float] { [r/w] 0.1    2.0    1.0     Low-frequency to mid-frequency decay time ratio                       (SUPPORTED:---) }
  Reflections [integer!] { [r/w] -10000 1000   -2602   Early reflections level relative to room effect                       (SUPPORTED:SFX/WII) }
  ReflectionsDelay [float] { [r/w] 0.0    0.3    0.007   Initial reflection delay time                                         (SUPPORTED:SFX) }
  Reverb [integer!] { [r/w] -10000 2000   200     Late reverberation level relative to room effect                      (SUPPORTED:SFX) }
  ReverbDelay [float] { [r/w] 0.0    0.1    0.011   Late reverberation delay time relative to initial reflection          (SUPPORTED:SFX/WII) }
  ModulationTime [float] { [r/w] 0.04   4.0    0.25    Modulation time                                                       (SUPPORTED:---) }
  ModulationDepth [float] { [r/w] 0.0    1.0    0.0     Modulation depth                                                      (SUPPORTED:WII) }
  HFReference [float] { [r/w] 1000.0 20000  5000.0  Reference high frequency (hz)                                         (SUPPORTED:SFX) }
  LFReference [float] { [r/w] 20.0   1000.0 250.0   Reference low frequency (hz)                                          (SUPPORTED:SFX) }
  Diffusion [float] { [r/w] 0.0    100.0  100.0   Value that controls the echo density in the late reverberation decay. (SUPPORTED:SFX) }
  Density [float] { [r/w] 0.0    100.0  100.0   Value that controls the modal density in the late reverberation decay (SUPPORTED:SFX) }
  Flags [integer!] { [r/w] FMOD_REVERB_FLAGS - modifies the behavior of above properties                               (SUPPORTED:WII) }
] none ;


{
[DEFINE] 
[
    [NAME] 
    FMOD_REVERB_FLAGS

    [DESCRIPTION]
    Values for the Flags member of the FMOD_REVERB_PROPERTIES structure.

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    FMOD_REVERB_PROPERTIES
]
}
FMOD_REVERB_FLAGS_HIGHQUALITYREVERB:     1024 { Wii. Use high quality reverb }
FMOD_REVERB_FLAGS_HIGHQUALITYDPL2REVERB: 2048 { Wii. Use high quality DPL2 reverb }
FMOD_REVERB_FLAGS_DEFAULT:               0
{ [DEFINE_END] }


{
[DEFINE] 
[
    [NAME] 
    FMOD_REVERB_PRESETS

    [DESCRIPTION]   
    A set of predefined environment PARAMETERS.
    These are used to initialize an FMOD_REVERB_PROPERTIES structure statically.
    i.e.
    FMOD_REVERB_PROPERTIES prop = FMOD_PRESET_GENERIC;

    [REMARKS]

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::setReverbProperties
]
}
{                             Inst Env  Diffus  Room  RoomHF  RmLF DecTm   DecHF DecLF  Refl  RefDel  Revb  RevDel ModTm  ModDp   HFRef  LFRef Diffus Densty FLAGS }
FMOD_PRESET_OFF:              [  0  -1   1.00  -10000  -10000  0    1.00   1.00  1.0   -2602  0.007    200  0.011  0.25  0.000  5000.0  250.0    0.0    0.0  51 ]
FMOD_PRESET_GENERIC:          [  0   0   1.00  -1000   -100    0    1.49   0.83  1.0   -2602  0.007    200  0.011  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_PADDEDCELL:       [  0   1   1.00  -1000   -6000   0    0.17   0.10  1.0   -1204  0.001    207  0.002  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_ROOM:             [  0   2   1.00  -1000   -454    0    0.40   0.83  1.0   -1646  0.002     53  0.003  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_BATHROOM:         [  0   3   1.00  -1000   -1200   0    1.49   0.54  1.0    -370  0.007   1030  0.011  0.25  0.000  5000.0  250.0  100.0   60.0  3 ]
FMOD_PRESET_LIVINGROOM:       [  0   4   1.00  -1000   -6000   0    0.50   0.10  1.0   -1376  0.003  -1104  0.004  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_STONEROOM:        [  0   5   1.00  -1000   -300    0    2.31   0.64  1.0    -711  0.012     83  0.017  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_AUDITORIUM:       [  0   6   1.00  -1000   -476    0    4.32   0.59  1.0    -789  0.020   -289  0.030  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_CONCERTHALL:      [  0   7   1.00  -1000   -500    0    3.92   0.70  1.0   -1230  0.020     -2  0.029  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_CAVE:             [  0   8   1.00  -1000   0       0    2.91   1.30  1.0    -602  0.015   -302  0.022  0.25  0.000  5000.0  250.0  100.0  100.0  1 ]
FMOD_PRESET_ARENA:            [  0   9   1.00  -1000   -698    0    7.24   0.33  1.0   -1166  0.020     16  0.030  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_HANGAR:           [  0   10  1.00  -1000   -1000   0    10.05  0.23  1.0    -602  0.020    198  0.030  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_CARPETTEDHALLWAY: [  0   11  1.00  -1000   -4000   0    0.30   0.10  1.0   -1831  0.002  -1630  0.030  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_HALLWAY:          [  0   12  1.00  -1000   -300    0    1.49   0.59  1.0   -1219  0.007    441  0.011  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_STONECORRIDOR:    [  0   13  1.00  -1000   -237    0    2.70   0.79  1.0   -1214  0.013    395  0.020  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_ALLEY:            [  0   14  0.30  -1000   -270    0    1.49   0.86  1.0   -1204  0.007     -4  0.011  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_FOREST:           [  0   15  0.30  -1000   -3300   0    1.49   0.54  1.0   -2560  0.162   -229  0.088  0.25  0.000  5000.0  250.0   79.0  100.0  3 ]
FMOD_PRESET_CITY:             [  0   16  0.50  -1000   -800    0    1.49   0.67  1.0   -2273  0.007  -1691  0.011  0.25  0.000  5000.0  250.0   50.0  100.0  3 ]
FMOD_PRESET_MOUNTAINS:        [  0   17  0.27  -1000   -2500   0    1.49   0.21  1.0   -2780  0.300  -1434  0.100  0.25  0.000  5000.0  250.0   27.0  100.0  1 ]
FMOD_PRESET_QUARRY:           [  0   18  1.00  -1000   -1000   0    1.49   0.83  1.0  -10000  0.061    500  0.025  0.25  0.000  5000.0  250.0  100.0  100.0  3 ]
FMOD_PRESET_PLAIN:            [  0   19  0.21  -1000   -2000   0    1.49   0.50  1.0   -2466  0.179  -1926  0.100  0.25  0.000  5000.0  250.0   21.0  100.0  3 ]
FMOD_PRESET_PARKINGLOT:       [  0   20  1.00  -1000   0       0    1.65   1.50  1.0   -1363  0.008  -1153  0.012  0.25  0.000  5000.0  250.0  100.0  100.0  1 ]
FMOD_PRESET_SEWERPIPE:        [  0   21  0.80  -1000   -1000   0    2.81   0.14  1.0     429  0.014   1023  0.021  0.25  0.000  5000.0  250.0   80.0   60.0  3 ]
FMOD_PRESET_UNDERWATER:       [  0   22  1.00  -1000   -4000   0    1.49   0.10  1.0    -449  0.007   1700  0.011  1.18  0.348  5000.0  250.0  100.0  100.0  3 ]

{ PlayStation Portable Only presets }
FMOD_PRESET_PSP_ROOM:         [  0   1   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_STUDIO_A:     [  0   2   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_STUDIO_B:     [  0   3   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_STUDIO_C:     [  0   4   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_HALL:         [  0   5   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_SPACE:        [  0   6   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_ECHO:         [  0   7   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_DELAY:        [  0   8   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
FMOD_PRESET_PSP_PIPE:         [  0   9   0      0       0       0    0.0    0.0   0.0      0   0.000      0  0.000  0.00  0.000  0000.0    0.0   0.0     0.0  49 ]
{ [DEFINE_END] }


{
[STRUCTURE] 
[
    [DESCRIPTION]
    Structure defining the properties for a reverb source, related to a FMOD channel.
    
    Note the default reverb properties are the same as the FMOD_PRESET_GENERIC preset.
    Note that integer values that typically range from -10,000 to 1000 are represented in 
    decibels, and are of a logarithmic scale, not linear, wheras float values are typically linear.
    PORTABILITY: Each member has the platform it supports in braces ie (win32/wii).
    
    The numerical values listed below are the maximum, minimum and default values for each variable respectively.

    [REMARKS]
    <b>SUPPORTED</b> next to each parameter means the platform the parameter can be set on.  Some platforms support all parameters and some don't.
    WII   means Nintendo Wii hardware reverb (must use FMOD_HARDWARE).
    PSP   means Playstation Portable hardware reverb (must use FMOD_HARDWARE).
    SFX   means FMOD SFX software reverb.  This works on any platform that uses FMOD_SOFTWARE for loading sounds.
    ---   means unsupported/deprecated.  Will either be removed or supported by SFX in the future.
    
    
    <b>'ConnectionPoint' Parameter.</b>  This parameter is for the FMOD software reverb only (known as SFX in the list above).
    By default the dsp network connection for a channel and its reverb is between the 'SFX Reverb' unit, and the channel's wavetable/resampler/dspcodec/oscillator unit (the unit below the channel DSP head).  NULL can be used for this parameter to make it use this default behaviour.
    This parameter allows the user to connect the SFX reverb to somewhere else internally, for example the channel DSP head, or a related channelgroup.  The event system uses this so that it can have the output of an event going to the reverb, instead of just the output of the event's channels (thereby ignoring event effects/submixes etc).
    Do not use if you are unaware of DSP network connection issues.  Leave it at the default of NULL instead.
    
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.
    Members marked with [r/w] are either read or write depending on if you are using Channel::setReverbProperties (w) or Channel::getReverbProperties (r).

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    Channel::setReverbProperties
    Channel::getReverbProperties
    FMOD_REVERB_CHANNELFLAGS 
]
}
FMOD_REVERB_CHANNELPROPERTIES: make struct! [

 {       MIN    MAX  DEFAULT  DESCRIPTION }
  Direct [integer!] { [r/w] -10000 1000 0        Direct path level                                        (SUPPORTED:SFX) }
  Room [integer!] { [r/w] -10000 1000 0        Room effect level                                        (SUPPORTED:SFX) }
  Flags [integer!] { [r/w] FMOD_REVERB_CHANNELFLAGS - modifies the behavior of properties                (SUPPORTED:SFX) }
  ConnectionPoint [integer!] { [r/w] See remarks.         DSP network location to connect reverb for this channel. (SUPPORTED:SFX).}
] none ;


{
[DEFINE] 
[
    [NAME] 
    FMOD_REVERB_CHANNELFLAGS

    [DESCRIPTION]
    Values for the Flags member of the FMOD_REVERB_CHANNELPROPERTIES structure.

    [REMARKS]
    For SFX Reverb, there is support for multiple reverb environments.
    Use FMOD_REVERB_CHANNELFLAGS_ENVIRONMENT0 to FMOD_REVERB_CHANNELFLAGS_ENVIRONMENT3 in the flags member 
    of FMOD_REVERB_CHANNELPROPERTIES to specify which environment instance(s) to target. 
    - If you do not specify any instance the first reverb instance will be used.
    - If you specify more than one instance with getReverbProperties, the first instance will be used.
    - If you specify more than one instance with setReverbProperties, it will set more than 1 instance at once.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    FMOD_REVERB_CHANNELPROPERTIES
]
}
FMOD_REVERB_CHANNELFLAGS_INSTANCE0:     16 { SFX/Wii. Specify channel to target reverb instance 0.  Default target. }
FMOD_REVERB_CHANNELFLAGS_INSTANCE1:     32 { SFX/Wii. Specify channel to target reverb instance 1. }
FMOD_REVERB_CHANNELFLAGS_INSTANCE2:     64 { SFX/Wii. Specify channel to target reverb instance 2. }
FMOD_REVERB_CHANNELFLAGS_INSTANCE3:     128 { SFX. Specify channel to target reverb instance 3. }

FMOD_REVERB_CHANNELFLAGS_DEFAULT:       FMOD_REVERB_CHANNELFLAGS_INSTANCE0
{ [DEFINE_END] }


{
[STRUCTURE] 
[
    [DESCRIPTION]
    Settings for advanced features like configuring memory and cpu usage for the FMOD_CREATECOMPRESSEDSAMPLE feature.

    [REMARKS]
    maxMPEGcodecs / maxADPCMcodecs / maxXMAcodecs will determine the maximum cpu usage of playing realtime samples.  Use this to lower potential excess cpu usage and also control memory usage.
    
    maxPCMcodecs is for use with PS3 only. It will determine the maximum number of PCM voices that can be played at once. This includes streams of any format and all sounds created
    *without* the FMOD_CREATECOMPRESSEDSAMPLE flag.
    
    Memory will be allocated for codecs 'up front' (during System::init) if these values are specified as non zero.  If any are zero, it allocates memory for the codec whenever a file of the type in question is loaded.  So if maxMPEGcodecs is 0 for example, it will allocate memory for the mpeg codecs the first time an mp3 is loaded or an mp3 based .FSB file is loaded.
    
    Due to inefficient encoding techniques on certain .wav based ADPCM files, FMOD can can need an extra 29720 bytes per codec.  This means for lowest memory consumption.  Use FSB as it uses an optimal/small ADPCM block size.
    
    Members marked with [r] mean the variable is modified by FMOD and is for reading purposes only.  Do not change this value.
    Members marked with [w] mean the variable can be written to.  The user can set the value.
    Members marked with [r/w] are either read or write depending on if you are using System::setAdvancedSettings (w) or System::getAdvancedSettings (r).

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::setAdvancedSettings
    System::getAdvancedSettings
    System::init
    FMOD_MODE
]
}
FMOD_ADVANCEDSETTINGS: make struct! [
  cbsize [integer!] { [w]   Size of this structure.  Use sizeof(FMOD_ADVANCEDSETTINGS)  NOTE: This must be set before calling System::getAdvancedSettings! }
  maxMPEGcodecs [integer!] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_CREATECOMPRESSEDSAMPLE only.  Mpeg  codecs consume 21,684 bytes per instance and this number will determine how many mpeg channels can be played simultaneously.   Default = 32. }
  maxADPCMcodecs [integer!] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_CREATECOMPRESSEDSAMPLE only.  ADPCM codecs consume  2,136 bytes per instance and this number will determine how many ADPCM channels can be played simultaneously.  Default = 32. }
  maxXMAcodecs [integer!] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_CREATECOMPRESSEDSAMPLE only.  XMA   codecs consume 14,836 bytes per instance and this number will determine how many XMA channels can be played simultaneously.    Default = 32. }
  maxCELTcodecs [integer!] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_CREATECOMPRESSEDSAMPLE only.  CELT  codecs consume 11,500 bytes per instance and this number will determine how many CELT channels can be played simultaneously.   Default = 32. }
  maxPCMcodecs [integer!] { [r/w] Optional. Specify 0 to ignore. For use with PS3 only.                          PCM   codecs consume 12,672 bytes per instance and this number will determine how many streams and PCM voices can be played simultaneously. Default = 16. }
  ASIONumChannels [integer!] { [r/w] Optional. Specify 0 to ignore. Number of channels available on the ASIO device. }
  ASIOChannelList [integer!] { [r/w] Optional. Specify 0 to ignore. Pointer to an array of strings (number of entries defined by ASIONumChannels) with ASIO channel names. }
  ASIOSpeakerList [integer!] { [r/w] Optional. Specify 0 to ignore. Pointer to a list of speakers that the ASIO channels map to.  This can be called after System::init to remap ASIO output. }
  max3DReverbDSPs [integer!] { [r/w] Optional. Specify 0 to ignore. The max number of 3d reverb DSP's in the system. (NOTE: CURRENTLY DISABLED / UNUSED) }
  HRTFMinAngle [float] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_INIT_SOFTWARE_HRTF.  The angle range (0-360) of a 3D sound in relation to the listener, at which the HRTF function begins to have an effect. 0 = in front of the listener. 180 = from 90 degrees to the left of the listener to 90 degrees to the right. 360 = behind the listener. Default = 180.0. }
  HRTFMaxAngle [float] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_INIT_SOFTWARE_HRTF.  The angle range (0-360) of a 3D sound in relation to the listener, at which the HRTF function has maximum effect. 0 = front of the listener. 180 = from 90 degrees to the left of the listener to 90 degrees to the right. 360 = behind the listener. Default = 360.0. }
  HRTFFreq [float] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_INIT_SOFTWARE_HRTF.  The cutoff frequency of the HRTF's lowpass filter function when at maximum effect. (i.e. at HRTFMaxAngle).  Default = 4000.0. }
  vol0virtualvol [float] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_INIT_VOL0_BECOMES_VIRTUAL.  If this flag is used, and the volume is 0.0, then the sound will become virtual.  Use this value to raise the threshold to a different point where a sound goes virtual. }
  eventqueuesize [integer!] { [r/w] Optional. Specify 0 to ignore. For use with FMOD Event system only.  Specifies the number of slots available for simultaneous non blocking loads, across all threads.  Default = 32. }
  defaultDecodeBufferSize [integer!] { [r/w] Optional. Specify 0 to ignore. For streams. This determines the default size of the double buffer (in milliseconds) that a stream uses.  Default = 400ms }
  debugLogFilename [string!] { [r/w] Optional. Specify 0 to ignore. Gives fmod's logging system a path/filename.  Normally the log is placed in the same directory as the executable and called fmod.log. When using System::getAdvancedSettings, provide at least 256 bytes of memory to copy into. }
  profileport [short] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_INIT_ENABLE_PROFILE.  Specify the port to listen on for connections by the profiler application. }
  geometryMaxFadeTime [integer!] { [r/w] Optional. Specify 0 to ignore. The maximum time in miliseconds it takes for a channel to fade to the new level when its occlusion changes. }
  maxSpectrumWaveDataBuffers [integer!] { [r/w] Optional. Specify 0 to ignore. Tells System::init to allocate a pool of wavedata/spectrum buffers to prevent memory fragmentation, any additional buffers will be allocated normally. }
  musicSystemCacheDelay [integer!] { [r/w] Optional. Specify 0 to ignore. The delay the music system should allow for loading a sample from disk (in milliseconds). Default = 400 ms. }
  distanceFilterCentreFreq [float] { [r/w] Optional. Specify 0 to ignore. For use with FMOD_INIT_DISTANCE_FILTERING.  The default centre frequency in Hz for the distance filtering effect. Default = 1500.0. }
] none ;


{
[ENUM]
[
    [DESCRIPTION]
    Special channel index values for FMOD functions.

    [REMARKS]
    To get 'all' of the channels, use System::getMasterChannelGroup.

    [PLATFORMS]
    Win32, Win64, Linux, Linux64, Macintosh, Xbox360, PlayStation Portable, PlayStation 3, Wii, iPhone, 3GS, NGP, Android

    [SEE_ALSO]
    System::playSound
    System::playDSP
    System::getChannel
    System::getMasterChannelGroup
]
}
FMOD_CHANNEL_FREE: -1 { For a channel index, FMOD chooses a free voice using the priority system. }
FMOD_CHANNEL_REUSE: -2 { For a channel index, re-use the channel handle that was passed in. }
 { For a channel index, re-use the channel handle that was passed in. }
FMOD_CHANNELINDEX: integer!;

{
#include "fmod_codec.h"
#include "fmod_dsp.h"
#include "fmod_memoryinfo.h"
}

{ ========================================================================================== }
{ FUNCTION PROTOTYPES                                                                        }
{ ========================================================================================== }


{
    FMOD global system functions (optional).
}

FMOD_Memory_Initialize: make routine! [ poolmem [struct! []] poollen [integer!] useralloc [FMOD_MEMORY_ALLOCCALLBACK] userrealloc [FMOD_MEMORY_REALLOCCALLBACK] userfree [FMOD_MEMORY_FREECALLBACK] memtypeflags [FMOD_MEMORY_TYPE] return: [FMOD_RESULT] ] fmod-lib "FMOD_Memory_Initialize" 
FMOD_Memory_GetStats: make routine! [ currentalloced [integer!] maxalloced [integer!] blocking [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Memory_GetStats" 
FMOD_Debug_SetLevel: make routine! [ level [FMOD_DEBUGLEVEL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Debug_SetLevel" 
FMOD_Debug_GetLevel: make routine! [ level [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Debug_GetLevel" 
FMOD_File_SetDiskBusy: make routine! [ busy [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_File_SetDiskBusy" 
FMOD_File_GetDiskBusy: make routine! [ busy [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_File_GetDiskBusy" 

{
    FMOD System factory functions.  Use this to create an FMOD System Instance.  below you will see FMOD_System_Init/Close to get started.
}

FMOD_System_Create: make routine! [ system [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Create" 
FMOD_System_Release: make routine! [ system [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Release" 


{
    'System' API
}

{
     Pre-init functions.
}

FMOD_System_SetOutput: make routine! [ system [integer!] output [FMOD_OUTPUTTYPE] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetOutput" 
FMOD_System_GetOutput: make routine! [ system [integer!] output [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetOutput" 
FMOD_System_GetNumDrivers: make routine! [ system [integer!] numdrivers [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetNumDrivers" 
FMOD_System_GetDriverInfo: make routine! [ system [integer!] id [integer!] name [string!] namelen [integer!] guid [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDriverInfo" 
FMOD_System_GetDriverInfoW: make routine! [ system [integer!] id [integer!] name [integer!] namelen [integer!] guid [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDriverInfoW" 
FMOD_System_GetDriverCaps: make routine! [ system [integer!] id [integer!] caps [integer!] controlpaneloutputrate [integer!] controlpanelspeakermode [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDriverCaps" 
FMOD_System_SetDriver: make routine! [ system [integer!] driver [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetDriver" 
FMOD_System_GetDriver: make routine! [ system [integer!] driver [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDriver" 
FMOD_System_SetHardwareChannels: make routine! [ system [integer!] numhardwarechannels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetHardwareChannels" 
FMOD_System_SetSoftwareChannels: make routine! [ system [integer!] numsoftwarechannels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetSoftwareChannels" 
FMOD_System_GetSoftwareChannels: make routine! [ system [integer!] numsoftwarechannels [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetSoftwareChannels" 
FMOD_System_SetSoftwareFormat: make routine! [ system [integer!] samplerate [integer!] format [FMOD_SOUND_FORMAT] numoutputchannels [integer!] maxinputchannels [integer!] resamplemethod [FMOD_DSP_RESAMPLER] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetSoftwareFormat" 
FMOD_System_GetSoftwareFormat: make routine! [ system [integer!] samplerate [integer!] format [struct! []] numoutputchannels [integer!] maxinputchannels [integer!] resamplemethod [integer!] bits [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetSoftwareFormat" 
FMOD_System_SetDSPBufferSize: make routine! [ system [integer!] bufferlength [integer!] numbuffers [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetDSPBufferSize" 
FMOD_System_GetDSPBufferSize: make routine! [ system [integer!] bufferlength [struct! []] numbuffers [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDSPBufferSize" 
FMOD_System_SetFileSystem: make routine! [ system [integer!] useropen [FMOD_FILE_OPENCALLBACK] userclose [FMOD_FILE_CLOSECALLBACK] userread [FMOD_FILE_READCALLBACK] userseek [FMOD_FILE_SEEKCALLBACK] userasyncread [FMOD_FILE_ASYNCREADCALLBACK] userasynccancel [FMOD_FILE_ASYNCCANCELCALLBACK] blockalign [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetFileSystem" 
FMOD_System_AttachFileSystem: make routine! [ system [integer!] useropen [FMOD_FILE_OPENCALLBACK] userclose [FMOD_FILE_CLOSECALLBACK] userread [FMOD_FILE_READCALLBACK] userseek [FMOD_FILE_SEEKCALLBACK] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_AttachFileSystem" 
FMOD_System_SetAdvancedSettings: make routine! [ system [integer!] settings [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetAdvancedSettings" 
FMOD_System_GetAdvancedSettings: make routine! [ system [integer!] settings [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetAdvancedSettings" 
FMOD_System_SetSpeakerMode: make routine! [ system [integer!] speakermode [FMOD_SPEAKERMODE] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetSpeakerMode" 
FMOD_System_GetSpeakerMode: make routine! [ system [integer!] speakermode [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetSpeakerMode" 
FMOD_System_SetCallback: make routine! [ system [integer!] callback [FMOD_SYSTEM_CALLBACK] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetCallback" 

{
     Plug-in support                       
}

FMOD_System_SetPluginPath: make routine! [ system [integer!] path [string!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetPluginPath" 
FMOD_System_LoadPlugin: make routine! [ system [integer!] filename [string!] handle [integer!] priority [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_LoadPlugin" 
FMOD_System_UnloadPlugin: make routine! [ system [integer!] handle [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_UnloadPlugin" 
FMOD_System_GetNumPlugins: make routine! [ system [integer!] plugintype [FMOD_PLUGINTYPE] numplugins [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetNumPlugins" 
FMOD_System_GetPluginHandle: make routine! [ system [integer!] plugintype [FMOD_PLUGINTYPE] index [integer!] handle [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetPluginHandle" 
FMOD_System_GetPluginInfo: make routine! [ system [integer!] handle [struct! []] plugintype [struct! []] name [string!] namelen [integer!] version [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetPluginInfo" 
FMOD_System_SetOutputByPlugin: make routine! [ system [integer!] handle [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetOutputByPlugin" 
FMOD_System_GetOutputByPlugin: make routine! [ system [integer!] handle [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetOutputByPlugin" 
FMOD_System_CreateDSPByPlugin: make routine! [ system [integer!] handle [integer!] dsp [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateDSPByPlugin" 
FMOD_System_CreateCodec: make routine! [ system [integer!] description [integer!] priority [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateCodec" 

{
     Init/Close                            
}

FMOD_System_Init: make routine! [ system [integer!] maxchannels [integer!] flags [FMOD_INITFLAGS] extradriverdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Init" 
FMOD_System_Close: make routine! [ system [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Close" 

{
     General post-init system functions    
}

FMOD_System_Update: make routine! [ system [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Update" 

FMOD_System_Set3DSettings: make routine! [ system [integer!] dopplerscale [float] distancefactor [float] rolloffscale [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Set3DSettings" 
FMOD_System_Get3DSettings: make routine! [ system [integer!] dopplerscale [struct! []] distancefactor [struct! []] rolloffscale [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Get3DSettings" 
FMOD_System_Set3DNumListeners: make routine! [ system [integer!] numlisteners [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Set3DNumListeners" 
FMOD_System_Get3DNumListeners: make routine! [ system [integer!] numlisteners [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Get3DNumListeners" 
FMOD_System_Set3DListenerAttributes: make routine! [ system [integer!] listener [integer!] pos [integer!] vel [integer!] forward [integer!] up [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Set3DListenerAttributes" 
FMOD_System_Get3DListenerAttributes: make routine! [ system [integer!] listener [struct! []] pos [struct! []] vel [struct! []] forward [struct! []] up [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Get3DListenerAttributes" 
FMOD_System_Set3DRolloffCallback: make routine! [ system [integer!] callback [FMOD_3D_ROLLOFFCALLBACK] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Set3DRolloffCallback" 
FMOD_System_Set3DSpeakerPosition: make routine! [ system [integer!] speaker [FMOD_SPEAKER] x [float] y [float] active [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Set3DSpeakerPosition" 
FMOD_System_Get3DSpeakerPosition: make routine! [ system [integer!] speaker [FMOD_SPEAKER] x [struct! []] y [struct! []] active [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_Get3DSpeakerPosition" 

FMOD_System_SetStreamBufferSize: make routine! [ system [integer!] filebuffersize [integer!] filebuffersizetype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetStreamBufferSize" 
FMOD_System_GetStreamBufferSize: make routine! [ system [integer!] filebuffersize [struct! []] filebuffersizetype [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetStreamBufferSize" 

{
     System information functions.        
}

FMOD_System_GetVersion: make routine! [ system [integer!] version [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetVersion" 
FMOD_System_GetOutputHandle: make routine! [ system [integer!] handle [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetOutputHandle" 
FMOD_System_GetChannelsPlaying: make routine! [ system [integer!] channels [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetChannelsPlaying" 
FMOD_System_GetHardwareChannels: make routine! [ system [integer!] numhardwarechannels [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetHardwareChannels" 
FMOD_System_GetCPUUsage: make routine! [ system [integer!] dsp [struct! []] stream [struct! []] geometry [struct! []] update [struct! []] total [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetCPUUsage" 
FMOD_System_GetSoundRAM: make routine! [ system [integer!] currentalloced [struct! []] maxalloced [struct! []] total [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetSoundRAM" 
FMOD_System_GetNumCDROMDrives: make routine! [ system [integer!] numdrives [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetNumCDROMDrives" 
FMOD_System_GetCDROMDriveName: make routine! [ system [integer!] drive [integer!] drivename [string!] drivenamelen [integer!] scsiname [string!] scsinamelen [integer!] devicename [string!] devicenamelen [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetCDROMDriveName" 
FMOD_System_GetSpectrum: make routine! [ system [integer!] spectrumarray [struct! []] numvalues [integer!] channeloffset [integer!] windowtype [FMOD_DSP_FFT_WINDOW] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetSpectrum" 
FMOD_System_GetWaveData: make routine! [ system [integer!] wavearray [struct! []] numvalues [integer!] channeloffset [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetWaveData" 

{
     Sound/DSP/Channel/FX creation and retrieval.       
}
FMOD_DSP_TYPE: integer!
FMOD_System_CreateSound: make routine! [ system [integer!] name_or_data [string!] mode [FMOD_MODE] exinfo [integer!] sound [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateSound" 
FMOD_System_CreateStream: make routine! [ system [integer!] name_or_data [string!] mode [FMOD_MODE] exinfo [integer!] sound [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateStream" 
FMOD_System_CreateDSP: make routine! [ system [integer!] description [struct! []] dsp [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateDSP" 
FMOD_System_CreateDSPByType: make routine! [ system [integer!] type [FMOD_DSP_TYPE] dsp [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateDSPByType" 
FMOD_System_CreateChannelGroup: make routine! [ system [integer!] name [string!] channelgroup [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateChannelGroup" 
FMOD_System_CreateSoundGroup: make routine! [ system [integer!] name [string!] soundgroup [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateSoundGroup" 
FMOD_System_CreateReverb: make routine! [ system [integer!] reverb [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateReverb" 

FMOD_System_PlaySound: make routine! [ system [integer!] channelid [FMOD_CHANNELINDEX] sound [integer!] paused [FMOD_BOOL] channel [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_PlaySound" 
FMOD_System_PlayDSP: make routine! [ system [integer!] channelid [FMOD_CHANNELINDEX] dsp [integer!] paused [FMOD_BOOL] channel [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_PlayDSP" 
FMOD_System_GetChannel: make routine! [ system [integer!] channelid [integer!] channel [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetChannel" 
FMOD_System_GetMasterChannelGroup: make routine! [ system [integer!] channelgroup [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetMasterChannelGroup" 
FMOD_System_GetMasterSoundGroup: make routine! [ system [integer!] soundgroup [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetMasterSoundGroup" 

{
     Reverb API                           
}

FMOD_System_SetReverbProperties: make routine! [ system [integer!] prop [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetReverbProperties" 
FMOD_System_GetReverbProperties: make routine! [ system [integer!] prop [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetReverbProperties" 
FMOD_System_SetReverbAmbientProperties: make routine! [ system [integer!] prop [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetReverbAmbientProperties" 
FMOD_System_GetReverbAmbientProperties: make routine! [ system [integer!] prop [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetReverbAmbientProperties" 

{
     System level DSP access.
}

FMOD_System_GetDSPHead: make routine! [ system [integer!] dsp [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDSPHead" 
FMOD_System_AddDSP: make routine! [ system [integer!] dsp [integer!] connection [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_AddDSP" 
FMOD_System_LockDSP: make routine! [ system [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_LockDSP" 
FMOD_System_UnlockDSP: make routine! [ system [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_UnlockDSP" 
FMOD_System_GetDSPClock: make routine! [ system [integer!] hi [struct! []] lo [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetDSPClock" 

{
     Recording API.
}

FMOD_System_GetRecordNumDrivers: make routine! [ system [integer!] numdrivers [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetRecordNumDrivers" 
FMOD_System_GetRecordDriverInfo: make routine! [ system [integer!] id [integer!] name [string!] namelen [integer!] guid [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetRecordDriverInfo" 
FMOD_System_GetRecordDriverInfoW: make routine! [ system [integer!] id [integer!] name [integer!] namelen [integer!] guid [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetRecordDriverInfoW" 
FMOD_System_GetRecordDriverCaps: make routine! [ system [integer!] id [integer!] caps [struct! []] minfrequency [struct! []] maxfrequency [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetRecordDriverCaps" 
FMOD_System_GetRecordPosition: make routine! [ system [integer!] id [integer!] position [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetRecordPosition" 

FMOD_System_RecordStart: make routine! [ system [integer!] id [integer!] sound [integer!] loop [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_RecordStart" 
FMOD_System_RecordStop: make routine! [ system [integer!] id [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_RecordStop" 
FMOD_System_IsRecording: make routine! [ system [integer!] id [integer!] recording [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_IsRecording" 

{
     Geometry API.
}

FMOD_System_CreateGeometry: make routine! [ system [integer!] maxpolygons [integer!] maxvertices [integer!] geometry [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_CreateGeometry" 
FMOD_System_SetGeometrySettings: make routine! [ system [integer!] maxworldsize [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetGeometrySettings" 
FMOD_System_GetGeometrySettings: make routine! [ system [integer!] maxworldsize [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetGeometrySettings" 
FMOD_System_LoadGeometry: make routine! [ system [integer!] data [integer!] datasize [integer!] geometry [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_LoadGeometry" 
FMOD_System_GetGeometryOcclusion: make routine! [ system [integer!] listener [struct! []] source [struct! []] direct [struct! []] reverb [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetGeometryOcclusion" 

{
     Network functions.
}

FMOD_System_SetNetworkProxy: make routine! [ system [integer!] proxy [string!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetNetworkProxy" 
FMOD_System_GetNetworkProxy: make routine! [ system [integer!] proxy [string!] proxylen [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetNetworkProxy" 
FMOD_System_SetNetworkTimeout: make routine! [ system [integer!] timeout [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetNetworkTimeout" 
FMOD_System_GetNetworkTimeout: make routine! [ system [integer!] timeout [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetNetworkTimeout" 

{
     Userdata set/get.
}

FMOD_System_SetUserData: make routine! [ system [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_SetUserData" 
FMOD_System_GetUserData: make routine! [ system [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetUserData" 

FMOD_System_GetMemoryInfo: make routine! [ system [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_System_GetMemoryInfo" 

 {
    'Sound' API
}

FMOD_Sound_Release: make routine! [ sound [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Release" 
FMOD_Sound_GetSystemObject: make routine! [ sound [integer!] system [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetSystemObject" 

 {
     Standard sound manipulation functions.                                                
}

FMOD_Sound_Lock: make routine! [ sound [integer!] offset [integer!] length [integer!] ptr1 [integer!] ptr2 [integer!] len1 [integer!] len2 [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Lock" 
FMOD_Sound_Unlock: make routine! [ sound [integer!] ptr1 [integer!] ptr2 [integer!] len1 [integer!] len2 [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Unlock" 
FMOD_Sound_SetDefaults: make routine! [ sound [integer!] frequency [float] volume [float] pan [float] priority [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetDefaults" 
FMOD_Sound_GetDefaults: make routine! [ sound [integer!] frequency [struct! []] volume [struct! []] pan [struct! []] priority [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetDefaults" 
FMOD_Sound_SetVariations: make routine! [ sound [integer!] frequencyvar [float] volumevar [float] panvar [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetVariations" 
FMOD_Sound_GetVariations: make routine! [ sound [integer!] frequencyvar [struct! []] volumevar [struct! []] panvar [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetVariations" 
FMOD_Sound_Set3DMinMaxDistance: make routine! [ sound [integer!] min [float] max [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Set3DMinMaxDistance" 
FMOD_Sound_Get3DMinMaxDistance: make routine! [ sound [integer!] min [struct! []] max [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Get3DMinMaxDistance" 
FMOD_Sound_Set3DConeSettings: make routine! [ sound [integer!] insideconeangle [float] outsideconeangle [float] outsidevolume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Set3DConeSettings" 
FMOD_Sound_Get3DConeSettings: make routine! [ sound [integer!] insideconeangle [struct! []] outsideconeangle [struct! []] outsidevolume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Get3DConeSettings" 
FMOD_Sound_Set3DCustomRolloff: make routine! [ sound [integer!] points [integer!] numpoints [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Set3DCustomRolloff" 
FMOD_Sound_Get3DCustomRolloff: make routine! [ sound [integer!] points [struct! []] numpoints [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_Get3DCustomRolloff" 
FMOD_Sound_SetSubSound: make routine! [ sound [integer!] index [integer!] subsound [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetSubSound" 
FMOD_Sound_GetSubSound: make routine! [ sound [integer!] index [struct! []] subsound [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetSubSound" 
FMOD_Sound_SetSubSoundSentence: make routine! [ sound [integer!] subsoundlist [integer!] numsubsounds [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetSubSoundSentence" 
FMOD_Sound_GetName: make routine! [ sound [integer!] name [string!] namelen [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetName" 
FMOD_Sound_GetLength: make routine! [ sound [integer!] length [struct! []] lengthtype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetLength" 
FMOD_Sound_GetFormat: make routine! [ sound [integer!] type [struct! []] format [struct! []] channels [struct! []] bits [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetFormat" 
FMOD_Sound_GetNumSubSounds: make routine! [ sound [integer!] numsubsounds [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetNumSubSounds" 
FMOD_Sound_GetNumTags: make routine! [ sound [integer!] numtags [struct! []] numtagsupdated [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetNumTags" 
FMOD_Sound_GetTag: make routine! [ sound [integer!] name [string!] index [struct! []] tag [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetTag" 
FMOD_Sound_GetOpenState: make routine! [ sound [integer!] openstate [struct! []] percentbuffered [struct! []] starving [struct! []] diskbusy [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetOpenState" 
FMOD_Sound_ReadData: make routine! [ sound [integer!] buffer [integer!] lenbytes [integer!] read [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_ReadData" 
FMOD_Sound_SeekData: make routine! [ sound [integer!] pcm [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SeekData" 

FMOD_Sound_SetSoundGroup: make routine! [ sound [integer!] soundgroup [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetSoundGroup" 
FMOD_Sound_GetSoundGroup: make routine! [ sound [integer!] soundgroup [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetSoundGroup" 

 {
     Synchronization point API.  These points can come from markers embedded in wav files, and can also generate channel callbacks.        
}

FMOD_Sound_GetNumSyncPoints: make routine! [ sound [integer!] numsyncpoints [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetNumSyncPoints" 
FMOD_Sound_GetSyncPoint: make routine! [ sound [integer!] index [integer!] point [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetSyncPoint" 
FMOD_Sound_GetSyncPointInfo: make routine! [ sound [integer!] point [struct! []] name [string!] namelen [integer!] offset [struct! []] offsettype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetSyncPointInfo" 
FMOD_Sound_AddSyncPoint: make routine! [ sound [integer!] offset [integer!] offsettype [FMOD_TIMEUNIT] name [string!] point [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_AddSyncPoint" 
FMOD_Sound_DeleteSyncPoint: make routine! [ sound [integer!] point [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_DeleteSyncPoint" 

 {
     Functions also in Channel class but here they are the 'default' to save having to change it in Channel all the time.
}

FMOD_Sound_SetMode: make routine! [ sound [integer!] mode [FMOD_MODE] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetMode" 
FMOD_Sound_GetMode: make routine! [ sound [integer!] mode [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetMode" 
FMOD_Sound_SetLoopCount: make routine! [ sound [integer!] loopcount [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetLoopCount" 
FMOD_Sound_GetLoopCount: make routine! [ sound [integer!] loopcount [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetLoopCount" 
FMOD_Sound_SetLoopPoints: make routine! [ sound [integer!] loopstart [integer!] loopstarttype [FMOD_TIMEUNIT] loopend [integer!] loopendtype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetLoopPoints" 
FMOD_Sound_GetLoopPoints: make routine! [ sound [integer!] loopstart [struct! []] loopstarttype [FMOD_TIMEUNIT] loopend [struct! []] loopendtype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetLoopPoints" 

 {
     For MOD/S3M/XM/IT/MID sequenced formats only.
}

FMOD_Sound_GetMusicNumChannels: make routine! [ sound [integer!] numchannels [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetMusicNumChannels" 
FMOD_Sound_SetMusicChannelVolume: make routine! [ sound [integer!] channel [integer!] volume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetMusicChannelVolume" 
FMOD_Sound_GetMusicChannelVolume: make routine! [ sound [integer!] channel [struct! []] volume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetMusicChannelVolume" 
FMOD_Sound_SetMusicSpeed: make routine! [ sound [integer!] speed [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetMusicSpeed" 
FMOD_Sound_GetMusicSpeed: make routine! [ sound [integer!] speed [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetMusicSpeed" 

 {
     Userdata set/get.
}

FMOD_Sound_SetUserData: make routine! [ sound [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_SetUserData" 
FMOD_Sound_GetUserData: make routine! [ sound [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetUserData" 

FMOD_Sound_GetMemoryInfo: make routine! [ sound [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Sound_GetMemoryInfo" 

 {
    'Channel' API
}

FMOD_Channel_GetSystemObject: make routine! [ channel [integer!] system [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetSystemObject" 

FMOD_Channel_Stop: make routine! [ channel [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Stop" 
FMOD_Channel_SetPaused: make routine! [ channel [integer!] paused [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetPaused" 
FMOD_Channel_GetPaused: make routine! [ channel [integer!] paused [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetPaused" 
FMOD_Channel_SetVolume: make routine! [ channel [integer!] volume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetVolume" 
FMOD_Channel_GetVolume: make routine! [ channel [integer!] volume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetVolume" 
FMOD_Channel_SetFrequency: make routine! [ channel [integer!] frequency [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetFrequency" 
FMOD_Channel_GetFrequency: make routine! [ channel [integer!] frequency [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetFrequency" 
FMOD_Channel_SetPan: make routine! [ channel [integer!] pan [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetPan" 
FMOD_Channel_GetPan: make routine! [ channel [integer!] pan [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetPan" 
FMOD_Channel_SetDelay: make routine! [ channel [integer!] delaytype [FMOD_DELAYTYPE] delayhi [integer!] delaylo [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetDelay" 
FMOD_Channel_GetDelay: make routine! [ channel [integer!] delaytype [FMOD_DELAYTYPE] delayhi [struct! []] delaylo [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetDelay" 
FMOD_Channel_SetSpeakerMix: make routine! [ channel [integer!] frontleft [float] frontright [float] center [float] lfe [float] backleft [float] backright [float] sideleft [float] sideright [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetSpeakerMix" 
FMOD_Channel_GetSpeakerMix: make routine! [ channel [integer!] frontleft [integer!] frontright [integer!] center [integer!] lfe [integer!] backleft [integer!] backright [integer!] sideleft [integer!] sideright [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetSpeakerMix" 
FMOD_Channel_SetSpeakerLevels: make routine! [ channel [integer!] speaker [FMOD_SPEAKER] levels [integer!] numlevels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetSpeakerLevels" 
FMOD_Channel_GetSpeakerLevels: make routine! [ channel [integer!] speaker [FMOD_SPEAKER] levels [struct! []] numlevels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetSpeakerLevels" 
FMOD_Channel_SetInputChannelMix: make routine! [ channel [integer!] levels [integer!] numlevels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetInputChannelMix" 
FMOD_Channel_GetInputChannelMix: make routine! [ channel [integer!] levels [struct! []] numlevels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetInputChannelMix" 
FMOD_Channel_SetMute: make routine! [ channel [integer!] mute [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetMute" 
FMOD_Channel_GetMute: make routine! [ channel [integer!] mute [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetMute" 
FMOD_Channel_SetPriority: make routine! [ channel [integer!] priority [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetPriority" 
FMOD_Channel_GetPriority: make routine! [ channel [integer!] priority [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetPriority" 
FMOD_Channel_SetPosition: make routine! [ channel [integer!] position [integer!] postype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetPosition" 
FMOD_Channel_GetPosition: make routine! [ channel [integer!] position [struct! []] postype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetPosition" 
FMOD_Channel_SetReverbProperties: make routine! [ channel [integer!] prop [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetReverbProperties" 
FMOD_Channel_GetReverbProperties: make routine! [ channel [integer!] prop [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetReverbProperties" 
FMOD_Channel_SetLowPassGain: make routine! [ channel [integer!] gain [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetLowPassGain" 
FMOD_Channel_GetLowPassGain: make routine! [ channel [integer!] gain [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetLowPassGain" 

FMOD_Channel_SetChannelGroup: make routine! [ channel [integer!] channelgroup [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetChannelGroup" 
FMOD_Channel_GetChannelGroup: make routine! [ channel [integer!] channelgroup [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetChannelGroup" 
FMOD_Channel_SetCallback: make routine! [ channel [integer!] callback [FMOD_CHANNEL_CALLBACK] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetCallback" 

 {
     3D functionality.
}

FMOD_Channel_Set3DAttributes: make routine! [ channel [integer!] pos [integer!] vel [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DAttributes" 
FMOD_Channel_Get3DAttributes: make routine! [ channel [integer!] pos [struct! []] vel [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DAttributes" 
FMOD_Channel_Set3DMinMaxDistance: make routine! [ channel [integer!] mindistance [float] maxdistance [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DMinMaxDistance" 
FMOD_Channel_Get3DMinMaxDistance: make routine! [ channel [integer!] mindistance [struct! []] maxdistance [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DMinMaxDistance" 
FMOD_Channel_Set3DConeSettings: make routine! [ channel [integer!] insideconeangle [float] outsideconeangle [float] outsidevolume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DConeSettings" 
FMOD_Channel_Get3DConeSettings: make routine! [ channel [integer!] insideconeangle [struct! []] outsideconeangle [struct! []] outsidevolume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DConeSettings" 
FMOD_Channel_Set3DConeOrientation: make routine! [ channel [integer!] orientation [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DConeOrientation" 
FMOD_Channel_Get3DConeOrientation: make routine! [ channel [integer!] orientation [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DConeOrientation" 
FMOD_Channel_Set3DCustomRolloff: make routine! [ channel [integer!] points [integer!] numpoints [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DCustomRolloff" 
FMOD_Channel_Get3DCustomRolloff: make routine! [ channel [integer!] points [struct! []] numpoints [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DCustomRolloff" 
FMOD_Channel_Set3DOcclusion: make routine! [ channel [integer!] directocclusion [float] reverbocclusion [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DOcclusion" 
FMOD_Channel_Get3DOcclusion: make routine! [ channel [integer!] directocclusion [struct! []] reverbocclusion [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DOcclusion" 
FMOD_Channel_Set3DSpread: make routine! [ channel [integer!] angle [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DSpread" 
FMOD_Channel_Get3DSpread: make routine! [ channel [integer!] angle [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DSpread" 
FMOD_Channel_Set3DPanLevel: make routine! [ channel [integer!] level [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DPanLevel" 
FMOD_Channel_Get3DPanLevel: make routine! [ channel [integer!] level [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DPanLevel" 
FMOD_Channel_Set3DDopplerLevel: make routine! [ channel [integer!] level [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DDopplerLevel" 
FMOD_Channel_Get3DDopplerLevel: make routine! [ channel [integer!] level [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DDopplerLevel" 
FMOD_Channel_Set3DDistanceFilter: make routine! [ channel [integer!] custom [FMOD_BOOL] customLevel [float] centerFreq [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Set3DDistanceFilter" 
FMOD_Channel_Get3DDistanceFilter: make routine! [ channel [integer!] custom [struct! []] customLevel [struct! []] centerFreq [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_Get3DDistanceFilter" 

 {
     DSP functionality only for channels playing sounds created with FMOD_SOFTWARE.
}

FMOD_Channel_GetDSPHead: make routine! [ channel [integer!] dsp [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetDSPHead" 
FMOD_Channel_AddDSP: make routine! [ channel [integer!] dsp [integer!] connection [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_AddDSP" 

 {
     Information only functions.
}

FMOD_Channel_IsPlaying: make routine! [ channel [integer!] isplaying [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_IsPlaying" 
FMOD_Channel_IsVirtual: make routine! [ channel [integer!] isvirtual [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_IsVirtual" 
FMOD_Channel_GetAudibility: make routine! [ channel [integer!] audibility [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetAudibility" 
FMOD_Channel_GetCurrentSound: make routine! [ channel [integer!] sound [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetCurrentSound" 
FMOD_Channel_GetSpectrum: make routine! [ channel [integer!] spectrumarray [struct! []] numvalues [integer!] channeloffset [integer!] windowtype [FMOD_DSP_FFT_WINDOW] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetSpectrum" 
FMOD_Channel_GetWaveData: make routine! [ channel [integer!] wavearray [struct! []] numvalues [integer!] channeloffset [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetWaveData" 
FMOD_Channel_GetIndex: make routine! [ channel [integer!] index [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetIndex" 

 {
     Functions also found in Sound class but here they can be set per channel.
}

FMOD_Channel_SetMode: make routine! [ channel [integer!] mode [FMOD_MODE] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetMode" 
FMOD_Channel_GetMode: make routine! [ channel [integer!] mode [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetMode" 
FMOD_Channel_SetLoopCount: make routine! [ channel [integer!] loopcount [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetLoopCount" 
FMOD_Channel_GetLoopCount: make routine! [ channel [integer!] loopcount [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetLoopCount" 
FMOD_Channel_SetLoopPoints: make routine! [ channel [integer!] loopstart [integer!] loopstarttype [FMOD_TIMEUNIT] loopend [integer!] loopendtype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetLoopPoints" 
FMOD_Channel_GetLoopPoints: make routine! [ channel [integer!] loopstart [struct! []] loopstarttype [FMOD_TIMEUNIT] loopend [integer!] loopendtype [FMOD_TIMEUNIT] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetLoopPoints" 

 {
     Userdata set/get.                                                
}

FMOD_Channel_SetUserData: make routine! [ channel [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_SetUserData" 
FMOD_Channel_GetUserData: make routine! [ channel [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetUserData" 

FMOD_Channel_GetMemoryInfo: make routine! [ channel [integer!] memorybits [integer!] event_memorybits [integer!] memoryused [integer!] memoryused_details [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Channel_GetMemoryInfo" 

 {
    'ChannelGroup' API
}

FMOD_ChannelGroup_Release: make routine! [ channelgroup [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_Release" 
FMOD_ChannelGroup_GetSystemObject: make routine! [ channelgroup [integer!] system [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetSystemObject" 

 {
     Channelgroup scale values.  (changes attributes relative to the channels, doesn't overwrite them)
}

FMOD_ChannelGroup_SetVolume: make routine! [ channelgroup [integer!] volume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_SetVolume" 
FMOD_ChannelGroup_GetVolume: make routine! [ channelgroup [integer!] volume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetVolume" 
FMOD_ChannelGroup_SetPitch: make routine! [ channelgroup [integer!] pitch [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_SetPitch" 
FMOD_ChannelGroup_GetPitch: make routine! [ channelgroup [integer!] pitch [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetPitch" 
FMOD_ChannelGroup_Set3DOcclusion: make routine! [ channelgroup [integer!] directocclusion [float] reverbocclusion [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_Set3DOcclusion" 
FMOD_ChannelGroup_Get3DOcclusion: make routine! [ channelgroup [integer!] directocclusion [struct! []] reverbocclusion [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_Get3DOcclusion" 
FMOD_ChannelGroup_SetPaused: make routine! [ channelgroup [integer!] paused [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_SetPaused" 
FMOD_ChannelGroup_GetPaused: make routine! [ channelgroup [integer!] paused [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetPaused" 
FMOD_ChannelGroup_SetMute: make routine! [ channelgroup [integer!] mute [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_SetMute" 
FMOD_ChannelGroup_GetMute: make routine! [ channelgroup [integer!] mute [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetMute" 

 {
     Channelgroup override values.  (recursively overwrites whatever settings the channels had)
}

FMOD_ChannelGroup_Stop: make routine! [ channelgroup [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_Stop" 
FMOD_ChannelGroup_OverrideVolume: make routine! [ channelgroup [integer!] volume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_OverrideVolume" 
FMOD_ChannelGroup_OverrideFrequency: make routine! [ channelgroup [integer!] frequency [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_OverrideFrequency" 
FMOD_ChannelGroup_OverridePan: make routine! [ channelgroup [integer!] pan [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_OverridePan" 
FMOD_ChannelGroup_OverrideReverbProperties: make routine! [ channelgroup [integer!] prop [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_OverrideReverbProperties" 
FMOD_ChannelGroup_Override3DAttributes: make routine! [ channelgroup [integer!] pos [integer!] vel [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_Override3DAttributes" 
FMOD_ChannelGroup_OverrideSpeakerMix: make routine! [ channelgroup [integer!] frontleft [float] frontright [float] center [float] lfe [float] backleft [float] backright [float] sideleft [float] sideright [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_OverrideSpeakerMix" 

 {
     Nested channel groups.
}

FMOD_ChannelGroup_AddGroup: make routine! [ channelgroup [integer!] group [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_AddGroup" 
FMOD_ChannelGroup_GetNumGroups: make routine! [ channelgroup [integer!] numgroups [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetNumGroups" 
FMOD_ChannelGroup_GetGroup: make routine! [ channelgroup [integer!] index [integer!] group [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetGroup" 
FMOD_ChannelGroup_GetParentGroup: make routine! [ channelgroup [integer!] group [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetParentGroup" 

 {
     DSP functionality only for channel groups playing sounds created with FMOD_SOFTWARE.
}

FMOD_ChannelGroup_GetDSPHead: make routine! [ channelgroup [integer!] dsp [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetDSPHead" 
FMOD_ChannelGroup_AddDSP: make routine! [ channelgroup [integer!] dsp [integer!] connection [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_AddDSP" 

 {
     Information only functions.
}

FMOD_ChannelGroup_GetName: make routine! [ channelgroup [integer!] name [string!] namelen [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetName" 
FMOD_ChannelGroup_GetNumChannels: make routine! [ channelgroup [integer!] numchannels [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetNumChannels" 
FMOD_ChannelGroup_GetChannel: make routine! [ channelgroup [integer!] index [integer!] channel [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetChannel" 
FMOD_ChannelGroup_GetSpectrum: make routine! [ channelgroup [integer!] spectrumarray [struct! []] numvalues [integer!] channeloffset [integer!] windowtype [FMOD_DSP_FFT_WINDOW] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetSpectrum" 
FMOD_ChannelGroup_GetWaveData: make routine! [ channelgroup [integer!] wavearray [struct! []] numvalues [integer!] channeloffset [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetWaveData" 

 {
     Userdata set/get.
}

FMOD_ChannelGroup_SetUserData: make routine! [ channelgroup [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_SetUserData" 
FMOD_ChannelGroup_GetUserData: make routine! [ channelgroup [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetUserData" 

FMOD_ChannelGroup_GetMemoryInfo: make routine! [ channelgroup [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_ChannelGroup_GetMemoryInfo" 

 {
    'SoundGroup' API
}

FMOD_SoundGroup_Release: make routine! [ soundgroup [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_Release" 
FMOD_SoundGroup_GetSystemObject: make routine! [ soundgroup [integer!] system [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetSystemObject" 

 {
     SoundGroup control functions.
}

FMOD_SoundGroup_SetMaxAudible: make routine! [ soundgroup [integer!] maxaudible [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_SetMaxAudible" 
FMOD_SoundGroup_GetMaxAudible: make routine! [ soundgroup [integer!] maxaudible [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetMaxAudible" 
FMOD_SoundGroup_SetMaxAudibleBehavior: make routine! [ soundgroup [integer!] behavior [FMOD_SOUNDGROUP_BEHAVIOR] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_SetMaxAudibleBehavior" 
FMOD_SoundGroup_GetMaxAudibleBehavior: make routine! [ soundgroup [integer!] behavior [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetMaxAudibleBehavior" 
FMOD_SoundGroup_SetMuteFadeSpeed: make routine! [ soundgroup [integer!] speed [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_SetMuteFadeSpeed" 
FMOD_SoundGroup_GetMuteFadeSpeed: make routine! [ soundgroup [integer!] speed [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetMuteFadeSpeed" 
FMOD_SoundGroup_SetVolume: make routine! [ soundgroup [integer!] volume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_SetVolume" 
FMOD_SoundGroup_GetVolume: make routine! [ soundgroup [integer!] volume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetVolume" 
FMOD_SoundGroup_Stop: make routine! [ soundgroup [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_Stop" 

 {
     Information only functions.
}

FMOD_SoundGroup_GetName: make routine! [ soundgroup [integer!] name [string!] namelen [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetName" 
FMOD_SoundGroup_GetNumSounds: make routine! [ soundgroup [integer!] numsounds [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetNumSounds" 
FMOD_SoundGroup_GetSound: make routine! [ soundgroup [integer!] index [integer!] sound [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetSound" 
FMOD_SoundGroup_GetNumPlaying: make routine! [ soundgroup [integer!] numplaying [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetNumPlaying" 

 {
     Userdata set/get.
}

FMOD_SoundGroup_SetUserData: make routine! [ soundgroup [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_SetUserData" 
FMOD_SoundGroup_GetUserData: make routine! [ soundgroup [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetUserData" 

FMOD_SoundGroup_GetMemoryInfo: make routine! [ soundgroup [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_SoundGroup_GetMemoryInfo" 

 {
    'DSP' API
}

FMOD_DSP_Release: make routine! [ dsp [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_Release" 
FMOD_DSP_GetSystemObject: make routine! [ dsp [integer!] system [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetSystemObject" 

 {
     Connection / disconnection / input and output enumeration.
}

FMOD_DSP_AddInput: make routine! [ dsp [integer!] target [integer!] connection [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_AddInput" 
FMOD_DSP_DisconnectFrom: make routine! [ dsp [integer!] target [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_DisconnectFrom" 
FMOD_DSP_DisconnectAll: make routine! [ dsp [integer!] inputs [FMOD_BOOL] outputs [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_DisconnectAll" 
FMOD_DSP_Remove: make routine! [ dsp [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_Remove" 
FMOD_DSP_GetNumInputs: make routine! [ dsp [integer!] numinputs [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetNumInputs" 
FMOD_DSP_GetNumOutputs: make routine! [ dsp [integer!] numoutputs [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetNumOutputs" 
FMOD_DSP_GetInput: make routine! [ dsp [integer!] index [integer!] input [struct! []] inputconnection [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetInput" 
FMOD_DSP_GetOutput: make routine! [ dsp [integer!] index [integer!] output [struct! []] outputconnection [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetOutput" 

 {
     DSP unit control.
}

FMOD_DSP_SetActive: make routine! [ dsp [integer!] active [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_SetActive" 
FMOD_DSP_GetActive: make routine! [ dsp [integer!] active [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetActive" 
FMOD_DSP_SetBypass: make routine! [ dsp [integer!] bypass [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_SetBypass" 
FMOD_DSP_GetBypass: make routine! [ dsp [integer!] bypass [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetBypass" 
FMOD_DSP_SetSpeakerActive: make routine! [ dsp [integer!] speaker [FMOD_SPEAKER] active [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_SetSpeakerActive" 
FMOD_DSP_GetSpeakerActive: make routine! [ dsp [integer!] speaker [FMOD_SPEAKER] active [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetSpeakerActive" 
FMOD_DSP_Reset: make routine! [ dsp [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_Reset" 

 {
     DSP parameter control.
}

FMOD_DSP_SetParameter: make routine! [ dsp [integer!] index [integer!] value [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_SetParameter" 
FMOD_DSP_GetParameter: make routine! [ dsp [integer!] index [integer!] value [struct! []] valuestr [string!] valuestrlen [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetParameter" 
FMOD_DSP_GetNumParameters: make routine! [ dsp [integer!] numparams [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetNumParameters" 
FMOD_DSP_GetParameterInfo: make routine! [ dsp [integer!] index [integer!] name [string!] label [string!] description [string!] descriptionlen [integer!] min [struct! []] max [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetParameterInfo" 
FMOD_DSP_ShowConfigDialog: make routine! [ dsp [integer!] hwnd [integer!] show [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_ShowConfigDialog" 

 {
     DSP attributes.        
}

FMOD_DSP_GetInfo: make routine! [ dsp [integer!] name [string!] version [struct! []] channels [struct! []] configwidth [struct! []] configheight [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetInfo" 
FMOD_DSP_GetType: make routine! [ dsp [integer!] type [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetType" 
FMOD_DSP_SetDefaults: make routine! [ dsp [integer!] frequency [float] volume [float] pan [float] priority [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_SetDefaults" 
FMOD_DSP_GetDefaults: make routine! [ dsp [integer!] frequency [struct! []] volume [struct! []] pan [struct! []] priority [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetDefaults" 

 {
     Userdata set/get.
}

FMOD_DSP_SetUserData: make routine! [ dsp [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_SetUserData" 
FMOD_DSP_GetUserData: make routine! [ dsp [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetUserData" 

FMOD_DSP_GetMemoryInfo: make routine! [ dsp [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSP_GetMemoryInfo" 

 {
    'DSPConnection' API
}

FMOD_DSPConnection_GetInput: make routine! [ dspconnection [integer!] input [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_GetInput" 
FMOD_DSPConnection_GetOutput: make routine! [ dspconnection [integer!] output [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_GetOutput" 
FMOD_DSPConnection_SetMix: make routine! [ dspconnection [integer!] volume [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_SetMix" 
FMOD_DSPConnection_GetMix: make routine! [ dspconnection [integer!] volume [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_GetMix" 
FMOD_DSPConnection_SetLevels: make routine! [ dspconnection [integer!] speaker [FMOD_SPEAKER] levels [integer!] numlevels [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_SetLevels" 
FMOD_DSPConnection_GetLevels: make routine! [ dspconnection [integer!] speaker [FMOD_SPEAKER] levels [struct! []] numlevels [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_GetLevels" 

 {
     Userdata set/get.
}

FMOD_DSPConnection_SetUserData: make routine! [ dspconnection [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_SetUserData" 
FMOD_DSPConnection_GetUserData: make routine! [ dspconnection [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_GetUserData" 

FMOD_DSPConnection_GetMemoryInfo: make routine! [ dspconnection [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_DSPConnection_GetMemoryInfo" 

 {
    'Geometry' API
}

FMOD_Geometry_Release: make routine! [ geometry [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_Release" 

 {
     Polygon manipulation.
}

FMOD_Geometry_AddPolygon: make routine! [ geometry [integer!] directocclusion [float] reverbocclusion [float] doublesided [FMOD_BOOL] numvertices [integer!] vertices [integer!] polygonindex [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_AddPolygon" 
FMOD_Geometry_GetNumPolygons: make routine! [ geometry [integer!] numpolygons [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetNumPolygons" 
FMOD_Geometry_GetMaxPolygons: make routine! [ geometry [integer!] maxpolygons [struct! []] maxvertices [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetMaxPolygons" 
FMOD_Geometry_GetPolygonNumVertices: make routine! [ geometry [integer!] index [integer!] numvertices [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetPolygonNumVertices" 
FMOD_Geometry_SetPolygonVertex: make routine! [ geometry [integer!] index [integer!] vertexindex [integer!] vertex [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetPolygonVertex" 
FMOD_Geometry_GetPolygonVertex: make routine! [ geometry [integer!] index [integer!] vertexindex [integer!] vertex [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetPolygonVertex" 
FMOD_Geometry_SetPolygonAttributes: make routine! [ geometry [integer!] index [integer!] directocclusion [float] reverbocclusion [float] doublesided [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetPolygonAttributes" 
FMOD_Geometry_GetPolygonAttributes: make routine! [ geometry [integer!] index [integer!] directocclusion [struct! []] reverbocclusion [struct! []] doublesided [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetPolygonAttributes" 

 {
     Object manipulation.
}

FMOD_Geometry_SetActive: make routine! [ geometry [integer!] active [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetActive" 
FMOD_Geometry_GetActive: make routine! [ geometry [integer!] active [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetActive" 
FMOD_Geometry_SetRotation: make routine! [ geometry [integer!] forward [integer!] up [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetRotation" 
FMOD_Geometry_GetRotation: make routine! [ geometry [integer!] forward [struct! []] up [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetRotation" 
FMOD_Geometry_SetPosition: make routine! [ geometry [integer!] position [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetPosition" 
FMOD_Geometry_GetPosition: make routine! [ geometry [integer!] position [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetPosition" 
FMOD_Geometry_SetScale: make routine! [ geometry [integer!] scale [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetScale" 
FMOD_Geometry_GetScale: make routine! [ geometry [integer!] scale [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetScale" 
FMOD_Geometry_Save: make routine! [ geometry [integer!] data [integer!] datasize [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_Save" 

 {
     Userdata set/get.
}

FMOD_Geometry_SetUserData: make routine! [ geometry [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_SetUserData" 
FMOD_Geometry_GetUserData: make routine! [ geometry [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetUserData" 

FMOD_Geometry_GetMemoryInfo: make routine! [ geometry [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Geometry_GetMemoryInfo" 

 {
    'Reverb' API
}

FMOD_Reverb_Release: make routine! [ reverb [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_Release" 

 {
     Reverb manipulation.
}

FMOD_Reverb_Set3DAttributes: make routine! [ reverb [integer!] position [integer!] mindistance [float] maxdistance [float] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_Set3DAttributes" 
FMOD_Reverb_Get3DAttributes: make routine! [ reverb [integer!] position [struct! []] mindistance [struct! []] maxdistance [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_Get3DAttributes" 
FMOD_Reverb_SetProperties: make routine! [ reverb [integer!] properties [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_SetProperties" 
FMOD_Reverb_GetProperties: make routine! [ reverb [integer!] properties [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_GetProperties" 
FMOD_Reverb_SetActive: make routine! [ reverb [integer!] active [FMOD_BOOL] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_SetActive" 
FMOD_Reverb_GetActive: make routine! [ reverb [integer!] active [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_GetActive" 

 {
     Userdata set/get.
}

FMOD_Reverb_SetUserData: make routine! [ reverb [integer!] userdata [integer!] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_SetUserData" 
FMOD_Reverb_GetUserData: make routine! [ reverb [integer!] userdata [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_GetUserData" 

FMOD_Reverb_GetMemoryInfo: make routine! [ reverb [integer!] memorybits [struct! []] event_memorybits [struct! []] memoryused [struct! []] memoryused_details [struct! []] return: [FMOD_RESULT] ] fmod-lib "FMOD_Reverb_GetMemoryInfo" 

;comment[ ;uncumment this and comment next line to comment example code
context [

	{===============================================================================================
	 PlaySound Example
	 Copyright (c), Firelight Technologies Pty, Ltd 2004-2011.

	 This example shows how to simply load and play multiple sounds.  This is about the simplest
	 use of FMOD.
	 This makes FMOD decode the into memory when it loads.  If the sounds are big and possibly take
	 up a lot of ram, then it would be better to use the FMOD_CREATESTREAM flag so that it is 
	 streamed in realtime as it plays.
	===============================================================================================}

	ERRCHECK: func [result [FMOD_RESULT]] [
	    if (result <> FMOD_OK) [
	        print ["FMOD error!" result FMOD_ErrorString result]
			;free fmod-lib
			halt
	        quit/return -1
	    ]
	]

	; main
	
	fsystem: int-ptr	;REBOL-NOTE: use a struct! that will be overwritten by an address (used as an integer!)
	sound1: int-ptr
	sound2: int-ptr
	sound3: int-ptr
	channel: 0			;REBOL-NOTE: this will be set to an address (as an integer!)
	&channel: int-ptr	;REBOL-NOTE: this is the struct! used to get the above address
	result: none
	key: none
	version: int-ptr

	{
		Create a System object and initialize.
	}
	result: FMOD_System_Create fsystem
	ERRCHECK result
	fsystem: fsystem/value  ;REBOL-NOTE: overwrite struct! with integer! address (since from now on we will use only the address)

	result: FMOD_System_GetVersion fsystem version
	ERRCHECK result
	version: version/value

	if (version < FMOD_VERSION)
	[
		print ["Error!  You are using an old version of FMOD:" to-hex version ". This program requires:" to-hex FMOD_VERSION]
		free fmod-lib
		halt
		quit/return 0;
	]

	result: FMOD_System_Init fsystem 32 FMOD_INIT_NORMAL 0
	ERRCHECK result

    result: FMOD_System_CreateSound fsystem "drumloop.wav" FMOD_HARDWARE 0 sound1
    ERRCHECK result
	sound1: sound1/value

    result: FMOD_Sound_SetMode sound1 FMOD_LOOP_OFF { drumloop.wav has embedded loop points which automatically makes looping turn on }
    ERRCHECK result

    result: FMOD_System_CreateSound fsystem "jaguar.wav" FMOD_SOFTWARE 0 sound2
    ERRCHECK result
	sound2: sound2/value

    result: FMOD_System_CreateSound fsystem "swish.wav" FMOD_HARDWARE 0 sound3
    ERRCHECK result
	sound3: sound3/value

    print ["==================================================================="]
    print ["PlaySound Example.  Copyright (c) Firelight Technologies 2004-2011."]
    print ["==================================================================="]
    print [""]
    print ["Press '1' to play a mono sound using hardware mixing"]
    print ["Press '2' to play a mono sound using software mixing"]
    print ["Press '3' to play a stereo sound using hardware mixing"]
    print ["Press 'Esc' to quit"]
    print [""]
	
	keys: open/binary/no-wait [scheme: 'console] ; REBOL-NOTE: use a non-blocking input console
    {
        Main loop.
    }

    until
    [
		key: to-string to-char to-integer copy keys

		switch (key)
		[
			"1"
			[
				result: FMOD_System_PlaySound fsystem FMOD_CHANNEL_FREE sound1 0 &channel
				ERRCHECK result
			]
			"2"
			[
				result: FMOD_System_PlaySound fsystem FMOD_CHANNEL_FREE sound2 0 &channel
				ERRCHECK result
			]
			"3"
			[
				result: FMOD_System_PlaySound fsystem FMOD_CHANNEL_FREE sound3 0 &channel
				ERRCHECK result
			]
		]
		channel: &channel/value ;REBOL-NOTE: get the address

        FMOD_System_Update fsystem

        do
        [
            ms: 0
            &ms: int-ptr
            lenms: 0
            &lenms: int-ptr
            playing: 0
            &playing: int-ptr
            paused: 0
            &paused: int-ptr
            channelsplaying: 0
            &channelsplaying: int-ptr

            if (channel <> 0)
            [
                currentsound: 0
                &currentsound: int-ptr

                result: FMOD_Channel_IsPlaying channel &playing
                if ((result <> FMOD_OK) and (result <> FMOD_ERR_INVALID_HANDLE) and (result <> FMOD_ERR_CHANNEL_STOLEN))
                [
                    ERRCHECK result
                ]
                playing: to-logic &playing/value ;REBOL-NOTE: convert to logic! to use it in bool expressions

                result: FMOD_Channel_GetPaused channel &paused
                if ((result <> FMOD_OK) and (result <> FMOD_ERR_INVALID_HANDLE) and (result <> FMOD_ERR_CHANNEL_STOLEN))
                [
                    ERRCHECK result
                ]
                paused: to-logic &paused/value

                result: FMOD_Channel_GetPosition channel &ms FMOD_TIMEUNIT_MS
                if ((result <> FMOD_OK) and (result <> FMOD_ERR_INVALID_HANDLE) and (result <> FMOD_ERR_CHANNEL_STOLEN))
                [
                    ERRCHECK result
                ]
				ms: &ms/value

                FMOD_Channel_GetCurrentSound channel &currentsound
				currentsound: &currentsound/value
                if (currentsound <> 0)
                [
                    result: FMOD_Sound_GetLength currentsound &lenms FMOD_TIMEUNIT_MS
                    if ((result <> FMOD_OK) and (result <> FMOD_ERR_INVALID_HANDLE) and (result <> FMOD_ERR_CHANNEL_STOLEN))
                    [
                        ERRCHECK result
                    ]
					lenms: &lenms/value
                ]
            ]

            FMOD_System_GetChannelsPlaying fsystem &channelsplaying
			channelsplaying: &channelsplaying/value

			|02d: func [num [number!]] [reverse head change copy "00" reverse form to-integer num] ;REBOL-NOTE: same as %02d C formatting code
            print rejoin ["Time " |02d ms / 1000 / 60 "m:" |02d ms / 1000 // 60 "s:" |02d ms / 10 // 100 "/" |02d lenms / 1000 / 60 "m:" |02d lenms / 1000 // 60 "s:" |02d lenms / 10 // 100 " : " either paused ["Paused "] [either playing ["Playing"] ["Stopped"]] " : Channels Playing " channelsplaying "       "]
			prin "^(1B)[1A" ;REBOL-NOTE: go back up 1 line
        ]

		wait/all [keys 0.1]
		
		(key = (escape))

    ] 

    print [""]

    {
        Shut down
    }
    result: FMOD_Sound_Release sound1
    ERRCHECK result
    result: FMOD_Sound_Release sound2
    ERRCHECK result
    result: FMOD_Sound_Release sound3
    ERRCHECK result
    result: FMOD_System_Close fsystem
    ERRCHECK result
    result: FMOD_System_Release fsystem
    ERRCHECK result

	free fmod-lib
]


