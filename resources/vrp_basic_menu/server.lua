--[[
    FiveM Scripts
    Copyright C 2018  Sighmir

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    at your option any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("vrp", "lib/htmlEntities")

vRPbm = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_basic_menu")
BMclient = Tunnel.getInterface("vRP_basic_menu","vRP_basic_menu")
vRPbsC = Tunnel.getInterface("vRP_barbershop","vRP_basic_menu")
Tunnel.bindInterface("vrp_basic_menu",vRPbm)

local Lang = module("vrp", "lib/Lang")
local cfg = module("vrp", "cfg/base")
local lang = Lang.new(module("vrp", "cfg/lang/"..cfg.lang) or {})

-- LOG FUNCTION
function vRPbm.logInfoToFile(file,info)
  file = io.open(file, "a")
  if file then
    file:write(os.date("%c").." => "..info.."\n")
  end
  file:close()
end
-- MAKE CHOICES
--toggle service
local choice_service = {function(player,choice)
  local user_id = vRP.getUserId({player})
  local service = "onservice"
  if user_id ~= nil then
    if vRP.hasGroup({user_id,service}) then
	  vRP.removeUserGroup({user_id,service})
	  if vRP.hasMission({player}) then
		vRP.stopMission({player})
	  end
      vRPclient.notify(player,{"~r~Serviço desligado"})
	else
	  vRP.addUserGroup({user_id,service})
      vRPclient.notify(player,{"~g~Serviço ligado"})
	end
  end
end, "Ligar/Desligar serviços"}

-- teleport waypoint
local choice_tptowaypoint = {function(player,choice)
  TriggerClientEvent("TpToWaypoint", player)
end, "Teleportar para marcação."}

-- fix barbershop green hair for now
local ch_fixhair = {function(player,choice)
    local custom = {}
    local user_id = vRP.getUserId({player})
    vRP.getUData({user_id,"vRP:head:overlay",function(value)
	  if value ~= nil then
	    custom = json.decode(value)
        vRPbsC.setOverlay(player,{custom,true})
	  end
	end})
end, "Fixar o bug da barbearia."}

--toggle blips
local ch_blips = {function(player,choice)
  TriggerClientEvent("showBlips", player)
end, "Ativar blips."}

local spikes = {}
local ch_spikes = {function(player,choice)
	local user_id = vRP.getUserId({player})
	BMclient.isCloseToSpikes(player,{},function(closeby)
		if closeby and (spikes[player] or vRP.hasPermission({user_id,"admin.spikes"})) then
		  BMclient.removeSpikes(player,{})
		  spikes[player] = false
		elseif closeby and not spikes[player] and not vRP.hasPermission({user_id,"admin.spikes"}) then
		  vRPclient.notify(player,{"~r~Você só pode carregar apenas um conjunto de spikes!"})
		elseif not closeby and spikes[player] and not vRP.hasPermission({user_id,"admin.spikes"}) then
		  vRPclient.notify(player,{"~r~Você só pode implantar apenas um conjunto de spikes!"})
		elseif not closeby and (not spikes[player] or vRP.hasPermission({user_id,"admin.spikes"})) then
		  BMclient.setSpikesOnGround(player,{})
		  spikes[player] = true
		end
	end)
end, "Ativar spikes."}

local ch_sprites = {function(player,choice)
  TriggerClientEvent("showSprites", player)
end, "Ativar sprites."}

local ch_deleteveh = {function(player,choice)
  BMclient.deleteVehicleInFrontOrInside(player,{5.0})
end, "Deletar o carro mais próximo."}

--client function
local ch_crun = {function(player,choice)
  vRP.prompt({player,"Function:","",function(player,stringToRun) 
    stringToRun = stringToRun or ""
	TriggerClientEvent("RunCode:RunStringLocally", player, stringToRun)
  end})
end, "Ativar função do client."}

--server function
local ch_srun = {function(player,choice)
  vRP.prompt({player,"Function:","",function(player,stringToRun) 
    stringToRun = stringToRun or ""
	TriggerEvent("RunCode:RunStringRemotelly", stringToRun)
  end})
end, "Ativar função do servidor."}

--police weapons // comment out the weapons if you dont want to give weapons.
-- Colete pra geral

--store money
local choice_store_money = {function(player, choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    local amount = vRP.getMoney({user_id})
    if vRP.tryPayment({user_id, amount}) then -- unpack the money
      vRP.giveInventoryItem({user_id, "money", amount, true})
    end
  end
end, "Enviar seu dinheiro da carteira para o inventário."}

local pm_weapons = {}
pm_weapons["Coronel"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pm_weapons["TCel."] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pm_weapons["Major/Capitao"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_CARBINERIFLE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pm_weapons["Sargento"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SMG"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pm_weapons["Soldado"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pm_weapons["Recruta"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pm_weapons["Curar"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRPclient.setHealth(player,{1000})
end}

local pcesp_weapons = {}
pcesp_weapons["Delegado 1"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pcesp_weapons["Delegado 2"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_HEAVYSNIPER"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pcesp_weapons["Agente"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SMG"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
pcesp_weapons["Curar"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRPclient.setHealth(player,{1000})
end}

local rota_weapons = {}
rota_weapons["Coronel 1"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
rota_weapons["Coronel 2"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_HEAVYSNIPER"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
rota_weapons["Sargento"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
rota_weapons["Soldado"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
rota_weapons["Curar"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRPclient.setHealth(player,{1000})
end}

local grpae_weapons = {}
grpae_weapons["Coronel"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SPECIALCARBINE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
grpae_weapons["Major/Capitao"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_CARBINERIFLE"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
grpae_weapons["Sargento"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
      ["WEAPON_COMBATPISTOL"] = {ammo=250},
	  ["WEAPON_SMG"] = {ammo=250},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=250},
	  ["WEAPON_NIGHTSTICK"] = {ammo=250},
	  ["WEAPON_STUNGUN"] = {ammo=250}
	}, true})
	BMclient.setArmour(player,{100,true})
end}
grpae_weapons["Curar"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRPclient.setHealth(player,{1000})
end}
--medkit storage
local emergency_medkit = {}
emergency_medkit["Take"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRP.giveInventoryItem({user_id,"medkit",25,true})
	vRP.giveInventoryItem({user_id,"pills",25,true})
end}

--heal me
local emergency_heal = {}
emergency_heal["Curar"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRPclient.setHealth(player,{1000})
end}

--loot corpse
local choice_loot = {function(player,choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      local nuser_id = vRP.getUserId({nplayer})
      if nuser_id ~= nil then
        vRPclient.isInComa(nplayer,{}, function(in_coma)
          if in_coma then
			local revive_seq = {
			  {"amb@medic@standing@kneel@enter","enter",1},
			  {"amb@medic@standing@kneel@idle_a","idle_a",1},
			  {"amb@medic@standing@kneel@exit","exit",1}
			}
  			vRPclient.playAnim(player,{false,revive_seq,false}) -- anim
            SetTimeout(15000, function()
              local ndata = vRP.getUserDataTable({nuser_id})
              if ndata ~= nil then
			    if ndata.inventory ~= nil then -- gives inventory items
				  vRP.clearInventory({nuser_id})
                  for k,v in pairs(ndata.inventory) do 
			        vRP.giveInventoryItem({user_id,k,v.amount,true})
	              end
				end
			  end
			  local nmoney = vRP.getMoney({nuser_id})
			  if vRP.tryPayment({nuser_id,nmoney}) then
			    vRP.giveMoney({user_id,nmoney})
			  end
            end)
			vRPclient.stopAnim(player,{false})
          else
            vRPclient.notify(player,{lang.emergency.menu.revive.not_in_coma()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player, {5}, function(nplayer)
    SetTimeout(15000, function()
      local nuser_id = vRP.getUserId({nplayer})
      if nuser_id ~= nil then
	  vRPclient.isInComa(nplayer,{}, function(in_coma)
          if in_coma then
            vRPclient.getWeapons(nplayer,{},function(weapons)
              for k,v in pairs(weapons) do -- display seized weapons
                -- vRPclient.notify(player,{lang.police.menu.seize.seized({k,v.ammo})})
                -- convert weapons to parametric weapon items
                vRP.giveInventoryItem({user_id, "wbody|"..k, 1, true})
                if v.ammo > 0 then
                  vRP.giveInventoryItem({user_id, "wammo|"..k, v.ammo, true})
                end
              end

              -- clear all weapons
              vRPclient.giveWeapons(nplayer,{{},true})
            end)
			end
			end)
          end
        end)
      end)
    end
end,"Saquear corpo próximo"}

-- hack player
local ch_hack = {function(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{25},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
          -- prompt number
		  local nbank = vRP.getBankMoney({nuser_id})
          local amount = math.floor(nbank*0.01)
		  local nvalue = nbank - amount
		  if math.random(1,100) == 1 then
			vRP.setBankMoney({nuser_id,nvalue})
            vRPclient.notify(nplayer,{"Hackeado ~r~".. amount .."$."})
		    vRP.giveInventoryItem({user_id,"dirty_money",amount,true})
		  else
            vRPclient.notify(nplayer,{"~g~Tentativa de hackear falhou."})
            vRPclient.notify(player,{"~r~Tentativa de hackear falhou."})
		  end
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end,"Hackear o player mais próximo."}

-- mug player
local ch_mug = {function(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
          -- prompt number
		  local nmoney = vRP.getMoney({nuser_id})
          local amount = nmoney
		  if math.random(1,3) == 1 then
            if vRP.tryPayment({nuser_id,amount}) then
              vRPclient.notify(nplayer,{"Assaltou ~r~"..amount.."$."})
		      vRP.giveInventoryItem({user_id,"dirty_money",amount,true})
            else
              vRPclient.notify(player,{lang.money.not_enough()})
            end
		  else
            vRPclient.notify(nplayer,{"~g~Tentativa de assalto falhou."})
            vRPclient.notify(player,{"~r~Tentativa de assalto falhou."})
		  end
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, "Assaltar player mais próximo."}

-- drag player
local ch_drag = {function(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
		  vRPclient.isHandcuffed(nplayer,{},function(handcuffed)
			if handcuffed then
				TriggerClientEvent("dr:drag", nplayer, player)
			else
				vRPclient.notify(player,{"O jogador não está algemado."})
			end
		  end)
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, "Arrastar jogador mais próximo."}

-- player check
local choice_player_check = {function(player,choice)
  vRPclient.getNearestPlayer(player,{5},function(nplayer)
    local nuser_id = vRP.getUserId({nplayer})
    if nuser_id ~= nil then
      vRPclient.notify(nplayer,{lang.police.menu.check.checked()})
      vRPclient.getWeapons(nplayer,{},function(weapons)
        -- prepare display data (money, items, weapons)
        local money = vRP.getMoney({nuser_id})
        local items = ""
        local data = vRP.getUserDataTable({nuser_id})
        if data and data.inventory then
          for k,v in pairs(data.inventory) do
            local item_name = vRP.getItemName({k})
            if item_name then
              items = items.."<br />"..item_name.." ("..v.amount..")"
            end
          end
        end

        local weapons_info = ""
        for k,v in pairs(weapons) do
          weapons_info = weapons_info.."<br />"..k.." ("..v.ammo..")"
        end

        vRPclient.setDiv(player,{"police_check",".div_police_check{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",lang.police.menu.check.info({money,items,weapons_info})})
        -- request to hide div
        vRP.request({player, lang.police.menu.check.request_hide(), 1000, function(player,ok)
          vRPclient.removeDiv(player,{"police_check"})
        end})
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end, lang.police.menu.check.description()}

-- player store weapons
local store_weapons_cd = {}
function storeWeaponsCooldown()
  for user_id,cd in pairs(store_weapons_cd) do
    if cd > 0 then
      store_weapons_cd[user_id] = cd - 1
	end
  end
  SetTimeout(1000,function()
	storeWeaponsCooldown()
  end)
end
storeWeaponsCooldown()
local choice_store_weapons = {function(player, choice)
  local user_id = vRP.getUserId({player})
  if (store_weapons_cd[user_id] == nil or store_weapons_cd[user_id] == 0) and user_id ~= nil then
    store_weapons_cd[user_id] = 5
    vRPclient.getWeapons(player,{},function(weapons)
      for k,v in pairs(weapons) do
        -- convert weapons to parametric weapon items
        vRP.giveInventoryItem({user_id, "wbody|"..k, 1, true})
        if v.ammo > 0 then
          vRP.giveInventoryItem({user_id, "wammo|"..k, v.ammo, true})
        end
      end
      -- clear all weapons
      vRPclient.giveWeapons(player,{{},true})
    end)
  else
    vRPclient.notify(player,{"~r~Você já está guardando suas armas."})
  end
end, lang.police.menu.store_weapons.description()}

-- armor item
vRP.defInventoryItem({"body_armor","Colete","Colete intacto.",
function(args)
  local choices = {}

  choices["Equip"] = {function(player,choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
      if vRP.tryGetInventoryItem({user_id, "body_armor", 1, true}) then
		BMclient.setArmour(player,{100,true})
        vRP.closeMenu({player})
      end
    end
  end}

  return choices
end,
5.00})

-- store armor
local choice_store_armor = {function(player, choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    BMclient.getArmour(player,{},function(armour)
      if armour > 95 then
        vRP.giveInventoryItem({user_id, "body_armor", 1, true})
        -- clear armor
	    BMclient.setArmour(player,{0,false})
	  else
	    vRPclient.notify(player, {"~r~Coletes danificados não podem ser armazenados!"})
      end
    end)
  end
end, "Guardar Colete no inventário."}

local unjailed = {}
function jail_clock(target_id,timer)
  local target = vRP.getUserSource({tonumber(target_id)})
  local users = vRP.getUsers({})
  local online = false
  for k,v in pairs(users) do
	if tonumber(k) == tonumber(target_id) then
	  online = true
	end
  end
  if online then
    if timer>0 then
	  vRPclient.notify(target, {"~r~Tempo restante: " .. timer .. " minuto(s)."})
      vRP.setUData({tonumber(target_id),"vRP:jail:time",json.encode(timer)})
	  SetTimeout(60*1000, function()
		for k,v in pairs(unjailed) do -- check if player has been unjailed by cop or admin
		  if v == tonumber(target_id) then
	        unjailed[v] = nil
		    timer = 0
		  end
		end
		vRP.setHunger({tonumber(target_id), 0})
		vRP.setThirst({tonumber(target_id), 0})
	    jail_clock(tonumber(target_id),timer-1)
	  end) 
    else 
	  BMclient.loadFreeze(target,{false,true,true})
	  SetTimeout(15000,function()
		BMclient.loadFreeze(target,{false,false,false})
	  end)
	  vRPclient.teleport(target,{425.7607421875,-978.73425292969,30.709615707397}) -- teleport to outside jail
	  vRPclient.setHandcuffed(target,{false})
      vRPclient.notify(target,{"~b~Você foi liberado."})
	  vRP.setUData({tonumber(target_id),"vRP:jail:time",json.encode(-1)})
    end
  end
end

-- dynamic jail
local ch_jail = {function(player,choice) 
  vRPclient.getNearestPlayers(player,{15},function(nplayers) 
	local user_list = ""
    for k,v in pairs(nplayers) do
	  user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
    end 
	if user_list ~= "" then
	  vRP.prompt({player,"Jogadores perto:" .. user_list,"",function(player,target_id) 
	    if target_id ~= nil and target_id ~= "" then 
	      vRP.prompt({player,"Tempo de prisão em minutos:","1",function(player,jail_time)
			if jail_time ~= nil and jail_time ~= "" then 
	          local target = vRP.getUserSource({tonumber(target_id)})
			  if target ~= nil then
		        if tonumber(jail_time) > 60 then
  			      jail_time = 60
		        end
		        if tonumber(jail_time) < 1 then
		          jail_time = 1
		        end
		  
                vRPclient.isHandcuffed(target,{}, function(handcuffed)  
                  if handcuffed then 
					BMclient.loadFreeze(target,{false,true,true})
					SetTimeout(15000,function()
					  BMclient.loadFreeze(target,{false,false,false})
					end)
				    vRPclient.teleport(target,{1641.5477294922,2570.4819335938,45.564788818359}) -- teleport to inside jail
				    vRPclient.notify(target,{"~r~Você foi enviado para a prisão."})
				    vRPclient.notify(player,{"~b~Você enviou um jogador para a prisão."})
				    vRP.setHunger({tonumber(target_id),0})
				    vRP.setThirst({tonumber(target_id),0})
				    jail_clock(tonumber(target_id),tonumber(jail_time))
					local user_id = vRP.getUserId({player})
					vRPbm.logInfoToFile("jailLog.txt",user_id .. " jailed "..target_id.." for " .. jail_time .. " minutes")
			      else
				    vRPclient.notify(player,{"~r~Esse jogador não está algemado."})
			      end
			    end)
			  else
				vRPclient.notify(player,{"~r~Essa ID parece inválida."})
			  end
			else
			  vRPclient.notify(player,{"~r~O tempo de prisão não pode estar vazia."})
			end
	      end})
        else
          vRPclient.notify(player,{"~r~Nenhum ID de jogador selecionado."})
        end 
	  end})
    else
      vRPclient.notify(player,{"~r~Nenhum jogador próximo."})
    end 
  end)
end,"Envie um jogador próximo para a prisão."}

-- dynamic unjail
local ch_unjail = {function(player,choice) 
	vRP.prompt({player,"Player ID:","",function(player,target_id) 
	  if target_id ~= nil and target_id ~= "" then 
		vRP.getUData({tonumber(target_id),"vRP:jail:time",function(value)
		  if value ~= nil then
		  custom = json.decode(value)
			if custom ~= nil then
			  local user_id = vRP.getUserId({player})
			  if tonumber(custom) > 0 or vRP.hasPermission({user_id,"admin.easy_unjail"}) then
	            local target = vRP.getUserSource({tonumber(target_id)})
				if target ~= nil then
	              unjailed[target] = tonumber(target_id)
				  vRPclient.notify(player,{"~g~Target será lançado em breve."})
				  vRPclient.notify(target,{"~g~Alguém abaixou sua sentença."})
				  vRPbm.logInfoToFile("jailLog.txt",user_id .. " libertado "..target_id.." de uma sentença de " .. custom .. " minutos.")
				else
				  vRPclient.notify(player,{"~r~Essa ID parece inválida."})
				end
			  else
				vRPclient.notify(player,{"~r~O alvo não está preso."})
			  end
			end
		  end
		end})
      else
        vRPclient.notify(player,{"~r~Nenhum ID de jogador selecionado."})
      end 
	end})
end,"Libera um jogador preso."}

-- (server) called when a logged player spawn to check for vRP:jail in user_data
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn) 
  local target = vRP.getUserSource({user_id})
  SetTimeout(35000,function()
    local custom = {}
    vRP.getUData({user_id,"vRP:jail:time",function(value)
	  if value ~= nil then
	    custom = json.decode(value)
	    if custom ~= nil then
		  if tonumber(custom) > 0 then
			BMclient.loadFreeze(target,{false,true,true})
			SetTimeout(15000,function()
			  BMclient.loadFreeze(target,{false,false,false})
			end)
            vRPclient.setHandcuffed(target,{true})
            vRPclient.teleport(target,{1641.5477294922,2570.4819335938,45.564788818359}) -- teleport inside jail
            vRPclient.notify(target,{"~r~Pague sua sentença."})
			vRP.setHunger({tonumber(user_id),0})
			vRP.setThirst({tonumber(user_id),0})
			vRPbm.logInfoToFile("jailLog.txt",user_id.." foi mandado para a prisão por " .. custom .. " para pagar sua sentença.")
		    jail_clock(tonumber(user_id),tonumber(custom))
		  end
	    end
	  end
	end})
  end)
end)

-- dynamic fine
local ch_fine = {function(player,choice) 
  vRPclient.getNearestPlayers(player,{15},function(nplayers) 
	local user_list = ""
    for k,v in pairs(nplayers) do
	  user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
    end 
	if user_list ~= "" then
	  vRP.prompt({player,"Jogadores perto:" .. user_list,"",function(player,target_id) 
	    if target_id ~= nil and target_id ~= "" then 
	      vRP.prompt({player,"Preço da Multa:","100",function(player,fine)
			if fine ~= nil and fine ~= "" then 
	          vRP.prompt({player,"Motivo da Multa:","",function(player,reason)
			    if reason ~= nil and reason ~= "" then 
	              local target = vRP.getUserSource({tonumber(target_id)})
				  if target ~= nil then
		            if tonumber(fine) > 100000 then
  			          fine = 100000
		            end
		            if tonumber(fine) < 100 then
		              fine = 100
		            end
			  
		            if vRP.tryFullPayment({tonumber(target_id), tonumber(fine)}) then
                      vRP.insertPoliceRecord({tonumber(target_id), lang.police.menu.fine.record({reason,fine})})
                      vRPclient.notify(player,{lang.police.menu.fine.fined({reason,fine})})
                      vRPclient.notify(target,{lang.police.menu.fine.notify_fined({reason,fine})})
					  local user_id = vRP.getUserId({player})
					  vRPbm.logInfoToFile("fineLog.txt",user_id .. " multado "..target_id.." no preço de " .. fine .. " por ".. reason)
                      vRP.closeMenu({player})
                    else
                      vRPclient.notify(player,{lang.money.not_enough()})
                    end
				  else
					vRPclient.notify(player,{"~r~Essa ID parece inválida."})
				  end
				else
				  vRPclient.notify(player,{"~r~Você não pode prender sem um motivo."})
				end
	          end})
			else
			  vRPclient.notify(player,{"~r~Sua multa tem que ter um valor."})
			end
	      end})
        else
          vRPclient.notify(player,{"~r~Nenhum ID de jogador selecionado."})
        end 
	  end})
    else
      vRPclient.notify(player,{"~r~Nenhum jogador nas proximidades."})
    end 
  end)
end,"Multar um jogador próximo."}

-- improved handcuff
local ch_handcuff = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId({nplayer})
    if nuser_id ~= nil then
      vRPclient.toggleHandcuff(nplayer,{})
	  local user_id = vRP.getUserId({player})
	  vRPbm.logInfoToFile("jailLog.txt",user_id .. " cuffed "..nuser_id)
      vRP.closeMenu({nplayer})
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.handcuff.description()}

-- admin god mode
local gods = {}
function task_god()
  SetTimeout(10000, task_god)

  for k,v in pairs(gods) do
    vRP.setHunger({v, 0})
    vRP.setThirst({v, 0})

    local player = vRP.getUserSource({v})
    if player ~= nil then
      vRPclient.setHealth(player, {200})
    end
  end
end
task_god()

local ch_godmode = {function(player,choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    if gods[player] then
	  gods[player] = nil
	  vRPclient.notify(player,{"~r~Godmode desativado."})
	else
	  gods[player] = user_id
	  vRPclient.notify(player,{"~g~Godmode ativado."})
	end
  end
end, "Ativa o admin godmode."}

function vRPbm.chargePhoneNumber(user_id,phone)
  local player = vRP.getUserSource({user_id})
  local directory_name = vRP.getPhoneDirectoryName({user_id, phone})
  if directory_name == "unknown" then
	directory_name = phone
  end
  vRP.prompt({player,"Valor a ser cobrado "..directory_name..":","0",function(player,charge)
	if charge ~= nil and charge ~= "" and tonumber(charge)>0 then 
	  vRP.getUserByPhone({phone, function(target_id)
		if target_id~=nil then
			if charge ~= nil and charge ~= "" then 
	          local target = vRP.getUserSource({target_id})
			  if target ~= nil then
				vRP.getUserIdentity({user_id, function(identity)
				  local my_directory_name = vRP.getPhoneDirectoryName({target_id, identity.phone})
				  if my_directory_name == "unknown" then
				    my_directory_name = identity.phone
				  end
			      local text = "~b~" .. my_directory_name .. "~w~ está cobrando você ~r~$" .. charge .. "~w~ por seus serviços."
				  vRP.request({target,text,600,function(req_player,ok)
				    if ok then
					  local target_bank = vRP.getBankMoney({target_id}) - tonumber(charge)
					  local my_bank = vRP.getBankMoney({user_id}) + tonumber(charge)
		              if target_bank>0 then
					    vRP.setBankMoney({user_id,my_bank})
					    vRP.setBankMoney({target_id,target_bank})
					    vRPclient.notify(player,{"Você cobrou ~y~$"..charge.." ~w~de ~b~"..directory_name .."~w~ pelos seus serviços."})
						vRPclient.notify(target,{"~b~"..my_directory_name.."~w~ cobrou você ~r~$"..charge.."~w~ por seus serviços."})
					    --vRPbm.logInfoToFile("mchargeLog.txt",user_id .. " mobile charged "..target_id.." the amount of " .. charge .. ", user bank post-payment for "..user_id.." equals $"..my_bank.." and for "..user_id.." equals $"..target_bank)
					    vRP.closeMenu({player})
                      else
                        vRPclient.notify(target,{lang.money.not_enough()})
                        vRPclient.notify(player,{"~b~" .. directory_name .. "~w~ tentou, mas~r~ não pode~w~ pagar por seus serviços."})
                      end
				    else
                      vRPclient.notify(player,{"~b~" .. directory_name .. "~r~ recusou-se~w~ a pagar pelos seus serviços."})
				    end
				  end})
				end})
			  else
			    vRPclient.notify(player,{"~r~Você não pode fazer cobranças para jogadores off-line."})
			  end
			else
			  vRPclient.notify(player,{"~r~Sua cobrança deve ter um valor."})
			end
		else
		  vRPclient.notify(player,{"~r~Esse número de telefone parece inválido."})
		end
	  end})
	else
	  vRPclient.notify(player,{"~r~O valor deve ser maior do que 0."})
	end
  end})
end

function vRPbm.payPhoneNumber(user_id,phone)
  local player = vRP.getUserSource({user_id})
  local directory_name = vRP.getPhoneDirectoryName({user_id, phone})
  if directory_name == "unknown" then
	directory_name = phone
  end
  vRP.prompt({player,"Quantidade a ser enviada para "..directory_name..":","0",function(player,transfer)
	if transfer ~= nil and transfer ~= "" and tonumber(transfer)>0 then 
	  vRP.getUserByPhone({phone, function(target_id)
	    local my_bank = vRP.getBankMoney({user_id}) - tonumber(transfer)
		if target_id~=nil then
          if my_bank >= 0 then
		    local target = vRP.getUserSource({target_id})
			if target ~= nil then
			  vRP.setBankMoney({user_id,my_bank})
              vRPclient.notify(player,{"~g~Você transferiu ~r~$"..transfer.." ~g~para ~b~"..directory_name})
			  local target_bank = vRP.getBankMoney({target_id}) + tonumber(transfer)
			  vRP.setBankMoney({target_id,target_bank})
			  vRPbm.logInfoToFile("mpayLog.txt",user_id .. " pagou por telefone "..target_id.." a quantidade de " .. transfer .. ", pagamento do banco do usuário para "..user_id.." é igual a $"..my_bank.." e para "..user_id.." é igual a $"..target_bank)
			  vRP.getUserIdentity({user_id, function(identity)
		        local my_directory_name = vRP.getPhoneDirectoryName({target_id, identity.phone})
			    if my_directory_name == "unknown" then
		          my_directory_name = identity.phone
			    end
                vRPclient.notify(target,{"~g~Você recebeu ~y~$"..transfer.." ~g~de ~b~"..my_directory_name})
			  end})
              vRP.closeMenu({player})
			else
			  vRPclient.notify(player,{"~r~Você não pode fazer pagamentos para jogadores off-line."})
			end
          else
            vRPclient.notify(player,{lang.money.not_enough()})
          end
		else
		  vRPclient.notify(player,{"~r~Esse número de telefone parece ser inválido."})
		end
	  end})
	else
	  vRPclient.notify(player,{"~r~O valor deve ser maior do que 0."})
	end
  end})
end

-- mobilepay
local ch_mobilepay = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	local menu = {}
	menu.name = lang.phone.directory.title()
	menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu
	menu[">Type Number"] = {
	  -- payment function
	  function(player,choice) 
	    vRP.prompt({player,"Número de telefone:","000-0000",function(player,phone)
	      if phone ~= nil and phone ~= "" then 
		    vRPbm.payPhoneNumber(user_id,phone)
		  else
		    vRPclient.notify(player,{"~r~Você precisa digitar um número de telefone."})
		  end
	    end})
	  end,"Digite o número de telefone manualmente."}
	local directory = vRP.getPhoneDirectory({user_id})
	for k,v in pairs(directory) do
	  menu[k] = {
	    -- payment function
	    function(player,choice) 
		  vRPbm.payPhoneNumber(user_id,v)
	    end
	  ,v} -- number as description
	end
	vRP.openMenu({player, menu})
end,"Transferir dinheiro através do telefone."}

-- mobilecharge
local ch_mobilecharge = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	local menu = {}
	menu.name = lang.phone.directory.title()
	menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu
	menu[">Type Number"] = {
	  -- payment function
	  function(player,choice) 
	    vRP.prompt({player,"Número de telefone:","000-0000",function(player,phone)
	      if phone ~= nil and phone ~= "" then 
		    vRPbm.chargePhoneNumber(user_id,phone)
		  else
		    vRPclient.notify(player,{"~r~Você precisa digitar um número de telefone."})
		  end
	    end})
	  end,"Digite o número de telefone manualmente."}
	local directory = vRP.getPhoneDirectory({user_id})
	for k,v in pairs(directory) do
	  menu[k] = {
	    -- payment function
	    function(player,choice) 
		  vRPbm.chargePhoneNumber(user_id,v)
	    end
	  ,v} -- number as description
	end
	vRP.openMenu({player, menu})
end,"Cobrar dinheiro pelo telefone."}

-- spawn vehicle
local ch_spawnveh = {function(player,choice) 
	vRP.prompt({player,"Vehicle Model:","",function(player,model)
	  if model ~= nil and model ~= "" then 
	    BMclient.spawnVehicle(player,{model})
	  else
		vRPclient.notify(player,{"~r~You have to type a vehicle model."})
	  end
	end})
end,"Spawnar um modelo de veículo."}

-- lockpick vehicle
local ch_lockpickveh = {function(player,choice) 
	BMclient.lockpickVehicle(player,{20,true}) -- 20s to lockpick, allow to carjack unlocked vehicles (has to be true for NoCarJack Compatibility)
end,"Usar chave mestra no veículo mais próximo."}

-- dynamic freeze
local ch_freeze = {function(player,choice) 
	local user_id = vRP.getUserId({player})
	if vRP.hasPermission({user_id,"admin.bm_freeze"}) then
	  vRP.prompt({player,"Player ID:","",function(player,target_id) 
	    if target_id ~= nil and target_id ~= "" then 
	      local target = vRP.getUserSource({tonumber(target_id)})
		  if target ~= nil then
		    vRPclient.notify(player,{"~g~Você descongelou esse player."})
		    BMclient.loadFreeze(target,{true,true,true})
		  else
		    vRPclient.notify(player,{"~r~Essa ID parece inválida."})
		  end
        else
          vRPclient.notify(player,{"~r~Nenhuma ID de player selecionada."})
        end 
	  end})
	else
	  vRPclient.getNearestPlayer(player,{10},function(nplayer)
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
		  vRPclient.notify(player,{"~g~Você descongelou esse player."})
		  BMclient.loadFreeze(nplayer,{true,false,false})
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      end)
	end
end,"Congelar player."}

-- lockpicking item
vRP.defInventoryItem({"lockpicking_kit","Chave mestra","Usado para destrancar veículos.", -- add it for sale to vrp/cfg/markets.lua if you want to use it
function(args)
  local choices = {}

  choices["Lockpick"] = {function(player,choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
      if vRP.tryGetInventoryItem({user_id, "lockpicking_kit", 1, true}) then
		BMclient.lockpickVehicle(player,{20,true}) -- 20s to lockpick, allow to carjack unlocked vehicles (has to be true for NoCarJack Compatibility)
        vRP.closeMenu({player})
      end
    end
  end,"Usar chave mestra no veículo mais próximo."}

  return choices
end,
5.00})

-- ADD STATIC MENU CHOICES // STATIC MENUS NEED TO BE ADDED AT vRP/cfg/gui.lua
vRP.addStaticMenuChoices({"pm_weapons", pm_weapons}) -- police gear
vRP.addStaticMenuChoices({"pcesp_weapons", pcesp_weapons}) -- police gear
vRP.addStaticMenuChoices({"grpae_weapons", grpae_weapons}) -- police gear
vRP.addStaticMenuChoices({"rota_weapons", rota_weapons}) -- police gear
vRP.addStaticMenuChoices({"emergency_medkit", emergency_medkit}) -- pills and medkits
vRP.addStaticMenuChoices({"emergency_heal", emergency_heal}) -- heal button

-- REMEMBER TO ADD THE PERMISSIONS FOR WHAT YOU WANT TO USE
-- CREATES PLAYER SUBMENU AND ADD CHOICES
local ch_player_menu = {function(player,choice)
	local user_id = vRP.getUserId({player})
	local menu = {}
	menu.name = "Player"
	menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu
	
    if vRP.hasPermission({user_id,"player.store_money"}) then
      menu["Guardar Dinheiro"] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
    end
	
    if vRP.hasPermission({user_id,"player.fix_haircut"}) then
      menu["Desbugar Rosto"] = ch_fixhair -- just a work around for barbershop green hair bug while I am busy
    end
	
    if vRP.hasPermission({user_id,"player.userlist"}) then
      menu["Lista de players"] = ch_userlist -- a user list for players with vRP ids, player name and identity names only.
    end
	
    if vRP.hasPermission({user_id,"player.store_weapons"}) then
      menu["🔫Armas para inventário"] = choice_store_weapons -- store player weapons, like police store weapons from vrp
    end
	
    if vRP.hasPermission({user_id,"player.store_armor"}) then
      menu["Guardar Colete"] = choice_store_armor -- store player armor
    end
	
    if vRP.hasPermission({user_id,"player.check"}) then
      menu["Revistar"] = choice_player_check -- checks nearest player inventory, like police check from vrp
    end
	
	vRP.openMenu({player, menu})
end}

-- REGISTER MAIN MENU CHOICES
vRP.registerMenuBuilder({"main", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.hasPermission({user_id,"player.player_menu"}) then
      choices["🤴Player"] = ch_player_menu -- opens player submenu
    end
	
    if vRP.hasPermission({user_id,"toggle.service"}) then
      choices["Serviços"] = choice_service -- toggle the receiving of missions
    end
	
    if vRP.hasPermission({user_id,"player.loot"}) then
      choices["💰Loot"] = choice_loot -- take the items of nearest player in coma
    end
	
    if vRP.hasPermission({user_id,"mugger.mug"}) then
      choices["Assaltar"] = ch_mug -- steal nearest player wallet
    end
	
    if vRP.hasPermission({user_id,"hacker.hack"}) then
      choices["Hackear"] = ch_hack --  1 in 100 chance of stealing 1% of nearest player bank
    end
	
    if vRP.hasPermission({user_id,"carjacker.lockpick"}) then
      choices["Chave mestra"] = ch_lockpickveh -- opens a locked vehicle
    end
	
    add(choices)
  end
end})

-- RESGISTER ADMIN MENU CHOICES
vRP.registerMenuBuilder({"admin", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
	if vRP.hasPermission({user_id,"admin.deleteveh"}) then
      choices["@DeleteVeh"] = ch_deleteveh -- Delete nearest vehicle (Fixed pull request https://github.com/Sighmir/vrp_basic_menu/pull/11/files/419405349ca0ad2a215df90cfcf656e7aa0f5e9c from benjatw)
	end
	
	if vRP.hasPermission({user_id,"admin.spawnveh"}) then
      choices["@SpawnVeh"] = ch_spawnveh -- Spawn a vehicle model
	end
	
	if vRP.hasPermission({user_id,"admin.godmode"}) then
      choices["@Godmode"] = ch_godmode -- Toggles admin godmode (Disable the default admin.god permission to use this!) 
	end
	
    if vRP.hasPermission({user_id,"player.blips"}) then
      choices["@Blips"] = ch_blips -- turn on map blips and sprites
    end
	
    if vRP.hasPermission({user_id,"player.sprites"}) then
      choices["@Sprites"] = ch_sprites -- turn on only name sprites
    end
	
    if vRP.hasPermission({user_id,"admin.crun"}) then
      choices["@Crun"] = ch_crun -- run any client command, any GTA V client native http://www.dev-c.com/nativedb/
    end
	
    if vRP.hasPermission({user_id,"admin.srun"}) then
      choices["@Srun"] = ch_srun -- run any server command, any GTA V server native http://www.dev-c.com/nativedb/
    end

	if vRP.hasPermission({user_id,"player.tptowaypoint"}) then
      choices["@TpToWaypoint"] = choice_tptowaypoint -- teleport user to map blip
	end
	
	if vRP.hasPermission({user_id,"admin.easy_unjail"}) then
      choices["@UnJail"] = ch_unjail -- Un jails chosen player if he is jailed (Use admin.easy_unjail as permission to have this in admin menu working in non jailed players)
    end
	
	if vRP.hasPermission({user_id,"admin.spikes"}) then
      choices["@Spikes"] = ch_spikes -- Toggle spikes
    end
	
	if vRP.hasPermission({user_id,"admin.bm_freeze"}) then
      choices["@Freeze"] = ch_freeze -- Toggle freeze
    end
	
    add(choices)
  end
end})

-- REGISTER POLICE MENU CHOICES
vRP.registerMenuBuilder({"police", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.hasPermission({user_id,"police.store_money"}) then
      choices["Guardar Dinheiro"] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
    end
	
	if vRP.hasPermission({user_id,"police.easy_jail"}) then
      choices["Prender Por Tempo"] = ch_jail -- Send a nearby handcuffed player to jail with prompt for choice and user_list
    end
	
	if vRP.hasPermission({user_id,"police.easy_unjail"}) then
      choices["Tirar da prisão"] = ch_unjail -- Un jails chosen player if he is jailed (Use admin.easy_unjail as permission to have this in admin menu working in non jailed players)
    end
	
	if vRP.hasPermission({user_id,"police.easy_fine"}) then
      choices["Multar Fácil"] = ch_fine -- Fines closeby player
    end
	
	if vRP.hasPermission({user_id,"police.easy_cuff"}) then
      choices["Algemar"] = ch_handcuff -- Toggle cuffs AND CLOSE MENU for nearby player
    end
	
	if vRP.hasPermission({user_id,"police.spikes"}) then
      choices["Spikes"] = ch_spikes -- Toggle spikes
    end
	
    if vRP.hasPermission({user_id,"police.drag"}) then
      choices["Arrastar"] = ch_drag -- Drags closest handcuffed player
    end
	
	if vRP.hasPermission({user_id,"police.bm_freeze"}) then
      choices["Congelar"] = ch_freeze -- Toggle freeze
    end
	
    add(choices)
  end
end})

-- REGISTER PHONE MENU CHOICES
-- TO USE THIS FUNCTION YOU NEED TO HAVE THE ORIGINAL vRP UPDATED TO THE LASTEST VERSION
vRP.registerMenuBuilder({"phone", function(add) -- phone menu is created on server start, so it has no permissions.
    local choices = {} -- Comment the choices you want to disable by adding -- in front of them.
	
    choices["📲MPagar p/Telefone"] = ch_mobilepay -- transfer money through phone
    choices["📲MCobrar p/Telefone"] = ch_mobilecharge -- charge money through phone
	
    add(choices)
end})