-- PCW-26. Install this same source under both PhuongMVP.shared roots.
-- These are the selected IDs, not an assertion of permission or audition.
return {
    Music = {
        Birthday = { id = "87992648461099", title = "Birthday song", volume = .22 },
        World = { id = "139568344220252", title = "Slow Mornings · gentle acoustic guitar", volume = .18 },
    },
    Effects = {
        SoftClick = { id = "88442833509532", volume = .18 },
        SuccessChime = { id = "103516326607012", volume = .22 },
        JasperBark = { id = "135016436724006", volume = .25 },
        JasperPant = { id = "6463651038", volume = .10 },
    },
    DefaultMusicVolume = .5,
    VolumeStep = .25,
    CrossfadeSeconds = .65,
    LoadTimeoutSeconds = 8,
    ReceiptLimit = 4096,
}
