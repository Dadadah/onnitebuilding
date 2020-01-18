-- Constants
GHOSTED_PROPERTY_NAME = GetPackageName() .. "::ghosted"
OWNER_PROPERTY_NAME = GetPackageName() .. "::owner"
CONSTRUCTION_ID_PROPERTY_NAME = GetPackageName() .. "::construction_id"

CONSTRUCTION_OBJECTS = {}

CONSTRUCTION_OBJECTS[1] = {
    ID = 240,
    BaseRotation = {0, 0, 180},
    Scale = {2, 2, 2},
    RelativeOffset = {-300, 0, 400},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, -300, 0}
}
CONSTRUCTION_OBJECTS[2] = {
    ID = 387,
    BaseRotation = {33.7, 0, 0},
    Scale = {0.3606, 0.3, 0.3},
    RelativeOffset = {0, 0, 200},
    SelfOffset = {300, 300, 400},
    GlobalOffset = {0, 0, 0}
}
CONSTRUCTION_OBJECTS[3] = {
    ID = 387,
    BaseRotation = {0, 0, 0},
    Scale = {0.3, 0.3, 0.3},
    RelativeOffset = {0, 0, 0},
    SelfOffset = {300, 300, -10},
    GlobalOffset = {0, 0, 10}
}
CONSTRUCTION_OBJECTS[4] = {
    ID = 851,
    BaseRotation = {0, 0, 0},
    Scale = {0.75, 1, 0.8},
    RelativeOffset = {-300, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, -300, 0}
}
CONSTRUCTION_OBJECTS[5] = {
    ID = 852,
    BaseRotation = {0, 0, 0},
    Scale = {0.75, 1, 0.8},
    RelativeOffset = {300, 0, 0},
    SelfOffset = {0, 0, 0},
    GlobalOffset = {300, -300, 0}
}
--CONSTRUCTION_OBJECTS[index] = object id -- https://dev.playonset.com/wiki/Objects
