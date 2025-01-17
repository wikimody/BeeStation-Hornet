//nutrition
/datum/mood_event/fat
	description = "<span class='warning'><B>I'm so fat.</B></span>" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "<span class='nicegreen'>I'm stuffed!</span>"
	mood_change = 8

/datum/mood_event/fed
	description = "<span class='nicegreen'>I have recently had some food.</span>"
	mood_change = 5

/datum/mood_event/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>"
	mood_change = -10

/datum/mood_event/starving
	description = "<span class='boldwarning'>I'm starving!</span>"
	mood_change = -16

//charge
/datum/mood_event/charged
	description = "<span class='nicegreen'>I feel the power in my veins!</span>"
	mood_change = 6

/datum/mood_event/lowpower
	description = "<span class='warning'>My power is running low, I should go charge up somewhere.</span>"
	mood_change = -10

/datum/mood_event/decharged
	description = "<span class='boldwarning'>I'm in desperate need of some electricity!</span>"
	mood_change = -15

//Disgust
/datum/mood_event/gross
	description = "<span class='warning'>I saw something gross.</span>"
	mood_change = -4

/datum/mood_event/verygross
	description = "<span class='warning'>I think I'm going to puke.</span>"
	mood_change = -6

/datum/mood_event/disgusted
	description = "<span class='boldwarning'>Oh god, that's disgusting.</span>"
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "<span class='warning'>I can smell something horribly decayed inside this room.</span>"
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "<span class='warning'>The stench of rotting carcasses is unbearable!</span>"
	mood_change = -12

//Generic needs events
/datum/mood_event/nice_shower
	description = "<span class='nicegreen'>I have recently had a nice shower.</span>"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = "<span class='nicegreen'>There's nothing like the feeling of a freshly laundered jumpsuit.</span>"
	mood_change = 2
	timeout = 10 MINUTES
