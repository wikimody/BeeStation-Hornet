#define DEFAULT_METEOR_LIFETIME 1800
GLOBAL_VAR_INIT(meteor_wave_delay, 625) //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
							/obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=3)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium=4, /obj/effect/meteor/big=8, \
							/obj/effect/meteor/flaming=3, /obj/effect/meteor/irradiated=3)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium=5, /obj/effect/meteor/big=75, \
							/obj/effect/meteor/flaming=10, /obj/effect/meteor/irradiated=10, /obj/effect/meteor/tunguska = 1)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meteorsB, list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1)) //for meaty ore event

GLOBAL_LIST_INIT(meteorsC, list(/obj/effect/meteor/dust)) //for space dust event


///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteortypes, z = 0)
	for(var/i in 1 to number)
		spawn_meteor(meteortypes, z)

/proc/spawn_meteor(list/meteortypes, z = 0)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10//number of tries to spawn meteor.
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinals)
		var/startZ = (z || pick(SSmapping.levels_by_trait(ZTRAIT_STATION)))
		pickedstart = spaceDebrisStartLoc(startSide, startZ)
		pickedgoal = spaceDebrisFinishLoc(startSide, startZ)
		max_i--
		if(max_i<=0)
			return
	var/Me = pick_weight(meteortypes)
	new Me(pickedstart, pickedgoal)

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			startx = (TRANSITIONEDGE+1)
	. = locate(startx, starty, Z)

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = (TRANSITIONEDGE+1)
			endx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			endy = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			endx = (TRANSITIONEDGE+1)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE+1)
			endx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			endy = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			endx = world.maxx-(TRANSITIONEDGE+1)
	. = locate(endx, endy, Z)

//These two procs give space debris start and end turfs with a higher chance of hitting the center of the station
/proc/aimbotDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	var/generator/G = generator("num", TRANSITIONEDGE + 1, world.maxx - (TRANSITIONEDGE + 1), "NORMAL_RAND")
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = G.Rand()
		if(EAST)
			starty = G.Rand()
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = G.Rand()
		if(WEST)
			starty = G.Rand()
			startx = (TRANSITIONEDGE+1)
	. = locate(startx, starty, Z)

/proc/aimbotDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	var/generator/G = generator("num", TRANSITIONEDGE + 1, world.maxx - (TRANSITIONEDGE + 1), NORMAL_RAND)
	switch(startSide)
		if(NORTH)
			endy = (TRANSITIONEDGE+1)
			endx = G.Rand()
		if(EAST)
			endy = G.Rand()
			endx = (TRANSITIONEDGE+1)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE+1)
			endx = G.Rand()
		if(WEST)
			endy = G.Rand()
			endx = world.maxx-(TRANSITIONEDGE+1)
	. = locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "\proper the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	anchored = TRUE
	var/hits = 4
	var/hitpwr = 2 //Level of ex_act to be called on hit.
	pass_flags = PASSTABLE
	var/heavy = 0
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original
	var/threat = 0 // used for determining which meteors are most interesting
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	var/dropamt = 2
	///The thing we're moving towards, usually a turf
	var/atom/dest
	///Lifetime in seconds
	var/lifetime = DEFAULT_METEOR_LIFETIME


CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/meteor)

/obj/effect/meteor/Initialize(mapload, target)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SSaugury.register_doom(src, threat)
	SpinAnimation()
	chase_target(target)

/obj/effect/meteor/Destroy()
	GLOB.meteor_list -= src
	SSaugury.unregister_doom(src)
	if(istype(loc, /obj/effect/falling_meteor))
		var/obj/effect/falling_meteor/holder = loc
		holder.contained_meteor = null
		if(!QDELETED(holder))
			qdel(holder)
	. = ..()
/obj/effect/meteor/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(QDELETED(src))
		return
	if(OldLoc != loc)//If did move, ram the turf we get in
		var/turf/T = get_turf(loc)
		ram_turf(T)

		if(prob(10) && !isspaceturf(T))//randomly takes a 'hit' from ramming
			get_hit()

	if(z != z_original || loc == get_turf(dest))
		qdel(src)
		return

/obj/effect/meteor/Process_Spacemove()
	return TRUE //Keeps us from drifting for no reason

/obj/effect/meteor/Bump(atom/A)
	if(A)
		ram_turf(get_turf(A))
		playsound(src.loc, meteorsound, 40, 1)
		get_hit()

/obj/effect/meteor/proc/chase_target(atom/chasing, delay, home)
	if(!isatom(chasing))
		return
	var/datum/move_loop/new_loop = SSmove_manager.move_towards(src, chasing, delay, home, lifetime)
	if(!new_loop)
		return

	RegisterSignal(new_loop, COMSIG_PARENT_QDELETING, PROC_REF(handle_stopping))

///Deals with what happens when we stop moving, IE we die
/obj/effect/meteor/proc/handle_stopping()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first yell at mobs about them dying horribly
	for(var/mob/living/living_thing in T)
		living_thing.visible_message(span_warning("[src] slams into [living_thing]."), span_userdanger("[src] slams into you!."))

	//then, ram the turf
	switch(hitpwr)
		if(EXPLODE_DEVASTATE)
			SSexplosions.highturf += T
		if(EXPLODE_HEAVY)
			SSexplosions.medturf += T
		if(EXPLODE_LIGHT)
			SSexplosions.lowturf += T

//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/effect/meteor/examine(mob/user)
	. = ..()
	if(!(flags_1 & ADMIN_SPAWNED_1) && isliving(user))
		user.client.give_award(/datum/award/achievement/misc/meteor_examine, user)

/obj/effect/meteor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MINING)
		make_debris()
		qdel(src)
	else
		. = ..()

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		new thing_to_spawn(get_turf(src))

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		var/sound/meteor_sound = sound(meteorsound)
		var/random_frequency = get_rand_frequency()

		for(var/mob/M in GLOB.player_list)
			if((M.orbiting) && (SSaugury.watchers[M]))
				continue
			var/turf/T = get_turf(M)
			if(!T || T.get_virtual_z_level() != src.get_virtual_z_level())
				continue
			var/dist = get_dist(M.loc, src.loc)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(src.loc, null, 50, 1, random_frequency, 10, S = meteor_sound)

/obj/effect/meteor/has_gravity(turf/T)
	return FALSE

///////////////////////
//Meteor types
///////////////////////

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = 3
	meteorsound = 'sound/weapons/gunshot_smg.ogg'
	meteordrop = list(/obj/item/stack/ore/glass)
	threat = 1

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3
	threat = 5

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(src.loc, 0, 1, 2, 3, 0)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 6
	heavy = 1
	dropamt = 4
	threat = 10

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = 1
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 20

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = 1
	meteordrop = list(/obj/item/stack/ore/uranium)
	threat = 15


/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src.loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, 500)

//Meaty Ore
/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = 1
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/food/meat/slab/human, /obj/item/food/meat/slab/human/mutant, /obj/item/organ/heart, /obj/item/organ/lungs, /obj/item/organ/tongue, /obj/item/organ/appendix/)
	var/meteorgibs = /obj/effect/gibspawner/generic
	threat = 2

/obj/effect/meteor/meaty/Initialize(mapload)
	for(var/path in meteordrop)
		if(path == /obj/item/food/meat/slab/human/mutant)
			meteordrop -= path
			meteordrop += pick(subtypesof(path))

	for(var/path in meteordrop)
		if(path == /obj/item/organ/tongue)
			meteordrop -= path
			meteordrop += pick(typesof(path))
	return ..()

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/meaty/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood(T)

/obj/effect/meteor/meaty/Bump(atom/A)
	EX_ACT(A, hitpwr)
	get_hit()

//Meaty Ore Xeno edition
/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = list(/obj/item/food/meat/slab/xeno, /obj/item/organ/tongue/alien)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/effect/meteor/meaty/xeno/Initialize(mapload)
	meteordrop += subtypesof(/obj/item/organ/alien)
	return ..()

/obj/effect/meteor/meaty/xeno/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/xenoblood(T)

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 30
	hitpwr = 1
	heavy = 1
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 50

/obj/effect/meteor/tunguska/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(src.loc, 5, 10, 15, 20, 0)

/obj/effect/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(src.loc,2,4,6,8)

//////////////////////////
//Spookoween meteors
/////////////////////////

GLOBAL_LIST_INIT(meteorsSPOOKY, list(/obj/effect/meteor/pumpkin))

/obj/effect/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	hits = 10
	heavy = 1
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/utility/hardhat/pumpkinhead, /obj/item/food/grown/pumpkin)
	threat = 100

/obj/effect/meteor/pumpkin/Initialize(mapload)
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')
//////////////////////////
#undef DEFAULT_METEOR_LIFETIME

//////////////////////////
// Falling meteors
/////////////////////////

/obj/effect/falling_meteor
	name = "falling meteor"
	desc = "..."
	alpha = 0
	var/obj/effect/meteor/contained_meteor
	var/obj/effect/meteor_shadow/shadow
	var/falltime = 2 SECONDS
	var/prefalltime = 8 SECONDS
	layer = METEOR_LAYER

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/falling_meteor)

/obj/effect/falling_meteor/Initialize(mapload, meteor_type)
	. = ..()
	if(!meteor_type)
		meteor_type = /obj/effect/meteor/big
	contained_meteor = new meteor_type(src)
	name = contained_meteor.name
	desc = contained_meteor.desc
	icon = contained_meteor.icon
	icon_state = contained_meteor.icon_state
	var/matrix/M = new()
	M.Scale(3, 3)
	M.Translate(-1.5 * world.icon_size, -1.5 * world.icon_size)
	M.Translate(0, world.icon_size * 7)
	transform = M
	INVOKE_ASYNC(src, PROC_REF(fall_animation))

/obj/effect/falling_meteor/Destroy(force)
	if(contained_meteor)
		QDEL_NULL(contained_meteor)
	QDEL_NULL(shadow)
	. = ..()

/obj/effect/falling_meteor/proc/fall_animation()
	//Create a dummy effect
	shadow = new(get_turf(src))
	shadow.icon = icon
	shadow.icon_state = icon_state
	animate(shadow, time = (prefalltime + falltime), transform = matrix(), alpha = 255)
	sleep(prefalltime)
	animate(src, 5, alpha = 255)
	animate(src, falltime, transform = matrix(), flags = ANIMATION_PARALLEL)
	sleep(falltime)
	if (istype(loc, /turf/open/openspace))
		fall_below()
	//Trigger multiple simulated bumps (Z levels are much more expensive to travel)
	contained_meteor.forceMove(loc)
	contained_meteor.hits -= rand(4, 10)
	contained_meteor.Bump(loc)
	//If the meteor was deleted by the bumps, destroy the falling meteor
	if (QDELETED(contained_meteor))
		qdel(src)
	else
		//Fall down and repeat if possible
		contained_meteor.forceMove(src)
		//Try to fall down
		if (!fall_below())
			qdel(src)

/obj/effect/falling_meteor/proc/fall_below()
	var/turf/current = loc
	if (!istype(current))
		return FALSE
	var/turf/below = GET_TURF_BELOW(current)
	//Move down a layer and fall again
	if (below != null)
		forceMove(below)
		fall_animation()
		return TRUE
	return FALSE

/obj/effect/meteor_shadow
	name = "shadow"
	desc = "What the hell? Is something falling out the sky???"
	alpha = 0
	layer = METEOR_SHADOW_LAYER

/obj/effect/meteor_shadow/Initialize(mapload)
	. = ..()
	color = list(0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/matrix/M = matrix()
	M.Scale(3, 3)
	M.Translate(-1.5 * world.icon_size, -1.5 * world.icon_size)
	transform = M
