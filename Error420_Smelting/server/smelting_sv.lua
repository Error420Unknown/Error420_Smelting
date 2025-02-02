local QBCore = exports.qbx_core
local smeltingTimers = {}

local DiscordWebhook = "https://discord.com/api/webhooks/1335515567234486304/vw73ZfnlnbGqu4BGzMV45FA-hTZ9TXj9xDx4j0PpNeC2xpHFl2jvODNzpr9fb3zztX72"

local function SendDiscordLog(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color,
            ["footer"] = { ["text"] = os.date("%Y-%m-%d %H:%M:%S") }
        }
    }

    PerformHttpRequest(DiscordWebhook, function(err, text, headers) end, "POST",
    json.encode({username = "AntiCheat Logs", embeds = embed}),
    { ["Content-Type"] = "application/json" })
end

RegisterNetEvent('Error420_Smelting:attemptSmelt', function(item, batchSize)
    local src = source
    local recipe = Config.Recipes[item]
    if not recipe then return end

    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local nearFurnace = false

    for _, furnace in pairs(Config.Furnaces) do
        if #(playerCoords - furnace.coords) < 2.0 then
            nearFurnace = true
            break
        end
    end

    if not nearFurnace then
        SendDiscordLog("🚨 Cheat Alert!", "**Player:** " .. GetPlayerName(src) .. " (" .. src .. ")\n**Reason:** Attempted smelting far from furnace.", 16711680)
        DropPlayer(src, "Kicked for attempting to exploit smelting.")
        return
    end

    batchSize = tonumber(batchSize) or 1
    if batchSize < 1 or batchSize > Config.MaxBatch then
        SendDiscordLog("⚠️ Exploit Attempt!", "**Player:** " .. GetPlayerName(src) .. " (" .. src .. ")\n**Reason:** Sent invalid batch size.", 16753920)
        return
    end

    for _, input in pairs(recipe.Inputs) do
        local requiredAmount = input.amount * batchSize
        local itemData = exports.ox_inventory:GetItem(src, input.item)

        if not itemData or (itemData.count or 0) < requiredAmount then
            TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = Config.MenuLabels.NotEnoughMessage:format(input.label, batchSize)})
            return
        end
    end

    for _, input in pairs(recipe.Inputs) do
        exports.ox_inventory:RemoveItem(src, input.item, input.amount * batchSize)
    end

    smeltingTimers[src] = os.time() + (recipe.Time * batchSize) / 1000

    TriggerClientEvent('Error420_Smelting:playAnimation', src, recipe.Time * batchSize, item, batchSize)
end)

RegisterNetEvent('Error420_Smelting:completeSmelting', function(item, batchSize)
    local src = source
    local recipe = Config.Recipes[item]
    if not recipe then return end

    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local nearFurnace = false

    for _, furnace in pairs(Config.Furnaces) do
        if #(playerCoords - furnace.coords) < 2.0 then
            nearFurnace = true
            break
        end
    end

    if not nearFurnace then
        SendDiscordLog("🚨 Cheat Alert!", "**Player:** " .. GetPlayerName(src) .. " (" .. src .. ")\n**Reason:** Attempted completing smelting far from furnace.", 16711680)
        DropPlayer(src, "Kicked for attempting to exploit smelting.")
        return
    end

    if smeltingTimers[src] and os.time() < smeltingTimers[src] then
        SendDiscordLog("⚠️ Speed Hack Alert!", "**Player:** " .. GetPlayerName(src) .. " (" .. src .. ")\n**Reason:** Tried completing smelting too fast!", 16711680)
        DropPlayer(src, "Kicked for using speed hacks to complete smelting.")
        return
    end

    local totalAmount = recipe.Result.amount * batchSize
    exports.ox_inventory:AddItem(src, recipe.Result.item, totalAmount)

    TriggerClientEvent('ox_lib:notify', src, {type = 'success', description = Config.MenuLabels.SuccessMessage:format(totalAmount, recipe.Result.label)})

    smeltingTimers[src] = nil
end)

RegisterNetEvent('Error420_Smelting:refundMaterials', function(item, batchSize)
    local src = source
    local recipe = Config.Recipes[item]
    if not recipe then return end

    for _, input in pairs(recipe.Inputs) do
        exports.ox_inventory:AddItem(src, input.item, input.amount * batchSize)
    end
    TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = Config.MenuLabels.CancelMessage})

    smeltingTimers[src] = nil
end)