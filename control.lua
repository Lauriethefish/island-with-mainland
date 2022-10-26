
require("perlin")

local enable_generator = settings.global["enable-island-with-mainland"].value;
local generalScale = 0.005 -- Scale of the lowest frequency noise, for overall island shape
local generalAmp = 5 -- Amplitude of the lowest frequency noise
local scale = 0.03 -- Scale of the middle-frequency noise, for medium sized pieces of detail
local amplitude = 0.75 -- Amplitude of the middle-frequency noise
local roughScale = 0.1 -- Scale of the high-frequency noise, for rough detail on a small scale.
local roughAmplitude = 0.25 -- Amplitude of the high-frequency noise
local distanceScale = -0.03 -- The speed at which distance from spawn causes the island to drop-off, and be replaced by ocean.
local bias = 10.0 -- The value added to the noise to create an island until the drop-off point
local totalScale = settings.global["island-scale"].value -- The overall scale that the X and Y coordinates are multiplied by before putting into any other scales.
local revertDistance = settings.global["island-water-gap"].value -- The distance from spawn at which the distance starts to have the opposite effect, causing the mainland to generate

if enable_generator then
    script.on_event(defines.events.on_chunk_generated,
        function(event)
            local seed = event.surface.map_gen_settings.seed
            local area = event.area
            local tiles = {} -- Tiles that we will replace with water tiles

            -- Loop through the tiles in this chunk
            for rX = area.left_top.x, area.right_bottom.x, 1 do
                for rY = area.left_top.y, area.right_bottom.y, 1 do
                    -- Scale each position by the overall scale
                    local x = rX * totalScale
                    local y = rY * totalScale

                    -- Calculate the distance from spawn, possibly reversing its effect if far enough from spawn
                    local distance = math.sqrt((x ^ 2) + (y ^ 2))
                    if distance > revertDistance then
                        -- Cause the distance to decrease if at least `revertDistance` away
                        distance = (2 * revertDistance) - distance
                    end

                    -- Compute the X and Y coordinates that we will plugin into our noise, making sure to apply the seed
                    local noiseX = x + seed
                    local noiseY = y + seed

                    local noiseValue = perlin:noise(noiseX * generalScale, noiseY * generalScale) * generalAmp
                        + perlin:noise(noiseX * scale, noiseY * scale, 0) * amplitude
                        + perlin:noise(noiseX * roughScale, noiseY * roughScale) * roughAmplitude 
                        + bias
                        + distance * distanceScale

                    local tilePosition = { x = rX, y = rY }
                    if noiseValue < -0.2 then -- If far enough from the island, we will place deep water
                        table.insert(tiles, { position = tilePosition, name = "deepwater" })
                    elseif (noiseValue < 0 and event.surface.get_tile(rX, rY).name ~= "deepwater") then
                        -- Otherwise, we will generate shallow water, but only if the water at the given position is not already deep water.
                        -- As this can lead to random bands of shallow water where our generation interferes with vanilla lake generation
                        table.insert(tiles, { position = tilePosition, name = "water" })
                    end
                end
            end

            -- Update the necessary tiles of the chunk
            event.surface.set_tiles(tiles)
        end
    )
end