ESX = nil
local spawnedVehicles = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    TriggerServerEvent('pv:loadVehicles')
end)

RegisterNetEvent('pv:spawnVehicles')
AddEventHandler('pv:spawnVehicles', function(vehicles)
    for _,v in pairs(vehicles) do
        local model = v.model
        local props = json.decode(v.props)
        local x, y, z = table.unpack(props.position)
        ESX.Game.SpawnVehicle(model, vector3(x, y, z), props.heading, function(vehicle)
            ESX.Game.SetVehicleProperties(vehicle, props)
            spawnedVehicles[v.plate] = vehicle
        end)
    end
end)
