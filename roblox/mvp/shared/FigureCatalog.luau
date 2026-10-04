-- Session IDs/probabilities stay in Config. These are palette-constrained toy
-- interpretations, not reference-approved Big into Energy colors or likenesses.
local Config = require(script.Parent.Config)
local Catalog = { Figures = {}, ById = {} }
local styles = {
	{ label = "Love", body = "blossom", accent = "golden", badge = "heart" },
	{ label = "Happiness", body = "golden", accent = "cream", badge = "sun" },
	{ label = "Loyalty", body = "forest", accent = "sage", badge = "pair" },
	{ label = "Serenity", body = "sage", accent = "cream", badge = "moon" },
	{ label = "Hope", body = "cream", accent = "blossom", badge = "bow" },
	{ label = "Luck", body = "wood", accent = "golden", badge = "clover" },
	{ label = "Secret · ID", body = "brick", accent = "ink", badge = "star" },
}
for index, style in ipairs(styles) do
	local entry = {
		id = Config.RegularFigureIds[index] or Config.SecretFigureId,
		label = style.label, body = style.body, accent = style.accent, badge = style.badge,
		secret = index == 7, probability = index == 7 and Config.SecretProbability or Config.RegularProbability,
		odds = index == 7 and "Secret · 1%" or "Regular · 16.5%",
	}
	table.insert(Catalog.Figures, entry); Catalog.ById[entry.id] = entry
end
function Catalog.Label(id) return Catalog.ById[id] and Catalog.ById[id].label or "Choose a figure" end
return Catalog
