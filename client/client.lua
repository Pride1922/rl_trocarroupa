ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = sourcePlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

-- Criar markers e eventos de entrar e sair do marker
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        Citizen.Wait(5)
        local playerPed = GetPlayerPed(-1)
        local playerPosition = GetEntityCoords(playerPed)
	
		for k, v in pairs (Config.Markers) do 
            if ESX.PlayerData.job.name == v.trabalho or ESX.PlayerData.job.name == v.offtrabalho then
                if GetDistanceBetweenCoords(playerPosition, v.coords.x, v.coords.y, v.coords.z) <= 15 then
                    DrawMarker(Config.MarkerType, v.coords.x, v.coords.y, v.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, false, false, true, false, false, false)
					if GetDistanceBetweenCoords(playerPosition, v.coords.x, v.coords.y, v.coords.z) <= 1.5 then
                        if not IsPedInAnyVehicle(playerPed) then
                            DrawText3D(v.coords.x, v.coords.y, v.coords.z + 0.25, '~g~E~w~ - Trocar de roupa')
                            if IsControlJustReleased(0, 38) then
								openmenuroupa()
                            end
                        end
                    end
                end
			end
		end
	end
end)
--Funcao para trocar ou apagar roupa
function openmenuroupa()
	local elements = {}
	table.insert(elements, {label = ('Trocar Roupa'), value = 'player_dressing'})
	table.insert(elements, {label = ('Remover Roupa'), value = 'remove_cloth'})
	
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room', {
		title    = 'Roupeiro',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
	
		if data.current.value == 'player_dressing' then
			-- funcao para carregar roupas 
			ESX.TriggerServerCallback('rl_trocarroupa:getPlayerDressing', function(dressing)
				local elements = {}
				for i=1, #dressing, 1 do
					table.insert(elements, {
						label = dressing[i],
						value = i
					})
				end
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
					title    = 'Roupas',
					align    = 'top-left',
					elements = elements
					}, function(data2, menu2)
					TriggerEvent('skinchanger:getSkin', function(skin)
					ESX.TriggerServerCallback('rl_trocarroupa:getPlayerOutfit', function(clothes)
						TriggerEvent('skinchanger:loadClothes', skin, clothes)
						TriggerEvent('esx_skin:setLastSkin', skin)
						TriggerEvent('skinchanger:getSkin', function(skin)
						TriggerServerEvent('esx_skin:save', skin)
						end)
					end, data2.current.value)
					end)
					end, function(data2, menu2)
					menu2.close()
				end)
			end)
		elseif data.current.value == 'remove_cloth' then
			ESX.TriggerServerCallback('rl_trocarroupa:getPlayerDressing', function(dressing)
				local elements = {}

				for i=1, #dressing, 1 do
					table.insert(elements, {
						label = dressing[i],
						value = i
					})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_cloth', {
					title    = 'Remover Roupas',
					align    = 'top-left',
					elements = elements
				}, function(data2, menu2)
					menu2.close()
					TriggerServerEvent('rl_trocarroupa:removeOutfit', data2.current.value)
					exports['mythic_notify']:SendAlert('success', _U('deleted_clothes.')
				end, function(data2, menu2)
					menu2.close()
				end)
			end)
		end
	end, function(data, menu)
	menu.close()
	end)
end


-- Funcao para criar texto 3D no marcador
DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
