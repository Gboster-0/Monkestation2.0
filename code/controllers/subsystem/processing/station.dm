PROCESSING_SUBSYSTEM_DEF(station)
	name = "Station"
	init_order = INIT_ORDER_STATION
	flags = SS_BACKGROUND | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME
	wait = 5 SECONDS

	///A list of currently active station traits
	var/list/station_traits = list()
	///Assoc list of trait type || assoc list of traits with weighted value. Used for picking traits from a specific category.
	var/list/selectable_traits_by_types = list(STATION_TRAIT_POSITIVE = list(), STATION_TRAIT_NEUTRAL = list(), STATION_TRAIT_NEGATIVE = list())
	///Currently active announcer. Starts as a type but gets initialized after traits are selected
	var/datum/centcom_announcer/announcer = /datum/centcom_announcer/default

/datum/controller/subsystem/processing/station/Initialize()

	//If doing unit tests we don't do none of that trait shit ya know?
	// Autowiki also wants consistent outputs, for example making sure the vending machine page always reports the normal products
	#if !defined(UNIT_TESTS) && !defined(AUTOWIKI)
	SetupTraits()
	#endif

	announcer = new announcer() //Initialize the station's announcer datum

	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/station/Recover()
	station_traits = SSstation.station_traits.Copy()
	selectable_traits_by_types = deep_copy_list(SSstation.selectable_traits_by_types)
	announcer = SSstation.announcer

///Rolls for the amount of traits and adds them to the traits list
/datum/controller/subsystem/processing/station/proc/SetupTraits()
	if (CONFIG_GET(flag/forbid_station_traits))
		return

	if (fexists(FUTURE_STATION_TRAITS_FILE))
		var/forced_traits_contents = file2text(FUTURE_STATION_TRAITS_FILE)
		fdel(FUTURE_STATION_TRAITS_FILE)

		var/list/forced_traits_text_paths = json_decode(forced_traits_contents)
		forced_traits_text_paths = SANITIZE_LIST(forced_traits_text_paths)

		for (var/trait_text_path in forced_traits_text_paths)
			var/station_trait_path = text2path(trait_text_path)
			if (!ispath(station_trait_path, /datum/station_trait) || station_trait_path == /datum/station_trait)
				var/message = "Invalid station trait path [station_trait_path] was requested in the future station traits!"
				log_game(message)
				message_admins(message)
				continue

			setup_trait(station_trait_path)

		return

	for(var/i in subtypesof(/datum/station_trait))
		var/datum/station_trait/trait_typepath = i

		// If forced, (probably debugging), just set it up now, keep it out of the pool.
		if(initial(trait_typepath.force))
			setup_trait(trait_typepath)
			continue

		if(initial(trait_typepath.trait_flags) & STATION_TRAIT_ABSTRACT)
			continue //Dont add abstract ones to it
		selectable_traits_by_types[initial(trait_typepath.trait_type)][trait_typepath] = initial(trait_typepath.weight)

	var/positive_trait_count = pick(4;0, 3;1, 2;2, 1;3)
	var/neutral_trait_count = pick(3;0, 6;1, 3;2, 1;3)
	var/negative_trait_count = pick(4;0, 3;1, 2;2, 1;3)

	pick_traits(STATION_TRAIT_POSITIVE, positive_trait_count)
	pick_traits(STATION_TRAIT_NEUTRAL, neutral_trait_count)
	pick_traits(STATION_TRAIT_NEGATIVE, negative_trait_count)

///Picks traits of a specific category (e.g. bad or good) and a specified amount, then initializes them, adds them to the list of traits,
///then removes them from possible traits as to not roll twice.
/datum/controller/subsystem/processing/station/proc/pick_traits(trait_sign, amount)
	if(!amount)
		return
	for(var/iterator in 1 to amount)
		var/datum/station_trait/trait_type = pick_weight(selectable_traits_by_types[trait_sign]) //Rolls from the table for the specific trait type
		selectable_traits_by_types[trait_sign] -= trait_type
		if(istype(trait_type, /datum/station_trait/late_arrivals) && SSmapping.current_map.map_name == "Oshan Station")
			amount++
			continue
		setup_trait(trait_type)

///Creates a given trait of a specific type, while also removing any blacklisted ones from the future pool.
/datum/controller/subsystem/processing/station/proc/setup_trait(datum/station_trait/trait_type)
	var/datum/station_trait/trait_instance = new trait_type()
	station_traits += trait_instance
	log_game("Station Trait: [trait_instance.name] chosen for this round.")
	if(!trait_instance.blacklist)
		return
	for(var/i in trait_instance.blacklist)
		var/datum/station_trait/trait_to_remove = i
		selectable_traits_by_types[initial(trait_to_remove.trait_type)] -= trait_to_remove
