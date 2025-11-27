ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local PlayerVehicles = {}

-- Lade persistente Fahrzeuge beim Login
RegisterServerEvent('pv:loadVehicles')
AddEventHandler('pv:loadVehicles', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(vehicles)
        PlayerVehicles[xPlayer.identifier] = vehicles
        TriggerClientEvent('pv:spawnVehicles', source, vehicles)
    end)
end)

-- Speichere Fahrzeug
RegisterServerEvent('pv:saveVehicle')
AddEventHandler('pv:saveVehicle', function(vehicleData)
    local xPlayer = ESX.GetPlayerFromId(source)
    if Config.SaveOnlyPlayerVehicles and not vehicleData.owner then
        return -- Fahrzeuge ohne Besitzer werden nicht gespeichert
    end

    if Config.AntiDupe then
        local exists = MySQL.Sync.fetchScalar('SELECT COUNT(1) FROM player_vehicles WHERE plate = @plate', {
            ['@plate'] = vehicleData.plate
        })
        if exists > 0 then
            if Config.Debug then print('Duplikat-Fahrzeug erkannt: '..vehicleData.plate) end
            return
        end
    end

    MySQL.Async.execute('INSERT INTO player_vehicles (owner, plate, model, props, stored) VALUES (@owner, @plate, @model, @props, @stored)', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = vehicleData.plate,
        ['@model'] = vehicleData.model,
        ['@props'] = json.encode(vehicleData.props),
        ['@stored'] = 1
    })
end)

-- Auto-Parking Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.AutoParkTime * 3600 * 1000)
        if Config.CleanupNPC then
            MySQL.Async.execute('DELETE FROM player_vehicles WHERE stored = 0', {}, function(rowsChanged)
                if Config.Debug then print('NPC-Fahrzeuge geparkt: '..rowsChanged) end
            end)
        end
    end
end)
