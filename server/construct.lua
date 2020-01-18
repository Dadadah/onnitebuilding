local prop_limit = 100

local admins_remove = {}

--admins_remove["76561197972837186"] = true -- vugi99
--admins_remove["steamid"] = true

local constructions = {}
local propcount = {}

local shadows = {}

function rshadow(ply)
    if (shadows[ply]) then
        DestroyObject(shadows[ply].mapobjid)
        shadows[ply] = nil
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
        SetObjectPropertyValue(identifier, CONSTRUCTION_ID_PROPERTY_NAME, conid, true)

    else
        print("Error at CreateObject Construction mod")
    end
end

function upcons(ply, conid)
    if (shadows[ply]) then
        if (shadows[ply].objid ~= conid) then
            DestroyObject(shadows[ply].mapobjid)
            shadows[ply] = nil
            constructshadow(ply, conid)
        end
    else
        constructshadow(ply, conid)
    end
end
AddRemoteEvent("UpdateCons", upcons)

function OnPlayerQuit(ply)
    rshadow(ply)
    local steamid = tostring(GetPlayerSteamId(ply))

    for k, v in pairs(constructions) do
        if v.owner == steamid then
            RemoveConstruction(ply, k)
        end
    end
    propcount[ply] = nil
end
AddEvent("OnPlayerQuit", OnPlayerQuit)


function OnPlayerJoin(ply)
    propcount[ply] = 0
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function Createobj(ply, x, y, z, pitch, yaw, roll)
    if (shadows[ply]) then
        if propcount[ply] >= prop_limit then
            AddPlayerChat(ply, "Prop limit reached")
            return
        end
        local tbltoinsert = {}
        tbltoinsert.mapobjid = shadows[ply].mapobjid
        tbltoinsert.objid = shadows[ply].objid
        tbltoinsert.owner = tostring(GetPlayerSteamId(ply))

        propcount[ply] = propcount[ply] + 1

        -- Move the object to the desired position
        SetObjectLocation(tbltoinsert.mapobjid, x, y, z)
        SetObjectRotation(tbltoinsert.mapobjid, pitch, yaw, roll)

        -- Disable ghosting on this object
        SetObjectPropertyValue(tbltoinsert.mapobjid, GHOSTED_PROPERTY_NAME, false, true)

        constructions[tbltoinsert.mapobjid] = tbltoinsert

        shadows[ply] = nil
    end
end
AddRemoteEvent("Createcons", Createobj)

function Removeobj(ply, hitentity)
    local steamid = tostring(GetPlayerSteamId(ply))
    local v = constructions[hitentity]
    if v == nil then
        return
    end
    if (v.owner == steamid or admins_remove[steamid]) then
        RemoveConstruction(ply, v.mapobjid)
    else
        AddPlayerChat(ply, "You can't remove this object")
    end
end
AddRemoteEvent("Removeobj", Removeobj)

function RemoveConstruction(ply, constructionID)
    propcount[ply] = propcount[ply] - 1
    DestroyObject(constructionID)
    constructions[constructionID] = nil
end
