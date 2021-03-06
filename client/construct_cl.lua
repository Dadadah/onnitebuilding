--[[
Copyright (C) 2020  Jacob Schlecht

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.]]--

local constructionActivated = false
local curstruct = 1
local currotyaw = 0
local remove_obj = false
local swaplayout = false

local my_shadow = 0

local constructionOffsetCache = {}

-- Constants
local ACTIVATE_CONSTRUCTION_KEY = "Y"
local ACTIVATE_REMOVE_MODE_KEY = "E"
local ROTATE_KEY = "R"

function OnKeyPress(key)
	if IsPlayerDead() or IsPlayerInVehicle() then
		if constructionActivated and not remove_obj then CallRemoteEvent("RemoveShadow") end
		constructionActivated = false
		remove_obj = false
		my_shadow = 0
		return
	end
	if key == ACTIVATE_CONSTRUCTION_KEY then
		constructionActivated = not constructionActivated
		if (constructionActivated == false) then
			CallRemoteEvent("RemoveShadow")
			remove_obj = false
			my_shadow = 0
		else
			CallRemoteEvent("UpdateCons", curstruct)
		end
	end
	if constructionActivated then
		if key == ACTIVATE_REMOVE_MODE_KEY then
			remove_obj = not remove_obj
			local actor = GetObjectActor(my_shadow)
			if remove_obj and actor ~= false then
				actor:SetActorHiddenInGame(true)
			else
				actor:SetActorHiddenInGame(false)
			end
		end
		if key == "Left Mouse Button" then
			local _, entityId = GetAimPosHitEntity(2000)
			if not remove_obj then
				local x, y, z = GetAimPosHitLocation(2000)
				if x then
					-- Distance Check
					local xply, yply, zply = GetPlayerLocation()
					if GetDistance3D(x, y, z, xply, yply, zply) < 2000 then
						local entConID = GetObjectPropertyValue(entityId, CONSTRUCTION_ID_PROPERTY_NAME)
						local xpos, ypos, zpos, pitch, yaw, roll = getConstructOffset(curstruct)
						if entConID ~= nil and GetObjectPropertyValue(entityId, OWNER_PROPERTY_NAME) == GetPlayerId() then
							x, y, z = GetObjectLocation(entityId)
							local xsub, ysub, zsub = getConstructOffset(entConID, curstruct)
							xpos = xpos + xsub
							ypos = ypos + ysub
							zpos = zpos - zsub
						end
						-- Uncomment to get size of a new object
						-- local xsize, ysize, zsize = GetObjectSize(my_shadow)
						-- AddPlayerChat("size x: " .. xsize .. " y: " .. ysize .. " z: " .. zsize)
						CallRemoteEvent("Createcons", x + xpos, y + ypos, z + zpos, 0 + pitch, currotyaw + yaw, 0 + roll)
						CallRemoteEvent("UpdateCons", curstruct)

						-- We should probably let them know that roofs don't work like they think they do.
						if curstruct == 2 then
							AddPlayerChat("Don't forget to place a floor on top of your roof")
						end
					else
						AddPlayerChat("That's too far away")
					end
				else
					AddPlayerChat("Invalid location")
				end
			else
				if (entityId ~= 0) then
					CallRemoteEvent("Removeobj", entityId)
				end
			end
		end
		if not remove_obj then
			if key == "Mouse Wheel Up" then
				curstruct = curstruct + 1
				curstruct = ((curstruct - 1) % #CONSTRUCTION_OBJECTS) + 1
				CallRemoteEvent("UpdateCons", curstruct)
				my_shadow = 0
			end
			if key == "Mouse Wheel Down" then
				curstruct = curstruct - 1
				curstruct = ((curstruct - 1) % #CONSTRUCTION_OBJECTS) + 1
				CallRemoteEvent("UpdateCons", curstruct)
				my_shadow = 0
			end
			if key == ROTATE_KEY then
				currotyaw = currotyaw + 90
				currotyaw = currotyaw % 360
			end
		end
	end
end
AddEvent("OnKeyPress", OnKeyPress)

function tickhook(DeltaSeconds)
	if (constructionActivated) and (not remove_obj) and (my_shadow ~= 0) and (not IsPlayerInMainMenu()) then
		local actor = GetObjectActor(my_shadow)
		if not actor then return end
		local x, y, z = GetAimPosHitLocation(2000)
		if x then
			-- Distance Check
			local xply, yply, zply = GetPlayerLocation()
			if GetDistance3D(x, y, z, xply, yply, zply) < 2000 then
				local hittype, entityId = GetAimPosHitEntity(2000)
				if hittype then
					local entConID = GetObjectPropertyValue(entityId, CONSTRUCTION_ID_PROPERTY_NAME)
					local xpos, ypos, zpos, pitch, yaw, roll = getConstructOffset(curstruct)
					if entConID ~= nil and GetObjectPropertyValue(entityId, OWNER_PROPERTY_NAME) == GetPlayerId() then
						x, y, z = GetObjectLocation(entityId)
						local xsub, ysub, zsub = getConstructOffset(entConID, curstruct)
						xpos = xpos + xsub
						ypos = ypos + ysub
						zpos = zpos - zsub
					end
					actor:SetActorHiddenInGame(false)
					actor:SetActorLocation(FVector(x + xpos, y + ypos, z + zpos))
					actor:SetActorRotation(FRotator(0 + pitch, currotyaw + yaw,	0 + roll))
				end
			else
				actor:SetActorHiddenInGame(true)
			end
		end
	end
end
AddEvent("OnGameTick", tickhook)

function getConstructOffset(constructID, stackID)
	local indexName = constructID .. "_" .. currotyaw
	if stackID ~= nil then
		indexName = constructID .. "_" .. stackID .. "_" .. currotyaw
	end
	if constructionOffsetCache[indexName] == nil then
		local yawcos = math.cos(math.rad(currotyaw))
		local yawsin = math.sin(math.rad(currotyaw))
		local xxoff = CONSTRUCTION_OBJECTS[constructID].RelativeOffset[1] * yawcos
		local yxoff = CONSTRUCTION_OBJECTS[constructID].RelativeOffset[1] * yawsin
		local xyoff = CONSTRUCTION_OBJECTS[constructID].RelativeOffset[2] * yawcos
		local yyoff = CONSTRUCTION_OBJECTS[constructID].RelativeOffset[2] * yawsin
		local xxselfoff = 0
		local yxselfoff = 0
		local xyselfoff = 0
		local yyselfoff = 0
		local zselfoff = 0
		local xglobaloff = CONSTRUCTION_OBJECTS[constructID].GlobalOffset[1] * yawsin
		local yglobaloff = CONSTRUCTION_OBJECTS[constructID].GlobalOffset[2] * yawcos
		local zglobaloff = CONSTRUCTION_OBJECTS[constructID].GlobalOffset[3]
		if stackID ~= nil and CONSTRUCTION_OBJECTS[stackID].IgnoreGlobalOffset ~= nil and CONSTRUCTION_OBJECTS[stackID].IgnoreGlobalOffset[constructID] then
			xglobaloff = -1 * xglobaloff
			yglobaloff = -1 * yglobaloff
			zglobaloff = 0
		end
		if stackID == constructID then
			xxselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[1] * yawcos
			yxselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[1] * yawsin
			xyselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[2] * yawcos
			yyselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[2] * yawsin
			zselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[3]
		end
		constructionOffsetCache[indexName] = {}
		constructionOffsetCache[indexName].xpos = xxoff + xyoff + xglobaloff + xxselfoff + xyselfoff
		constructionOffsetCache[indexName].ypos = yyoff + yxoff + yglobaloff + yyselfoff + yxselfoff
		constructionOffsetCache[indexName].zpos = CONSTRUCTION_OBJECTS[constructID].RelativeOffset[3] + zglobaloff - zselfoff
		constructionOffsetCache[indexName].pitch = CONSTRUCTION_OBJECTS[constructID].BaseRotation[1]
		constructionOffsetCache[indexName].yaw = CONSTRUCTION_OBJECTS[constructID].BaseRotation[2]
		constructionOffsetCache[indexName].roll = CONSTRUCTION_OBJECTS[constructID].BaseRotation[3]
	end
	return constructionOffsetCache[indexName].xpos, -- XPos
	constructionOffsetCache[indexName].ypos, -- YPos
	constructionOffsetCache[indexName].zpos, -- ZPos
	constructionOffsetCache[indexName].pitch, -- Pitch
	constructionOffsetCache[indexName].yaw, -- Yaw
	constructionOffsetCache[indexName].roll -- Roll
end

function GhostNewObject(object)
	if GetObjectPropertyValue(object, GHOSTED_PROPERTY_NAME) == true then
		if GetObjectPropertyValue(object, OWNER_PROPERTY_NAME) ~= GetPlayerId() then
			GetObjectActor(object):SetActorHiddenInGame(true)
		else
			my_shadow = object
			GetObjectStaticMeshComponent(my_shadow):SetMobility(EComponentMobility.Movable)
		end
		GetObjectActor(object):SetActorEnableCollision(false)
		SetObjectCastShadow(object, false)
		EnableObjectHitEvents(object, false)
	end
end
AddEvent("OnObjectStreamIn", GhostNewObject)

function GhostObject(object, prop, val)
	if prop == GHOSTED_PROPERTY_NAME then
		if GetObjectPropertyValue(object, OWNER_PROPERTY_NAME) ~= GetPlayerId() then
			GetObjectActor(object):SetActorHiddenInGame(val)
		elseif val then
			my_shadow = object
			GetObjectStaticMeshComponent(my_shadow):SetMobility(EComponentMobility.Movable)
		elseif not val then
			GetObjectStaticMeshComponent(my_shadow):SetMobility(EComponentMobility.Static)
			my_shadow = 0
		end
		GetObjectActor(object):SetActorEnableCollision(not val)
		SetObjectCastShadow(object, not val)
		EnableObjectHitEvents(object, not val)
	end
end
AddEvent("OnObjectNetworkUpdatePropertyValue", GhostObject)

function render_cons()
	SetDrawColor(RGBA(0, 0, 0, 255))
	SetTextDrawScale(1.25, 1.25)
	DrawText(5, 400, "Y - Toggle Construction")
	if constructionActivated then
		DrawText(5, 425, "E - Removal Mode")
		DrawText(5, 450, "R - Rotate 90 Degrees")
		DrawText(5, 475, "Mouse Wheel - Switch Construction")
		DrawText(5, 500, "Click - Place Construction")
		if remove_obj then
			local hittype, entityId = GetAimPosHitEntity(2000)
			if hittype and entityId ~= 0 and GetObjectPropertyValue(entityId, CONSTRUCTION_ID_PROPERTY_NAME) ~= nil then
				local x, y, z = GetObjectLocation(entityId)
				local bResult, ScreenX, ScreenY = WorldToScreen(x, y, z)
				if bResult then
					DrawText(ScreenX - 40, ScreenY, "Left Click to remove")
				end
			end
		end
	end
end
AddEvent("OnRenderHUD", render_cons)

--[[
This function will get the aim pos hit location of the local player.

When the aimpos hits air at distanceFromPlayer then this function will return false.

We must do two line traces if the first hits the local player. I'm not sure if
this is a bug so we'll just workaround it.

If the player is looking down on themselves in first person I guess it won't
work but OH WELL /shrug
]]--
function GetAimPosHitLocation(distanceFromPlayer)
	if distanceFromPlayer == nil then distanceFromPlayer = 10000 end
	local ScreenX, ScreenY = GetScreenSize()
	local res, x, y, z = ScreenToWorld(ScreenX / 2, ScreenY/2)
	if not res then return false end
	local camx, camy, camz = GetCameraForwardVector()
	local endX = x + camx * distanceFromPlayer
	local endY = y + camy * distanceFromPlayer
	local endZ = z + camz * distanceFromPlayer
	local hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, z, endX, endY, endZ)
	-- Do another linetrace if we hit local player because linetrace hits local player for some reason
	if hittype == HIT_PLAYER and hitid == GetPlayerId() then
		x = impactX + camx * 50
		y = impactY + camy * 50
		z = impactZ + camz * 50
		local endX = x + camx * distanceFromPlayer
		local endY = y + camy * distanceFromPlayer
		local endZ = z + camz * distanceFromPlayer
		hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, z, endX, endY, endZ)
	end
	if hittype == HIT_AIR then return false end
	return impactX, impactY, impactZ
end

--[[
This function will get the aim pos hit entity of the local player.

When the aimpos hits air at distanceFromPlayer then this function will return false.

We must do two line traces if the first hits the local player. I'm not sure if
this is a bug so we'll just workaround it.

If the player is looking down on themselves in first person I guess it won't
work but OH WELL /shrug
]]--
function GetAimPosHitEntity()
	if distanceFromPlayer == nil then distanceFromPlayer = 10000 end
	local ScreenX, ScreenY = GetScreenSize()
	local res, x, y, z = ScreenToWorld(ScreenX / 2, ScreenY/2)
	if not res then return false end
	local camx, camy, camz = GetCameraForwardVector()
	local endX = x + camx * distanceFromPlayer
	local endY = y + camy * distanceFromPlayer
	local endZ = z + camz * distanceFromPlayer
	local hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, z, endX, endY, endZ)
	-- Do another linetrace if we hit local player because linetrace hits local player for some reason
	if hittype == HIT_PLAYER and hitid == GetPlayerId() then
		x = impactX + camx * 50
		y = impactY + camy * 50
		z = impactZ + camz * 50
		local endX = x + camx * distanceFromPlayer
		local endY = y + camy * distanceFromPlayer
		local endZ = z + camz * distanceFromPlayer
		hittype, hitid, impactX, impactY, impactZ = LineTrace(x, y, z, endX, endY, endZ)
	end
	if hittype == HIT_AIR then return false end
	return hittype, hitid
end
