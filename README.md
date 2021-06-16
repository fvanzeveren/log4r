# log4r
A logging framework for REBOL and Red langages.
## Overview
In log4r, logging messages are managed by "loggers". There are five loggers, one per level of logging: DEBUG, INFO, WARN, ERROR and FATAL.

Each logger can be activated or disabled independently. When a logger is disabled, logging messages whose level is managed by the "logger" are no longer delivered.

Loggers delegate the actual delivery of logging messages to "appenders". You can link as many appenders as you like to a logger. The logger will instruct each appender to deliver logging messages for which the logger is responsible (i.e. depending on the level of the logging message).
## Guidelines for logging level
- fatal, designates very severe error events that will presumably lead the application to abort.
- error, designates error events that might still allow the application to continue running.
- warn, designates potentially harmful situations.
- info, designates informational messages that highlight the progress of the application at coarse-grained level.
- debug, designates fine-grained informational events that are most useful to debug an application.
