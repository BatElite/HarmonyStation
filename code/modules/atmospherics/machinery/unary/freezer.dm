/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "freezer"
	icon = 'icons/obj/machines/Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	anchored = 1.0
	current_heat_capacity = 1000
	mats = list("MET-1" = 8, "CON-1" = 15) //IDK it's something

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	// Medbay and kitchen freezers start at correct temperature to avoid pointless busywork.
	cryo
		name = "freezer (cryo cell)"
		current_temperature = 73.15

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	kitchen
		name = "freezer (kitchen)"
		current_temperature = 150
		on = 1

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	update_icon()

		if(src.node)
			if(src.on)
				icon_state = "freezer_1"
			else
				icon_state = "freezer"
		else
			icon_state = "freezer_0"
		return

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attack_hand(mob/user)
		src.add_dialog(user)
		var/temp_text = ""
		if(air_contents.temperature > (T0C - 20))
			temp_text = "<FONT color=red>[air_contents.temperature - T0C]</FONT>"
		else if(air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
			temp_text = "<FONT color=black>[air_contents.temperature - T0C]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature - T0C]</FONT>"

		var/dat = {"<B>Cryo gas cooling system</B><BR>
		Current status: [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
		Current gas temperature: [temp_text]&deg;C<BR>
		Current air pressure: [MIXTURE_PRESSURE(air_contents)] kPa<BR>
		Target gas temperature: <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> <A href='?src=\ref[src];settemp=1'>[current_temperature - T0C]&deg;C</A> <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A><BR>
		"}

		user.Browse(dat, "window=freezer;size=400x500")
		onclose(user, "freezer")

	Topic(href, href_list)
		if ((usr.contents.Find(src) || ((BOUNDS_DIST(src, usr) == 0) && istype(src.loc, /turf))) || (isAI(usr)))
			src.add_dialog(usr)
			if (href_list["start"])
				src.on = !src.on
				UpdateIcon()
			if(href_list["temp"])
				var/amount = text2num_safe(href_list["temp"])
				if(amount > 0)
					src.current_temperature = min(T20C, src.current_temperature+amount)
				else
					src.current_temperature = max((T0C - 200), src.current_temperature+amount)
			if (href_list["settemp"])
				var/change = input(usr,"Target Temperature (-200 C - 20 C):","Enter target temperature",current_temperature - T0C) as num
				if(!isnum_safe(change)) return
				current_temperature = clamp(change + T0C, 73.15, 293.15)
				src.updateUsrDialog()
				return

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		return

	process()
		..()
		src.updateUsrDialog()
		if(prob(5) && src.on)
			playsound(src.loc, ambience_atmospherics, 30, 1)

	was_built_from_frame(mob/user, newly_built)
		..()
		initialize_directions = dir
		initialize()

	//Having one (1) atmos machine that's done via the ruckingenur system instead of pipe frames is probably a great idea that won't cause bugs
	was_deconstructed_to_frame(mob/user)
		src.on = FALSE
		//All of this is basically unary disposing
		if(node)
			node.disconnect(src)
			if (network)
				network.dispose()

		if(air_contents)
			qdel(air_contents)
			air_contents = null

		node = null
		network = null
		..()
