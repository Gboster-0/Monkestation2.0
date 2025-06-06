
SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 1 SECONDS
	init_order = INIT_ORDER_RESEARCH
	//TECHWEB STATIC
	var/list/techweb_nodes = list() //associative id = node datum
	var/list/techweb_designs = list() //associative id = node datum

	///List of all techwebs.
	var/list/datum/techweb/techwebs = list()
	///The default Science Techweb.
	var/datum/techweb/science/science_tech
	///The default Admin Techweb.
	var/datum/techweb/admin/admin_tech

	var/datum/techweb_node/error_node/error_node //These two are what you get if a node/design is deleted and somehow still stored in a console.
	var/datum/design/error_design/error_design

	//ERROR LOGGING
	///associative id = number of times
	var/list/invalid_design_ids = list()
	///associative id = number of times
	var/list/invalid_node_ids = list()
	///associative id = error message
	var/list/invalid_node_boost = list()

	///associative id = TRUE
	var/list/techweb_nodes_starting = list()
	///category name = list(node.id = TRUE)
	var/list/techweb_categories = list()
	///List of all items that can unlock a node. (node.id = list(items))
	var/list/techweb_unlock_items = list()
	///Node ids that should be hidden by default.
	var/list/techweb_nodes_hidden = list()
	///Node ids that are exclusive to the BEPIS.
	var/list/techweb_nodes_experimental = list()
	///path = list(point type = value)
	var/list/techweb_point_items = list(
		/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	)
	var/list/errored_datums = list()
	///Associated list of all point types that techwebs will have and their respective 'abbreviated' name.
	var/list/point_types = list(
		TECHWEB_POINT_TYPE_GENERIC = "Gen. Res.",
		TECHWEB_POINT_TYPE_NANITES = "Nanite Res."
	)
	//----------------------------------------------
	var/list/single_server_income = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_SINGLE_SERVER_INCOME,
	)
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

	/// The global list of raw anomaly types that have been refined, for hard limits.
	var/list/created_anomaly_types = list()
	/// The hard limits of cores created for each anomaly type. For faster code lookup without switch statements.
	var/list/anomaly_hard_limit_by_type = list(
		/obj/item/assembly/signaler/anomaly/bluespace = MAX_CORES_BLUESPACE,
		/obj/item/assembly/signaler/anomaly/pyro = MAX_CORES_PYRO,
		/obj/item/assembly/signaler/anomaly/grav = MAX_CORES_GRAVITATIONAL,
		/obj/item/assembly/signaler/anomaly/vortex = MAX_CORES_VORTEX,
		/obj/item/assembly/signaler/anomaly/flux = MAX_CORES_FLUX,
		/obj/item/assembly/signaler/anomaly/hallucination = MAX_CORES_HALLUCINATION,
		/obj/item/assembly/signaler/anomaly/bioscrambler = MAX_CORES_BIOSCRAMBLER,
		/obj/item/assembly/signaler/anomaly/dimensional = MAX_CORES_DIMENSIONAL,
	)

	///our total xenobiology points
	var/xenobio_points
	/// Lookup list for ordnance briefers.
	var/list/ordnance_experiments = list()
	/// Lookup list for scipaper partners.
	var/list/datum/scientific_partner/scientific_partners = list()

	var/list/slime_core_prices = list()

	var/static/list/default_core_prices = list(
		SLIME_VALUE_TIER_1,
		SLIME_VALUE_TIER_2,
		SLIME_VALUE_TIER_3,
		SLIME_VALUE_TIER_4,
		SLIME_VALUE_TIER_5,
		SLIME_VALUE_TIER_6,
		SLIME_VALUE_TIER_7,
	)

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	populate_ordnance_experiments()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	error_design = new
	error_node = new
	initialize_slime_prices()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/research/fire()
	for(var/datum/techweb/techweb_list as anything in techwebs)
		if(!techweb_list.should_generate_points)
			continue
		var/list/bitcoins = list()
		for(var/obj/machinery/rnd/server/miner as anything in techweb_list.techweb_servers)
			if(miner.working)
				bitcoins = single_server_income.Copy()
				break //Just need one to work.

		if (techweb_list.nanite_bonus)
			bitcoins[TECHWEB_POINT_TYPE_GENERIC] += techweb_list.nanite_bonus

		if(!isnull(techweb_list.last_income))
			var/income_time_difference = world.time - techweb_list.last_income
			techweb_list.last_bitcoins = bitcoins  // Doesn't take tick drift into account
			for(var/i in bitcoins)
				bitcoins[i] *= (income_time_difference / 10) * techweb_list.income_modifier
			techweb_list.add_point_list(bitcoins)

		techweb_list.last_income = world.time

		if(length(techweb_list.research_queue_nodes))
			techweb_list.research_node_id(techweb_list.research_queue_nodes[1]) // Attempt to research the first node in queue if possible

			for(var/node_id in techweb_list.research_queue_nodes)
				var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
				if(node.is_free(techweb_list)) // Automatically research all free nodes in queue if any
					techweb_list.research_node(node)

	for(var/core_type in slime_core_prices)
		var/obj/item/slime_extract/core = core_type
		var/price_mod = rand(SLIME_RANDOM_MODIFIER_MIN * 1000000, SLIME_RANDOM_MODIFIER_MAX * 1000000) / 1000000
		var/price_limiter = 1 - ((default_core_prices[initial(core.tier)] * SLIME_SELL_MINIMUM_MODIFIER) / slime_core_prices[core_type])
		slime_core_prices[core_type] = (1 + price_mod * price_limiter) * slime_core_prices[core_type]

/datum/controller/subsystem/research/proc/initialize_slime_prices()
	for(var/core_type in subtypesof(/obj/item/slime_extract))
		var/obj/item/slime_extract/core = core_type
		if(!initial(core.tier))
			continue
		slime_core_prices[core_type] = default_core_prices[initial(core.tier)]

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = TRUE
		else
			techweb_categories[I.category] = list(I.id = TRUE)

/datum/controller/subsystem/research/proc/techweb_node_by_id(id)
	return techweb_nodes[id] || error_node

/datum/controller/subsystem/research/proc/techweb_design_by_id(id)
	return techweb_designs[id] || error_design

/datum/controller/subsystem/research/proc/on_design_deletion(datum/design/D)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN = techwebs[i]
		TN.on_design_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/on_node_deletion(datum/techweb_node/TN)
	for(var/i in techweb_nodes)
		var/datum/techweb_node/TN2 = techwebs[i]
		TN2.on_node_deletion(TN)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

/datum/controller/subsystem/research/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(techweb_nodes) && clearall)
		QDEL_LIST_ASSOC_VAL(techweb_nodes)
	if(islist(techweb_nodes_starting && clearall))
		techweb_nodes_starting.Cut()
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		if(returned[initial(TN.id)])
			stack_trace("WARNING: Techweb node ID clash with ID [initial(TN.id)] detected! Path: [path]")
			errored_datums[TN] = initial(TN.id)
			continue
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			techweb_nodes_starting[TN.id] = TRUE
	for(var/id in techweb_nodes)
		var/datum/techweb_node/TN = techweb_nodes[id]
		TN.Initialize()
	techweb_nodes = returned
	if (!verify_techweb_nodes()) //Verify all nodes have ids and such.
		stack_trace("Invalid techweb nodes detected")
	calculate_techweb_nodes()
	calculate_techweb_item_unlocking_requirements()
	if (!verify_techweb_nodes()) //Verify nodes and designs have been crosslinked properly.
		CRASH("Invalid techweb nodes detected")

/datum/controller/subsystem/research/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(techweb_designs) && clearall)
		QDEL_LIST_ASSOC_VAL(techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			stack_trace("WARNING: Design with null ID detected. Build path: [initial(DN.build_path)]")
			continue
		else if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		if(returned[initial(DN.id)])
			stack_trace("WARNING: Design ID clash with ID [initial(DN.id)] detected! Path: [path]")
			errored_datums[DN] = initial(DN.id)
			continue
		DN.InitializeMaterials() //Initialize the materials in the design
		returned[initial(DN.id)] = DN
	techweb_designs = returned
	verify_techweb_designs()


/datum/controller/subsystem/research/proc/verify_techweb_nodes()
	. = TRUE
	for(var/n in techweb_nodes)
		var/datum/techweb_node/N = techweb_nodes[n]
		if(!istype(N))
			WARNING("Invalid research node with ID [n] detected and removed.")
			techweb_nodes -= n
			research_node_id_error(n)
			. = FALSE
		for(var/p in N.prereq_ids)
			var/datum/techweb_node/P = techweb_nodes[p]
			if(!istype(P))
				WARNING("Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prereq_ids  -= p
				research_node_id_error(p)
				. = FALSE
		for(var/d in N.design_ids)
			var/datum/design/D = techweb_designs[d]
			if(!istype(D))
				WARNING("Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.design_ids -= d
				design_id_error(d)
				. = FALSE
		for(var/u in N.unlock_ids)
			var/datum/techweb_node/U = techweb_nodes[u]
			if(!istype(U))
				WARNING("Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlock_ids -= u
				research_node_id_error(u)
				. = FALSE
		for(var/p in N.required_items_to_unlock)
			if(!ispath(p))
				N.required_items_to_unlock -= p
				WARNING("[p] is not a valid path.")
				node_boost_error(N.id, "[p] is not a valid path.")
				. = FALSE
			var/list/points = N.required_items_to_unlock[p]
			if(!isnull(points))
				N.required_items_to_unlock -= p
				node_boost_error(N.id, "No valid list.")
				WARNING("No valid list.")
				. = FALSE
		CHECK_TICK

/datum/controller/subsystem/research/proc/verify_techweb_designs()
	for(var/d in techweb_designs)
		var/datum/design/D = techweb_designs[d]
		if(!istype(D))
			stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			techweb_designs -= d
		CHECK_TICK

/datum/controller/subsystem/research/proc/research_node_id_error(id)
	if(invalid_node_ids[id])
		invalid_node_ids[id]++
	else
		invalid_node_ids[id] = 1

/datum/controller/subsystem/research/proc/design_id_error(id)
	if(invalid_design_ids[id])
		invalid_design_ids[id]++
	else
		invalid_design_ids[id] = 1

/datum/controller/subsystem/research/proc/calculate_techweb_nodes()
	for(var/design_id in techweb_designs)
		var/datum/design/D = techweb_designs[design_id]
		D.unlocked_by.Cut()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
		for(var/i in node.design_ids)
			var/datum/design/D = techweb_designs[i]
			node.design_ids[i] = TRUE
			D.unlocked_by += node.id
		if(node.hidden)
			techweb_nodes_hidden[node.id] = TRUE
		if(node.experimental)
			techweb_nodes_experimental[node.id] = TRUE
		CHECK_TICK
	generate_techweb_unlock_linking()

/datum/controller/subsystem/research/proc/generate_techweb_unlock_linking()
	for(var/node_id in techweb_nodes) //Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = techweb_nodes[node_id]
		node.unlock_ids = list()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq_node = techweb_node_by_id(prereq_id)
			prereq_node.unlock_ids[node.id] = node

/datum/controller/subsystem/research/proc/calculate_techweb_item_unlocking_requirements()
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		for(var/path in node.required_items_to_unlock)
			if(!ispath(path))
				continue
			if(length(techweb_unlock_items[path]))
				techweb_unlock_items[path][node.id] = node.required_items_to_unlock[path]
			else
				techweb_unlock_items[path] = list(node.id = node.required_items_to_unlock[path])
		CHECK_TICK

/datum/controller/subsystem/research/proc/populate_ordnance_experiments()
	for (var/datum/experiment/ordnance/experiment_path as anything in subtypesof(/datum/experiment/ordnance))
		if (initial(experiment_path.experiment_proper))
			ordnance_experiments += new experiment_path()

	for(var/partner_path in subtypesof(/datum/scientific_partner))
		var/datum/scientific_partner/partner = new partner_path
		if(!partner.accepted_experiments.len)
			for (var/datum/experiment/ordnance/ordnance_experiment as anything in ordnance_experiments)
				partner.accepted_experiments += ordnance_experiment.type
		scientific_partners += partner
