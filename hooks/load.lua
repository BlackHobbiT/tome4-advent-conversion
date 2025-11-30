local class = require "engine.class"
local ActorTalents = require "engine.interface.ActorTalents"
local Birther = require "engine.Birther"


class:bindHook("ToME:load", function(self, data)
    ActorTalents:loadDefinition('/data-advconversion/talents/cunning/conversion.lua')
    Birther:loadDefinition('/data-advconversion/birth/classes/dummy.lua')
end)