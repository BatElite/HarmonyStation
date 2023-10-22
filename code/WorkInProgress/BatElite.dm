/*
TODO

Make blood/decomp sprites respect missing limbs (or at least the heads, maybe arms are fine)

Figure out a better way to do the surgery branching (on torso?), then start reworking surgery

Swimming:
	-movement modifiers still apply the same, even for things like mechboots
	-linked_hole doesn't really ever get updated if the hole being linked is patched up, do you can swim up through floors :V
	-is it possible to have the verbs unhyphenated?

/area/martian_trader is just 4 turfs between oshan/Z5, what's up with that

Pod weapons:

-Class A phaser (base type)
-UFO
-Artillery (grenade launcher)
-Mining phaser
-Mining laser
-Mining Drills
-Disruptor
-Heavy disruptor
-Construction/Foam
-Shotgun
-Scout laser
	-Short pod wars version
-Assault laser
-Light phaser
	-Short pod wars version
-Iridium thingy (seems unfinished, or for an azone pod)
-Strelka thing
-Syndie purge system
-Pod taser


Pod secondary systems:

-UFO
-Cargo hold (sproted)
	-small one
-Ore scoop (sproted)
-Cloaking device
	Makes the whole thing invisible, but I think would be nicer as a counterpart to the handheld cloaker
-SEED
	Practically broken
-GPS (obsolete, don't bother)
-Repair/Construction device
	Basically a shitty RCD, might be worth just slapping an RCD item into this and turning into a passthrough
-Syndie rewind system (mothballed, probably has a sprot already)
-tractor beam
	This thing is pretty damn slow

Pod...tertiary systems?

-Lock (sproted)
	-Pod wars one (probably won't bother with a separate sprite, might not even be able to be taken out of the pods)
-Tires (sproted, actually pretty nice but huge)
-Tracks

(these sprites aren't something I'm terribly happy with but )

*/

///Hell vending machine that stocks itself with every single valid ingredient it finds in the oven recipe list, so you don't have to procure them.
obj/machinery/vending/kitchen/oven_debug //Good luck finding them though
	name = "cornucopia of ingredience"
	desc = "Everything you could ever need, in abundance."
	req_access_txt = null
	color = "#CCFFCC"

	create_products()
		//Fun fact this proc doesn't need to call parent, which is why I can have it be a subtype of the kitchen vendor
		build_oven_recipes()
		var/list/all_ingredients_ever = list()
		for(var/datum/cookingrecipe/recipe as anything in oven_recipes)
			if (recipe.item1)
				if(IS_ABSTRACT(recipe.item1))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item1, cache = FALSE)) //Get something that'll qualify just in case
				else
					all_ingredients_ever |= recipe.item1
			if (recipe.item2)
				if(IS_ABSTRACT(recipe.item2))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item2, cache = FALSE))
				else
					all_ingredients_ever |= recipe.item2
			if (recipe.item3)
				if(IS_ABSTRACT(recipe.item3))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item3, cache = FALSE))
				else
					all_ingredients_ever |= recipe.item3
			if (recipe.item4)
				if(IS_ABSTRACT(recipe.item4))
					all_ingredients_ever |= pick(concrete_typesof(recipe.item4, cache = FALSE))
				else
					all_ingredients_ever |= recipe.item4
		for(var/type in all_ingredients_ever)
			product_list += new/datum/data/vending_product(type, 50)

//When uncommented, these two together should produce an undecidability crash in insert_recipe
/*
/datum/cookingrecipe/undecidable_A
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	item2 = /obj/item/reagent_containers/food/snacks/breadslice/
/datum/cookingrecipe/undecidable_B
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item2 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
*/
