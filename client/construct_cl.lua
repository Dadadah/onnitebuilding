
local constructionActivated = false
local curstruct = 1
local currotyaw = 0
local remove_obj = false

local my_shadow = 0

-- Constants
local GHOSTED_PROPERTY_NAME = GetPackageName() .. "::ghosted"
local OWNER_PROPERTY_NAME = GetPackageName() .. "::owner"
local ACTIVATE_CONSTRUCTION_KEY = "Y"
local ACTIVATE_REMOVE_MODE_KEY = "E"
local ROTATE_KEY = "R"

function OnKeyPress(key)
	if key == ACTIVATE_CONSTRUCTION_KEY then
        constructionActivated = not constructionActivated
        if (constructionActivated == false) then
            CallRemoteEvent("RemoveShadow")
        else
			CallRemoteEvent("UpdateCons", curstruct)
		end
    end
    if (constructionActivated == true) then
    	if key == ACTIVATE_REMOVE_MODE_KEY then
            remove_obj = not remove_obj
            if remove_obj then
        		CallRemoteEvent("RemoveShadow")
            end
        end
	    if key == "Mouse Wheel Up" then
			curstruct = curstruct + 1
	        curstruct = ((curstruct - 1) % #CONSTRUCTION_OBJECTS) + 1
			CallRemoteEvent("UpdateCons", curstruct)
	    end
	    if key == "Mouse Wheel Down" then
			curstruct = curstruct + 1
			curstruct = (curstruct % #CONSTRUCTION_OBJECTS) + 1
			CallRemoteEvent("UpdateCons", curstruct)
	    end
	    if key == ROTATE_KEY then
	        currotyaw = currotyaw + 90
			currotyaw = currotyaw % 360
	    end
	    if key == "Left Mouse Button" then
            if (remove_obj == false) then
				local x, y, z = GetMouseHitLocation()
				if (x ~= 0) then
	            	CallRemoteEvent("Createcons", x, y, z, 0, currotyaw, 0)
				else
					AddPlayerChat("Please look at valid locations")
				end
            else
                local ScreenX, ScreenY = GetScreenSize()
                SetMouseLocation(ScreenX/2, ScreenY/2)
                local entityType, entityId = GetMouseHitEntity()
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
		if remove_obj == false then
			if my_shadow ~= 0 then
				local actor = GetObjectActor(my_shadow)
				actor:SetActorLocation(FVector(x, y, z))
				actor:SetActorRotation(FRotator(0, 0, currotyaw))
			end
		end
	end
end
AddEvent("OnGameTick", tickhook)

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
		end
		GetObjectActor(object):SetActorEnableCollision(not val)
	    SetObjectCastShadow(object, not val)
	    EnableObjectHitEvents(object, not val)
	end
end
AddEvent("OnObjectNetworkUpdatePropertyValue", GhostObject)

function render_cons()
    if constructionActivated then
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
