///Something you can plop down in the map editor as a reference for screen size and what bits will get obscured by the HUD
/obj/mapping_HUD_template
	icon = 'icons/map-editing/mapping_HUD_template.dmi'
	icon_state = "template" //blue is TG HUD, yellow is regular
	plane = PLANE_HUD

	New()
		..()
		qdel(src)
