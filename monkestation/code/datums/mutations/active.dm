/datum/mutation/human/consumption
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	quality = POSITIVE
	text_gain_indication = span_userdanger("You feel... How hungry?")
	text_lose_indication = span_notice("You don't feel quite so hungry anymore.")
	instability = 40
	power_path = /datum/action/cooldown/spell/pointed/consumption
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/consumption/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		REMOVE_TRAIT(owner, TRAIT_STABILIZED_EATER, GENETIC_MUTATION)

/datum/mutation/human/consumption/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/pointed/consumption/to_modify = .
	to_modify.healing_multiplier *= GET_MUTATION_POWER(src)
	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		ADD_TRAIT(owner, TRAIT_STABILIZED_EATER, GENETIC_MUTATION)

/datum/action/cooldown/spell/pointed/consumption
	name = "Eat Matter"
	desc = "Eat just about anything!"
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "regurgitate"

	cooldown_time = 1 MINUTE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	antimagic_flags = NONE
	cast_range = 1
	aim_assist = FALSE

	var/healing_multiplier = 1

/datum/action/cooldown/spell/pointed/consumption/IsAvailable(feedback = FALSE)
	if(owner)
		var/mob/living/carbon/human = owner
		if(istype(owner) && human.is_mouth_covered())
			if(feedback)
				owner.balloon_alert(owner, "mouth blocked!")
			return FALSE

	return ..()

/datum/action/cooldown/spell/pointed/consumption/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(ismegafauna(cast_on))
		cast_on.balloon_alert(owner, "???")
		to_chat(owner, span_userdanger("you are NOT eating a fucking [cast_on] no matter how hard you try"))
		return . | SPELL_CANCEL_CAST

	if(is_type_in_typecache(cast_on, GLOB.oilfry_blacklisted_items))
		cast_on.balloon_alert(owner, "A nuclear bomb looks tastier than this.")
		return . | SPELL_CANCEL_CAST

	if(ishuman(cast_on))
		var/mob/living/carbon/human/human_target = cast_on
		if(owner.zone_selected == BODY_ZONE_PRECISE_GROIN)
			var/message = pick(list("... You wouldn't.", "Nope.", "Better not.", "Not a good idea."))
			cast_on.balloon_alert(owner, message)
			return . | SPELL_CANCEL_CAST

		if(owner.zone_selected == BODY_ZONE_CHEST)
			cast_on.balloon_alert(owner, "too big!")
			return . | SPELL_CANCEL_CAST

		var/obj/item/bodypart/limb = human_target.get_bodypart(owner.zone_selected)
		if(!limb)
			cast_on.balloon_alert(owner, "nothing there!") // Is that a reference to project m-
			return . | SPELL_CANCEL_CAST

		if(owner.zone_selected == BODY_ZONE_HEAD)
			if(owner.pulling != cast_on)
				cast_on.balloon_alert(owner, "need grasp!")
				return . | SPELL_CANCEL_CAST

			if(owner.grab_state != GRAB_KILL)
				cast_on.balloon_alert(owner, "grasp too loose!")
				return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/consumption/cast(obj/cast_on)
	. = ..()
	var/mob/living/carbon/human/human_owner = owner
	if(istype(human_owner))
		if(istype(cast_on, /obj/machinery/power/apc) || istype(cast_on, /obj/structure/cable))
			if(!locate(/datum/mutation/human/insulated) in human_owner.dna.mutations) // last chance
				electrocute_mob(owner, cast_on, cast_on, always_shock = TRUE)
				return FALSE

	if(isturf(cast_on) || ismachinery(cast_on)|| istype(cast_on, /obj/structure/window))
		var/do_after_time = 45 SECONDS
		owner.visible_message(span_danger("[owner] begins stuffing [cast_on] into [owner.p_their()] gaping maw!"))
		if(istype(cast_on, /turf/closed/wall/r_wall))
			do_after_time *= 2

		if(!do_after(owner, do_after_time, cast_on))
			to_chat(owner, span_danger("You were interrupted before you could eat [cast_on]!"))
			return FALSE

		owner.visible_message(span_danger("[owner] eats [cast_on]."))
		playsound(owner.loc, 'sound/items/eatfood.ogg', 150, FALSE)
		cast_on.acid_melt()
		return TRUE

	if(ishuman(cast_on))
		var/mob/living/carbon/human/human_target = cast_on
		var/obj/item/bodypart/limb = human_target.get_bodypart(owner.zone_selected)

		owner.visible_message(span_danger("[owner] begins stuffing [human_target]'s [limb.name] into [owner.p_their()] gaping maw!"))
		if(!do_after(owner, 30 SECONDS, human_target))
			to_chat(owner, span_danger("You were interrupted before you could eat [cast_on]!"))
			return FALSE

		if(istype(human_owner) && HAS_TRAIT(human_owner, TRAIT_CLUMSY)) // Whoops, i bit off my head again
			if(prob(25))
				limb = human_owner.get_bodypart(owner.zone_selected)

		if(!limb || !human_target)
			return FALSE

		owner.visible_message(span_danger("[owner] [pick("chomps","bites")] off [cast_on]'s [limb]!"))
		playsound(owner.loc, 'sound/items/eatfood.ogg', 50, 0)

		// Most limbs will drop here. Groin won't, but this
		// still spills out the organs that were in it.
		limb.dismember(wounding_type = WOUND_PIERCE)
		Heal()
		return TRUE

	owner.visible_message(span_danger("[owner] eats [cast_on]."))
	playsound(owner.loc, 'sound/items/eatfood.ogg', 50, FALSE)
	Heal()
	if(istype(cast_on, /obj/machinery/power/apc) || istype(cast_on, /obj/structure/cable)) // Not good for eating
		qdel(cast_on)
		return TRUE

	cast_on.forceMove(owner)
	var/obj/brain
	if(istype(cast_on, /obj/item/organ/internal/brain))
		brain = cast_on
	else
		brain = locate(/obj/item/organ/internal/brain) in cast_on

	if(brain)
		INVOKE_ASYNC(src, PROC_REF(vomit_brain), brain)
	return TRUE

/datum/action/cooldown/spell/pointed/consumption/proc/Heal()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return

	human_owner.adjustBruteLoss(-15 * healing_multiplier)

/datum/action/cooldown/spell/pointed/consumption/proc/vomit_brain(obj/item/organ/internal/brain/brain)
	if(QDELETED(brain))
		return

	var/mob/living/carbon/human/human_owner = owner
	sleep(2.5 SECONDS)
	to_chat(owner, span_userdanger("You feel something sloshing around in your stomach..."))
	sleep(2.5 SECONDS)
	brain.forceMove(get_turf(owner))
	human_owner.vomit()
	step(brain, owner.dir)



/*
Jumpy:
Port from Paradise
20 Instablity
Add energizer chromosome to reduce cooldown
Add power chromosome to let it be used while being restrained/grabbed knocking down and stunning the grabber/restrainer
Add power chromosome letting you target a tile/object/mob to jump on
Add synchronizer chromosome reducing negative effects of failed jumps
Having hulk and or being Fat should increase damage of jumping on someone
*/
