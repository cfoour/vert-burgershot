local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}

CreateThread(function()
    for k, v in pairs(Config.Vehicles) do
        lib.requestModel(Config.Vehicles[k].model)
        vehiclePed = CreatePed(3, Config.Vehicles[k].model, v.pedcoords.x, v.pedcoords.y, v.pedcoords.z - 1.0, v.pedcoords.w, false, false)
        FreezeEntityPosition(vehiclePed, true)
        SetEntityInvincible(vehiclePed, true)
        TaskStartScenarioInPlace(vehiclePed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
        exports.ox_target:addLocalEntity(vehiclePed, {
            {
                event = 'vert-burgershot:client:spawnVehicle',
                icon = 'fas fa-car',
                label = 'Spawn Vehicle',
            },
            {
                event = 'vert-burgershot:client:returnVehicle',
                icon = 'fas fa-sign-in-alt',
                label = 'Return Vehicle',
            }
        })
    end
end)

for k, v in pairs(Config.FoodWarmers) do
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vec3(1.4, 1.0, 2.3),
        rotation = v.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'foodwarmers',
                icon = 'fas fa-fire',
                label = 'Open Food Warmer',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', v.name)
                end
            }
        }
    })
end

for k, v in pairs(Config.Counters) do
    exports.ox_target:addSphereZone({
        coords = v.coords,
        radius = v.radius,
        debug = Config.Debug,
        options = {
            {
                name = 'foodtray',
                icon = 'fas fa-box',
                label = 'Open Food Tray',
                distance = 1.5,
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', v.name)
                end
            }
        }
    })
end

for k, v in pairs(Config.Grill) do
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vec3(1.4, 1.0, 1.0),
        rotation = v.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'grill',
                icon = 'fas fa-utensils',
                label = 'Cook Food',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    TriggerEvent('vert-burgershot:client:OpenCookMenu')
                end
            }
        }
    })
end

for k, v in pairs(Config.Fryer) do
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vec3(1.4, 1.0, 1.0),
        rotation = v.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'fryer',
                icon = 'fas fa-utensils',
                label = 'Fry Food',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    TriggerEvent('vert-burgershot:client:OpenFryerMenu')
                end
            }
        }
    })
end

for k, v in pairs(Config.ChoppingStation) do
    exports.ox_target:addSphereZone({
        coords = v.coords,
        radius = v.radius,
        debug = Config.Debug,
        options = {
            {
                name = 'choppingstation',
                icon = 'fas fa-scissors',
                label = 'Slice Food',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    TriggerEvent('vert-burgershot:client:OpenChopMenu')
                end
            }
        }
    })
end

for k, v in pairs(Config.PrepStation) do
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vec3(0.8, 2.0, 1.0),
        rotation = v.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'prepstation',
                icon = 'nui://ox_inventory/web/images/rawonion.png',
                label = 'Prepare Food',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    TriggerEvent('vert-burgershot:client:OpenPrepMenu')
                end
            }
        }
    })
end

for k, v in pairs(Config.IngredientsStore) do
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vec3(2.2, 0.6, 3.0),
        rotation = v.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'ingredients',
                icon = 'fas fa-cart-shopping',
                label = 'Buy Ingredients',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    exports.ox_inventory:openInventory('shop', { type = 'burgershot' })
                end
            }
        }
    })
end

for k, v in pairs(Config.DrinkStations) do
    exports.ox_target:addBoxZone({
        coords = v.coords,
        size = vec3(1.4, 0.4, 1.4),
        rotation = v.heading,
        debug = Config.Debug,
        options = {
            {
                name = 'drinks',
                icon = 'fas fa-mug-hot',
                label = 'Make Drinks',
                distance = 1.5,
                groups = Config.Job,
                onSelect = function()
                    TriggerEvent('vert-burgershot:client:OpenDrinkMenu')
                end
            }
        }
    })
end

RegisterNetEvent('vert-burgershot:client:spawnVehicle', function()
    for k, v in pairs(Config.Vehicles) do
        local model = Config.Vehicles[k].vehicle
        local player = cache.ped
        if IsAnyVehicleNearPoint(v.vehiclecoords.x, v.vehiclecoords.y, v.vehiclecoords.z, 2.0) then
            QBCore.Functions.Notify('There is a vehicle in the way!', 'error', 5000)
            return
        end

        QBCore.Functions.SpawnVehicle(model, function(vehicle)
            SetEntityHeading(vehicle, 340.0)
            TaskWarpPedIntoVehicle(player, vehicle, -1)
            TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
            SetVehicleEngineOn(vehicle, true, true)
            SetEntityHeading(vehicle, v.vehiclecoords.w)
            SetVehicleColours(vehicle, 150)
            exports[Config.Vehicles[k].fuelexport]:SetFuel(vehicle, 100.0)
            SpawnVehicle = true
        end, v.vehiclecoords, true)

        Wait(1000)

        local vehicle = GetVehiclePedIsIn(player, false)
        local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        vehicleLabel = GetLabelText(vehicleLabel)
        local plate = GetVehicleNumberPlateText(vehicle)
        break
    end
end)

RegisterNetEvent('vert-burgershot:client:returnVehicle', function()
    if SpawnVehicle then
        QBCore.Functions.Notify('Vehicle Returned!', 'success')
        local car = GetVehiclePedIsIn(cache.ped, true)
        NetworkFadeOutEntity(car, true, false)
        Wait(2000)
        QBCore.Functions.DeleteVehicle(car)
    else
        QBCore.Functions.Notify('There is no vehicle to return!', 'error', 5000)
    end
    SpawnVehicle = false
end)

RegisterNetEvent('vert-burgershot:client:OpenCookMenu', function()
    lib.registerContext({
        id = 'Cook_Station',
        title = 'Burgershot Cooking Station',
        options = {
            {
                title = 'Cook Beef',
                icon = 'nui://ox_inventory/web/images/groundbeef.png',
                event = 'vert-burgershot:client:StartGrill',
                args = {
                    Item = 'groundbeef',
                }
            },
            {
                title = 'Cook Bacon',
                icon = 'nui://ox_inventory/web/images/rawbacon.png',
                event = 'vert-burgershot:client:StartGrill',
                args = {
                    Item = 'rawbacon',
                }
            },
        }
    })
    lib.showContext('Cook_Station')
end)

RegisterNetEvent('vert-burgershot:client:OpenFryerMenu', function()
    lib.registerContext({
        id = 'Frying_Station',
        title = 'Burgershot Frying Station',
        options = {
            {
                title = 'Fry Chicken',
                description = 'Requires:  \n - 1x Ground Chicken,  \n - 1x Breadcrumbs,  \n - 1x Salt',
                icon = 'nui://ox_inventory/web/images/burger_shotnuggets.png',
                event = 'vert-burgershot:client:StartFryer',
                args = {
                    Item = 'burger_shotnuggets',
                }
            },
            {
                title = 'Fry Potatoes',
                description = 'Requires:  \n - 1x Sliced Potato,  \n - 1x Salt',
                icon = 'nui://ox_inventory/web/images/burger_fries.png',
                event = 'vert-burgershot:client:StartFryer',
                args = {
                    Item = 'burger_fries',
                }
            },
            {
                title = 'Fry Onions',
                description = 'Requires:  \n - 1x Sliced Onion,  \n - 1x Salt',
                icon = 'nui://ox_inventory/web/images/burger_shotrings.png',
                event = 'vert-burgershot:client:StartFryer',
                args = {
                    Item = 'burger_shotrings',
                }
            },
        }
    })
    lib.showContext('Frying_Station')
end)

RegisterNetEvent('vert-burgershot:client:OpenChopMenu', function()
    lib.registerContext({
        id = 'Chop_Station',
        title = 'Burgershot Chopping Station',
        options = {
            {
                title = 'Grind Beef',
                icon = 'nui://ox_inventory/web/images/rawbeef.png',
                event = 'vert-burgershot:client:StartPrep',
                args = {
                    Item = 'rawbeef',
                }
            },
            {
                title = 'Grind Chicken',
                icon = 'nui://ox_inventory/web/images/rawchicken.png',
                event = 'vert-burgershot:client:StartPrep',
                args = {
                    Item = 'rawchicken',
                }
            },
            {
                title = 'Slice Potatoes',
                icon = 'nui://ox_inventory/web/images/rawpotato.png',
                event = 'vert-burgershot:client:StartPrep',
                args = {
                    Item = 'rawpotato',
                }
            },
            {
                title = 'Dice Onions',
                icon = 'nui://ox_inventory/web/images/rawonion.png',
                event = 'vert-burgershot:client:StartPrep',
                args = {
                    Item = 'rawonion',
                }
            },
        }
    })
    lib.showContext('Chop_Station')
end)

RegisterNetEvent('vert-burgershot:client:OpenPrepMenu', function()
    lib.registerContext({
        id = 'Prep_Station',
        title = 'Burgershot Preparing Station',
        options = {
            {
                title = 'Cook Bacon Cheeseburger',
                description = 'Requires:  \n - 1x Beef Patty,  \n - 1x Bacon,  \n - 1x Cheese,  \n - 1x Burger Buns',
                icon = 'nui://ox_inventory/web/images/bacon_cheeseburger.png',
                event = 'vert-burgershot:client:BuildBurger',
                args = {
                    Item = 'bacon_cheeseburger',
                }
            },
            {
                title = 'Cook Moneyshot Burger',
                description = 'Requires:  \n - 2x Beef Patty,  \n - 1x Bacon,  \n - 2x Cheese,  \n - 1x Burger Buns',
                icon = 'nui://ox_inventory/web/images/burger_moneyshot.png',
                event = 'vert-burgershot:client:BuildBurger',
                args = {
                    Item = 'burger_moneyshot',
                }
            },
            {
                title = 'Cook Bleeder Burger',
                description = 'Requires:  \n - 1x Beef Patty,  \n - 1x Cheese,  \n - 1x Burger Buns,  \n - 1x Sliced Onion',
                icon = 'nui://ox_inventory/web/images/burger_bleeder.png',
                event = 'vert-burgershot:client:BuildBurger',
                args = {
                    Item = 'burger_bleeder',
                }
            },
            {
                title = 'Cook Heartstopper Burger',
                description = 'Requires:  \n - 4x Beef Patty,  \n - 4x Cheese,  \n - 1x Burger Buns,  \n - 2x Bacon',
                icon = 'nui://ox_inventory/web/images/burger_heartstopper.png',
                event = 'vert-burgershot:client:BuildBurger',
                args = {
                    Item = 'burger_heartstopper',
                }
            },
            {
                title = 'Cook Torpedo Burger',
                description = 'Requires:  \n - 1x Beef Patty,  \n - 1x Cheese,  \n - 1x Burger Buns,  \n - 1x Bacon,  \n - 1x Sliced Onion',
                icon = 'nui://ox_inventory/web/images/burger_torpedo.png',
                event = 'vert-burgershot:client:BuildBurger',
                args = {
                    Item = 'burger_torpedo',
                }
            },
        }
    })
    lib.showContext('Prep_Station')
end)

RegisterNetEvent('vert-burgershot:client:OpenDrinkMenu', function()
    lib.registerContext({
        id = 'Drink_Station',
        title = 'Burgershot Drink Station',
        options = {
            {
                title = 'Soft Drink',
                description = 'Requires:  \n - 1x cola  \n - 1x cup',
                icon = 'nui://ox_inventory/web/images/burger_softdrink.png',
                event = 'vert-burgershot:client:PourDrink',
                args = {
                    Item = 'burger_softdrink',
                }
            },
            {
                title = 'Coffee',
                description = 'Requires:  \n - 1x Coffee Beans  \n - 1x Creamer',
                icon = 'nui://ox_inventory/web/images/burger_coffee.png',
                event = 'vert-burgershot:client:PourDrink',
                args = {
                    Item = 'burger_coffee',
                }
            },
        }
    })
    lib.showContext('Drink_Station')
end)

RegisterNetEvent('vert-burgershot:client:StartGrill', function(data) -- Cooking Food
    local Input = lib.inputDialog('How many items would you like to cook?', {
        { type = 'number', label = 'How many items would you like to cook?', min = 1, max = 15 },
    })
    if not Input then return end
    local Time = (Config.GrillItems[data.Item].choptime * 1000) * Input[1]
    QBCore.Functions.TriggerCallback('vert-burgershot:server:StartCook', function(cb)
        if cb then
            if lib.progressBar({
                duration = Time,
                label = Config.GrillItems[data.Item].progressbar,
                useWhileDead = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = {
                    dict = 'amb@prop_human_bbq@male@base',
                    clip = 'base',
                    flag = 1,
                },
            }) then -- done
                ClearPedTasks(cache.ped)
                TriggerServerEvent('vert-burgershot:server:BeginCook', data.Item, Input[1])
            else -- cancel
                ClearPedTasks(cache.ped)
                QBCore.Functions.Notify('Cancelled...', 'error', 7500)
            end
        end
    end, data.Item, Input[1])
end)

RegisterNetEvent('vert-burgershot:client:StartFryer', function(data) -- Frying Food
    local Input = lib.inputDialog('How many items would you like to fry?', {
        { type = 'number', label = 'How many items would you like to fry?', min = 1, max = 15 },
    })
    if not Input then return end
    local Time = (Config.FryerItems[data.Item].choptime * 1000) * Input[1]
    QBCore.Functions.TriggerCallback('vert-burgershot:server:StartFrying', function(cb)
        if cb then
            if lib.progressBar({
                duration = Time,
                label = Config.FryerItems[data.Item].progressbar,
                useWhileDead = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = {
                    dict = 'amb@prop_human_bbq@male@base',
                    clip = 'base',
                    flag = 1,
                },
            }) then -- done
                ClearPedTasks(cache.ped)
                TriggerServerEvent('vert-burgershot:server:BeginFrying', data.Item, Input[1])
            else -- cancel
                ClearPedTasks(cache.ped)
                QBCore.Functions.Notify('Cancelled...', 'error', 7500)
            end
        end
    end, data.Item, Input[1])
end)

RegisterNetEvent('vert-burgershot:client:StartPrep', function(data) -- Prepping
    local Input = lib.inputDialog('How many items would you like to slice?', {
        { type = 'number', label = 'How many items would you like to slice?', min = 1, max = 15 },
    })
    if not Input then return end
    local Time = (Config.ChoppingItems[data.Item].choptime * 1000) * Input[1]
    QBCore.Functions.TriggerCallback('vert-burgershot:server:StartPrep', function(cb)
        if cb then
            if lib.progressBar({
                duration = Time,
                label = Config.ChoppingItems[data.Item].progressbar,
                useWhileDead = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = {
                    dict = 'anim@amb@business@coc@coc_unpack_cut_left@',
                    clip = 'coke_cut_coccutter',
                    flag = 1,
                },
            }) then -- done
                ClearPedTasks(cache.ped)
                TriggerServerEvent('vert-burgershot:server:BeginPrep', data.Item, Input[1])
            else -- cancel
                ClearPedTasks(cache.ped)
                QBCore.Functions.Notify('Cancelled...', 'error', 7500)
            end
        end
    end, data.Item, Input[1])
end)

RegisterNetEvent('vert-burgershot:client:BuildBurger', function(data) -- Making Burgers
    local Input = lib.inputDialog('How many items would you like to prepare?', {
        { type = 'number', label = 'How many items would you like to prepare?', min = 1, max = 15 },
    })
    if not Input then return end
    local Time = (Config.PreppingItems[data.Item].choptime * 1000) * Input[1]
    QBCore.Functions.TriggerCallback('vert-burgershot:server:BuildBurger', function(cb)
        if cb then
            if lib.progressBar({
                duration = Time,
                label = Config.PreppingItems[data.Item].progressbar,
                useWhileDead = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = {
                    dict = 'anim@amb@business@coc@coc_unpack_cut_left@',
                    clip = 'coke_cut_coccutter',
                    flag = 1,
                },
            }) then -- done
                ClearPedTasks(cache.ped)
                TriggerServerEvent('vert-burgershot:server:BeginBuilding', data.Item, Input[1])
            else -- cancel
                ClearPedTasks(cache.ped)
                QBCore.Functions.Notify('Cancelled...', 'error', 7500)
            end
        end
    end, data.Item, Input[1])
end)

RegisterNetEvent('vert-burgershot:client:PourDrink', function(data) -- Making Drinks
    local Input = lib.inputDialog('How many drinks would you like to pour?', {
        { type = 'number', label = 'How many drinks would you like to pour?', min = 1, max = 15 },
    })
    if not Input then return end
    local Time = (Config.DrinkItems[data.Item].choptime * 1000) * Input[1]
    QBCore.Functions.TriggerCallback('vert-burgershot:server:PourDrink', function(cb)
        if cb then
            if lib.progressBar({
                duration = Time,
                label = Config.DrinkItems[data.Item].progressbar,
                useWhileDead = false,
                allowCuffed = false,
                allowFalling = false,
                canCancel = false,
                disable = { car = true, move = true, combat = true },
                anim = {
                    dict = 'anim@amb@casino@mini@drinking@bar@drink@heels@two',
                    clip = 'two_bartender',
                    flag = 1,
                },
            }) then -- done
                ClearPedTasks(cache.ped)
                TriggerServerEvent('vert-burgershot:server:BeginPouring', data.Item, Input[1])
            else -- cancel
                ClearPedTasks(cache.ped)
                QBCore.Functions.Notify('Cancelled...', 'error', 7500)
            end
        end
    end, data.Item, Input[1])
end)

CreateThread(function()
    for k, v in pairs(Config.Blips) do
        if v.enable then
            blips[k] = AddBlipForCoord(v.coords)
            SetBlipSprite(blips[k], v.sprite)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale(blips[k], v.scale)
            SetBlipAsShortRange(blips[k], true)
            SetBlipColour(blips[k], v.color)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.text)
            EndTextCommandSetBlipName(blips[k])
        end
    end
end)
