local QBCore = exports.qbx_core

CreateThread(function()
    for _, furnace in pairs(Config.Furnaces) do
        exports.ox_target:addBoxZone({
            coords = furnace.coords,
            size = vec3(1, 1, 2),
            rotation = 0,
            debug = false,
            options = {
                {
                    name = 'smelt',
                    event = 'Error420_Smelting:startSmelting',
                    icon = 'fa-solid fa-fire',
                    label = 'Use Furnace',
                    canInteract = function(entity, distance, data)
                        return distance < 2.0
                    end
                }
            }
        })
    end
end)

RegisterNetEvent('Error420_Smelting:startSmelting', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearFurnace = false

    for _, furnace in pairs(Config.Furnaces) do
        if #(playerCoords - furnace.coords) < 2.0 then
            nearFurnace = true
            break
        end
    end

    if not nearFurnace then
        exports.qbx_core:Notify('You are too far from the furnace!', 'error')
        return
    end

    local options = {}
    for item, data in pairs(Config.Recipes) do
        local inputText = Config.MenuLabels.DescriptionPrefix

        for _, input in pairs(data.Inputs) do
            inputText = inputText .. input.amount .. "x " .. input.label .. ", "
        end

        inputText = inputText:sub(1, -3)

        table.insert(options, {
            title = Config.MenuLabels.SmeltButton .. " " .. data.Label,
            description = inputText,
            icon = 'fa-solid fa-fire',
            onSelect = function()
                local batchSize = lib.inputDialog(Config.MenuLabels.SelectBatch, {Config.MenuLabels.EnterBatch:format(Config.MaxBatch)})
                if batchSize then
                    batchSize = tonumber(batchSize[1]) or 1
                    if batchSize < 1 then batchSize = 1 end
                    batchSize = math.min(batchSize, Config.MaxBatch)

                    local newCoords = GetEntityCoords(PlayerPedId())
                    for _, furnace in pairs(Config.Furnaces) do
                        if #(newCoords - furnace.coords) < 2.0 then
                            TriggerServerEvent('Error420_Smelting:attemptSmelt', item, batchSize)
                            return
                        end
                    end

                    exports.qbx_core:Notify('You moved too far from the furnace!', 'error')
                end
            end
        })
    end

    lib.registerContext({id = 'smelting_menu', title = Config.MenuLabels.Title, options = options})
    lib.showContext('smelting_menu')
end)

RegisterNetEvent('Error420_Smelting:playAnimation', function(time, item, batchSize)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearFurnace = false

    for _, furnace in pairs(Config.Furnaces) do
        if #(playerCoords - furnace.coords) < 2.0 then
            nearFurnace = true
            break
        end
    end

    if not nearFurnace then
        exports.qbx_core:Notify('You are too far from the furnace!', 'error')
        return
    end

    RequestAnimDict('mini@repair')
    while not HasAnimDictLoaded('mini@repair') do
        Wait(10)
    end

    local blowtorch = CreateObject(`prop_tool_blowtorch`, 0, 0, 0, true, true, false)
    AttachEntityToEntity(blowtorch, playerPed, GetPedBoneIndex(playerPed, 57005), 0.15, 0, 0, 0, 0, 90, true, true, false, true, 1, true)

    TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 1, 0, false, false, false)

    local success = lib.progressBar({
        duration = time,
        label = "Smelting...",
        useWhileDead = false,
        canCancel = true,
        disable = {move = true, car = true, combat = true}
    })

    ClearPedTasks(playerPed)
    DeleteObject(blowtorch)

    if success then
        local finalCoords = GetEntityCoords(PlayerPedId())
        for _, furnace in pairs(Config.Furnaces) do
            if #(finalCoords - furnace.coords) < 2.0 then
                TriggerServerEvent('Error420_Smelting:completeSmelting', item, batchSize)
                return
            end
        end
        exports.qbx_core:Notify('Smelting failed: You moved too far from the furnace!', 'error')
    else
        TriggerServerEvent('Error420_Smelting:refundMaterials', item, batchSize)
        exports.qbx_core:Notify('Smelting cancelled! Materials returned.', 'error')
    end
end)