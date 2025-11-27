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
    MySQL.Async.execute('INSERT INTO player_vehicles (owner, plate, model, props, stored) VALUES (@owner, @plate, @model, @props, @stored)', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = vehicleData.plate,
        ['@model'] = vehicleData.model,
        ['@props'] = json.encode(vehicleData.props),
        ['@stored'] = 1
    })
end)
