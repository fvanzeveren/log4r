# log4r
A logging framework for REBOL and Red langages.
In log4r, logging messages are managed by "loggers". There are five loggers, each one managing a specific level of logging: DEBUG, INFO, WARN, ERROR and FATAL.
Each logger can be activated or disabled independently. When a logger is disabled, logging messages whose level is managed by the "logger" are no longer delivered.

## Guidelines for logging level
- fatal	The 'fatal level designates very severe error events that will presumably lead the application to abort.
- error	The 'error level designates error events that might still allow the application to continue running.
- warn	The 'warn level designates potentially harmful situations.
- info	The 'info level designates informational messages that highlight the progress of the application at coarse-grained level.
- debug	The 'debug Level designates fine-grained informational events that are most useful to debug an application.
