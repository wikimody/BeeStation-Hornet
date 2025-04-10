/datum/game_mode
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	report_type = "traitor"
	role_preference = /datum/role_preference/antagonist/traitor
	antag_datum = /datum/antagonist/traitor
	false_report_weight = 20 //Reports of traitors are pretty common.
	restricted_jobs = list(JOB_NAME_CYBORG)//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1

	announce_span = "danger"
	announce_text = "There are Syndicate agents on the station!\n \
	" + span_danger("Traitors") + ": Accomplish your objectives.\n \
	" + span_notice("Crew") + ": Do not let the traitors succeed!"

	title_icon = "traitor"

	var/list/datum/mind/pre_traitors = list()
	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.
	var/traitors_required = TRUE //Will allow no traitors


/datum/game_mode/traitor/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)

	var/num_traitors = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_traitors = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = antag_pick(antag_candidates, /datum/role_preference/antagonist/traitor)
		pre_traitors += traitor
		traitor.special_role = traitor_name
		traitor.restricted_roles = restricted_jobs
		GLOB.pre_setup_antags += traitor
		log_game("[key_name(traitor)] has been selected as a [traitor_name]")
		antag_candidates.Remove(traitor)

	var/enough_tators = !traitors_required || pre_traitors.len > 0

	if(!enough_tators)
		setup_error = "Not enough traitor candidates"
		return FALSE
	else
		return TRUE


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/new_antag = new antag_datum()
		addtimer(CALLBACK(traitor, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(10,100))
		GLOB.pre_setup_antags -= traitor
	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
	..()

	//We're not actually ready until all traitors are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

/datum/game_mode/traitor/make_antag_chance(mob/living/carbon/human/character) //Assigns traitor to latejoiners
	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	var/traitorcap = min(round(GLOB.joined_player_list.len / (tsc * 2)) + 2 + num_modifier, round(GLOB.joined_player_list.len / tsc) + num_modifier)
	if((SSticker.mode.traitors.len + pre_traitors.len) >= traitorcap) //Upper cap for number of latejoin antagonists
		return
	if((SSticker.mode.traitors.len + pre_traitors.len) <= (traitorcap - 2) || prob(100 / (tsc * 2)))
		if(!QDELETED(character) && character.client?.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime),
		))
			if(!(character.job in restricted_jobs))
				add_latejoin_traitor(character.mind)

/datum/game_mode/traitor/proc/add_latejoin_traitor(datum/mind/character)
	var/datum/antagonist/traitor/new_antag = new antag_datum()
	character.add_antag_datum(new_antag)

/datum/game_mode/traitor/generate_report()
	return "Although more specific threats are commonplace, you should always remain vigilant for Syndicate agents aboard your station. Syndicate communications have implied that many \
		Nanotrasen employees are Syndicate agents with hidden memories that may be activated at a moment's notice, so it's possible that these agents might not even know their positions."


/datum/game_mode/traitor/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The [syndicate_name()] Spies:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/traitor in traitors)
		round_credits += "<center><h2>[traitor.name] as a [syndicate_name()] traitor</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The traitors have concealed their treachery!</h2>", "<center><h2>We couldn't locate them!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
