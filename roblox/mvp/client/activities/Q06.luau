-- UI-safe Q06 descriptor. Client code renders this; it never grants progress.
return {
	activityId = "Q06",
	title = "Something Delicious",
	menuStatus = "Build a bowl at FOB, add sauce at Aladdins, then set the serving table",
	anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" },
	roles = {
		{ id = "base", label = "Choose a base", items = { "rice" } },
		{ id = "protein", label = "Choose a protein", items = { "tofu", "chicken", "mushroom" } },
		{ id = "toppings", label = "Choose a fresh topping", items = { "greens", "cucumber", "carrot" } },
		{ id = "sauce", label = "Choose a finish", items = { "sauce", "sesame" } },
		{ id = "settingA", label = "Left table setting", items = { "plate", "napkin" } },
		{ id = "settingB", label = "Right table setting", items = { "cup", "napkin" } },
	},
	input = { sequence = { "choose-card", "preview-selection", "add-or-place" }, cancel = "tap-cancel", desktopEquivalent = true, minTargetScreenUnits = 48 },
	feedback = { accepted = "Added to the shared meal", busy = "A friend is choosing for this spot", complete = "Done! Your shared meal is ready" },
}
