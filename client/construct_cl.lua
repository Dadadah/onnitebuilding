
local consactivated = false
local curstruct = 1
local currotyaw = 0
local remove_obj = false

local numb_of_objs = 0

local shadows = {}

-- Constants
local GHOSTED_PROPERTY_NAME = GetPackageName() .. "::ghosted"
local OWNER_PROPERTY_NAME = GetPackageName() .. "::owner"

function OnKeyPress(key)
	if key == "Y" then
        consactivated = not consactivated
        if (consactivated == false) then
            CallRemoteEvent("RemoveShadow")
        end
    end
    if key == "E" then
        if (consactivated == true) then
            remove_obj = not remove_obj
            if remove_obj then
        		CallRemoteEvent("RemoveShadow")
            end
        end
    end
    if key == "Mouse Wheel Up" then
		curstruct = curstruct + 1
        curstruct = ((curstruct - 1) % numb_of_objs) + 1
    end
    if key == "Mouse Wheel Down" then
		curstruct = curstruct + 1
		curstruct = (curstruct % numb_of_objs) + 1
    end
    if key == "R" then
        if (currotyaw + 90 > 180) then
            currotyaw = -90
        else
            currotyaw = currotyaw + 90
        end
    end
    if key == "Left Mouse Button" then
        if consactivated then
            if (remove_obj==false) then
            	CallRemoteEvent("Createcons")
            else
                local ScreenX, ScreenY = GetScreenSize()
                SetMouseLocation(ScreenX/2, ScreenY/2)
                local entityType, entityId = GetMouseHitEntity()
                if (entityId~=0) then
                	CallRemoteEvent("Removeobj",entityId)
                end
            end
        end
    end
end
AddEvent("OnKeyPress", OnKeyPress)

local lasthitposx = nil
local lasthitposy = nil
local lasthitposz = nil
local lastang = nil

local lastcons = nil

local lastconsactivated = nil

function tickhook(DeltaSeconds)
    if consactivated then
		local ScreenX, ScreenY = GetScreenSize()
		SetMouseLocation(ScreenX/2, ScreenY/2)
		if remove_obj == false then
		lastconsactivated = true
		local x,y,z = GetMouseHitLocation()
			if (x ~= lasthitposx or y ~= lasthitposy or z ~= lasthitposz or lastang ~= currotyaw or lastconsactivated ~= consactivated or lastcons ~= curstruct) then
				lasthitposx = x
				lasthitposy = y
				lasthitposz = z
				lastang = currotyaw
				lastcons = curstruct
				lastconsactivated = true
				if (x ~= 0) then
					local entityType, entityId = GetMouseHitEntity()
					local pitch,yaw,roll = GetCameraRotation()
			    	CallRemoteEvent("UpdateCons", curstruct, currotyaw, x, y, z, entityId, yaw)
				else
					AddPlayerChat("Please look at valid locations")
				end
		    end
		end
	else
        lastconsactivated=false
    end
end
AddEvent("OnGameTick", tickhook)

function GhostNewObject(object)
	if GetObjectPropertyValue(object, GHOSTED_PROPERTY_NAME) == true then
		if GetObjectPropertyValue(object, OWNER_PROPERTY_NAME) ~= GetPlayerId() then
			GetObjectActor(object):SetActorHiddenInGame(true)
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
		end
		GetObjectActor(object):SetActorEnableCollision(not val)
	    SetObjectCastShadow(object, not val)
	    EnableObjectHitEvents(object, not val)
	end
end
AddEvent("OnObjectNetworkUpdatePropertyValue", GhostObject)

AddRemoteEvent("numberof_objects", function(number)
    numb_of_objs = number
end)

function render_cons()
    if consactivated then
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
