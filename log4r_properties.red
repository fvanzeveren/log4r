Red [
	Title: "Properties file for log4r"
	File: %log4r_properties.red
	Auhthor: "François Vanzeveren"
	Date: 16-Jun-2021
	Version: 1.0.0
]


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
