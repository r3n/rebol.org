REBOL [
title: "Tiff Lib"
date: 2-Mar-2010
file: %tifflib.r
version: "1.0"
home: ""
author: "François Jouen"
rights: ""
needs: ""
Purpose: {A  basic library for reading and writing Tiff files}
comment: {This a basic library for reading and writing Tiff files. 
		 Only uncompressed RGB color and Palette color type files are actually supported.
		 Multipage files are also supported if RGB or Palette color.
		 Any Rebol image can be saved  as 24-bit color RGB Tiff}
History: [
		2004 <François Jouen> "Tiff tag processing"
		2006 <Marc Le Marchand> "improving data processing"
		2009 <François Jouen> "First version including Tiff files saving"
	]
	
library: [
        level: 'intermediate
        platform: 'all
        type: [tool ]
        domain: [file-handling]
        tested-under: all plateforms
        support: none
        license: 'BSD
        see-also: none
	]
]






{*
 * Tag Image File Format (TIFF)
 *
 * Based on Rev 6.0 from:
 *    Developer's Desk
 *    Aldus Corporation
 *    411 First Ave. South
 *    Suite 200
 *    Seattle, WA  98104
 *    206-622-5500
 */}




; list of tags 
Tiff_Tags: [
	; subfile data descriptor */ default 0
 	254 [NewSubfileType [
 		0 Default	
		1 ReducedImage 	; reduced resolution version */
		2 Page 	; one page of many */
		4 Mask 	; transparency mask */
	]]
	; +kind of data in subfile */
	255 [OldSubfileType [
		0 Default
	    1 FullImage 	; full resolution image data */
		2 ReducedImage 	; reduced size image data */
		3 Page ; one page of many */
	]]
	256 [ImageWidth]	; image width in pixels */
	257 [ImageLength] ; image height in pixels */		
	258 [BitsPerSample]		; bits per channel (sample) */
	; data compression technique */
	259 [Compression [			
		1 Uncompressed ; dump mode */
		2 CCITTRLE	; CCITT modified Huffman RLE */
		3 CCITT_T4       ; CCITT T.4 (TIFF 6 name) */
		4 CCITT_T  ; CCITT T.6 (TIFF 6 name) */
		5 LZW      ; Lempel-Ziv  & Welch */
		6 OJPEG	; !6.0 JPEG */
		7 JPEG			; %JPEG DCT compression */
		32766 NEXT			; NeXT 2-bit RLE */
		32771 CCITTRLEW		; #1 w/ word alignment */
		32773 PACKBITS		; Macintosh RLE */
		32809 THUNDERSCAN		; ThunderScan RLE */
		;; codes 32895-32898 are reserved for ANSI IT8 TIFF/IT <dkelly@apago.com) */
		32895 IT8CTPAD	   ; IT8 CT w/padding */
		32896 IT8LW		   ; IT8 Linework RLE */
		32897 IT8MP		   ; IT8 Monochrome picture */
		32898 IT8BL		   ; IT8 Binary line art */
		;; compression codes 32908-32911 are reserved for Pixar */
		32908 PIXARFILM	   ; Pixar companded 10bit LZW */
		32909 PIXARLOG	   ; Pixar companded 11bit ZIP */
		32946 DEFLATE			; Deflate compression */
		8 ADOBE_DEFLATE          ; Deflate compression as recognized by Adobe */
		;; compression code 32947 is reserved for Oceana Matrix <dev@oceana.com> */
		32947 DCS                ; Kodak DCS encoding */
		34661 JBIG			; ISO JBIG */
		34676 SGILOG			; SGI Log Luminance RLE */
		34677 SGILOG24		; SGI Log 24-bit packed */
		34712 JP2000         ; Leadtools JPEG2000 */
	]]
	; photometric interpretation */
	262 [Photometric [			
		0 MinIsWhite		; min value is white */
		1 MinIsBlack		; min value is black */
		2 RGB			; RGB color model */
		3 Palette		; color map indexed */
		4 Mask			; $holdout mask */
		5 Separated		; !color separations */
		6 YCBCR			; !CCIR 601 */
		8 CIELAB			; !1976 CIE L*a*b* */
		9 ICCLAB			; ICC L*a*b* [Adobe TIFF Technote 4] */
		10 ITULAB			; ITU L*a*b* */
		32844 LOGL			; CIE Log2(L) */
		32845 LOGLUV			; CIE Log2(L) (u',v') */
	]]
	; +thresholding used on data */
	263 [Thresholding [	
		1 BiLevel			; b&w art scan */
		2 HalfTone			; or dithered scan */
		3 ErrorDiffuse 	; usually floyd-steinberg */
	]]
	264 [CellWidth]	; +dithering matrix width */
	265 [CellLength]	; +dithering matrix height */
	; data order within a byte */
	266 [FillOrder [
		1 MSB2LSB			; most significant -> least */
		2 LSB2MSB			; least significant -> most */
	]]
	269 [DocumentName]	; name of doc. image is from */
	270 [ImageDescription]; info about image */
	271 [Maker]	; scanner manufacturer name */
	272 [Model]	; scanner model name/number */
	273 [StripOffsets]	; offsets to data strips */
	; +image orientation */
	274 [Orientation [	
		1 TopLeft			; row 0 top, col 0 lhs */
		2 TopRight		; row 0 top, col 0 rhs */
		3 BottomRight		; row 0 bottom, col 0 rhs */
		4 BottomLeft			; row 0 bottom, col 0 lhs */
		5 LeftTop			; row 0 lhs, col 0 top */
		6 RightTop		; row 0 rhs, col 0 top */
		7 RightBottom		; row 0 rhs, col 0 bottom */
		8 LeftBottom			; row 0 lhs, col 0 bottom */
	]]
	277 [SamplesPerPixel]	; samples per pixel */
	278 [RowsPerStrip]		; rows per strip of data */
	279 [StripByteCounts]	; bytes counts for strips */
	280 [MinimumSampleValue]	; +minimum sample value */
	281 [MaxSampleValue]	; +maximum sample value */
	282 [XResolution] 		; pixels/resolution in x */
	283 [YResolution]		; pixels/resolution in y */
	; storage organization */
	284 [PlanarConfig [	
		1 Contig		; single image plane */
		2 Separate	; separate planes of data */
	]]
	285 [PageName]		; page name image is from */
	286 [XPosition]		; x page offset of image lhs */
	287 [YPosition]		; y page offset of image lhs */
	288 [FreeOffsets]	; +byte offset to free block */
	289 [FreeByteCounts]; +sizes of free blocks */
	; $gray scale curve accuracy */
	290 [GrayResponseUnit [
		1 _10S		; tenths of a unit */
		2 _100S		; hundredths of a unit */
		3 _1000S		; thousandths of a unit */
		4 _10000S		; ten-thousandths of a unit */
		5 _100000S 	; hundred-thousandths */
	]]
	291 [GrayResponsCurve]	; $gray scale response curve */
	292 [Group3Options]		; 32 flag bits */
	; TIFF 6.0 proper name alias */
	292 [T4Options [
		1 _2DEncoding		; 2-dimensional coding */
		2 Uncompressed		; data not compressed */
		3 FillBits			; fill to byte boundary */
	]]
	293 [Group4Options]		; 32 flag bits */
	; TIFF 6.0 proper name */
	293 [T6OPTIONS [    
		2 Uncompressed		; data not compressed */
	]]
	; units of resolutions */
	296 [ResolutionUnit	[
		1 None	; no meaningful units */
		2 Inch	; english */
		3 Centimeter	; metric */
	]]
	297 [PageNumber]	; page numbers of multi-page */
	; $color curve accuracy */
	300 [ColorResponseUnit [
		1 _10S		; tenths of a unit */
		2 _100S		; hundredths of a unit */
		3 _1000S		; thousandths of a unit */
		4 _10000S		; ten-thousandths of a unit */
		5 _100000S		; hundred-thousandths */
	]]
	301	[TransferFunction]	; !colorimetry info */
	305 [Software]			; name & release */
	306 [DateTime]			; creation date and time */
	315 [Artist]			; creator of image */
	316 [HostComputer] 		; machine where created */
	; prediction scheme w/ LZW */
	317 [Predictor [
		1 None 	; no prediction scheme used */
		2 Horizontal		; horizontal differencing */
		3 FloatingPoint	; floating point predictor */
	]]
	318 [WhitePoint]			; image white point */
	319 [PrimaryChromaticities]		; !primary chromaticities */
	320 [ColorMap] 	; RGB map for pallette image */
	321 [HalfToneHints]			; !highlight+shadow info */
	322 [TileWidth]			; !tile width in pixels */
	323 [TileLength]			; !tile height in pixels */
	324 [TileOffsets]		; !offsets to data tiles */
	325 [TileByteCount]		; !byte counts for tiles */
	326 [BadFaxLines]			; lines w/ wrong pixel count */
	;regenerated line info */
	327 [CleanFaxData [
		0 Clean			; no errors detected */
		1 Regenerated	; receiver regenerated lines */
		2 Unclean	; uncorrected errors exist */
	]]
	328 [ConsecutiveBadFaxLines]	; max consecutive bad fax lines */
	330 [SubIFD]					; subimage descriptors */
	; !inks in separated image */
	332 [InkSet	[	
		1 CMYK				; !cyan-magenta-yellow-black color */
		2 MultiInk			; !multi-ink or hi-fi color */
	]]
	333 [InkNames]			; !ascii names of inks */
	334 [NumberOfInks]		; !number of inks */
	336 [DotRange]			; !0% and 100% dot codes */
	337 [TargetPrinter]		; !separation target */
	; !info about extra samples */
	338 [ExtraSamples [
		0 Unspecified	; !unspecified data */
		1 AssocAlpha		; !associated alpha data */
		2 UuAssAlpha		; !unassociated alpha data */
	]]
	; !data sample format */
	339 [SampleFormat [
		1 Uint			; !unsigned integer data */
		2 Int			; !signed integer data */
		3 IEEEFP			; !IEEE floating point data */
		4 Void 		; !untyped data */
		5 ComplexInt		; !complex signed int */
		6 ComplexIEEEFP		; !complex ieee floating */
	]]
	340 [SMinSampleValue]			; !variable MinSampleValue */
	341 [SMaxSampleValue]			; !variable MaxSampleValue */
	343 [ClipPath]					; %ClipPath [Adobe TIFF technote 2] */
	344 [XClipPathUnits]			; %XClipPathUnits[Adobe TIFF technote 2] */
	345 [YClipPathUnits]			; %YClipPathUnits[Adobe TIFF technote 2] */
	346 [Indexed]					; %Indexed[Adobe TIFF Technote 3] */
	347 [JPEGTables]				; %JPEG table stream */
	351 [OPIProxy]					; %OPI Proxy [Adobe TIFF technote] */
	;* Tags 512-521 are obsoleted by Technical Note #2 which specifies a revised JPEG-in-TIFF scheme.
	; !JPEG processing algorithm */
	512 [JpegProc [
		1 Baseline			; !baseline sequential */
		14 LossLess 		; !Huffman coded lossless */
	]]
	513 [JPEGIFOffset]			; !pointer to SOI marker */
	514 [JPEGIFByteCountT]		; !JFIF stream length */
	515 [JPEGRestartInterval]		; !restart interval length */
	517 [JPEGLossLessPredictors]		; !lossless proc predictor */
	518 [JPEGPointTransform]		; !lossless point transform */
	519 [JPEGQTables]			; !Q matrice offsets */
	520 [JPEGDCTables]			; !DCT table offsets */
	521 [JPEGACTables]			; !AC coefficient offsets */
	529 [YCBCRCoefficients]		; !RGB -> YCbCr transform */
	530 [YCBCRSubSampling]	; !YCbCr subsampling factors */
	; !subsample positioning */
	531 [YCBCRPositioning [
		1 Centered	; !as in PostScript Level 2 */
		2 Cosited	; !as in CCIR 601-1 */
	]]
	532 [ReferenceBlackWhite]		; !colorimetry info */
	700 [XMLPacket]			; %XML packet[Adobe XMP Specification,January 2004 */
	32781 [OPIImageID]		; %OPI ImageID [Adobe TIFF technote] */
	; tags 32952-32956 are private tags registered to Island Graphics */
	32953 [RefPts]				; image reference points */
	32954 [RegionTackPoint]			; region-xform tack point */
	32955 [RegionWarpCorners]		; warp quadrilateral */
	32956 [RegionAffine]			; affine transformation mat */
	; tags 32995-32999 are private tags registered to SGI */
	32995 [Matteing]			; $use ExtraSamples */
	32996 [DataType]			; $use SampleFormat */
	32997 [IMAGEDEPTH]			; z depth of image */
	32998 [TILEDEPTH]			; z depth/data tile */
	;; tags 33300-33309 are private tags registered to Pixar */
	{* PIXAR_IMAGEFULLWIDTH and PIXAR_IMAGEFULLLENGTH
 	* are set when an image has been cropped out of a larger image.  
 	* They reflect the size of the original uncropped image.
 	* The XPOSITION and YPOSITION can be used
 	* to determine the position of the smaller image in the larger one.*}
	33300 [PIXAR_IMAGEFULLWIDTH]       ; full image size in x */
	33301 [PIXAR_IMAGEFULLLENGTH]      ; full image size in y */
	;; Tags 33302-33306 are used to identify special image modes and data /used by Pixar's texture formats.
	33302 [PIXAR_TEXTUREFORMAT]		; texture map format */
	33303 [PIXAR_WRAPMODES]			; s & t wrap modes */
	33304 [PIXAR_FOVCOT]			; cotan(fov) for env. maps */
	33305 [PIXAR_MATRIX_WORLDTOSCREEN] 
	33306 [PIXAR_MATRIX_WORLDTOCAMERA]
	33405 [WRITERSERIALNUMBER]         ; device serial number tag 33405 is a private tag registered to Eastman Kodak *
	33432 [COPYRIGHT]			; copyright string */
	33723 [RICHTIFFIPTC]		 ; IPTC TAG from RichTIFF specifications */
	; 34016-34029 are reserved for ANSI IT8 TIFF/IT <dkelly@apago.com) */
	34016 [IT8SITE]				; site name */
	34017 [IT8COLORSEQUENCE]		; color seq. [RGB,CMYK,etc] */
	34018 [IT8HEADER]			; DDES Header */
	34019 [IT8RASTERPADDING]		; raster scanline padding */
	34020 [IT8BITSPERRUNLENGTH]		; # of bits in short run */
	34021 [IT8BITSPEREXTENDEDRUNLENGTH] ; # of bits in long run */
	34022 [IT8COLORTABLE]			; LW colortable */
	34023 [IT8IMAGECOLORINDICATOR]		; BP/BL image color switch */
	34024 [IT8BKGCOLORINDICATOR]		; BP/BL bg color switch */
	34025 [IT8IMAGECOLORVALUE]		; BP/BL image color value */
	34026 [IT8BKGCOLORVALUE]		; BP/BL bg color value */
	34027 [IT8PIXELINTENSITYRANGE]		; MP pixel intensity value */
	34028 [IT8TRANSPARENCYINDICATOR] 	; HC transparency switch */
	34029 [IT8COLORCHARACTERIZATION] 	; color character. table */
	34030 [IT8HCUSAGE]			; HC usage indicator */
	34031 [IT8TRAPINDICATOR]		; Trapping indicator (untrapped=0, trapped=1) */
	34032 [IT8CMYKEQUIVALENT]		; CMYK color equivalents */
	34232 [FRAMECOUNT]                 ; Sequence Frame Count private tags registered to Texas Instruments /
	34377 [PHOTOSHOP]			; tag 34377 is private tag registered to Adobe for PhotoShop */
	34665 [EXIFIFD]				; Pointer to EXIF private directory */
	34675 [ICCPROFILE]			; ICC profile data */
	34750 [JBIGOPTIONS]			; JBIG options private tag registered to Pixel Magic
	34853 [GPSIFD]				; Pointer to GPS private directory */
	; tags 34908-34914 are private tags registered to SGI */
	34908 [FAXRECVPARAMS]			; encoded Class 2 ses. parms */
	34909 [FAXSUBADDRESS]			; received SubAddr string */
	34910 [FAXRECVTIME]			; receive time (secs) */
	34911 [FAXDCS]				; encoded fax ses. params, Table 2/T.30 */
	37439 [STONITS]				; Sample value to Nits */
	34929 [FEDEX_EDR]			; a private tag registered to FedEx */ unknown use */
	40965 [INTEROPERABILITYIFD]		; Pointer to Interoperability private directory */
	; Adobe Digital Negative (DNG) format tags */
	50706 [DNGVERSION]				; &DNG version number */
	50707 [DNGBACKWARDVERSION]		; &DNG compatibility version */
	50708 [UNIQUECAMERAMODEL]		; &name for the camera model */
	50709 [LOCALIZEDCAMERAMODEL]	; &localized camera model name */
	50710 [CFAPLANECOLOR]			; &CFAPattern->LinearRaw space mapping */
	50711 [CFALAYOUT]				; &spatial layout of the CFA */
	50712 [LINEARIZATIONTABLE]		; &lookup table description */
	50713 [BLACKLEVELREPEATDIM]		; &repeat pattern size for the BlackLevel tag */
	50714 [BLACKLEVEL]				; &zero light encoding level */
	50715 [BLACKLEVELDELTAH]		; &zero light encoding level differences (columns) */
	50716 [BLACKLEVELDELTAV]		; &zero light encoding level differences (rows) */
	50717 [WHITELEVEL]				; &fully saturated encoding level */
	50718 [DEFAULTSCALE]			; &default scale factors */
	50719 [DEFAULTCROPORIGIN]		; &origin of the final image area */
	50720 [DEFAULTCROPSIZE]			; &size of the final image  area */
	50721 [COLORMATRIX1]			; &XYZ->reference color space transformation matrix 1 */
	50722 [COLORMATRIX2]			; &XYZ->reference color space transformation matrix 2 */
	50723 [CAMERACALIBRATION1]		; &calibration matrix 1 */
	50724 [CAMERACALIBRATION2]		; &calibration matrix 2 */
	50725 [REDUCTIONMATRIX1]		; &dimensionality reduction matrix 1 */
	50726 [REDUCTIONMATRIX2]		; &dimensionality reduction matrix 2 */
	50727 [ANALOGBALANCE]			; &gain applied the stored raw values*/
	50728 [ASSHOTNEUTRAL]			; &selected white balance in linear reference space */
	50729 [ASSHOTWHITEXY]			; &selected white balance in x-y chromaticity coordinates */
	50730 [BASELINEEXPOSURE]		; &how much to move the zero point */
	50731 [BASELINENOISE]			; &relative noise level */
	50732 [BASELINESHARPNESS]		; &relative amount of sharpening */
	50733 [BAYERGREENSPLIT]			; &how closely the values of the green pixels in the blue/green rows track the values of the green pixel in the red/green rows */
	50734 [LINEARRESPONSELIMIT]		; &non-linear encoding range */
	50735 [CAMERASERIALNUMBER]		; &camera's serial number */
	50736 [LENSINFO]			; info about the lens */
	50737 [CHROMABLURRADIUS]		; &chroma blur radius */
	50738 [ANTIALIASSTRENGTH]		; &relative strength of the  camera's anti-alias filter */
	50739 [SHADOWSCALE]			; &used by Adobe Camera Raw */
	50740 [DNGPRIVATEDATA]			; &manufacturer's private data */
	50741 [MAKERNOTESAFETY]			; &whether the EXIF MakerNote tag is safe to preserve  along with the rest of the EXIF data */
	50778 [CALIBRATIONILLUMINANT1]		; &illuminant 1 */
	50779 [CALIBRATIONILLUMINANT2]		; &illuminant 2 */
	50780 [BESTQUALITYSCALE]	; &best quality multiplier */
	50781 [RAWDATAUNIQUEID]			; &unique identifier for the raw image data */
	50827 [ORIGINALRAWFILENAME]		; &file name of the original raw file */
	50828 [ORIGINALRAWFILEDATA]		; &contents of the original raw file */
	50829 [ACTIVEAREA]			; &active (non-masked) pixels of the sensor */
	50830 [MASKEDAREAS]			; &list of coordinates of fully masked pixels */
	50831 [ASSHOTICCPROFILE]		; &these two tags used to */
	50832 [ASSHOTPREPROFILEMATRIX]		; map cameras's color space into ICC profile space */
	50833 [CURRENTICCPROFILE]		; & */
	50834 [CURRENTPREPROFILEMATRIX]		; & */
	65535 [DCSHUESHIFTVALUES]          ; hue shift correction data used by Eastman Kodak 
	{* The following are ``pseudo tags'' that can be used to control
 	* codec-specific functionality.  These tags are not written to file.
	 * Note that these values start at 0xffff+1 so that they'll never
 	* collide with Aldus-assigned tags.
 	*
 	* If you want your private pseudo tags ``registered'' (i.e. added to
 	* this file), please post a bug report via the tracking system at
 	* http://www.remotesensing.org/libtiff/bugs.html with the appropriate
 	* C definitions to add.}
 	; Group 3/4 format control */
	65536 [FAXMODE [			
			FAXMODE_CLASSIC	#00000000		; default, include RTC */
			FAXMODE_NORTC	#00000001		; no RTC at end of data */
			FAXMODE_NOEOL	#00000002		; no EOL code at end of row */
			FAXMODE_BYTEALIGN	#00000004		; byte align row */
			FAXMODE_WORDALIGN	#00000008		; word align row */
			FAXMODE_CLASSF	#00000001	; TIFF Class F */
	]]
	65537 [JPEGQUALITY]			; Compression quality level ; Note: quality level is on the IJG 0-100 scale.  Default value is 75
	; Auto RGB<=>YCbCr convert? */
	65538 [JPEGCOLORMODE [			
		JPEGCOLORMODE_RAW	#00000000		; no conversion (default) */
		PEGCOLORMODE_RGB	#00000001		; do auto conversion */
	]]
	; What to put in JPEGTables */
	65539 [JPEGTABLESMODE [			
			JPEGTABLESMODE_QUANT #00000001		; include quantization tbls */
			JPEGTABLESMODE_HUFF	#00000002		; include Huffman tbls */
			; Note: default is JPEGTABLESMODE_QUANT | JPEGTABLESMODE_HUFF */
	]]
	65540 [FAXFILLFUNC]			; G3/G4 fill function */
	; PixarLogCodec I/O data sz */	
	65549 [PIXARLOGDATAFMT [			
		PIXARLOGDATAFMT_8BIT	0	; regular u_char samples */
		PIXARLOGDATAFMT_8BITABGR	1	; ABGR-order u_chars */
		PIXARLOGDATAFMT_11BITLOG	2	; 11-bit log-encoded (raw) */
		PIXARLOGDATAFMT_12BITPICIO	3	; as per PICIO (1.0==2048) */
		PIXARLOGDATAFMT_16BIT	4	; signed short samples */
		PIXARLOGDATAFMT_FLOAT	5	; IEEE float samples */
	]]
	; 65550-65556 are allocated to Oceana Matrix <dev@oceana.com> */
	; imager model & filter */
	65550 [DCSIMAGERTYPE [              
			DCSIMAGERMODEL_M3           0       ; M3 chip (1280 x 1024) */
			DCSIMAGERMODEL_M5           1       ; M5 chip (1536 x 1024) */
			DCSIMAGERMODEL_M6           2       ; M6 chip (3072 x 2048) */
			DCSIMAGERFILTER_IR          0       ; infrared filter */
			DCSIMAGERFILTER_MONO        1       ; monochrome filter */
			DCSIMAGERFILTER_CFA         2       ; color filter array */
			DCSIMAGERFILTER_OTHER       3       ; other filter */
	]]
	; interpolation mode */
	65551 [DCSINTERPMODE[             
			DCSINTERPMODE_NORMAL        #00000000     ; whole image, default */
			DCSINTERPMODE_PREVIEW       #00000001     ; preview of image (384x256) */
	]]
	65552 [DCSBALANCEARRAY]            ; color balance values */
	65553 [DCSCORRECTMATRIX]           ; color correction values */
	65554 [DCSGAMMA]                   ; gamma value */
	65555 [DCSTOESHOULDERPTS]          ; toe & shoulder points */
	65556 [DCSCALIBRATIONFD]           ; calibration file desc */
	65557 [ZIPQUALITY]				; compression quality level ; Note: quality level is on the ZLIB 1-9 scale. Default value is -1 
	65558 [PIXARLOGQUALITY]			; PixarLog uses same scale */
	65559 [DCSCLIPRECTANGLE]		; area of image to acquire 65559 is allocated to Oceana Matrix <dev@oceana.com>
	; SGILog user data format */
	65560 [SGILOGDATAFMT [			
			SGILOGDATAFMT_FLOAT		0	; IEEE float samples */
			SGILOGDATAFMT_16BIT		1	; 16-bit samples */
			SGILOGDATAFMT_RAW		2	; uninterpreted data */
			SGILOGDATAFMT_8BIT		3	; 8-bit RGB monitor values */
	]]
	; SGILog data encoding control*/	
	65561 [SGILOGENCODE	[	 
			SGILOGENCODE_NODITHER	0     ; do not dither encoded values*/
			SGILOGENCODE_RANDITHER	1     ; randomly dither encd values */
	]]
	;EXIF tags
	33434 [EXIFTAG_EXPOSURETIME]			; Exposure time */
	33437 [EXIFTAG_FNUMBER]				; F number */
	34850 [EXIFTAG_EXPOSUREPROGRAM]			; Exposure program */
	34852 [EXIFTAG_SPECTRALSENSITIVITY]		; Spectral sensitivity */
	34855 [EXIFTAG_ISOSPEEDRATINGS]			; ISO speed rating */
	34856 [EXIFTAG_OECF]				; Optoelectric conversionbfactor */
	36864 [EXIFTAG_EXIFVERSION]			; Exif version */
	36867 [EXIFTAG_DATETIMEORIGINAL]		; Date and time of original data generation */
	36868 [EXIFTAG_DATETIMEDIGITIZED]		; Date and time of digitaldata generation */
	37121 [EXIFTAG_COMPONENTSCONFIGURATION]		; Meaning of each component */
	37122 [EXIFTAG_COMPRESSEDBITSPERPIXEL]		; Image compression mode */
	37377 [EXIFTAG_SHUTTERSPEEDVALUE]		; Shutter speed */
	37378 [EXIFTAG_APERTUREVALUE]			; Aperture */
	37379 [EXIFTAG_BRIGHTNESSVALUE]			; Brightness */
	37380 [EXIFTAG_EXPOSUREBIASVALUE]		; [Exposure bias */
	37381 [EXIFTAG_MAXAPERTUREVALUE]		; Maximum lens aperture */
	37382 [EXIFTAG_SUBJECTDISTANCE]			; Subject distance */
	37383 [EXIFTAG_METERINGMODE]			; Metering mode */
	37384 [EXIFTAG_LIGHTSOURCE]			; Light source */
	37385 [EXIFTAG_FLASH]				; Flash */
	37386 [EXIFTAG_FOCALLENGTH]			; Lens focal length */
	37396 [EXIFTAG_SUBJECTAREA]			; Subject area */
	37500 [EXIFTAG_MAKERNOTE]			; Manufacturer notes */
	37510 [EXIFTAG_USERCOMMENT]			; User comments */
	37520 [EXIFTAG_SUBSECTIME]			; DateTime subseconds */
	37521 [EXIFTAG_SUBSECTIMEORIGINAL]		; DateTimeOriginal subseconds */
	37522 [EXIFTAG_SUBSECTIMEDIGITIZED]		; DateTimeDigitized subseconds */
	40960 [EXIFTAG_FLASHPIXVERSION]			; Supported Flashpix version */
	40961 [EXIFTAG_COLORSPACE]			; Color space information */
	40962 [EXIFTAG_PIXELXDIMENSION]			; Valid image width */
	40963 [EXIFTAG_PIXELYDIMENSION]			; Valid image height */
	40964 [EXIFTAG_RELATEDSOUNDFILE]		; Related audio file */
	41483 [EXIFTAG_FLASHENERGY]			; Flash [Energy */
	41484 [EXIFTAG_SPATIALFREQUENCYRESPONSE] 	; Spatial frequency response */
	41486 [EXIFTAG_FOCALPLANEXRESOLUTION]		; Focal plane X resolution */
	41487 [EXIFTAG_FOCALPLANEYRESOLUTION]		; Focal plane Y resolution */
	41488 [EXIFTAG_FOCALPLANERESOLUTIONUNIT] 	; Focal plane resolution unit */
	41492 [EXIFTAG_SUBJECTLOCATION]			; Subject location */
	41493 [EXIFTAG_EXPOSUREINDEX]			; [Exposure index */
	41495 [EXIFTAG_SENSINGMETHOD]			; Sensing method */
	41728 [EXIFTAG_FILESOURCE]			; File source */
	41729 [EXIFTAG_SCENETYPE]			; Scene type */
	41730 [EXIFTAG_CFAPATTERN]			; CFA pattern */
	41985 [EXIFTAG_CUSTOMRENDERED]			; Custom image processing */
	41986 [EXIFTAG_EXPOSUREMODE]			; [Exposure mode */
	41987 [EXIFTAG_WHITEBALANCE]			; White balance */
	41988 [EXIFTAG_DIGITALZOOMRATIO]		; Digital zoom ratio */
	41989 [EXIFTAG_FOCALLENGTHIN35MMFILM]		; Focal length in 35 mm film */
	41990 [EXIFTAG_SCENECAPTURETYPE]	; Scene capture type */
	41991 [EXIFTAG_GAINCONTROL]			; Gain control */
	41992 [EXIFTAG_CONTRAST]			; Contrast */
	41993 [EXIFTAG_SATURATION]			; Saturation */
	41994 [EXIFTAG_SHARPNESS]			; Sharpness */
	41995 [EXIFTAG_DEVICESETTINGDESCRIPTION] 	; Device settings description */
	41996 [EXIFTAG_SUBJECTDISTANCERANGE]		; Subject distance range */
	41991 [EXIFTAG_GAINCONTROL]			; Gain control */
	41991 [EXIFTAG_GAINCONTROL]			; Gain control */
	42016 [EXIFTAG_IMAGEUNIQUEID]			; Unique image ID */
]
 
 

byte_order: "Intel" 
Big_Endian: false
Number_of_Pages: 1
Image_Type: "grayscale"
image_created: false
image_data: #{} 
image_rgb: #{}
tiffBloc: []
Tag_Block: []
Tag_List: []



;initialisation des blocs pourla gestion des strips de données :
BStripOffsets: []
BStripByteCounts: []

;Tiff Header Structure
; header size: 8 bytes
TIFFHeader: make struct! [
	tiffBOrder [string!];  2 bytes 0-1 byte order; could be also a binary or integer
	tiffVersion [integer!] ; 2b ytes 2-3 42 version number
	tiffFIFD [integer!] ; 4 bytes 4-7 offset of the first Image File Directory
] none 

;Image File Directory 
; Dir entry size: 12 bytes by entry

TImgFDEntry: make struct! [
	tiffTag [integer! ] ;byte 0-1 TIFF Field Tag 2 bytes 0-1 see TIFF Tag Definitions
	tiffDataType [integer!] ; byte 2-3  Field data type  2 bytes 2-3 see TIFFDataType
	tiffDataLength [integer!] ; byte 4-7  number of values of the indicated type; length in spec  4 bytes 4-7
	tiffOffset [integer!] ; byte 8-11 byte offset to field data 4 bytes 8-11 or value of the field if datalength < 4 bytes
	tiffValue [string!] ; supplementary rebol field to get the "real" value
] none


; kind of TIFF Images

{Baseline TIFF bilevel images were called TIFF Class B images in earlier versions of the TIFF specification}


TBiLevel: make struct! [
	SubfileType [integer! ] ; 254 or 255
	ImageWidth [integer! ]; 256 SHORT or LONG
	ImageLength [integer! ]; 257 SHORT or LONG
	Compression [integer! ]; 259 SHORT expected value: 1, 2 or 32773
	PhotometricInterpretation [integer! ]; 262 SHORT expected value 0 1
	StripOffsets [integer! ]; 273 SHORT or LONG
	RowsPerStrip [integer! ]; 278 SHORT or LONG
	StripByteCounts [integer! ]; 279 SHORT or LONG
	XResolution [decimal! ] ;282 RATIONAL
	YResolution [decimal! ] ;283 RATIONAL
	ResolutionUnit [integer! ]; 296 SHORT expected value: 1, 2 or 3	
] none	


{ Baseline TIFF grayscale images were called TIFF Class G images in earlier versions
of the TIFF specification}

TGrayScale: make struct! [
	SubfileType [integer! ] ; 254 or 255 
	ImageWidth [integer! ];256  SHORT or LONG
	ImageLength [integer! ];257  SHORT or LONG
	BitsPerSample [integer! ];258  SHORT 4 or 8
	Compression [integer! ];259 SHORT 1 or 32773
	PhotometricInterpretation [integer! ] ;262 SHORT 0 or 1
	StripOffsets [integer! ];273 SHORT or LONG
	RowsPerStrip [integer! ];278 SHORT or LONG
	StripByteCounts [integer! ];279  LONG or SHORT
	XResolution [decimal! ];282  RATIONAL
	YResolution [decimal! ]; 283  RATIONAL
	ResolutionUnit [integer! ];296  SHORT 1 or 2 or 3
] none


{Baseline TIFF palette-color images were called TIFF Class P images in earlier
versions of the TIFF specification }



TColorPalette: make struct! [
	SubfileType [integer! ] ; 254 or 255
	ImageWidth [integer! ];256  SHORT or LONG
	ImageLength [integer! ];257 SHORT or LONG
	BitsPerSample [integer! ];258 SHORT 4 or 8
	Compression [integer! ]; 259 SHORT 1 or 32773
	PhotometricInterpretation [integer! ];262 SHORT 3
	StripOffsets [integer! ];273 SHORT or LONG
	RowsPerStrip [integer! ];278 SHORT or LONG
	StripByteCounts [integer! ];279 LONG or SHORT
	XResolution [decimal! ];282 RATIONAL
	YResolution [decimal! ];283  RATIONAL
	ResolutionUnit [integer! ];296  SHORT 1 or 2 or 3
	ColorMap [integer! ];320 SHORT
	;mlm01 new variable for the colormap count
	ColorMapCount [integer!];320 length
] none


{ In an RGB image, each pixel is made up of three components: red, green, and
blue. There is no ColorMap}


TRGBImage: make struct! [
	SubfileType [integer! ] ; 254 or 255 
	ImageWidth [integer! ];256 SHORT or LONG
	ImageLength [integer! ];257 SHORT or LONG
	BitsPerSample [integer! ];258 SHORT 8,8,8
	Compression [integer! ];259  SHORT 1 or 32773
	PhotometricInterpretation [integer! ];262 SHORT 2
	StripOffsets [integer! ];273 SHORT or LONG
	SamplesPerPixel [integer! ];277 SHORT 3 or more
	RowsPerStrip [integer! ];278 SHORT or LONG
	StripByteCounts [integer! ];279 LONG or SHORT
	XResolution [decimal! ];282  RATIONAL
	YResolution [decimal! ];283  RATIONAL
	ResolutionUnit [integer! ];296 SHORT 1, 2 or 3
] none


;Read Tiff File header (8 bytes)
Read_Header:  does [
		tiff: head tiff
	    header: copy/part tiff 8
		tmp: to-string copy/part header 2 
		; file created by motorola (big endian) or intel (litte endian) processor?
		either (tmp = "MM") [Big_Endian: true byte_order: "Motorola"] [Big_Endian: false byte_order: "Intel"]
		TiffHeader/tiffBOrder: tmp
		header: skip header 2
		tmp: copy/part header 2 
		if not Big_Endian [reverse tmp]
		TiffHeader/tiffVersion: to-integer tmp  ; expected value: 42
		header: skip header 2
		tmp: copy/part header 4
		if not Big_Endian [reverse tmp]
		TiffHeader/tiffFIFD: to-integer tmp
		;initialisation des blocs pour la gestion des strips de données :
		clear BStripOffsets
		clear BStripByteCounts
]

             

; make the list of  Image File Directory (IFD) 12 bytes
Make_IFD_List: does [
	IFD_Offset_List: copy []
	;now move to the First Image directory offset and get the number of entries
	tiff: head tiff
	stream: skip tiff TiffHeader/tiffFIFD
	start_offset: TiffHeader/tiffFIFD
	tmp: copy/part stream 2        
    if not Big_Endian [reverse tmp]
    Number_of_Entries: to-integer tmp 
    bloc: copy []
    append bloc start_offset
    append bloc  Number_of_Entries
    append/only IFD_Offset_List  bloc ; append data to the offset list
    ;move to the next IDF offset and get the value
    next_offset: start_offset + 2 + (Number_of_Entries * 12)
    stream: skip tiff next_offset    
    tmp: copy/part stream 4         
    if not Big_Endian [reverse tmp]
    offset_value: to-integer tmp                 
   ; print [to-hex Number_of_Entries to-hex start_offset next_offset offset_value]
    
    ;now move to the other IFD if exist and get the number of entries
    ; this is case for multi pages files
    ;repeat until ifd offset = 0
    
    if  offset_value > 0 [                               
    until [
    	start_offset: offset_value 
    	tiff: head tiff
    	stream: skip tiff  start_offset                     
   	 	tmp: copy/part stream 2                              
    	if not Big_Endian [reverse tmp]                      
    	Number_of_Entries: to-integer tmp                       
    	bloc: copy []                                        
    	append bloc start_offset                             
    	append bloc  Number_of_Entries                          
    	append/only IFD_Offset_List  bloc                    
    	next_offset: start_offset + 2 + (Number_of_Entries * 12)
    	stream: skip tiff next_offset                        
    	tmp: copy/part stream 4                              
    	if not Big_Endian [reverse tmp]                      
    	offset_value: to-integer tmp  
    	(offset_value = 0 ) ] 
    ]      
    Number_of_IFD: length? IFD_Offset_List 
    Number_of_Pages: Number_of_IFD              
]



; what kind of images are included in the file ?
; parameter the number of the image
Get_Image_Type: func  [Page_Number] [
	clear Tag_Block
	bloc: pick IFD_Offset_List Page_Number 
	start_offset: first bloc ; offset
	Number_of_Entries: second bloc ; number of entries
	for i 1 Number_of_Entries 1 [ tag_offset: (start_offset + 2) + ( 12 * (i - 1))
		; get the entry values
		tiff: head tiff
		tiff2: skip tiff  tag_offset 
		stream: copy/part tiff2 12
		tmp: copy/part stream 2                              
    	if not Big_Endian [reverse tmp]
    	; tag number
    	TImgFDEntry/tiffTag: to-integer tmp
		stream: skip stream 2
		tmp: copy/part stream 2                              
    	if not Big_Endian [reverse tmp]
    	; tag type 
    	TImgFDEntry/tiffDataType: to-integer tmp
    	
		stream: skip stream 2
		tmp: copy/part stream 4                              
    	if not Big_Endian [reverse tmp] 
    	; tag count or length
    	TImgFDEntry/tiffDataLength: to-integer tmp
    	
    	stream: skip stream 4
		tmp: copy/part stream 4  
		; value or offset of the value                   
    	if not Big_Endian [reverse tmp] 
    	TImgFDEntry/tiffOffset: to-integer tmp
    	append/only Tag_Block TImgFDEntry/tiffTag
    	; get PhotometricInterpretation
    	if (TImgFDEntry/tiffTag = 262) [photometric: TImgFDEntry/tiffOffset ]
    ]
   
    if photometric > 65535 [photometric: photometric / 65536]; correction for short value 
	
   	; image type according to PhotometricInterpretation
   	Image_Type: "bilevel" ; default
   	if (photometric = 0) and ( found? find Tag_Block 258) [Image_Type: "grayscale" ] ;OK
   	if (photometric = 1) and ( found? find Tag_Block 258) [Image_Type: "grayscale" ] ;OK
   	if (photometric = 2) [Image_Type: "rgb" ]  ; OK
   	if (photometric = 3) [Image_Type: "palette" ] ;0K
   
   		
   	;make the image structure     
    switch Image_Type [
    	"bilevel" [Timage: make struct! TBiLevel none]
    	"grayscale" [Timage: make struct! TGrayScale none]
    	"palette" [Timage: make struct! TColorPalette none]
    	"rgb" [Timage: make struct! TRGBImage none]]
    image_created: true	
]


; for each tag get the tag value
Get_Tag_Value: does [
	
		; use a block rather a string for specific tags such as StripOffsets 
		clear tiffBloc  
		tiff:  head tiff
		; adapt to the real data length in reference to data type
		switch TImgFDEntry/tiffDataType [
    	 	0 [cc: 1 ] ;[TIFF_NOTYPE] placeholder ; 1 byte
			1 [cc: 1 ] ;[TIFF_BYTE] 8-bit unsigned integer
			2 [cc: 1 ] ;[TIFF_ASCII]8-bit bytes w/ last byte null 
			3 [cc: 2 ] ;[TIFF_SHORT];16-bit unsigned integer 
			4 [cc: 4 ] ;[TIFF_LONG] 32-bit unsigned integer 
			5 [cc: 8 ] ;[TIFF_RATIONAL]; 64-bit unsigned fraction (Two longs first represents the numerator and second the denominator)
			6 [cc: 1 ] ;[TIFF_SBYTE] ; !8-bit signed integer 
			7 [cc: 1 ] ;[TIFF_] ;!8-bit untyped data (similar to ascii)
			8 [cc: 2 ] ;[TIFF_SSHORT]; !16-bit signed integer 
			9 [cc: 4 ] ;[TIFF_SLONG]; !32-bit signed integer 
			10 [cc: 8 ];[TIFF_SRATIONAL]; !64-bit signed fraction (Two longs first represents the numerator and second the denominator)
			11 [cc: 4 ];[TIFF_FLOAT]; !32-bit IEEE floating point 
			12 [cc: 8 ];[TIFF_DOUBLE] ;!64-bit IEEE floating point    
	 	]
	 	
		
		;normalement le calcul suivant devrait être correct: 
		;mais attention c'est le pb des valeurs 16 bit (short) qui pose pb
	 	tlong: (TImgFDEntry/tiffDataLength * cc )
	 	
	 	
	 	
		; less than 4 bytes: value is here
		;print [TImgFDEntry/tiffTag TImgFDEntry/tiffOffset]
    	either tlong <= 4 [
    		value: TImgFDEntry/tiffOffset
    		; test for 8-bit value
    		if (TImgFDEntry/tiffDataType = 1) and (value > 255) [value: (TImgFDEntry/tiffOffset / 256)]
    		if (TImgFDEntry/tiffDataType = 6) and (value > 255) [value: (TImgFDEntry/tiffOffset / 256)]
    		; test for 16-bit value
    		if (TImgFDEntry/tiffDataType = 3) and (value > 65535) [value: to-integer (TImgFDEntry/tiffOffset / 65536)]
    		if (TImgFDEntry/tiffDataType = 8) and (value > 32767) [value: to-integer (TImgFDEntry/tiffOffset / 32768)]
    	
        	TImgFDEntry/tiffValue: to-string (value)
        	append tiffBloc value 
        	
        	]
    	; > 4 bytes: go to offset to find the tag value
    	[tiff:  skip tiff  to-integer TImgFDEntry/tiffOffset 
    	 str: copy/part tiff (tlong)
    	 
    	 switch TImgFDEntry/tiffDataType [
    	 	0 [TImgFDEntry/tiffValue: "0"]  
			1 [TImgFDEntry/tiffValue: str]
			2 [TImgFDEntry/tiffValue: str] 
			3 [ n1: copy/part str 2
				if not Big_Endian [reverse n1]
				TImgFDEntry/tiffValue: to-string to-integer n1 
				] 
			4 [tmpstr: copy ""
				for cpt 1 TImgFDEntry/tiffDataLength 1 [
					n1: copy/part str 4
					str: skip str 4
					if not Big_Endian [reverse n1]
					append tiffBloc  to-integer n1
					either cpt <= (TImgFDEntry/tiffDataLength - 1) 
					[append tmpstr join to-string to-integer n1 ", "]
					[append tmpstr  to-string to-integer n1]
				]
				TImgFDEntry/tiffValue: tmpstr
			  ] 
			5 [ ; 64-bit unsigned fraction  -> get 2 values
				n1: copy/part str 4
				if not Big_Endian [reverse n1]
				str: skip str 4
				n2: copy/part str 4
				if not Big_Endian [reverse n2] 
				TImgFDEntry/tiffValue: to-string ((to-integer n1) / (to-integer n2)) ] 
			6 [TImgFDEntry/tiffValue: str]  
			7 [TImgFDEntry/tiffValue: str ] 
			8 [n1: copy/part str 2
				if not Big_Endian [reverse n1]
				TImgFDEntry/tiffValue: to-string to-integer n1]
			9 [n1: copy/part str 4
				if not Big_Endian [reverse n1]
				TImgFDEntry/tiffValue: to-string to-integer n1] 
			10 [; 64-bit unsigned fraction  -> get 2 values
				n1: copy/part str 4
				if not Big_Endian [reverse n1]
				str: skip str 4
				n2: copy/part str 4
				if not Big_Endian [reverse n2] 
				TImgFDEntry/tiffValue: to-string ((to-integer n1) / (to-integer n2))]
			11 [; 64-bit -> get 2 values
				n1: copy/part str 4
				if not Big_Endian [reverse n1]
				str: skip str 4
				n2: copy/part str 4
				if not Big_Endian [reverse n2] 
				TImgFDEntry/tiffValue: to-string ((to-integer n1) / (to-integer n2))]
			12 [n1: copy/part str 8
				if not Big_Endian [reverse n1]
				TImgFDEntry/tiffValue: to-string to-integer n1]   
	 		]
    	]
]

Process_Tags: does [
	tbloc: copy []
	append tbloc TImgFDEntry/tiffTag
	either not found? find Tiff_Tags TImgFDEntry/tiffTag [append tbloc to-string  ": Unknown Tag"]
	 [
		if error? try [
					code: select Tiff_Tags TImgFDEntry/tiffTag x: length? code
					val: to-integer TImgFDEntry/tiffValue 
					either ( x > 1) [ xs: select second code val append tbloc join to-string first code [" : " xs]]
					[append tbloc join to-string first code " : " ]
		] [code: select Tiff_Tags TImgFDEntry/tiffTag append tbloc join to-string first code " : " ]	
	]
	append tbloc join  " [ "  [ TImgFDEntry/tiffValue " ]" newline]
	append/only Tag_List tbloc
	
	;note tiffbloc contient la liste des offsets et byteCounts ["n1" "n2"....]. On pourrait stocker
	; dans  TImage/StripOffsets et TImage/StripByteCounts en mettant leur type à string  et
	; en copiant un form exemple: TImage/StripOffsets: form tiffbloc 
	switch TImgFDEntry/tiffTag [
		254 [TImage/SubfileType: to-integer TImgFDEntry/tiffValue ]
		255 [TImage/SubfileType: to-integer TImgFDEntry/tiffValue ]
		256 [TImage/ImageWidth: to-integer TImgFDEntry/tiffValue]
		257 [TImage/ImageLength: to-integer TImgFDEntry/tiffValue ]
		258 [TImage/BitsPerSample: to-integer TImgFDEntry/tiffValue]
		259 [TImage/Compression: to-integer TImgFDEntry/tiffValue]
		262 [TImage/PhotometricInterpretation: to-integer TImgFDEntry/tiffValue]
		273 [BStripOffsets: copy tiffBloc
		     TImage/StripOffsets: to-integer TImgFDEntry/tiffOffset ]
		278 [TImage/RowsPerStrip: to-integer TImgFDEntry/tiffValue]
		277 [if Image_Type = "rgb" [TImage/SamplesPerPixel: to-integer TImgFDEntry/tiffValue]] 
		279 [BStripByteCounts: copy tiffBloc  
		     TImage/StripByteCounts: to-integer TImgFDEntry/tiffOffset]
		282 [TImage/XResolution: to-decimal TImgFDEntry/tiffValue]
		283 [TImage/YResolution: to-decimal TImgFDEntry/tiffValue]
		296 [TImage/ResolutionUnit: to-integer TImgFDEntry/tiffValue]
		320 [if Image_Type = "palette" [TImage/Colormap: to-integer TImgFDEntry/tiffOffset
		     TImage/ColorMapCount: to-integer (TImgFDEntry/tiffDataLength * cc ) ] ]
	] 
]


Read_Image_Tags: func [index] [ 
	; get the image description for each image included in the file
	; 
	clear Tag_List
	bloc: pick IFD_Offset_List index
	start_offset: first bloc
	Number_of_Entries: second bloc
	

	for i 1 Number_of_Entries 1 [ 
	    tag_offset: (start_offset) + ( 12 * (i - 1) + 2)	
		tiff:  head tiff
		tiff:  skip tiff  tag_offset 
		; read directory entry (12 bytes)
		stream: copy/part tiff 12
		
		tmp: copy/part stream 2                             
    	if not Big_Endian [reverse tmp] 
    	TImgFDEntry/tiffTag: to-integer tmp ; tag number
    	stream: skip stream 2
    	
		tmp: copy/part stream 2                              
    	if not Big_Endian [reverse tmp] 
    	TImgFDEntry/tiffDataType: to-integer tmp ; tag type
    	stream: skip stream 2
    	
    	tmp: copy/part stream 4                          
    	if not Big_Endian [reverse tmp] 
    	TImgFDEntry/tiffDataLength: to-integer tmp; number of values of previous tag type
    	stream: skip stream 4
    	
    	tmp: copy/part stream 4                  
    	if not Big_Endian [reverse tmp] 
    	
    	TImgFDEntry/tiffOffset: to-integer tmp ; value offset or data 
    	Get_Tag_Value ; get the tag value
    	Process_Tags ; and process tags
    	
    ]
]


; procedure to read  images from the tiff file
;parameter: the number of the page in case of multipage file
Read_Image_Data: func [page] [
	clear image_data
	clear image_rgb
	
	Get_Image_Type page
	Read_Image_Tags page
	;now get the image data
	
	BStripOffsets: head  BStripOffsets
	BStripByteCounts: head BStripByteCounts
	StripsPerImage: to-integer (TImage/ImageLength + TImage/RowsPerStrip - 1 / TImage/RowsPerStrip)
	
	;Since each strip is a stream of bytes no endianess correction is needed.
	for i 1  StripsPerImage 1 [
	   startoff: pick BStripOffsets i 
	   data_length: to-integer (pick BStripByteCounts i) 
	   ;if TImage/BitsPerSample = 1 [data_length: to-integer data_length / 3]
	   tiff:  head tiff
   	   tiff:  skip tiff  to-integer startoff
   	   data: copy/part tiff ( data_length ) 
   	   append image_data data 
    ]
    
    if (Image_Type = "palette") [
		tiff:  head tiff
		skip tiff TImage/Colormap
		data: copy/part tiff TImage/ColorMapCount
   		append image_rgb data 
   	]
   	
   	;necessary for gray palette?
   	if (Image_Type = "grayscale") [
   		data: #{}
   		append image_rgb data 
   	]
 
   
]


Read_Tiff_File: has [files] [
	files: request-file/filter ["*.tiff" "*.tif"]
	either all [ 
			(not none? files) 
			(not empty? files)
	] [
			tiff: read/binary first files 
			Read_header 
			Make_IFD_List
 			Read_Image_Data 1
 			str: join "0 : " first files
 			return reduce [0 first files]
		]
		[return  reduce [1 "Non supported File"]]
]


; 2 functions for tiff file writing
; Décompose un Long en octets 
DecomposeLong: func [cL] [lstr: copy ""
 		x: to-char (mod cl 256)
 		append lstr x
 		x: to-char ( mod to-integer(cl / 256)  256)
 		append lstr x
 		x: to-char ( mod to-integer(cl / 65536) 256)
 		append lstr x
 		x: to-char (mod to-integer(cl / 16777216) 256)
		append lstr x
 		return lstr
]



WriteHexString: func [ str file][
	lg: to-integer length? str
	for i 1 lg 2 [a: pick str i   b: pick str i + 1 
	     		 c: join a b
	             HexStr: to-char to-integer to-issue c
	             write/binary/append file HexStr
	]
]



Write_Tiff_File: func [an_image] [
	;24 bit colour RGB TIFF creation from Paul Bourke'sample
	; get processor mode for file saving
	mode: trim/all to-string get-modes system:// 'endian
	
	files: request-file/filter/Save ["*.tiff" "*.tif"]
	either all [ 
			(not none? files) 
			(not empty? files)
	] [ nx: an_image/size/x ny: an_image/size/y
	
		wtiff: first files
		
		either ( mode = "little") [str: "II"] [str: "MM"] ; Header TIFF (Little or big Endian)
		write/binary wtiff str	;creates file
		either (mode = "little") [WriteHexString "2a00" wtiff] [WriteHexString "002a" wtiff] ; tiff magic number
		TOffset: nx * ny * 3 + 8; offset of the first IFD for a file with 1 RGB image (; located after the image data)
		s: DecomposeLong TOffset
		either (mode = "little") [write/binary/append wtiff s] [write/binary/append wtiff reverse s]  ;OK
	    ; image data
		trgb: an_image/rgb    ; rebol specific RGB
		talpha: an_image/alpha ; and alpha 
		write/binary/append wtiff trgb ;/* Write the binary data */  
		; The number of directory entries (14)
		either (mode = "little") [WriteHexString "0e00" wtiff] [WriteHexString "000e" wtiff] 
		

		; Image width tag, short int 
		either (mode = "little") [TagStr: "0001030001000000"] [TagStr: "0100000300000001"] 
		WriteHexString TagStr wtiff
		TOffset: nx
		s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff first s
                                  write/binary/append wtiff second s]
                                 [write/binary/append wtiff second s
                                  write/binary/append wtiff first s] 
        WriteHexString "0000" wtiff
       
        
		; Height tag, short int 
		Toffset: ny
		either (mode = "little") [TagStr: "0101030001000000"] [TagStr: "0101000300000001"]
		WriteHexString TagStr wtiff
        s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff first s
                                  write/binary/append wtiff second s]
                                 [write/binary/append wtiff second s
                                  write/binary/append wtiff first s] 
        WriteHexString "0000" wtiff
      

        ; Bits per sample tag, short int 
        TOffset: nx * ny * 3 + 182;
        either (mode = "little") [TagStr: "0201030003000000"] [TagStr: "0102000300000003"]
        WriteHexString TagStr wtiff
        s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff s] [write/binary/append wtiff reverse s]
        
        
		either (mode = "little") [TagStr: "030103000100000001000000"] [TagStr: "010300030000000100010000"]
		WriteHexString TagStr wtiff   ;Compression flag, short int : 1 none
		
	
		either (mode = "little") [TagStr: "060103000100000002000000"] [TagStr: "010600030000000100020000"]
        WriteHexString TagStr wtiff   ;  Photometric interpolation tag, short int: 2 RGB
        
       
        either (mode = "little") [TagStr: "110104000100000008000000"] [TagStr: "011100040000000100000008"]
        WriteHexString TagStr wtiff   ; Strip offset tag, long int  
        
        either (mode = "little") [TagStr: "120103000100000001000000"] [TagStr: "011200030000000100010000"]
        WriteHexString TagStr wtiff   ; Orientation flag, short int 1: Top and Left
        
        either (mode = "little") [TagStr: "150103000100000003000000"] [TagStr: "011500030000000100030000"]
        WriteHexString TagStr wtiff   ;Sample per pixel tag, short int 3 since RGB Image
       
         ; Rows per strip tag, short int 
        
        TOffset: ny
        either (mode = "little") [TagStr: "1601030001000000"] [TagStr: "0116000300000001"]
        WriteHexString TagStr wtiff
        s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff first s
                                  write/binary/append wtiff second s]
                                 [write/binary/append wtiff second s
                                  write/binary/append wtiff first s] 
        WriteHexString "0000" wtiff
        
        
        ;Strip byte count flag, long int 
        TOffset:  nx * ny * 3
        either (mode = "little") [TagStr: "1701040001000000"] [TagStr: "0117000400000001"]
        WriteHexString TagStr wtiff
      	s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff s] [write/binary/append wtiff reverse s]
		
		
		;Minimum sample value flag, short int 
		TOffset: nx * ny * 3 + 188
		either (mode = "little") [TagStr: "1801030003000000"] [TagStr: "0118000300000003"]
		WriteHexString TagStr wtiff
        s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff s] [write/binary/append wtiff reverse s]
		
		; Maximum sample value tag, short int 
		
		TOffset: nx * ny * 3 + 194
		either (mode = "little") [TagStr: "1901030003000000"] [TagStr: "0119000300000003"]
		WriteHexString TagStr wtiff
        s: DecomposeLong TOffset
        either (mode = "little") [write/binary/append wtiff s] [write/binary/append wtiff reverse s]
		
        
        either (mode = "little") [TagStr: "1c0103000100000001000000"] [TagStr: "011c00030000000100010000"]
		WriteHexString TagStr wtiff ;Planar configuration tag, short int 
		
		;Sample format tag, short int 
		TOffset: nx * ny * 3 + 200
		either (mode = "little") [TagStr: "5301030003000000"] [TagStr: "0153000300000003"]
		WriteHexString TagStr wtiff
		s: DecomposeLong TOffset 
        either (mode = "little") [write/binary/append wtiff s] [write/binary/append wtiff reverse s]
		
        
        
       
		
		
		WriteHexString "00000000" wtiff           ; End of the directory entry 
		either (mode = "little") [TagStr: "080008000800"] [TagStr: "000800080008"]
        WriteHexString TagStr wtiff       ;Bits for each RGB colour channel  */
        WriteHexString "000000000000" wtiff       ; Minimum value for each component (0) 
        either (mode = "little") [TagStr: "ff00ff00ff00"] [TagStr: "00ff00ff00ff"]
        WriteHexString TagStr wtiff       ; Maximum value per channel (255) 
        either (mode = "little") [TagStr: "010001000100"] [TagStr: "000100010001"]
        WriteHexString TagStr wtiff       ;Samples per pixel for each channel 
        
        
   		return 0
	   ]
	[return 1]	
]


   
 
   