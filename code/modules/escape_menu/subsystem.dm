/// Subsystem for controlling anything related to the escape menu
PROCESSING_SUBSYSTEM_DEF(escape_menu)
	name = "Escape Menu"
	flags = SS_NO_INIT | SS_HIBERNATE
	runlevels = ALL
	wait = 2 SECONDS
