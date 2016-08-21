GS = GSD.RotationToggle("d")
do
    local arcane_torrent =  69179 -- verify: Warrior
    local avatar         = 107574 -- verify: Warrior
    local battle_cry     =   1719
    local berserker_rage =  18499
    local blood_fury     =  20572
    local heroic_charge  =    nil
    local rage           =  GS.PP
    local shockwave      =  46968
    local stone_heart    = 225947 -- verify: Arms and Fury Warrior
    local storm_bolt     = 107570

    do -- Arms
        -- talents=1111122
        -- artifact=36:0:0:0:0:1136:1:1137:1:1139:1:1142:1:1145:3:1147:2:1148:3:1149:3:1150:3:1356:1
        local bladestorm         = 227847
        local cleave             =        {spell =    845,   buff = 188923}
        local colossus_smash     =        {spell = 167105, debuff = 208086}
        local execute            = 163201
        local focused_rage       = 207982
        local hamstring          =   1715
        local mortal_strike      =  12294
        local overpower          =   7384
        local ravager            = 152277
        local rend               =    772
        local shattered_defenses = 209706 -- verify: Arms Warrior
        local slam               =   1464
        local warbreaker         = 209577 -- verify: Arms Warrior
        local whirlwind          =   1680

        local precise_strikes = function()
            GSHealingTooltipFrame:ClearLines()
            GSHealingTooltipFrame:SetSpellByID(61304)
            GSHealingTooltipFrame:SetAlpha(0)
            if GSHealingTooltipFrameTextLeft1:GetText() ~= "Global Cooldown" then
                GSHealingTooltipFrame:SetOwner(UIParent)
                GSHealingTooltipFrame:SetAlpha(0)
            end
            GSHealingTooltipFrame:ClearLines()
            GSHealingTooltipFrame:SetSpellByID(mortal_strike)
            GSHealingTooltipFrame:SetAlpha(0)
            healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft2:GetText(), "%d+ Rage")
            healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
            healingStringPlaceholderOne = healingStringPlaceholderOne + 0
            return healingStringPlaceholderOne ~= 20 and healingStringPlaceholderOne ~= 16
        end

        function GS.WARRIOR1()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack("target")
                    -- actions+=/potion,name=deadly_grace,if=(target.health.pct<20&buff.battle_cry.up)|target.time_to_die<25
                    if GS.CDs then
                        if GS.SIR(battle_cry) and (not GS.AuraRemaining("target", colossus_smash.debuff, 5, "", "PLAYER") or GS.Aura("target", colossus_smash.debuff, "", "PLAYER") and GS.SpellCDDuration(colossus_smash.spell) == 0) then
                            if GS.SCA(colossus_smash.spell) and not precise_strikes() and not GS.Aura("player", shattered_defenses) then GS.Cast(_, battle_cry, _, _, _, _, "Battle Cry: Synced Colossus Smash") return end
                        end
                        if GS.Talent33 and GS.SIR(avatar) and (not GS.AuraRemaining("target", colossus_smash.debuff, 5, "", "PLAYER") or GS.Aura("target", colossus_smash.debuff, "", "PLAYER") and GS.SpellCDDuration(colossus_smash.spell) == 0) then
                            if GS.SCA(colossus_smash.spell) and not precise_strikes() and not GS.Aura("player", shattered_defenses) then GS.Cast(_, avatar, _, _, _, _, "Avatar: Synced Colossus Smash") return end
                        end
                        if GS.SIR(blood_fury) and GS.Aura("player", battle_cry) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury: Orc Racial AP") return end
                        if GS.SIR(berserking) and GS.Aura("player", battle_cry) then GS.Cast(_, berserking, _, _, _, _, "Berserking: Troll Racial") return end
                        if GS.SIR(arcane_torrent) and rage("deficit") > 40 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent: Blood Elf Racial Warrior") return end
                    end
                    -- actions+=/heroic_leap,if=buff.shattered_defenses.down
                    if GS.Talent32 and GS.SCA(rend) and GS.AuraRemaining("target", rend, GS.GCD(), "", "PLAYER") then GS.Cast(_, rend, _, _, _, _, "Rend: Less than GCD") return end
                    if GS.Talent61 and GS.SCA(hamstring) and GS.Aura("player", battle_cry) then GS.Cast(_, hamstring, _, _, _, _, "Hamstring: Free") return end
                    if GS.SCA(colossus_smash.spell) and not GS.Aura("target", colossus_smash.debuff, "", "PLAYER") then GS.Cast(_, colossus_smash.spell, _, _, _, _, "", "PLAYER") return end
                    -- actions+=/warbreaker,if=debuff.colossus_smash.down
                    if GS.Talent73 and GS.SIR(ravager) then
                        if GS.AoE then
                            GS.SmartAoE(40, 8, true)
                            GS.Cast(_, ravager, rotationXC, rotationYC, rotationZC, _, "Ravager: AoE")
                            return
                        else
                            GS.Cast(_, ravager, _, _, _, _, "Ravager")
                            return
                        end
                    end
                    if GS.Talent12 and GS.SCA(overpower) then GS.Cast(_, overpower, _, _, _, _, "Overpower") return end
                    if GS.Health("target", _, true) >= 20 then -- Single
                        if GS.SCA(mortal_strike) then GS.Cast(_, mortal_strike, _, _, _, _, "Mortal Strike") return end
                        if GS.SCA(colossus_smash.spell) and not GS.Aura("player", shattered_defenses) and not precise_strikes() then GS.Cast(_, colossus_smash.spell, _, _, _, _, "Colossus Smash: No Buffs") return end
                        -- actions.single+=/warbreaker,if=buff.shattered_defenses.down
                        if GS.Talent53 and GS.SIR(focused_rage) and (not GS.AuraStacks("player", focused_rage, 3) or GS.Talent61 and GS.Aura("player", battle_cry)) then GS.Cast(_, focused_rage, _, _, _, _, "Focused Rage") return end
                        if GS.SIR(whirlwind) and GS.Distance() < 8+UnitCombatReach("target") and (GS.Talent31 and (GS.Aura("target", colossus_smash.debuff, "", "PLAYER") or rage("deficit") < 50) and not GS.Talent53 or GS.Talent61 and GS.Aura("player", battle_cry) or GS.Aura("player", cleave.buff)) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: Dump") return end
                        if GS.SCA(slam) and (not GS.Talent31 and (GS.Aura("target", colossus_smash.debuff, "", "PLAYER") or rage("deficit") < 40) and not GS.Talent53 or GS.Talent61 and GS.Aura("player", battle_cry)) then GS.Cast(_, slam, _, _, _, _, "Slam: Dump") return end
                        if GS.Talent32 and GS.SCA(rend) and GS.AuraRemaining("target", rend, 4.5, "", "PLAYER") then GS.Cast(_, rend, _, _, _, _, "Rend: Refresh") return end
                        -- actions.single+=/heroic_charge
                        if GS.Talent31 then
                            if GS.SIR(whirlwind) and GS.Distance() < 8+UnitCombatReach("target") and (not GS.Talent53 or rage() > 100 or GS.AuraStacks("player", focused_rage, 3)) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind") return end
                        else
                            if GS.SCA(slam) and (not GS.Talent53 or rage() > 100 or GS.AuraStacks("player", focused_rage, 3)) then GS.Cast(_, slam, _, _, _, _, "Slam") return end
                        end
                        if GS.SCA(execute) then GS.Cast(_, execute, _, _, _, _, "Execute") return end
                        -- actions.single+=/shockwave
                        -- actions.single+=/storm_bolt
                    else -- Execute
                        if GS.SCA(mortal_strike) and GS.Aura("player", shattered_defenses) and GS.AuraStacks("player", focused_rage, 3) then GS.Cast(_, mortal_strike, _, _, _, _, "Mortal Strike: Shattered Defenses Focused Rage") return end
                        if GS.SCA(execute) and GS.Aura("target", colossus_smash.debuff, "", "PLAYER") and (GS.Aura("player", shattered_defenses) or rage() > 100 or GS.Talent61 and GS.Aura("player", battle_cry)) then GS.Cast(_, execute, _, _, _, _, "Execute: Powered Up") return end
                        if GS.SCA(mortal_strike) and not GS.Aura("player", shattered_defenses) then GS.Cast(_, mortal_strike, _, _, _, _, "Mortal Strike: Execute") return end
                        if GS.SCA(colossus_smash.spell) and not GS.Aura("player", shattered_defenses) and not precise_strikes() then GS.Cast(_, colossus_smash.spell, _, _, _, _, "Colossus Smash: No Buffs") return end
                        -- actions.execute+=/warbreaker,if=buff.shattered_defenses.down
                        if GS.SCA(mortal_strike) then GS.Cast(_, mortal_strike, _, _, _, _, "Mortal Strike") return end
                        if GS.SCA(execute) and (GS.Aura("target", colossus_smash.debuff, "", "PLAYER") or rage() >= 100) then GS.Cast(_, execute, _, _, _, _, "Execute") return end
                        if GS.Talent53 and GS.Talent61 and GS.SIR(focused_rage) and GS.Aura("player", battle_cry) then GS.Cast(_, focused_rage, _, _, _, _, "Focused Rage") return end
                        if GS.Talent32 and GS.SCA(rend) and GS.AuraRemaining("target", rend, 4.5, "", "PLAYER") then GS.Cast(_, rend, _, _, _, _, "Rend: Refresh") return end
                        -- actions.execute+=/heroic_charge
                        -- actions.execute+=/shockwave
                        -- actions.execute+=/storm_bolt
                    end
                end
            end
        end
    end

    do -- Fury
        -- talents=2232133
        -- talent_override=massacre
        -- artifact=35:0:0:0:0:982:1:984:1:985:1:986:1:988:2:990:3:991:3:995:3:996:3:1357:1
        local bladestorm    =  46924
        local bloodbath     =  12292
        local bloodthirst   =  23881
        local dragon_roar   = 118000
        local enrage        = 184362
        local execute       =   5308
        local furious_slash = 100130
        local juggernaut    =        {buff = 201009} -- verify: Fury Warrior
        local massacre      = 206316 -- verify: Fury Warrior
        local meat_cleaver  =  85739
        local odyns_fury    = 205545 -- verify: Fury Warrior
        local raging_blow   =  85288
        local rampage       = 184367
        local whirlwind     = 190411
        local wrecking_ball = 215570
        
        function GS.WARRIOR2()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack("target")
                    if GS.CDs then
                        -- actions+=/use_item,name=faulty_countermeasure,if=(spell_targets.whirlwind>1|!raid_event.adds.exists)&((talent.bladestorm.enabled&cooldown.bladestorm.remains=0)|buff.battle_cry.up|target.time_to_die<25)
                        -- actions+=/potion,name=deadly_grace,if=(target.health.pct<20&buff.battle_cry.up)|target.time_to_die<=30
                        if GS.SIR(battle_cry) then GS.Cast(_, battle_cry, _, _, _, _, "Battle Cry: Artifact Odyn's Fury Not Enabled") return end
                        -- actions+=/battle_cry,if=(artifact.odyns_fury.enabled&cooldown.odyns_fury.remains=0&(cooldown.bloodthirst.remains=0|(buff.enrage.remains>cooldown.bloodthirst.remains)))|!artifact.odyns_fury.enabled
                        if GS.Talent33 and GS.SIR(avatar) and (GS.Aura("player", battle_cry) or GS.UnitIsBoss("target") and GS.GetTTD() < GS.SpellCDDuration(battle_cry)+10) then GS.Cast(_, avatar, _, _, _, _, "Avatar") return end
                        if GS.Talent61 and GS.SIR(bloodbath) and (GS.Aura("player", dragon_roar) or not GS.Talent73 and (GS.Aura("player", battle_cry) or GS.SpellCDDuration(battle_cry) > 10)) then GS.Cast(_, bloodbath, _, _, _, _, "Bloodbath") return end
                        if GS.SIR(blood_fury) and GS.Aura("player", battle_cry) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                        -- actions+=/berserking,if=buff.battle_cry.up
                        -- actions+=/arcane_torrent,if=rage<rage.max-40
                    end
                    if GS.AoE and GS.PlayerCount(8, _, 2, "inclusive", 3) then
                        if GS.SIR(whirlwind) and not GS.Aura("player", meat_cleaver) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: Cleave, Meat Cleaver Not Up") return end
                        -- actions.two_targets+=/call_action_list,name=bladestorm
                        if GS.SCA(rampage) and (not GS.Aura("player", enrage) or rage() == 100 and not GS.Aura("player", juggernaut.buff) or GS.Aura("player", massacre)) then GS.Cast(_, rampage, _, _, _, _, "Rampage: Cleave, Not Enraged|Not Juggernaut Execute|Free Massacre") return end
                        if GS.SCA(bloodthirst) and not GS.Aura("player", enrage) then GS.Cast(_, bloodthirst, _, _, _, _, "Bloodthirst: Cleave, Not Enraged") return end
                        if GS.SCA(raging_blow) and GS.PlayerCount(8, _, 2, "==") then GS.Cast(_, raging_blow, _, _, _, _, "Raging Blow: Cleave") return end
                        if GS.SIR(whirlwind) and GS.PlayerCount(8, _, 2, ">") then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: 3 Cleave") return end
                        if GS.Talent73 and GS.SIR(dragon_roar) then GS.Cast(_, dragon_roar, _, _, _, _, "Dragon Roar: Cleave") return end
                        if GS.SCA(bloodthirst) then GS.Cast(_, bloodthirst, _, _, _, _, "Bloodthirst: Cleave") return end
                        if GS.SIR(whirlwind) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: 2 Cleave") return end
                        return
                    end
                    if GS.AoE and GS.PlayerCount(8, _, 3, ">") then
                        if GS.SCA(bloodthirst) and (not GS.Aura("player", enrage) or rage() < 50) then GS.Cast(_, bloodthirst, _, _, _, _, "Bloodthirst: AoE, Not Enraged or Low Rage") return end
                        -- actions.aoe+=/call_action_list,name=bladestorm
                        if GS.SIR(whirlwind) and GS.Aura("player", enrage) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: AoE, Enraged") return end
                        if GS.Talent73 and GS.SIR(dragon_roar) then GS.Cast(_, dragon_roar, _, _, _, _, "Dragon Roar: AoE") return end
                        if GS.SCA(rampage) and GS.Aura("player", meat_cleaver) then GS.Cast(_, rampage, _, _, _, _, "Rampage: AoE, Meat Cleaver") return end
                        if GS.SCA(bloodthirst) then GS.Cast(_, bloodthirst, _, _, _, _, "Bloodthirst: AoE") return end
                        if GS.SIR(whirlwind) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: AoE") return end
                        return
                    end
                    -- actions.single_target=odyns_fury,if=buff.battle_cry.up|target.time_to_die<cooldown.battle_cry.remains
                    -- actions.single_target+=/execute,if=artifact.juggernaut.enabled&(!buff.juggernaut.up|buff.juggernaut.remains<2)
                    if GS.Talent32 and GS.Talent73 and GS.SIR(berserker_rage) and GS.SpellCDDuration(dragon_roar) == 0 and not GS.Aura("player", enrage) then GS.Cast(_, berserker_rage, _, _, _, _, "Berserker Rage: Not Enraged, Dragon Roar Cooled Off") return end
                    if GS.SCA(rampage) and (rage() > 95 or GS.Aura("player", massacre)) then GS.Cast(_, rampage, _, _, _, _, "Rampage: Dump|Free") return end
                    if not GS.Talent63 and GS.SIR(whirlwind) and GS.Distance("target") < 8+UnitCombatReach("target") and GS.Aura("player", wrecking_ball) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: Wrecking Ball, Inner Rage Not Talented") return end
                    if GS.SCA(raging_blow) and GS.Aura("player", enrage) then GS.Cast(_, raging_blow, _, _, _, _, "Raging Blow: Enraged") return end
                    if GS.SIR(whirlwind) and GS.Distance("target") < 8+UnitCombatReach("target") and GS.Aura("player", wrecking_ball) and GS.Aura("player", enrage) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: Wrecking Ball Enraged") return end
                    if GS.SCA(execute) and (GS.Aura("player", enrage) or GS.Aura("player", battle_cry) or GS.Aura("player", stone_heart) or GS.Aura("player", juggernaut.buff) and GS.AuraRemaining("player", juggernaut.buff, 2)) then GS.Cast(_, execute, _, _, _, _, "Execute: Enraged|Battle Cry|Stone Heart|Juggernaut About to Expire") return end
                    if GS.SCA(bloodthirst) then GS.Cast(_, bloodthirst, _, _, _, _, "Bloodthirst") return end
                    if GS.SCA(raging_blow) then GS.Cast(_, raging_blow, _, _, _, _, "Raging Blow") return end
                    if GS.Talent73 and GS.SIR(dragon_roar) and GS.Distance("target") < 8+UnitCombatReach("target") and (not GS.Talent61 and (GS.SpellCDDuration(battle_cry) < 1 or GS.SpellCDDuration(battle_cry) > 10) or GS.Talent61 and GS.SpellCDDuration(bloodbath) == 0) then GS.Cast(_, dragon_roar, _, _, _, _, "Dragon Roar") return end
                    if GS.SCA(rampage) and GS.Health("target", maxhealth, true) > 20 and (GS.SpellCDDuration(battle_cry) > 3 or GS.Aura("player", battle_cry) or rage() > 90) then GS.Cast(_, rampage, _, _, _, _, "Rampage") return end
                    if GS.SCA(execute) and (rage() > 50 or GS.Aura("player", battle_cry) or GS.Aura("player", stone_heart) or GS.GetTTD() < 20)  then GS.Cast(_, execute, _, _, _, _, "Execute: Rage Dump|Battle Cry|Stone Heart|TTD < 20") return end
                    if GS.SCA(furious_slash) then GS.Cast(_, furious_slash, _, _, _, _, "Furious Slash") return end

                    -- actions.bladestorm=bladestorm,if=buff.enrage.remains>2&(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)
                end
            end
        end
    end

    do -- Protection
        -- talents=0111201
        -- artifact=11:133763:137412:133686:0:91:1:92:1:93:1:99:3:100:6:101:3:102:3:103:1:104:1:1358:1
        local devastate = 20243
        local revenge = 6572
        local shield_slam = 23922
        local thunder_clap = 6343

        function GS.WARRIOR3()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack("target")
                    -- actions+=/use_item,name=horn_of_valor
                    -- actions+=/use_item,name=coagulated_nightwell_residue
                    -- actions+=/blood_fury
                    -- actions+=/berserking
                    -- actions+=/arcane_torrent

                    -- actions.prot=shield_block
                    -- actions.prot+=/ignore_pain

                    -- actions.prot+=/demoralizing_shout,if=incoming_damage_2500ms>health.max*0.20
                    -- actions.prot+=/shield_wall,if=incoming_damage_2500ms>health.max*0.50
                    -- actions.prot+=/last_stand,if=incoming_damage_2500ms>health.max*0.50&!cooldown.shield_wall.remains=0

                    -- actions.prot+=/potion,name=unbending_potion,if=(incoming_damage_2500ms>health.max*0.15&!buff.unbending_potion.up)|target.time_to_die<=25

                    if GS.AoE and GS.PlayerCount(8, false, 3, ">=") then
                        -- actions.prot_aoe=battle_cry
                        -- actions.prot_aoe+=/demoralizing_shout,if=talent.booming_voice.enabled&rage<=50
                        -- actions.prot_aoe+=/ravager,if=talent.ravager.enabled
                        -- actions.prot_aoe+=/neltharions_fury,if=buff.battle_cry.up
                        if GS.SCA(shield_slam) then GS.Cast(_, shield_slam, _, _, _, _, "Shield Slam: AoE") return end
                        if GS.SCA(revenge) then GS.Cast(_, revenge, _, _, _, _, "Revenge: AoE") return end
                        if GS.SIR(thunder_clap) then GS.Cast(_, thunder_clap, _, _, _, _, "Thunder Clap") return end
                        if GS.SCA(devastate) then GS.Cast(_, devastate, _, _, _, _, "Devastate: AoE") return end
                        return
                    end
                    -- actions.prot+=/battle_cry
                    -- actions.prot+=/demoralizing_shout,if=talent.booming_voice.enabled&rage<=50
                    -- actions.prot+=/ravager,if=talent.ravager.enabled
                    -- actions.prot+=/neltharions_fury,if=buff.battle_cry.up
                    if GS.SCA(shield_slam) then GS.Cast(_, shield_slam, _, _, _, _, "Shield Slam") return end
                    if GS.SCA(revenge) then GS.Cast(_, revenge, _, _, _, _, "Revenge") return end
                    if GS.SCA(devastate) then GS.Cast(_, devastate, _, _, _, _, "Devastate") return end

                end
            end
        end
    end
end