REBOL [
	title: "SDL library interface"
	file: %sdl-h.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 10-08-2012
	version: 0.8.1
	needs: {
		- SDL shared library version 1.12 or newer in the same directory (or adjust first lines)
		- a CD in the CD tray to run the example
	}
	comment: {ONLY A FEW FUNCTIONs TESTED !!!! Use example code to test others.
		See REBOL-NOTEs in example code at the start and end for rebol-specific implementation issues.
		Some of the SDL functions and structures need callback functions pointers that sadly Rebol can't handle.
	}
	Purpose: "Code to bind SDL shared library to Rebol."
	History: [
		0.0.1 [06-11-2011 "First version"]
		0.8.0 [12-11-2011 "Example completed"]
		0.8.1 [10-08-2012 "Minor changes and fixes"]
	]
	Category: [library music sound graphics]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'module
		domain: [sound graphics external-library]
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
	
	;;;
	;;;REBOL-NOTE: use this function to map data to a struct!
	;;;
	addr-to-struct: func [
		"returns the given struct! initialized with content of given address"
		addr [integer!] struct [struct!] /local int-ptr tstruct
		][
		int-ptr: make struct! [value [integer!]] reduce [addr]
		tstruct: make struct! compose/deep/only [ptr [struct! (first struct)]] none
		change third tstruct third int-ptr
		change third struct third tstruct/ptr
		struct
	]

	lib: switch/default System/version/4 [
		2 [%libSDL-1.2.dylib]	;OSX
		3 [%SDL.dll]	;Windows
	] [%libSDL-1.2.so.0]

	if not SDL-lib: load/library lib [alert "SDL library not found. Quit" quit]

{
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997-2009 Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Sam Lantinga
    slouken@libsdl.org
}

{*
 *  @file SDL_endian.h
 *  Functions for reading and writing endian-specific values
 }
{* @name SDL_ENDIANs
 *  The two types of endianness 
 }
SDL_LIL_ENDIAN:	1234
SDL_BIG_ENDIAN:	4321

SDL_BYTEORDER: does [either 'little = get-modes system:// 'endian [SDL_LIL_ENDIAN][SDL_BIG_ENDIAN]]

{* @name SDL_INIT Flags
 *  These are the flags which may be passed to SDL_Init() -- you should
 *  specify the subsystems which you will be using in your application.
 }
SDL_INIT_TIMER:		1
SDL_INIT_AUDIO:		16
SDL_INIT_VIDEO:		32
SDL_INIT_CDROM:		256
SDL_INIT_JOYSTICK:	512
SDL_INIT_NOPARACHUTE:	1048576	{*< Don't catch fatal signals }
SDL_INIT_EVENTTHREAD:	16777216	{*< Not supported on all OS's }
SDL_INIT_EVERYTHING:	65535

{* This function loads the SDL dynamically linked library and initializes 
 *  the subsystems specified by 'flags' (and those satisfying dependencies)
 *  Unless the SDL_INIT_NOPARACHUTE flag is set, it will install cleanup
 *  signal handlers for some commonly ignored fatal signals (like SIGSEGV)
 }
SDL_Init: make routine! [ flags [integer!] return: [integer!] ] SDL-lib "SDL_Init" 

 {* This function initializes specific SDL subsystems }
SDL_InitSubSystem: make routine! [ flags [integer!] return: [integer!] ] SDL-lib "SDL_InitSubSystem" 

 {* This function cleans up specific SDL subsystems }
SDL_QuitSubSystem: make routine! [ flags [integer!] return: [integer!] ] SDL-lib "SDL_QuitSubSystem" 

 {* This function returns mask of the specified subsystems which have
 *  been initialized.
 *  If 'flags' is 0, it returns a mask of all initialized subsystems.
 }
SDL_WasInit: make routine! [ flags [integer!] return: [integer!] ] SDL-lib "SDL_WasInit" 

 {* This function cleans up all initialized subsystems and unloads the
 *  dynamically linked library.  You should call it upon all exit conditions.
 }
SDL_Quit: make routine! [return: [integer!] ] SDL-lib "SDL_Quit" 

{*
 *  @file SDL_active.h
 *  Include file for SDL application focus event handling 
 }

{* @name The available application states }

SDL_APPMOUSEFOCUS:	1		{*< The app has mouse coverage }
SDL_APPINPUTFOCUS:	2		{*< The app has input focus }
SDL_APPACTIVE:		4		{*< The application is active }


{* 
 * This function returns the current state of the application, which is a
 * bitwise combination of SDL_APPMOUSEFOCUS, SDL_APPINPUTFOCUS, and
 * SDL_APPACTIVE.  If SDL_APPACTIVE is set, then the user is able to
 * see your application, otherwise it has been iconified or disabled.
 }
SDL_GetAppState: make routine! [ a [integer!] return: [char!] ] SDL-lib "SDL_GetAppState" 

{*
 *  @file SDL_audio.h
 *  Access to the raw audio mixing buffer for the SDL library
 }

{*
 * When filling in the desired audio spec structure,
 * - 'desired->freq' should be the desired audio frequency in samples-per-second.
 * - 'desired->format' should be the desired audio format.
 * - 'desired->samples' is the desired size of the audio buffer, in samples.
 *     This number should be a power of two, and may be adjusted by the audio
 *     driver to a value more suitable for the hardware.  Good values seem to
 *     range between 512 and 8096 inclusive, depending on the application and
 *     CPU speed.  Smaller values yield faster response time, but can lead
 *     to underflow if the application is doing heavy processing and cannot
 *     fill the audio buffer in time.  A stereo sample consists of both right
 *     and left channels in LR ordering.
 *     Note that the number of samples is directly related to time by the
 *     following formula:  ms = (samples*1000)/freq
 * - 'desired->size' is the size in bytes of the audio buffer, and is
 *     calculated by SDL_OpenAudio().
 * - 'desired->silence' is the value used to set the buffer to silence,
 *     and is calculated by SDL_OpenAudio().
 * - 'desired->callback' should be set to a function that will be called
 *     when the audio device is ready for more data.  It is passed a pointer
 *     to the audio buffer, and the length in bytes of the audio buffer.
 *     This function usually runs in a separate thread, and so you should
 *     protect data structures that it accesses by calling SDL_LockAudio()
 *     and SDL_UnlockAudio() in your code.
 * - 'desired->userdata' is passed as the first parameter to your callback
 *     function.
 *
 * @note The calculated values in this structure are calculated by SDL_OpenAudio()
 *
 }
SDL_AudioSpec: make struct! [
  freq [integer!] {*< DSP frequency -- samples per second }
  format [short] {*< Audio data format }
  channels [char!] {*< Number of channels: 1 mono, 2 stereo }
  silence [char!] {*< Audio buffer silence value (calculated) }
  samples [short] {*< Audio buffer size in samples (power of 2) }
  padding [short] {*< Necessary for some compile environments }
  size [integer!] {*< Audio buffer size in bytes (calculated) }
 {*
	 *  This function is called when the audio device needs more data.
	 *
	 *  @param[out] stream	A pointer to the audio data buffer
	 *  @param[in]  len	The length of the audio buffer in bytes.
	 *
	 *  Once the callback returns, the buffer will no longer be valid.
	 *  Stereo samples are stored in a LRLRLR ordering.
	 }
  callback [integer!]
  userdata [integer!]
] none ;

{*
 *  @name Audio format flags
 *  defaults to LSB byte order
 }

AUDIO_U8:	8	{*< Unsigned 8-bit samples }
AUDIO_S8:	32776	{*< Signed 8-bit samples }
AUDIO_U16LSB:	16	{*< Unsigned 16-bit samples }
AUDIO_S16LSB:	32784	{*< Signed 16-bit samples }
AUDIO_U16MSB:	4112	{*< As above, but big-endian byte order }
AUDIO_S16MSB:	36880	{*< As above, but big-endian byte order }
AUDIO_U16:	AUDIO_U16LSB
AUDIO_S16:	AUDIO_S16LSB

{*
 *  @name Native audio byte ordering
 }
either SDL_BYTEORDER = SDL_LIL_ENDIAN [
AUDIO_U16SYS:	AUDIO_U16LSB
AUDIO_S16SYS:	AUDIO_S16LSB
][
AUDIO_U16SYS:	AUDIO_U16MSB
AUDIO_S16SYS:	AUDIO_S16MSB
]

{* A structure to hold a set of audio conversion filters and buffers }
SDL_AudioCVT_: SDL_AudioCVT: make struct! [
  needed [integer!] {*< Set to 1 if conversion possible }
  src_format [short] {*< Source audio format }
  dst_format [short] {*< Target audio format }
  rate_incr [double] {*< Rate conversion increment }
  buf [integer!] {*< Buffer to hold entire audio data }
  len [integer!] {*< Length of original audio buffer }
  len_cvt [integer!] {*< Length of converted audio buffer }
  len_mult [integer!] {*< buffer must be len*len_mult big }
  len_ratio [double] {*< Given len, final size is len*len_ratio }
  filters [integer!] {void (SDLCALL *filters[10])(struct SDL_AudioCVT *cvt, Uint16 format);}
  filter_index [integer!] {*< Current audio conversion function }
] none ;

{*
 * @name Audio Init and Quit
 * These functions are used internally, and should not be used unless you
 * have a specific need to specify the audio driver you want to use.
 * You should normally use SDL_Init() or SDL_InitSubSystem().
 }
SDL_AudioInit: make routine! [ driver_name [string!] return: [integer!] ] SDL-lib "SDL_AudioInit" 
SDL_AudioQuit: make routine! [ return: [integer!] ] SDL-lib "SDL_AudioQuit" 

{*
 * This function fills the given character buffer with the name of the
 * current audio driver, and returns a pointer to it if the audio driver has
 * been initialized.  It returns NULL if no driver has been initialized.
 }
SDL_AudioDriverName: make routine! [ namebuf [string!] maxlen [integer!] return: [string!] ] SDL-lib "SDL_AudioDriverName" 

 {*
 * This function opens the audio device with the desired parameters, and
 * returns 0 if successful, placing the actual hardware parameters in the
 * structure pointed to by 'obtained'.  If 'obtained' is NULL, the audio
 * data passed to the callback function will be guaranteed to be in the
 * requested format, and will be automatically converted to the hardware
 * audio format if necessary.  This function returns -1 if it failed 
 * to open the audio device, or couldn't set up the audio thread.
 *
 * The audio device starts out playing silence when it's opened, and should
 * be enabled for playing by calling SDL_PauseAudio(0) when you are ready
 * for your audio callback function to be called.  Since the audio driver
 * may modify the requested size of the audio buffer, you should allocate
 * any local mixing buffers after you open the audio device.
 *
 * @sa SDL_AudioSpec
 }
SDL_OpenAudio: make routine! [ desired [struct! []] obtained [integer!] return: [integer!] ] SDL-lib "SDL_OpenAudio" 

SDL_AUDIO_STOPPED: 0
SDL_AUDIO_PLAYING: 1
SDL_AUDIO_PAUSED: 2

SDL_audiostatus: integer!;

{* Get the current audio state }
SDL_GetAudioStatus: make routine! [ return: [SDL_audiostatus] ] SDL-lib "SDL_GetAudioStatus" 

{*
 * This function pauses and unpauses the audio callback processing.
 * It should be called with a parameter of 0 after opening the audio
 * device to start playing sound.  This is so you can safely initialize
 * data for your callback function after opening the audio device.
 * Silence will be written to the audio device during the pause.
 }
SDL_PauseAudio: make routine! [ pause_on [integer!] return: [integer!] ] SDL-lib "SDL_PauseAudio" 

 {*
 * This function loads a WAVE from the data source, automatically freeing
 * that source if 'freesrc' is non-zero.  For example, to load a WAVE file,
 * you could do:
 *	@code SDL_LoadWAV_RW(SDL_RWFromFile("sample.wav", "rb"), 1, ...); @endcode
 *
 * If this function succeeds, it returns the given SDL_AudioSpec,
 * filled with the audio data format of the wave data, and sets
 * 'audio_buf' to a malloc()'d buffer containing the audio data,
 * and sets 'audio_len' to the length of that audio buffer, in bytes.
 * You need to free the audio buffer with SDL_FreeWAV() when you are 
 * done with it.
 *
 * This function returns NULL and sets the SDL error message if the 
 * wave file cannot be opened, uses an unknown data format, or is 
 * corrupt.  Currently raw and MS-ADPCM WAVE files are supported.
 }
SDL_LoadWAV_RW: make routine! [ src [integer!] freesrc [integer!] spec [struct! []] audio_buf [struct! []] audio_len [struct! []] return: [integer!] ] SDL-lib "SDL_LoadWAV_RW" 

{* Compatibility convenience function -- loads a WAV from a file }
SDL_LoadWAV: func [file  spec  audio_buf  audio_len] [
	SDL_LoadWAV_RW SDL_RWFromFile file "rb" 1 spec audio_buf audio_len
]

{*
 * This function frees data previously allocated with SDL_LoadWAV_RW()
 }
SDL_FreeWAV: make routine! [ audio_buf [integer!] return: [integer!] ] SDL-lib "SDL_FreeWAV" 

 {*
 * This function takes a source format and rate and a destination format
 * and rate, and initializes the 'cvt' structure with information needed
 * by SDL_ConvertAudio() to convert a buffer of audio data from one format
 * to the other.
 *
 * @return This function returns 0, or -1 if there was an error.
 }
SDL_BuildAudioCVT: make routine! [ cvt [integer!]
 src_format [short] src_channels [char!] src_rate [integer!]
 dst_format [short] dst_channels [char!] dst_rate [integer!] return: [integer!] ] SDL-lib "SDL_BuildAudioCVT" 

 {*
 * Once you have initialized the 'cvt' structure using SDL_BuildAudioCVT(),
 * created an audio buffer cvt->buf, and filled it with cvt->len bytes of
 * audio data in the source format, this function will convert it in-place
 * to the desired format.
 * The data conversion may expand the size of the audio data, so the buffer
 * cvt->buf should be allocated after the cvt structure is initialized by
 * SDL_BuildAudioCVT(), and should be cvt->len*cvt->len_mult bytes long.
 }
SDL_ConvertAudio: make routine! [ cvt [integer!] return: [integer!] ] SDL-lib "SDL_ConvertAudio" 

SDL_MIX_MAXVOLUME: 128
{*
 * This takes two audio buffers of the playing audio format and mixes
 * them, performing addition, volume adjustment, and overflow clipping.
 * The volume ranges from 0 - 128, and should be set to SDL_MIX_MAXVOLUME
 * for full audio volume.  Note this does not change hardware volume.
 * This is provided for convenience -- you can mix your own audio data.
 }
SDL_MixAudio: make routine! [ dst [integer!] src [integer!] len [integer!] volume [integer!] return: [integer!] ] SDL-lib "SDL_MixAudio" 

 {*
 * @name Audio Locks
 * The lock manipulated by these functions protects the callback function.
 * During a LockAudio/UnlockAudio pair, you can be guaranteed that the
 * callback function is not running.  Do not call these from the callback
 * function or you will cause deadlock.
 }
 
SDL_LockAudio: make routine! [ return: [integer!] ] SDL-lib "SDL_LockAudio" 
SDL_UnlockAudio: make routine! [ return: [integer!] ] SDL-lib "SDL_UnlockAudio" 

{*
 * This function shuts down audio processing and closes the audio device.
 }
SDL_CloseAudio: make routine! [ return: [integer!] ] SDL-lib "SDL_CloseAudio" 

{*
 *  @file SDL_cdrom.h
 *  This is the CD-audio control API for Simple DirectMedia Layer
 }
{*
 *  @file SDL_cdrom.h
 *  In order to use these functions, SDL_Init() must have been called
 *  with the SDL_INIT_CDROM flag.  This causes SDL to scan the system
 *  for CD-ROM drives, and load appropriate drivers.
 }

{* The maximum number of CD-ROM tracks on a disk }
SDL_MAX_TRACKS:	99

{* @name Track Types
 *  The types of CD-ROM track possible
 }
SDL_AUDIO_TRACK:	0
SDL_DATA_TRACK:	4

{* The possible states which a CD-ROM drive can be in. }
CD_TRAYEMPTY: 0
CD_STOPPED: 1
CD_PLAYING: 2
CD_PAUSED: 3
CD_ERROR: -1

CDstatus: integer!;

{* Given a status, returns true if there's a disk in the drive }
CD_INDRIVE: func [status] [ status > 0 ]

SDL_CDtrack: make struct! [
  id [char!] {*< Track number }
  type [char!] {*< Data or audio track }
  unused [short] {}
  length [integer!] {*< Length, in frames, of this track }
  offset [integer!] {*< Offset, in frames, from start of disk }
] none ;

{* This structure is only current as of the last call to SDL_CDStatus() }
SDL_CD: make struct! [;[save]
  id [integer!] {*< Private drive identifier }
  status [CDstatus] {*< Current drive status}

 {* The rest of this structure is only valid if there's a CD in drive }
 
  numtracks [integer!] {*< Number of tracks on disk }
  cur_track [integer!] {*< Current track position }
  cur_frame [integer!] {*< Current frame offset within current track }
  ;tracks {[100]} ;REBOL-NOTE: see below
 
] none ;

SDL_CD-spec: copy first SDL_CD
use [trk n] [
	for n 0 (SDL_MAX_TRACKS + 1) 1 [
		trk: copy first SDL_CDtrack
		forskip trk 3 [
			change trk to-word rejoin ['track- n '- first trk]
		]
		insert tail SDL_CD-spec trk
	]
]
SDL_CD: make struct! SDL_CD-spec none

{REBOL-NOTE: use this func to access tracks' info. Usage: print cdrom/(track- i 'length) }
track-: func [i [integer!] memb [word!]] [to-word rejoin ['track- i '- memb]]

{* @name Frames / MSF Conversion Functions
 *  Conversion functions from frames to Minute/Second/Frames and vice versa
 }
CD_FPS:	75
FRAMES_TO_MSF: func [fr M [word!] S [word!] F [word!] /local value] [					
	value: fr							
	set F value // CD_FPS	
	value: value / CD_FPS						
	set S value // 60						
	value: to-integer value / 60							
	set M value							
]
MSF_TO_FRAMES: func [M  S  F] 	  [M * 60 * CD_FPS + S * CD_FPS + F]  

{ CD-audio API functions: }
{*
 *  Returns the number of CD-ROM drives on the system, or -1 if
 *  SDL_Init() has not been called with the SDL_INIT_CDROM flag.
 }
SDL_CDNumDrives: make routine! [ return: [integer!] ] SDL-lib "SDL_CDNumDrives" 

{*
 *  Returns a human-readable, system-dependent identifier for the CD-ROM.
 *  Example:
 *   - "/dev/cdrom"
 *   - "E:"
 *   - "/dev/disk/ide/1/master"
 }
SDL_CDName: make routine! [ drive [integer!] return: [string!] ] SDL-lib "SDL_CDName" 

{*
 *  Opens a CD-ROM drive for access.  It returns a drive handle on success,
 *  or NULL if the drive was invalid or busy.  This newly opened CD-ROM
 *  becomes the default CD used when other CD functions are passed a NULL
 *  CD-ROM handle.
 *  Drives are numbered starting with 0.  Drive 0 is the system default CD-ROM.
 }
SDL_CDOpen: make routine! [ drive [integer!] return: [integer!] ] SDL-lib "SDL_CDOpen" 

{*
 *  This function returns the current status of the given drive.
 *  If the drive has a CD in it, the table of contents of the CD and current
 *  play position of the CD will be stored in the SDL_CD structure.
 }
SDL_CDStatus: make routine! [ cdrom [integer!] return: [CDstatus] ] SDL-lib "SDL_CDStatus" 

 {*
 *  Play the given CD starting at 'start_track' and 'start_frame' for 'ntracks'
 *  tracks and 'nframes' frames.  If both 'ntrack' and 'nframe' are 0, play 
 *  until the end of the CD.  This function will skip data tracks.
 *  This function should only be called after calling SDL_CDStatus() to 
 *  get track information about the CD.
 *  For example:
 *      @code
 *	; Play entire CD:
 *	if ( CD_INDRIVE(SDL_CDStatus(cdrom)) )
 *		SDL_CDPlayTracks(cdrom, 0, 0, 0, 0);
 *	; Play last track:
 *	if ( CD_INDRIVE(SDL_CDStatus(cdrom)) ) {
 *		SDL_CDPlayTracks(cdrom, cdrom->numtracks-1, 0, 0, 0);
 *	}
 *	; Play first and second track and 10 seconds of third track:
 *	if ( CD_INDRIVE(SDL_CDStatus(cdrom)) )
 *		SDL_CDPlayTracks(cdrom, 0, 0, 2, 10);
 *      @endcode
 *
 *  @return This function returns 0, or -1 if there was an error.
 }
SDL_CDPlayTracks: make routine! [ cdrom [integer!]
 start_track [integer!] start_frame [integer!] ntracks [integer!] nframes [integer!] return: [integer!] ] SDL-lib "SDL_CDPlayTracks" 

{*
 *  Play the given CD starting at 'start' frame for 'length' frames.
 *  @return It returns 0, or -1 if there was an error.
 }
SDL_CDPlay: make routine! [ cdrom [integer!] start [integer!] length [integer!] return: [integer!] ] SDL-lib "SDL_CDPlay" 

 {* Pause play
 *  @return returns 0, or -1 on error
 }
SDL_CDPause: make routine! [ cdrom [integer!] return: [integer!] ] SDL-lib "SDL_CDPause" 

 {* Resume play
 *  @return returns 0, or -1 on error
 }
SDL_CDResume: make routine! [ cdrom [integer!] return: [integer!] ] SDL-lib "SDL_CDResume" 

 {* Stop play
 *  @return returns 0, or -1 on error
 }
SDL_CDStop: make routine! [ cdrom [integer!] return: [integer!] ] SDL-lib "SDL_CDStop" 

 {* Eject CD-ROM
 *  @return returns 0, or -1 on error
 }
SDL_CDEject: make routine! [ cdrom [integer!] return: [integer!] ] SDL-lib "SDL_CDEject" 

 {* Closes the handle for the CD-ROM drive }
SDL_CDClose: make routine! [ cdrom [integer!] return: [integer!] ] SDL-lib "SDL_CDClose" 

SDL_HAS_64BIT_TYPE: 1

{ Enable various audio drivers }
{ #undef SDL_AUDIO_DRIVER_ALSA }
{ #undef SDL_AUDIO_DRIVER_ALSA_DYNAMIC }
{ #undef SDL_AUDIO_DRIVER_ARTS }
{ #undef SDL_AUDIO_DRIVER_ARTS_DYNAMIC }
{ #undef SDL_AUDIO_DRIVER_BAUDIO }
{ #undef SDL_AUDIO_DRIVER_BSD }
{ #undef SDL_AUDIO_DRIVER_COREAUDIO }
{ #undef SDL_AUDIO_DRIVER_DART }
{ #undef SDL_AUDIO_DRIVER_DC }
SDL_AUDIO_DRIVER_DISK: 1
SDL_AUDIO_DRIVER_DUMMY: 1
{ #undef SDL_AUDIO_DRIVER_DMEDIA }
SDL_AUDIO_DRIVER_DSOUND: 1
{ #undef SDL_AUDIO_DRIVER_PULSE }
{ #undef SDL_AUDIO_DRIVER_PULSE_DYNAMIC }
{ #undef SDL_AUDIO_DRIVER_ESD }
{ #undef SDL_AUDIO_DRIVER_ESD_DYNAMIC }
{ #undef SDL_AUDIO_DRIVER_MINT }
{ #undef SDL_AUDIO_DRIVER_MMEAUDIO }
{ #undef SDL_AUDIO_DRIVER_NAS }
{ #undef SDL_AUDIO_DRIVER_NAS_DYNAMIC }
{ #undef SDL_AUDIO_DRIVER_OSS }
{ #undef SDL_AUDIO_DRIVER_OSS_SOUNDCARD_H }
{ #undef SDL_AUDIO_DRIVER_PAUD }
{ #undef SDL_AUDIO_DRIVER_QNXNTO }
{ #undef SDL_AUDIO_DRIVER_SNDMGR }
{ #undef SDL_AUDIO_DRIVER_SUNAUDIO }
SDL_AUDIO_DRIVER_WAVEOUT: 1

switch system/version/4 [
{ Enable various cdrom drivers }
{ #undef SDL_CDROM_AIX }
{ #undef SDL_CDROM_BEOS }
{ #undef SDL_CDROM_BSDI }
{ #undef SDL_CDROM_DC }
{ #undef SDL_CDROM_DUMMY }
{ #undef SDL_CDROM_FREEBSD }
{ #undef SDL_CDROM_LINUX }
{ #undef SDL_CDROM_MACOS }
 2 [SDL_CDROM_MACOSX: 1]
{ #undef SDL_CDROM_MINT }
{ #undef SDL_CDROM_OPENBSD }
{ #undef SDL_CDROM_OS2 }
{ #undef SDL_CDROM_OSF }
{ #undef SDL_CDROM_QNX }
 3 [SDL_CDROM_WIN32: 1]
]
switch system/version/4 [
{ Enable various input drivers }
{ #undef SDL_INPUT_LINUXEV }
{ #undef SDL_INPUT_TSLIB }
{ #undef SDL_JOYSTICK_BEOS }
{ #undef SDL_JOYSTICK_DC }
{ #undef SDL_JOYSTICK_DUMMY }
{ #undef SDL_JOYSTICK_IOKIT }
{ #undef SDL_JOYSTICK_LINUX }
 2 [SDL_JOYSTICK_MACOS: 1]
{ #undef SDL_JOYSTICK_MINT }
{ #undef SDL_JOYSTICK_OS2 }
{ #undef SDL_JOYSTICK_RISCOS }
 3 [SDL_JOYSTICK_WINMM: 1]
{ #undef SDL_JOYSTICK_USBHID }
{ #undef SDL_JOYSTICK_USBHID_MACHINE_JOYSTICK_H }
]
switch system/version/4 [
{ Enable various shared object loading systems }
{ #undef SDL_LOADSO_BEOS }
{ #undef SDL_LOADSO_DLCOMPAT }
{ #undef SDL_LOADSO_DLOPEN }
{ #undef SDL_LOADSO_DUMMY }
{ #undef SDL_LOADSO_LDG }
 2 [SDL_LOADSO_MACOS: 1]
{ #undef SDL_LOADSO_OS2 }
 3 [SDL_LOADSO_WIN32: 1]
]
switch system/version/4 [
{ Enable various threading systems }
{ #undef SDL_THREAD_BEOS }
{ #undef SDL_THREAD_DC }
{ #undef SDL_THREAD_OS2 }
{ #undef SDL_THREAD_PTH }
{ #undef SDL_THREAD_PTHREAD }
{ #undef SDL_THREAD_PTHREAD_RECURSIVE_MUTEX }
{ #undef SDL_THREAD_PTHREAD_RECURSIVE_MUTEX_NP }
{ #undef SDL_THREAD_SPROC }
 3 [SDL_THREAD_WIN32: 1]
]
switch system/version/4 [
{ Enable various timer systems }
{ #undef SDL_TIMER_BEOS }
{ #undef SDL_TIMER_DC }
{ #undef SDL_TIMER_DUMMY }
 2 [SDL_TIMER_MACOS: 1]
{ #undef SDL_TIMER_MINT }
{ #undef SDL_TIMER_OS2 }
{ #undef SDL_TIMER_RISCOS }
 4 [SDL_TIMER_UNIX: 1]
 3 [SDL_TIMER_WIN32: 1]
{ #undef SDL_TIMER_WINCE }
]
{ Enable various video drivers }
{ #undef SDL_VIDEO_DRIVER_AALIB }
{ #undef SDL_VIDEO_DRIVER_BWINDOW }
{ #undef SDL_VIDEO_DRIVER_CACA }
{ #undef SDL_VIDEO_DRIVER_DC }
SDL_VIDEO_DRIVER_DDRAW: 1
{ #undef SDL_VIDEO_DRIVER_DGA }
{ #undef SDL_VIDEO_DRIVER_DIRECTFB }
{ #undef SDL_VIDEO_DRIVER_DRAWSPROCKET }
SDL_VIDEO_DRIVER_DUMMY: 1
{ #undef SDL_VIDEO_DRIVER_FBCON }
{ #undef SDL_VIDEO_DRIVER_GAPI }
{ #undef SDL_VIDEO_DRIVER_GEM }
{ #undef SDL_VIDEO_DRIVER_GGI }
{ #undef SDL_VIDEO_DRIVER_IPOD }
{ #undef SDL_VIDEO_DRIVER_NANOX }
{ #undef SDL_VIDEO_DRIVER_OS2FS }
{ #undef SDL_VIDEO_DRIVER_PHOTON }
{ #undef SDL_VIDEO_DRIVER_PICOGUI }
{ #undef SDL_VIDEO_DRIVER_PS2GS }
{ #undef SDL_VIDEO_DRIVER_PS3 }
{ #undef SDL_VIDEO_DRIVER_QTOPIA }
{ #undef SDL_VIDEO_DRIVER_QUARTZ }
{ #undef SDL_VIDEO_DRIVER_RISCOS }
{ #undef SDL_VIDEO_DRIVER_SVGALIB }
{ #undef SDL_VIDEO_DRIVER_TOOLBOX }
{ #undef SDL_VIDEO_DRIVER_VGL }
SDL_VIDEO_DRIVER_WINDIB: 1
{ #undef SDL_VIDEO_DRIVER_WSCONS }
{ #undef SDL_VIDEO_DRIVER_X11 }
{ #undef SDL_VIDEO_DRIVER_X11_DGAMOUSE }
{ #undef SDL_VIDEO_DRIVER_X11_DYNAMIC }
{ #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT }
{ #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR }
{ #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XRENDER }
{ #undef SDL_VIDEO_DRIVER_X11_VIDMODE }
{ #undef SDL_VIDEO_DRIVER_X11_XINERAMA }
{ #undef SDL_VIDEO_DRIVER_X11_XME }
{ #undef SDL_VIDEO_DRIVER_X11_XRANDR }
{ #undef SDL_VIDEO_DRIVER_X11_XV }
{ #undef SDL_VIDEO_DRIVER_XBIOS }

{ Enable OpenGL support }
SDL_VIDEO_OPENGL: 1
{ #undef SDL_VIDEO_OPENGL_GLX }
SDL_VIDEO_OPENGL_WGL: 1
{ #undef SDL_VIDEO_OPENGL_OSMESA }
{ #undef SDL_VIDEO_OPENGL_OSMESA_DYNAMIC }

{ Disable screensaver }
SDL_VIDEO_DISABLE_SCREENSAVER: 1

{ Enable assembly routines }
SDL_ASSEMBLY_ROUTINES: 1
SDL_HERMES_BLITTERS: 1
{ #undef SDL_ALTIVEC_BLITTERS }

{* This function returns true if the CPU has the RDTSC instruction }
SDL_HasRDTSC: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_HasRDTSC" 

 {* This function returns true if the CPU has MMX features }
SDL_HasMMX: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_HasMMX" 

 {* This function returns true if the CPU has MMX Ext. features }
SDL_HasMMXExt: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_HasMMXExt" 

 {* This function returns true if the CPU has 3DNow features }
SDL_Has3DNow: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_Has3DNow" 

 {* This function returns true if the CPU has 3DNow! Ext. features }
SDL_Has3DNowExt: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_Has3DNowExt" 

 {* This function returns true if the CPU has SSE features }
SDL_HasSSE: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_HasSSE" 

 {* This function returns true if the CPU has SSE2 features }
SDL_HasSSE2: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_HasSSE2" 

 {* This function returns true if the CPU has AltiVec features }
SDL_HasAltiVec: make routine! [ return: [SDL_bool] ] SDL-lib "SDL_HasAltiVec" 

{*
 *  @name SDL_Swap Functions
 *  Use inline functions for compilers that support them, and static
 *  functions for those that do not.  Because these functions become
 *  static for compilers that do not support inline functions, this
 *  header should only be included in files that actually use them.
 }
SDL_Swap16: func [x] [
	(shift/left x 8) or (shift x 8)
]

SDL_Swap32: func [x] [
	((shift/left x 24) or ((shift/left x 8) and 16711680) or ((shift x 8) and 65280) or (shift x 24))
]

either SDL_HAS_64BIT_TYPE > 0 [
 SDL_Swap64: func [x /local hi  lo] [

	{ Separate into high and low 32-bit values and swap them }
	lo: x and -1
	x: shift x 32
	hi: x and -1
	x: SDL_Swap32 lo
	x: shift/left x 32
	x: x or SDL_Swap32 hi
 ]
] [

{ This is mainly to keep compilers from complaining in SDL code.
 * If there is no real 64-bit datatype, then compilers will complain about
 * the fake 64-bit datatype that SDL provides when it compiles user code.
 }
SDL_Swap64: func [X] [X]
]


{*
 *  @name SDL_SwapLE and SDL_SwapBE Functions
 *  Byteswap item from the specified endianness to the native endianness
 }

either SDL_BYTEORDER = SDL_LIL_ENDIAN [
SDL_SwapLE16: func [X] [X]
SDL_SwapLE32: func [X] [X]
SDL_SwapLE64: func [X] [X]
SDL_SwapBE16: func [X] [SDL_Swap16 X] 
SDL_SwapBE32: func [X] [SDL_Swap32 X] 
SDL_SwapBE64: func [X] [SDL_Swap64 X] 
][
SDL_SwapLE16: func [X] [SDL_Swap16 X] 
SDL_SwapLE32: func [X] [SDL_Swap32 X] 
SDL_SwapLE64: func [X] [SDL_Swap64 X] 
SDL_SwapBE16: func [X] [X]
SDL_SwapBE32: func [X] [X]
SDL_SwapBE64: func [X] [X]
]

{*
 *  @file SDL_error.h
 *  Simple error message routines for SDL
 }
{* 
 *  @name Public functions
 }
SDL_SetError: make routine! [ fmt [string!] return: [integer!] ] SDL-lib "SDL_SetError" {,...} 
SDL_GetError: make routine! [ return: [string!] ] SDL-lib "SDL_GetError" 
SDL_ClearError: make routine! [ return: [integer!] ] SDL-lib "SDL_ClearError" 

{*
 *  @name Private functions
 *  @internal Private error message function - used internally
 }
SDL_OutOfMemory: func [] [SDL_Error SDL_ENOMEM] 
SDL_Unsupported: func [] [SDL_Error SDL_UNSUPPORTED] 

SDL_ENOMEM: 0
SDL_EFREAD: 1
SDL_EFWRITE: 2
SDL_EFSEEK: 3
SDL_UNSUPPORTED: 4
SDL_LASTERROR: 5

SDL_errorcode: integer!

SDL_Error: make routine! [ code [SDL_errorcode] return: [integer!] ] SDL-lib "SDL_Error" 


{* What we really want is a mapping of every raw key on the keyboard.
 *  To support international keyboards, we use the range 161 - 255
 *  as international virtual keycodes.  We'll follow in the footsteps of X11...
 *  @brief The names of the keys
 }
 {* @name ASCII mapped keysyms
         *  The keyboard syms have been cleverly chosen to map to ASCII
         }
 
SDLK_UNKNOWN: 0
SDLK_FIRST: 0
SDLK_BACKSPACE: 8
SDLK_TAB: 9
SDLK_CLEAR: 12
SDLK_RETURN: 13
SDLK_PAUSE: 19
SDLK_ESCAPE: 27
SDLK_SPACE: 32
SDLK_EXCLAIM: 33
SDLK_QUOTEDBL: 34
SDLK_HASH: 35
SDLK_DOLLAR: 36
SDLK_AMPERSAND: 38
SDLK_QUOTE: 39
SDLK_LEFTPAREN: 40
SDLK_RIGHTPAREN: 41
SDLK_ASTERISK: 42
SDLK_PLUS: 43
SDLK_COMMA: 44
SDLK_MINUS: 45
SDLK_PERIOD: 46
SDLK_SLASH: 47
SDLK_0: 48
SDLK_1: 49
SDLK_2: 50
SDLK_3: 51
SDLK_4: 52
SDLK_5: 53
SDLK_6: 54
SDLK_7: 55
SDLK_8: 56
SDLK_9: 57
SDLK_COLON: 58
SDLK_SEMICOLON: 59
SDLK_LESS: 60
SDLK_EQUALS: 61
SDLK_GREATER: 62
SDLK_QUESTION: 63
SDLK_AT: 64
 { 
	   Skip uppercase letters
	 }
SDLK_LEFTBRACKET: 91
SDLK_BACKSLASH: 92
SDLK_RIGHTBRACKET: 93
SDLK_CARET: 94
SDLK_UNDERSCORE: 95
SDLK_BACKQUOTE: 96
SDLK_a: 97
SDLK_b: 98
SDLK_c: 99
SDLK_d: 100
SDLK_e: 101
SDLK_f: 102
SDLK_g: 103
SDLK_h: 104
SDLK_i: 105
SDLK_j: 106
SDLK_k: 107
SDLK_l: 108
SDLK_m: 109
SDLK_n: 110
SDLK_o: 111
SDLK_p: 112
SDLK_q: 113
SDLK_r: 114
SDLK_s: 115
SDLK_t: 116
SDLK_u: 117
SDLK_v: 118
SDLK_w: 119
SDLK_x: 120
SDLK_y: 121
SDLK_z: 122
SDLK_DELETE: 127
 { End of ASCII mapped keysyms }
 
 {* @name International keyboard syms }
SDLK_WORLD_0: 160 { 160 }
SDLK_WORLD_1: 161
SDLK_WORLD_2: 162
SDLK_WORLD_3: 163
SDLK_WORLD_4: 164
SDLK_WORLD_5: 165
SDLK_WORLD_6: 166
SDLK_WORLD_7: 167
SDLK_WORLD_8: 168
SDLK_WORLD_9: 169
SDLK_WORLD_10: 170
SDLK_WORLD_11: 171
SDLK_WORLD_12: 172
SDLK_WORLD_13: 173
SDLK_WORLD_14: 174
SDLK_WORLD_15: 175
SDLK_WORLD_16: 176
SDLK_WORLD_17: 177
SDLK_WORLD_18: 178
SDLK_WORLD_19: 179
SDLK_WORLD_20: 180
SDLK_WORLD_21: 181
SDLK_WORLD_22: 182
SDLK_WORLD_23: 183
SDLK_WORLD_24: 184
SDLK_WORLD_25: 185
SDLK_WORLD_26: 186
SDLK_WORLD_27: 187
SDLK_WORLD_28: 188
SDLK_WORLD_29: 189
SDLK_WORLD_30: 190
SDLK_WORLD_31: 191
SDLK_WORLD_32: 192
SDLK_WORLD_33: 193
SDLK_WORLD_34: 194
SDLK_WORLD_35: 195
SDLK_WORLD_36: 196
SDLK_WORLD_37: 197
SDLK_WORLD_38: 198
SDLK_WORLD_39: 199
SDLK_WORLD_40: 200
SDLK_WORLD_41: 201
SDLK_WORLD_42: 202
SDLK_WORLD_43: 203
SDLK_WORLD_44: 204
SDLK_WORLD_45: 205
SDLK_WORLD_46: 206
SDLK_WORLD_47: 207
SDLK_WORLD_48: 208
SDLK_WORLD_49: 209
SDLK_WORLD_50: 210
SDLK_WORLD_51: 211
SDLK_WORLD_52: 212
SDLK_WORLD_53: 213
SDLK_WORLD_54: 214
SDLK_WORLD_55: 215
SDLK_WORLD_56: 216
SDLK_WORLD_57: 217
SDLK_WORLD_58: 218
SDLK_WORLD_59: 219
SDLK_WORLD_60: 220
SDLK_WORLD_61: 221
SDLK_WORLD_62: 222
SDLK_WORLD_63: 223
SDLK_WORLD_64: 224
SDLK_WORLD_65: 225
SDLK_WORLD_66: 226
SDLK_WORLD_67: 227
SDLK_WORLD_68: 228
SDLK_WORLD_69: 229
SDLK_WORLD_70: 230
SDLK_WORLD_71: 231
SDLK_WORLD_72: 232
SDLK_WORLD_73: 233
SDLK_WORLD_74: 234
SDLK_WORLD_75: 235
SDLK_WORLD_76: 236
SDLK_WORLD_77: 237
SDLK_WORLD_78: 238
SDLK_WORLD_79: 239
SDLK_WORLD_80: 240
SDLK_WORLD_81: 241
SDLK_WORLD_82: 242
SDLK_WORLD_83: 243
SDLK_WORLD_84: 244
SDLK_WORLD_85: 245
SDLK_WORLD_86: 246
SDLK_WORLD_87: 247
SDLK_WORLD_88: 248
SDLK_WORLD_89: 249
SDLK_WORLD_90: 250
SDLK_WORLD_91: 251
SDLK_WORLD_92: 252
SDLK_WORLD_93: 253
SDLK_WORLD_94: 254
SDLK_WORLD_95: 255 { 255 }
 
 {* @name Numeric keypad }
 
SDLK_KP0: 256
SDLK_KP1: 257
SDLK_KP2: 258
SDLK_KP3: 259
SDLK_KP4: 260
SDLK_KP5: 261
SDLK_KP6: 262
SDLK_KP7: 263
SDLK_KP8: 264
SDLK_KP9: 265
SDLK_KP_PERIOD: 266
SDLK_KP_DIVIDE: 267
SDLK_KP_MULTIPLY: 268
SDLK_KP_MINUS: 269
SDLK_KP_PLUS: 270
SDLK_KP_ENTER: 271
SDLK_KP_EQUALS: 272
 
 {* @name Arrows + Home/End pad }
 
SDLK_UP: 273
SDLK_DOWN: 274
SDLK_RIGHT: 275
SDLK_LEFT: 276
SDLK_INSERT: 277
SDLK_HOME: 278
SDLK_END: 279
SDLK_PAGEUP: 280
SDLK_PAGEDOWN: 281
 
 {* @name Function keys }
 
SDLK_F1: 282
SDLK_F2: 283
SDLK_F3: 284
SDLK_F4: 285
SDLK_F5: 286
SDLK_F6: 287
SDLK_F7: 288
SDLK_F8: 289
SDLK_F9: 290
SDLK_F10: 291
SDLK_F11: 292
SDLK_F12: 293
SDLK_F13: 294
SDLK_F14: 295
SDLK_F15: 296
 
 {* @name Key state modifier keys }
 
SDLK_NUMLOCK: 300
SDLK_CAPSLOCK: 301
SDLK_SCROLLOCK: 302
SDLK_RSHIFT: 303
SDLK_LSHIFT: 304
SDLK_RCTRL: 305
SDLK_LCTRL: 306
SDLK_RALT: 307
SDLK_LALT: 308
SDLK_RMETA: 309
SDLK_LMETA: 310
SDLK_LSUPER: 311 {*< Left "Windows" key }
SDLK_RSUPER: 312 {*< Right "Windows" key }
SDLK_MODE: 313 {*< "Alt Gr" key }
SDLK_COMPOSE: 314 {*< Multi-key compose key }
 
 {* @name Miscellaneous function keys }
 
SDLK_HELP: 315
SDLK_PRINT: 316
SDLK_SYSREQ: 317
SDLK_BREAK: 318
SDLK_MENU: 319
SDLK_POWER: 320 {*< Power Macintosh power key }
SDLK_EURO: 321 {*< Some european keyboards }
SDLK_UNDO: 322 {*< Atari keyboard has Undo }

 { Add any other keys here }

SDLK_LAST: 323

SDLKey: integer!;

{* Enumeration of valid key mods (possibly OR'd together) }
KMOD_NONE: 0
KMOD_LSHIFT: 1
KMOD_RSHIFT: 2
KMOD_LCTRL: 64
KMOD_RCTRL: 128
KMOD_LALT: 256
KMOD_RALT: 512
KMOD_LMETA: 1024
KMOD_RMETA: 2048
KMOD_NUM: 4096
KMOD_CAPS: 8192
KMOD_MODE: 16384
KMOD_RESERVED: 32768

SDLMod: integer!;

KMOD_CTRL:    KMOD_LCTRL or KMOD_RCTRL 
KMOD_SHIFT:   KMOD_LSHIFT or KMOD_RSHIFT 
KMOD_ALT:     KMOD_LALT or KMOD_RALT 
KMOD_META:    KMOD_LMETA or KMOD_RMETA 


{* Keysym structure
 *
 *  - The scancode is hardware dependent, and should not be used by general
 *    applications.  If no hardware scancode is available, it will be 0.
 *
 *  - The 'unicode' translated character is only available when character
 *    translation is enabled by the SDL_EnableUNICODE() API.  If non-zero,
 *    this is a UNICODE character corresponding to the keypress.  If the
 *    high 9 bits of the character are 0, then this maps to the equivalent
 *    ASCII character:
 *      @code
 *	char ch;
 *	if ( (keysym.unicode & 65408) == 0 ) {
 *		ch = keysym.unicode & 127;
 *	} else {
 *		An international character..
 *	}
 *      @endcode
 }
SDL_keysym_: SDL_keysym: make struct! [
  scancode [char!] {*< hardware specific scancode }
  sym [SDLKey] {*< SDL virtual keysym }
  mod [SDLMod] {*< current key modifiers }
  unicode [short] {*< translated character }
] none ;

{* This is the mask which refers to all hotkey bindings }
SDL_ALL_HOTKEYS:		-1


{*
 * Enable/Disable UNICODE translation of keyboard input.
 *
 * This translation has some overhead, so translation defaults off.
 *
 * @param[in] enable
 * If 'enable' is 1, translation is enabled.
 * If 'enable' is 0, translation is disabled.
 * If 'enable' is -1, the translation state is not changed.
 *
 * @return It returns the previous state of keyboard translation.
 }
SDL_EnableUNICODE: make routine! [ enable [integer!] return: [integer!] ] SDL-lib "SDL_EnableUNICODE" 

SDL_DEFAULT_REPEAT_DELAY:	500
SDL_DEFAULT_REPEAT_INTERVAL:	30
{*
 * Enable/Disable keyboard repeat.  Keyboard repeat defaults to off.
 *
 *  @param[in] delay
 *  'delay' is the initial delay in ms between the time when a key is
 *  pressed, and keyboard repeat begins.
 *
 *  @param[in] interval
 *  'interval' is the time in ms between keyboard repeat events.
 *
 *  If 'delay' is set to 0, keyboard repeat is disabled.
 }
SDL_EnableKeyRepeat: make routine! [ delay [integer!] interval [integer!] return: [integer!] ] SDL-lib "SDL_EnableKeyRepeat" 
SDL_GetKeyRepeat: make routine! [ delay [struct! []] interval [struct! []] return: [integer!] ] SDL-lib "SDL_GetKeyRepeat" 

{*
 * Get a snapshot of the current state of the keyboard.
 * Returns an array of keystates, indexed by the SDLK_* syms.
 * Usage:
 *	@code
 * 	Uint8 *keystate = SDL_GetKeyState(NULL);
 *	if ( keystate[SDLK_RETURN] ) ;... \<RETURN> is pressed.
 *	@endcode
 }
SDL_GetKeyState: make routine! [ numkeys [struct! []] return: [struct! []] ] SDL-lib "SDL_GetKeyState" 

 {*
 * Get the current key modifier state
 }
SDL_GetModState: make routine! [ return: [SDLMod] ] SDL-lib "SDL_GetModState" 

 {*
 * Set the current key modifier state.
 * This does not change the keyboard state, only the key modifier flags.
 }
SDL_SetModState: make routine! [ modstate [SDLMod] return: [integer!] ] SDL-lib "SDL_SetModState" 

 {*
 * Get the name of an SDL virtual keysym
 }
SDL_GetKeyName: make routine! [ key [SDLKey] return: [string!] ] SDL-lib "SDL_GetKeyName" 

{* @name Useful data types }

SDL_Rect_: SDL_Rect: make struct! [
  x [short]  y [short]
  w [short]  h [short]
] none ;

SDL_Colour: SDL_Color_: SDL_Color: make struct! [
  r [char!]
  g [char!]
  b [char!]
  unused [char!]
] none ;
;alias 'SDL_Color "SDL_Colour"

SDL_Palette_: SDL_Palette: make struct! [
  ncolors [integer!]
  colors [integer!]
] none ;

{* Everything in the pixel format structure is read-only }
SDL_PixelFormat_: SDL_PixelFormat: make struct! [
  palette [integer!]
  BitsPerPixel [char!]
  BytesPerPixel [char!]
  Rloss [char!]
  Gloss [char!]
  Bloss [char!]
  Aloss [char!]
  Rshift [char!]
  Gshift [char!]
  Bshift [char!]
  Ashift [char!]
  Rmask [integer!]
  Gmask [integer!]
  Bmask [integer!]
  Amask [integer!]

 {* RGB color key information }
  colorkey [integer!]
 {* Alpha value information (per-surface alpha) }
  alpha [char!]
] none ;

{* This structure should be treated as read-only, except for 'pixels',
 *  which, if not NULL, contains the raw pixel data for the surface.
 }
SDL_Surface_: SDL_Surface: make struct! [
  flags [integer!] {*< Read-only }
  format [integer!] {*< Read-only }
  w [integer!]  h [integer!] {*< Read-only }
  pitch [short] {*< Read-only }
  pixels [integer!] {*< Read-write }
  offset [integer!] {*< Private }

 {* Hardware-specific surface info }
  hwdata [integer!]

 {* clipping information }
  clip_rect [struct! [
  x [short]  y [short]
  w [short]  h [short]
]] {*< Read-only }
  unused1 [integer!] {*< for binary compatibility }

 {* Allow recursive locks }
  locked [integer!] {*< Private }

 {* info for fast blit mapping to other surfaces }
 map [integer!] {*< Private }

 {* format version, bumped at every change to invalidate blit maps }
  format_version [integer!] {*< Private }

 {* Reference count -- used when freeing surface }
  refcount [integer!] {*< Read-mostly }
] none ;

{* @name SDL_Surface Flags
 *  These are the currently supported flags for the SDL_surface
 }
{* Available for SDL_CreateRGBSurface() or SDL_SetVideoMode() }

SDL_SWSURFACE:	0	{*< Surface is in system memory }
SDL_HWSURFACE:	1	{*< Surface is in video memory }
SDL_ASYNCBLIT:	4	{*< Use asynchronous blits if possible }

{*
 *  @file SDL_events.h
 *  Include file for SDL event handling
 }
{* @name General keyboard/mouse state definitions }
SDL_RELEASED:	0
SDL_PRESSED:	1

{* Event enumerations }

SDL_NOEVENT: 0 {*< Unused (do not remove) }
SDL_ACTIVEEVENT: 1 {*< Application loses/gains visibility }
SDL_KEYDOWN: 2 {*< Keys pressed }
SDL_KEYUP: 3 {*< Keys released }
SDL_MOUSEMOTION: 4 {*< Mouse moved }
SDL_MOUSEBUTTONDOWN: 5 {*< Mouse button pressed }
SDL_MOUSEBUTTONUP: 6 {*< Mouse button released }
SDL_JOYAXISMOTION: 7 {*< Joystick axis motion }
SDL_JOYBALLMOTION: 8 {*< Joystick trackball motion }
SDL_JOYHATMOTION: 9 {*< Joystick hat position change }
SDL_JOYBUTTONDOWN: 10 {*< Joystick button pressed }
SDL_JOYBUTTONUP: 11 {*< Joystick button released }
SDL_QUIT: 12 {*< User-requested quit }
SDL_SYSWMEVENT: 13 {*< System specific event }
SDL_EVENT_RESERVEDA: 14 {*< Reserved for future use.. }
SDL_EVENT_RESERVEDB: 15 {*< Reserved for future use.. }
SDL_VIDEORESIZE: 16 {*< User resized video mode }
SDL_VIDEOEXPOSE: 17 {*< Screen needs to be redrawn }
SDL_EVENT_RESERVED2: 18 {*< Reserved for future use.. }
SDL_EVENT_RESERVED3: 19 {*< Reserved for future use.. }
SDL_EVENT_RESERVED4: 20 {*< Reserved for future use.. }
SDL_EVENT_RESERVED5: 21 {*< Reserved for future use.. }
SDL_EVENT_RESERVED6: 22 {*< Reserved for future use.. }
SDL_EVENT_RESERVED7: 23 {*< Reserved for future use.. }
 {* Events SDL_USEREVENT through SDL_MAXEVENTS-1 are for your use }
SDL_USEREVENT: 24
 {* This last event is only for bounding internal arrays
	*  It is the number of bits in the event mask datatype -- Uint32
        }
SDL_NUMEVENTS: 32

SDL_EventType: integer!;

{* @name Predefined event masks }

SDL_EVENTMASK: func [X] [shift/left 1 X]

 SDL_ACTIVEEVENTMASK: SDL_EVENTMASK SDL_ACTIVEEVENT  
 SDL_KEYDOWNMASK: SDL_EVENTMASK SDL_KEYDOWN  
 SDL_KEYUPMASK: SDL_EVENTMASK SDL_KEYUP  
 SDL_KEYEVENTMASK: (SDL_EVENTMASK SDL_KEYDOWN) or SDL_EVENTMASK SDL_KEYUP  
 SDL_MOUSEMOTIONMASK: SDL_EVENTMASK SDL_MOUSEMOTION  
 SDL_MOUSEBUTTONDOWNMASK: SDL_EVENTMASK SDL_MOUSEBUTTONDOWN  
 SDL_MOUSEBUTTONUPMASK: SDL_EVENTMASK SDL_MOUSEBUTTONUP  
 SDL_MOUSEEVENTMASK: (SDL_EVENTMASK SDL_MOUSEMOTION) or (SDL_EVENTMASK SDL_MOUSEBUTTONDOWN) or (SDL_EVENTMASK SDL_MOUSEBUTTONUP)  
 SDL_JOYAXISMOTIONMASK: SDL_EVENTMASK SDL_JOYAXISMOTION  
 SDL_JOYBALLMOTIONMASK: SDL_EVENTMASK SDL_JOYBALLMOTION  
 SDL_JOYHATMOTIONMASK: SDL_EVENTMASK SDL_JOYHATMOTION  
 SDL_JOYBUTTONDOWNMASK: SDL_EVENTMASK SDL_JOYBUTTONDOWN  
 SDL_JOYBUTTONUPMASK: SDL_EVENTMASK SDL_JOYBUTTONUP 
 SDL_JOYEVENTMASK: (SDL_EVENTMASK SDL_JOYAXISMOTION) or (SDL_EVENTMASK SDL_JOYBALLMOTION) or (SDL_EVENTMASK SDL_JOYHATMOTION) or (SDL_EVENTMASK SDL_JOYBUTTONDOWN) or (SDL_EVENTMASK SDL_JOYBUTTONUP)  
 SDL_VIDEORESIZEMASK: SDL_EVENTMASK SDL_VIDEORESIZE  
 SDL_VIDEOEXPOSEMASK: SDL_EVENTMASK SDL_VIDEOEXPOSE  
 SDL_QUITMASK: SDL_EVENTMASK SDL_QUIT  
 SDL_SYSWMEVENTMASK: SDL_EVENTMASK SDL_SYSWMEVENT 
SDL_EventMask: integer!
SDL_ALLEVENTS:		-1

{* Application visibility event structure }
SDL_ActiveEvent_: make struct! [
  type [char!] {*< SDL_ACTIVEEVENT }
  gain [char!] {*< Whether given states were gained or lost (1/0) }
  state [char!] {*< A mask of the focus states }
] none ;

{* Keyboard event structure }
SDL_KeyboardEvent_: SDL_KeyboardEvent: make struct! [
  type [char!] {*< SDL_KEYDOWN or SDL_KEYUP }
  which [char!] {*< The keyboard device index }
  state [char!] {*< SDL_PRESSED or SDL_RELEASED }
  ;keysym [struct! [
	  keysym-scancode [char!] {*< hardware specific scancode }
	  keysym-pad [integer!] {REBOL-NOTE: it's necessary to add this...}
	  keysym-sym [SDLKey] {*< SDL virtual keysym }
	  keysym-mod [SDLMod] {*< current key modifiers }
	  keysym-unicode [short] {*< translated character }
	;]
 ;]
] none ;

{* Mouse motion event structure }
SDL_MouseMotionEvent_: SDL_MouseMotionEvent: make struct! [
  type [char!] {*< SDL_MOUSEMOTION }
  which [char!] {*< The mouse device index }
  state [char!] {*< The current button state }
  x [short]  y [short] {*< The X/Y coordinates of the mouse }
  xrel [short] {*< The relative motion in the X direction }
  yrel [short] {*< The relative motion in the Y direction }
] none ;

{* Mouse button event structure }
SDL_MouseButtonEvent_: SDL_MouseButtonEvent: make struct! [
  type [char!] {*< SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP }
  which [char!] {*< The mouse device index }
  button [char!] {*< The mouse button index }
  state [char!] {*< SDL_PRESSED or SDL_RELEASED }
  x [short]  y [short] {*< The X/Y coordinates of the mouse at press time }
] none ;

{* Joystick axis motion event structure }
SDL_JoyAxisEvent_: SDL_JoyAxisEvent: make struct! [
  type [char!] {*< SDL_JOYAXISMOTION }
  which [char!] {*< The joystick device index }
  axis [char!] {*< The joystick axis index }
  value [short] {*< The axis value (range: -32768 to 32767) }
] none ;

{* Joystick trackball motion event structure }
SDL_JoyBallEvent_: SDL_JoyBallEvent: make struct! [
  type [char!] {*< SDL_JOYBALLMOTION }
  which [char!] {*< The joystick device index }
  ball [char!] {*< The joystick trackball index }
  xrel [short] {*< The relative motion in the X direction }
  yrel [short] {*< The relative motion in the Y direction }
] none ;

{* Joystick hat position change event structure }
SDL_JoyHatEvent_: SDL_JoyHatEvent: make struct! [
  type [char!] {*< SDL_JOYHATMOTION }
  which [char!] {*< The joystick device index }
  hat [char!] {*< The joystick hat index }
  value [char!] {*< The hat position value:
			 *   SDL_HAT_LEFTUP   SDL_HAT_UP       SDL_HAT_RIGHTUP
			 *   SDL_HAT_LEFT     SDL_HAT_CENTERED SDL_HAT_RIGHT
			 *   SDL_HAT_LEFTDOWN SDL_HAT_DOWN     SDL_HAT_RIGHTDOWN
			 *  Note that zero means the POV is centered.
			 }
] none ;

{* Joystick button event structure }
SDL_JoyButtonEvent_: SDL_JoyButtonEvent: make struct! [
  type [char!] {*< SDL_JOYBUTTONDOWN or SDL_JOYBUTTONUP }
  which [char!] {*< The joystick device index }
  button [char!] {*< The joystick button index }
  state [char!] {*< SDL_PRESSED or SDL_RELEASED }
] none ;

{* The "window resized" event
 *  When you get this event, you are responsible for setting a new video
 *  mode with the new width and height.
 }
SDL_ResizeEvent_: SDL_ResizeEvent: make struct! [
  type [char!] {*< SDL_VIDEORESIZE }
  w [integer!] {*< New width }
  h [integer!] {*< New height }
] none ;

{* The "screen redraw" event }
SDL_ExposeEvent_: SDL_ExposeEvent: make struct! [
  type [char!] {*< SDL_VIDEOEXPOSE }
] none ;

{* The "quit requested" event }
SDL_QuitEvent_: SDL_QuitEvent: make struct! [
  type [char!] {*< SDL_QUIT }
] none ;

{* A user-defined event type }
SDL_UserEvent_: SDL_UserEvent: make struct! [
  type [char!] {*< SDL_USEREVENT through SDL_NUMEVENTS-1 }
  code [integer!] {*< User defined event code }
  data1 [integer!] {*< User defined data pointer }
  data2 [integer!] {*< User defined data pointer }
] none ;

{* If you want to use this event, you should include SDL_syswm.h }
{struct SDL_SysWMmsg;
typedef struct SDL_SysWMmsg SDL_SysWMmsg;}
SDL_SysWMEvent_: SDL_SysWMEvent: make struct! [
  type [char!]
  msg [integer!]
] none ;

{* General event structure }
SDL_Event_: SDL_Event: make struct! [
  type [char!]
  active [struct! [
  type [char!] {*< SDL_ACTIVEEVENT }
  gain [char!] {*< Whether given states were gained or lost (1/0) }
  state [char!] {*< A mask of the focus states }
]]
  key [struct! [
  type [char!] {*< SDL_KEYDOWN or SDL_KEYUP }
  which [char!] {*< The keyboard device index }
  state [char!] {*< SDL_PRESSED or SDL_RELEASED }
  keysym [struct! [
	  scancode [char!] {*< hardware specific scancode }
	  sym [SDLKey] {*< SDL virtual keysym }
	  mod [SDLMod] {*< current key modifiers }
	  unicode [short] {*< translated character }
	]
 ]
]]
  motion [struct! [
  type [char!] {*< SDL_MOUSEMOTION }
  which [char!] {*< The mouse device index }
  state [char!] {*< The current button state }
  x [short]  y [short] {*< The X/Y coordinates of the mouse }
  xrel [short] {*< The relative motion in the X direction }
  yrel [short] {*< The relative motion in the Y direction }
]]
  button [struct! [
  type [char!] {*< SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP }
  which [char!] {*< The mouse device index }
  button [char!] {*< The mouse button index }
  state [char!] {*< SDL_PRESSED or SDL_RELEASED }
  x [short]  y [short] {*< The X/Y coordinates of the mouse at press time }
]]
  jaxis [struct! [
  type [char!] {*< SDL_JOYAXISMOTION }
  which [char!] {*< The joystick device index }
  axis [char!] {*< The joystick axis index }
  value [short] {*< The axis value (range: -32768 to 32767) }
]]
  jball [struct! [
  type [char!] {*< SDL_JOYBALLMOTION }
  which [char!] {*< The joystick device index }
  ball [char!] {*< The joystick trackball index }
  xrel [short] {*< The relative motion in the X direction }
  yrel [short] {*< The relative motion in the Y direction }
]]
  jhat [struct! [
  type [char!] {*< SDL_JOYHATMOTION }
  which [char!] {*< The joystick device index }
  hat [char!] {*< The joystick hat index }
  value [char!] {*< The hat position value:
			 *   SDL_HAT_LEFTUP   SDL_HAT_UP       SDL_HAT_RIGHTUP
			 *   SDL_HAT_LEFT     SDL_HAT_CENTERED SDL_HAT_RIGHT
			 *   SDL_HAT_LEFTDOWN SDL_HAT_DOWN     SDL_HAT_RIGHTDOWN
			 *  Note that zero means the POV is centered.
			 }
]]
  jbutton [struct! [
  type [char!] {*< SDL_JOYBUTTONDOWN or SDL_JOYBUTTONUP }
  which [char!] {*< The joystick device index }
  button [char!] {*< The joystick button index }
  state [char!] {*< SDL_PRESSED or SDL_RELEASED }
]]
  resize [struct! [
  type [char!] {*< SDL_VIDEORESIZE }
  w [integer!] {*< New width }
  h [integer!] {*< New height }
]]
  expose [struct! [
  type [char!] {*< SDL_VIDEOEXPOSE }
]]
  quit [struct! [
  type [char!] {*< SDL_QUIT }
]]
  user [struct! [
  type [char!] {*< SDL_USEREVENT through SDL_NUMEVENTS-1 }
  code [integer!] {*< User defined event code }
  data1 [integer!] {*< User defined data pointer }
  data2 [integer!] {*< User defined data pointer }
]]
  syswm [struct! [
  type [char!]
  msg [integer!]
]]
] none ;

{* General event structure }
SDL_Event_: SDL_Event: make struct! [
  type [char!]
  subtype [integer!]
  data1 [integer!]
  data2 [integer!]
] none

{* Pumps the event loop, gathering events from the input devices.
 *  This function updates the event queue and internal input device state.
 *  This should only be run in the thread that sets the video mode.
 }
SDL_PumpEvents: make routine! [ return: [integer!] ] SDL-lib "SDL_PumpEvents" 

SDL_ADDEVENT: 0
SDL_PEEKEVENT: 1
SDL_GETEVENT: 2

SDL_eventaction: integer!;

{*
 *  Checks the event queue for messages and optionally returns them.
 *
 *  If 'action' is SDL_ADDEVENT, up to 'numevents' events will be added to
 *  the back of the event queue.
 *  If 'action' is SDL_PEEKEVENT, up to 'numevents' events at the front
 *  of the event queue, matching 'mask', will be returned and will not
 *  be removed from the queue.
 *  If 'action' is SDL_GETEVENT, up to 'numevents' events at the front 
 *  of the event queue, matching 'mask', will be returned and will be
 *  removed from the queue.
 *
 *  @return
 *  This function returns the number of events actually stored, or -1
 *  if there was an error.
 *
 *  This function is thread-safe.
 }
SDL_PeepEvents: make routine! [ events [integer!] numevents [integer!]
 action [SDL_eventaction] mask [integer!] return: [integer!] ] SDL-lib "SDL_PeepEvents" 

 {* Polls for currently pending events, and returns 1 if there are any pending
 *  events, or 0 if there are none available.  If 'event' is not NULL, the next
 *  event is removed from the queue and stored in that area.
 }
SDL_PollEvent: make routine! [ event [struct! []] return: [integer!] ] SDL-lib "SDL_PollEvent" 

 {* Waits indefinitely for the next available event, returning 1, or 0 if there
 *  was an error while waiting for events.  If 'event' is not NULL, the next
 *  event is removed from the queue and stored in that area.
 }
SDL_WaitEvent: make routine! [ event [integer!] return: [integer!] ] SDL-lib "SDL_WaitEvent" 

 {* Add an event to the event queue.
 *  This function returns 0 on success, or -1 if the event queue was full
 *  or there was some other error.
 }
SDL_PushEvent: make routine! [ event [integer!] return: [integer!] ] SDL-lib "SDL_PushEvent" 

{* @name Event Filtering }

{typedef int (SDLCALL *SDL_EventFilter)(const SDL_Event *event);}
SDL_EventFilter: integer!
{*
 *  This function sets up a filter to process all events before they
 *  change internal state and are posted to the internal event queue.
 *
 *  The filter is protypted as:
 *      @code typedef int (SDLCALL *SDL_EventFilter)(const SDL_Event *event); @endcode
 *
 * If the filter returns 1, then the event will be added to the internal queue.
 * If it returns 0, then the event will be dropped from the queue, but the 
 * internal state will still be updated.  This allows selective filtering of
 * dynamically arriving events.
 *
 * @warning  Be very careful of what you do in the event filter function, as 
 *           it may run in a different thread!
 *
 * There is one caveat when dealing with the SDL_QUITEVENT event type.  The
 * event filter is only called when the window manager desires to close the
 * application window.  If the event filter returns 1, then the window will
 * be closed, otherwise the window will remain open if possible.
 * If the quit event is generated by an interrupt signal, it will bypass the
 * internal queue and be delivered to the application at the next event poll.
 }
SDL_SetEventFilter: make routine! [ filter [SDL_EventFilter] return: [integer!] ] SDL-lib "SDL_SetEventFilter" 

 {*
 *  Return the current event filter - can be used to "chain" filters.
 *  If there is no event filter set, this function returns NULL.
 }
SDL_GetEventFilter: make routine! [ return: [SDL_EventFilter] ] SDL-lib "SDL_GetEventFilter" 

{* @name Event State }
SDL_QUERY:	-1
SDL_IGNORE:	 0
SDL_DISABLE:	 0
SDL_ENABLE:	 1

{*
* This function allows you to set the state of processing certain events.
* If 'state' is set to SDL_IGNORE, that event will be automatically dropped
* from the event queue and will not event be filtered.
* If 'state' is set to SDL_ENABLE, that event will be processed normally.
* If 'state' is set to SDL_QUERY, SDL_EventState() will return the 
* current processing state of the specified event.
}
SDL_EventState: make routine! [ type [char!] state [integer!] return: [char!] ] SDL-lib "SDL_EventState" 

{* @file SDL_joystick.h
 *  @note In order to use these functions, SDL_Init() must have been called
 *        with the SDL_INIT_JOYSTICK flag.  This causes SDL to scan the system
 *        for joysticks, and load appropriate drivers.
 }

{* The joystick structure used to identify an SDL joystick }
{struct _SDL_Joystick;
typedef struct _SDL_Joystick SDL_Joystick;}

{*
 * Count the number of joysticks attached to the system
 }
SDL_NumJoysticks: make routine! [ return: [integer!] ] SDL-lib "SDL_NumJoysticks" 

 {*
 * Get the implementation dependent name of a joystick.
 *
 * This can be called before any joysticks are opened.
 * If no name can be found, this function returns NULL.
 }
SDL_JoystickName: make routine! [ device_index [integer!] return: [string!] ] SDL-lib "SDL_JoystickName" 

 {*
 * Open a joystick for use.
 *
 * @param[in] device_index
 * The index passed as an argument refers to
 * the N'th joystick on the system.  This index is the value which will
 * identify this joystick in future joystick events.
 *
 * @return This function returns a joystick identifier, or NULL if an error occurred.
 }
SDL_JoystickOpen: make routine! [ device_index [integer!] return: [integer!] ] SDL-lib "SDL_JoystickOpen" 

{*
 * Returns 1 if the joystick has been opened, or 0 if it has not.
 }
SDL_JoystickOpened: make routine! [ device_index [integer!] return: [integer!] ] SDL-lib "SDL_JoystickOpened" 

 {*
 * Get the device index of an opened joystick.
 }
SDL_JoystickIndex: make routine! [ joystick [integer!] return: [integer!] ] SDL-lib "SDL_JoystickIndex" 

 {*
 * Get the number of general axis controls on a joystick
 }
SDL_JoystickNumAxes: make routine! [ joystick [integer!] return: [integer!] ] SDL-lib "SDL_JoystickNumAxes" 

{*
 * Get the number of trackballs on a joystick
 *
 * Joystick trackballs have only relative motion events associated
 * with them and their state cannot be polled.
 }
SDL_JoystickNumBalls: make routine! [ joystick [integer!] return: [integer!] ] SDL-lib "SDL_JoystickNumBalls" 

 {*
 * Get the number of POV hats on a joystick
 }
SDL_JoystickNumHats: make routine! [ joystick [integer!] return: [integer!] ] SDL-lib "SDL_JoystickNumHats" 

 {*
 * Get the number of buttons on a joystick
 }
SDL_JoystickNumButtons: make routine! [ joystick [integer!] return: [integer!] ] SDL-lib "SDL_JoystickNumButtons" 

{*
 * Update the current state of the open joysticks.
 *
 * This is called automatically by the event loop if any joystick
 * events are enabled.
 }
SDL_JoystickUpdate: make routine! [ return: [integer!] ] SDL-lib "SDL_JoystickUpdate" 

 {*
 * Enable/disable joystick event polling.
 *
 * If joystick events are disabled, you must call SDL_JoystickUpdate()
 * yourself and check the state of the joystick when you want joystick
 * information.
 *
 * @param[in] state The state can be one of SDL_QUERY, SDL_ENABLE or SDL_IGNORE.
 }
SDL_JoystickEventState: make routine! [ state [integer!] return: [integer!] ] SDL-lib "SDL_JoystickEventState" 

{*
 * Get the current state of an axis control on a joystick
 *
 * @param[in] axis The axis indices start at index 0.
 *
 * @return The state is a value ranging from -32768 to 32767.
 }
SDL_JoystickGetAxis: make routine! [ joystick [struct! []] axis [integer!] return: [short] ] SDL-lib "SDL_JoystickGetAxis" 

{*
 *  @name Hat Positions
 *  The return value of SDL_JoystickGetHat() is one of the following positions:
 }

SDL_HAT_CENTERED:	0
SDL_HAT_UP:		1
SDL_HAT_RIGHT:		2
SDL_HAT_DOWN:		4
SDL_HAT_LEFT:		8
SDL_HAT_RIGHTUP:  SDL_HAT_RIGHT + SDL_HAT_UP 
SDL_HAT_RIGHTDOWN:  SDL_HAT_RIGHT + SDL_HAT_DOWN 
SDL_HAT_LEFTUP:  SDL_HAT_LEFT + SDL_HAT_UP 
SDL_HAT_LEFTDOWN:  SDL_HAT_LEFT + SDL_HAT_DOWN 

{* 
 *  Get the current state of a POV hat on a joystick
 *
 *  @param[in] hat The hat indices start at index 0.
 }
SDL_JoystickGetHat: make routine! [ joystick [integer!] hat [integer!] return: [char!] ] SDL-lib "SDL_JoystickGetHat" 

 {*
 * Get the ball axis change since the last poll
 *
 * @param[in] ball The ball indices start at index 0.
 *
 * @return This returns 0, or -1 if you passed it invalid parameters.
 }
SDL_JoystickGetBall: make routine! [ joystick [integer!] ball [integer!] dx [integer!] dy [integer!] return: [integer!] ] SDL-lib "SDL_JoystickGetBall" 

 {*
 * Get the current state of a button on a joystick
 *
 * @param[in] button The button indices start at index 0.
 }
SDL_JoystickGetButton: make routine! [ joystick [integer!] button [integer!] return: [char!] ] SDL-lib "SDL_JoystickGetButton" 

 {*
 * Close a joystick previously opened with SDL_JoystickOpen()
 }
SDL_JoystickClose: make routine! [ joystick [integer!] return: [integer!] ] SDL-lib "SDL_JoystickClose" 

{* @file SDL_loadso.h
 *  Some things to keep in mind:                                        
 *  - These functions only work on C function names.  Other languages may
 *    have name mangling and intrinsic language support that varies from
 *    compiler to compiler.
 *  - Make sure you declare your function pointers with the same calling
 *    convention as the actual library function.  Your code will crash
 *    mysteriously if you do not do this.
 *  - Avoid namespace collisions.  If you load a symbol from the library,
 *    it is not defined whether or not it goes into the global symbol
 *    namespace for the application.  If it does and it conflicts with
 *    symbols in your code or other shared libraries, you will not get
 *    the results you expect. :)
 }
{*
 * This function dynamically loads a shared object and returns a pointer
 * to the object handle (or NULL if there was an error).
 * The 'sofile' parameter is a system dependent name of the object file.
 }
SDL_LoadObject: make routine! [ sofile [string!] return: [integer!] ] SDL-lib "SDL_LoadObject" 

 {*
 * Given an object handle, this function looks up the address of the
 * named function in the shared object and returns it.  This address
 * is no longer valid after calling SDL_UnloadObject().
 }
SDL_LoadFunction: make routine! [ handle [integer!] name [string!] return: [integer!] ] SDL-lib "SDL_LoadFunction" 

 {* Unload a shared object from memory }
SDL_UnloadObject: make routine! [ handle [integer!] return: [integer!] ] SDL-lib "SDL_UnloadObject" 

{* @file SDL_main.h
 *  Redefine main() on Win32 and MacOS so that it is called by winmain.c
 }
{* The application's main() function must be called with C linkage,
 *  and should be declared like this:
 *      @code
 *      #ifdef __cplusplus
 *      extern "C"
 *      #endif
 *	int main(int argc, char *argv[])
 *	{
 *	}
 *      @endcode
 }

{* The prototype for the application's main() function }
;SDL_main: make routine! [ argc [integer!] argv [string!] return: [C_LINKAGE] ] SDL-lib "SDL_main" 

{* This should be called from your WinMain() function, if any }
;SDL_SetModuleHandle: make routine! [ hInst [integer!] return: [integer!] ] SDL-lib "SDL_SetModuleHandle" 
 {* This can also be called, but is no longer necessary }
;SDL_RegisterApp: make routine! [ name [string!] style [integer!] hInst [integer!] return: [integer!] ] SDL-lib "SDL_RegisterApp" 
 {* This can also be called, but is no longer necessary (SDL_Quit calls it) }
;SDL_UnregisterApp: make routine! [ return: [integer!] ] SDL-lib "SDL_UnregisterApp" 

{* Forward declaration so we don't need to include QuickDraw.h }
{struct QDGlobals;}

{* This should be called from your main() function, if any }
;SDL_InitQuickDraw: make routine! [ the_qd [integer!] return: [integer!] ] SDL-lib "SDL_InitQuickDraw" 

{typedef struct WMcursor WMcursor;}	{*< Implementation dependent }
SDL_Cursor_: SDL_Cursor: make struct! [
  area [struct! [
  x [short]  y [short]
  w [short]  h [short]
]] {*< The area of the mouse cursor }
  hot_x [short]  hot_y [short] {*< The "tip" of the cursor }
  data [integer!] {*< B/W cursor data }
  mask [integer!] {*< B/W cursor mask }
  save [struct! []] {[2]}{*< Place to save cursor area }
  wm_cursor [integer!] {*< Window-manager cursor }
] none ;

{*
 * Retrieve the current state of the mouse.
 * The current button state is returned as a button bitmask, which can
 * be tested using the SDL_BUTTON(X) macros, and x and y are set to the
 * current mouse cursor position.  You can pass NULL for either x or y.
 }
SDL_GetMouseState: make routine! [ x [integer!] y [integer!] return: [char!] ] SDL-lib "SDL_GetMouseState" 

 {*
 * Retrieve the current state of the mouse.
 * The current button state is returned as a button bitmask, which can
 * be tested using the SDL_BUTTON(X) macros, and x and y are set to the
 * mouse deltas since the last call to SDL_GetRelativeMouseState().
 }
SDL_GetRelativeMouseState: make routine! [ x [integer!] y [integer!] return: [char!] ] SDL-lib "SDL_GetRelativeMouseState" 

 {*
 * Set the position of the mouse cursor (generates a mouse motion event)
 }
SDL_WarpMouse: make routine! [ x [short] y [short] return: [integer!] ] SDL-lib "SDL_WarpMouse" 

 {*
 * Create a cursor using the specified data and mask (in MSB format).
 * The cursor width must be a multiple of 8 bits.
 *
 * The cursor is created in black and white according to the following:
 * data  mask    resulting pixel on screen
 *  0     1       White
 *  1     1       Black
 *  0     0       Transparent
 *  1     0       Inverted color if possible, black if not.
 *
 * Cursors created with this function must be freed with SDL_FreeCursor().
 }
SDL_CreateCursor: make routine! [
 data [integer!] mask [integer!] w [integer!] h [integer!] hot_x [integer!] hot_y [integer!] return: [integer!] ] SDL-lib "SDL_CreateCursor" 

 {*
 * Set the currently active cursor to the specified one.
 * If the cursor is currently visible, the change will be immediately 
 * represented on the display.
 }
SDL_SetCursor: make routine! [ cursor [integer!] return: [integer!] ] SDL-lib "SDL_SetCursor" 

 {*
 * Returns the currently active cursor.
 }
SDL_GetCursor: make routine! [ return: [integer!] ] SDL-lib "SDL_GetCursor" 

 {*
 * Deallocates a cursor created with SDL_CreateCursor().
 }
SDL_FreeCursor: make routine! [ cursor [integer!] return: [integer!] ] SDL-lib "SDL_FreeCursor" 

 {*
 * Toggle whether or not the cursor is shown on the screen.
 * The cursor start off displayed, but can be turned off.
 * SDL_ShowCursor() returns 1 if the cursor was being displayed
 * before the call, or 0 if it was not.  You can query the current
 * state by passing a 'toggle' value of -1.
 }
SDL_ShowCursor: make routine! [ toggle [integer!] return: [integer!] ] SDL-lib "SDL_ShowCursor" 

{* Used as a mask when testing buttons in buttonstate
 *  Button 1:	Left mouse button
 *  Button 2:	Middle mouse button
 *  Button 3:	Right mouse button
 *  Button 4:	Mouse wheel up	 (may also be a real button)
 *  Button 5:	Mouse wheel down (may also be a real button)
 }
SDL_BUTTON: func [X] [shift/left 1 X - 1]
SDL_BUTTON_LEFT:     1
SDL_BUTTON_MIDDLE:   2
SDL_BUTTON_RIGHT:    3
SDL_BUTTON_WHEELUP:  4
SDL_BUTTON_WHEELDOWN:    5
SDL_BUTTON_X1:       6
SDL_BUTTON_X2:       7
SDL_BUTTON_LMASK: SDL_BUTTON SDL_BUTTON_LEFT 
SDL_BUTTON_MMASK: SDL_BUTTON SDL_BUTTON_MIDDLE 
SDL_BUTTON_RMASK: SDL_BUTTON SDL_BUTTON_RIGHT 
SDL_BUTTON_X1MASK: SDL_BUTTON SDL_BUTTON_X1 
SDL_BUTTON_X2MASK: SDL_BUTTON SDL_BUTTON_X2 

{* @file SDL_mutex.h
 *  Functions to provide thread synchronization primitives
 *
 *  @note These are independent of the other SDL routines.
 }
{* Synchronization functions which can time out return this value
 *  if they time out.
 }
SDL_MUTEX_TIMEDOUT:	1

{* This is the timeout value which corresponds to never time out }
SDL_MUTEX_MAXWAIT: -1

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{* @name Mutex functions                                        } 
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

{* The SDL mutex structure, defined in SDL_mutex.c }
{struct SDL_mutex;
typedef struct SDL_mutex SDL_mutex;}

{* Create a mutex, initialized unlocked }
SDL_CreateMutex: make routine! [ return: [integer!] ] SDL-lib "SDL_CreateMutex" 

SDL_LockMutex: func [m] [SDL_mutexP m] 
{* Lock the mutex
 *  @return 0, or -1 on error
 }
SDL_mutexP: make routine! [ mutex [integer!] return: [integer!] ] SDL-lib "SDL_mutexP" 

SDL_UnlockMutex: func [m] [SDL_mutexV m] 
{* Unlock the mutex
 *  @return 0, or -1 on error
 *
 *  It is an error to unlock a mutex that has not been locked by
 *  the current thread, and doing so results in undefined behavior.
 }
SDL_mutexV: make routine! [ mutex [integer!] return: [integer!] ] SDL-lib "SDL_mutexV" 

 {* Destroy a mutex }
SDL_DestroyMutex: make routine! [ mutex [integer!] return: [integer!] ] SDL-lib "SDL_DestroyMutex" 

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{* @name Semaphore functions                                    } 
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

{* The SDL semaphore structure, defined in SDL_sem.c }
{struct SDL_semaphore;
typedef struct SDL_semaphore SDL_sem;}

{* Create a semaphore, initialized with value, returns NULL on failure. }
SDL_CreateSemaphore: make routine! [ initial_value [integer!] return: [integer!] ] SDL-lib "SDL_CreateSemaphore" 

 {* Destroy a semaphore }
SDL_DestroySemaphore: make routine! [ sem [integer!] return: [integer!] ] SDL-lib "SDL_DestroySemaphore" 

 {*
 * This function suspends the calling thread until the semaphore pointed 
 * to by sem has a positive count. It then atomically decreases the semaphore
 * count.
 }
SDL_SemWait: make routine! [ sem [integer!] return: [integer!] ] SDL-lib "SDL_SemWait" 

 {* Non-blocking variant of SDL_SemWait().
 *  @return 0 if the wait succeeds,
 *  SDL_MUTEX_TIMEDOUT if the wait would block, and -1 on error.
 }
SDL_SemTryWait: make routine! [ sem [integer!] return: [integer!] ] SDL-lib "SDL_SemTryWait" 

{* Variant of SDL_SemWait() with a timeout in milliseconds, returns 0 if
 *  the wait succeeds, SDL_MUTEX_TIMEDOUT if the wait does not succeed in
 *  the allotted time, and -1 on error.
 *
 *  On some platforms this function is implemented by looping with a delay
 *  of 1 ms, and so should be avoided if possible.
 }
SDL_SemWaitTimeout: make routine! [ sem [integer!] ms [integer!] return: [integer!] ] SDL-lib "SDL_SemWaitTimeout" 

{* Atomically increases the semaphore's count (not blocking).
 *  @return 0, or -1 on error.
 }
SDL_SemPost: make routine! [ sem [integer!] return: [integer!] ] SDL-lib "SDL_SemPost" 

 {* Returns the current count of the semaphore }
SDL_SemValue: make routine! [ sem [integer!] return: [integer!] ] SDL-lib "SDL_SemValue" 

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{* @name Condition_variable_functions                           } 
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

{* The SDL condition variable structure, defined in SDL_cond.c }
{struct SDL_cond;
typedef struct SDL_cond SDL_cond;}

{* Create a condition variable }
SDL_CreateCond: make routine! [ return: [integer!] ] SDL-lib "SDL_CreateCond" 

 {* Destroy a condition variable }
SDL_DestroyCond: make routine! [ cond [integer!] return: [integer!] ] SDL-lib "SDL_DestroyCond" 

 {* Restart one of the threads that are waiting on the condition variable,
 *  @return 0 or -1 on error.
 }
SDL_CondSignal: make routine! [ cond [integer!] return: [integer!] ] SDL-lib "SDL_CondSignal" 

 {* Restart all threads that are waiting on the condition variable,
 *  @return 0 or -1 on error.
 }
SDL_CondBroadcast: make routine! [ cond [integer!] return: [integer!] ] SDL-lib "SDL_CondBroadcast" 

 {* Wait on the condition variable, unlocking the provided mutex.
 *  The mutex must be locked before entering this function!
 *  The mutex is re-locked once the condition variable is signaled.
 *  @return 0 when it is signaled, or -1 on error.
 }
SDL_CondWait: make routine! [ cond [integer!] mut [integer!] return: [integer!] ] SDL-lib "SDL_CondWait" 

{* Waits for at most 'ms' milliseconds, and returns 0 if the condition
 *  variable is signaled, SDL_MUTEX_TIMEDOUT if the condition is not
 *  signaled in the allotted time, and -1 on error.
 *  On some platforms this function is implemented by looping with a delay
 *  of 1 ms, and so should be avoided if possible.
 }
SDL_CondWaitTimeout: make routine! [ cond [integer!] mutex [integer!] ms [integer!] return: [integer!] ] SDL-lib "SDL_CondWaitTimeout" 

SDL_NAME: func [X] [join "SDL_##" X]

{* @file SDL_quit.h
 *  Include file for SDL quit event handling
 }
{* @file SDL_quit.h
 *  An SDL_QUITEVENT is generated when the user tries to close the application
 *  window.  If it is ignored or filtered out, the window will remain open.
 *  If it is not ignored or filtered, it is queued normally and the window
 *  is allowed to close.  When the window is closed, screen updates will 
 *  complete, but have no effect.
 *
 *  SDL_Init() installs signal handlers for SIGINT (keyboard interrupt)
 *  and SIGTERM (system termination request), if handlers do not already
 *  exist, that generate SDL_QUITEVENT events as well.  There is no way
 *  to determine the cause of an SDL_QUITEVENT, but setting a signal
 *  handler in your application will override the default generation of
 *  quit events for that signal.
 }

{* @file SDL_quit.h
 *  There are no functions directly affecting the quit event 
 }
SDL_QuitRequested: func [] [SDL_PumpEvents    SDL_PeepEvents NULL 0 SDL_PEEKEVENT SDL_QUITMASK]  

{* @file SDL_rwops.h
 *  This file provides a general interface for SDL to read and write
 *  data sources.  It can easily be extended to files, memory, etc.
 }
{* This is the read/write operation structure -- very basic }

HAVE_STDIO_H: false

{typedef struct SDL_RWops ^{
	/** Seek to 'offset' relative to whence, one of stdio's whence values:
	 *	SEEK_SET, SEEK_CUR, SEEK_END
	 *  Returns the final offset in the data source.
	 */
	int (SDLCALL *seek)(struct SDL_RWops *context, int offset, int whence);

	/* Read up to 'maxnum' objects each of size 'size' from the data
	 *  source to the area pointed at by 'ptr'.
	 *  Returns the number of objects read, or -1 if the read failed.
	 */
	int (SDLCALL *read)(struct SDL_RWops *context, void *ptr, int size, int maxnum);

	/* Write exactly 'num' objects each of size 'objsize' from the area
	 *  pointed at by 'ptr' to data source.
	 *  Returns 'num', or -1 if the write failed.
	 */
	int (SDLCALL *write)(struct SDL_RWops *context, const void *ptr, int size, int num);

	/* Close and free an allocated SDL_FSops structure */
	int (SDLCALL *close)(struct SDL_RWops *context);

	Uint32 type;
	union ^{
#if defined(__WIN32__) && !defined(__SYMBIAN32__)
	    struct ^{
		int   append;
		void *h;
		struct ^{
		    void *data;
		    int size;
		    int left;
		^} buffer;
	    ^} win32io;
#endif
#ifdef HAVE_STDIO_H 
	    struct ^{
		int autoclose;
	 	FILE *fp;
	    ^} stdio;
#endif
	    struct ^{
		Uint8 *base;
	 	Uint8 *here;
		Uint8 *stop;
	    ^} mem;
	    struct ^{
		void *data1;
	    ^} unknown;
	^} hidden;

^} SDL_RWops;

}
{* @name Functions to create SDL_RWops structures from various data sources }
SDL_RWFromFile: make routine! [ file [string!] mode [string!] return: [integer!] ] SDL-lib "SDL_RWFromFile" 

if HAVE_STDIO_H [
SDL_RWFromFP: make routine! [ fp [integer!] autoclose [integer!] return: [integer!] ] SDL-lib "SDL_RWFromFP" 
]

SDL_RWFromMem: make routine! [ mem [integer!] size [integer!] return: [integer!] ] SDL-lib "SDL_RWFromMem" 
SDL_RWFromConstMem: make routine! [ mem [integer!] size [integer!] return: [integer!] ] SDL-lib "SDL_RWFromConstMem" 
SDL_AllocRW: make routine! [ return: [integer!] ] SDL-lib "SDL_AllocRW" 
SDL_FreeRW: make routine! [ area [integer!] return: [integer!] ] SDL-lib "SDL_FreeRW" 

{* @name Seek Reference Points }
RW_SEEK_SET:	0	{*< Seek from the beginning of data }
RW_SEEK_CUR:	1	{*< Seek relative to current read point }
RW_SEEK_END:	2	{*< Seek relative to the end of data }

{* @name Macros to easily read and write from an SDL_RWops structure }
SDL_RWseek: func [ctx  offset  whence]	[ctx/seek ctx  offset  whence]
SDL_RWtell: func [ctx] [ctx/seek ctx 0 RW_SEEK_CUR]
SDL_RWread: func [ctx ptr size n] [ctx/read ctx ptr size n]
SDL_RWwrite: func [ctx ptr size n] [ctx/write ctx ptr size n]
SDL_RWclose: func [ctx] [ctx/close ctx]

{* @name Read an item of the specified endianness and return in native format }
SDL_ReadLE16: make routine! [ src [integer!] return: [short] ] SDL-lib "SDL_ReadLE16" 
SDL_ReadBE16: make routine! [ src [integer!] return: [short] ] SDL-lib "SDL_ReadBE16" 
SDL_ReadLE32: make routine! [ src [integer!] return: [integer!] ] SDL-lib "SDL_ReadLE32" 
SDL_ReadBE32: make routine! [ src [integer!] return: [integer!] ] SDL-lib "SDL_ReadBE32" 
SDL_ReadLE64: make routine! [ src [integer!] return: [decimal!] ] SDL-lib "SDL_ReadLE64" 
SDL_ReadBE64: make routine! [ src [integer!] return: [decimal!] ] SDL-lib "SDL_ReadBE64" 
 
 {* @name Write an item of native format to the specified endianness }
 
SDL_WriteLE16: make routine! [ dst [integer!] value [short] return: [integer!] ] SDL-lib "SDL_WriteLE16" 
SDL_WriteBE16: make routine! [ dst [integer!] value [short] return: [integer!] ] SDL-lib "SDL_WriteBE16" 
SDL_WriteLE32: make routine! [ dst [integer!] value [integer!] return: [integer!] ] SDL-lib "SDL_WriteLE32" 
SDL_WriteBE32: make routine! [ dst [integer!] value [integer!] return: [integer!] ] SDL-lib "SDL_WriteBE32" 
SDL_WriteLE64: make routine! [ dst [integer!] value [decimal!] return: [integer!] ] SDL-lib "SDL_WriteLE64" 
SDL_WriteBE64: make routine! [ dst [integer!] value [decimal!] return: [integer!] ] SDL-lib "SDL_WriteBE64" 

{* The number of elements in an array }
SDL_arraysize: func [array] [(length? array) / length? first array]
SDL_TABLESIZE: func [table] [SDL_arraysize table] 

{* @name Basic data types }
SDL_FALSE: 0
SDL_TRUE: 1

SDL_bool: integer!;
{
typedef int8_t		Sint8;
typedef uint8_t		Uint8;
typedef int16_t		Sint16;
typedef uint16_t	Uint16;
typedef int32_t		Sint32;
typedef uint32_t	Uint32;
}

{#ifdef SDL_HAS_64BIT_TYPE
typedef int64_t		Sint64;
#ifndef SYMBIAN32_GCCE
typedef uint64_t	Uint64;
#endif
#else}
{ This is really just a hack to prevent the compiler from complaining }
{typedef struct {
	Uint32 hi;
	Uint32 lo;
} Uint64, Sint64;
#endif
}

{* @name Make sure the types really have the right sizes }

{#define SDL_COMPILE_TIME_ASSERT(name, x)               \
       typedef int SDL_dummy_ ## name[(x) * 2 - 1]

SDL_COMPILE_TIME_ASSERT(uint8, sizeof(Uint8) == 1);
SDL_COMPILE_TIME_ASSERT(sint8, sizeof(Sint8) == 1);
SDL_COMPILE_TIME_ASSERT(uint16, sizeof(Uint16) == 2);
SDL_COMPILE_TIME_ASSERT(sint16, sizeof(Sint16) == 2);
SDL_COMPILE_TIME_ASSERT(uint32, sizeof(Uint32) == 4);
SDL_COMPILE_TIME_ASSERT(sint32, sizeof(Sint32) == 4);
SDL_COMPILE_TIME_ASSERT(uint64, sizeof(Uint64) == 8);
SDL_COMPILE_TIME_ASSERT(sint64, sizeof(Sint64) == 8);}

size_t: integer!
{SDL_malloc: make routine! [ size [size_t] return: [integer!] ] SDL-lib "SDL_malloc" 
SDL_calloc: make routine! [ nmemb [size_t] size [size_t] return: [integer!] ] SDL-lib "SDL_calloc" 
SDL_realloc: make routine! [ mem [integer!] size [size_t] return: [integer!] ] SDL-lib "SDL_realloc" 
SDL_free: make routine! [ mem [integer!] return: [integer!] ] SDL-lib "SDL_free" 
SDL_stack_alloc: func [type  count]      [SDL_malloc (length? type) * count]  
SDL_stack_free: func [data] [SDL_free data] }

if system/version/4 = 3 [
SDL_getenv: make routine! [ name [string!] return: [string!] ] SDL-lib "SDL_getenv" 
SDL_putenv: make routine! [ variable [string!] return: [integer!] ] SDL-lib "SDL_putenv" 
]

{SDL_qsort: make routine! [ base [integer!] nmemb [size_t] size [size_t]
 compare [integer!] return: [integer!] ] SDL-lib "SDL_qsort"  ;int (*compare)(const void *, const void *));}

SDL_abs: :abs
SDL_min: :min
SDL_max: :max 
SDL_isdigit: func [X] [found? find charset "1234567890" any [X "-"]]
SDL_isspace: func [X] [found? find charset " ^-^/" any [X "-"]]
SDL_toupper: :uppercase
SDL_tolower: :lowercase
;SDL_memset: make routine! [ dst [integer!] c [integer!] len [size_t] return: [integer!] ] SDL-lib "SDL_memset" 
;SDL_memset4: :SDL_memset
{
#define SDL_memset4(dst, val, len)		\
do ^{						\
	unsigned _count = (len);		\
	unsigned _n = (_count + 3) / 4;		\
	Uint32 *_p = SDL_static_cast(Uint32 *, dst);	\
	Uint32 _val = (val);			\
	if (len == 0) break;			\
        switch (_count % 4) ^{			\
        case 0: do {    *_p++ = _val;		\
        case 3:         *_p++ = _val;		\
        case 2:         *_p++ = _val;		\
        case 1:         *_p++ = _val;		\
		} while ( --_n );		\
	^}					\
^} while(0)


SDL_memcpy: make routine! [ dst [integer!] src [integer!] len [size_t] return: [integer!] ] SDL-lib "SDL_memcpy" 
SDL_memcpy4: func [dst src len] [SDL_memcpy dst src len * 4] 
SDL_revcpy: make routine! [ dst [integer!] src [integer!] len [size_t] return: [integer!] ] SDL-lib "SDL_revcpy" 

SDL_memmove: func [dst src len] [
 either dst < src [
  SDL_memcpy dst src len
 ] [
 SDL_revcpy dst src len
 ]
] 
}
;SDL_memcmp: make routine! [ s1 [integer!] s2 [integer!] len [size_t] return: [integer!] ] SDL-lib "SDL_memcmp" 
;SDL_strlen: make routine! [ string [string!] return: [size_t] ] SDL-lib "SDL_strlen" 
SDL_strlcpy: make routine! [ dst [string!] src [string!] maxlen [size_t] return: [size_t] ] SDL-lib "SDL_strlcpy" 
SDL_strlcat: make routine! [ dst [string!] src [string!] maxlen [size_t] return: [size_t] ] SDL-lib "SDL_strlcat" 
{
SDL_strdup: make routine! [ string [string!] return: [string!] ] SDL-lib "SDL_strdup" 
SDL_strrev: make routine! [ string [string!] return: [string!] ] SDL-lib "SDL_strrev" 
SDL_strupr: make routine! [ string [string!] return: [string!] ] SDL-lib "SDL_strupr" 
SDL_strlwr: make routine! [ string [string!] return: [string!] ] SDL-lib "SDL_strlwr" 
SDL_strchr: make routine! [ string [string!] c [integer!] return: [string!] ] SDL-lib "SDL_strchr" 
SDL_strrchr: make routine! [ string [string!] c [integer!] return: [string!] ] SDL-lib "SDL_strrchr" 
SDL_strstr: make routine! [ haystack [string!] needle [string!] return: [string!] ] SDL-lib "SDL_strstr" 
SDL_ltoa: make routine! [ value [integer!] string [string!] radix [integer!] return: [string!] ] SDL-lib "SDL_ltoa"
SDL_itoa: :SDL_ltoa 
SDL_ultoa: make routine! [ value [integer!] string [string!] radix [integer!] return: [string!] ] SDL-lib "SDL_ultoa" 
SDL_uitoa: :SDL_ultoa
SDL_strtol: make routine! [ string [string!] endp [string!] base [integer!] return: [integer!] ] SDL-lib "SDL_strtol" 
SDL_strtoul: make routine! [ string [string!] endp [string!] base [integer!] return: [integer!] ] SDL-lib "SDL_strtoul" 


if SDL_HAS_64BIT_TYPE > 0 [
SDL_lltoa: make routine! [ value [decimal!] string [string!] radix [integer!] return: [string!] ] SDL-lib "SDL_lltoa" 
SDL_ulltoa: make routine! [ value [decimal!] string [string!] radix [integer!] return: [string!] ] SDL-lib "SDL_ulltoa" 
SDL_strtoll: make routine! [ string [string!] endp [string!] base [integer!] return: [decimal!] ] SDL-lib "SDL_strtoll" 
SDL_strtoull: make routine! [ string [string!] endp [string!] base [integer!] return: [decimal!] ] SDL-lib "SDL_strtoull" 
] 
SDL_atoi: func [X] [SDL_strtol X 0 0] 
SDL_strtod: make routine! [ string [string!] endp [string!] return: [double] ] SDL-lib "SDL_strtod" 
SDL_atof: func [X] [SDL_strtod X 0] 
SDL_strcmp: make routine! [ str1 [string!] str2 [string!] return: [integer!] ] SDL-lib "SDL_strcmp" 
SDL_strncmp: make routine! [ str1 [string!] str2 [string!] maxlen [size_t] return: [integer!] ] SDL-lib "SDL_strncmp" 
SDL_strcasecmp: make routine! [ str1 [string!] str2 [string!] return: [integer!] ] SDL-lib "SDL_strcasecmp" 
SDL_strncasecmp: make routine! [ str1 [string!] str2 [string!] maxlen [size_t] return: [integer!] ] SDL-lib "SDL_strncasecmp" 
SDL_sscanf: make routine! [ text [string!] fmt [string!] return: [integer!] ] SDL-lib "SDL_sscanf" {,...} 
SDL_snprintf: make routine! [ text [string!] maxlen [size_t] fmt [string!] return: [integer!] ] SDL-lib "SDL_snprintf" {,...} 
SDL_vsnprintf: make routine! [ text [string!] maxlen [size_t] fmt [string!] ap [va_list] return: [integer!] ] SDL-lib "SDL_vsnprintf" 
}

{* @file SDL_version.h
 *  This header defines the current SDL version
 }

{* @name Version Number
 *  Printable format: "%d.%d.%d", MAJOR, MINOR, PATCHLEVEL
 }

SDL_MAJOR_VERSION:	1
SDL_MINOR_VERSION:	2
SDL_PATCHLEVEL:		14

SDL_version_: SDL_version: make struct! [
  major [char!]
  minor [char!]
  patch [char!]
] none ;

{*
 * This macro can be used to fill a version structure with the compile-time
 * version of the SDL library.
 }
SDL_VERSION: func [X]
[									
	 X/major: SDL_MAJOR_VERSION					
	 X/minor: SDL_MINOR_VERSION					
	 X/patch: SDL_PATCHLEVEL					
]

{* This macro turns the version numbers into a numeric value:
 *  (1,2,3) -> (1203)
 *  This assumes that there will never be more than 100 patchlevels
 }
SDL_VERSIONNUM: func [X Y Z] [X * 1000 + Y * 100 + Z]

{* This is the version number macro for the current SDL version }
SDL_COMPILEDVERSION: does [SDL_VERSIONNUM SDL_MAJOR_VERSION  SDL_MINOR_VERSION  SDL_PATCHLEVEL] 

{* This macro will evaluate to true if compiled with SDL at least X.Y.Z }
SDL_VERSION_ATLEAST: func [X  Y  Z]   [SDL_COMPILEDVERSION >= (SDL_VERSIONNUM X  Y  Z)]  

{* This function gets the version of the dynamically linked SDL library.
 *  it should NOT be used to fill a version structure, instead you should
 *  use the SDL_Version() macro.
 }
SDL_Linked_Version: make routine! [ return: [integer!] ] SDL-lib "SDL_Linked_Version" 

{* @name SDL_ICONV Error Codes
 *  The SDL implementation of iconv() returns these error codes 
 }
SDL_ICONV_ERROR:		-1
SDL_ICONV_E2BIG:		-2
SDL_ICONV_EILSEQ:	-3
SDL_ICONV_EINVAL:	-4

{
typedef struct _SDL_iconv_t *SDL_iconv_t;}
if system/version/4 = 3 [
SDL_iconv_open: make routine! [ tocode [string!] fromcode [string!] return: [integer!] ] SDL-lib "SDL_iconv_open" 
SDL_iconv_close: make routine! [ cd [integer!] return: [integer!] ] SDL-lib "SDL_iconv_close" 
]
SDL_iconv: make routine! [ cd [integer!] inbuf [integer!] inbytesleft [integer!] outbuf [integer!] outbytesleft [integer!] return: [size_t] ] SDL-lib "SDL_iconv" 
{* This function converts a string between encodings in one pass, returning a
 *  string that must be freed with SDL_free() or NULL on error.
 }
SDL_iconv_string: make routine! [ tocode [string!] fromcode [string!] inbuf [string!] inbytesleft [size_t] return: [string!] ] SDL-lib "SDL_iconv_string" 
SDL_iconv_utf8_locale: func [S] [SDL_iconv_string ""  "UTF-8"  S  SDL_strlen S + 1 ]
SDL_iconv_utf8_ucs2: func [S] [SDL_iconv_string "UCS-2"  "UTF-8"  S  SDL_strlen S + 1 ]
SDL_iconv_utf8_ucs4: func [S] [SDL_iconv_string "UCS-4"  "UTF-8"  S  SDL_strlen S + 1 ]

{
/* @file SDL_syswm.h
 *  Your application has access to a special type of event 'SDL_SYSWMEVENT',
 *  which contains window-manager specific information and arrives whenever
 *  an unhandled window event occurs.  This event is ignored by default, but
 *  you can enable it with SDL_EventState()
 */
#ifdef SDL_PROTOTYPES_ONLY
struct SDL_SysWMinfo;
typedef struct SDL_SysWMinfo SDL_SysWMinfo;
#else

/* This is the structure for custom window manager events */
#if defined(SDL_VIDEO_DRIVER_X11)
#if defined(__APPLE__) && defined(__MACH__)
/* conflicts with Quickdraw.h */
#define Cursor X11Cursor
#endif

#include <X11/Xlib.h>
#include <X11/Xatom.h>

#if defined(__APPLE__) && defined(__MACH__)
/* matches the re-define above */
#undef Cursor
#endif

/* These are the various supported subsystems under UNIX */
typedef enum ^{
	SDL_SYSWM_X11
^} SDL_SYSWM_TYPE;

/* The UNIX custom event structure */
struct SDL_SysWMmsg ^{
	SDL_version version;
	SDL_SYSWM_TYPE subsystem;
	union ^{
	    XEvent xevent;
	^} event;
^};

/* The UNIX custom window manager information structure.
 *  When this structure is returned, it holds information about which
 *  low level system it is using, and will be one of SDL_SYSWM_TYPE.
 */
typedef struct SDL_SysWMinfo ^{
	SDL_version version;
	SDL_SYSWM_TYPE subsystem;
	union ^{
	    struct ^{
	    	Display *display;	/*< The X11 display */
	    	Window window;		/*< The X11 display window */
		/* These locking functions should be called around
                 *  any X11 functions using the display variable, 
                 *  but not the gfxdisplay variable.
                 *  They lock the event thread, so should not be
		 *  called around event functions or from event filters.
		 */
                
		void (*lock_func)();
		void (*unlock_func)();
                

		/* @name Introduced in SDL 1.0.2 */
                
	    	Window fswindow;	/*< The X11 fullscreen window */
	    	Window wmwindow;	/*< The X11 managed input window */
                

		/* @name Introduced in SDL 1.2.12 */
                
		Display *gfxdisplay;	/*< The X11 display to which rendering is done */
                
	    ^} x11;
	^} info;
^} SDL_SysWMinfo;

#elif defined(SDL_VIDEO_DRIVER_NANOX)
#include <microwin/nano-X.h>

/* The generic custom event structure */
struct SDL_SysWMmsg ^{
	SDL_version version;
	int data;
^};

/* The windows custom window manager information structure */
typedef struct SDL_SysWMinfo ^{
	SDL_version version ;
	GR_WINDOW_ID window ;	/* The display window */
^} SDL_SysWMinfo;

#elif defined(SDL_VIDEO_DRIVER_WINDIB) || defined(SDL_VIDEO_DRIVER_DDRAW) || defined(SDL_VIDEO_DRIVER_GAPI)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

/* The windows custom event structure */
struct SDL_SysWMmsg ^{
	SDL_version version;
	HWND hwnd;			/*< The window for the message */
	UINT msg;			/*< The type of message */
	WPARAM wParam;			/*< WORD message parameter */
	LPARAM lParam;			/*< LONG message parameter */
^};

/* The windows custom window manager information structure */
typedef struct SDL_SysWMinfo ^{
	SDL_version version;
	HWND window;			/*< The Win32 display window */
	HGLRC hglrc;			/*< The OpenGL context, if any */
^} SDL_SysWMinfo;


#else
}

{ The generic custom event structure }
SDL_SysWMmsg: make struct! [
  version [struct! [
  major [char!]
  minor [char!]
  patch [char!]
]]
  data [integer!]
] none ;

{ The generic custom window manager information structure }
SDL_SysWMinfo_: SDL_SysWMinfo: make struct! [
  version [struct! [
  major [char!]
  minor [char!]
  patch [char!]
]]
  data [integer!]
] none ;

{
#endif /* video driver type */

#endif /* SDL_PROTOTYPES_ONLY */

}



{*
 * This function gives you custom hooks into the window manager information.
 * It fills the structure pointed to by 'info' with custom information and
 * returns 1 if the function is implemented.  If it's not implemented, or
 * the version member of the 'info' structure is invalid, it returns 0. 
 *
 * You typically use this function like this:
 * @code
 * SDL_SysWMInfo info;
 * SDL_VERSION(&info.version);
 * if ( SDL_GetWMInfo(&info) ) { ... }
 * @endcode
 }
SDL_GetWMInfo: make routine! [ info [integer!] return: [integer!] ] SDL-lib "SDL_GetWMInfo" 

{* The SDL thread structure, defined in SDL_thread.c }
{struct SDL_Thread;
typedef struct SDL_Thread SDL_Thread;}

{* Create a thread }
{*
 *  We compile SDL into a DLL on OS/2. This means, that it's the DLL which
 *  creates a new thread for the calling process with the SDL_CreateThread()
 *  API. There is a problem with this, that only the RTL of the SDL.DLL will
 *  be initialized for those threads, and not the RTL of the calling application!
 *  To solve this, we make a little hack here.
 *  We'll always use the caller's _beginthread() and _endthread() APIs to
 *  start a new thread. This way, if it's the SDL.DLL which uses this API,
 *  then the RTL of SDL.DLL will be used to create the new thread, and if it's
 *  the application, then the RTL of the application will be used.
 *  So, in short:
 *  Always use the _beginthread() and _endthread() of the calling runtime library!
 }
SDL_CreateThread: make routine! [ fn [integer!] data [integer!] return: [integer!] ] SDL-lib "SDL_CreateThread" 

{* Get the 32-bit thread identifier for the current thread }
SDL_ThreadID: make routine! [ return: [integer!] ] SDL-lib "SDL_ThreadID" 

 {* Get the 32-bit thread identifier for the specified thread,
 *  equivalent to SDL_ThreadID() if the specified thread is NULL.
 }
SDL_GetThreadID: make routine! [ thread [integer!] return: [integer!] ] SDL-lib "SDL_GetThreadID" 

 {* Wait for a thread to finish.
 *  The return code for the thread function is placed in the area
 *  pointed to by 'status', if 'status' is not NULL.
 }
SDL_WaitThread: make routine! [ thread [integer!] status [integer!] return: [integer!] ] SDL-lib "SDL_WaitThread" 

 {* Forcefully kill a thread without worrying about its state }
SDL_KillThread: make routine! [ thread [integer!] return: [integer!] ] SDL-lib "SDL_KillThread" 

{* @file SDL_timer.h
 *  Header for the SDL time management routines
 }
{* This is the OS scheduler timeslice, in milliseconds }
SDL_TIMESLICE:		10

{* This is the maximum resolution of the SDL timer on all platforms }
TIMER_RESOLUTION:	10	{*< Experimentally determined }

{*
 * Get the number of milliseconds since the SDL library initialization.
 * Note that this value wraps if the program runs for more than ~49 days.
 } 
SDL_GetTicks: make routine! [ return: [integer!] ] SDL-lib "SDL_GetTicks" 

 {* Wait a specified number of milliseconds before returning }
SDL_Delay: make routine! [ ms [integer!] return: [integer!] ] SDL-lib "SDL_Delay" 

{* Function prototype for the timer callback function }
{typedef Uint32 (SDLCALL *SDL_TimerCallback)(Uint32 interval);}

{*
 * Set a callback to run after the specified number of milliseconds has
 * elapsed. The callback function is passed the current timer interval
 * and returns the next timer interval.  If the returned value is the 
 * same as the one passed in, the periodic alarm continues, otherwise a
 * new alarm is scheduled.  If the callback returns 0, the periodic alarm
 * is cancelled.
 *
 * To cancel a currently running timer, call SDL_SetTimer(0, NULL);
 *
 * The timer callback function may run in a different thread than your
 * main code, and so shouldn't call any functions from within itself.
 *
 * The maximum resolution of this timer is 10 ms, which means that if
 * you request a 16 ms timer, your callback will run approximately 20 ms
 * later on an unloaded system.  If you wanted to set a flag signaling
 * a frame update at 30 frames per second (every 33 ms), you might set a 
 * timer for 30 ms:
 *   @code SDL_SetTimer((33/10)*10, flag_update); @endcode
 *
 * If you use this function, you need to pass SDL_INIT_TIMER to SDL_Init().
 *
 * Under UNIX, you should not use raise or use SIGALRM and this function
 * in the same program, as it is implemented using setitimer().  You also
 * should not use this function in multi-threaded applications as signals
 * to multi-threaded apps have undefined behavior in some implementations.
 *
 * This function returns 0 if successful, or -1 if there was an error.
 }
SDL_SetTimer: make routine! [ interval [integer!] callback [integer!] return: [integer!] ] SDL-lib "SDL_SetTimer" 

{* @name New timer API
 * New timer API, supports multiple timers
 * Written by Stephane Peter <megastep@lokigames.com>
 }
{*
 * Function prototype for the new timer callback function.
 * The callback function is passed the current timer interval and returns
 * the next timer interval.  If the returned value is the same as the one
 * passed in, the periodic alarm continues, otherwise a new alarm is
 * scheduled.  If the callback returns 0, the periodic alarm is cancelled.
 }
{typedef Uint32 (SDLCALL *SDL_NewTimerCallback)(Uint32 interval, void *param);}

{* Definition of the timer ID type }
{typedef struct _SDL_TimerID *SDL_TimerID;}

{* Add a new timer to the pool of timers already running.
 *  Returns a timer ID, or NULL when an error occurs.
 }
SDL_AddTimer: make routine! [ interval [integer!] callback [integer!] param [integer!] return: [integer!] ] SDL-lib "SDL_AddTimer" 

 {*
 * Remove one of the multiple timers knowing its ID.
 * Returns a boolean value indicating success.
 }
SDL_RemoveTimer: make routine! [ t [integer!] return: [SDL_bool] ] SDL-lib "SDL_RemoveTimer" 

{* @name Transparency definitions
 *  These define alpha as the opacity of a surface
 }

SDL_ALPHA_OPAQUE: 255
SDL_ALPHA_TRANSPARENT: 0


{* Available for SDL_SetVideoMode() }
SDL_ANYFORMAT:	268435456	{*< Allow any video depth/pixel-format }
SDL_HWPALETTE:	536870912	{*< Surface has exclusive palette }
SDL_DOUBLEBUF:	1073741824	{*< Set up double-buffered video mode }
SDL_FULLSCREEN:	-2147483648	{*< Surface is a full screen display }
SDL_OPENGL:      2      {*< Create an OpenGL rendering context }
SDL_OPENGLBLIT:	10	{*< Create an OpenGL rendering context and use it for blitting }
SDL_RESIZABLE:	16	{*< This video mode may be resized }
SDL_NOFRAME:	32	{*< No window caption or edge frame }

{* Used internally (read-only) }
SDL_HWACCEL:	256	{*< Blit uses hardware acceleration }
SDL_SRCCOLORKEY:	4096	{*< Blit uses a source color key }
SDL_RLEACCELOK:	8192	{*< Private flag }
SDL_RLEACCEL:	16384	{*< Surface is RLE encoded }
SDL_SRCALPHA:	65536	{*< Blit uses source alpha blending }
SDL_PREALLOC:	16777216	{*< Surface uses preallocated memory }

{* Evaluates to true if the surface needs to be locked before access }
SDL_MUSTLOCK: func [surface] [any[surface/offset ((surface/flags and (SDL_HWSURFACE or SDL_ASYNCBLIT or SDL_RLEACCEL)) )]]

{* typedef for private surface blitting functions }
{typedef int (*SDL_blit)(struct SDL_Surface *src, SDL_Rect *srcrect,
			struct SDL_Surface *dst, SDL_Rect *dstrect);}

{* Useful for determining the video hardware capabilities }
SDL_hw_available: 1 {*< Flag: Can you create hardware surfaces? }
SDL_wm_available: 2 {*< Flag: Can you talk to a window manager? }
SDL_UnusedBits1:  0 {6 bits}
SDL_UnusedBits2:  256
SDL_blit_hw:      512 {*< Flag: Accelerated blits HW --> HW }
SDL_blit_hw_CC:   1024 {*< Flag: Accelerated blits with Colorkey }
SDL_blit_hw_A:    2048 {*< Flag: Accelerated blits with Alpha }
SDL_blit_sw:      4096 {*< Flag: Accelerated blits SW --> HW }
SDL_blit_sw_CC:   8192 {*< Flag: Accelerated blits with Colorkey }
SDL_blit_sw_A:    16384 {*< Flag: Accelerated blits with Alpha }
SDL_blit_fill:    327768 {*< Flag: Accelerated color fill }
SDL_VideoInfo_: SDL_VideoInfo: make struct! [
  Bits [short]
  UnusedBits3 [short] {:16;}
  video_mem [integer!] {*< The total amount of video memory (in K) }
  vfmt [integer!] {*< Value: The format of the video surface }
  current_w [integer!] {*< Value: The current video mode width }
  current_h [integer!] {*< Value: The current video mode height }
] none ;

{* @name Overlay Formats
 *  The most common video overlay formats.
 *  For an explanation of these pixel formats, see:
 *	http:;www.webartz.com/fourcc/indexyuv.htm
 *
 *  For information on the relationship between color spaces, see:
 *  http:;www.neuro.sfc.keio.ac.jp/~aly/polygon/info/color-space-faq.html
 }
SDL_YV12_OVERLAY:  842094169	{*< Planar mode: Y + V + U  (3 planes) }
SDL_IYUV_OVERLAY:  1448433993	{*< Planar mode: Y + U + V  (3 planes) }
SDL_YUY2_OVERLAY:  844715353	{*< Packed mode: Y0+U0+Y1+V0 (1 plane) }
SDL_UYVY_OVERLAY:  1498831189	{*< Packed mode: U0+Y0+V0+Y1 (1 plane) }
SDL_YVYU_OVERLAY:  1431918169	{*< Packed mode: Y0+V0+Y1+U0 (1 plane) }

{* The YUV hardware video overlay }
SDL_Overlay_: SDL_Overlay: make struct! [
  format [integer!] {*< Read-only }
  w [integer!]  h [integer!] {*< Read-only }
  planes [integer!] {*< Read-only }
  pitches [integer!] {*< Read-only }
  pixels [integer!] {*< Read-write }

 {* @name Hardware-specific surface info }
  hwfuncs [integer!]
  hwdata [integer!]

 {* @name Special flags }
 {Uint32 hw_overlay :1;} {*< Flag: This overlay hardware accelerated? }
 {Uint32 UnusedBits :31;}
  hw_overlay [integer!]
 
] none ;

{* Public enumeration for setting the OpenGL window attributes. }
SDL_GL_RED_SIZE: 0
SDL_GL_GREEN_SIZE: 1
SDL_GL_BLUE_SIZE: 2
SDL_GL_ALPHA_SIZE: 3
SDL_GL_BUFFER_SIZE: 4
SDL_GL_DOUBLEBUFFER: 5
SDL_GL_DEPTH_SIZE: 6
SDL_GL_STENCIL_SIZE: 7
SDL_GL_ACCUM_RED_SIZE: 8
SDL_GL_ACCUM_GREEN_SIZE: 9
SDL_GL_ACCUM_BLUE_SIZE: 10
SDL_GL_ACCUM_ALPHA_SIZE: 11
SDL_GL_STEREO: 12
SDL_GL_MULTISAMPLEBUFFERS: 13
SDL_GL_MULTISAMPLESAMPLES: 14
SDL_GL_ACCELERATED_VISUAL: 15
SDL_GL_SWAP_CONTROL: 16

SDL_GLattr: integer!;

{* @name flags for SDL_SetPalette() }
SDL_LOGPAL: 1
SDL_PHYSPAL: 2

{*
 * @name Video Init and Quit
 * These functions are used internally, and should not be used unless you
 * have a specific need to specify the video driver you want to use.
 * You should normally use SDL_Init() or SDL_InitSubSystem().
 }
{*
 * Initializes the video subsystem. Sets up a connection
 * to the window manager, etc, and determines the current video mode and
 * pixel format, but does not initialize a window or graphics mode.
 * Note that event handling is activated by this routine.
 *
 * If you use both sound and video in your application, you need to call
 * SDL_Init() before opening the sound device, otherwise under Win32 DirectX,
 * you won't be able to set full-screen display modes.
 }
SDL_VideoInit: make routine! [ driver_name [string!] flags [integer!] return: [integer!] ] SDL-lib "SDL_VideoInit" 
SDL_VideoQuit: make routine! [ return: [integer!] ] SDL-lib "SDL_VideoQuit" 
 
 {*
 * This function fills the given character buffer with the name of the
 * video driver, and returns a pointer to it if the video driver has
 * been initialized.  It returns NULL if no driver has been initialized.
 }
SDL_VideoDriverName: make routine! [ namebuf [string!] maxlen [integer!] return: [string!] ] SDL-lib "SDL_VideoDriverName" 

 {*
 * This function returns a pointer to the current display surface.
 * If SDL is doing format conversion on the display surface, this
 * function returns the publicly visible surface, not the real video
 * surface.
 }
SDL_GetVideoSurface: make routine! [ return: [integer!] ] SDL-lib "SDL_GetVideoSurface" 

 {*
 * This function returns a read-only pointer to information about the
 * video hardware.  If this is called before SDL_SetVideoMode(), the 'vfmt'
 * member of the returned structure will contain the pixel format of the
 * "best" video mode.
 }
SDL_GetVideoInfo: make routine! [ return: [integer!] ] SDL-lib "SDL_GetVideoInfo" 

 {*
 * Check to see if a particular video mode is supported.
 * It returns 0 if the requested mode is not supported under any bit depth,
 * or returns the bits-per-pixel of the closest available mode with the
 * given width and height.  If this bits-per-pixel is different from the
 * one used when setting the video mode, SDL_SetVideoMode() will succeed,
 * but will emulate the requested bits-per-pixel with a shadow surface.
 *
 * The arguments to SDL_VideoModeOK() are the same ones you would pass to
 * SDL_SetVideoMode()
 }
SDL_VideoModeOK: make routine! [ width [integer!] height [integer!] bpp [integer!] flags [integer!] return: [integer!] ] SDL-lib "SDL_VideoModeOK" 

{*
 * Return a pointer to an array of available screen dimensions for the
 * given format and video flags, sorted largest to smallest.  Returns 
 * NULL if there are no dimensions available for a particular format, 
 * or (SDL_Rect **)-1 if any dimension is okay for the given format.
 *
 * If 'format' is NULL, the mode list will be for the format given 
 * by SDL_GetVideoInfo()->vfmt
 }
SDL_ListModes: make routine! [ format [integer!] flags [integer!] return: [integer!] ] SDL-lib "SDL_ListModes" 

{*
 * Set up a video mode with the specified width, height and bits-per-pixel.
 *
 * If 'bpp' is 0, it is treated as the current display bits per pixel.
 *
 * If SDL_ANYFORMAT is set in 'flags', the SDL library will try to set the
 * requested bits-per-pixel, but will return whatever video pixel format is
 * available.  The default is to emulate the requested pixel format if it
 * is not natively available.
 *
 * If SDL_HWSURFACE is set in 'flags', the video surface will be placed in
 * video memory, if possible, and you may have to call SDL_LockSurface()
 * in order to access the raw framebuffer.  Otherwise, the video surface
 * will be created in system memory.
 *
 * If SDL_ASYNCBLIT is set in 'flags', SDL will try to perform rectangle
 * updates asynchronously, but you must always lock before accessing pixels.
 * SDL will wait for updates to complete before returning from the lock.
 *
 * If SDL_HWPALETTE is set in 'flags', the SDL library will guarantee
 * that the colors set by SDL_SetColors() will be the colors you get.
 * Otherwise, in 8-bit mode, SDL_SetColors() may not be able to set all
 * of the colors exactly the way they are requested, and you should look
 * at the video surface structure to determine the actual palette.
 * If SDL cannot guarantee that the colors you request can be set, 
 * i.e. if the colormap is shared, then the video surface may be created
 * under emulation in system memory, overriding the SDL_HWSURFACE flag.
 *
 * If SDL_FULLSCREEN is set in 'flags', the SDL library will try to set
 * a fullscreen video mode.  The default is to create a windowed mode
 * if the current graphics system has a window manager.
 * If the SDL library is able to set a fullscreen video mode, this flag 
 * will be set in the surface that is returned.
 *
 * If SDL_DOUBLEBUF is set in 'flags', the SDL library will try to set up
 * two surfaces in video memory and swap between them when you call 
 * SDL_Flip().  This is usually slower than the normal single-buffering
 * scheme, but prevents "tearing" artifacts caused by modifying video 
 * memory while the monitor is refreshing.  It should only be used by 
 * applications that redraw the entire screen on every update.
 *
 * If SDL_RESIZABLE is set in 'flags', the SDL library will allow the
 * window manager, if any, to resize the window at runtime.  When this
 * occurs, SDL will send a SDL_VIDEORESIZE event to you application,
 * and you must respond to the event by re-calling SDL_SetVideoMode()
 * with the requested size (or another size that suits the application).
 *
 * If SDL_NOFRAME is set in 'flags', the SDL library will create a window
 * without any title bar or frame decoration.  Fullscreen video modes have
 * this flag set automatically.
 *
 * This function returns the video framebuffer surface, or NULL if it fails.
 *
 * If you rely on functionality provided by certain video flags, check the
 * flags of the returned surface to make sure that functionality is available.
 * SDL will fall back to reduced functionality if the exact flags you wanted
 * are not available.
 }
SDL_SetVideoMode: make routine! [
 width [integer!] height [integer!] bpp [integer!] flags [integer!] return: [integer!] ] SDL-lib "SDL_SetVideoMode" 

{* @name SDL_Update Functions
 * These functions should not be called while 'screen' is locked.
 }
{*
 * Makes sure the given list of rectangles is updated on the given screen.
 }
SDL_UpdateRects: make routine! [
 screen [integer!] numrects [integer!] rects [integer!] return: [integer!] ] SDL-lib "SDL_UpdateRects" 
 {*
 * If 'x', 'y', 'w' and 'h' are all 0, SDL_UpdateRect will update the entire
 * screen.
 }
SDL_UpdateRect: make routine! [
 screen [integer!] x [integer!] y [integer!] w [integer!] h [integer!] return: [integer!] ] SDL-lib "SDL_UpdateRect" 
 
 {*
 * On hardware that supports double-buffering, this function sets up a flip
 * and returns.  The hardware will wait for vertical retrace, and then swap
 * video buffers before the next video surface blit or lock will return.
 * On hardware that doesn not support double-buffering, this is equivalent
 * to calling SDL_UpdateRect(screen, 0, 0, 0, 0);
 * The SDL_DOUBLEBUF flag must have been passed to SDL_SetVideoMode() when
 * setting the video mode for this function to perform hardware flipping.
 * This function returns 0 if successful, or -1 if there was an error.
 }
SDL_Flip: make routine! [ screen [integer!] return: [integer!] ] SDL-lib "SDL_Flip" 

{*
 * Set the gamma correction for each of the color channels.
 * The gamma values range (approximately) between 0.1 and 10.0
 * 
 * If this function isn't supported directly by the hardware, it will
 * be emulated using gamma ramps, if available.  If successful, this
 * function returns 0, otherwise it returns -1.
 }
SDL_SetGamma: make routine! [ red [float] green [float] blue [float] return: [integer!] ] SDL-lib "SDL_SetGamma" 

 {*
 * Set the gamma translation table for the red, green, and blue channels
 * of the video hardware.  Each table is an array of 256 16-bit quantities,
 * representing a mapping between the input and output for that channel.
 * The input is the index into the array, and the output is the 16-bit
 * gamma value at that index, scaled to the output color precision.
 * 
 * You may pass NULL for any of the channels to leave it unchanged.
 * If the call succeeds, it will return 0.  If the display driver or
 * hardware does not support gamma translation, or otherwise fails,
 * this function will return -1.
 }
SDL_SetGammaRamp: make routine! [ red [integer!] green [integer!] blue [integer!] return: [integer!] ] SDL-lib "SDL_SetGammaRamp" 

 {*
 * Retrieve the current values of the gamma translation tables.
 * 
 * You must pass in valid pointers to arrays of 256 16-bit quantities.
 * Any of the pointers may be NULL to ignore that channel.
 * If the call succeeds, it will return 0.  If the display driver or
 * hardware does not support gamma translation, or otherwise fails,
 * this function will return -1.
 }
SDL_GetGammaRamp: make routine! [ red [integer!] green [integer!] blue [integer!] return: [integer!] ] SDL-lib "SDL_GetGammaRamp" 

{*
 * Sets a portion of the colormap for the given 8-bit surface.  If 'surface'
 * is not a palettized surface, this function does nothing, returning 0.
 * If all of the colors were set as passed to SDL_SetColors(), it will
 * return 1.  If not all the color entries were set exactly as given,
 * it will return 0, and you should look at the surface palette to
 * determine the actual color palette.
 *
 * When 'surface' is the surface associated with the current display, the
 * display colormap will be updated with the requested colors.  If 
 * SDL_HWPALETTE was set in SDL_SetVideoMode() flags, SDL_SetColors()
 * will always return 1, and the palette is guaranteed to be set the way
 * you desire, even if the window colormap has to be warped or run under
 * emulation.
 }
SDL_SetColors: make routine! [ surface [integer!]
 colors [integer!] firstcolor [integer!] ncolors [integer!] return: [integer!] ] SDL-lib "SDL_SetColors" 

 {*
 * Sets a portion of the colormap for a given 8-bit surface.
 * 'flags' is one or both of:
 * SDL_LOGPAL  -- set logical palette, which controls how blits are mapped
 *                to/from the surface,
 * SDL_PHYSPAL -- set physical palette, which controls how pixels look on
 *                the screen
 * Only screens have physical palettes. Separate change of physical/logical
 * palettes is only possible if the screen has SDL_HWPALETTE set.
 *
 * The return value is 1 if all colours could be set as requested, and 0
 * otherwise.
 *
 * SDL_SetColors() is equivalent to calling this function with
 *     flags = (SDL_LOGPAL|SDL_PHYSPAL).
 }
SDL_SetPalette: make routine! [ surface [integer!] flags [integer!]
 colors [integer!] firstcolor [integer!]
 ncolors [integer!] return: [integer!] ] SDL-lib "SDL_SetPalette" 

{*
 * Maps an RGB triple to an opaque pixel value for a given pixel format
 }
SDL_MapRGB: make routine! [
 format [integer!]
 r [char!] g [char!] b [char!] return: [integer!] ] SDL-lib "SDL_MapRGB" 

 {*
 * Maps an RGBA quadruple to a pixel value for a given pixel format
 }
SDL_MapRGBA: make routine! [
 format [integer!]
 r [char!] g [char!] b [char!] a [char!] return: [integer!] ] SDL-lib "SDL_MapRGBA" 

{*
 * Maps a pixel value into the RGB components for a given pixel format
 }
SDL_GetRGB: make routine! [ pixel [integer!]
 fmt [struct! []]
 r [struct! []] g [struct! []] b [struct! []] return: [integer!] ] SDL-lib "SDL_GetRGB" 

 {*
 * Maps a pixel value into the RGBA components for a given pixel format
 }
SDL_GetRGBA: make routine! [ pixel [integer!]
 fmt [struct! []]
 r [struct! []] g [struct! []] b [struct! []] a [struct! []] return: [integer!] ] SDL-lib "SDL_GetRGBA" 

{* @sa SDL_CreateRGBSurface }
{*
 * Allocate and free an RGB surface (must be called after SDL_SetVideoMode)
 * If the depth is 4 or 8 bits, an empty palette is allocated for the surface.
 * If the depth is greater than 8 bits, the pixel format is set using the
 * flags '[RGB]mask'.
 * If the function runs out of memory, it will return NULL.
 *
 * The 'flags' tell what kind of surface to create.
 * SDL_SWSURFACE means that the surface should be created in system memory.
 * SDL_HWSURFACE means that the surface should be created in video memory,
 * with the same format as the display surface.  This is useful for surfaces
 * that will not change much, to take advantage of hardware acceleration
 * when being blitted to the display surface.
 * SDL_ASYNCBLIT means that SDL will try to perform asynchronous blits with
 * this surface, but you must always lock it before accessing the pixels.
 * SDL will wait for current blits to finish before returning from the lock.
 * SDL_SRCCOLORKEY indicates that the surface will be used for colorkey blits.
 * If the hardware supports acceleration of colorkey blits between
 * two surfaces in video memory, SDL will try to place the surface in
 * video memory. If this isn't possible or if there is no hardware
 * acceleration available, the surface will be placed in system memory.
 * SDL_SRCALPHA means that the surface will be used for alpha blits and 
 * if the hardware supports hardware acceleration of alpha blits between
 * two surfaces in video memory, to place the surface in video memory
 * if possible, otherwise it will be placed in system memory.
 * If the surface is created in video memory, blits will be _much_ faster,
 * but the surface format must be identical to the video surface format,
 * and the only way to access the pixels member of the surface is to use
 * the SDL_LockSurface() and SDL_UnlockSurface() calls.
 * If the requested surface actually resides in video memory, SDL_HWSURFACE
 * will be set in the flags member of the returned surface.  If for some
 * reason the surface could not be placed in video memory, it will not have
 * the SDL_HWSURFACE flag set, and will be created in system memory instead.
 }
SDL_CreateRGBSurface: make routine! [
 flags [integer!] width [integer!] height [integer!] depth [integer!]
 Rmask [integer!] Gmask [integer!] Bmask [integer!] Amask [integer!] return: [integer!] ] SDL-lib "SDL_CreateRGBSurface" 
 {* @sa SDL_CreateRGBSurface }
SDL_CreateRGBSurfaceFrom: make routine! [ pixels [integer!]
 width [integer!] height [integer!] depth [integer!] pitch [integer!]
 Rmask [integer!] Gmask [integer!] Bmask [integer!] Amask [integer!] return: [integer!] ] SDL-lib "SDL_CreateRGBSurfaceFrom" 
SDL_FreeSurface: make routine! [ surface [integer!] return: [integer!] ] SDL-lib "SDL_FreeSurface" 

SDL_AllocSurface:    :SDL_CreateRGBSurface

{*
 * SDL_LockSurface() sets up a surface for directly accessing the pixels.
 * Between calls to SDL_LockSurface()/SDL_UnlockSurface(), you can write
 * to and read from 'surface->pixels', using the pixel format stored in 
 * 'surface->format'.  Once you are done accessing the surface, you should 
 * use SDL_UnlockSurface() to release it.
 *
 * Not all surfaces require locking.  If SDL_MUSTLOCK(surface) evaluates
 * to 0, then you can read and write to the surface at any time, and the
 * pixel format of the surface will not change.  In particular, if the
 * SDL_HWSURFACE flag is not given when calling SDL_SetVideoMode(), you
 * will not need to lock the display surface before accessing it.
 * 
 * No operating system or library calls should be made between lock/unlock
 * pairs, as critical system locks may be held during this time.
 *
 * SDL_LockSurface() returns 0, or -1 if the surface couldn't be locked.
 }
SDL_LockSurface: make routine! [ surface [integer!] return: [integer!] ] SDL-lib "SDL_LockSurface" 
SDL_UnlockSurface: make routine! [ surface [integer!] return: [integer!] ] SDL-lib "SDL_UnlockSurface" 

 {*
 * Load a surface from a seekable SDL data source (memory or file.)
 * If 'freesrc' is non-zero, the source will be closed after being read.
 * Returns the new surface, or NULL if there was an error.
 * The new surface should be freed with SDL_FreeSurface().
 }
SDL_LoadBMP_RW: make routine! [ src [integer!] freesrc [integer!] return: [integer!] ] SDL-lib "SDL_LoadBMP_RW" 

{* Convenience macro -- load a surface from a file }
SDL_LoadBMP: func [file] [SDL_LoadBMP_RW SDL_RWFromFile file "rb" 1]

{*
 * Save a surface to a seekable SDL data source (memory or file.)
 * If 'freedst' is non-zero, the source will be closed after being written.
 * Returns 0 if successful or -1 if there was an error.
 }
SDL_SaveBMP_RW: make routine! [
 surface [integer!] dst [integer!] freedst [integer!] return: [integer!] ] SDL-lib "SDL_SaveBMP_RW" 

{* Convenience macro -- save a surface to a file }
SDL_SaveBMP: func [surface file] [SDL_SaveBMP_RW surface SDL_RWFromFile file "wb" 1]

{*
 * Sets the color key (transparent pixel) in a blittable surface.
 * If 'flag' is SDL_SRCCOLORKEY (optionally OR'd with SDL_RLEACCEL), 
 * 'key' will be the transparent pixel in the source image of a blit.
 * SDL_RLEACCEL requests RLE acceleration for the surface if present,
 * and removes RLE acceleration if absent.
 * If 'flag' is 0, this function clears any current color key.
 * This function returns 0, or -1 if there was an error.
 }
SDL_SetColorKey: make routine! [
 surface [integer!] flag [integer!] key [integer!] return: [integer!] ] SDL-lib "SDL_SetColorKey" 

 {*
 * This function sets the alpha value for the entire surface, as opposed to
 * using the alpha component of each pixel. This value measures the range
 * of transparency of the surface, 0 being completely transparent to 255
 * being completely opaque. An 'alpha' value of 255 causes blits to be
 * opaque, the source pixels copied to the destination (the default). Note
 * that per-surface alpha can be combined with colorkey transparency.
 *
 * If 'flag' is 0, alpha blending is disabled for the surface.
 * If 'flag' is SDL_SRCALPHA, alpha blending is enabled for the surface.
 * OR:ing the flag with SDL_RLEACCEL requests RLE acceleration for the
 * surface; if SDL_RLEACCEL is not specified, the RLE accel will be removed.
 *
 * The 'alpha' parameter is ignored for surfaces that have an alpha channel.
 }
SDL_SetAlpha: make routine! [ surface [integer!] flag [integer!] alpha [char!] return: [integer!] ] SDL-lib "SDL_SetAlpha" 

 {*
 * Sets the clipping rectangle for the destination surface in a blit.
 *
 * If the clip rectangle is NULL, clipping will be disabled.
 * If the clip rectangle doesn't intersect the surface, the function will
 * return SDL_FALSE and blits will be completely clipped.  Otherwise the
 * function returns SDL_TRUE and blits to the surface will be clipped to
 * the intersection of the surface area and the clipping rectangle.
 *
 * Note that blits are automatically clipped to the edges of the source
 * and destination surfaces.
 }
SDL_SetClipRect: make routine! [ surface [integer!] rect [integer!] return: [SDL_bool] ] SDL-lib "SDL_SetClipRect" 

{*
 * Gets the clipping rectangle for the destination surface in a blit.
 * 'rect' must be a pointer to a valid rectangle which will be filled
 * with the correct values.
 }
SDL_GetClipRect: make routine! [ surface [integer!] rect [integer!] return: [integer!] ] SDL-lib "SDL_GetClipRect" 

 {*
 * Creates a new surface of the specified format, and then copies and maps 
 * the given surface to it so the blit of the converted surface will be as 
 * fast as possible.  If this function fails, it returns NULL.
 *
 * The 'flags' parameter is passed to SDL_CreateRGBSurface() and has those 
 * semantics.  You can also pass SDL_RLEACCEL in the flags parameter and
 * SDL will try to RLE accelerate colorkey and alpha blits in the resulting
 * surface.
 *
 * This function is used internally by SDL_DisplayFormat().
 }
SDL_ConvertSurface: make routine! [
 src [integer!] fmt [integer!] flags [integer!] return: [integer!] ] SDL-lib "SDL_ConvertSurface" 

{*
 * This performs a fast blit from the source surface to the destination
 * surface.  It assumes that the source and destination rectangles are
 * the same size.  If either 'srcrect' or 'dstrect' are NULL, the entire
 * surface (src or dst) is copied.  The final blit rectangles are saved
 * in 'srcrect' and 'dstrect' after all clipping is performed.
 * If the blit is successful, it returns 0, otherwise it returns -1.
 *
 * The blit function should not be called on a locked surface.
 *
 * The blit semantics for surfaces with and without alpha and colorkey
 * are defined as follows:
 *
 * RGBA->RGB:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using alpha-channel).
 * 	SDL_SRCCOLORKEY ignored.
 *     SDL_SRCALPHA not set:
 * 	copy RGB.
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	RGB values of the source colour key, ignoring alpha in the
 * 	comparison.
 * 
 * RGB->RGBA:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using the source per-surface alpha value);
 * 	set destination alpha to opaque.
 *     SDL_SRCALPHA not set:
 * 	copy RGB, set destination alpha to source per-surface alpha value.
 *     both:
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	source colour key.
 * 
 * RGBA->RGBA:
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using the source alpha channel) the RGB values;
 * 	leave destination alpha untouched. [Note: is this correct?]
 * 	SDL_SRCCOLORKEY ignored.
 *     SDL_SRCALPHA not set:
 * 	copy all of RGBA to the destination.
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	RGB values of the source colour key, ignoring alpha in the
 * 	comparison.
 * 
 * RGB->RGB: 
 *     SDL_SRCALPHA set:
 * 	alpha-blend (using the source per-surface alpha value).
 *     SDL_SRCALPHA not set:
 * 	copy RGB.
 *     both:
 * 	if SDL_SRCCOLORKEY set, only copy the pixels matching the
 * 	source colour key.
 *
 * If either of the surfaces were in video memory, and the blit returns -2,
 * the video memory was lost, so it should be reloaded with artwork and 
 * re-blitted:
 * @code
 *	while ( SDL_BlitSurface(image, imgrect, screen, dstrect) == -2 ) {
 *		while ( SDL_LockSurface(image) < 0 )
 *			Sleep(10);
 *		-- Write image pixels to image->pixels --
 *		SDL_UnlockSurface(image);
 *	}
 * @endcode
 *
 * This happens under DirectX 5.0 when the system switches away from your
 * fullscreen application.  The lock will also fail until you have access
 * to the video memory again.
 *
 * You should call SDL_BlitSurface() unless you know exactly how SDL
 * blitting works internally and how to use the other blit functions.
 }

{* This is the public blit function, SDL_BlitSurface(), and it performs
 *  rectangle validation and clipping before passing it to SDL_LowerBlit()
 }
SDL_UpperBlit: make routine! [
 src [integer!] srcrect [integer!]
 dst [integer!] dstrect [integer!] return: [integer!] ] SDL-lib "SDL_UpperBlit" 
 {* This is a semi-private blit function and it performs low-level surface
 *  blitting only.
 }
SDL_LowerBlit: make routine! [
 src [integer!] srcrect [integer!]
 dst [integer!] dstrect [integer!] return: [integer!] ] SDL-lib "SDL_LowerBlit" 

SDL_BlitSurface: :SDL_UpperBlit

{*
 * This function performs a fast fill of the given rectangle with 'color'
 * The given rectangle is clipped to the destination surface clip area
 * and the final fill rectangle is saved in the passed in pointer.
 * If 'dstrect' is NULL, the whole surface will be filled with 'color'
 * The color should be a pixel of the format used by the surface, and 
 * can be generated by the SDL_MapRGB() function.
 * This function returns 0 on success, or -1 on error.
 }
SDL_FillRect: make routine! [
 dst [integer!] dstrect [integer!] color [integer!] return: [integer!] ] SDL-lib "SDL_FillRect" 

 {*
 * This function takes a surface and copies it to a new surface of the
 * pixel format and colors of the video framebuffer, suitable for fast
 * blitting onto the display surface.  It calls SDL_ConvertSurface()
 *
 * If you want to take advantage of hardware colorkey or alpha blit
 * acceleration, you should set the colorkey and alpha value before
 * calling this function.
 *
 * If the conversion fails or runs out of memory, it returns NULL
 }
SDL_DisplayFormat: make routine! [ surface [integer!] return: [integer!] ] SDL-lib "SDL_DisplayFormat" 

{*
 * This function takes a surface and copies it to a new surface of the
 * pixel format and colors of the video framebuffer (if possible),
 * suitable for fast alpha blitting onto the display surface.
 * The new surface will always have an alpha channel.
 *
 * If you want to take advantage of hardware colorkey or alpha blit
 * acceleration, you should set the colorkey and alpha value before
 * calling this function.
 *
 * If the conversion fails or runs out of memory, it returns NULL
 }
SDL_DisplayFormatAlpha: make routine! [ surface [integer!] return: [integer!] ] SDL-lib "SDL_DisplayFormatAlpha" 

 { * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
 {* @name YUV video surface overlay functions                                } 
 { * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

 {* This function creates a video output overlay
 *  Calling the returned surface an overlay is something of a misnomer because
 *  the contents of the display surface underneath the area where the overlay
 *  is shown is undefined - it may be overwritten with the converted YUV data.
 }
SDL_CreateYUVOverlay: make routine! [ width [integer!] height [integer!]
 format [integer!] display [integer!] return: [integer!] ] SDL-lib "SDL_CreateYUVOverlay" 

 {* Lock an overlay for direct access, and unlock it when you are done }
SDL_LockYUVOverlay: make routine! [ overlay [integer!] return: [integer!] ] SDL-lib "SDL_LockYUVOverlay" 
SDL_UnlockYUVOverlay: make routine! [ overlay [integer!] return: [integer!] ] SDL-lib "SDL_UnlockYUVOverlay" 

{* Blit a video overlay to the display surface.
 *  The contents of the video surface underneath the blit destination are
 *  not defined.  
 *  The width and height of the destination rectangle may be different from
 *  that of the overlay, but currently only 2x scaling is supported.
 }
SDL_DisplayYUVOverlay: make routine! [ overlay [integer!] dstrect [integer!] return: [integer!] ] SDL-lib "SDL_DisplayYUVOverlay" 

 {* Free a video overlay }
SDL_FreeYUVOverlay: make routine! [ overlay [integer!] return: [integer!] ] SDL-lib "SDL_FreeYUVOverlay" 

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{* @name OpenGL support functions.                                          } 
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{*
 * Dynamically load an OpenGL library, or the default one if path is NULL
 *
 * If you do this, you need to retrieve all of the GL functions used in
 * your program from the dynamic library using SDL_GL_GetProcAddress().
 }
SDL_GL_LoadLibrary: make routine! [ path [string!] return: [integer!] ] SDL-lib "SDL_GL_LoadLibrary" 

{*
 * Get the address of a GL function
 }
SDL_GL_GetProcAddress: make routine! [ proc [string!] return: [integer!] ] SDL-lib "SDL_GL_GetProcAddress" 

 {*
 * Set an attribute of the OpenGL subsystem before intialization.
 }
SDL_GL_SetAttribute: make routine! [ attr [SDL_GLattr] value [integer!] return: [integer!] ] SDL-lib "SDL_GL_SetAttribute" 

{*
 * Get an attribute of the OpenGL subsystem from the windowing
 * interface, such as glX. This is of course different from getting
 * the values from SDL's internal OpenGL subsystem, which only
 * stores the values you request before initialization.
 *
 * Developers should track the values they pass into SDL_GL_SetAttribute
 * themselves if they want to retrieve these values.
 }
SDL_GL_GetAttribute: make routine! [ attr [SDL_GLattr] value [integer!] return: [integer!] ] SDL-lib "SDL_GL_GetAttribute" 

 {*
 * Swap the OpenGL buffers, if double-buffering is supported.
 }
SDL_GL_SwapBuffers: make routine! [ return: [integer!] ] SDL-lib "SDL_GL_SwapBuffers" 

 {* @name OpenGL Internal Functions
 * Internal functions that should not be called unless you have read
 * and understood the source code for these functions.
 }
 
SDL_GL_UpdateRects: make routine! [ numrects [integer!] rects [integer!] return: [integer!] ] SDL-lib "SDL_GL_UpdateRects" 
SDL_GL_Lock: make routine! [ return: [integer!] ] SDL-lib "SDL_GL_Lock" 
SDL_GL_Unlock: make routine! [ return: [integer!] ] SDL-lib "SDL_GL_Unlock" 

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{* @name Window Manager Functions                                           }
{* These functions allow interaction with the window manager, if any.       } 
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

{*
 * Sets the title and icon text of the display window (UTF-8 encoded)
 }
SDL_WM_SetCaption: make routine! [ title [string!] icon [string!] return: [integer!] ] SDL-lib "SDL_WM_SetCaption" 
{*
 * Gets the title and icon text of the display window (UTF-8 encoded)
 }
SDL_WM_GetCaption: make routine! [ title [struct! []] icon [struct! []] return: [integer!] ] SDL-lib "SDL_WM_GetCaption" 

{*
 * Sets the icon for the display window.
 * This function must be called before the first call to SDL_SetVideoMode().
 * It takes an icon surface, and a mask in MSB format.
 * If 'mask' is NULL, the entire icon surface will be used as the icon.
 }
SDL_WM_SetIcon: make routine! [ icon [integer!] mask [integer!] return: [integer!] ] SDL-lib "SDL_WM_SetIcon" 

 {*
 * This function iconifies the window, and returns 1 if it succeeded.
 * If the function succeeds, it generates an SDL_APPACTIVE loss event.
 * This function is a noop and returns 0 in non-windowed environments.
 }
SDL_WM_IconifyWindow: make routine! [ return: [integer!] ] SDL-lib "SDL_WM_IconifyWindow" 

{*
 * Toggle fullscreen mode without changing the contents of the screen.
 * If the display surface does not require locking before accessing
 * the pixel information, then the memory pointers will not change.
 *
 * If this function was able to toggle fullscreen mode (change from 
 * running in a window to fullscreen, or vice-versa), it will return 1.
 * If it is not implemented, or fails, it returns 0.
 *
 * The next call to SDL_SetVideoMode() will set the mode fullscreen
 * attribute based on the flags parameter - if SDL_FULLSCREEN is not
 * set, then the display will be windowed by default where supported.
 *
 * This is currently only implemented in the X11 video driver.
 }
SDL_WM_ToggleFullScreen: make routine! [ surface [integer!] return: [integer!] ] SDL-lib "SDL_WM_ToggleFullScreen" 

SDL_GRAB_QUERY: -1
SDL_GRAB_OFF: 0
SDL_GRAB_ON: 1
 {*< Used internally }
SDL_GRAB_FULLSCREEN: 2 {*< Used internally }
 {*< Used internally }
SDL_GrabMode: integer!;
{*
 * This function allows you to set and query the input grab state of
 * the application.  It returns the new input grab state.
 *
 * Grabbing means that the mouse is confined to the application window,
 * and nearly all keyboard input is passed directly to the application,
 * and not interpreted by a window manager, if any.
 }
SDL_WM_GrabInput: make routine! [ mode [SDL_GrabMode] return: [SDL_GrabMode] ] SDL-lib "SDL_WM_GrabInput" 

 {* @internal Not in public API at the moment - do not use! }
SDL_SoftStretch: make routine! [ src [integer!] srcrect [integer!]
 dst [integer!] dstrect [integer!] return: [integer!] ] SDL-lib "SDL_SoftStretch" 


;comment[ ;uncomment this and comment next line to comment example code
context [

	{===============================================================================================}

	{ Test the SDL CD-ROM audio functions }

	{ Call this instead of exit(), so we can clean up SDL: atexit() is evil. }
	quit*: func [rc] 
	[
		SDL_Quit
		halt
		quit/return rc 
	]

	PrintStatus: func [driveindex &cdrom /local cdrom status status_str m s f] 
	[
		status: SDL_CDStatus &cdrom 
		cdrom: addr-to-struct &cdrom SDL_CD ;REBOL-NOTE: function defined at the beginning
		switch (status) reduce [
			CD_TRAYEMPTY
				[status_str: "tray empty"]
				
			CD_STOPPED
				[status_str: "stopped"]
				
			CD_PLAYING
				[status_str: "playing"]
				
			CD_PAUSED
				[status_str: "paused"]
				
			CD_ERROR
				[status_str: "error state"]
				
		]
		print ["Drive" driveindex "status:" status_str] 
		if ( status >= CD_PLAYING ) [
			
			FRAMES_TO_MSF cdrom/cur_frame 'm 's 'f 
			print rejoin ["Currently playing track " to-integer cdrom/(track- cdrom/cur_track 'id) ", " m ":" round/to s 0.01]  
		]
	]

	ListTracks: func [&cdrom /local cdrom i m s f trtype]
	[
		SDL_CDStatus &cdrom 
		cdrom: addr-to-struct &cdrom SDL_CD
		print ["Drive tracks:" cdrom/numtracks] 
		for  i 0 (cdrom/numtracks - 1) 1 [
			FRAMES_TO_MSF cdrom/(track- i 'length) 'm 's 'f 
			if ( f > 0 ) [
				s: s + 1
			]
			switch/default to-integer cdrom/(track- i 'type) reduce
			[
			    SDL_AUDIO_TRACK
				[trtype: "audio"]			

			    SDL_DATA_TRACK
				[trtype: "data"]
			][			
				[trtype: "unknown"]
			]
			print rejoin ["^-Track (index " i ") " to-integer cdrom/(track- i 'id) ": " m ":" round/to s 0.01 " / " cdrom/(track- i 'length) " [" trtype " track]"]
		]
	]

	do PrintUsage: does
	[
		print "Usage:"
		print "Write one of:"
		print "	-drive <number>"
		print "	-status"
		print "	-list"
		print "	-play first_track first_frame num_tracks num_frames"
		print "	-pause"
		print "	-resume"
		print "	-stop"
		print "	-eject"
		print "	-sleep <milliseconds>"
		print "	-quit"
	]

	; main
	do
	[
		drive: 0
		i: 0
		cdrom: 0 ;SDL_CD *

		{ Initialize SDL first }
		if ( (SDL_Init SDL_INIT_CDROM) < 0 ) [
			print ["Couldn't initialize SDL:" SDL_GetError]
			halt
			;return 1 
		]

		{ Find out how many CD-ROM drives are connected to the system }
		if ( SDL_CDNumDrives = 0 ) [
			print "No CD-ROM devices detected" 
			quit* 0
		]
		print ["Drives available:" SDL_CDNumDrives]   
		for i 0 (SDL_CDNumDrives - 1) 1 [
			print rejoin ["Drive " i {: "} SDL_CDName i {"}]
		]
		{ Open the CD-ROM }
		drive: 0
		cdrom: SDL_CDOpen drive 
		if cdrom = 0   [
			print ["Couldn't open drive" drive ":" SDL_GetError]   
			quit* 2 
		]
		print "Current drive: 0"
		
		{ Find out which function to perform }
		until [
			prin "?:" ;REBOL-NOTE: prompt
			argv: input
			argv: parse argv none
			
			case [
				(argv/1 = "-drive") and SDL_isdigit argv/2 [
					drive: to-integer argv/2
					cdrom: SDL_CDOpen drive 
					if cdrom = 0   [
						print ["Couldn't open drive" drive ":" SDL_GetError]   
						quit* 2 
					]
				]
				( argv/1 = "-status") [
					PrintStatus drive cdrom
				]
				( argv/1 = "-list") [
					ListTracks cdrom
				]
				( argv/1 = "-play") [
					use [
					strack sframe
					ntrack nframe
					][
					i: 2
					strack: 0
					if ( SDL_isdigit argv/:i ) [
						strack: to-integer argv/:i i: i + 1
					]
					sframe: 0
					if ( SDL_isdigit argv/:i ) [
						sframe: to-integer argv/:i i: i + 1
					]
					ntrack: 0
					if ( SDL_isdigit argv/:i ) [
						ntrack: to-integer argv/:i i: i + 1
					]
					nframe: 0
					if ( SDL_isdigit argv/:i ) [
						nframe: to-integer argv/:i i: i + 1
					]
					either ( CD_INDRIVE SDL_CDStatus cdrom ) [
						if ( SDL_CDPlayTracks cdrom strack sframe
									ntrack nframe) < 0 [
							print rejoin [
					"Couldn't play tracks " strack "/" sframe " for " ntrack "/" nframe ": " SDL_GetError
							]
						]
					] [
						print "No CD in drive!"
					]
					] ;use
				]
				( argv/1 = "-pause" ) [
					if ( SDL_CDPause cdrom) < 0 [
						print ["Couldn't pause CD:" SDL_GetError]
					]
				]
				( argv/1 = "-resume") [
					if ( SDL_CDResume cdrom) < 0 [
						print ["Couldn't resume CD:" SDL_GetError]
					]
				]
				( argv/1 = "-stop") [
					if ( SDL_CDStop cdrom) < 0 [
						print ["Couldn't stop CD:" SDL_GetError]
					]
				]
				( argv/1 = "-eject") [
					if ( SDL_CDEject cdrom ) < 0 [
						print ["Couldn't eject CD:" SDL_GetError]
					]
				]
				( argv/1 = "-sleep") and SDL_isdigit argv/2 [
					SDL_Delay argv/2
					print ["Delayed" argv/2 "milliseconds"]
				]
				( argv/1 = "-quit" ) [
				]
				(true) [
					PrintUsage
				]
			] ;{case} 

			argv/1 = "-quit"
		] ; until
		PrintStatus drive cdrom 
		SDL_CDClose cdrom 

		SDL_Quit  

		0 
	]
	free SDL-lib
	halt
]
