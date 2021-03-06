/obj/item/papercutter
	name = "paper cutter"
	desc = "Standard office equipment. Precisely cuts paper using a large blade."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papercutter"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/paper/storedpaper = null
	var/obj/item/hatchet/cutterblade/storedcutter = null
	var/cuttersecured = TRUE
	pass_flags = PASSTABLE


/obj/item/papercutter/Initialize()
	. = ..()
	storedcutter = new /obj/item/hatchet/cutterblade(src)
	update_icon()

/obj/item/papercutter/update_icon()
	..()
	cut_overlays()
	icon_state = (storedcutter ? "[initial(icon_state)]-cutter" : "[initial(icon_state)]")
	if(storedpaper)
		add_overlay("paper")


/obj/item/papercutter/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper) && !storedpaper)
		if(!user.drop_item())
			return
		playsound(loc, "pageturn", 60, 1)
		to_chat(user, "<span class='notice'>You place [P] in [src].</span>")
		P.loc = src
		storedpaper = P
		update_icon()
		return
	if(istype(P, /obj/item/hatchet/cutterblade) && !storedcutter)
		if(!user.drop_item())
			return
		to_chat(user, "<span class='notice'>You replace [src]'s [P].</span>")
		P.loc = src
		storedcutter = P
		update_icon()
		return
	if(istype(P, /obj/item/screwdriver) && storedcutter)
		playsound(src, P.usesound, 50, 1)
		to_chat(user, "<span class='notice'>[storedcutter] has been [cuttersecured ? "unsecured" : "secured"].</span>")
		cuttersecured = !cuttersecured
		return
	..()


/obj/item/papercutter/attack_hand(mob/user)
	add_fingerprint(user)
	if(!storedcutter)
		to_chat(user, "<span class='notice'>The cutting blade is gone! You can't use [src] now.</span>")
		return

	if(!cuttersecured)
		to_chat(user, "<span class='notice'>You remove [src]'s [storedcutter].</span>")
		user.put_in_hands(storedcutter)
		storedcutter = null
		update_icon()

	if(storedpaper)
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You neatly cut [storedpaper].</span>")
		storedpaper = null
		qdel(storedpaper)
		new /obj/item/paperslip(get_turf(src))
		new /obj/item/paperslip(get_turf(src))
		update_icon()


/obj/item/papercutter/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(M.incapacitated() || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)
	add_fingerprint(M)


/obj/item/paperslip
	name = "paper slip"
	desc = "A little slip of paper left over after a larger piece was cut. Whoa."
	icon_state = "paperslip"
	icon = 'icons/obj/bureaucracy.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 50

/obj/item/paperslip/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


/obj/item/hatchet/cutterblade
	name = "paper cutter"
	desc = "The blade of a paper cutter. Most likely removed for polishing or sharpening."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "cutterblade"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
