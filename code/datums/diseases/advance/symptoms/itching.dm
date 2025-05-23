/*
//////////////////////////////////////

Itching

	Not noticeable or unnoticeable.
	Resistant.
	Increases stage speed.
	Little transmissibility.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/itching

	name = "Itching"
	desc = "The virus irritates the skin, causing itching."
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmission = 1
	level = 1
	severity = 0
	symptom_delay_min = 5
	symptom_delay_max = 25
	prefixes = list("Irritant ")
	bodies = list("Itch")
	var/scratch = FALSE
	threshold_desc = "<b>Transmission 6:</b> Increases frequency of itching.<br>\
						<b>Stage Speed 7:</b> The host will scrath itself when itching, causing superficial damage."

/datum/symptom/itching/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 6) //itch more often
		symptom_delay_min = 1
		symptom_delay_max = 4
	if(A.stage_rate >= 7) //scratch
		scratch = TRUE

/datum/symptom/itching/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat >= DEAD)
		return
	var/picked_bodypart = pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/obj/item/bodypart/bodypart = M.get_bodypart(picked_bodypart)
	if(bodypart && (IS_ORGANIC_LIMB(bodypart)) && !bodypart.is_pseudopart)	 //robotic limbs will mean less scratching overall
		var/can_scratch = scratch && !M.incapacitated() && get_location_accessible(M, picked_bodypart)
		M.visible_message("[can_scratch ? span_warning("[M] scratches [M.p_their()] [bodypart.name].") : ""]", span_notice("Your [bodypart.name] itches. [can_scratch ? " You scratch it." : ""]"))
		if(can_scratch)
			bodypart.receive_damage(0.5)
