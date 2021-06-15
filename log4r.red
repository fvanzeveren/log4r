Red [
	File: %log4r.red
	Date: 15-Jun-2021
	Title: "Logging Framework For Rebol"
	Purpose: {Logging within the context of program development constitutes inserting statements 
		into the program that provide some kind of output information that is useful to the developer. 
		Examples of logging are trace statements, dumping of structures and the familiar 'prin or 
		'print debug statements. log4r offers a hierarchical way to insert logging statements within 
		a Rebol program. Multiple output formats and multiple levels of logging information are available.
		By using log4r, the overhead of maintaining thousands of 'print statements is alleviated as 
		the logging may be controlled at runtime from configuration scripts. log4r maintains the log 
		statements in the shipped code. By formalising the process of logging, some feel that one is 
		encouraged to use logging more and with higher degree of usefulness.}
	Library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		Domain: [debug testing]
		Tested-under: none
        Support: none
        License: 'gpl
        see-also: none
	]
	Version: 2.2.0
	
	Author: "Francois Vanzeveren"

	History: [
		0.0.1 [21-Nov-2003 "Created this file" "Francois"]
		0.0.2 [23-Nov-2003 {Modified implementation. The previous one 
				could not properly handle applications made of several 
				modules/scripts. I therefore change the way it works.} "Francois"]
		0.0.3 [27-Nov-2003 "Added /msg and /data refinements to specify the message and the data to log" "Francois"]
		0.0.4 [30-Nov-2003 {
			+ 'log function made global.
			+ Fixed and improved error logging
		} "Francois"]
		1.0.0 [1-Dec-2003 "First Public Release." "Francois"]
		1.1.0 [29-Dec-2003 {BUG FIX: an error occured when logging a block with words without meaning.
				Blocks are reduced using 'remold before being included in the error message. This triggered an error
				on blocks with words without meaning. On such blocks, 'mold is now applied rather than 'remold
		} "Francois"]
		2.0.0 [19-Sep-2004 {The framework has been enhanced and extended to
				handle appenders and layouts. New appenders and layouts can
				be easily added to the log4reb framework.
				Implemented appenders:
					+ console-appender
					+ file-appender
				Implemented layout:
					+ pattern-layout
		} "Francois"]
		2.0.1 [20-Sep-2004 {The level argument of the 'log function has been 
				replaced by refinements for clarity purpose. The available 
				refinements are /debug /info /warn /error /fatal} "Francois"
		]
		2.0.2 [3-Jul-2005 "Rebol header modified to comply with Rebol.org standards" "Francois"]
		2.0.3 [27-Jul-2005 {BUG Fix: local variable 'the-msg of 'log function holds a series and 
				the problem described at http://www.rebol.com/docs/core23/rebolcore-9.html#section-3.6 
				occured.} "Francois"]
		2.0.4 [28-Jul-2005 "Error formatting improved." "Francois"]
		2.0.5 [21-Aug-2005 {'init-log4reb can now be called mutiple times without 
							overriding existing loggers, appenders and layouts.} "Francois"]
		2.0.6 [16-Feb-2006 {New /override refinement to override existing loggers, appenders and layouts.} "Francois"]
		2.1.0 [14-Jun-2021 {Script ported to Red and renamed 'log4r'} "Francois"]
		2.2.0 [15-Jun-2021 {
			- Improved 'format method in 'pattern-layout object!
			- New line bug fixed in file appender}  "Francois"]
	]
]

log4r: context [
;	Possible levels:
;		'fatal	The 'fatal level designates very severe error events that will presumably lead the application to abort.
;		'error	The 'error level designates error events that might still allow the application to continue running.
;		'warn	The 'warn level designates potentially harmful situations.
;		'info	The 'info level designates informational messages that highlight the progress of the application at coarse-grained level.
;		'debug	The 'debug Level designates fine-grained informational events that are most useful to debug an application.

	_level-labels: make block! [fatal "FATAL" error "ERROR"  warn "WARN " info "INFO " debug "DEBUG"]
	
	_loggers: none
	_appenders: none
	_layouts: none
	
	; Skeleton of a logger
	logger!: make object! [
		level: active: appenders: none 
		
		log: func [usr-msg [string!] /local app] [
			forall appenders [
				app: select _appenders first appenders
				app/append usr-msg self
			]
			appenders: head appenders
		]
	]
	
	; ******************************* APPENDERS *******************************
	
	; Skeleton of an appender:	
	appender!: make object! [
		name: layout: logger: none
	]
	
	console-appender!: make appender! [
		append: func [usr-msg [string!] the-logger [object!]
			/local msg lay
		] [
			logger: the-logger
			lay: select _layouts layout
			msg: lay/format usr-msg self
			print msg
		]
	]
	
	file-appender!: make appender! [
		out: none
		
		append: func [usr-msg [string!] the-logger [object!] 
			/local msg lay path target
		] [
			logger: the-logger
			lay: select _layouts layout
			msg: lay/format usr-msg self
			set [path target] split-path out
			if not exists? path [make-dir/deep path]
			attempt [
				write/append/lines out msg
			]
		]
	]
	
	; ******************************** LAYOUTS ********************************
	
	;=====================================
	; Pattern Layout
	; ---------------
	; %c	logger name
	; %d\\dd MMM yyyy HH:MM:ss,SSS\\ Date
	; %m user-defined message
	; %p Level
	; %r Milliseconds since program start ; NOT YET IMPLEMENTED
	; %% individual percentage sign
	;=====================================
	pattern-layout!: make object! [
		name: none
		pattern: none
		
		format: func [usr-msg [string!] appender [object!] 
			/local sep nnow nnow-splitted msg date-format c 
		] [
			sep: charset "/+.-:"
			nnow: now/precise 						; 15-Jun-2021/9:23:42.1185+02:00
			nnow-splitted: split to-string nnow sep ; ["15" "Jun" "2021" "9" "23" "42" "1185" "02" "00"]
			msg: copy ""
			parse pattern [ any [
				"%d\\" copy date-format to "\\" (
					parse date-format [ any [
						"day"   	(append msg nnow/day) |					; 15
						"weekday"	(append msg nnow/weekday) |				; 2
						"m" 		(append msg nnow/month ) |				; 6
						"month"		(append msg second nnow-splitted) |		; "Jun"
						"year" 		(append msg nnow/year) |				; 2021
						"yearday" 	(append msg nnow/year)day |				; 166
						"date" 		(append msg nnow/date) |				; 15-Jun-2021
						"time" 		(append msg nnow/time) |				; 9:23:42.1185
						"HH" 		(append msg fourth nnow-splitted) |		; 9
						"MM" 		(append msg fifth nnow-splitted) |		; 23
						"SSS" 		(append msg nnow-splitted/7) |			; 1185
						"SS" 		(append msg nnow-splitted/6) |			; 42
						copy c skip (append msg c)
					]]
				) thru "\\" |
				"%m" (append msg usr-msg) |
				"%p" (append msg select _level-labels appender/logger/level) |
				"%%" (append msg "%") |
				copy c skip (append msg c)
			]]
			return msg
		]
	]
	
	
	set 'init-log4r func [
		the-loggers [block!]
		the-appenders [block!]
		the-layouts [block!]
		/override "Overrides existing configuration."
		/local obj
	] [
		if any [override none? _loggers] [_loggers: make hash! []]
		if any [override none? _appenders] [_appenders: make hash! []]
		if any [override none? _layouts] [_layouts: make hash! []]
		
		foreach [level args] the-loggers [
			obj: make logger! args
			obj/level: level
			repend _loggers [level obj]
		]
		foreach [name appender-type args] the-appenders [
			obj: make get in log4r appender-type args
			obj/name: name
			repend _appenders [name obj]
		]
		foreach [name layout-type args] the-layouts [
			obj: make get in log4r layout-type args
			obj/name: name
			repend _layouts [name obj]
		]
	]

	set 'log function [ 
		/debug /info /warn /error /fatal
		/msg the-msg [string!]
		/data the-data [any-type!]
		/local error-str tmp-block logger level 
	] [
		level: select reduce [debug 'debug info 'info warn 'warn error 'error fatal 'fatal] true
		logger: select _loggers level
		if logger/active 
		[
			; To avoid the side effect of local variables that hold series
			; as described at http://www.rebol.com/docs/core23/rebolcore-9.html#section-3.6
			either msg [the-msg: copy the-msg] [the-msg: copy ""]
			trim/lines the-msg
			if error? the-data [
				tmp-block: make block! []
				error-str: rejoin [
					"** "
					get in 
						get in system/error 
							get in disarm the-data 'type 
						'type 
					": "
					reform bind append tmp-block 
						get in 
							get in system/error 
								get in disarm the-data 'type 
							get in disarm the-data 'id 
					in disarm the-data 'arg1 
					" - Near: "
					mold get in disarm the-data 'near
					" **"
				]
			]
			if data [
				append the-msg join " " trim/lines 
					either error? the-data 
						[error-str] 
						[ 
							use [tmp] [
								if error? tmp: try [remold the-data] [
									tmp: mold the-data
								]
								tmp
							]
						]
			]
			logger/log the-msg
		]
    ]
	
	attempt: func [
		{Tries to evaluate and returns result or NONE on error.}
		value
	][
		if not error? set/any 'value try :value [get/any 'value]
	]
]

; The following is a skeleton for the properties file.
; Copy this to a seperate file and adapt it to your needs.
; Then you do:
; do %log4r.r
; do %log4r.properties ; if you called the properties file log4r.properties

comment {
	; <logger level> <constructor arguments>
	;--------------------------------------
	;	Possible levels:
	;		'fatal	The 'fatal level designates very severe error events that will presumably lead the application to abort.
	;		'error	The 'error level designates error events that might still allow the application to continue running.
	;		'warn	The 'warn level designates potentially harmful situations.
	;		'info	The 'info level designates informational messages that highlight the progress of the application at coarse-grained level.
	;		'debug	The 'debug Level designates fine-grained informational events that are most useful to debug an application.
	
	log4r-loggers: make block! [
		debug 	[active: true appenders: [debug]]
		info 	[active: true appenders: [debug]]
		warn 	[active: true appenders: [debug console]]
		error 	[active: true appenders: [debug console fatality]]
		fatal 	[active: true appenders: [debug console fatality]]
	]
	
	; <appender name> <appender type> <constructor arguments>
	log4r-appenders: make block! [
		console		console-appender! 	[layout: 'short]
		debug 		file-appender! 		[layout: 'long out: %debug.log]
		fatality 	file-appender! 		[layout: 'long out: %fatality.log]
	]
	
	; <layout name> <layout type> <constructor arguments>
		; Pattern Layout
		; ---------------
		; %d\\day weekday m month year yearday date time HH MM SS SSS\\ --> Date and time
		; %m --> user-defined message
		; %p --> Level
		; %r --> Milliseconds since program start ; NOT YET IMPLEMENTED
		; %% --> individual percentage sign
	log4r-layouts: make block! [
		short 	pattern-layout! 	[pattern: "[%p] %d\\time\\ - %m."]
		long 	pattern-layout!  	[pattern: "[%p] %d\\date@time\\ - %m."]
	]
	
	init-log4r/override log4r-loggers log4r-appenders log4r-layouts
}
