/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
#ifndef IN_MAP_EDITOR
	icon_state = "intercom"
#else
	icon_state = "intercom-map"
#endif
	anchored = 1.0
	plane = PLANE_NOSHADOW_ABOVE
	mats = 3
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL
	chat_class = RADIOCL_INTERCOM
	var/number = 0
	rand_pos = 0
	desc = "A wall-mounted radio intercom, used to communicate with the specified frequency. Usually turned off except during emergencies."
	hardened = 0
	var/screen_icon_state = "intercom-screen"

/obj/item/device/radio/intercom/proc/update_pixel_offset_dir(obj/item/AM, old_dir, new_dir)
	src.pixel_x = 0
	src.pixel_y = 0
	switch(new_dir)
		if(NORTH)
			src.pixel_y = -21
		if(SOUTH)
			src.pixel_y = 24
		if(EAST)
			src.pixel_x = -21
		if(WEST)
			src.pixel_x = 21

/obj/item/device/radio/intercom/New()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGED, PROC_REF(update_pixel_offset_dir))
	if(src.screen_icon_state) // instead of checking icon state, null screen_icon_state now
		var/image/screen_image = image(src.icon, screen_icon_state)
		screen_image.color = src.device_color
		if(src.device_color == RADIOC_INTERCOM || isnull(src.device_color)) // unboringify the colour if default
			var/new_color = default_frequency_color(src.frequency)
			if(new_color)
				screen_image.color = new_color
		screen_image.alpha = 180
		src.UpdateOverlays(screen_image, "screen")
		if(src.pixel_x == 0 && src.pixel_y == 0)
			update_pixel_offset_dir(src,null,src.dir)

/obj/item/device/radio/intercom/initialize() //this override was on pretty much every child what the fuck
	set_frequency(frequency)

/obj/item/device/radio/intercom/ui_state(mob/user)
	return tgui_default_state

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	SPAWN(0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_hand(mob/user)
	src.add_fingerprint(user)
	SPAWN(0)
		attack_self(user)

/obj/item/device/radio/intercom/send_hear()
	if (src.listening)
		return hearers(7, src.loc)

/obj/item/device/radio/intercom/showMapText(var/mob/target, var/mob/sender, receive, msg, secure, real_name, lang_id, textLoc)
	if (!isAI(sender) || isdead(sender) || (frequency == R_FREQ_DEFAULT))
		..() // we also want the AI to be able to tune to any intercom and have maptext, but not the main radio (1459) because of spam
		return
	var/maptext = generateMapText(msg, textLoc, style = "color:#7F7FE2;", alpha = 255)
	target.show_message(type = 2, just_maptext = TRUE, assoc_maptext = maptext)

/obj/item/device/radio/intercom/putt
	name = "Colosseum Intercommunicator"
	frequency = R_FREQ_INTERCOM_COLOSSEUM
	broadcasting = 1
	device_color = "#aa5c00"
	protected_radio = 1

// -------------------- VR --------------------
/obj/item/device/radio/intercom/virtual
	desc = "Virtual radio for all your beeps and bops."
	icon = 'icons/effects/VR.dmi'
	protected_radio = 1
// --------------------------------------------

//Table flavours
ABSTRACT_TYPE(/obj/item/device/radio/intercom/table)
/obj/item/device/radio/intercom/table
	screen_icon_state = "intercom_table-screen"
	update_pixel_offset_dir(obj/item/AM, old_dir, new_dir)
		return
/obj/item/device/radio/intercom/table/white
	icon_state = "intercom_table-w"
/obj/item/device/radio/intercom/table/black
	icon_state = "intercom_table-b"

// ** preset intercoms to make mapping suck less augh **

//Hey I made most of this one of these defines because why not I'm not making a big list for all the table intercoms
//also lowercased them names
#define ENUMERATE_INTERCOMS(_supertype)\
/obj/item/device/radio/_supertype/medical;\
/obj/item/device/radio/_supertype/medical/name = "medical intercom";\
/obj/item/device/radio/_supertype/medical/frequency = R_FREQ_INTERCOM_MEDICAL;\
/obj/item/device/radio/_supertype/medical/device_color = "#0093FF";\
/obj/item/device/radio/_supertype/security;\
/obj/item/device/radio/_supertype/security/name = "security intercom";\
/obj/item/device/radio/_supertype/security/frequency = R_FREQ_INTERCOM_SECURITY;\
/obj/item/device/radio/_supertype/security/device_color = "#FF2000";\
/obj/item/device/radio/_supertype/brig;\
/obj/item/device/radio/_supertype/brig/name = "brig intercom";\
/obj/item/device/radio/_supertype/brig/frequency = R_FREQ_INTERCOM_BRIG;\
/obj/item/device/radio/_supertype/brig/device_color = "#FF5000";\
/obj/item/device/radio/_supertype/science;\
/obj/item/device/radio/_supertype/science/name = "research intercom";\
/obj/item/device/radio/_supertype/science/frequency = R_FREQ_INTERCOM_RESEARCH;\
/obj/item/device/radio/_supertype/science/device_color = "#C652CE";\
/obj/item/device/radio/_supertype/engineering;\
/obj/item/device/radio/_supertype/engineering/name = "engineering intercom";\
/obj/item/device/radio/_supertype/engineering/frequency = R_FREQ_INTERCOM_ENGINEERING;\
/obj/item/device/radio/_supertype/engineering/device_color = "#BBBB00";\
/obj/item/device/radio/_supertype/cargo;\
/obj/item/device/radio/_supertype/cargo/name = "cargo intercom";\
/obj/item/device/radio/_supertype/cargo/frequency = R_FREQ_INTERCOM_CARGO;\
/obj/item/device/radio/_supertype/cargo/device_color = "#9A8B0D";\
/obj/item/device/radio/_supertype/catering;\
/obj/item/device/radio/_supertype/catering/name = "catering intercom";\
/obj/item/device/radio/_supertype/catering/frequency = R_FREQ_INTERCOM_CATERING;\
/obj/item/device/radio/_supertype/catering/device_color = "#C16082";\
/obj/item/device/radio/_supertype/botany;\
/obj/item/device/radio/_supertype/botany/name = "botany intercom";\
/obj/item/device/radio/_supertype/botany/frequency = R_FREQ_INTERCOM_BOTANY;\
/obj/item/device/radio/_supertype/botany/device_color = "#78ee48";\
/obj/item/device/radio/_supertype/AI;\
/obj/item/device/radio/_supertype/AI/name = "\improper AI intercom";\
/obj/item/device/radio/_supertype/AI/frequency = R_FREQ_INTERCOM_AI;\
/obj/item/device/radio/_supertype/AI/device_color = "#7F7FE2";\
/obj/item/device/radio/_supertype/AI/broadcasting = TRUE;\
/obj/item/device/radio/_supertype/bridge;\
/obj/item/device/radio/_supertype/bridge/name = "bridge intercom";\
/obj/item/device/radio/_supertype/bridge/frequency = R_FREQ_INTERCOM_BRIDGE;\
/obj/item/device/radio/_supertype/bridge/device_color = "#339933";\
/obj/item/device/radio/_supertype/bridge/broadcasting = TRUE;\

ENUMERATE_INTERCOMS(intercom) //wall intercoms
ENUMERATE_INTERCOMS(intercom/table/black)
ENUMERATE_INTERCOMS(intercom/table/white)

#undef ENUMERATE_INTERCOMS

/obj/item/device/radio/intercom/syndicate
	name = "Syndicate Intercom"
	frequency = R_FREQ_SYNDICATE
	broadcasting = TRUE
	device_color = "#820A16"
	hardened = TRUE

	initialize()
		if(istype(ticker.mode, /datum/game_mode/nuclear))
			var/datum/game_mode/nuclear/N = ticker.mode
			if(N.agent_radiofreq)
				set_frequency(N.agent_radiofreq)
		else
			set_frequency(frequency)

////// adventure area intercoms

/obj/item/device/radio/intercom/adventure/owlery
	name = "Owlery Intercom"
	frequency = R_FREQ_INTERCOM_OWLERY
	locked_frequency = TRUE
	broadcasting = 0
	device_color = "#3344AA"

	initialize()
		set_frequency(frequency)

/obj/item/device/radio/intercom/adventure/syndcommand
	name = "Suspicious Intercom"
	frequency = R_FREQ_INTERCOM_SYNDCOMMAND
	locked_frequency = TRUE
	broadcasting = 1
	device_color = "#BB3333"

	initialize()
		set_frequency(frequency)


/obj/item/device/radio/intercom/adventure/wizards
	name = "SWF Intercom"
	frequency = R_FREQ_INTERCOM_WIZARD
	broadcasting = 1
	device_color = "#3333AA"

	initialize()
		set_frequency(frequency)
