////////////// I don't know who made this header before I refactored alcohols but I'm going to fucking strangle them because it was so ugly, holy Christ
// ALCOHOLS //
//////////////

/datum/reagent/consumable/ethanol
	name = "Ethanol"
	description = "A well-known alcohol with a variety of applications."
	color = "#404030" // rgb: 64, 64, 48
	nutriment_factor = 0
	taste_description = "alcohol"
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	var/boozepwr = 65 //Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning

/*
Boozepwr Chart
Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts (i.e. light poisoning inherts from slight poisoning)
In addition, severe effects won't always trigger unless the drink is poisonously strong
All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance

0: Non-alcoholic
1-10: Barely classifiable as alcohol - occasional slurring
11-20: Slight alcohol content - slurring
21-30: Below average - imbiber begins to look slightly drunk
31-40: Just below average - no unique effects
41-50: Average - mild disorientation, imbiber begins to look drunk
51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
71-80: High alcohol content - blurry vision, imbiber completely shitfaced
81-90: Extremely high alcohol content - heavy toxin damage, passing out
91-100: Dangerously toxic - swift death
*/

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	if(C.drunkenness < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER)
		var/booze_power = boozepwr
		if(HAS_TRAIT(C, TRAIT_ALCOHOL_TOLERANCE)) //we're an accomplished drinker
			booze_power *= 0.7
		if(HAS_TRAIT(C, TRAIT_LIGHT_DRINKER))
			if(booze_power < 0)
				booze_power *= -1
			else
				booze_power *= 2
		C.drunkenness = max((C.drunkenness + (sqrt(volume) * booze_power * ALCOHOL_RATE * REM * delta_time)), 0) //Volume, power, and server alcohol rate effect how quickly one gets drunk
		if(C.drunkenness >= 250)
			C.client?.give_award(/datum/award/achievement/misc/drunk, C)
		var/obj/item/organ/liver/L = C.getorganslot(ORGAN_SLOT_LIVER)
		if (istype(L))
			L.applyOrganDamage(((max(sqrt(volume) * (boozepwr ** ALCOHOL_EXPONENT) * L.alcohol_tolerance * delta_time, 0))/150))
	return ..()

/datum/reagent/consumable/ethanol/expose_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/paper))
		var/obj/item/paper/paperaffected = O
		paperaffected.clear_paper()
		to_chat(usr, span_notice("[paperaffected]'s ink washes away."))
	if(istype(O, /obj/item/book))
		if(reac_volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			O.visible_message(span_notice("[O]'s writing is washed away by [name]!"))
		else
			O.visible_message(span_warning("[O]'s ink is smeared by [name], but doesn't wash away!"))
	return

/datum/reagent/consumable/ethanol/expose_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!isliving(M))
		return

	if(method in list(TOUCH, VAPOR, PATCH))
		M.adjust_fire_stacks(reac_volume / 15)

		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/power_multiplier = boozepwr / 65 // Weak alcohol has less sterilizing power

			for(var/s in C.surgeries)
				var/datum/surgery/S = s
				S.speed_modifier = max(0.1*power_multiplier, S.speed_modifier)
				// +10% surgery speed on each step, useful while operating in less-than-perfect conditions
	return ..()

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. Still popular today."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "piss water"
	glass_icon_state = "beerglass"
	glass_name = "glass of beer"
	glass_desc = "A freezing pint of beer."

/datum/reagent/consumable/ethanol/ftliver
	name = "Faster-Than-Liver"
	description = "A beverage born among the stars, it's said drinking too much feels just like FTL transit."
	color = "#0D0D0D" // rgb: 13, 13, 13
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 52
	taste_description = "empty space"
	glass_icon_state = "ftliver"
	glass_name = "glass of Faster-Than-Liver"
	glass_desc = "My god, it's full of stars!"
	var/HasTraveled = 0

/datum/reagent/consumable/ethanol/ftliver/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!HasTraveled && prob(volume))
		HasTraveled = 1
		M.AdjustKnockdown(15)
		M.become_nearsighted("ftliver")
		shake_camera(M,15)
		M.playsound_local(M.loc,"sound/effects/hyperspace_end.ogg",50)
		addtimer(CALLBACK(src, PROC_REF(Recover), M), 55)
	return ..()

/datum/reagent/consumable/ethanol/ftliver/proc/Recover(mob/living/M)
	M.cure_nearsighted("ftliver")

/datum/reagent/consumable/ethanol/beer/light
	name = "Light Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety has reduced calorie and alcohol content."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 5 //Space Europeans hate it
	taste_description = "dish water"
	glass_name = "glass of light beer"
	glass_desc = "A freezing pint of watery light beer."

/datum/reagent/consumable/ethanol/beer/green
	name = "Green Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is dyed a festive green."
	color = "#A8E61D"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "green piss water"
	glass_icon_state = "greenbeerglass"
	glass_name = "glass of green beer"
	glass_desc = "A freezing pint of green beer. Festive."

/datum/reagent/consumable/ethanol/beer/green/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.color != color)
		M.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)
	return ..()

/datum/reagent/consumable/ethanol/beer/green/on_mob_end_metabolize(mob/living/M)
	M.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	glass_icon_state = "kahluaglass"
	glass_name = "glass of RR coffee liquor"
	glass_desc = "DAMN, THIS THING LOOKS ROBUST!"
	shot_glass_icon_state = "shotglasscream"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.dizziness = max(M.dizziness - (5 * REM * delta_time), 0)
	M.drowsyness = max(M.drowsyness - (3 * REM * delta_time), 0)
	M.AdjustSleeping(-40 * REM * delta_time)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.Jitter(5)
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 75
	taste_description = "molasses"
	glass_icon_state = "whiskeyglass"
	glass_name = "glass of whiskey"
	glass_desc = "The silky, smokey whiskey goodness inside the glass makes the drink look very classy."
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 80
	quality = DRINK_GOOD
	overdose_threshold = 60
	addiction_threshold = 30
	taste_description = "jitters and death"
	glass_icon_state = "thirteen_loko_glass"
	glass_name = "glass of Thirteen Loko"
	glass_desc = "This is a glass of Thirteen Loko, it appears to be of the highest quality. The drink, not the glass."

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.drowsyness = max(M.drowsyness - (7 * REM * delta_time))
	M.AdjustSleeping(-40 * REM * delta_time)
	M.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, M.get_body_temp_normal())
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.Jitter(5)
	return ..()

/datum/reagent/consumable/ethanol/thirteenloko/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("Your entire body violently jitters as you start to feel queasy. You really shouldn't have drank all of that [name]!"))
	M.Jitter(20)
	M.Stun(15)

/datum/reagent/consumable/ethanol/thirteenloko/overdose_process(mob/living/M, delta_time, times_fired)
	if(DT_PROB(3.5, delta_time) && iscarbon(M))
		var/obj/item/I = M.get_active_held_item()
		if(I)
			M.dropItemToGround(I)
			to_chat(M, span_notice("Your hands jitter and you drop what you were holding!"))
			M.Jitter(10)

	if(DT_PROB(3.5, delta_time))
		to_chat(M, span_notice("[pick("You have a really bad headache.", "Your eyes hurt.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")]"))

	if(DT_PROB(2.5, delta_time) && iscarbon(M))
		var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
		if(M.is_blind())
			if(istype(eyes))
				eyes.Remove(M)
				eyes.forceMove(get_turf(M))
				to_chat(M, span_userdanger("You double over in pain as you feel your eyeballs liquify in your head!"))
				M.emote("scream")
				M.adjustBruteLoss(15)
		else
			to_chat(M, span_userdanger("You scream in terror as you go blind!"))
			eyes.applyOrganDamage(eyes.maxHealth)
			M.emote("scream")

	if(DT_PROB(1.5, delta_time) && iscarbon(M))
		M.visible_message(span_danger("[M] starts having a seizure!"), span_userdanger("You have a seizure!"))
		M.Unconscious(100)
		M.Jitter(350)

	if(DT_PROB(0.5, delta_time) && iscarbon(M))
		var/datum/disease/D = new /datum/disease/heart_failure
		M.ForceContractDisease(D)
		to_chat(M, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
		M.playsound_local(M, 'sound/effects/singlebeat.ogg', 100, 0)

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8" // rgb: 0, 100, 200
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 65
	taste_description = "grain alcohol"
	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of vodka"
	glass_desc = "The glass contain wodka. Xynta."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.radiation = max(M.radiation - (2 * REM * delta_time),0)
	return ..()

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 15
	taste_description = "desperation and lactate"
	glass_icon_state = "glass_brown"
	glass_name = "glass of bilk"
	glass_desc = "A brew of milk and beer. For those alcoholics who fear osteoporosis."

/datum/reagent/consumable/ethanol/bilk/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.getBruteLoss() && DT_PROB(5, delta_time))
		M.heal_bodypart_damage(brute = 1)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	description = "Made for a woman, but strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "dryness"
	glass_icon_state = "threemileislandglass"
	glass_name = "Three Mile Island Ice Tea"
	glass_desc = "A glass of this is sure to prevent a meltdown."

/datum/reagent/consumable/ethanol/threemileisland/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_drugginess(50 * REM * delta_time)
	return ..()

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	taste_description = "an alcoholic christmas tree"
	glass_icon_state = "ginvodkaglass"
	glass_name = "glass of gin"
	glass_desc = "A crystal clear glass of Griffeater gin."

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	description = "Yohoho and all that."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 60
	taste_description = "spiked butterscotch"
	glass_icon_state = "rumglass"
	glass_name = "glass of rum"
	glass_desc = "Now you want to Pray for a pirate suit, don't you?"
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	description = "A strong and mildly flavoured Mexican produced spirit. Feeling thirsty, hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 70
	taste_description = "paint stripper"
	glass_icon_state = "tequilaglass"
	glass_name = "glass of tequila"
	glass_desc = "Now all that's missing is the weird colored shades!"
	shot_glass_icon_state = "shotglassgold"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	taste_description = "dry alcohol"
	glass_icon_state = "vermouthglass"
	glass_name = "glass of vermouth"
	glass_desc = "You wonder why you're even drinking this straight."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	description = "A premium alcoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 35
	taste_description = "bitter sweetness"
	glass_icon_state = "wineglass"
	glass_name = "glass of wine"
	glass_desc = "A very classy looking drink."
	shot_glass_icon_state = "shotglassred"

/datum/reagent/consumable/ethanol/lizardwine
	name = "Lizard wine"
	description = "An alcoholic beverage from Space China, made by infusing lizard tails in ethanol."
	color = "#7E4043" // rgb: 126, 64, 67
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_FANTASTIC
	taste_description = "scaley sweetness"

/datum/reagent/consumable/ethanol/grappa
	name = "Grappa"
	description = "A fine Italian brandy for when regular wine just isn't alcoholic enough for you."
	color = "#F8EBF1"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	taste_description = "classy bitter sweetness"
	glass_icon_state = "grappa"
	glass_name = "glass of grappa"
	glass_desc = "A fine drink originally made to prevent waste by using the leftovers from winemaking."

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	description = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 75
	taste_description = "classy French brandy"
	glass_icon_state = "cognacglass"
	glass_name = "glass of cognac"
	glass_desc = "Damn, you feel like some kind of French aristocrat just by holding this."
	shot_glass_icon_state = "shotglassbrown"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	description = "A powerful alcoholic drink. Rumored to cause hallucinations, but does not."
	color = rgb(10, 206, 0)
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 80 //Very strong even by default
	taste_description = "death and licorice"
	glass_icon_state = "absinthe"
	glass_name = "glass of absinthe"
	glass_desc = "It's as strong as it smells."
	shot_glass_icon_state = "shotglassgreen"

/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(5, delta_time) && !HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.hallucination += 4 //Reference to the urban myth
	..()

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	description = "Either someone's failure at cocktail making or attempt in alcohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 100
	taste_description = "pure resignation"
	glass_icon_state = "glass_brown2"
	glass_name = "Hooch"
	glass_desc = "You've really hit rock bottom now... your liver packed its bags and left last night."

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.mind?.assigned_role == JOB_NAME_ASSISTANT)
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	description = "A dark alcoholic beverage made with malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 65
	taste_description = "hearty barley ale"
	glass_icon_state = "aleglass"
	glass_name = "glass of ale"
	glass_desc = "A freezing pint of delicious Ale."

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#FFFF91" // rgb: 255, 255, 145
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "burning cinnamon"
	glass_icon_state = "goldschlagerglass"
	glass_name = "glass of goldschlager"
	glass_desc = "100% proof that teen girls will drink anything with gold in it."
	shot_glass_icon_state = "shotglassgold"

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_VERYGOOD
	taste_description = "metallic and expensive"
	glass_icon_state = "patronglass"
	glass_name = "glass of patron"
	glass_desc = "Drinking patron in the bar, with all the subpar ladies."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	description = "An all time classic, mild cocktail."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "mild and tart"
	glass_icon_state = "gintonicglass"
	glass_name = "Gin and Tonic"
	glass_desc = "A mild but still great cocktail. Drink up, like a true Englishman."

/datum/reagent/consumable/ethanol/rum_coke
	name = "Rum and Coke"
	description = "Rum mixed with cola."
	taste_description = "cola"
	color = "#3E1B00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	quality = DRINK_NICE
	glass_icon_state = "whiskeycolaglass"
	glass_name = "Rum and Coke"
	glass_desc = "The classic go-to of space-fratboys."

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	description = "Viva la Revolucion! Viva Cuba Libre!"
	color = "#3E1B00" // rgb: 62, 27, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "a refreshing marriage of citrus and rum"
	glass_icon_state = "cubalibreglass"
	glass_name = "Cuba Libre"
	glass_desc = "A classic mix of rum, cola, and lime. A favorite of revolutionaries everywhere!"

/datum/reagent/consumable/ethanol/cuba_libre/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M?.mind?.has_antag_datum(/datum/antagonist/rev)) //Cuba Libre, the traditional drink of revolutions! Heals revolutionaries.
		M.adjustBruteLoss(-1 * REM * delta_time, 0)
		M.adjustFireLoss(-1 * REM * delta_time, 0)
		M.adjustToxLoss(-1 * REM * delta_time, 0)
		M.adjustOxyLoss(-5 * REM * delta_time, 0)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	description = "Whiskey mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "cola"
	glass_icon_state = "whiskeycolaglass"
	glass_name = "whiskey cola"
	glass_desc = "An innocent-looking mixture of cola and Whiskey. Delicious."


/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_NICE
	taste_description = "dry class"
	glass_icon_state = "martiniglass"
	glass_name = "Classic Martini"
	glass_desc = "Damn, the bartender even stirred it, not shook it."

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 65
	quality = DRINK_NICE
	taste_description = "shaken, not stirred"
	glass_icon_state = "martiniglass"
	glass_name = "Vodka martini"
	glass_desc ="A bastardisation of the classic martini. Still great."

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "bitter cream"
	glass_icon_state = "whiterussianglass"
	glass_name = "White Russian"
	glass_desc = "A very nice looking drink. But that's just, like, your opinion, man."

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	description = "Vodka mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 55
	quality = DRINK_NICE
	taste_description = "oranges"
	glass_icon_state = "screwdriverglass"
	glass_name = "Screwdriver"
	glass_desc = "A simple, yet superb mixture of Vodka and orange juice. Just the thing for the tired engineer."

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.mind && (M.mind.assigned_role in list(JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN, JOB_NAME_CHIEFENGINEER))) //Engineers lose radiation poisoning at a massive rate.
		M.radiation = max(M.radiation - (25 * REM * delta_time), 0)
	return ..()

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	description = "Ewww..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	taste_description = "sweet 'n creamy"
	glass_icon_state = "booger"
	glass_name = "Booger"
	glass_desc = "Ewww..."

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	description = "A strange yet pleasurable mixture made of vodka, tomato, and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 55
	quality = DRINK_GOOD
	taste_description = "tomatoes with a hint of lime"
	glass_icon_state = "bloodymaryglass"
	glass_name = "Bloody Mary"
	glass_desc = "Tomato juice, mixed with Vodka and a lil' bit of lime. Tastes like liquid murder."

/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	if(C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume = min(C.blood_volume + (3 * REM * delta_time), BLOOD_VOLUME_NORMAL) //Bloody Mary quickly restores blood loss.
	..()

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	description = "It's just as effective as Dutch-Courage!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_NICE
	taste_description = "alcoholic bravery"
	glass_icon_state = "bravebullglass"
	glass_name = "Brave Bull"
	glass_desc = "Tequila and Coffee liqueur, brought together in a mouthwatering mixture. Drink up."
	var/tough_text

/datum/reagent/consumable/ethanol/brave_bull/on_mob_metabolize(mob/living/M)
	tough_text = pick("brawny", "tenacious", "tough", "hardy", "sturdy") //Tuff stuff
	to_chat(M, span_notice("You feel [tough_text]!"))
	M.maxHealth += 10 //Brave Bull makes you sturdier, and thus capable of withstanding a tiny bit more punishment.
	M.health += 10

/datum/reagent/consumable/ethanol/brave_bull/on_mob_end_metabolize(mob/living/M)
	to_chat(M, span_notice("You no longer feel [tough_text]."))
	M.maxHealth -= 10
	M.health = min(M.health - 10, M.maxHealth) //This can indeed crit you if you're alive solely based on alchol ingestion

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	description = "Tequila, Grenadine, and Orange Juice."
	color = "#FFE48C" // rgb: 255, 228, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "oranges with a hint of pomegranate"
	glass_icon_state = "tequilasunriseglass"
	glass_name = "tequila Sunrise"
	glass_desc = "Oh great, now you feel nostalgic about sunrises back on Terra..."
	var/obj/effect/light_holder

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_metabolize(mob/living/M)
	to_chat(M, span_notice("You feel gentle warmth spread through your body!"))
	light_holder = new(M)
	light_holder.set_light(3, 0.7, "#FFCC00") //Tequila Sunrise makes you radiate dim light, like a sunrise!

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(QDELETED(light_holder))
		M.reagents.del_reagent(/datum/reagent/consumable/ethanol/tequila_sunrise) //If we lost our light object somehow, remove the reagent
	else if(light_holder.loc != M)
		light_holder.forceMove(M)
	return ..()

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_end_metabolize(mob/living/M)
	to_chat(M, span_notice("The warmth in your body fades."))
	QDEL_NULL(light_holder)

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "spicy toxins"
	glass_icon_state = "toxinsspecialglass"
	glass_name = "Toxins Special"
	glass_desc = "Whoah, this thing is on FIRE!"
	shot_glass_icon_state = "toxinsspecialglass"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(15 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, M.get_body_temp_normal() + 20) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	description = "Drink this and prepare for the LAW."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90 //THE FIST OF THE LAW IS STRONG AND HARD
	quality = DRINK_GOOD
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "JUSTICE"
	glass_icon_state = "beepskysmashglass"
	glass_name = "Beepsky Smash"
	glass_desc = "Heavy, hot and strong. Just like the iron fist of the LAW."
	overdose_threshold = 40

	var/datum/brain_trauma/special/beepsky/B

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_metabolize(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		metabolization_rate = 0.8
	if(M.mind != null && !HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		B = new()
		M.gain_trauma(B, TRAUMA_RESILIENCE_ABSOLUTE)
	ADD_TRAIT(M, TRAIT_NOBLOCK, type) //sorry sec, but you dont get a special stam heal to help with blocking
	..()

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.Jitter(2)
	if(M.mind != null && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.adjustStaminaLoss(-10 * REM * delta_time, 0)
		if(DT_PROB(10, delta_time))
			new /datum/hallucination/items_other(M)
		if(DT_PROB(5, delta_time))
			new /datum/hallucination/stray_bullet(M)
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_end_metabolize(mob/living/carbon/M)
	if(B)
		QDEL_NULL(B)
	REMOVE_TRAIT(M, TRAIT_NOBLOCK, type)
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash/overdose_start(mob/living/carbon/M)
	if(M.mind != null && !HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.gain_trauma(/datum/brain_trauma/mild/phobia/security, TRAUMA_RESILIENCE_BASIC)


/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	description = "Whiskey-imbued cream. What else would you expect from the Irish?"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_NICE
	taste_description = "creamy alcohol"
	glass_icon_state = "irishcreamglass"
	glass_name = "Irish Cream"
	glass_desc = "Whiskey-imbued cream. What else would you expect from the Irish?"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	description = "Beer and Ale brought together in a delicious mix. Intended for true men only."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 100 //For the manly only
	quality = DRINK_NICE
	taste_description = "hair on your chest and your chin"
	glass_icon_state = "manlydorfglass"
	glass_name = "The Manly Dorf"
	glass_desc = "Beer and Ale brought together in a delicious mix. Intended for true men only."
	var/dorf_mode

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_metabolize(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(HAS_TRAIT(C, TRAIT_ALCOHOL_TOLERANCE) || HAS_TRAIT(C, TRAIT_DWARF))
			to_chat(C, span_notice("Now THAT is MANLY!"))
			boozepwr = 5 //We've had worse in the mines
			dorf_mode = TRUE

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(dorf_mode)
		M.adjustBruteLoss(-2 * REM * delta_time)
		M.adjustFireLoss(-2 * REM * delta_time)
	return ..()

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	description = "The entire liquor cabinet brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "a mixture of cola and alcohol"
	glass_icon_state = "longislandicedteaglass"
	glass_name = "Long Island Iced Tea"
	glass_desc = "The entire liquor cabinet brought together in a delicious mix. Intended for middle-aged alcoholic women only."


/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	description = "You've really hit rock bottom now. Your liver packed its bags and left last night."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha) (like water)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING | CHEMICAL_GOAL_BOTANIST_HARVEST
	boozepwr = 95
	taste_description = "bitterness"
	glass_icon_state = "glass_clear"
	glass_name = "Moonshine"
	glass_desc = "You've really hit rock bottom now. Your liver packed its bags and left last night."

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 85
	quality = DRINK_GOOD
	taste_description = "angry and irish"
	glass_icon_state = "b52glass"
	glass_name = "B-52"
	glass_desc = "Kahlua, Irish Cream, and cognac. You will get bombed."
	shot_glass_icon_state = "b52glass"

/datum/reagent/consumable/ethanol/b52/on_mob_metabolize(mob/living/M)
	playsound(M, 'sound/effects/explosion_distant.ogg', 100, FALSE)

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	description = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "giving up on the day"
	glass_icon_state = "irishcoffeeglass"
	glass_name = "Irish Coffee"
	glass_desc = "Coffee and alcohol. More fun than a Mimosa to drink in the morning."

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "dry and salty"
	glass_icon_state = "margaritaglass"
	glass_name = "Margarita"
	glass_desc = "On the rocks with salt on the rim. Arriba~!"

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "bitterness"
	glass_icon_state = "blackrussianglass"
	glass_name = "Black Russian"
	glass_desc = "For the lactose-intolerant. Still as classy as a White Russian."


/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "mild dryness"
	glass_icon_state = "manhattanglass"
	glass_name = "Manhattan"
	glass_desc = "The Detective's undercover drink of choice. He never could stomach gin."


/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	description = "A scientist's drink of choice. Great for pondering ways to blow up the station."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "death, the destroyer of worlds"
	glass_icon_state = "proj_manhattanglass"
	glass_name = "Manhattan Project"
	glass_desc = "A scientist's drink of choice. Great for thinking how to blow up the station."


/datum/reagent/consumable/ethanol/manhattan_proj/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_drugginess(30 * REM * delta_time)
	return ..()

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	description = "For the more refined griffon."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "soda"
	glass_icon_state = "whiskeysodaglass2"
	glass_name = "whiskey soda"
	glass_desc = "Ultimate refreshment."

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	description = "The ultimate refreshment. Not what it sounds like."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "Jack Frost's piss"
	glass_icon_state = "antifreeze"
	glass_name = "Anti-freeze"
	glass_desc = "The ultimate refreshment."

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, M.get_body_temp_normal() + 20) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	description = "Barefoot and pregnant."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "creamy berries"
	glass_icon_state = "b&p"
	glass_name = "Barefoot"
	glass_desc = "Barefoot and pregnant."

/datum/reagent/consumable/ethanol/barefoot/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(ishuman(M)) //Barefoot causes the imbiber to quickly regenerate brute trauma if they're not wearing shoes.
		var/mob/living/carbon/human/H = M
		if(!H.shoes)
			H.adjustBruteLoss(-3 * REM * delta_time, 0)
			. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	description = "A cold refreshment."
	color = "#FFFFFF" // rgb: 255, 255, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "refreshing cold"
	glass_icon_state = "snowwhite"
	glass_name = "Snow White"
	glass_desc = "A cold refreshment."

/datum/reagent/consumable/ethanol/demonsblood //Prevents the imbiber from being dragged into a pool of blood by a slaughter demon.
	name = "Demon's Blood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 75
	quality = DRINK_VERYGOOD
	taste_description = "sweet tasting iron"
	glass_icon_state = "demonsblood"
	glass_name = "Demons Blood"
	glass_desc = "Just looking at this thing makes the hair at the back of your neck stand up."


/datum/reagent/consumable/ethanol/demonsblood/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	RegisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_PRE_CONSUMED, PROC_REF(pre_bloodcrawl_consumed))

/datum/reagent/consumable/ethanol/demonsblood/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	UnregisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_PRE_CONSUMED)

/// Prevents the imbiber from being dragged into a pool of blood by a slaughter demon.
/datum/reagent/consumable/ethanol/demonsblood/proc/pre_bloodcrawl_consumed(
	mob/living/source,
	datum/action/spell/jaunt/bloodcrawl/crawl,
	mob/living/jaunter,
	obj/effect/decal/cleanable/blood,
)

	SIGNAL_HANDLER

	var/turf/jaunt_turf = get_turf(jaunter)
	jaunt_turf.visible_message(
		("<span class='warning'>Something prevents [source] from entering [blood]!</span>"),
		blind_message = ("<span class='notice'>You hear a splash and a thud.</span>")
	)
	to_chat(jaunter, ("<span class='warning'>A strange force is blocking [source] from entering!</span>"))

	return COMPONENT_STOP_CONSUMPTION

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devil's Kiss"
	description = "A creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_VERYGOOD
	taste_description = "bitter iron"
	glass_icon_state = "devilskiss"
	glass_name = "Devils Kiss"
	glass_desc = "A creepy time!"

/datum/reagent/consumable/ethanol/devilskiss/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	RegisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_CONSUMED, PROC_REF(on_bloodcrawl_consumed))

/datum/reagent/consumable/ethanol/devilskiss/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	UnregisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_CONSUMED)

/// If eaten by a slaughter demon, the demon will regret it.
/datum/reagent/consumable/ethanol/devilskiss/proc/on_bloodcrawl_consumed(
	mob/living/source,
	datum/action/spell/jaunt/bloodcrawl/crawl,
	mob/living/jaunter,
)

	SIGNAL_HANDLER

	. = COMPONENT_STOP_CONSUMPTION

	to_chat(jaunter, ("<span class='boldwarning'>AAH! THEIR FLESH! IT BURNS!</span>"))
	jaunter.apply_damage(25, BRUTE)

	for(var/obj/effect/decal/cleanable/nearby_blood in range(1, get_turf(source)))
		if(!nearby_blood.can_bloodcrawl_in())
			continue
		source.forceMove(get_turf(nearby_blood))
		source.visible_message(("<span class='warning'>[nearby_blood] violently expels [source]!</span>"))
		crawl.exit_blood_effect(source)
		return

	// Fuck it, just eject them, thanks to some split second cleaning
	source.forceMove(get_turf(source))
	source.visible_message(("<span class='warning'>[source] appears from nowhere, covered in blood!</span>"))
	crawl.exit_blood_effect(source)

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	description = "For when a gin and tonic isn't Russian enough."
	color = "#0064C8" // rgb: 0, 100, 200
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "tart bitterness"
	glass_icon_state = "vodkatonicglass"
	glass_name = "vodka and tonic"
	glass_desc = "For when a gin and tonic isn't Russian enough."


/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "dry, tart lemons"
	glass_icon_state = "ginfizzglass"
	glass_name = "gin fizz"
	glass_desc = "Refreshingly lemony, deliciously dry."


/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama Mama"
	description = "A tropical cocktail with a complex blend of flavors."
	color = "#FF7F3B" // rgb: 255, 127, 59
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "pineapple, coconut, and a hint of coffee"
	glass_icon_state = "bahama_mama"
	glass_name = "Bahama Mama"
	glass_desc = "A tropical cocktail with a complex blend of flavors."

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	description = "A blue-space beverage!"
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "concentrated matter"
	glass_icon_state = "singulo"
	glass_name = "Singulo"
	glass_desc = "A blue-space beverage."

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_GOOD
	taste_description = "hot and spice"
	glass_icon_state = "sbitenglass"
	glass_name = "Sbiten"
	glass_desc = "A spicy Vodka! Might be a little hot for the little guys!"

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(50 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, BODYTEMP_HEAT_DAMAGE_LIMIT) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	description = "The true Viking drink! Even though it has a strange red color."
	color = "#C73C00" // rgb: 199, 60, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 31 //Red drinks are stronger
	quality = DRINK_GOOD
	taste_description = "sweet and salty alcohol"
	glass_icon_state = "red_meadglass"
	glass_name = "Red Mead"
	glass_desc = "The true Viking drink! Even though it has a strange red color."

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	description = "A Viking drink, though a cheap one."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "sweet, sweet alcohol"
	glass_icon_state = "meadglass"
	glass_name = "Mead"
	glass_desc = "A Viking's Beverage, though a cheap one."

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 15
	taste_description = "refreshingly cold"
	glass_icon_state = "iced_beerglass"
	glass_name = "iced beer"
	glass_desc = "A beer so frosty, the air around it freezes."

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(-20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, T0C) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	description = "Watered down rum. Nanotrasen approved!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 1 //Basically nothing
	taste_description = "a poor excuse for alcohol"
	glass_icon_state = "grogglass"
	glass_name = "Grog"
	glass_desc = "Watered down rum. Nanotrasen approved!"


/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	description = "So very, very, very good."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "sweet 'n creamy"
	glass_icon_state = "aloe"
	glass_name = "Aloe"
	glass_desc = "Very, very, very good."

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	description = "A nice, strangely named drink."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "lemons"
	glass_icon_state = "andalusia"
	glass_name = "Andalusia"
	glass_desc = "A nice, strangely named drink."

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	description = "A drink made from your allies. Not as sweet as those made from your enemies."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 45
	quality = DRINK_NICE
	taste_description = "bitter yet free"
	glass_icon_state = "alliescocktail"
	glass_name = "Allies cocktail"
	glass_desc = "A drink made from your allies. Not as sweet as those made from your enemies."

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	description = "A drink for the daring! Made from 20% more live aliens."
	color = "#365000" // rgb: 54, 80, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_VERYGOOD
	taste_description = "stomach acid"
	glass_icon_state = "acidspitglass"
	glass_name = "Acid Spit"
	glass_desc = "A drink for the daring! Made from 20% more live aliens."

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	description = "Official drink of the Nanotrasen Gun-Club!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "dark and metallic"
	glass_icon_state = "amasecglass"
	glass_name = "Amasec"
	glass_desc = "Official drink of the Nanotrasen Gun-Club!"

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 95
	quality = DRINK_GOOD
	taste_description = "your brain coming out your nose"
	glass_icon_state = "changelingsting"
	glass_name = "Changeling Sting"
	glass_desc = "A stingy drink."

/datum/reagent/consumable/ethanol/changelingsting/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.mind) //Changeling Sting assists in the recharging of changeling chemicals.
		var/datum/antagonist/changeling/changeling = M.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges += metabolization_rate * REM * delta_time
			changeling.chem_charges = clamp(changeling.chem_charges, 0, changeling.chem_storage)
	return ..()

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	description = "Mmm, tastes like chocolate cake..."
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "delicious anger"
	glass_icon_state = "irishcarbomb"
	glass_name = "Irish Car Bomb"
	glass_desc = "An Irish car bomb."

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	description = "Tastes like terrorism!"
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90
	quality = DRINK_GOOD
	taste_description = "purified antagonism"
	glass_icon_state = "syndicatebomb"
	glass_name = "Syndicate Bomb"
	glass_desc = "A syndicate bomb."

/datum/reagent/consumable/ethanol/syndicatebomb/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(2.5, delta_time))
		playsound(get_turf(M), 'sound/effects/explosionfar.ogg', 100, 1)
	return ..()

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	description = "The surprise is, it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "tartness and bananas"
	glass_icon_state = "erikasurprise"
	glass_name = "Erika Surprise"
	glass_desc = "The surprise is, it's green!"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 65
	quality = DRINK_GOOD
	taste_description = "a beach"
	glass_icon_state = "driestmartiniglass"
	glass_name = "Driest Martini"
	glass_desc = "Only for the experienced. You think you see sand floating in the glass."

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Honk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFF91" // rgb: 255, 255, 140
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "a bad joke"
	glass_icon_state = "bananahonkglass"
	glass_name = "Banana Honk"
	glass_desc = "A drink from Clown Heaven."

/datum/reagent/consumable/ethanol/bananahonk/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if((ishuman(M) && M.job == JOB_NAME_CLOWN) || ismonkey(M))
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = NONE
	boozepwr = 59 //Proof that clowns are better than mimes right here
	quality = DRINK_GOOD
	taste_description = "a pencil eraser"
	glass_icon_state = "silencerglass"
	glass_name = "Silencer"
	glass_desc = "A drink from Mime Heaven."

/datum/reagent/consumable/ethanol/silencer/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.silent = max(M.silent, 1.25)
	if(ishuman(M) && M.job == JOB_NAME_MIME)
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	description = "A weird mix of whiskey and blumpkin juice."
	color = "#1EA0FF" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "molasses and a mouthful of pool water"
	glass_icon_state = "drunkenblumpkin"
	glass_name = "Drunken Blumpkin"
	glass_desc = "A weird mix of whiskey and blumpkin juice."

/datum/reagent/consumable/ethanol/whiskey_sour //Requested since we had whiskey cola and soda but not sour.
	name = "Whiskey Sour"
	description = "Lemon juice mixed with whiskey and a dash of sugar. Surprisingly satisfying."
	color = rgb(255, 201, 49)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "sour lemons"
	glass_icon_state = "whiskey_sour"
	glass_name = "whiskey sour"
	glass_desc = "Lemon juice mixed with whiskey and a dash of sugar. Surprisingly satisfying."

/datum/reagent/consumable/ethanol/hcider
	name = "Hard Cider"
	description = "Tastes like autumn. No wait, fall!"
	color = "#CD6839"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "the season that <i>falls</i> between summer and winter"
	glass_icon_state = "whiskeyglass"
	glass_name = "hard cider"
	glass_desc = "Tastes like autumn. No wait, fall!"
	shot_glass_icon_state = "shotglassbrown"


/datum/reagent/consumable/ethanol/fetching_fizz //A reference to one of my favorite games of all time. Pulls nearby ores to the imbiber!
	name = "Fetching Fizz"
	description = "Whiskey sour/iron/uranium mixture resulting in a highly magnetic slurry. Mild alcohol content." //Requires no alcohol to make but has alcohol anyway because ~magic~
	color = rgb(255, 91, 15)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_VERYGOOD
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	taste_description = "charged metal" // the same as teslium, honk honk.
	glass_icon_state = "fetching_fizz"
	glass_name = "Fetching Fizz"
	glass_desc = "Induces magnetism in the imbiber. Started as a barroom prank but evolved to become popular with miners and scrappers. Metallic aftertaste."


/datum/reagent/consumable/ethanol/fetching_fizz/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	for(var/obj/item/stack/ore/O in orange(3, M))
		step_towards(O, get_turf(M))
	return ..()

//Another reference. Heals those in critical condition extremely quickly.
/datum/reagent/consumable/ethanol/hearty_punch
	name = "Hearty Punch"
	description = "Brave bull/syndicate bomb/absinthe mixture resulting in an energizing beverage. Mild alcohol content."
	color = rgb(140, 0, 0)
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90
	quality = DRINK_VERYGOOD
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	taste_description = "bravado in the face of disaster"
	glass_icon_state = "hearty_punch"
	glass_name = "Hearty Punch"
	glass_desc = "Aromatic beverage served piping hot. According to folk tales it can almost wake the dead."


/datum/reagent/consumable/ethanol/hearty_punch/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.health <= 0)
		M.adjustBruteLoss(-3 * REM * delta_time, 0)
		M.adjustFireLoss(-3 * REM * delta_time, 0)
		M.adjustCloneLoss(-5 * REM * delta_time, 0)
		M.adjustOxyLoss(-4 * REM * delta_time, 0)
		M.adjustToxLoss(-3 * REM * delta_time, 0)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	description = "Unidentifiable mixture. Unmeasurably high alcohol content."
	color = rgb(51, 19, 3) //Sickly brown
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 300 //I warned you
	taste_description = "a wall of bricks"
	glass_icon_state = "glass_brown2"
	glass_name = "Bacchus' Blessing"
	glass_desc = "You didn't think it was possible for a liquid to be so utterly revolting. Are you sure about this...?"



/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 0 //custom drunk effect
	quality = DRINK_FANTASTIC
	taste_description = "da bomb"
	glass_icon_state = "atomicbombglass"
	glass_name = "Atomic Bomb"
	glass_desc = "Nanotrasen cannot take legal responsibility for your actions after imbibing."

/datum/reagent/consumable/ethanol/atomicbomb/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_drugginess(50 * REM * delta_time)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.confused = max(M.confused + (2 * REM * delta_time),0)
		M.Dizzy(10 * REM * delta_time)
	if (!M.slurring)
		M.slurring = 1 * REM * delta_time
	M.slurring += 3 * REM * delta_time
	switch(current_cycle)
		if(51 to 200)
			M.Sleeping(100 * REM * delta_time)
			. = TRUE
		if(201 to INFINITY)
			M.AdjustSleeping(40 * REM * delta_time)
			M.adjustToxLoss(2 * REM * delta_time, 0)
			. = TRUE
	..()

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 0 //custom drunk effect
	quality = DRINK_GOOD
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"
	glass_icon_state = "gargleblasterglass"
	glass_name = "Pan-Galactic Gargle Blaster"
	glass_desc = "Like having your brain smashed out by a slice of lemon wrapped around a large gold brick."

/datum/reagent/consumable/ethanol/gargle_blaster/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.dizziness += 1.5 * REM * delta_time
	switch(current_cycle)
		if(15 to 45)
			if(!M.slurring)
				M.slurring = 1 * REM * delta_time
			M.slurring += 3 * REM * delta_time
		if(45 to 55)
			if(DT_PROB(30, delta_time))
				M.confused = max(M.confused + 3, 0)
		if(55 to 200)
			M.set_drugginess(55 * REM * delta_time)
		if(200 to INFINITY)
			M.adjustToxLoss(2 * REM * delta_time, 0)
			. = TRUE
	..()

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "a numbing sensation"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	glass_icon_state = "neurotoxinglass"
	glass_name = "Neurotoxin"
	glass_desc = "A drink that is guaranteed to knock you silly."


/datum/reagent/consumable/ethanol/neurotoxin/proc/pickt()
	return (pick(TRAIT_PARALYSIS_L_ARM,TRAIT_PARALYSIS_R_ARM,TRAIT_PARALYSIS_R_LEG,TRAIT_PARALYSIS_L_LEG))

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_drugginess(50 * REM * delta_time)
	M.dizziness += 2 * REM * delta_time
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM * delta_time, 150)
	if(DT_PROB(10, delta_time))
		M.adjustStaminaLoss(10)
		M.drop_all_held_items()
		to_chat(M, span_notice("You cant feel your hands!"))
	if(current_cycle > 5)
		if(DT_PROB(10, delta_time))
			var/t = pickt()
			ADD_TRAIT(M, t, type)
			M.adjustStaminaLoss(10)
		if(current_cycle > 30)
			M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * delta_time)
			if(current_cycle > 50 && DT_PROB(7.5, delta_time))
				if(!M.undergoing_cardiac_arrest() && M.can_heartattack())
					M.set_heartattack(TRUE)
					if(M.stat == CONSCIOUS)
						M.visible_message(span_userdanger("[M] clutches at [M.p_their()] chest as if [M.p_their()] heart stopped!"))
	. = TRUE
	..()

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_end_metabolize(mob/living/carbon/M)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_L_ARM, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_R_ARM, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_R_LEG, type)
	REMOVE_TRAIT(M, TRAIT_PARALYSIS_L_LEG, type)
	M.adjustStaminaLoss(10)
	..()

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	description = "You just don't get it maaaan."
	color = "#664300" // rgb: 102, 67, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 0
	boozepwr = 0 //custom drunk effect
	quality = DRINK_FANTASTIC
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "giving peace a chance"
	glass_icon_state = "hippiesdelightglass"
	glass_name = "Hippie's Delight"
	glass_desc = "A drink enjoyed by people during the 1960's."


/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if (!M.slurring)
		M.slurring = 1 * REM * delta_time
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(10 * REM * delta_time)
			M.set_drugginess(30 * REM * delta_time)
			if(DT_PROB(5, delta_time))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(20 * REM * delta_time)
			M.Dizzy(20 * REM * delta_time)
			M.set_drugginess(45 * REM * delta_time)
			if(DT_PROB(10, delta_time))
				M.emote(pick("twitch","giggle"))
		if (10 to 200)
			M.Jitter(40 * REM * delta_time)
			M.Dizzy(40 * REM * delta_time)
			M.set_drugginess(60 * REM * delta_time)
			if(DT_PROB(16, delta_time))
				M.emote(pick("twitch","giggle"))
		if(200 to INFINITY)
			M.Jitter(60 * REM * delta_time)
			M.Dizzy(60 * REM * delta_time)
			M.set_drugginess(75 * REM * delta_time)
			if(DT_PROB(23, delta_time))
				M.emote(pick("twitch","giggle"))
			if(DT_PROB(16, delta_time))
				M.adjustToxLoss(2, 0)
				. = TRUE
	..()

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	description = "For enjoying the most wonderful time of the year."
	color = "#fcfdc6" // rgb: 252, 253, 198
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 1
	quality = DRINK_VERYGOOD
	taste_description = "custard and alcohol"
	glass_icon_state = "glass_yellow"
	glass_name = "eggnog"
	glass_desc = "For enjoying the most wonderful time of the year."


/datum/reagent/consumable/ethanol/narsour
	name = "Nar'Sour"
	description = "Side effects include self-mutilation and hoarding plasteel."
	color = RUNE_COLOR_DARKRED
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "blood"
	glass_icon_state = "narsour"
	glass_name = "Nar'Sour"
	glass_desc = "A new hit cocktail inspired by THE ARM Breweries will have you shouting Fuu ma'jin in no time!"


/datum/reagent/consumable/ethanol/narsour/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.cultslurring = min(M.cultslurring + (3 * REM * delta_time), 3)
	M.stuttering = min(M.stuttering + (3 * REM * delta_time), 3)
	..()

/datum/reagent/consumable/ethanol/triple_sec
	name = "Triple Sec"
	description = "A sweet and vibrant orange liqueur."
	color = "#ffcc66"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 30
	taste_description = "a warm flowery orange taste which recalls the ocean air and summer wind of the caribbean"
	glass_icon_state = "glass_orange"
	glass_name = "Triple Sec"
	glass_desc = "A glass of straight Triple Sec."

/datum/reagent/consumable/ethanol/creme_de_menthe
	name = "Creme de Menthe"
	description = "A minty liqueur excellent for refreshing, cool drinks."
	color = "#00cc00"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "a minty, cool, and invigorating splash of cold streamwater"
	glass_icon_state = "glass_green"
	glass_name = "Creme de Menthe"
	glass_desc = "You can almost feel the first breath of spring just looking at it."

/datum/reagent/consumable/ethanol/creme_de_cacao
	name = "Creme de Cacao"
	description = "A chocolatey liqueur excellent for adding dessert notes to beverages and bribing sororities."
	color = "#996633"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "a slick and aromatic hint of chocolates swirling in a bite of alcohol"
	glass_icon_state = "glass_brown"
	glass_name = "Creme de Cacao"
	glass_desc = "A million hazing lawsuits and alcohol poisonings have started with this humble ingredient."

/datum/reagent/consumable/ethanol/creme_de_coconut
	name = "Creme de Coconut"
	description = "A coconut liqueur for smooth, creamy, tropical drinks."
	color = "#F7F0D0"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "a sweet milky flavor with notes of toasted sugar"
	glass_icon_state = "glass_white"
	glass_name = "Creme de Coconut"
	glass_desc = "An unintimidating glass of coconut liqueur."

/datum/reagent/consumable/ethanol/quadruple_sec
	name = "Quadruple Sec"
	description = "Kicks just as hard as licking the power cell on a baton, but tastier."
	color = "#cc0000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "an invigorating bitter freshness which suffuses your being; no enemy of the station will go unrobusted this day"
	glass_icon_state = "quadruple_sec"
	glass_name = "Quadruple Sec"
	glass_desc = "An intimidating and lawful beverage dares you to violate the law and make its day. Still can't drink it on duty, though."

/datum/reagent/consumable/ethanol/quadruple_sec/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	//Securidrink in line with the Screwdriver for engineers or Nothing for mimes
	if(M.mind != null && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(0.5 * REM * delta_time, 0.5 * REM * delta_time)
		M.adjust_nutrition(-1 * REM * delta_time)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/quintuple_sec
	name = "Quintuple Sec"
	description = "Law, Order, Alcohol, and Police Brutality distilled into one single elixir of JUSTICE."
	color = "#ff3300"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_FANTASTIC
	taste_description = "THE LAW"
	glass_icon_state = "quintuple_sec"
	glass_name = "Quintuple Sec"
	glass_desc = "Now you are become law, destroyer of clowns."


/datum/reagent/consumable/ethanol/quintuple_sec/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	//Securidrink in line with the Screwdriver for engineers or Nothing for mimes but STRONG..
	if(M.mind != null && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time, 1 * REM * delta_time)
		M.adjust_nutrition(-2 * REM * delta_time)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/grasshopper
	name = "Grasshopper"
	description = "A fresh and sweet dessert shooter. Difficult to look manly while drinking this."
	color = "#00ff00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "chocolate and mint dancing around your mouth"
	glass_icon_state = "grasshopper"
	glass_name = "Grasshopper"
	glass_desc = "You weren't aware edible beverages could be that green."

/datum/reagent/consumable/ethanol/stinger
	name = "Stinger"
	description = "A snappy way to end the day."
	color = "#ccff99"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "a slap on the face in the best possible way"
	glass_icon_state = "stinger"
	glass_name = "Stinger"
	glass_desc = "You wonder what would happen if you pointed this at a heat source..."

/datum/reagent/consumable/ethanol/bastion_bourbon
	name = "Bastion Bourbon"
	description = "Soothing hot herbal brew with restorative properties. Hints of citrus and berry flavors."
	color = "#00FFFF"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 30
	quality = DRINK_FANTASTIC
	taste_description = "hot herbal brew with a hint of fruit"
	metabolization_rate = 2 * REAGENTS_METABOLISM //0.4u per second
	glass_icon_state = "bastion_bourbon"
	glass_name = "Bastion Bourbon"
	glass_desc = "If you're feeling low, count on the buttery flavor of our own bastion bourbon."
	shot_glass_icon_state = "shotglassgreen"


/datum/reagent/consumable/ethanol/bastion_bourbon/on_mob_metabolize(mob/living/L)
	var/heal_points = 10
	if(L.health <= 0)
		heal_points = 20 //heal more if we're in softcrit
	for(var/i in 1 to min(volume, heal_points)) //only heals 1 point of damage per unit on add, for balance reasons
		L.adjustBruteLoss(-1)
		L.adjustFireLoss(-1)
		L.adjustToxLoss(-1)
		L.adjustOxyLoss(-1)
		L.adjustStaminaLoss(-1)
	L.visible_message(span_warning("[L] shivers with renewed vigor!"), span_notice("One taste of [LOWER_TEXT(name)] fills you with energy!"))
	if(!L.stat && heal_points == 20) //brought us out of softcrit
		L.visible_message(span_danger("[L] lurches to [L.p_their()] feet!"), span_boldnotice("Up and at 'em, kid."))

/datum/reagent/consumable/ethanol/bastion_bourbon/on_mob_life(mob/living/L, delta_time, times_fired)
	if(L.health > 0)
		L.adjustBruteLoss(-1 * REM * delta_time)
		L.adjustFireLoss(-1 * REM * delta_time)
		L.adjustToxLoss(-0.5 * REM * delta_time)
		L.adjustOxyLoss(-3 * REM * delta_time)
		L.adjustStaminaLoss(-5 * REM * delta_time)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/squirt_cider
	name = "Squirt Cider"
	description = "Fermented squirt extract with a nose of stale bread and ocean water. Whatever a squirt is."
	color = "#FF0000"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	taste_description = "stale bread with a staler aftertaste"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	glass_icon_state = "squirt_cider"
	glass_name = "Squirt Cider"
	glass_desc = "Squirt cider will toughen you right up. Too bad about the musty aftertaste."
	shot_glass_icon_state = "shotglassgreen"

/datum/reagent/consumable/ethanol/squirt_cider/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.satiety += 5 * REM * delta_time //for context, vitamins give 15 satiety per second
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/fringe_weaver
	name = "Fringe Weaver"
	description = "Bubbly, classy, and undoubtedly strong - a Glitch City classic."
	color = "#FFEAC4"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 90 //classy hooch, essentially, but lower pwr to make up for slightly easier access
	quality = DRINK_GOOD
	taste_description = "ethylic alcohol with a hint of sugar"
	glass_icon_state = "fringe_weaver"
	glass_name = "Fringe Weaver"
	glass_desc = "It's a wonder it doesn't spill out of the glass."

/datum/reagent/consumable/ethanol/sugar_rush
	name = "Sugar Rush"
	description = "Sweet, light, and fruity - as girly as it gets."
	color = "#FF226C"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_GOOD
	taste_description = "your arteries clogging with sugar"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	glass_icon_state = "sugar_rush"
	glass_name = "Sugar Rush"
	glass_desc = "If you can't mix a Sugar Rush, you can't tend bar."

/datum/reagent/consumable/ethanol/sugar_rush/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.satiety -= 10 * REM * delta_time //junky as hell! a whole glass will keep you from being able to eat junk food
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/crevice_spike
	name = "Crevice Spike"
	description = "Sour, bitter, and smashingly sobering. Doesn't sober up light drinkers."
	color = "#5BD231"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = -10 //sobers you up - ideally, one would drink to get hit with brute damage now to avoid alcohol problems later
	quality = DRINK_VERYGOOD
	taste_description = "a bitter SPIKE with a sour aftertaste"
	glass_icon_state = "crevice_spike"
	glass_name = "Crevice Spike"
	glass_desc = "It'll either knock the drunkenness out of you or knock you out cold. Both, probably."


/datum/reagent/consumable/ethanol/crevice_spike/on_mob_metabolize(mob/living/L) //damage only applies when drink first enters system and won't again until drink metabolizes out
	L.adjustBruteLoss(3 * min(5,volume)) //minimum 3 brute damage on ingestion to limit non-drink means of injury - a full 5 unit gulp of the drink trucks you for the full 15

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	description = "A sweet rice wine of questionable legality and extreme potency."
	color = "#DDDDDD"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 70
	taste_description = "sweet rice wine"
	glass_icon_state = "sakecup"
	glass_name = "cup of sake"
	glass_desc = "A traditional cup of sake."

/datum/reagent/consumable/ethanol/peppermint_patty
	name = "Peppermint Patty"
	description = "This lightly alcoholic drink combines the benefits of menthol and cocoa."
	color = "#45ca7a"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "mint and chocolate"
	boozepwr = 25
	quality = DRINK_GOOD
	glass_icon_state = "peppermint_patty"
	glass_name = "Peppermint Patty"
	glass_desc = "A boozy minty hot cocoa that warms your belly on a cold night."

/datum/reagent/consumable/ethanol/peppermint_patty/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.apply_status_effect(/datum/status_effect/throat_soothed)
	M.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, 0, M.get_body_temp_normal())
	..()

/datum/reagent/consumable/ethanol/alexander
	name = "Alexander"
	description = "Named after a Greek hero, this mix is said to embolden a user's shield as if they were in a phalanx."
	color = "#F5E9D3"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_GOOD
	taste_description = "bitter, creamy cacao"
	glass_icon_state = "alexander"
	glass_name = "Alexander"
	glass_desc = "A creamy, indulgent delight that is stronger than it seems."
	var/obj/item/shield/mighty_shield

/datum/reagent/consumable/ethanol/alexander/on_mob_metabolize(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/thehuman = L
		for(var/obj/item/shield/theshield in thehuman.contents)
			mighty_shield = theshield
			mighty_shield.block_power += 15
			to_chat(thehuman, span_notice("[theshield] appears polished, although you don't recall polishing it."))
			return TRUE

/datum/reagent/consumable/ethanol/alexander/on_mob_life(mob/living/L, delta_time, times_fired)
	..()
	if(mighty_shield && !(mighty_shield in L.contents)) //If you had a shield and lose it, you lose the reagent as well. Otherwise this is just a normal drink.
		L.reagents.del_reagent(/datum/reagent/consumable/ethanol/alexander)

/datum/reagent/consumable/ethanol/alexander/on_mob_end_metabolize(mob/living/L)
	if(mighty_shield)
		mighty_shield.block_power -= 15
		to_chat(L,span_notice("You notice [mighty_shield] looks worn again. Weird."))
	..()

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	description = "The one ride you'll gladly give up the wheel for."
	color = "#FFC55B"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_GOOD
	taste_description = "delicious freedom"
	glass_icon_state = "sidecar"
	glass_name = "Sidecar"
	glass_desc = "The one ride you'll gladly give up the wheel for."

/datum/reagent/consumable/ethanol/between_the_sheets
	name = "Between the Sheets"
	description = "A provocatively named classic. Funny enough, doctors recommend drinking it before taking a nap."
	color = "#F4C35A"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 80
	quality = DRINK_GOOD
	taste_description = "seduction"
	glass_icon_state = "between_the_sheets"
	glass_name = "Between the Sheets"
	glass_desc = "The only drink that comes with a label reminding you of Nanotrasen's zero-tolerance promiscuity policy."

/datum/reagent/consumable/ethanol/between_the_sheets/on_mob_life(mob/living/L, delta_time, times_fired)
	..()
	if(L.IsSleeping())
		if(L.getBruteLoss() && L.getFireLoss()) //If you are damaged by both types, slightly increased healing but it only heals one. The more the merrier wink wink.
			if(prob(50))
				L.adjustBruteLoss(-0.25 * REM * delta_time)
			else
				L.adjustFireLoss(-0.25 * REM * delta_time)
		else if(L.getBruteLoss()) //If you have only one, it still heals but not as well.
			L.adjustBruteLoss(-0.2 * REM * delta_time)
		else if(L.getFireLoss())
			L.adjustFireLoss(-0.2 * REM * delta_time)

/datum/reagent/consumable/ethanol/kamikaze
	name = "Kamikaze"
	description = "Divinely windy."
	color = "#EEF191"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "divine windiness"
	glass_icon_state = "kamikaze"
	glass_name = "Kamikaze"
	glass_desc = "Divinely windy."

/datum/reagent/consumable/ethanol/mojito
	name = "Mojito"
	description = "A drink that looks as refreshing as it tastes."
	color = "#DFFAD9"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "refreshing mint"
	glass_icon_state = "mojito"
	glass_name = "Mojito"
	glass_desc = "A drink that looks as refreshing as it tastes."

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	description = "An incredibly bitter herbal liqueur used as a digestif."
	color = "#1B2E24" // rgb: 27, 46, 36
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 80
	taste_description = "utter bitterness"
	glass_name = "glass of fernet"
	glass_desc = "A glass of pure Fernet. Only an absolute madman would drink this alone." //Hi Kevum

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(1 * REM * delta_time, 0)
	M.adjust_nutrition(-5 * REM * delta_time)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fernet_cola
	name = "Fernet Cola"
	description = "A very popular and bittersweet digestif, ideal after a heavy meal. Best served on a sawed-off cola bottle as per tradition."
	color = "#390600" // rgb: 57, 6,
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "sweet relief"
	glass_icon_state = "godlyblend"
	glass_name = "glass of fernet cola"
	glass_desc = "A sawed-off cola bottle filled with Fernet Cola. Nothing better after eating like a lardass."

/datum/reagent/consumable/ethanol/fernet_cola/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(0.5 * REM * delta_time, 0)
	M.adjust_nutrition(-3 * REM * delta_time)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli

	name = "Fanciulli"
	description = "What if the Manhattan coctail ACTUALLY used a bitter herb liquour? Helps you sobers up. Doesn't sober up light drinkers." //also causes a bit of stamina damage to symbolize the afterdrink lazyness
	color = "#CA933F" // rgb: 202, 147, 63
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = -10
	quality = DRINK_NICE
	taste_description = "a sweet sobering mix"
	glass_icon_state = "fanciulli"
	glass_name = "glass of fanciulli"
	glass_desc = "A glass of Fanciulli. It's just Manhattan with Fernet."

/datum/reagent/consumable/ethanol/fanciulli/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_nutrition(-5 * REM * delta_time)
	M.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli/on_mob_metabolize(mob/living/M)
	if(M.health > 0)
		M.adjustStaminaLoss(20)
		. = TRUE
	..()


/datum/reagent/consumable/ethanol/branca_menta
	name = "Branca Menta"
	description = "A refreshing mixture of bitter Fernet with mint creme liquour."
	color = "#4B5746" // rgb: 75, 87, 70
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "a bitter freshness"
	glass_icon_state= "minted_fernet"
	glass_name = "glass of branca menta"
	glass_desc = "A glass of Branca Menta, perfect for those lazy and hot sunday summer afternoons." //Get lazy literally by drinking this


/datum/reagent/consumable/ethanol/branca_menta/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(-20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time, T0C)
	return ..()

/datum/reagent/consumable/ethanol/branca_menta/on_mob_metabolize(mob/living/M)
	if(M.health > 0)
		M.adjustStaminaLoss(35)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/blank_paper
	name = "Blank Paper"
	description = "A bubbling glass of blank paper. Just looking at it makes you feel fresh."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#DCDCDC" // rgb: 220, 220, 220
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 20
	quality = DRINK_GOOD
	taste_description = "bubbling possibility"
	glass_icon_state = "blank_paper"
	glass_name = "glass of blank paper"
	glass_desc = "A fizzy cocktail for those looking to start fresh."


/datum/reagent/consumable/ethanol/blank_paper/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.silent = max(M.silent, MIMEDRINK_SILENCE_DURATION)
	if(ishuman(M) && M.job == JOB_NAME_MIME)
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Fruit Wine"
	description = "A wine made from grown plants."
	color = "#FFFFFF"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "bad coding"
	var/list/names = list("null fruit" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("bad coding" = 1) //List of tastes. See above.

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	if(!data)
		return

	src.data = data
	names = data["names"]
	tastes = data["tastes"]
	boozepwr = data["boozepwr"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	boozepwr *= oldvolume
	var/newzepwr = data["boozepwr"] * amount
	boozepwr += newzepwr
	boozepwr /= volume //Blending boozepwr to volume.
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	//BYOND compiler bug means this must be an explicit constant
	var/const/minimum_percent = 0.15 //Percentages measured between 0 and 1.
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	glass_name = "glass of [name]"
	glass_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(minimum_percent*2 to INFINITY)
				primary_tastes += taste
			if(minimum_percent to minimum_percent*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "wine"
	else
		name = "mixed [names_in_order[1]] wine"

	var/alcohol_description
	switch(boozepwr)
		if(120 to INFINITY)
			alcohol_description = "suicidally strong"
		if(90 to 120)
			alcohol_description = "rather strong"
		if(70 to 90)
			alcohol_description = "strong"
		if(40 to 70)
			alcohol_description = "rich"
		if(20 to 40)
			alcohol_description = "mild"
		if(0 to 20)
			alcohol_description = "sweet"
		else
			alcohol_description = "watery" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "other plants"
	var/fruit_list = english_list(fruits)
	description = "A [alcohol_description] wine brewed from [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] alcohol")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", with a hint of "
		flavor += english_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()


/datum/reagent/consumable/ethanol/champagne //How the hell did we not have champagne already!?
	name = "Champagne"
	description = "A sparkling wine known for its ability to strike fast and hard."
	color = "#ffffc1"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 40
	taste_description = "auspicious occasions and bad decisions"
	glass_icon_state = "champagne_glass"
	glass_name = "Champagne"
	glass_desc = "The flute clearly displays the slowly rising bubbles."


/datum/reagent/consumable/ethanol/wizz_fizz
	name = "Wizz Fizz"
	description = "A magical potion, fizzy and wild! However the taste, you will find, is quite mild."
	color = "#4235d0" //Just pretend that the triple-sec was blue curacao.
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "friendship! It is magic, after all"
	glass_icon_state = "wizz_fizz"
	glass_name = "Wizz Fizz"
	glass_desc = "The glass bubbles and froths with an almost magical intensity."

/datum/reagent/consumable/ethanol/wizz_fizz/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	//A healing drink similar to Quadruple Sec, Ling Stings, and Screwdrivers for the Wizznerds; the check is consistent with the changeling sting
	if(M?.mind?.has_antag_datum(/datum/antagonist/wizard))
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time, 1 * REM * delta_time)
		M.adjustOxyLoss(-1 * REM * delta_time, 0)
		M.adjustToxLoss(-1 * REM * delta_time, 0)
	return ..()

/datum/reagent/consumable/ethanol/bug_spray
	name = "Bug Spray"
	description = "A harsh, acrid, bitter drink, for those who need something to brace themselves."
	color = "#33ff33"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "the pain of ten thousand slain mosquitos"
	glass_icon_state = "bug_spray"
	glass_name = "Bug Spray"
	glass_desc = "Your eyes begin to water as the sting of alcohol reaches them."

/datum/reagent/consumable/ethanol/bug_spray/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	//Bugs should not drink Bug spray.
	if(ismoth(M) || isflyperson(M) || isdiona(M))
		M.adjustToxLoss(1 * REM * delta_time, 0)
	return ..()

/datum/reagent/consumable/ethanol/bug_spray/on_mob_metabolize(mob/living/carbon/M)

	if(ismoth(M) || isflyperson(M) || isdiona(M))
		M.emote("scream")
	return ..()


/datum/reagent/consumable/ethanol/applejack
	name = "Applejack"
	description = "The perfect beverage for when you feel the need to horse around."
	color = "#ff6633"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 20
	taste_description = "an honest day's work at the orchard"
	glass_icon_state = "applejack_glass"
	glass_name = "Applejack"
	glass_desc = "You feel like you could drink this all neight."

/datum/reagent/consumable/ethanol/jack_rose
	name = "Jack Rose"
	description = "A light cocktail perfect for sipping with a slice of pie."
	color = "#ff6633"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 15
	quality = DRINK_NICE
	taste_description = "a sweet and sour slice of apple"
	glass_icon_state = "jack_rose"
	glass_name = "Jack Rose"
	glass_desc = "Enough of these, and you really will start to suppose your toeses are roses."

/datum/reagent/consumable/ethanol/turbo
	name = "Turbo"
	description = "A turbulent cocktail associated with outlaw hoverbike racing. Not for the faint of heart."
	color = "#e94c3a"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 85
	quality = DRINK_VERYGOOD
	taste_description = "the outlaw spirit"
	glass_icon_state = "turbo"
	glass_name = "Turbo"
	glass_desc = "A turbulent cocktail for outlaw hoverbikers."

/datum/reagent/consumable/ethanol/turbo/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(2, delta_time))
		to_chat(M, span_notice("[pick("You feel disregard for the rule of law.", "You feel pumped!", "Your head is pounding.", "Your thoughts are racing..")]"))
	M.adjustStaminaLoss(-0.25 * M.drunkenness * REM * delta_time)
	return ..()

/datum/reagent/consumable/ethanol/old_timer
	name = "Old Timer"
	description = "An archaic potation enjoyed by old coots of all ages."
	color = "#996835"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "simpler times"
	glass_icon_state = "old_timer"
	glass_name = "Old Timer"
	glass_desc = "WARNING! May cause premature aging!"

/datum/reagent/consumable/ethanol/old_timer/on_mob_life(mob/living/carbon/human/metabolizer, delta_time, times_fired)
	if(DT_PROB(10, delta_time) && istype(metabolizer))
		metabolizer.age += 1
		if(metabolizer.age > 70)
			metabolizer.facial_hair_color = "ccc"
			metabolizer.hair_color = "ccc"
			metabolizer.update_hair()
			if(metabolizer.age > 100)
				metabolizer.become_nearsighted(type)
				if(metabolizer.gender == MALE)
					metabolizer.facial_hair_style = "Beard (Very Long)"
					metabolizer.update_hair()

				if(metabolizer.age > 969) //Best not let people get older than this or i might incur G-ds wrath
					metabolizer.visible_message(span_notice("[metabolizer] becomes older than any man should be.. and crumbles into dust!"))
					metabolizer.dust(just_ash = FALSE, drop_items = TRUE, force = FALSE)

	return ..()

/datum/reagent/consumable/ethanol/rubberneck
	name = "Rubberneck"
	description = "A quality rubberneck should not contain any gross natural ingredients."
	color = "#ffe65b"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "artifical fruityness"
	glass_icon_state = "rubberneck"
	glass_name = "Rubberneck"
	glass_desc = "A popular drink amongst those adhering to an all synthetic diet."

/datum/reagent/consumable/ethanol/duplex
	name = "Duplex"
	description = "An inseparable combination of two fruity drinks."
	color = "#50e5cf"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "green apples and blue raspberries"
	glass_icon_state = "duplex"
	glass_name = "Duplex"
	glass_desc = "To imbibe one component separately from the other is consider a great faux pas."

/datum/reagent/consumable/ethanol/trappist
	name = "Trappist Beer"
	description = "A strong dark ale brewed by space-monks."
	color = "#390c00"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 40
	quality = DRINK_VERYGOOD
	taste_description = "dried plums and malt"
	glass_icon_state = "trappistglass"
	glass_name = "Trappist Beer"
	glass_desc = "boozy Catholicism in a glass."

/datum/reagent/consumable/ethanol/trappist/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.mind?.holy_role)
		M.adjustFireLoss(-2.5 * REM * delta_time, 0)
		M.jitteriness = max(M.jitteriness - (1 * REM * delta_time), 0)
		M.stuttering = max(M.stuttering - (1 * REM * delta_time), 0)
	return ..()

/datum/reagent/consumable/ethanol/blazaam
	name = "Blazaam"
	description = "A strange drink that few people seem to remember existing. Doubles as a Berenstain remover."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY // don't put CHEMICAL_GOAL_BARTENDER_SERVING. peach juice is totally RNG to get
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "alternate realities"
	glass_icon_state = "blazaamglass"
	glass_name = "Blazaam"
	glass_desc = "The glass seems to be sliding between realities. Doubles as a Berenstain remover."

	var/stored_teleports = 0

/datum/reagent/consumable/ethanol/blazaam/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.drunkenness > 40)
		if(stored_teleports)
			do_teleport(M, get_turf(M), rand(1,3), channel = TELEPORT_CHANNEL_WORMHOLE)
			stored_teleports--

		if(DT_PROB(5, delta_time))
			stored_teleports += rand(2, 6)
			if(prob(70))
				M.vomit()
	return ..()


/datum/reagent/consumable/ethanol/planet_cracker
	name = "Planet Cracker"
	description = "This jubilant drink celebrates humanity's triumph over the alien menace. May be offensive to non-human crewmembers."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "triumph with a hint of bitterness"
	glass_icon_state = "planet_cracker"
	glass_name = "Planet Cracker"
	glass_desc = "Although historians believe the drink was originally created to commemorate the end of an important conflict in man's past, its origins have largely been forgotten and it is today seen more as a general symbol of human supremacy."

/datum/reagent/consumable/ethanol/mauna_loa
	name = "Mauna Loa"
	description = "Extremely hot; not for the faint of heart!"
	boozepwr = 40
	color = "#fe8308" // 254, 131, 8
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_FANTASTIC
	taste_description = "fiery, with an aftertaste of burnt flesh"
	glass_icon_state = "mauna_loa"
	glass_name = "Mauna Loa"
	glass_desc = "Lavaland in a drink... mug... volcano... thing."


/datum/reagent/consumable/ethanol/mauna_loa/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	// Heats the user up while the reagent is in the body. Occasionally makes you burst into flames.
	M.adjust_bodytemperature(25 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time)
	if (DT_PROB(2.5, delta_time))
		M.adjust_fire_stacks(1)
		M.IgniteMob()
	..()

/datum/reagent/consumable/ethanol/painkiller
	name = "Painkiller"
	description = "Dulls your pain. Your emotional pain, that is."
	boozepwr = 20
	color = "#EAD677"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_NICE
	taste_description = "sugary tartness"
	glass_icon_state = "painkiller"
	glass_name = "Painkiller"
	glass_desc = "A combination of tropical juices and rum. Surely this will make you feel better."

/datum/reagent/consumable/ethanol/pina_colada
	name = "Pina Colada"
	description = "A fresh pineapple drink with coconut rum. Yum."
	boozepwr = 40
	color = "#FFF1B2"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	quality = DRINK_FANTASTIC
	taste_description = "pineapple, coconut, and a hint of the ocean"
	glass_icon_state = "pina_colada"
	glass_name = "Pina Colada"
	glass_desc = "If you like pina coladas, and getting caught in the rain... well, you'll like this drink."

/datum/reagent/consumable/ethanol/plasmaflood
	name = "Plasma Flood"
	description = "Not very popular with plasmamen, for obvious reasons."
	color = "#630480" // rgb: 99, 4, 128
	chem_flags = NONE
	boozepwr = 60
	quality = DRINK_NICE
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "a plasma fire in your mouth"
	glass_icon_state = "plasmaflood"
	glass_name = "Plasma Flood"
	glass_desc = "A favorite of the grey tide. Ironically, not recommended to stand in plasma while drinking this."

/datum/reagent/consumable/ethanol/plasmaflood/on_mob_metabolize(mob/living/L)
	to_chat(L, span_notice("You feel immune to the fire!"))
	. = ..()

/datum/reagent/consumable/ethanol/plasmaflood/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(prob(80))
		M.IgniteMob()
		M.adjust_fire_stacks(10 * REM * delta_time)

	if(M.fire_stacks > 9)
		if(M.on_fire)
			M.adjustFireLoss(-16 * REM * delta_time, 0)

	..()

/datum/reagent/consumable/ethanol/plasmaflood/on_mob_end_metabolize(mob/living/L)
	to_chat(L, span_warning("You no longer feel immune to burning!"))
	. = ..()

/datum/reagent/consumable/ethanol/fourthwall
	name = "Fourth Wall"
	description = "This substance seems like it shouldn't exist."
	color = "#0b43a3"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 0 //I feel like brain traumas is enough
	quality = DRINK_GOOD
	metabolization_rate = 0.3
	taste_description = "binary"
	glass_icon_state = "fourthwallglass"
	glass_name = "Fourth Wall"
	glass_desc = "Just looking at this makes your head hurt."
	var/list/trauma_list

/datum/reagent/consumable/ethanol/fourthwall/proc/traumaweightpick(var/mild,var/severe,var/special)
	return pick(pick_weight(list(subtypesof(/datum/brain_trauma/mild) = mild, subtypesof(/datum/brain_trauma/severe) - /datum/brain_trauma/severe/split_personality - /datum/brain_trauma/severe/hypnotic_stupor = severe, subtypesof(/datum/brain_trauma/special) - typesof(/datum/brain_trauma/special/imaginary_friend) = special)))

/datum/reagent/consumable/ethanol/fourthwall/on_mob_metabolize(mob/living/carbon/M)
	trauma_list = list()
	to_chat(M, span_warning("Your mind breaks, as you realize your reality is just some comupter game."))
	var/datum/brain_trauma/trauma = traumaweightpick(60,40,0)
	trauma = new trauma()
	trauma_list += trauma
	M.gain_trauma(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/consumable/ethanol/fourthwall/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/datum/brain_trauma/OD_trauma
	M.Jitter(2)
	if(DT_PROB(2.5, delta_time) && current_cycle > 10)
		switch(current_cycle) //The longer they're on this stuff, the higher the chance for worse brain trauma
			if(10 to 50)
				to_chat(M, span_warning("Your mind cracks."))
				OD_trauma = traumaweightpick(50,40,10)
			if(50 to 100)
				to_chat(M, span_warning("Your mind splinters."))
				OD_trauma = traumaweightpick(30,50,20)
			if(100 to INFINITY)
				to_chat(M, span_warning("Your mind shatters."))
				OD_trauma = traumaweightpick(20,50,30)
		OD_trauma = new OD_trauma()
		trauma_list += OD_trauma
		M.gain_trauma(OD_trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/consumable/ethanol/fourthwall/on_mob_end_metabolize(mob/living/carbon/M)
	to_chat(M, span_notice("You know that you figured out something important, but can't quite remember what it is. Your head feels a lot better."))
	for(var/T in trauma_list)
		QDEL_NULL(T)
	return ..()

/datum/reagent/consumable/ethanol/ratvander
	name = "Rat'vander Cocktail"
	description = "Side effects include hoarding brass and hatred of blood."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "sweet brass"
	glass_icon_state = "ratvander"
	glass_name = "Rat'vander Cocktail"
	glass_desc = "A new cocktail originally mixed by TRNE Corp. Said to be embued with eldritch magic."


/datum/reagent/consumable/ethanol/ratvander/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(5, delta_time))
		to_chat(M, span_warning(pick("You can faintly hear the sound of gears.","You can feel an unnatural hatred towards exposed blood.","You swear you can feel steam eminating from the drink.","You hear faint, pleasant whispers.","You can see a white void within your mind.")))
	M.clockslurring = min(M.clockslurring + (3 * REM * delta_time), 3)
	M.stuttering = min(M.stuttering + (3 * REM * delta_time), 3)
	..()

/datum/reagent/consumable/ethanol/icewing
	name = "Icewing"
	description = "A frost beam on ice."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "frostburn"
	glass_icon_state = "icewing"
	glass_name = "Icewing"
	glass_desc = "A watcher hunter's drink of choice. Will heal your frostburns, or cool you down."


/datum/reagent/consumable/ethanol/icewing/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(-8 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, M.get_body_temp_normal())
	if(M.bodytemperature <= BODYTEMP_COLD_DAMAGE_LIMIT) //heals burn if freezing
		M.adjustFireLoss(-5 * REM * delta_time, 0)
	..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset
	name = "Sarsaparillian Sunset"
	description = "The taste of the waste."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "pleasant burning"
	glass_icon_state = "sarsaparilliansunset"
	glass_name = "Sarsaparillian Sunset"
	glass_desc = "The view of a sunset over an irradiated wasteland. Calms your burns, but don't drink too much."
	var/datum/action/spell/power = /datum/action/spell/basic_projectile/weak
	overdose_threshold = 50
	metabolization_rate = 0.5

/datum/reagent/consumable/ethanol/sarsaparilliansunset/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustFireLoss(-3 * REM * delta_time, 0)
	..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset/overdose_start(mob/living/M)
	to_chat(M, span_warning("You feel a heat from your abdomen, burning you from the inside!"))
	power = new power()
	power.Grant(M)
	. = ..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset/overdose_process(mob/living/M)
	M.adjustFireLoss(7, 0)
	. = ..()

/datum/reagent/consumable/ethanol/sarsaparilliansunset/on_mob_end_metabolize(mob/living/M)
	to_chat(M, span_notice("The fire inside of you calms down."))
	power.Remove(M)
	return ..()

/datum/action/spell/basic_projectile/weak
	name = "Fire Upchuck"
	desc = "You can feel heat rising from your stomach"
	projectile_range = 20
	cooldown_time = 300
	projectile_type = /obj/projectile/magic/fireball/firebreath/weak

/obj/projectile/magic/fireball/firebreath/weak
	exp_fire = 1

/datum/reagent/consumable/ethanol/beesknees
	name = "Bee's Knees"
	description = "This has way too much honey."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	boozepwr = 35
	quality = 0
	taste_description = "sweeter mead"
	glass_icon_state = "beesknees"
	glass_name = "Bee's Knees"
	glass_desc = "This glass is oozing with honey. A bit too much honey to look appealing for anyone but a certain insect."

/datum/reagent/consumable/ethanol/beesknees/on_mob_metabolize(mob/living/M)
	if(is_species(M, /datum/species/apid))
		to_chat(M, span_notice("What a good drink! Reminds you of the honey back home."))
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_fantastic)
	else
		to_chat(M, span_warning("That drink was way too sweet! You feel sick."))
		M.adjust_disgust(10)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
	. = ..()

/datum/reagent/consumable/ethanol/beesknees/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(is_species(M, /datum/species/apid))
		M.adjustBruteLoss(-1.5 * REM * delta_time, 0)
		M.adjustFireLoss(-1.5 * REM * delta_time, 0)
		M.adjustToxLoss(-1 * REM * delta_time, 0)
	. = ..()
