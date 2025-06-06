#define ROBOTIC_LIGHT_BRUTE_MSG "marred"
#define ROBOTIC_MEDIUM_BRUTE_MSG "dented"
#define ROBOTIC_HEAVY_BRUTE_MSG "falling apart"

#define ROBOTIC_LIGHT_BURN_MSG "scorched"
#define ROBOTIC_MEDIUM_BURN_MSG "charred"
#define ROBOTIC_HEAVY_BURN_MSG "smoldering"

//For ye whom may venture here, split up arm / hand sprites are formatted as "l_hand" & "l_arm".
//The complete sprite (displayed when the limb is on the ground) should be named "borg_l_arm".
//Failure to follow this pattern will cause the hand's icons to be missing due to the way get_limb_icon() works to generate the mob's icons using the aux_zone var.

/obj/item/bodypart/arm/left/robot
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	limb_id = BODYPART_ID_ROBOTIC
	attack_verb_simple = list("slapped", "punched")
	inhand_icon_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_static = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_arm"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	dmg_overlay_type = "robotic"

	brute_modifier = 0.8
	burn_modifier = 0.8

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)
	disabling_threshold_percentage = 1
	var/adjusted = FALSE

/obj/item/bodypart/arm/left/robot/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	if(.)
		return TRUE
	wrench.play_tool_sound(src)
	if(adjusted)
		bodytype &= ~(BODYTYPE_DIGITIGRADE)
		bodytype |= (BODYTYPE_HUMANOID)
		adjusted = FALSE

	else
		bodytype &= ~(BODYTYPE_HUMANOID)
		bodytype |= (BODYTYPE_DIGITIGRADE)
		adjusted = TRUE
	to_chat(user, span_notice("You modify [src] to be installed on a [adjusted == TRUE ? "digitigrade" : "humanoid"] body."))

/obj/item/bodypart/arm/right/robot
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb_simple = list("slapped", "punched")
	inhand_icon_state = "buildpipe"
	icon_static = 'icons/mob/augmentation/augments.dmi'
	icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = BODYPART_ID_ROBOTIC
	flags_1 = CONDUCT_1
	icon_state = "borg_r_arm"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	dmg_overlay_type = "robotic"

	brute_modifier = 0.8
	burn_modifier = 0.8
	disabling_threshold_percentage = 1

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)
	var/adjusted = FALSE

/obj/item/bodypart/arm/right/robot/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	if(.)
		return TRUE
	wrench.play_tool_sound(src)
	if(adjusted)
		bodytype &= ~(BODYTYPE_DIGITIGRADE)
		bodytype |= (BODYTYPE_HUMANOID)
		adjusted = FALSE

	else
		bodytype &= ~(BODYTYPE_HUMANOID)
		bodytype |= (BODYTYPE_DIGITIGRADE)
		adjusted = TRUE
	to_chat(user, span_notice("You modify [src] to be installed on a [adjusted == TRUE ? "digitigrade" : "humanoid"] body."))

/obj/item/bodypart/leg/left/robot
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb_simple = list("kicked", "stomped")
	inhand_icon_state = "buildpipe"
	icon_static = 'icons/mob/augmentation/augments.dmi'
	icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = BODYPART_ID_ROBOTIC
	flags_1 = CONDUCT_1
	icon_state = "borg_l_leg"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	dmg_overlay_type = "robotic"

	brute_modifier = 0.8
	burn_modifier = 0.8
	disabling_threshold_percentage = 1

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)
	var/adjusted = FALSE

/obj/item/bodypart/leg/left/robot/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	if(.)
		return TRUE
	wrench.play_tool_sound(src)
	if(adjusted)
		bodytype &= ~(BODYTYPE_DIGITIGRADE)
		bodytype |= (BODYTYPE_HUMANOID)
		adjusted = FALSE

	else
		bodytype &= ~(BODYTYPE_HUMANOID)
		bodytype |= (BODYTYPE_DIGITIGRADE)
		adjusted = TRUE
	to_chat(user, span_notice("You modify [src] to be installed on a [adjusted == TRUE ? "digitigrade" : "humanoid"] body."))

/obj/item/bodypart/leg/right/robot
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb_simple = list("kicked", "stomped")
	inhand_icon_state = "buildpipe"
	icon_static =  'icons/mob/augmentation/augments.dmi'
	icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = BODYPART_ID_ROBOTIC
	flags_1 = CONDUCT_1
	icon_state = "borg_r_leg"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	dmg_overlay_type = "robotic"

	brute_modifier = 0.8
	burn_modifier = 0.8
	disabling_threshold_percentage = 1

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	biological_state = (BIO_ROBOTIC|BIO_JOINTED)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)
	var/adjusted = FALSE

/obj/item/bodypart/leg/right/robot/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	if(.)
		return TRUE
	wrench.play_tool_sound(src)
	if(adjusted)
		bodytype &= ~(BODYTYPE_DIGITIGRADE)
		bodytype |= (BODYTYPE_HUMANOID)
		adjusted = FALSE

	else
		bodytype &= ~(BODYTYPE_HUMANOID)
		bodytype |= (BODYTYPE_DIGITIGRADE)
		adjusted = TRUE
	to_chat(user, span_notice("You modify [src] to be installed on a [adjusted == TRUE ? "digitigrade" : "humanoid"] body."))

/obj/item/bodypart/chest/robot
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	inhand_icon_state = "buildpipe"
	icon_static =  'icons/mob/augmentation/augments.dmi'
	icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = BODYPART_ID_ROBOTIC
	flags_1 = CONDUCT_1
	icon_state = "borg_chest"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	dmg_overlay_type = "robotic"

	brute_modifier = 0.8
	burn_modifier = 0.8

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	biological_state = (BIO_ROBOTIC)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

	var/wired = FALSE
	var/obj/item/stock_parts/cell/cell = null
	var/adjusted = FALSE

/obj/item/bodypart/chest/robot/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	if(.)
		return TRUE
	wrench.play_tool_sound(src)
	if(adjusted)
		bodytype &= ~(BODYTYPE_DIGITIGRADE)
		bodytype |= (BODYTYPE_HUMANOID)
		adjusted = FALSE

	else
		bodytype &= ~(BODYTYPE_HUMANOID)
		bodytype |= (BODYTYPE_DIGITIGRADE)
		adjusted = TRUE
	to_chat(user, span_notice("You modify [src] to be installed on a [adjusted == TRUE ? "digitigrade" : "humanoid"] body."))


/obj/item/bodypart/chest/robot/get_cell()
	return cell

/obj/item/bodypart/chest/robot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null

/obj/item/bodypart/chest/robot/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/bodypart/chest/robot/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, span_warning("You have already inserted a cell!"))
			return
		else
			if(!user.transferItemToLoc(weapon, src))
				return
			cell = weapon
			to_chat(user, span_notice("You insert the cell."))
	else if(istype(weapon, /obj/item/stack/cable_coil))
		if(wired)
			to_chat(user, span_warning("You have already inserted wire!"))
			return
		var/obj/item/stack/cable_coil/coil = weapon
		if (coil.use(1))
			wired = TRUE
			to_chat(user, span_notice("You insert the wire."))
		else
			to_chat(user, span_warning("You need one length of coil to wire it!"))
	else
		return ..()

/obj/item/bodypart/chest/robot/wirecutter_act(mob/living/user, obj/item/cutter)
	. = ..()
	if(!wired)
		return
	. = TRUE
	cutter.play_tool_sound(src)
	to_chat(user, span_notice("You cut the wires out of [src]."))
	new /obj/item/stack/cable_coil(drop_location(), 1)
	wired = FALSE

/obj/item/bodypart/chest/robot/screwdriver_act(mob/living/user, obj/item/screwtool)
	..()
	. = TRUE
	if(!cell)
		to_chat(user, span_warning("There's no power cell installed in [src]!"))
		return
	screwtool.play_tool_sound(src)
	to_chat(user, span_notice("Remove [cell] from [src]."))
	cell.forceMove(drop_location())

/obj/item/bodypart/chest/robot/examine(mob/user)
	. = ..()
	if(cell)
		. += {"It has a [cell] inserted.\n
		[span_info("You can use a <b>screwdriver</b> to remove [cell].")]"}
	else
		. += span_info("It has an empty port for a <b>power cell</b>.")
	if(wired)
		. += "Its all wired up[cell ? " and ready for usage" : ""].\n"+\
		span_info("You can use <b>wirecutters</b> to remove the wiring.")
	else
		. += span_info("It has a couple spots that still need to be <b>wired</b>.")

/obj/item/bodypart/chest/robot/drop_organs(mob/user, violent_removal)
	var/atom/drop_loc = drop_location()
	if(wired)
		new /obj/item/stack/cable_coil(drop_loc, 1)
		wired = FALSE
	cell?.forceMove(drop_loc)
	return ..()

/obj/item/bodypart/head/robot
	name = "cyborg head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	inhand_icon_state = "buildpipe"
	icon_static = 'icons/mob/augmentation/augments.dmi'
	icon = 'icons/mob/augmentation/augments.dmi'
	limb_id = BODYPART_ID_ROBOTIC
	flags_1 = CONDUCT_1
	icon_state = "borg_head"
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodytype = BODYTYPE_HUMANOID | BODYTYPE_ROBOTIC
	change_exempt_flags = BP_BLOCK_CHANGE_SPECIES
	dmg_overlay_type = "robotic"

	brute_modifier = 0.8
	burn_modifier = 0.8

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	biological_state = (BIO_ROBOTIC)

	damage_examines = list(BRUTE = ROBOTIC_BRUTE_EXAMINE_TEXT, BURN = ROBOTIC_BURN_EXAMINE_TEXT, CLONE = DEFAULT_CLONE_EXAMINE_TEXT)

	head_flags = HEAD_EYESPRITES

	var/obj/item/assembly/flash/handheld/flash1 = null
	var/obj/item/assembly/flash/handheld/flash2 = null
	var/adjusted = FALSE

/obj/item/bodypart/head/robot/wrench_act(mob/living/user, obj/item/wrench)
	. = ..()
	if(.)
		return TRUE
	wrench.play_tool_sound(src)
	if(adjusted)
		bodytype &= ~(BODYTYPE_DIGITIGRADE)
		bodytype |= (BODYTYPE_HUMANOID)
		adjusted = FALSE

	else
		bodytype &= ~(BODYTYPE_HUMANOID)
		bodytype |= (BODYTYPE_DIGITIGRADE)
		adjusted = TRUE
	to_chat(user, span_notice("You modify [src] to be installed on a [adjusted == TRUE ? "digitigrade" : "humanoid"] body."))

/obj/item/bodypart/head/robot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == flash1)
		flash1 = null
	if(gone == flash2)
		flash2 = null

/obj/item/bodypart/head/robot/Destroy()
	QDEL_NULL(flash1)
	QDEL_NULL(flash2)
	return ..()

/obj/item/bodypart/head/robot/examine(mob/user)
	. = ..()
	if(!flash1 && !flash2)
		. += span_info("It has two empty eye sockets for <b>flashes</b>.")
	else
		var/single_flash = FALSE
		if(!flash1 || !flash2)
			single_flash = TRUE
			. += {"One of its eye sockets is currently occupied by a flash.\n
			[span_info("It has an empty eye socket for another <b>flash</b>.")]"}
		else
			. += "It has two eye sockets occupied by flashes."
		. += span_notice("You can remove the seated flash[single_flash ? "":"es"] with a <b>crowbar</b>.")

/obj/item/bodypart/head/robot/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/flash = weapon
		if(flash1 && flash2)
			to_chat(user, span_warning("You have already inserted the eyes!"))
			return
		else if(flash.burnt_out)
			to_chat(user, span_warning("You can't use a broken flash!"))
			return
		else
			if(!user.transferItemToLoc(flash, src))
				return
			if(flash1)
				flash2 = flash
			else
				flash1 = flash
			to_chat(user, span_notice("You insert the flash into the eye socket."))
			return
	return ..()

/obj/item/bodypart/head/robot/crowbar_act(mob/living/user, obj/item/prytool)
	..()
	if(flash1 || flash2)
		prytool.play_tool_sound(src)
		to_chat(user, span_notice("You remove the flash from [src]."))
		flash1?.forceMove(drop_location())
		flash2?.forceMove(drop_location())
	else
		to_chat(user, span_warning("There is no flash to remove from [src]."))
	return TRUE

/obj/item/bodypart/head/robot/drop_organs(mob/user, violent_removal)
	var/atom/drop_loc = drop_location()
	flash1?.forceMove(drop_loc)
	flash2?.forceMove(drop_loc)
	return ..()

// Prosthetics - Cheap, mediocre, and worse than organic limbs
// The fact they dont have a internal biotype means theyre a lot weaker defensively,
// since they skip slash and go right to blunt
// They are VERY easy to delimb as a result
// HP is also reduced just in case this isnt enough

/obj/item/bodypart/arm/left/robot/surplus
	name = "surplus prosthetic left arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon_static = 'icons/mob/augmentation/surplus_augments.dmi'
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	burn_modifier = 1
	brute_modifier = 1
	max_damage = 20

	biological_state = (BIO_METAL|BIO_JOINTED)

/obj/item/bodypart/arm/right/robot/surplus
	name = "surplus prosthetic right arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon_static = 'icons/mob/augmentation/surplus_augments.dmi'
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	burn_modifier = 1
	brute_modifier = 1
	max_damage = 20

	biological_state = (BIO_METAL|BIO_JOINTED)

/obj/item/bodypart/leg/left/robot/surplus
	name = "surplus prosthetic left leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon_static = 'icons/mob/augmentation/surplus_augments.dmi'
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	brute_modifier = 1
	burn_modifier = 1
	max_damage = 20

	biological_state = (BIO_METAL|BIO_JOINTED)

/obj/item/bodypart/leg/right/robot/surplus
	name = "surplus prosthetic right leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon_static = 'icons/mob/augmentation/surplus_augments.dmi'
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	brute_modifier = 1
	burn_modifier = 1
	max_damage = 20

	biological_state = (BIO_METAL|BIO_JOINTED)

// Advanced Limbs: More durable, high punching force

/obj/item/bodypart/arm/left/robot/advanced
	name = "advanced robotic left arm"
	desc = "An advanced cybernetic arm, capable of greater feats of strength and durability."
	icon_static = 'icons/mob/augmentation/advanced_augments.dmi'
	icon = 'icons/mob/augmentation/advanced_augments.dmi'
	unarmed_damage_low = 5
	unarmed_damage_high = 13
	max_damage = 75
	brute_modifier = 0.5
	burn_modifier = 0.5
	is_emissive = TRUE

/obj/item/bodypart/arm/right/robot/advanced
	name = "advanced robotic right arm"
	desc = "An advanced cybernetic arm, capable of greater feats of strength and durability."
	icon_static = 'icons/mob/augmentation/advanced_augments.dmi'
	icon = 'icons/mob/augmentation/advanced_augments.dmi'
	unarmed_damage_low = 5
	unarmed_damage_high = 13
	max_damage = 75
	brute_modifier = 0.5
	burn_modifier = 0.5
	is_emissive = TRUE

/obj/item/bodypart/leg/left/robot/advanced
	name = "advanced robotic left leg"
	desc = "An advanced cybernetic leg, capable of greater feats of strength and durability."
	icon_static = 'icons/mob/augmentation/advanced_augments.dmi'
	icon = 'icons/mob/augmentation/advanced_augments.dmi'
	unarmed_damage_low = 7
	unarmed_damage_high = 17
	max_damage = 75
	brute_modifier = 0.5
	burn_modifier = 0.5
	is_emissive = TRUE

/obj/item/bodypart/leg/right/robot/advanced
	name = "advanced robotic right leg"
	desc = "An advanced cybernetic leg, capable of greater feats of strength and durability."
	icon_static = 'icons/mob/augmentation/advanced_augments.dmi'
	icon = 'icons/mob/augmentation/advanced_augments.dmi'
	unarmed_damage_low = 7
	unarmed_damage_high = 17
	max_damage = 75
	brute_modifier = 0.5
	burn_modifier = 0.5
	is_emissive = TRUE

#undef ROBOTIC_LIGHT_BRUTE_MSG
#undef ROBOTIC_MEDIUM_BRUTE_MSG
#undef ROBOTIC_HEAVY_BRUTE_MSG

#undef ROBOTIC_LIGHT_BURN_MSG
#undef ROBOTIC_MEDIUM_BURN_MSG
#undef ROBOTIC_HEAVY_BURN_MSG
