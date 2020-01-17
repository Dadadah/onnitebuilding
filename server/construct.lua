local remove_objs_cons = true -- does the mod remove all objects created by the player who quit the game

local objs = {}

objs[1] = 240 --Don't change this line
objs[2] = 387 --Don't change this line
objs[3] = 387 --Don't change this line
--objs[4] = 1003
--objs[index] = object id -- https://dev.playonset.com/wiki/Objects

local admins_remove = {}

--admins_remove["76561197972837186"] = true -- me
--admins_remove["steamid"] = true

local pitchstairs = 45

local constructed = {}

local constructedByID = {}

local shadows = {}

-- Constants
local GHOSTED_PROPERTY_NAME = GetPackageName() + "::ghosted"
local OWNER_PROPERTY_NAME = GetPackageName() + "::owner"

function rshadow(ply)
    if (shadows[ply]) then
        DestroyObject(shadows[ply].mapobjid)
        table.remove(shadows, ply)
    end
 end
 AddRemoteEvent("RemoveShadow",rshadow)

function constructshadow(ply, conid, angle, x, y, z, hitentity, camrot)
    local anglex = 0
    local size = 1
    if (conid == 1) then
        size = 2
        if (angle == 180) then
            angle = 0
            x = x - 300
        elseif (angle == -90) then
           angle = 90
           y = y - 300
        elseif (angle == 90) then
            y = y - 300
        elseif (angle == 0) then
            x = x - 300
        end
    end
    if (conid == 2) then
        anglex = 45
        size = 0.25
        z = z + 175
    end
    if (conid == 3) then
        size = 0.25
        z = z + 25
    end
    local identifier = CreateObject(objs[conid], x, y, z, anglex, angle, 0, size, size, size)
    if (identifier~=false) then
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

function upcons(ply, conid, angle, x, y, z, hitentity, camrot)
    if (shadows[ply]) then
        if (shadows[ply].objid == conid) then
            --AddPlayerChat(ply,"X : " .. x .. " Y : " .. y .. " Z : " .. z .. " Angle : " .. angle)
            if (conid == 1) then
                local befangle = angle
                if (angle == 180) then
                    angle = 0
                elseif (angle == -90) then
                   angle = 90
                end
                local nofound = true
                k = constructedByID[hitentity]
                if k ~= nil then
                    local v = constructed[k]
                    if v ~= nil and v.objid == 1 then
                        local rotx , roty , rotz = GetObjectRotation(hitentity)
                        local ox, oy, oz = GetObjectLocation(hitentity)
                        nofound = false
                        local valtoadd = 0
                        if (roty == 90 or roty == -90) then
                            if (y - oy > 300) then
                                valtoadd = 600
                            else
                                if (angle == 90) then
                                    valtoadd = -600
                                else
                                    valtoadd = 0
                                end
                            end
                        else
                            if (x - ox > 300) then
                                valtoadd = 600
                            else
                                if (angle == 0) then
                                    valtoadd = -600
                                else
                                    valtoadd = 0
                                end
                            end
                        end
                        x = ox
                        y = oy
                        z = oz
                        if (befangle == 180 and roty == 90) then
                            y = oy + valtoadd
                            x = ox - 600
                        elseif (befangle == -90 and roty == 0) then
                            x = ox + valtoadd
                            y = oy - 600
                        elseif (roty == 0) then
                            x = ox + valtoadd
                        elseif (roty == 90) then
                            y = oy + valtoadd
                        end
                    end
                end
                if (nofound == true) then
                    if (angle == 0) then
                       x = x - 300
                    elseif (angle == 90) then
                        y = y - 300
                    end
                end
            end
            if (conid == 2) then
                z = z + 175
                k = constructedByID[hitentity]
                if k ~= nil then
                    local v = constructed[k]
                    if v ~= nil and v.objid == 2 then
                        local rotx , roty , rotz = GetObjectRotation(hitentity)
                        local ox, oy, oz = GetObjectLocation(hitentity)
                        local valtoadd = 0
                        if (z - oz > 175) then
                          z = oz + 350
                          valtoadd = 350
                        else
                          z = oz - 350
                          valtoadd = -350
                        end
                        x = ox
                        y = oy
                        angle = roty
                        if (roty == 0) then
                            x = ox + valtoadd
                        elseif (roty == 90) then
                            y = oy + valtoadd
                        elseif (roty == 180) then
                            x = ox + valtoadd * -1
                        elseif (roty == -90) then
                            y = oy + valtoadd * -1
                        end
                    end
                end
            end
            if (conid == 3) then
                z = z + 25
                k = constructedByID[hitentity]
                if k ~= nil then
                    local v = constructed[k]
                    if v ~= nil and v.objid == 3 then
                        local rotx , roty , rotz = GetObjectRotation(hitentity)
                        local ox, oy, oz = GetObjectLocation(hitentity)
                        local valtoadd = 0
                        if (x - ox > 0 and y - oy > 0) then
                            if (x - ox > y - oy) then
                                x = ox+500
                                z = oz
                                y = oy
                            else
                                x = ox
                                z = oz
                                y = oy + 500
                            end
                        elseif (x - ox < 0 and y - oy < 0) then
                            if (x - ox < y - oy) then
                                x = ox - 500
                                z = oz
                                y = oy
                            else
                                x = ox
                                z = oz
                                y = oy - 500
                            end
                        elseif (x - ox < 0) then
                            if ((x - ox) * -1 > y - oy) then
                                x = ox - 500
                                z = oz
                                y = oy
                            else
                                x = ox
                                z = oz
                                y = oy + 500
                            end
                        elseif (y - oy < 0) then
                            if ((y - oy) * -1 > x - ox) then
                                x = ox
                                z = oz
                                y = oy - 500
                            else
                                x = ox + 500
                                z = oz
                                y = oy
                            end
                        end
                    end
                end
            end
            local px, py, pz = GetPlayerLocation(ply)
            local dist = GetDistance3D(px, py, pz, x, y, z)
            if (dist < 10000) then
                SetObjectLocation(shadows[ply].mapobjid, x, y, z)
                local anglex = 0
                if (conid == 2) then
                    anglex = 45
                end
                SetObjectRotation(shadows[ply].mapobjid, anglex, angle, 0)
            else
                AddPlayerChat(ply, "Too far from you")
            end
        else
            DestroyObject(shadows[ply].mapobjid)
            table.remove(shadows, ply)
            constructshadow(ply, conid, angle, x, y, z, hitentity, camrot)
        end
    else
        constructshadow(ply, conid, angle, x, y, z, hitentity, camrot)
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

function Createobj(ply)
    if (shadows[ply]) then
        local tbltoinsert = {}
        tbltoinsert.mapobjid = shadows[ply].mapobjid
        tbltoinsert.objid = shadows[ply].objid
        tbltoinsert.owner = tostring(GetPlayerSteamId(ply))

        -- Disable ghosting on this object
        SetObjectPropertyValue(tbltoinsert.mapobjid, GHOSTED_PROPERTY_NAME, false, true)

        -- Insert the index of the new object into the ByID table
        constructedByID[tbltoinsert.mapobjid] = #constructed + 1

        table.insert(constructed, tbltoinsert)
        for k, v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v, "Createdobj", shadows[ply].mapobjid, true)
        end
        table.remove(shadows, ply)
    end
end
AddRemoteEvent("Createcons", Createobj)

function coll_desync_workaround()
    for kobj, vobj in ipairs(shadows) do
        local identifier = vobj.mapobjid
        for k, v in ipairs(GetAllPlayers()) do
           CallRemoteEvent(v, "Createdobj", identifier, false)
        end
    end
end
AddEvent("OnPackageStart", function()
    CreateTimer(coll_desync_workaround, 1000)
end)

function OnPlayerSpawn(ply)
    CallRemoteEvent(ply, "numberof_objects", #objs)
end
AddEvent("OnPlayerSpawn", OnPlayerSpawn)

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
