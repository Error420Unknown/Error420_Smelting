Config = {}

Config.Furnaces = {
    {coords = vec3(1109.94, -2008.09, 31.06)}, -- Example Furnace Location
}

Config.MenuLabels = {
    Title = "Smelter", -- Title of the smelting menu
    DescriptionPrefix = "Requires: ", -- Prefix before listing required items
    SmeltButton = "Smelt", -- Button label for smelting
    SelectBatch = "Select Batch Size", -- Title for batch selection input
    EnterBatch = "Enter number of batches (Max: %d)", -- Input prompt (formatted)
    CancelMessage = "Smelting cancelled! Materials returned.", -- Cancel notification
    SmeltingMessage = "Smelting...", -- Progress bar label
    SuccessMessage = "You smelted %d x %s", -- Success message (formatted)
    NotEnoughMessage = "Not enough %s for %d batch(es)" -- Not enough materials message (formatted)
}

-- Smelting recipes (Fully customizable)
Config.Recipes = {
    --[[ Exmaple
    ["charcoal"] = {
        Label = "Charcoal", -- Display name for the menu
        Inputs = {
            {item = "bark", amount = 5, label = "Bark"}, -- Required items
            -- Add more if needed
        },
        Result = {item = "charcoal", amount = 1, label = "Charcoal"}, -- Item you receive after smelting
        Time = 5000
    }
    ]]
}

Config.MaxBatch = 10 -- Maximum number of batches a player can smelt at once