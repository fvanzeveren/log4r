# log4r
A logging framework for REBOL and Red langages.
In log4r, logging messages are managed by "loggers". There are five loggers, each one managing a specific level of logging: DEBUG, INFO, WARN, ERROR and FATAL.
Each logger can be activated or disabled independently. When a logger is disabled, logging messages whose level is managed by the "logger" are no longer delivered.
