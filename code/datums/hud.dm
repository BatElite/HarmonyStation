/atom/movable/screen
	anchored = 1
	plane = PLANE_HUD//wow WOW why won't you use /atom/movable/screen/hud, HUD OBJECTS???
	text = ""
	New()
		..()
		appearance_flags |= NO_CLIENT_COLOR

/atom/movable/screen/hud
	plane = PLANE_HUD
	var/datum/hud/master
	var/id = ""
	var/tooltipTheme
	var/obj/item/item

	clicked(list/params)
		sendclick(params, usr)

	proc/sendclick(list/params,mob/user = null)
		if (master && (!master.click_check || (user in master.mobs)))
			master.relay_click(src.id, user, params)

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (src.id == "stats" && istype(master, /datum/hud/human))
			var/datum/hud/human/H = master
			H.update_stats()
		if (usr.client.tooltipHolder && src.tooltipTheme)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = (src.desc ? src.desc : null),
				"theme" = src.tooltipTheme
			))
		else
			if (master && (!master.click_check || (usr in master.mobs)))
				master.MouseEntered(src, location, control, params)

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseExited(src)

	MouseWheel(dx, dy, loc, ctrl, parms)
		if (master && (!master.click_check || (usr in master.mobs)))
			master.scrolled(src.id, dx, dy, usr, parms, src)

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if (master && (!master.click_check || (usr in master.mobs)))
			master.MouseDrop(src, over_object, src_location, over_location, over_control, params)

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (master && (!master.click_check || (user in master.mobs)))
			master.MouseDrop_T(src, O, user)

	disposing()
		src.screen_loc = null // idk if this is necessary but im writing it anyways so there
		..()


/datum/hud
	var/list/mob/living/mobs = list()
	var/list/client/clients = list()
	var/list/atom/movable/screen/hud/objects = list()
	var/click_check = 1

	/**
	* assoc list of hud zones with the format:
	*
	* list(
	*
	*	"zone_alias" = list(
	*
	*		"coords" = list( // list of 2 coordinate pairs for the lower left corner and the upper right corner of the hud zone
	*			x_low = num, y_low = num, x_high = num, y_high = num
	*
	*		"elements" = list( // list of all visible hud elements in the hud zone
	*			"elem_alias" = screenobj // screenobj is the hud object that is visible on the players screen
	*
	*		"horizontal_edge" = "" // what horizontal edge of the zone elements are initially added from. should be EAST or WEST.
	*
	*		"vertical_edge" = "" // what vertical edge of the zone elements are intially added from. should be NORTH or SOUTH.
	*
	*		"horizontal_offset" = num // offset for the horizontal placement of elements, used when placing new elements so they dont overlap
	*
	*		"vertical_offset" = num // offset for the horizontal placement of elements, used when placing new elements so they dont overlap
	**/
	var/list/list/list/hud_zones = null

	disposing()
		for (var/mob/M in src.mobs)
			M.detach_hud(src)
		for (var/atom/movable/screen/hud/S in src.objects)
			if (S.master == src)
				S.master = null
		for (var/client/C in src.clients)
			remove_client(C)

		src.clear_master()
		..()

	proc/clear_master() //only some have masters. i use this for clean gc. itzs messy, im sorry
		.= 0

	proc/check_objects()
		for (var/i = 1; i <= src.objects.len; i++)
			var/j = 0
			while (j+i <= src.objects.len && isnull(src.objects[j+i]))
				j++
			if (j)
				src.objects.Cut(i, i+j)

	proc/add_client(client/C)
		check_objects()
		C.screen += src.objects
		src.clients += C

	proc/remove_client(client/C)
		src.clients -= C
		for (var/atom/A in src.objects)
			C.screen -= A

	proc/create_screen(id, name, icon = null, state = null, loc, layer = HUD_LAYER, dir = SOUTH, tooltipTheme = null, desc = null, customType = null, mouse_opacity = 1)
		var/atom/movable/screen/hud/S
		if (customType)
			if (!ispath(customType, /atom/movable/screen/hud))
				CRASH("Invalid type passed to create_screen ([customType])")
			S = new customType
		else
			S = new

		S.name = name
		S.desc = desc
		S.id = id
		S.master = src
		//these two are optional now for the sake of borg hud (I'm making subtypes) but if you do leave them out elsewhere it'll probably be a bad time
		if (!isnull(icon))
			S.icon = icon
		if (!isnull(state))
			S.icon_state = state
		S.screen_loc = loc
		S.layer = layer
		S.set_dir(dir)
		S.tooltipTheme = tooltipTheme
		S.mouse_opacity = mouse_opacity
		src.objects += S

		for (var/client/C in src.clients)
			C.screen += S
		return S

	proc/add_object(atom/movable/A, layer = HUD_LAYER, loc)
		if (loc)
			A.screen_loc = loc
		A.layer = layer
		A.plane = PLANE_HUD
		if (!(A in src.objects))
			src.objects += A
			for (var/client/C in src.clients)
				C.screen += A

	proc/remove_object(atom/movable/A)
		A.plane = initial(A.plane) // object should really be restoring this by itself, but we'll just make sure it doesnt get trapped in the HUD plane
		if (src.objects)
			src.objects -= A
		for (var/client/C in src.clients)
			C.screen -= A

	proc/add_screen(atom/movable/screen/S)
		if (!(S in src.objects))
			src.objects += S
			for (var/client/C in src.clients)
				C.screen += S

	proc/set_visible_id(id, visible)
		var/atom/movable/screen/S = get_by_id(id)
		if(S)
			if(visible)
				S.invisibility = INVIS_NONE
			else
				S.invisibility = INVIS_ALWAYS
		return

	proc/set_visible(atom/movable/screen/S, visible)
		if(S)
			if(visible)
				S.invisibility = INVIS_NONE
			else
				S.invisibility = INVIS_ALWAYS
		return

	proc/remove_screen(atom/movable/screen/S)
		src.objects -= S
		for (var/client/C in src.clients)
			C.screen -= S

	proc/remove_screen_id(var/id)
		var/atom/movable/screen/S = get_by_id(id)
		if(S)
			src.objects -= S
			for (var/client/C in src.clients)
				C.screen -= S

	proc/get_by_id(var/id)
		for(var/atom/movable/screen/hud/SC in src.objects)
			if(SC.id == id)
				return SC
		return null

	proc/relay_click(id)
	proc/scrolled(id, dx, dy, user, parms)
	proc/MouseEntered(id,location, control, params)
	proc/MouseExited(id)
	proc/MouseDrop(var/atom/movable/screen/hud/H, atom/over_object, src_location, over_location, over_control, params)
	proc/MouseDrop_T(var/atom/movable/screen/hud/H, atom/movable/O as obj, mob/user as mob)

/*
	dynamic hud stuff
	if you want to use this i strongly recommend looking at existing examples of how it's used
	i also strongly recommend copying the hud_layout_template.png file
	it is 21x15 (like widescreen mode) and you can colour in cells to show different hud zones
	this makes it easier to see where things are in relation to eachother, since codewise its all coordinate pairs
	and coordinate pairs are harder to intuit
*/

/**
* defines a hud zone within the bounds of the screen at the supplied coordinates
*
* dimensions: assoc list with format list(x_orig = num, y_orig = num, size_hor = num, size_vert = num)
* 	x_low and y_low are the x and y coordinates of the bottom left corner of the zone
* 	x_high and y_high are the x and y coordinates of the top right corner of the zone
*
* alias: string, key for the hud zone, used like this: src.hud_zones["[alias]"]
*
* horizontal_edge: what horizontal side of the hud zone are new elements added from? can be EAST or WEST
*	for example, if its EAST then the first element is added at the right edge of the zone
*	the second element is added to the left side of the first element
* 	the third element is added to the left side of the second element, etc.
*
* vertical_edge: what vertical side of the hud zone are new elements added from? can be NORTH or SOUTH
*	for example, if its NORTH then the first element is added at the top edge of the zone
*	the second element is added to the bottom side of the first element
* 	the third element is added to the bottom side of the second element, etc.
**/

/*so we need
-zone priority
-preferred edge (like, the pod HUD should move abilities a row downward but not to the right)
-spacing between elements
-standard offsets (central bars etc)
-specifying relations to other zones if they exist?

-hiding HUD zones
-moving zones en bloc
-manually populating a zone (whole or in part?)
-spacers
*/

/datum/hud/proc/add_hud_zone(alias, priority, x_orig, y_orig, size_hor, size_vert, padding_x = 0, padding_y = 0, primary_dir = EAST, secondary_dir = SOUTH, list/starting_elements = null, element_size = 32)

	if (!alias || !priority || !x_orig || !y_orig || !size_hor || !size_vert || !primary_dir || !secondary_dir)
		boutput(world, "<b>hud zone missing a parameter</b>")
		return

	/*if (abs(turn(primary_dir, secondary_dir)) != 90 || !(primary_dir in cardinal))
		boutput(world, "<b>hud zone has borked directions</b>")
		return*/


	if (!src.hud_zones)
		hud_zones = list()

	//calc total volume of rectangle
	var/size = /*(size_hor == "unlimited" || size_vert == "unlimited") ? -1 : */(size_hor*size_vert)

	//screen_loc style coordinates tend to be in a flavour of "NORTH+5" or whatever. This part splits that in text and number parts.
	//as for why I take the X and Y components as separate arguments instead of just a screen_loc,
	//it's because in the "EDGE+N,EDGE+N" format you can supply X and Y in either order, and I don't want to have to deal with that.
	var/regex/Rx = regex("(EAST|CENTER|WEST)")
	var/regex/Ry = regex("(NORTH|CENTER|SOUTH)")
	var/x_prefix
	var/y_prefix

	Rx.Find(x_orig)
	if (Rx.match)
		x_prefix = Rx.group[1]
		x_orig = copytext(x_orig, length(x_prefix)+1)
		if (!length(x_orig))
			x_orig = "+0"
	else
		x_orig = text2num(x_orig) //to be safe
		//screen_loc string building later on requires a leading + or -
		if (copytext(x_orig,1,2) != "-")
			x_orig = "+[x_orig]"

	Ry.Find(y_orig)
	if (Ry.match)
		y_prefix = Ry.group[1]
		y_orig = copytext(y_orig, length(y_prefix)+1)
		if (!length(y_orig))
			y_orig = "+0"
	else
		y_orig = text2num(y_orig) //to be safe
		if (copytext(y_orig,1,2) != "-")
			y_orig = "+[y_orig]"

	//determine the signs of which way the zone expands, so that hopefully we don't have to give a shit about this anywhere else.
	//(Note that the function of primary_dir and secondary_dir changes after this bit
	// x_in_zone and y_in_zone are fields in the element list, so some slight-of-hand is employed here to make calc_positions direction-agnostic)
	var/x_internal_dir
	var/y_internal_dir
	var/internal_limit
	var/primary_bound
	var/secondary_bound
	switch(primary_dir)
		if(NORTH)
			x_internal_dir = (secondary_dir == EAST) ? "+" : "-"
			y_internal_dir = "+"
			primary_dir = "y_in_zone"
			secondary_dir = "x_in_zone"
			internal_limit = "size_vert"
			primary_bound = "bounding_y"
			secondary_bound = "bounding_x"
		if(SOUTH)
			x_internal_dir = (secondary_dir == EAST) ? "+" : "-"
			y_internal_dir = "-"
			primary_dir = "y_in_zone"
			secondary_dir = "x_in_zone"
			internal_limit = "size_vert"
			primary_bound = "bounding_y"
			secondary_bound = "bounding_x"
		if(EAST)
			x_internal_dir = "+"
			y_internal_dir = (secondary_dir == NORTH) ? "+" : "-"
			primary_dir = "x_in_zone"
			secondary_dir = "y_in_zone"
			internal_limit = "size_hor"
			primary_bound = "bounding_x"
			secondary_bound = "bounding_y"
		if(WEST)
			x_internal_dir = "-"
			y_internal_dir = (secondary_dir == NORTH) ? "+" : "-"
			primary_dir = "x_in_zone"
			secondary_dir = "y_in_zone"
			internal_limit = "size_hor"
			primary_bound = "bounding_x"
			secondary_bound = "bounding_y"

	//
	/*var/x_current = x_orig
	var/y_current = y_orig
	for(var/other_zone in hud_zones)
		if ()*/


	/*"zone_alias" = alias,\ 				//for error messages I guess?
		"x_prefix" = x_prefix,\ 			//"EAST" or "WEST" part of the origin X position
		"y_prefix" = y_prefix,\ 			//"NORTH" or "SOUTH" part of the origin Y position
		"x_orig" = x_orig,\ 				//numerical part of the origin X position
		"y_orig" = y_orig,\ 				//numerical part of the origin Y position
		"elements" = list(),\ 				//HUD objects or groups by alias and their positions in the.
		"groups" = list(),\					//HUD objects that are in groups, per group alias
		"size_hor" = size_hor,\ 			//size on X-axis
		"size_vert" = size_vert,\ 			//size on Y-axis
		"size" = size,\ 					//total size in icons or whatever
		"padding_x" = padding_x,\ 			//padding between elements in px
		"padding_y" = padding_y,\ 			//padding between elements in px
		"element_size" = element_size,\ 	//pixel size of the assets
		"primary_dir" = primary_dir,\		//
		"secondary_dir" = secondary_dir,\
		"priority" = priority,\
		"bounding_x" = 0,\
		"bounding_y" = 0,\
		"primary_bound" = primary_bound,\
		"secondary_bound" = secondary_bound,\
		"x_internal_dir" = x_internal_dir,\
		"x_internal_dir" = y_internal_dir,\
		"internal_limit" = internal_limit)*/

	//I know for a fact that we don't use all of this crap again later on, but it's easier for me to not worry about pruning this right now.
	//(plus who knows what fucked up nonsense someone else may want to do with HUD code :P)
	src.hud_zones[alias] = list(\
		"zone_alias" = alias,\
		"x_prefix" = x_prefix,\
		"y_prefix" = y_prefix,\
		"x_orig" = x_orig,\
		"y_orig" = y_orig,\
		"x_cur" = x_orig,\
		"y_cur" = y_orig,\
		"elements" = list(),\
		"groups" = list(),\
		"size_hor" = size_hor,\
		"size_vert" = size_vert,\
		"size" = size,\
		"padding_x" = padding_x,\
		"padding_y" = padding_y,\
		"element_size" = element_size,\
		"primary_dir" = primary_dir,\
		"secondary_dir" = secondary_dir,\
		"priority" = priority,\
		"bounding_x" = 0,\
		"bounding_y" = 0,\
		"primary_bound" = primary_bound,\
		"secondary_bound" = secondary_bound,\
		"x_internal_dir" = x_internal_dir,\
		"y_internal_dir" = y_internal_dir,\
		"internal_limit" = internal_limit)

	var/da_zone = hud_zones[alias]

	if (length(starting_elements))
		for (var/tag as anything in starting_elements)
			if (islist(tag))
				register_element(da_zone, tag, tag[2], FALSE)
			else
				register_element(da_zone, starting_elements[tag], tag, FALSE)
	display_zone(da_zone)
	return da_zone

/// removes a hud zone and deletes all elements inside of it
/datum/hud/proc/remove_hud_zone(var/list/zone)
	if (!islist(zone))
		zone = hud_zones[zone]
	// remove elements
	var/list/elements = zone["elements"]
	for (var/element_alias in elements)
		var/atom/movable/screen/hud/to_delete = elements[element_alias]
		elements.Remove(to_delete)
		qdel(to_delete)

	src.hud_zones.Remove(zone)

/// adds a hud element (which will be associated with elem_alias) to the elements list of the hud zone associated with zone_alias.
//TODO - turn this from atom to /atom/movable/screen/hud, but for now we must deal with some hud stuff being objects
/datum/hud/proc/register_element(var/list/zone, var/atom/movable/element, var/elem_alias, defer_shift = FALSE)
	if (!zone || !element)
		return
	if (!islist(zone))
		zone = hud_zones[zone]
	if (/*zone[size] != -1 && */(length(zone["elements"]) >= zone["size"])) // if the amount of hud elements in the zone is greater than its max
		CRASH("Couldn't add element [elem_alias] to zone [zone["alias"]] because [zone["alias"]] was full.")
	var/group = null
	if (islist(element))
		group = element[2]
		element = element[1]
	else if (!elem_alias) //you don't need an alias if you're part of a group but otherwise piss off
		return

	var/list/stuff = calc_positions(zone, element, group)
	if (!stuff) //element was added to an existing group
		return
	zone["elements"][elem_alias] = stuff.Copy(1,4) // adds element to internal list

	var/old_secondary = stuff[zone["secondary_dir"]]
	zone[zone["primary_bound"]] = max(zone[zone["primary_bound"]], stuff["p_bound"])
	if (stuff["s_bound"] > zone[zone["secondary_bound"]])
		zone[zone["secondary_bound"]] = stuff["s_bound"]
		if (!defer_shift)
			var/difference = zone[zone["secondary_bound"]] - old_secondary
			for(var/list/other_zone in hud_zones)
				if (other_zone == zone)
					continue
				if (other_zone["priority"] >= zone["priority"])
					continue
				calc_zone_offset(other_zone, zone["secondary_bound"], difference, FALSE)
				display_zone(other_zone)


	//src.adjust_offset(hud_zone, element) // sets it correctly (and automatically) on screen


//Calculate where an element should go in the zone (or sort em into the right group)
/datum/hud/proc/calc_positions(var/zone, var/atom/movable/element, group, reposition = FALSE, new_pos = 0)
	if (!islist(zone))
		zone = hud_zones[zone]
	var/list/guff = list("element" = element, "x_in_zone", "y_in_zone", "p_bound" = 0, "s_bound" = 0)

	if (group)
		if (group in zone["groups"]) //shouldn't happen when repositioning groups
			zone["groups"][group] += element
			return FALSE
		else
			guff["element"] = group //calc position for the entire group instead
			if (!reposition)
				zone["groups"][group] = list(element)

	var/position = reposition ? new_pos : length(zone["elements"]) //append to end if new

	guff[zone["primary_dir"]] = /*(zone["size_x"] == "unlimited") ? zone["elements"] + 1 : */(position % zone[zone["internal_limit"]]) * (zone["element_size"]/32)
	guff[zone["secondary_dir"]] = /*(zone["size_x"] == "unlimited") ? 1 : */(round(position / zone[zone["internal_limit"]])) * (zone["element_size"]/32)
	guff["p_bound"] = guff[zone["primary_dir"]]
	guff["s_bound"] = guff[zone["secondary_dir"]]

	//These padding bits look kinda nasty but the gist is it's separating out whole element widths and just padding with the remainder (40px padding should become +1:8)
	if (guff["x_in_zone"] > 1 && zone["padding_x"])
		var/topad = zone["padding_x"] * (guff["x_in_zone"] - 1) //pixels
		guff["x_in_zone"] += round(topad / zone["element_size"])
		topad = topad % zone["element_size"]
		guff["x_in_zone"] = "[guff["x_in_zone"]]:[zone["x_internal_dir"]][topad]"
	if (guff["y_in_zone"] > 1 && zone["padding_y"])
		var/topad = zone["padding_y"] * (guff["y_in_zone"] - 1)
		guff["y_in_zone"] += round(topad / zone["element_size"])
		topad = topad % zone["element_size"]
		guff["y_in_zone"] = "[guff["y_in_zone"]]:[zone["y_internal_dir"]][topad]"

	return guff//list("element" = element, "x_in_zone" = x_in_zone, "y_in_zone" = y_in_zone)

/datum/hud/proc/calc_zone_offset(var/list/zone, var/direction, var/offset, var/absolute = FALSE)
	if (!islist(zone)) //IDK how you'd make a sensible to this without having the zone
		return
	var/temp
	switch(direction)
		if("bounding_x")
			temp = "[text2num(absolute ? zone["x_orig"] : zone["x_cur"]) + offset]"
			if (copytext(temp,1,2) != "-")
				temp = "+[temp]"
			zone["x_cur"] = temp
		if("bounding_y")
			temp = "[text2num(absolute ? zone["y_orig"] : zone["y_cur"]) + offset]"
			if (copytext(temp,1,2) != "-")
				temp = "+[temp]"
			zone["y_cur"] = temp


/datum/hud/proc/display_zone(var/list/zone)
	if (!islist(zone))
		zone = hud_zones[zone]
	for(var/element_alias in zone["elements"])
		var/list/shit = zone["elements"][element_alias]
		/*
		For these screen_loc statements:
		zone["(x/y)_prefix"]		- NORTH/SOUTH/EAST/WEST
		zone["(x/y)_cur"]			- +n or -n, the current origin coordinates of the zone including possible offsets cause by higher priority zones
		zone["(x/y)_internal_dir"]	- + or -, changes the sign of the element coords so they populate in whatever direction is configured
		shit["(x/y)_in_zone"]		- offsets of the element within the zone
		*/
		if (shit["element"] in zone["groups"])//a group (or, a stack of hud elements)
			var/group = zone["groups"][shit["element"]]
			for(var/atom/movable/a_element as anything in group) //everything gets slapped in the same location
				a_element.screen_loc = "[zone["x_prefix"]][zone["x_cur"]][zone["x_internal_dir"]][shit["x_in_zone"]],[zone["y_prefix"]][zone["y_cur"]][zone["y_internal_dir"]][shit["y_in_zone"]]"
				for (var/client/C in src.clients)
					C.screen += a_element
		else//loose elements
			var/atom/movable/a_element = shit["element"]
			if (a_element == "spacer")
				continue
			a_element.screen_loc = "[zone["x_prefix"]][zone["x_cur"]][zone["x_internal_dir"]][shit["x_in_zone"]],[zone["y_prefix"]][zone["y_cur"]][zone["y_internal_dir"]][shit["y_in_zone"]]"
			for (var/client/C in src.clients)
				C.screen += a_element

/// removes hud element "element_alias" from the hud zone "zone" and deletes it, then readjusts offsets
/datum/hud/proc/unregister_element(var/list/zone, var/element_alias)
	if (!islist(zone))
		zone = hud_zones[zone]
	var/list/elements = zone["elements"]
	var/atom/to_remove
	//It's probably pretty common to have the atom but not the alias, so a bit of switching around
	if (istype(element_alias, /atom/movable))
		to_remove = element_alias
		for (var/key in elements)
			if (elements[key]["element"] == to_remove)
				element_alias = key
				break
	else
		to_remove = elements[element_alias]
	if (!to_remove)
		return

	var/update_index = elements.Find(element_alias)
	if (to_remove in zone["groups"])
		var/list/group = zone["groups"][to_remove]
		for (var/atom/movable/part as anything in group)
			qdel(part)
	else
		qdel(to_remove)
	elements.Remove(element_alias)

	while (update_index <= length(zone["elements"]))
		element_alias = elements[update_index]
		var/atom/thing = elements[element_alias]["element"]
		if (istype(thing))
			elements[element_alias] = calc_positions(zone, thing, null, TRUE, update_index - 1) //the position calculation adds 1, so we have to compensate
		else
			elements[element_alias] = calc_positions(zone, null, thing, TRUE, update_index - 1)
		update_index++

	display_zone(zone)

/*
/// debug purposes only, call this to print ALL of the information you could ever need
/datum/hud/proc/debug_print_all()
	if (!length(src.hud_zones))
		boutput(world, "no hud zones, aborting")
		return

	boutput(world, "-------------------------------------------")

	for (var/zone_index in 1 to length(src.hud_zones))
		var/zone_alias = src.hud_zones[zone_index]
		var/list/hud_zone = src.hud_zones["[zone_alias]"]
		boutput(world, "ZONE [zone_index] alias: [zone_alias]")

		var/list/coords = hud_zone["coords"]
		boutput(world, "ZONE [zone_index] bottom left corner coordinates: ([coords["x_low"]], [coords["y_low"]])")
		boutput(world, "ZONE [zone_index] top right corner coordinates: ([coords["x_high"]], [coords["y_high"]])")

		boutput(world, "ZONE [zone_index] horizontal edge: [hud_zone["horizontal_edge"]]")
		boutput(world, "ZONE [zone_index] vertical edge: [hud_zone["vertical_edge"]]")

		boutput(world, "ZONE [zone_index] current horizontal offset: [hud_zone["horizontal_offset"]]")
		boutput(world, "ZONE [zone_index] current vertical offset: [hud_zone["vertical_offset"]]")

		var/list/elements = hud_zone["elements"]

		if (!length(elements))
			boutput(world, "ZONE [zone_index] has no elements")
			continue

		for (var/element_index in 1 to length(elements))
			var/element_alias = elements[element_index]
			var/atom/movable/screen/hud/element = elements[element_alias]
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] alias: [element_alias]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] icon_state: [element.icon_state]")
			boutput(world, "ZONE [zone_index] ELEMENT [element_index] screenloc: [element.screen_loc]")

	boutput(world, "-------------------------------------------")
*/
