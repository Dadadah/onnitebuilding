
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
	    if key == "Left Mouse Button" then
            if (remove_obj == false) then
				local x, y, z = GetMouseHitLocation()
				if (x ~= 0) then
					local xpos, ypos, zpos, pitch, yaw, roll = getShadowPositionAndRotation()
					-- Uncomment to get size of a new object
					-- local xsize, ysize, zsize = GetObjectSize(my_shadow)
					-- AddPlayerChat("size x: " .. xsize .. " y: " .. ysize .. " z: " .. zsize)
	            	CallRemoteEvent("Createcons", x + xpos, y + ypos, z + zpos, 0 + pitch, currotyaw + yaw, 0 + roll)
					CallRemoteEvent("UpdateCons", curstruct)
				else
					AddPlayerChat("Please look at valid locations")
				end
            else
                local ScreenX, ScreenY = GetScreenSize()
                SetMouseLocation(ScreenX/2, ScreenY/2)
                local _, entityId = GetMouseHitEntity()
                if (entityId ~= 0) then
                	CallRemoteEvent("Removeobj", entityId)
                end
            end
	    end
	end
end
AddEvent("OnKeyPress", OnKeyPress)

function tickhook(DeltaSeconds)
    if constructionActivated then
		local ScreenX, ScreenY = GetScreenSize()
		SetMouseLocation(ScreenX/2, ScreenY/2)
		if not remove_obj then
			if my_shadow ~= 0 then
				local actor = GetObjectActor(my_shadow)
				if not actor then return end
				local x, y, z = GetMouseHitLocation()
				local xpos, ypos, zpos, pitch, yaw, roll = getShadowPositionAndRotation()
				actor:SetActorLocation(FVector(x + xpos, y + ypos, z + zpos))
				actor:SetActorRotation(FRotator(0 + pitch, currotyaw + yaw,	0 + roll))
			end
		end
	end
end
AddEvent("OnGameTick", tickhook)

function getShadowPositionAndRotation()
	local xxmid = CONSTRUCTION_OBJECTS[curstruct].Middle[1] * math.cos(math.rad(currotyaw))
	local yxmid = CONSTRUCTION_OBJECTS[curstruct].Middle[1] * math.sin(math.rad(currotyaw))
	local xymid = CONSTRUCTION_OBJECTS[curstruct].Middle[2] * math.cos(math.rad(currotyaw))
	local yymid = CONSTRUCTION_OBJECTS[curstruct].Middle[2] * math.sin(math.rad(currotyaw))
	return CONSTRUCTION_OBJECTS[curstruct].Offset[1] + xxmid + xymid, -- XPos
	CONSTRUCTION_OBJECTS[curstruct].Offset[2] + yxmid + yymid, -- YPos
	CONSTRUCTION_OBJECTS[curstruct].Offset[3] + CONSTRUCTION_OBJECTS[curstruct].Middle[3], -- ZPos
	CONSTRUCTION_OBJECTS[curstruct].BaseRotation[1], -- Pitch
	CONSTRUCTION_OBJECTS[curstruct].BaseRotation[2], -- Yaw
	CONSTRUCTION_OBJECTS[curstruct].BaseRotation[3] -- Roll
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
	        local entityType, entityId = GetMouseHitEntity()
            if (entityId ~= 0) then
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
