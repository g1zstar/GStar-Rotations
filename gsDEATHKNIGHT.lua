GS = GSD.RotationToggle("d")
do
    local function numberOfAvailableRunes()
        local counter = 0
        for i = 1, 6 do
            if GetRuneCount(i) == 1 then counter = counter + 1 end
        end
        return counter
    end

    local runic_power = GS.PP
    local blood_fury = 20572
    local arcane_torrent = 50613

    -- todo: create Blood Death Knight
    do -- Frost
        -- talents=1130023
        -- artifact=12:0:0:0:0:108:3:110:2:113:3:114:3:119:1:120:1:122:1:123:1:1090:3:1332:1
        local frost_strike = 49143
        local obliteration = 207256
        local killing_machine = 51124
        local frostscythe = 207230
        local breath_of_sindragosa = 152279
        local pillar_of_frost = 51271
        local howling_blast = 49184
        local frost_fever = 55095
        local glacial_advance = 194913
        local obliterate = 49020
        local remorseless_winter = 196770
        local horn_of_winter = 57330
        local empower_rune_weapon = 47568
        local hungering_rune_weapon = 207127
        local freezing_fog = 59052

        function GS.DEATHKNIGHT2()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack("target")
                    if GS.CDs then
                        if GS.SIR(arcane_torrent) and GS.PP("deficit") > 20 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial") return end
                        if GS.SIR(blood_fury) and (not GS.Talent72 or GS.Aura("player", breath_of_sindragosa)) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                        if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                        -- actions+=/use_item,slot=trinket1
                        -- actions+=/potion,type=deadly_grace
                        if GS.SIR(pillar_of_frost) then GS.Cast(_, pillar_of_frost, _, _, _, _, "Pillar of Frost") return end
                        -- actions+=/sindragosas_fury
                        if GS.Talent71 and GS.SIR(obliteration) then GS.Cast(_, obliteration, _, _, _, _, "Obliteration") return end
                        if GS.Talent72 and GS.SIR(breath_of_sindragosa) and GS.PP() >= 50 then GS.Cast(_, breath_of_sindragosa, _, _, _, _, "Breath of Sindragosa") return end
                    end
                    if GS.Aura("player", breath_of_sindragosa) then -- Breath of Sindragosa Rotation
                        if GS.SCA(howling_blast) and not GS.Aura("target", frost_fever, "", "PLAYER") then GS.Cast(_, howling_blast, _, _, _, _, "Howling Blast: Frost Fever") return end
                        if GS.Talent73 and GS.SIR(glacial_advance) then GS.Cast(_, glacial_advance, _, _, _, _, "Glacial Advance") return end
                        if GS.SCA(frost_strike) and GS.Aura("player", obliteration) and not GS.Aura("player", killing_machine) then GS.Cast(_, frost_strike, _, _, _, _, "Frost Strike: Obliteration") return end
                        if not GS.Talent72 and GS.SIR(frostscythe) and GS.PlayerCount(8, _, 1, ">=") and (GS.Aura("player", killing_machine) or GS.PlayerCount(8, _, 4, ">=")) then GS.Cast(_, frostscythe, _, _, _, _, "Frostscythe") return end
                        if GS.SCA(obliterate) and GS.Aura("player", killing_machine) then GS.Cast(_, obliterate, _, _, _, _, "Obliterate: Killing Machine") return end
                        if GS.AoE and GS.SIR(remorseless_winter) and GS.PlayerCount(8) >= 2 then GS.Cast(_, remorseless_winter, _, _, _, _, "Remorseless Winter") return end
                        if GS.SCA(obliterate) then GS.Cast(_, obliterate, _, _, _, _, "Obliterate") return end
                        if GS.Talent22 then
                            if GS.Talent61 and GS.SIR(frostscythe) and GS.PlayerCount(8, _, 1, ">=") then GS.Cast(_, frostscythe, _, _, _, _, "Frostscythe: Frozen Pulse") return end
                            if GS.SCA(howling_blast) then GS.Cast(_, howling_blast, _, _, _, _, "Howling Blast: Frozen Pulse") return end
                        end
                        if GS.Talent23 and GS.SIR(horn_of_winter) then GS.Cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
                        if not GS.Talent32 then
                            if GS.SIR(empower_rune_weapon) and runic_power() <= 70 then GS.Cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
                        else
                            if GS.SIR(hungering_rune_weapon) then GS.Cast(_, hungering_rune_weapon, _, _, _, _, "Hungering Rune Weapon") return end
                        end
                        if GS.SCA(howling_blast) and GS.Aura("player", freezing_fog) then GS.Cast(_, howling_blast, _, _, _, _, "Howling Blast: Rime") return end
                    end
                    if GS.SCA(howling_blast) and not GS.Aura("target", frost_fever, "", "PLAYER") then GS.Cast(_, howling_blast, _, _, _, _, "Howling Blast: Frost Fever") return end
                    if GS.SCA(howling_blast) and GS.Aura("player", freezing_fog) then GS.Cast(_, howling_blast, _, _, _, _, "Howling Blast: Rime") return end
                    if GS.SCA(frost_strike) and GS.PP() >= 80 then GS.Cast(_, frost_strike, _, _, _, _, "Frost Strike: Dump RP") return end
                    if GS.Talent73 and GS.SIR(glacial_advance) then GS.Cast(_, glacial_advance, _, _, _, _, "Glacial Advance") return end
                    if GS.SCA(frost_strike) and GS.Aura("player", obliteration) and not GS.Aura("player", killing_machine) then GS.Cast(_, frost_strike, _, _, _, _, "Frost Strike: Obliteration") return end
                    if not GS.Talent72 and GS.SIR(frostscythe) and GS.PlayerCount(8, _, 1, ">=") and (GS.Aura("player", killing_machine) or GS.PlayerCount(8, _, 4, ">=")) then GS.Cast(_, frostscythe, _, _, _, _, "Frostscythe") return end
                    if GS.SCA(obliterate) and GS.Aura("player", killing_machine) then GS.Cast(_, obliterate, _, _, _, _, "Obliterate: Killing Machine") return end
                    if GS.AoE and GS.SIR(remorseless_winter) and GS.PlayerCount(8) >= 2 then GS.Cast(_, remorseless_winter, _, _, _, _, "Remorseless Winter") return end
                    if GS.SCA(obliterate) then GS.Cast(_, obliterate, _, _, _, _, "Obliterate") return end
                    if GS.Talent22 then
                        if GS.Talent61 and GS.SIR(frostscythe) and GS.PlayerCount(8, _, 1, ">=") then GS.Cast(_, frostscythe, _, _, _, _, "Frostscythe: Frozen Pulse") return end
                        if GS.SCA(howling_blast) then GS.Cast(_, howling_blast, _, _, _, _, "Howling Blast: Frozen Pulse") return end
                    end
                    if GS.Talent72 and  GS.Talent23 and GS.SpellCDDuration(breath_of_sindragosa) > 15 and GS.SIR(horn_of_winter) then GS.Cast(_, horn_of_winter, _, _, _, _, "Horn of Winter: Breath of Sindragosa Not Up") return end
                    if not GS.Talent72 and  GS.Talent23 and GS.SIR(horn_of_winter) then GS.Cast(_, horn_of_winter, _, _, _, _, "Horn of Winter") return end
                    if GS.Talent72 then
                        if GS.SCA(frost_strike) and GS.SpellCDDuration(breath_of_sindragosa) > 15 then GS.Cast(_, frost_strike, _, _, _, _, "Frost Strike: Breath of Sindragosa Not Up") return end
                    else
                        if GS.SCA(frost_strike) then GS.Cast(_, frost_strike, _, _, _, _, "Frost Strike") return end
                    end
                    if GS.Talent72 then
                        if GS.SpellCDDuration(breath_of_sindragosa) > 15 then
                            if not GS.Talent32 then
                                if GS.SIR(empower_rune_weapon) then GS.Cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
                            else
                                if GS.SIR(hungering_rune_weapon) then GS.Cast(_, hungering_rune_weapon, _, _, _, _, "Hungering Rune Weapon") return end
                            end
                        end
                    else
                        if not GS.Talent32 then
                            if GS.SIR(empower_rune_weapon) then GS.Cast(_, empower_rune_weapon, _, _, _, _, "Empower Rune Weapon") return end
                        else
                            if GS.SIR(hungering_rune_weapon) then GS.Cast(_, hungering_rune_weapon, _, _, _, _, "Hungering Rune Weapon") return end
                        end
                    end
                end
            end
        end
    end

    do -- Unholy
        -- talents=3330021
        -- artifact=16:0:0:0:0:149:1:152:1:153:1:157:3:158:3:264:3:266:3:1119:3:1333:1
        local death_and_decay = 43265
        local outbreak = 77575
        local virulent_plague = 191587
        local dark_transformation = 63560
        local blighted_rune_weapon = 194918
        local death_coil = 47541
        local dark_arbiter = 207349
        local scourge_strike = 55090
        local defile = 152280
        local clawing_shadows = 207311
        local festering_strike = 85948
        local festering_wound = 194310
        local summon_gargoyle = 49206
        local sudden_doom = 81340
        local soul_reaper = 130736
        local necrosis = 216974
        local unholy_strength = 53365
        
        function GS.DEATHKNIGHT3()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    -- actions=auto_attack
                    if GS.CDs then
                        if GS.SIR(arcane_torrent) and GS.PP("deficit") > 20 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial") return end
                        if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                        if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                        -- actions+=/potion,name=deadly_grace,if=buff.unholy_strength.react
                    end
                    if GS.SCA(outbreak) and not GS.Aura("target", virulent_plague, "", "PLAYER") then GS.Cast(_, outbreak, _, _, _, _, "Outbreak: Virulent Plague Not Up") return end
                    if GS.SIR(dark_transformation) then GS.Cast(_, dark_transformation, _, _, _, _, "Dark Transformation") return end
                    if GS.Talent23 and GS.SIR(blighted_rune_weapon) then GS.Cast(_, blighted_rune_weapon, _, _, _, _, "Blighted Rune Weapon") return end
                    if GS.Talent71 and GS.SpellCDDuration(dark_arbiter) > 165 then -- Val'kyr Rotation
                        if GS.SCA(death_coil) then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Valkyr") return end
                        -- actions.valkyr+=/apocalypse,if=debuff.festering_wound.stack=8
                        -- actions.valkyr+=/festering_strike,if=debuff.festering_wound.stack<8&cooldown.apocalypse.remains<5
                        if GS.AoE and GS.PlayerCount(8) >= 2 then
                            if not GS.Talent72 and GS.SIR(death_and_decay) then
                                if #GS.SmartAoE(30, 8, true, true) >= 2 then
                                    GS.SmartAoE(30, 8)
                                    GS.Cast(_, death_and_decay, rotationXC, rotationYC, rotationZC, _, "Death and Decay")
                                    return
                                end
                            end
                            -- actions.aoe+=/epidemic,if=spell_targets.epidemic>4
                            if not GS.Talent33 then
                                if GS.SCA(scourge_strike) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and death_and_decay or defile)) > 20 then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: DnD AoE") return end
                            else
                                if GS.SCA(clawing_shadows) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and death_and_decay or defile)) > 20 then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: DnD AoE") return end
                            end
                            -- actions.aoe+=/epidemic,if=spell_targets.epidemic>2
                        end
                        if GS.SCA(festering_strike) and not GS.AuraStacks("target", festering_wound, 4, "", "PLAYER") then GS.Cast(_, festering_strike, _, _, _, _, "Festering Strike: 3 or Less Festering Wounds") return end
                        if not GS.Talent33 then
                            if GS.SCA(scourge_strike) then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: Val'kyr, Pop Festering Wounds") return end
                        else
                            if GS.SCA(clawing_shadows) then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: Val'kyr, Pop Festering Wounds") return end
                        end
                    end
                    if GS.CDs then
                        if GS.Talent71 then
                            if GS.SIR(dark_arbiter) and GS.PP() > 80 then GS.Cast(_, dark_arbiter, _, _, _, _, "Dark Arbiter") return end
                        else
                            if GS.SIR(summon_gargoyle) then GS.Cast(_, summon_gargoyle, _, _, _, _, "Summon Gargoyle") return end
                        end
                    end
                    -- actions.generic+=/apocalypse,if=debuff.festering_wound.stack=8
                    if GS.SIR(death_coil) then
                        if GS.SCA(death_coil) and GS.PP() > 80 then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Dump RP") return end
                        if GS.Talent71 then
                            if GS.SCA(death_coil) and GS.Aura("player", sudden_doom) and GS.SpellCDDuration(dark_arbiter) > 5 then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Sudden Doom, Dark Arbiter Not Up") return end
                        else
                            if GS.SCA(death_coil) and GS.Aura("player", sudden_doom) then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Sudden Doom") return end
                        end
                    end
                    -- actions.generic+=/festering_strike,if=debuff.festering_wound.stack<8&cooldown.apocalypse.remains<5
                    if GS.Talent73 then
                        if GS.SCA(soul_reaper) and GS.AuraStacks("target", festering_wound, 3, "", "PLAYER") then GS.Cast(_, soul_reaper, _, _, _, _, "Soul Reaper") return end
                        if GS.Aura("target", soul_reaper, "", "PLAYER") then
                            if GS.SCA(festering_strike) and not GS.Aura("target", festering_wound, "", "PLAYER") then GS.Cast(_, festering_strike, _, _, _, _, "Festering Strike: Soul Reaper No Festering Wounds") return end
                            if GS.Aura("target", festering_wound, "", "PLAYER") then
                                if not GS.Talent33 then
                                    if GS.SCA(scourge_strike) then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: Soul Reaper Pop Festering Wounds") return end
                                else
                                    if GS.SCA(clawing_shadows) then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: Soul Reaper Pop Festering Wounds") return end
                                end
                            end
                        end
                    end
                    if GS.Talent72 and GS.SIR(defile) then
                        GS.SmartAoE(30, 8)
                        GS.Cast(_, defile, rotationXC, rotationYC, rotationZC, _, "Defile")
                        return
                    end
                    if GS.AoE and GS.PlayerCount(8) >= 2 then
                        if not GS.Talent72 and GS.SIR(death_and_decay) then
                            if #GS.SmartAoE(30, 8, true, true) >= 2 then
                                GS.SmartAoE(30, 8)
                                GS.Cast(_, death_and_decay, rotationXC, rotationYC, rotationZC, _, "Death and Decay")
                                return
                            end
                        end
                        -- actions.aoe+=/epidemic,if=spell_targets.epidemic>4
                        if not GS.Talent33 then
                            if GS.SCA(scourge_strike) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and death_and_decay or defile)) > 20 then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: DnD AoE") return end
                        else
                            if GS.SCA(clawing_shadows) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and death_and_decay or defile)) > 20 then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: DnD AoE") return end
                        end
                        -- actions.aoe+=/epidemic,if=spell_targets.epidemic>2
                    end
                    if GS.SCA(festering_strike) and not GS.AuraStacks("target", festering_wound, 4, "", "PLAYER") then GS.Cast(_, festering_strike, _, _, _, _, "Festering Strike: 3 or Less Festering Wounds") return end
                    if not GS.Talent33 then
                        if GS.SCA(scourge_strike) and GS.Aura("player", necrosis) then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: Necrosis") return end
                        if GS.SCA(scourge_strike) and GS.Aura("player", unholy_strength) then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: Unholy Strength") return end
                        if GS.SCA(scourge_strike) and numberOfAvailableRunes() >= 2 then GS.Cast(_, scourge_strike, _, _, _, _, "Scourge Strike: 3 or more Runes Available") return end
                    else
                        if GS.SCA(clawing_shadows) and GS.Aura("player", necrosis) then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: Necrosis") return end
                        if GS.SCA(clawing_shadows) and GS.Aura("player", unholy_strength) then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: Unholy Strength") return end
                        if GS.SCA(clawing_shadows) and numberOfAvailableRunes() >= 2 then GS.Cast(_, clawing_shadows, _, _, _, _, "Clawing Shadows: 3 or more Runes Available") return end
                    end
                    if GS.SIR(death_coil) then
                        if GS.Talent61 then
                            if GS.Talent71 then
                                if GS.SCA(death_coil) and not GS.Aura("pet", dark_transformation) and GS.SpellCDDuration(dark_arbiter) > 15 then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Reduce Dark Transformation CD, Dark Arbiter Not Up") return end
                            else
                                if GS.SCA(death_coil) and not GS.Aura("pet", dark_transformation) then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Reduce Dark Transformation CD") return end
                            end
                        end
                        if GS.Talent71 then
                            if GS.SCA(death_coil) and GS.SpellCDDuration(dark_arbiter) > 15 then GS.Cast(_, death_coil, _, _, _, _, "Death Coil: Dark Arbiter Not Up") return end
                        elseif not GS.Talent61 then
                            if GS.SCA(death_coil) then GS.Cast(_, death_coil, _, _, _, _, "Death Coil") return end
                        end
                    end
                end
            end
        end
    end
end