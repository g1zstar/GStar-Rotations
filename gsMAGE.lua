GS = GSD.RotationToggle("d")
do
    do -- Arcane
        local arcane_missiles = {spell = 5143, buff = 79683}
        local arcane_barrage = 44425
        local mystic_kilt_of_the_rune_master = 132451
        local arcane_explosion = 1449
        local arcane_blast = 30451
        local nether_tempest = 114923
        local supernova = 157980
        local presence_of_mind = 205025
        local burn_phase = nil
        local burn_phase_duration = 0
        local evocation = 12051
        local rune_of_power = {spell = 116011, buff = 116014}
        local charged_up = 205032

        function GS.MAGE1()
            if not UnitAffectingCombat("player") and burn_phase then burn_phase = false; burn_phase_duration = 0 end
            if UnitAffectingCombat("player") then
                if burn_phase and GS.DebugTable["ogSpell"] == evocation and GetTime()-burn_phase_duration > GS.GCD() then burn_phase = false; burn_phase_duration = GetTime()-burn_phase_duration;print("Stopping Burn Phase: "..(burn_phase_duration)) return end
                if GS.IsCAOCH() --[[UnitChannelInfo("player") == "Arcane Missiles"]] then return end
                if GS.ValidTarget() then
                    -- actions=counterspell,if=target.debuff.casting.react
                    -- actions+=/shard_of_the_exodar_warp,if=buff.bloodlust.down
                    -- actions+=/mark_of_aluneth,if=buff.rune_of_power.up|!talent.rune_of_power.enabled
                    -- if burn_phase and GS.DebugTable["ogSpell"] == evocation and GetTime()-burn_phase_duration > GS.GCD() then burn_phase = false; burn_phase_duration = GetTime()-burn_phase_duration;print("Stopping Burn Phase: "..(burn_phase_duration)) return end
                    -- if not burn_phase and ((GS.SpellCDDuration(evocation)-2*burn_phase_duration)/2 <= burn_phase_duration or GS.CDs and GS.Talent32 and GS.SpellCDDuration(arcane_power) <= GS.CastTime(rune_of_power.spell)+GS.GCD() or GS.UnitIsBoss() and GS.GetTTD() < GS.SpellCDDuration(arcane_power)+13) and GS.DebugTable["ogSpell"] ~= evocation and GS.PP() == 4 then
                    if not burn_phase and GS.SpellCDDuration(evocation) < 26.1 then
                        print("Starting Burn Phase");burn_phase = true; burn_phase_duration = GetTime()
                    end
                    do -- call_action_list,name=build
                        if GS.PP() < 4 then
                            if GS.Talent42 and GS.SIR(charged_up) and GS.PP() <= 1 then GS.Cast(_, charged_up, _, _, _, _, "Charged Up") return end
                            -- actions.build+=/arcane_orb
                            if GS.AoE and GS.SIR(arcane_explosion) and GS.PlayerCount(10, _, 1, ">") then GS.Cast(_, arcane_explosion, _, _, _, _, "Arcane Explosion: Build") return end
                            if GS.SCA(arcane_blast) then GS.Cast(_, arcane_blast, _, _, _, _, "Arcane Blast: Build") return end
                        end
                    end
                    do -- call_action_list,name=burn
                        if burn_phase then
                            do -- call_action_list,name=cooldowns
                                if GS.CDs then
                                    -- actions.cooldowns=rune_of_power
                                    if GS.SIR(12042) then GS.Cast(_, 12042, _, _, _, _, "Arcane Power") return end
                                    -- actions.cooldowns+=/blood_fury
                                    -- actions.cooldowns+=/berserking
                                    -- actions.cooldowns+=/arcane_torrent
                                    -- actions.cooldowns+=/potion,name=deadly_grace,if=buff.arcane_power.up
                                end
                            end
                            -- actions.burn+=/mark_of_aluneth
                            if GS.Talent41 and GS.SCA(supernova) and GS.PM() < 100 then GS.Cast(_, supernova, _, _, _, _, "Supernova: Burn") return end
                            if GS.Talent61 and GS.SCA(nether_tempest) and GS.AuraRemaining("target", nether_tempest, 2, "", "PLAYER") then GS.Cast(_, nether_tempest, _, _, _, _, "Nether Tempest: Burn") return end
                            if GS.Talent12 and GS.SIR(presence_of_mind) and not GS.AuraRemaining("player", arcane_power, 2*GS.GCD()) then GS.Cast(_, presence_of_mind, _, _, _, _, "Presence of Mind: Burn") return end
                            if GS.SCA(arcane_blast) and GS.Aura("player", presence_of_mind) then GS.Cast(_, arcane_blast, _, _, _, _, "Arcane Blast: Burn, Presence of Mind") return end
                            if GS.SCA(arcane_missiles.spell) then GS.Cast(_, arcane_missiles.spell, _, _, _, _, "Arcane Missiles: Burn") return end
                            if GS.AoE and GS.SIR(arcane_explosion) and GS.PlayerCount(10, _, 1, ">") then GS.Cast(_, arcane_explosion, _, _, _, _, "Arcane Explosion: Burn") return end
                            if GS.SCA(arcane_blast) then GS.Cast(_, arcane_blast, _, _, _, _, "Arcane Blast: Burn") return end
                            if GS.SIR(evocation) then GS.Cast(_, evocation, _, _, _, _, "Evocation") return end
                        end
                    end
                    -- actions+=/rune_of_power,if=recharge_time<cooldown.arcane_power.remains
                    -- actions+=/call_action_list,name=rop_phase,if=buff.rune_of_power.up
                    do -- call_action_list,name=conserve
                        if GS.SCA(arcane_missiles.spell) and GS.AuraStacks("player", arcane_missiles.buff, 3) then GS.Cast(_, arcane_missiles.spell, _, _, _, _, "Arcane Missiles: Conserve, Capped") return end
                        if GS.Talent41 and GS.SCA(supernova) and GS.PM() < 100 then GS.Cast(_, supernova, _, _, _, _, "Supernova: Conserve") return end
                        if GS.Talent61 and GS.SCA(nether_tempest) and GS.AuraRemaining("target", nether_tempest, 3.6, "", "PLAYER") then GS.Cast(_, nether_tempest, _, _, _, _, "Nether Tempest: Conserve") return end
                        if GS.SCA(arcane_missiles.spell) then GS.Cast(_, arcane_missiles.spell, _, _, _, _, "Arcane Missiles: Conserve") return end
                        if GS.AoE and GS.SIR(arcane_explosion) and GS.PM() >= 82 and IsEquippedItem(mystic_kilt_of_the_rune_master) and GS.PlayerCount(10, _, 1, ">") then GS.Cast(_, arcane_explosion, _, _, _, _, "Arcane Explosion: Conserve") return end
                        if GS.SCA(arcane_blast) and GS.PM() >= 82 and IsEquippedItem(mystic_kilt_of_the_rune_master) then GS.Cast(_, arcane_blast, _, _, _, _, "Arcane Blast: Conserve") return end
                        if GS.SCA(arcane_barrage) then GS.Cast(_, arcane_barrage, _, _, _, _, "Arcane Barrage: Conserver") return end
                    end
                end
            end
        end
        -- actions.rop_phase=nether_tempest,,if=dot.nether_tempest.remains<=2|!ticking
        -- actions.rop_phase+=/arcane_missiles
        -- actions.rop_phase+=/arcane_explosion,if=active_enemies>2
        -- actions.rop_phase+=/arcane_blast
    end
    -- todo: create Arcane Mage
    -- todo: create Fire Mage
    -- todo: create Frost Mage

    do -- Fire
        local fireball = 133
        local pyroblast = 11366
        local hot_streak = 48108
        local kaelthas_ultimate_ability = 209455
        local koralons_burning_touch = 132454
        local combustion = 190319
        local fire_blast = 108853
        local heating_up = 48107
        local scorch = 2948
        local flame_on = 205029
        local rune_of_power = {spell = 116011, buff = 116014}
        local blast_wave = 157981
        local phoenixs_flames = 194466
        local meteor = 153561

        function GS.MAGE2()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    -- actions=counterspell,if=target.debuff.casting.react
                    -- actions+=/mirror_image,if=buff.combustion.down
                    -- actions+=/rune_of_power,if=cooldown.combustion.remains>40&buff.combustion.down&(cooldown.flame_on.remains<5|cooldown.flame_on.remains>30)&!talent.kindling.enabled|target.time_to_die.remains<11|talent.kindling.enabled&(charges_fractional>1.8|time<40)&cooldown.combustion.remains>40
                    do -- call_action_list,name=combustion_phase
                        if GS.SpellCDDuration(combustion) <= GS.CastTime(rune_of_power.spell)+(GS.Talent71 and 0 or GS.GCD()) or GS.Aura("player", combustion) then
                            -- actions.combustion_phase=rune_of_power,if=buff.combustion.down
                            -- actions.combustion_phase+=/call_action_list,name=active_talents
                            if GS.CDs and GS.SIR(combustion) then GS.Cast(_, combustion, _, _, _, _, "Combustion") return end
                            -- actions.combustion_phase+=/combustion
                            -- actions.combustion_phase+=/potion,name=deadly_grace
                            -- actions.combustion_phase+=/blood_fury
                            -- actions.combustion_phase+=/berserking
                            -- actions.combustion_phase+=/arcane_torrent
                            if GS.SCA(pyroblast) and GS.Aura("player", hot_streak) then GS.Cast(_, pyroblast, _, _, _, _, "Pyroblast: Combustion") return end
                            if GS.SCA(fire_blast) and GS.Aura("player", heating_up) then GS.Cast(_, fire_blast, _, _, _, _, "Fire Blast: Combustion") return end
                            -- actions.combustion_phase+=/phoenixs_flames
                            if GS.SCA(scorch) and not GS.AuraRemaining("player", combustion, GS.CastTime(scorch)) then GS.Cast(_, scorch, _, _, _, _, "Scorch: Combustion") return end
                            -- actions.combustion_phase+=/scorch,if=target.health.pct<=25&equipped.132454
                        end
                    end
                    -- actions+=/call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
                    do -- call_action_list,name=single_target
                        if GS.SCA(pyroblast) and GS.Aura("player", hot_streak) and GS.AuraRemaining("player", hot_streak, GS.CastTime(fireball)) then GS.Cast(_, pyroblast, _, _, _, _, "Pyroblast: Hot Streak Expiring") return end
                        -- actions.single_target+=/phoenixs_flames,if=charges_fractional>2.7&active_enemies>2
                        -- actions.single_target+=/flamestrike,if=talent.flame_patch.enabled&active_enemies>2&buff.hot_streak.react
                        if GS.SCA(pyroblast) and GS.Aura("player", hot_streak) and GS.DebugTable["ogSpell"] ~= pyroblast then GS.Cast(_, pyroblast, _, _, _, _, "Pyroblast: Combine") return end
                        -- actions.single_target+=/pyroblast,if=buff.hot_streak.react&target.health.pct<=25&equipped.132454
                        -- actions.single_target+=/pyroblast,if=buff.kaelthas_ultimate_ability.react
                        -- actions.single_target+=/call_action_list,name=active_talents
                        if GS.SCA(fire_blast, "target", true) then
                            if GS.GetTTD() < 4 then GS.Cast(_, fire_blast, _, _, _, _, "Fireblast: TTD") return end
                            if GS.Aura("player", heating_up) then
                                if not GS.Talent71 then
                                    if (not GS.Talent32 or GS.FracCalc("spell", fire_blast) > 1.4 or GS.SpellCDDuration(combustion) < 40) and (3-GS.FracCalc("spell", fire_blast))*12*GS.SimCSpellHaste() < GS.SpellCDDuration(combustion)+3 then GS.Cast(_, fire_blast, _, _, _, _, "Fire Blast") return end
                                else
                                    if (not GS.Talent32 or GS.FracCalc("spell", fire_blast) > 1.5 or GS.SpellCDDuration(combustion) < 40) and (3-GS.FracCalc("spell", fire_blast))*18*GS.SimCSpellHaste() < GS.SpellCDDuration(combustion)+3 then GS.Cast(_, fire_blast, _, _, _, _, "Fire Blast") return end
                                end
                            end
                        end
                        -- actions.single_target+=/phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up|buff.incanters_flow.stack>3|talent.mirror_image.enabled)&artifact.phoenix_reborn.enabled&(4-charges_fractional)*13<cooldown.combustion.remains+5|target.time_to_die.remains<10
                        -- actions.single_target+=/phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up)&(4-charges_fractional)*30<cooldown.combustion.remains+5
                        -- actions.single_target+=/scorch,if=target.health.pct<=25&equipped.132454
                        if GS.SCA(fireball) then GS.Cast(_, fireball, _, _, _, _, "Fireball") return end
                    end
                end
            end
        end

        
        

        -- actions.rop_phase=rune_of_power
        -- actions.rop_phase+=/pyroblast,if=buff.hot_streak.up
        -- actions.rop_phase+=/call_action_list,name=active_talents
        -- actions.rop_phase+=/pyroblast,if=buff.kaelthas_ultimate_ability.react
        -- actions.rop_phase+=/fire_blast,if=!prev_off_gcd.fire_blast
        -- actions.rop_phase+=/phoenixs_flames,if=!prev_gcd.phoenixs_flames
        -- actions.rop_phase+=/scorch,if=target.health.pct<=25&equipped.132454
        -- actions.rop_phase+=/fireball

        -- actions.active_talents=flame_on,if=action.fire_blast.charges=0&(cooldown.combustion.remains>40+(talent.kindling.enabled*25)|target.time_to_die.remains<cooldown.combustion.remains)
        -- actions.active_talents+=/blast_wave,if=(buff.combustion.down)|(buff.combustion.up&action.fire_blast.charges<1&action.phoenixs_flames.charges<1)
        -- actions.active_talents+=/meteor,if=cooldown.combustion.remains>30|(cooldown.combustion.remains>target.time_to_die)|buff.rune_of_power.up
        -- actions.active_talents+=/cinderstorm,if=cooldown.combustion.remains<cast_time&(buff.rune_of_power.up|!talent.rune_on_power.enabled)|cooldown.combustion.remains>10*spell_haste&!buff.combustion.up
        -- actions.active_talents+=/dragons_breath,if=equipped.132863
        -- actions.active_talents+=/living_bomb,if=active_enemies>3&buff.combustion.down
    end

    do -- Frost
        local frostbolt = 116
        local ice_lance = 30455
        local fingers_of_frost = 44544
        local flurry = 44614
        local brain_freeze = 190446
        local ice_nova = 157997
        local icy_veins = 12472
        local frozen_orb = 84714

        function GS.MAGE3()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    -- actions=counterspell,if=target.debuff.casting.react
                    if GS.SCA(ice_lance) and not GS.Aura("player", fingers_of_frost) and GS.DebugTable["ogSpell"] == flurry then GS.Cast(_, ice_lance, _, _, _, _, "Ice Lance: Flurry") return end
                    do -- call_action_list,name=cooldowns
                        -- actions.cooldowns=rune_of_power,if=cooldown.icy_veins.remains<cast_time|charges_fractional>1.9&cooldown.icy_veins.remains>10|buff.icy_veins.up|target.time_to_die.remains+5<charges_fractional*10
                        if GS.CDs then
                            if GS.SIR(icy_veins) and not GS.Aura("player", icy_veins) then GS.Cast(_, icy_veins, _, _, _, _, "Icy Veins") return end
                            -- actions.cooldowns+=/mirror_image
                            -- actions.cooldowns+=/blood_fury
                            -- actions.cooldowns+=/berserking
                            -- actions.cooldowns+=/arcane_torrent
                            -- actions.cooldowns+=/potion,name=deadly_grace
                        end
                    end
                    if GS.SCA(ice_nova) and GS.DebugTable["ogSpell"] == flurry then GS.Cast(_, ice_nova, _, _, _, _, "Ice Nova: Flurry") return end
                    if GS.SCA(frostbolt) and GS.DebugTable["ogSpell"] == water_jet then GS.Cast(_, frostbolt, _, _, _, _, "Frostbolt: Water Jet") return end
                    -- actions+=/water_jet,if=prev_gcd.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
                    -- actions+=/ray_of_frost,if=buff.icy_veins.up|(cooldown.icy_veins.remains>action.ray_of_frost.cooldown&buff.rune_of_power.down)
                    if GS.SCA(flurry) and GS.Aura("player", brain_freeze) and not GS.Aura("player", fingers_of_frost) and GS.DebugTable["ogSpell"] == frostbolt then GS.Cast(_, flurry, _, _, _, _, "Flurry") return end
                    -- actions+=/glacial_spike
                    -- actions+=/frozen_touch,if=buff.fingers_of_frost.stack<=(0+artifact.icy_hand.enabled)
                    -- actions+=/frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&buff.fingers_of_frost.react>0
                    if GS.SCA(ice_lance) and (GS.Aura("player", fingers_of_frost) and GS.SpellCDDuration(icy_veins) > 10 or GS.AuraStacks("player", fingers_of_frost, 2--[[+artifact.icy_hand.enabled]])) then GS.Cast(_, ice_lance, _, _, _, _, "Ice Lance") return end
                    if GS.SIR(frozen_orb) then GS.Cast(_, frozen_orb, _, _, _, _, "Frozen Orb") return end
                    -- actions+=/ice_nova
                    -- actions+=/blizzard,if=(talent.arctic_gale.enabled&active_enemies>1)|active_enemies>3
                    -- actions+=/ebonbolt,if=buff.fingers_of_frost.stack<=(0+artifact.icy_hand.enabled)
                    if GS.SCA(frostbolt) then GS.Cast(_, frostbolt, _, _, _, _, "Frostbolt") return end
                end
            end
        end
    end
end