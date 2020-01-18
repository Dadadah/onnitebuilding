local remove_objs_cons = true -- does the mod remove all objects created by the player who quit the game

local admins_remove = {}

--admins_remove["76561197972837186"] = true -- vugi99
--admins_remove["steamid"] = true

local pitchstairs = 45

local constructed = {}

local constructedByID = {}

local shadows = {}

function rshadow(ply)
    if (shadows[ply]) then
        DestroyObject(shadows[ply].mapobjid)
        table.remove(shadows, ply)
    end
 end
 AddRemoteEvent("RemoveShadow",rshadow)

function constructshadow(ply, conid)
    local x, y, z = GetPlayerLocation(ply)
    local identifier = CreateObject(CONSTRUCTION_OBJECTS[conid].ID, x, y, z, 0, 0, 0, CONSTRUCTION_OBJECTS[conid].Scale[1], CONSTRUCTION_OBJECTS[conid].Scale[2], CONSTRUCTION_OBJECTS[conid].Scale[3])
    if (identifier ~= false) then
        shadows[ply] = {}
        shadows[ply].objid = conid
        shadows[ply].mapobjid = identifier

        -- Set the object as ghosted using package name as a prefix to prevent conflicts with other values. - Credit nexus#4880
        SetObjectPropertyValue(identifier, GHOSTED_PROPERTY_NAME, true, true)
        SetObjectPropertyValue(identifier, OWNER_PROPERTY_NAME, ply, true)

    else
        print("Error at CreateObject Construction mod")
    end
end

function upcons(ply, conid)
    if (shadows[ply]) then
        if (shadows[ply].objid ~= conid) then
            DestroyObject(shadows[ply].mapobjid)
            table.remove(shadows, ply)
            constructshadow(ply, conid)
        end
    else
        constructshadow(ply, conid)
    end
end
AddRemoteEvent("UpdateCons", upcons)

function OnPlayerQuit(ply)
    rshadow(ply)
    if (remove_objs_cons == true) then
        local steamid = tostring(GetPlayerSteamId(ply))

        local index = 1 -- DjCtavia#3870

        while index < #constructed + 1 do
            if (constructed[index].owner == steamid) then
                RemoveConstruction(index)
                index = index - 1
            end
            index = index + 1
        end
    end
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function Createobj(ply, x, y, z, pitch, yaw, roll)
    if (shadows[ply]) then
        local tbltoinsert = {}
        tbltoinsert.mapobjid = shadows[ply].mapobjid
        tbltoinsert.objid = shadows[ply].objid
        tbltoinsert.owner = tostring(GetPlayerSteamId(ply))

        -- Move the object to the desired position
        SetObjectLocation(tbltoinsert.mapobjid, x, y, z)
        SetObjectRotation(tbltoinsert.mapobjid, pitch, yaw, roll)

        -- Disable ghosting on this object
        SetObjectPropertyValue(tbltoinsert.mapobjid, GHOSTED_PROPERTY_NAME, false, true)

        -- Insert the index of the new object into the ByID table
        constructedByID[tbltoinsert.mapobjid] = #constructed + 1

        table.insert(constructed, tbltoinsert)
        table.remove(shadows, ply)
    end
end
AddRemoteEvent("Createcons", Createobj)

function coll_desync_workaround()
    -- TODO: Fix this code to work with the new system
    for kobj, vobj in ipairs(shadows) do
        local identifier = vobj.mapobjid
        for k, v in ipairs(GetAllPlayers()) do
           CallRemoteEvent(v, "Createdobj", identifier, false)
        end
    end
end
AddEvent("OnPackageStart", function()
    --CreateTimer(coll_desync_workaround, 1000)
end)

function Removeobj(ply, hitentity)
    local steamid = tostring(GetPlayerSteamId(ply))
    i = constructedByID[hitentity]
    if i == nil then
        return
    end
    local v = constructed[i]
    if v == nil then
        return
    end
    if (v.owner == steamid or admins_remove[steamid]) then
        RemoveConstruction(i)
    else
        AddPlayerChat(ply, "You can't remove this object")
    end
end
AddRemoteEvent("Removeobj", Removeobj)

function RemoveConstruction(constructedIndex)
    DestroyObject(constructed[constructedIndex].mapobjid)

    -- We can't use table.remove on this table because this array is sparse, it won't always start at 1 and it won't always be consecutive.
    constructedByID[constructed[constructedIndex].mapobjid] = nil

    table.remove(constructed, constructedIndex)
end
