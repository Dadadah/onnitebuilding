
local constructionActivated = false
local curstruct = 1
local currotyaw = 0
local remove_obj = false

local my_shadow = 0

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
    if (constructionActivated == true) then
    	if key == ACTIVATE_REMOVE_MODE_KEY then
            remove_obj = not remove_obj
            if remove_obj then
				GetObjectActor(my_shadow):SetActorHiddenInGame(true)
            else
				GetObjectActor(my_shadow):SetActorHiddenInGame(false)
			end
        end
	    if key == "Left Mouse Button" then
			local ScreenX, ScreenY = GetScreenSize()
			SetMouseLocation(ScreenX/2, ScreenY/2)
			local _, entityId = GetMouseHitEntity()
            if (remove_obj == false) then
				local x, y, z = GetMouseHitLocation()
				if (x ~= 0) then
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
				curstruct = curstruct + 1
				curstruct = (curstruct % #CONSTRUCTION_OBJECTS) + 1
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
		local ScreenX, ScreenY = GetScreenSize()
		SetMouseLocation(ScreenX/2, ScreenY/2)
		local x, y, z = GetMouseHitLocation()

		-- Distance Check
		local xply, yply, zply = GetPlayerLocation()
		if GetDistance3D(x, y, z, xply, yply, zply) < 2000
			local _, entityId = GetMouseHitEntity()
			local entConID = GetObjectPropertyValue(entityId, CONSTRUCTION_ID_PROPERTY_NAME)
			local xpos, ypos, zpos, pitch, yaw, roll = getConstructOffset(curstruct)
			if entConID ~= nil and GetObjectPropertyValue(entityId, OWNER_PROPERTY_NAME) == GetPlayerId() then
				x, y, z = GetObjectLocation(entityId)
				local xsub, ysub, zsub = getConstructOffset(entConID, curstruct)
				xpos = xpos + xsub
				ypos = ypos + ysub
				zpos = zpos - zsub
			end
			actor:SetActorLocation(FVector(x + xpos, y + ypos, z + zpos))
			actor:SetActorRotation(FRotator(0 + pitch, currotyaw + yaw,	0 + roll))
		end
	end
end
AddEvent("OnGameTick", tickhook)

function getConstructOffset(constructID, stackID)
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
	if stackID == constructID then
		xglobaloff = -1 * xglobaloff
		yglobaloff = -1 * yglobaloff
		zglobaloff = 0
		xxselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[1] * yawcos
		yxselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[1] * yawsin
		xyselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[2] * yawcos
		yyselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[2] * yawsin
		zselfoff = CONSTRUCTION_OBJECTS[constructID].SelfOffset[3]
	end
	return xxoff + xyoff + xglobaloff + xxselfoff + xyselfoff, -- XPos
	yyoff + yxoff + yglobaloff + yyselfoff + yxselfoff, -- YPos
	CONSTRUCTION_OBJECTS[constructID].RelativeOffset[3] + zglobaloff - zselfoff, -- ZPos
	CONSTRUCTION_OBJECTS[constructID].BaseRotation[1], -- Pitch
	CONSTRUCTION_OBJECTS[constructID].BaseRotation[2], -- Yaw
	CONSTRUCTION_OBJECTS[constructID].BaseRotation[3] -- Roll
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
    if constructionActivated then
		SetDrawColor(RGBA(0, 0, 0, 255))
		SetTextDrawScale(1, 1)
	    DrawText(5, 400, "Press Y to toggle construction")
	    DrawText(5, 425, "Press E to toggle remove constructions")
	    DrawText(5, 450, "Press R to rotate your construction")
	    DrawText(5, 475, "Use the mouse wheel to change your object")
	    DrawText(5, 500, "Use the left click to place your object")
	    if remove_obj then
	        local _, entityId = GetMouseHitEntity()
            if entityId ~= 0 and GetObjectPropertyValue(entityId, CONSTRUCTION_ID_PROPERTY_NAME) ~= nil then
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
