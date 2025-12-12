local Dialog = require "engine.ui.Dialog"

newTalentType { allow_random = false, type = "cunning/conversion", name = "conversion", description = "Adventurer's stuff." }

local cuns_req1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
local cuns_req2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
local cuns_req3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
local cuns_req4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

newTalent {
    name = "Selector",
    short_name = "CONVERSOIN_SELECTOR",
    image = "talents/conversion_dmg_advent.png",
    type = { "other/other", 1 },
    points = 1,
    cooldown = 20,
    action = function(self, t)
        local variants = {
            { name = DamageType:get(DamageType.PHYSICAL).text_color .. _t "Physical conversion", damtype = DamageType.PHYSICAL },
            { name = DamageType:get(DamageType.FIRE).text_color .. _t "Fire conversion", damtype = DamageType.FIRE },
            { name = DamageType:get(DamageType.COLD).text_color .. _t "Cold conversion", damtype = DamageType.COLD },
            { name = DamageType:get(DamageType.LIGHTNING).text_color .. _t "Lightning conversion", damtype = DamageType.LIGHTNING },
            { name = DamageType:get(DamageType.ACID).text_color .. _t "Acid conversion", damtype = DamageType.ACID },
            { name = DamageType:get(DamageType.NATURE).text_color .. _t "Nature conversion", damtype = DamageType.NATURE },
            { name = DamageType:get(DamageType.BLIGHT).text_color .. _t "Blight conversion", damtype = DamageType.BLIGHT },
            { name = DamageType:get(DamageType.LIGHT).text_color .. _t "Light conversion", damtype = DamageType.LIGHT },
            { name = DamageType:get(DamageType.DARKNESS).text_color .. _t "Darkness conversion", damtype = DamageType.DARKNESS },
            { name = DamageType:get(DamageType.MIND).text_color .. _t "Mind conversion", damtype = DamageType.MIND },
            { name = DamageType:get(DamageType.TEMPORAL).text_color .. _t "Temporal conversion",   damtype = DamageType.TEMPORAL },
            -- add special damage type? May be via prophecy? https://te4.org/wiki/Damage_Types#Special_Damage_Types
            { name = _t "Never mind" },
        }
        local current_var = self.convert_selection or DamageType.PHYSICAL
        for _, item in ipairs(variants) do
            if item.damtype and item.damtype == current_var then
                item.name = item.name .. _t "#LAST# #{italic}#(current)#{normal}#"
                break
            end
        end
        local damtype = self:talentDialog(Dialog:listPopup(_t "Conversion aspect", _t "Choose an aspect to bring forth:", variants, 500, 400, function(item) self:talentDialogReturn(item) end))
        if damtype and damtype.damtype then
            self.convert_selection = damtype.damtype
            self:updateTalentPassives(t.id)
        end
        return true
    end,
    info = [[Damage type selector]]
}

newTalent {
    name = "Damage conversion",
    short_name = "CONVERSION_DMG_ADVENT",
    image = "talents/conversion_dmg_advent.png",
    type = { "cunning/conversion", 1 },
    mode = "sustained",
    autolearn_talent = "T_CONVERSOIN_SELECTOR",
    require = cuns_req1,
    cooldown = 5,
    no_energy = true,
    no_sustain_autoreset = true,
    tactical = { BUFF = 2 },
    points = 5,
    getConversion = function(self, t) return math.min(100, math.ceil(self:combatTalentScale(t, 40, 90))) end, -- 20-40-60-80-100
    -- getPowerLoss = function(self, t) return math.max(10, math.ceil(self:combatStatScale("cun", 35, 14, -0.5))) end, -- at least 10% power loss
    activate = function(self, t)
        game:playSoundNear(self, "talents/heal")
        local particle = Particles.new("ultrashield", 1, {rm=204, rM=220, gm=102, gM=120, bm=0, bM=0, am=35, aM=90, radius=0.5, density=10, life=28, instop=100})
        if self:knowTalent(self.T_CONVERSION_PAIN_ADVENT) then
            local affinity = self:callTalent(self.T_CONVERSION_PAIN_ADVENT, "getAffinity")
            return {
                affinity = self:addTemporaryValue("damage_affinity", {[self.convert_selection or DamageType.PHYSICAL] = affinity}),
                converttype = self:addTemporaryValue("all_damage_convert", self.convert_selection or DamageType.PHYSICAL),
                convertamount = self:addTemporaryValue("all_damage_convert_percent", t.getConversion(self, t)),
                particle = self:addParticles(particle)
            }
        end
        return {
            affinity = nil,
            converttype = self:addTemporaryValue("all_damage_convert", self.convert_selection or DamageType.PHYSICAL),
            convertamount = self:addTemporaryValue("all_damage_convert_percent", t.getConversion(self, t)),
            particle = self:addParticles(particle)
        }
    end,
    deactivate = function(self, t, p)
        if self:knowTalent(self.T_CONVERSION_PAIN_ADVENT) and p.affinity then
            self:removeTemporaryValue("damage_affinity", p.affinity)
        end
        self:removeTemporaryValue("all_damage_convert", p.converttype)
        self:removeTemporaryValue("all_damage_convert_percent", p.convertamount)
        self:removeParticles(p.particle)
        return true
    end,
    info = function(self, t)
        local conv = t.getConversion(self, t)
        local dmgType = self.convert_selection or DamageType.PHYSICAL
        return ([[Concentrate all you powers to consolidate and convert %d%% damage output to %s]]):tformat(conv, DamageType:get(dmgType).name)
    end,
}

newTalent {
    name = "Affliction conversion",
    short_name = "CONVERSION_AFFLICTION_ADVENT",
    image = "talents/conversion_affliction_advent.png",
    type = { "cunning/conversion", 2 },
    require = cuns_req2,
    no_energy = true,
    points = 5,
    cooldown = 20,
    tactical = {
        CURE = function(self, t, target)
            local types = 0
            types = types + #self:effectsFilter({status="detrimental", type="physical"}, t.getCleanseNum(self, t))
            types = types + #self:effectsFilter({status="detrimental", type="magical"}, t.getCleanseNum(self, t))
            types = types + #self:effectsFilter({status="detrimental", type="mental"}, t.getCleanseNum(self, t))
            return types
        end
    },
    getCleanseNum = function(self, t) if self:getTalentLevelRaw(t) >= 5 then return 2 end return 1 end,
    getShield = function(self, t) return self:combatStatScale("cun", 20, 90) end,
    getDuration = function(self, t) return self:combatTalentScale(t, 2, 4) end,
    on_pre_use = function(self, t)
        if next(self:effectsFilter({type="physical", status="detrimental"}, 1)) then return true end
        if next(self:effectsFilter({type="magical", status="detrimental"}, 1)) then return true end
        if next(self:effectsFilter({type="mental", status="detrimental"}, 1)) then return true end
        if next(self:effectsFilter({subtype={["cross tier"] = true}, status="detrimental"}, 3)) then return true end
        return false
    end,
    action = function(self, t)
        local crosstiers = self:removeEffectsFilter(self, {subtype={["cross tier"] = true}, status="detrimental"}, 3)
        local cleansed = 0
        cleansed = cleansed + self:removeEffectsFilter(self, {type="physical", status="detrimental", t.getCleanseNum(self, t)})
        cleansed = cleansed + self:removeEffectsFilter(self, {type="magical", status="detrimental", t.getCleanseNum(self, t)})
        cleansed = cleansed + self:removeEffectsFilter(self, {type="mental", status="detrimental", t.getCleanseNum(self, t)})

        if crosstiers == 0 and cleansed == 0 then return nil end

        if cleansed > 0 then
            self:setEffect(self.EFF_DAMAGE_SHIELD, t.getDuration(self, t), {power=math.ceil(t.getShield(self, t) * cleansed)})
        end
        return true
    end,
    info = function(self, t)
        local effnum = t.getCleanseNum(self, t)
        local shld = t.getShield(self, t)
        local shldur = t.getDuration(self, t)
        return ([[Concentrate your power to remove up to %d detrimental effect of each type. For each effect removed get %d damage shield for %d turns.
        Damage shield and duration scales with Cunning.
        Cross-tier effects will also be removed.]]):tformat(effnum, shld, shldur)
    end,
}

newTalent {
    name = "Pain conversion",
    short_name = "CONVERSION_PAIN_ADVENT",
    image = "talents/conversion_pain_advent.png",
    type = { "cunning/conversion", 3 },
    require = cuns_req3,
    mode = "passive",
    points = 5,
    getAffinity = function(self, t) return self:combatTalentScale(t, 2, 10) end,
    info = function(self, t)
        local aff = t.getAffinity(self, t)
        local dmgType = self.convert_selection or DamageType.PHYSICAL
        return ([[Constant struggle with reality to alter damage composition makes you a little bit more robust.
        While maintaining Damage conversion you also gain %d%% damage affinity to selected damage type]]):tformat(aff)
    end,
}

newTalent {
    name = "Probability conversion",
    short_name = "CONVERSION_POWER_ADVENT",
    image = "talents/conversion_power_advent.png",
    type = { "cunning/conversion", 4 },
    require = cuns_req4,
    mode = "passive",
    points = 5,
    getCritResist = function(self, t) return self:combatTalentScale(t, 25, 60) end,
    getCriticalChance = function(self, t) return self:combatTalentScale(t, 4, 10, 0.2) end,
    passives = function(self, t, p)
        self:talentTemporaryValue(p, "combat_generic_crit", t.getCriticalChance(self, t))
        self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritResist(self, t))
    end,
    info = function(self, t)
        local critres = t.getCritResist(self, t)
        local critchance = t.getCriticalChance(self, t)
        return ([[You bend the laws of reality, gaining %d%% additional critical chance and %d%% chance to ignore critical strike]]):tformat(critchance, critres)
    end,
}