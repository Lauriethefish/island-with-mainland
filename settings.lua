-- THESE ARE FOR THE DEPRECATED, OLD GENERATOR THAT DOES NOT WORK ON MAP VIEW
-- THESE ARE NO LONGER USED EXCEPT ON OLD MAPS THAT USE THE OLD GENERATOR

data:extend({
    {
        type = "bool-setting",
        name = "enable-island-with-mainland",
        setting_type = "runtime-global",
        default_value = false -- Now deprecated and disabled by default
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