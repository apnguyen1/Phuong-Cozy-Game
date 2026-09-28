-- UI-safe Q06 descriptor. Client code renders this; it never grants progress.
return {
	activityId = "Q06",
	title = "Something Delicious",
	menuStatus = "Proposed venue-inspired bowl and plate assembly",
	anchors = { "Q06FOBCounter", "Q06AladdinsCounter", "Q06Serving" },
	roles = {
		{ id = "base", label = "Choose a base", items = { "rice" } },
		{ id = "toppings", label = "Add fresh toppings", items = { "greens", "cucumber", "carrot" } },
		{ id = "protein", label = "Add a warm topping", items = { "tofu", "chicken", "mushroom" } },
		{ id = "sauce", label = "Finish the plate", items = { "sauce", "sesame" } },
		{ id = "settingA", label = "Set a plate", items = { "plate", "napkin" } },
		{ id = "settingB", label = "Set a cup", items = { "cup", "napkin" } },
	},
	input = { sequence = { "tap-item", "tap-slot", "tap-confirm" }, cancel = "tap-cancel", desktopEquivalent = true, minTargetScreenUnits = 48 },
	feedback = { accepted = "Added to the shared birthday spread", busy = "Someone else is using that spot", complete = "Spread ready" },
}
