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

-- Constants
GHOSTED_PROPERTY_NAME = GetPackageName() .. "::ghosted"
OWNER_PROPERTY_NAME = GetPackageName() .. "::owner"
CONSTRUCTION_ID_PROPERTY_NAME = GetPackageName() .. "::construction_id"

CONSTRUCTION_OBJECTS = {}

CONSTRUCTION_OBJECTS[1] = {
    ID = 387,
    BaseRotation = {0, 0, 0},
    Scale = {0.3, 0.3, 0.3},
    RelativeOffset = {0, 0, 0},
    SelfOffset = {300, 300, -10},
    GlobalOffset = {0, 0, 10},
    IgnoreGlobalOffset = {
        [1] = true,
        [2] = true
    }
}
CONSTRUCTION_OBJECTS[2] = {
    ID = 387,
    BaseRotation = {0, 0, 0},
    Scale = {0.3, 0.3, 0.3},
    RelativeOffset = {0, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {0, 0, 390},
    IgnoreGlobalOffset = {
        [1] = true,
        [2] = true
    }
}
CONSTRUCTION_OBJECTS[3] = {
    ID = 851,
    BaseRotation = {0, 0, 0},
    Scale = {0.75, 1, 0.8},
    RelativeOffset = {-300, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, -300, 0},
    IgnoreGlobalOffset = {
        [3] = true,
        [4] = true
    }
}
CONSTRUCTION_OBJECTS[4] = {
    ID = 852,
    BaseRotation = {0, 0, 0},
    Scale = {0.75, 1, 0.8},
    RelativeOffset = {-300, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, -300, 0},
    IgnoreGlobalOffset = {
        [3] = true,
        [4] = true
    }
}
CONSTRUCTION_OBJECTS[5] = {
    ID = 387,
    BaseRotation = {33.7, 0, 0},
    Scale = {0.3606, 0.3, 0.3},
    RelativeOffset = {0, 0, 200},
    SelfOffset = {300, 300, 400},
    GlobalOffset = {0, 0, 0},
    IgnoreGlobalOffset = {}
}
CONSTRUCTION_OBJECTS[4] = {
    ID = 851,
    BaseRotation = {0, 0, 0},
    Scale = {0.75, 1, 0.8},
    RelativeOffset = {-300, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, 300, 0}
}
CONSTRUCTION_OBJECTS[5] = {
    ID = 852,
    BaseRotation = {0, 180, 0},
    Scale = {0.75, 1, 0.8},
    RelativeOffset = {-300, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, 300, 0}
}
--CONSTRUCTION_OBJECTS[index] = object id -- https://dev.playonset.com/wiki/Objects
