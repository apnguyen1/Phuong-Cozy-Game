-- UI-safe descriptor for Q02. Main client owns rendering and input routing.
return {
    activityId = "Q02",
    title = "Jasper's Favorite Things",
    prompts = {
        greet = {desktop = "Interact", touch = "Say hi to Jasper"},
        rabbitFound = {desktop = "Interact", touch = "Inspect basket"},
        rabbitReturned = {desktop = "Interact", touch = "Return rabbit"},
        fetch = {desktop = "Click / Throw", touch = "Throw"},
        greenie = {desktop = "Interact", touch = "Give Greenie"},
        pet = {desktop = "Interact", touch = "Pet Jasper"},
    },
    note = "Throw uses a forgiving lane target; no camera lock or repeated-pet reward.",
}
