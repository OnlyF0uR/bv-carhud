-- ========================================
-- Some config values
local seatbeltEjectSpeed = 45.0 -- Speed threshold to eject player (MPH)
local seatbeltEjectAccel = 100.0 -- Acceleration threshold to eject player (G's)

-- ========================================
local pedInVeh = false
local timeText = ""
zoneText = ""
streetText = ""
local currentFuel = 0.0
local currSpeed = 0.0
local seatbeltIsOn = false

-- ========================================
function checkModelTable(table, model)
    for k, v in pairs(table) do
        if model == v then
            return true
        end
    end
    return false
end

function drawTxt(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

-- ========================================
local zones = {
    ['AIRP'] = "Los Santos International Airport",
    ['ALAMO'] = "Alamo Sea",
    ['ALTA'] = "Alta",
    ['ARMYB'] = "Fort Zancudo",
    ['BANHAMC'] = "Banham Canyon Dr",
    ['BANNING'] = "Banning",
    ['BEACH'] = "Vespucci Beach",
    ['BHAMCA'] = "Banham Canyon",
    ['BRADP'] = "Braddock Pass",
    ['BRADT'] = "Braddock Tunnel",
    ['BURTON'] = "Burton",
    ['CALAFB'] = "Calafia Bridge",
    ['CANNY'] = "Raton Canyon",
    ['CCREAK'] = "Cassidy Creek",
    ['CHAMH'] = "Chamberlain Hills",
    ['CHIL'] = "Vinewood Hills",
    ['CHU'] = "Chumash",
    ['CMSW'] = "Chiliad Mountain State Wilderness",
    ['CYPRE'] = "Cypress Flats",
    ['DAVIS'] = "Davis",
    ['DELBE'] = "Del Perro Beach",
    ['DELPE'] = "Del Perro",
    ['DELSOL'] = "La Puerta",
    ['DESRT'] = "Grand Senora Desert",
    ['DOWNT'] = "Downtown",
    ['DTVINE'] = "Downtown Vinewood",
    ['EAST_V'] = "East Vinewood",
    ['EBURO'] = "El Burro Heights",
    ['ELGORL'] = "El Gordo Lighthouse",
    ['ELYSIAN'] = "Elysian Island",
    ['GALFISH'] = "Galilee",
    ['GOLF'] = "GWC and Golfing Society",
    ['GRAPES'] = "Grapeseed",
    ['GREATC'] = "Great Chaparral",
    ['HARMO'] = "Harmony",
    ['HAWICK'] = "Hawick",
    ['HORS'] = "Vinewood Racetrack",
    ['HUMLAB'] = "Humane Labs and Research",
    ['JAIL'] = "Bolingbroke Penitentiary",
    ['KOREAT'] = "Little Seoul",
    ['LACT'] = "Land Act Reservoir",
    ['LAGO'] = "Lago Zancudo",
    ['LDAM'] = "Land Act Dam",
    ['LEGSQU'] = "Legion Square",
    ['LMESA'] = "La Mesa",
    ['LOSPUER'] = "La Puerta",
    ['MIRR'] = "Mirror Park",
    ['MORN'] = "Morningwood",
    ['MOVIE'] = "Richards Majestic",
    ['MTCHIL'] = "Mount Chiliad",
    ['MTGORDO'] = "Mount Gordo",
    ['MTJOSE'] = "Mount Josiah",
    ['MURRI'] = "Murrieta Heights",
    ['NCHU'] = "North Chumash",
    ['NOOSE'] = "N.O.O.S.E",
    ['OCEANA'] = "Pacific Ocean",
    ['PALCOV'] = "Paleto Cove",
    ['PALETO'] = "Paleto Bay",
    ['PALFOR'] = "Paleto Forest",
    ['PALHIGH'] = "Palomino Highlands",
    ['PALMPOW'] = "Palmer-Taylor Power Station",
    ['PBLUFF'] = "Pacific Bluffs",
    ['PBOX'] = "Pillbox Hill",
    ['PROCOB'] = "Procopio Beach",
    ['RANCHO'] = "Rancho",
    ['RGLEN'] = "Richman Glen",
    ['RICHM'] = "Richman",
    ['ROCKF'] = "Rockford Hills",
    ['RTRAK'] = "Redwood Lights Track",
    ['SANAND'] = "San Andreas",
    ['SANCHIA'] = "San Chianski Mountain Range",
    ['SANDY'] = "Sandy Shores",
    ['SKID'] = "Mission Row",
    ['SLAB'] = "Stab City",
    ['STAD'] = "Maze Bank Arena",
    ['STRAW'] = "Strawberry",
    ['TATAMO'] = "Tataviam Mountains",
    ['TERMINA'] = "Terminal",
    ['TEXTI'] = "Textile City",
    ['TONGVAH'] = "Tongva Hills",
    ['TONGVAV'] = "Tongva Valley",
    ['VCANA'] = "Vespucci Canals",
    ['VESP'] = "Vespucci",
    ['VINE'] = "Vinewood",
    ['WINDF'] = "Ron Alternates Wind Farm",
    ['WVINE'] = "West Vinewood",
    ['ZANCUDO'] = "Zancudo River",
    ['ZP_ORT'] = "Port of South Los Santos",
    ['ZQ_UAR'] = "Davis Quartz"
}

Citizen.CreateThread(function()
    while true do
        -- Update when player is in a vehicle or on foot (if enabled)
        if pedInVeh then
            -- Get player, position and vehicle
            local player = PlayerPedId()
            local position = GetEntityCoords(player)

            -- Update time text string
            -- local hour = GetClockHours()
            -- local minute = GetClockMinutes()
            -- timeText = ("%.2d"):format((hour == 0) and 12 or hour) .. ":" .. ("%.2d"):format(minute) .. ((hour < 12) and " AM" or " PM")

            local hours = GetClockHours()
            if string.len(tostring(hours)) == 1 then
                hours = '0' .. hours
            end

            local mins = GetClockMinutes()
            if string.len(tostring(mins)) == 1 then
                mins = '0' .. mins
            end

            timeText = hours .. ':' .. mins

            local var1, var2 = GetStreetNameAtCoord(position.x, position.y, position.z, Citizen.ResultAsInteger(),
                Citizen.ResultAsInteger())

            streetText = GetStreetNameFromHashKey(var1)
            zoneText = zones[GetNameOfZone(position.x, position.y, position.z)]

            local streetName2 = GetStreetNameFromHashKey(var2)
            if streetName2 ~= "" then
                streetText = streetText .. " [" .. streetName2 .. "]"
            end

            -- Update fuel when in a vehicle
            if pedInVeh then
                local vehicle = GetVehiclePedIsIn(player, false)
                if vehicle ~= nil and DoesEntityExist(vehicle) then
                    local fuel = GetVehicleFuelLevel(vehicle)
                    currentFuel = math.floor(fuel * 10) / 10
                end
            end

            -- Update every second
            Citizen.Wait(1000)
        else
            Citizen.Wait(500)
        end
    end
end)

function turning(pVehicle, pToggle, pDefaultHandlingValue)
    if pVehicle ~= 0 then
        SetVehicleHandlingFloat(pVehicle, 'CHandlingData', 'fSteeringLock', (pToggle and pDefaultHandlingValue or (pDefaultHandlingValue / 4)))
    end
end

function harness(currentVehicle)
    -- Toggle steering
    local defaultSteering = GetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fSteeringLock')
    turning(currentVehicle, false, defaultSteering)

    if seatbeltIsOn then
        -- Taking of harnass
        TriggerEvent("mythic_progbar:client:progress", {
            name = "carhud",
            duration = 4000,
            label = "Taking off harness",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true
            }
        }, function(status)
            if not status then
                seatbeltIsOn = false
                TriggerServerEvent('InteractSound_SV:PlayOnSource', 'seatbeltoff', 1.0)

                turning(currentVehicle, true, defaultSteering)
            end
        end)
    else
        -- Putting harnass on
        TriggerEvent("mythic_progbar:client:progress", {
            name = "carhud",
            duration = 4000,
            label = "Putting on harness",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true
            }
        }, function(status)
            if not status then
                seatbeltIsOn = true
                TriggerServerEvent('InteractSound_SV:PlayOnSource', 'seatbelt', 1.0)

                turning(currentVehicle, true, defaultSteering)
            end
        end)
    end
end

-- ========================================
-- This part is seatbelt stuff
Citizen.CreateThread(function()
    while true do
        local sleep = 2000

        local player = PlayerPedId()
        local position = GetEntityCoords(player)
        local vehicle = GetVehiclePedIsIn(player, false)

        -- Set vehicle states
        if IsPedInAnyVehicle(player, false) then
            pedInVeh = true
            -- Set the sleep to 5 instead of the default (2000)
            sleep = 5

            local vehicleClass = GetVehicleClass(vehicle)
            if pedInVeh then
                -- Check for bike, bicycle and emergency bike
                if vehicleClass == 8 or vehicleClass == 13 or exports["bv-cars"]:GetCarClass(vehicle) == 'b_emergency' then
                    if not seatbeltIsOn then
                        seatbeltIsOn = true
                    end

                    goto continue
                end

                local prevSpeed = currSpeed
                currSpeed = GetEntitySpeed(vehicle)

                -- Set PED flags
                SetPedConfigFlag(player, 32, true)

                if IsControlJustReleased(0, 183) then
                    if exports["bv-cars"]:HasHarness(vehicle) then
                        harness(vehicle)
                    else
                        if seatbeltIsOn then
                            -- Adding seatbelt
                            seatbeltIsOn = false
                            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'seatbeltoff', 1.0)
                        else
                            -- Remove seatbelt
                            seatbeltIsOn = true
                            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'seatbelt', 1.0)
                        end
                    end

                    Citizen.Wait(500)
                end

                if not seatbeltIsOn then
                    -- Eject PED when moving forward, vehicle was going over 45 MPH and acceleration over 100 G's
                    local vehIsMovingFwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                    local vehAcc = (prevSpeed - currSpeed) / GetFrameTime()
                    if (vehIsMovingFwd and (prevSpeed > (seatbeltEjectSpeed / 2.237)) and
                        (vehAcc > (seatbeltEjectAccel * 9.81))) then
                        local position = GetEntityCoords(player)
                        SetEntityCoords(player, position.x, position.y, position.z - 0.47, true, true, true)
                        SetEntityVelocity(player, prevVelocity.x, prevVelocity.y, prevVelocity.z)
                        Wait(1)
                        SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)

                        pedInVeh = false
                        currSpeed = 0
                    else
                        -- Update previous velocity for ejecting player
                        prevVelocity = GetEntityVelocity(vehicle)
                    end
                else
                    -- Disable vehicle exit when seatbelt is on
                    DisableControlAction(0, 75)
                end
            end
            
        else
            -- Reset states when not in car
            pedInVeh = false
            seatbeltIsOn = false
        end

        ::continue::

        Wait(sleep)
    end
end)

-- ========================================
local time = "12:00"
RegisterNetEvent("timeheader")
AddEventHandler("timeheader", function(h, m)
    if h < 10 then
        h = "0" .. h
    end
    if m < 10 then
        m = "0" .. m
    end
    time = h .. ":" .. m
end)

-- ========================================
local playerPed = PlayerPedId()
local vehicle = GetVehiclePedIsIn(playerPed, false)
local Mph = GetEntitySpeed(vehicle) * 3.6
local uiopen = false
local colorblind = false
local compass_on = false

RegisterNetEvent('option:colorblind')
AddEventHandler('option:colorblind', function()
    colorblind = not colorblind
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        if IsVehicleEngineOn(GetVehiclePedIsIn(playerPed, false)) then
            if not uiopen then
                uiopen = true
                SendNUIMessage({
                    open = 1
                })
            end

            local vehicle = GetVehiclePedIsIn(playerPed, false)

            local atl = false
            if IsPedInAnyPlane(playerPed) or IsPedInAnyHeli(playerPed) then
                atl = string.format("%.1f", GetEntityHeightAboveGround(vehicle) * 3.28084)
            end

            local engine = false
            if GetVehicleEngineHealth(vehicle) < 400.0 then
                engine = true
            end

            local GasTank = false
            if GetVehiclePetrolTankHealth(vehicle) < 3002.0 then
                GasTank = true
            end

            SendNUIMessage({
                open = 2,
                mph = math.ceil(GetEntitySpeed(vehicle) * 3.6),
                fuel = currentFuel,
                belt = seatbeltIsOn,
                time = timeText,
                colorblind = colorblind,
                atl = atl,
                engine = engine,
                GasTank = GasTank
            })
        else
            if uiopen then
                SendNUIMessage({
                    open = 3
                })
                uiopen = false
            end
        end

        Citizen.Wait(5)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 2000

        local player = PlayerPedId()
        local veh = GetVehiclePedIsIn(player, false)
        local headingg = (-GetEntityHeading(player) % 360)
        if IsPedInAnyVehicle(player, false) then
            sleep = 100
        end

        if IsVehicleEngineOn(veh) then
            -- in vehicle
            SendNUIMessage({
                open = 2,
                direction = math.floor(calcHeading(headingg))
            })
        else
            Citizen.Wait(3000)
        end
        Citizen.Wait(sleep)
    end
end)

local imageWidth = 100 -- leave this variable, related to pixel size of the directions
local containerWidth = 100 -- width of the image container

-- local width =  (imageWidth / containerWidth) * 100; -- used to convert image width if changed
local width = 0;
local south = (-imageWidth) + width
local west = (-imageWidth * 2) + width
local north = (-imageWidth * 3) + width
local east = (-imageWidth * 4) + width
local south2 = (-imageWidth * 5) + width

function calcHeading(direction)
    if (direction < 90) then
        return lerp(north, east, direction / 90)
    elseif (direction < 180) then
        return lerp(east, south2, rangePercent(90, 180, direction))
    elseif (direction < 270) then
        return lerp(south, west, rangePercent(180, 270, direction))
    elseif (direction <= 360) then
        return lerp(west, north, rangePercent(270, 360, direction))
    end
end

function rangePercent(min, max, amt)
    return (((amt - min) * 100) / (max - min)) / 100
end

function lerp(min, max, amt)
    return (1 - amt) * min + amt * max
end

local enableCruise = false
Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedSittingInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if IsControlJustPressed(1, 29) then
                if (GetPedInVehicleSeat(vehicle, -1) == ped) then
                    if enableCruise then
                        -- turning off
                        SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel"))
                        exports['mythic_notify']:SendAlert('inform', 'Limiter is now turned off.')
                        enableCruise = false
                    else
                        -- turning on
                        local speed = GetEntitySpeed(vehicle)

                        SetEntityMaxSpeed(vehicle, speed)
                        exports['mythic_notify']:SendAlert('inform', 'Limiter is now set to:' .. math.floor(speed * 3.6) .. ' km/h.')
                        enableCruise = true
                    end
                end
            end
        else
            Citizen.Wait(2000)
        end
        Citizen.Wait(5)
    end
end)