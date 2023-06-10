/// Maximum distance from 0 that a bullet hole can appear at
#define MAX_OFFSET 14

TYPEINFO(/datum/component/bullet_holes)
	initialization_args = list(
		ARG_INFO("max_holes", DATA_INPUT_NUM, "The maximum number of holes that can appear on this object.", 10),
		ARG_INFO("req_damage", DATA_INPUT_NUM, "The amount of power required for a projectile to leave a decal (for armored things)", 0)
	)


/// A component which makes bullet holes appear on a thing when it gets shot
/datum/component/bullet_holes
	var/max_holes = 10
	var/req_damage = 0
	var/list/impact_images
	var/image/impact_image_base

	var/list/cooldowns //datums don't have this inherently

/datum/component/bullet_holes/Initialize(max_holes, req_damage)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.max_holes = max_holes
	src.req_damage = req_damage
	src.impact_images = list()
	src.impact_image_base = image('icons/obj/projectiles.dmi', "blank")
	src.impact_image_base.blend_mode = BLEND_INSET_OVERLAY // so the holes don't go over the edge of things

	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, .proc/handle_impact)
	RegisterSignal(parent, COMSIG_UPDATE_ICON, .proc/redraw_impacts) // just in case
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, .proc/get_examine_msg)


/datum/component/bullet_holes/proc/handle_impact(rendering_on, obj/projectile/shot)
	var/datum/projectile/shotdata = shot.proj_data
	if (!shotdata.impact_image_state)
		return

	if (length(src.impact_images) <= max_holes)
		var/image/impact = image('icons/obj/projectiles.dmi', shot.proj_data.impact_image_state)
		// Rotate the decal randomly for variety
		impact.transform = turn(impact.transform, rand(360, 1))

		// Apply offset based on dir. The side we want to put holes on is opposite the dir of the bullet
		// i.e. left facing bullet hits right side of wall
		// I guess you could kinda use this for forensics. Neat
		var/impact_side_dir = opposite_dir_to(shot.dir) // which edge of this object are we drawing the decals on
		impact.pixel_x += impact_side_dir & WEST ?  rand(0, -MAX_OFFSET) : (impact_side_dir & EAST ? rand(MAX_OFFSET) : rand(-MAX_OFFSET, MAX_OFFSET))
		impact.pixel_y += impact_side_dir & SOUTH ?  rand(0, -MAX_OFFSET) : (impact_side_dir & NORTH ? rand(MAX_OFFSET) : rand(-MAX_OFFSET, MAX_OFFSET))

		src.impact_images += impact
		src.redraw_impacts()

/datum/component/bullet_holes/proc/redraw_impacts()
	if (ON_COOLDOWN(src, "bullet hole render", 0.1 SECONDS))
		return

	var/atom/A = src.parent
	src.impact_image_base.overlays = null
	for (var/image/impact_image in src.impact_images)
		src.impact_image_base.overlays += impact_image
	A.UpdateOverlays(src.impact_image_base, "projectiles")

/datum/component/bullet_holes/proc/get_examine_msg(irrelevant, mob/examiner, list/lines)
	if (length(src.impact_images))
		var/shots_taken = 0
		for (var/i in src.impact_images)
			shots_taken++
		lines += "<br>[src] has [shots_taken] hole[s_es(shots_taken)] in it."
