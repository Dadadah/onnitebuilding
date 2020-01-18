-- Constants
GHOSTED_PROPERTY_NAME = GetPackageName() .. "::ghosted"
OWNER_PROPERTY_NAME = GetPackageName() .. "::owner"
CONSTRUCTION_ID_PROPERTY_NAME = GetPackageName() .. "::construction_id"

CONSTRUCTION_OBJECTS = {}

CONSTRUCTION_OBJECTS[1] = {
    ID = 240,
    BaseRotation = {0, 0, 180},
    Scale = {2, 2, 2},
    Offset = {-300, 0, 400}
}
CONSTRUCTION_OBJECTS[2] = {
    ID = 387,
    BaseRotation = {45, 0, 0},
    Scale = {0.25, 0.25, 0.25},
    Offset = {0, 0, 200}
}
CONSTRUCTION_OBJECTS[3] = {
    ID = 387,
    BaseRotation = {0, 0, 0},
    Scale = {0.25, 0.25, 0.25},
    Offset = {0, 0, 0}
}
--CONSTRUCTION_OBJECTS[index] = object id -- https://dev.playonset.com/wiki/Objects
