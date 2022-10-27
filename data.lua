local noise = require("noise")

local islandSize = noise.to_noise_expression(-0.0475);

-- Set the bias for the centre of the island to be land
local bias = {
    type = "function-application",
    function_name = "divide",
    arguments = {
        noise.to_noise_expression(10),
        noise.var("control-setting:island-size:frequency:multiplier"),
    }
}

-- Calculate/scale the distance before the mainland starts
local distanceBeforeMainland = {
    type = "function-application",
    function_name = "multiply",
    arguments = {
        noise.var("control-setting:island-size:size:multiplier"),
        noise.to_noise_expression(800)
    }
}

-- Calculate the distance to spawn
local distanceToSpawn = {
    type = "function-application",
    function_name = "distance-from-nearest-point",
    arguments = {
        x = noise.var("x"),
        y = noise.var("y"),
        points = noise.make_point_list({{0, 0}})
    }
}


data:extend{
    -- The noise expression for our island with a mainland
    {
        type = "noise-expression",
        name = "island-with-mainland",
        intended_property = "elevation",
        expression = {
            type = "function-application",
            function_name = "add",
            arguments = {
                data.raw["noise-expression"]["0_16-elevation"].expression, -- Base the elevation upon the default map generator
                noise.min(
                    0.0, -- Avoid adding to elevation, so that water still shows up in our spawn area
                    {
                        type = "function-application",
                        function_name = "add",
                        arguments = {
                            {
                                type = "function-application",
                                function_name = "multiply",
                                arguments = {
                                    islandSize, -- Multiply by the distance scale factor
                                    {
                                        type = "if-else-chain",
                                        arguments = {
                                            -- If we haven't reached the distance away from spawn at which the mainland should appear
                                            {
                                                type = "function-application",
                                                function_name = "less-or-equal",
                                                arguments = { 
                                                    distanceToSpawn,
                                                    distanceBeforeMainland
                                                }
                                            },
                                            -- Scale by our distance to spawn
                                            distanceToSpawn,

                                            -- Otherwise, we will apply another function to cause the distance to spawn to quickly decrease, causing land to again spawn
                                            {
                                                type = "function-application",
                                                function_name = "subtract",
                                                arguments = {
                                                    {
                                                        type = "function-application",
                                                        function_name = "multiply",
                                                        arguments = {
                                                            distanceBeforeMainland,
                                                            noise.to_noise_expression(3)
                                                        }
                                                    },
                                                    {
                                                        type = "function-application",
                                                        function_name = "multiply",
                                                        arguments = {
                                                            distanceToSpawn,
                                                            noise.to_noise_expression(2)
                                                        }
                                                    },
                                                }
                                            },
                                        }
                                    }
                                }
                            },
                            bias -- Add our bias, so that the middle of the island is always land
                        }
                    }
                )
            } 
        }
    },
    
    -- Add a setting to control the island size and water-gap
    -- TODO: This setting shows even if the "Island with mainland" elevation isn't enabled
    -- I couldn't find how to change this - perhaps it is not exposed to mods?
    {
        type = "autoplace-control",
        can_be_disabled = false,
        richness = false,
        name = "island-size",
        category = "terrain"
    }
}