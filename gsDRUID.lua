GS = GSD.RotationToggle("d")
do
    do -- Balance
        -- talents=2200221
        -- artifact=59:0:0:0:0:1035:3:1036:3:1039:2:1040:3:1042:3:1044:1:1046:1:1047:1:1049:1:1294:1
        local astral_communion    = 202359
        local blessing_of_anshe   = 202739
        local blessing_of_elune   = 202737
        local celestial_alignment = 194223
        local fury_of_elune       = 202770
        local incarnation         = 102560
        local lunar_empowerment   = 164547
        local lunar_strike        = 194153
        local moonfire            =        {spell = 8921, debuff = 164812}
        local solar_empowerment   = 164545
        local solar_wrath         = 190984
        local starsurge           =  78674
        local stellar_flare       = 202347
        local sunfire             =        {spell = 93402, debuff = 164815}
        local warrior_of_elune    = 202425
        
        function GS.DRUID1()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.CDs and GS.Aura("player", (GS.Talent52 and incarnation or celestial_alignment)) then
                        -- actions=potion,name=deadly_grace
                        -- actions+=/berserking
                    end
                    if GS.Talent71 and (GS.Aura("player", fury_of_elune) or GS.CDs and GS.UnitIsBoss("target") and GS.SpellCDDuration(fury_of_elune) < GS.GetTTD()) then -- Fury of Elune Rotation
                        if GS.PP() >= 95 and GS.SpellCDDuration(fury_of_elune) <= GS.GCD() then
                            if GS.Talent52 then
                                if GS.SIR(incarnation) then GS.Cast(_, incarnation, _, _, _, _, "Incarnation: Fury of Elune Time") return end
                            else
                                if GS.SIR(celestial_alignment) then GS.Cast(_, celestial_alignment, _, _, _, _, "Celestial Alignment: Fury of Elune Time") return end
                            end
                            if GS.SIR(fury_of_elune) then GS.Cast(_, fury_of_elune, _, _, _, _, "Fury of Elune") return end -- todo: handle the aoe part later
                        end
                        -- actions.fury_of_elune+=/new_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=90))
                        -- actions.fury_of_elune+=/half_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=80))
                        -- actions.fury_of_elune+=/full_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=60))
                        if GS.Talent62 and GS.SIR(astral_communion) and GS.PP() <= 25 then GS.Cast(_, astral_communion, _, _, _, _, "Astral Communion: Fury of Elune") return end
                        if GS.Talent12 and GS.SIR(warrior_of_elune) and (GS.Aura("player", fury_of_elune) or GS.SpellCDDuration(fury_of_elune) >= 35 and GS.Aura("player", lunar_empowerment)) then GS.Cast(_, warrior_of_elune, _, _, _, _, "Warrior of Elune: Fury of Elune") return end
                        if GS.SCA(lunar_strike) and GS.Aura("player", warrior_of_elune) and (GS.PP() <= 90 or GS.PP() <= 85 and GS.Aura("player", (GS.Talent52 and incarnation or celestial_alignment))) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Fury of Elune") return end
                        -- actions.fury_of_elune+=/new_moon,if=astral_power<=90&buff.fury_of_elune_up.up
                        -- actions.fury_of_elune+=/half_moon,if=astral_power<=80&buff.fury_of_elune_up.up&astral_power>cast_time*12
                        -- actions.fury_of_elune+=/full_moon,if=astral_power<=60&buff.fury_of_elune_up.up&astral_power>cast_time*12
                        if not GS.Aura("player", fury_of_elune) then
                            if GS.SCA(moonfire.spell) and GS.AuraRemaining("target", moonfire.debuff, 6.6, "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire: Fury of Elune") return end
                            if GS.SCA(sunfire.spell) and GS.AuraRemaining("target", sunfire.debuff, 5.4, "Solar", "PLAYER") then GS.Cast(_, sunfire.spell, _, _, _, _, "Sunfire: Fury of Elune") return end
                        end
                        if GS.Talent53 and GS.SCA(stellar_flare) and GS.AuraRemaining("target", stellar_flare, 7.2, "", "PLAYER") then GS.Cast(_, stellar_flare, _, _, _, _, "Stellar Flare: Refresh") return end
                        if GS.SCA(starsurge) and not GS.Aura("player", fury_of_elune) and (GS.PP() >= 92 and GS.SpellCDDuration(fury_of_elune) > GS.GCD()*3 or GS.SpellCDDuration(warrior_of_elune) <= 5 and GS.SpellCDDuration(fury_of_elune) >= 35 and not GS.AuraStacks("player", lunar_empowerment, 2)) then GS.Cast(_, starsurge, _, _, _, _, "Starsurge: Fury of Elune") return end
                        if GS.SCA(solar_wrath) and GS.Aura("player", solar_empowerment) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Empowered") return end
                        if GS.SCA(lunar_strike) and (GS.AuraStacks("player", lunar_empowerment, 3) or GS.Aura("player", lunar_empowerment) and GS.AuraRemaining("player", lunar_empowerment, 5)) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Fury of Elune") return end
                        if GS.SCA(solar_wrath) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath") return end
                    end
                    -- actions+=/new_moon,if=(charges=2&recharge_time<5)|charges=3
                    -- actions+=/half_moon,if=(charges=2&recharge_time<5)|charges=3|(target.time_to_die<15&charges=2)
                    -- actions+=/full_moon,if=(charges=2&recharge_time<5)|charges=3|target.time_to_die<15
                    if GS.Talent53 and GS.SCA(stellar_flare) and GS.AuraRemaining("target", stellar_flare, 7.2, "", "PLAYER") then GS.Cast(_, stellar_flare, _, _, _, _, "Stellar Flare: Refresh") return end
                    if GS.SCA(moonfire.spell) and GS.AuraRemaining("target", moonfire.debuff, (GS.Talent73 and 3 or 6.6), "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire") return end
                    if GS.SCA(sunfire.spell) and GS.AuraRemaining("target", sunfire.debuff, (GS.Talent73 and 5.4 or 3), "Solar", "PLAYER") then GS.Cast(_, sunfire.spell, _, _, _, _, "Sunfire") return end
                    if GS.CDs then
                        if GS.Talent62 and GS.SIR(astral_communion) and GS.PP("deficit") >= 75 then GS.Cast(_, astral_communion, _, _, _, _, "Astral Communion") return end
                        if GS.PP() >= 40 then
                            if GS.Talent52 then
                                if GS.SIR(incarnation) then GS.Cast(_, incarnation, _, _, _, _, "Incarnation") return end
                            else
                                if GS.SIR(celestial_alignment) then GS.Cast(_, celestial_alignment, _, _, _, _, "Celestial Alignment") return end
                            end
                        end
                    end
                    if GS.SCA(solar_wrath) and GS.AuraStacks("player", solar_empowerment, 3) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Capped Empowered") return end
                    if GS.SCA(lunar_strike) and GS.AuraStacks("player", lunar_empowerment, 3) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Capped Empowered") return end
                    if GS.Aura("player", (GS.Talent52 and incarnation or celestial_alignment)) then -- Celestial Alignment or Incarnation Rotation
                        if GS.SCA(starsurge) then GS.Cast(_, starsurge, _, _, _, _, "Starsurge") return end
                        if GS.Talent12 and GS.SIR(warrior_of_elune) and GS.AuraStacks("player", lunar_empowerment, 2) and GS.PP() <= (GS.Aura("player", blessing_of_elune) and 58 or 70) then GS.Cast(_, warrior_of_elune, _, _, _, _, "Warrior of Elune") return end
                        if GS.SCA(lunar_strike) and GS.Aura("player", warrior_of_elune) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Instant Warrior Of Elune") return end
                        if GS.SCA(solar_wrath) and GS.Aura("player", solar_empowerment) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Empowered") return end
                        if GS.SCA(lunar_strike) and GS.Aura("player", lunar_empowerment) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Empowered") return end
                        if GS.Talent73 and GS.SCA(solar_wrath) and GS.AuraRemaining("target", sunfire.debuff, 5, "Solar", "PLAYER") and not GS.AuraRemaining("target", sunfire.debuff, GS.CastTime(solar_wrath), "Solar", "PLAYER") then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Extend Sunfire") return end
                        if GS.Talent73 and GS.SCA(lunar_strike) and GS.AuraRemaining("target", moonfire.debuff, 5, "Lunar", "PLAYER") and not GS.AuraRemaining("target", moonfire.debuff, GS.CastTime(lunar_strike), "Lunar", "PLAYER") then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Extend Moonfire") return end
                        if GS.SCA(solar_wrath) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath") return end
                    end

                    -- actions.single_target=new_moon,if=astral_power<=90
                    -- actions.single_target+=/half_moon,if=astral_power<=80
                    -- actions.single_target+=/full_moon,if=astral_power<=60
                    if GS.SCA(starsurge) then GS.Cast(_, starsurge, _, _, _, _, "Starsurge") return end
                    if GS.Talent12 and GS.SIR(warrior_of_elune) and GS.AuraStacks("player", lunar_empowerment, 2) and GS.PP() <= (GS.Aura("player", blessing_of_elune) and 72 or 80) then GS.Cast(_, warrior_of_elune, _, _, _, _, "Warrior of Elune") return end
                    if GS.SCA(lunar_strike) and GS.Aura("player", warrior_of_elune) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Instant Warrior Of Elune") return end
                    if GS.SCA(solar_wrath) and GS.Aura("player", solar_empowerment) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Empowered") return end
                    if GS.SCA(lunar_strike) and GS.Aura("player", lunar_empowerment) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Empowered") return end
                    if GS.Talent73 and GS.SCA(solar_wrath) and GS.AuraRemaining("target", sunfire.debuff, 5, "Solar", "PLAYER") and not GS.AuraRemaining("target", sunfire.debuff, GS.CastTime(solar_wrath), "Solar", "PLAYER") then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Extend Sunfire") return end
                    if GS.Talent73 and GS.SCA(lunar_strike) and GS.AuraRemaining("target", moonfire.debuff, 5, "Lunar", "PLAYER") and not GS.AuraRemaining("target", moonfire.debuff, GS.CastTime(lunar_strike), "Lunar", "PLAYER") then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Extend Moonfire") return end
                    if GS.SCA(solar_wrath) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath") return end
                end
            end
        end
    end

    -- todo: create Feral Druid
    do -- Feral
        local function rakeCurrentMultiplier()
            local multiplier = 1
            if GS.Aura("player", 5217) then multiplier = multiplier * 1.15 end
            if GS.Aura("player", 52610) then multiplier = multiplier * 1.25 end
            if GS.Aura("player", 145152) then multiplier = multiplier * 1.5 end
            if GS.Aura("player", 5215) or GS.Aura("player", 102543) --[[shadowmeld]] then multiplier = multiplier * 2 end
            return multiplier
        end
    end

    do -- Guardian
        -- talents=3323323
        -- artifact=57:0:0:0:0:948:3:949:3:950:3:951:3:952:3:953:3:954:3:955:3:956:3:957:1:958:1:959:1:960:1:961:1:962:1:979:1:1334:1
        local pulverize = {spell = 80313, buff = 158792}
        local mangle = 33917
        local thrash = 77758
        local moonfire = {spell = 8921, debuff = 164812}

        function GS.DRUID3()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack()
                    if GSR.Interrupt then GS.Interrupt() end
                    
                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                    -- actions+=/use_item,slot=trinket2
                    -- actions+=/barkskin
                    -- actions+=/bristling_fur,if=buff.ironfur.remains<2&rage<40
                    -- actions+=/ironfur,if=buff.ironfur.down|rage.deficit<25
                    -- actions+=/frenzied_regeneration,if=!ticking&incoming_damage_6s%health.max>0.25+(2-charges_fractional)*0.15
                    if GS.Talent73 and not GS.Aura("player", pulverize.buff) then
                        if GS.SCA(pulverize.spell) then GS.Cast(_, pulverize.spell, _, _, _, _, "Pulverize") return end
                        for i = 1, mobTargetsSize do
                            rotationUnitIterator = GS.MobTargets[i]
                            if GS.SCA(pulverize.spell, rotationUnitIterator) then GS.Cast(rotationUnitIterator, pulverize.spell, _, _, _, _, "Pulverize") return end
                        end
                    end
                    if GS.SCA(mangle) then GS.Cast(_, mangle, _, _, _, _, "Mangle") return end
                    if GS.Talent73 and GS.AuraRemaining("player", pulverize.buff, GS.GCD()) then
                        if GS.SCA(pulverize.spell) then GS.Cast(_, pulverize.spell, _, _, _, _, "Pulverize") return end
                        for i = 1, mobTargetsSize do
                            rotationUnitIterator = GS.MobTargets[i]
                            if GS.SCA(pulverize.spell, rotationUnitIterator) then GS.Cast(rotationUnitIterator, pulverize.spell, _, _, _, _, "Pulverize") return end
                        end
                    end
                    -- actions+=/lunar_beam
                    -- actions+=/incarnation
                    if GS.AoE and GS.SIR(thrash) and GS.PlayerCount(8) >= 2 then GS.Cast(_, thrash, _, _, _, _, "Thrash: AoE") return end
                    if GS.Talent73 and GS.AuraRemaining("player", pulverize.buff, 3.6) then
                        if GS.SCA(pulverize.spell) then GS.Cast(_, pulverize.spell, _, _, _, _, "Pulverize") return end
                        for i = 1, mobTargetsSize do
                            rotationUnitIterator = GS.MobTargets[i]
                            if GS.SCA(pulverize.spell, rotationUnitIterator) then GS.Cast(rotationUnitIterator, pulverize.spell, _, _, _, _, "Pulverize") return end
                        end
                    end
                    if GS.Talent73 and GS.SIR(thrash) and GS.PlayerCount(8) > 0 and GS.AuraRemaining("player", pulverize.buff, 3.6) then GS.Cast(_, thrash, _, _, _, _, "Thrash: Pulverize Running Out") return end
                    if GS.SCA(moonfire.spell) and not GS.Aura("target", moonfire.debuff, "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire: Not Up") return end
                    for i = 1, mobTargetsSize do
                        rotationUnitIterator = GS.MobTargets[i]
                        if GS.UnitIsTappedByPlayer(rotationUnitIterator) and GS.SCA(moonfire.spell, rotationUnitIterator) and not GS.Aura(rotationUnitIterator, moonfire.debuff, "Lunar", "PLAYER") then GS.Cast(rotationUnitIterator, moonfire.spell, _, _, _, _, "Moonfire: AoE Not Up") return end
                    end
                    if GS.SCA(moonfire.spell) and GS.AuraRemaining("target", moonfire.debuff, 3.6, "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire: Low Duration") return end
                    for i = 1, mobTargetsSize do
                        rotationUnitIterator = GS.MobTargets[i]
                        if GS.UnitIsTappedByPlayer(rotationUnitIterator) and GS.SCA(moonfire.spell, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, moonfire.debuff, 3.6, "Lunar", "PLAYER") then GS.Cast(rotationUnitIterator, moonfire.spell, _, _, _, _, "Moonfire: AoE Low Duration") return end
                    end
                    if GS.SCA(moonfire.spell) and GS.AuraRemaining("target", moonfire.debuff, 7.2, "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire: Medium Duration") return end
                    for i = 1, mobTargetsSize do
                        rotationUnitIterator = GS.MobTargets[i]
                        if GS.UnitIsTappedByPlayer(rotationUnitIterator) and GS.SCA(moonfire.spell, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, moonfire.debuff, 7.2, "Lunar", "PLAYER") then GS.Cast(rotationUnitIterator, moonfire.spell, _, _, _, _, "Moonfire: AoE Medium Duration") return end
                    end
                    if GS.SCA(moonfire.spell) then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire") return end
                end
            end
        end
    end
    -- todo: create Restoration Druid
end