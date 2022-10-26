data:extend({
    {
        type = "bool-setting",
        name = "enable-island-with-mainland",
        setting_type = "runtime-global",
        default_value = true -- Perhaps make default_value false?
    },
    {
        type = "double-setting",
        name = "island-scale",
        setting_type = "runtime-global",
        minimum_value = 0.25,
        default_value = 0.75,
        maximum_value = 2,
    },
    {
        type = "int-setting",
        name = "island-water-gap",
        setting_type = "runtime-global",
        minimum_value = 250,
        maximum_value = 1000,
        default_value = 550
    }
})