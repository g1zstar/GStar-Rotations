GS = GSD.RotationToggle("d")
do
    local blood_fury = 20572
    local arcane_torrent = 25046
    local vanish = {spell = 1856, buff = 11327} -- verify: Rogue Vanish Buff
    local stealth = {spell = 1784}
    local marked_for_death = 137619
    local death_from_above = 152150
    local combo_points = GS.CP
    local energy = GS.PP

    do -- Assassination
        local mutilate = 1329
        local garrote = 703

        local hemorrhage = 0
        local rupture = 0

        function GS.ROGUE1X()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.CDs then
                        -- actions=potion,name=deadly_grace,if=buff.bloodlust.react|target.time_to_die<=25|debuff.vendetta.up
                        -- actions+=/use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
                        -- actions+=/blood_fury,if=debuff.vendetta.up
                        -- actions+=/berserking,if=debuff.vendetta.up
                        -- actions+=/arcane_torrent,if=debuff.vendetta.up&energy.deficit>50
                    end
                    do -- call_action_list,name=cds
                    end
                    -- actions+=/rupture,if=combo_points>=2&!ticking&time<10&!artifact.urge_to_kill.enabled
                    -- actions+=/rupture,if=combo_points>=4&!ticking
                    -- actions+=/pool_resource,for_next=1
                    -- actions+=/kingsbane,if=!talent.exsanguinate.enabled&(buff.vendetta.up|cooldown.vendetta.remains>10)|talent.exsanguinate.enabled&dot.rupture.exsanguinated
                    do
                        -- actions+=/run_action_list,name=exsang_combo,if=cooldown.exsanguinate.remains<3&talent.exsanguinate.enabled&(buff.vendetta.up|cooldown.vendetta.remains>15)
                    end
                    do
                        -- actions+=/call_action_list,name=garrote,if=spell_targets.fan_of_knives<=8-artifact.bag_of_tricks.enabled
                    end
                    do
                        -- actions+=/call_action_list,name=exsang,if=dot.rupture.exsanguinated
                    end
                    -- actions+=/rupture,if=talent.exsanguinate.enabled&remains-cooldown.exsanguinate.remains<(4+cp_max_spend*4)*0.3&new_duration-cooldown.exsanguinate.remains>=(4+cp_max_spend*4)*0.3+3
                    do
                        -- actions+=/call_action_list,name=finish
                    end
                    do
                        -- actions.build=hemorrhage,cycle_targets=1,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives<=4
                        -- actions.build+=/hemorrhage,cycle_targets=1,max_cycle_targets=3,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives=5
                        -- actions.build+=/fan_of_knives,if=(spell_targets>=2+debuff.vendetta.up&(combo_points.deficit>=1|energy.deficit<=30))|(!artifact.bag_of_tricks.enabled&spell_targets>=7+2*debuff.vendetta.up)
                        -- actions.build+=/fan_of_knives,if=equipped.the_dreadlords_deceit&((buff.the_dreadlords_deceit.stack>=29|buff.the_dreadlords_deceit.stack>=15&debuff.vendetta.remains<=3)&debuff.vendetta.up|buff.the_dreadlords_deceit.stack>=5&cooldown.vendetta.remains>60&cooldown.vendetta.remains<65)
                        -- actions.build+=/hemorrhage,if=(combo_points.deficit>=1&refreshable)|(combo_points.deficit=1&(dot.rupture.exsanguinated&dot.rupture.remains<=2|cooldown.exsanguinate.remains<=2))
                        if GS.SCA(mutilate) and combo_points("deficit") <= 1 and energy("deficit") <= 30 then GS.Cast(_, mutilate, _, _, _, _, "Mutilate: Prevent Capped Energy") return end
                        if GS.SCA(mutilate) and combo_points("deficit") >= 2 and GS.SpellCDDuration(garrote) > 2 then GS.Cast(_, mutilate, _, _, _, _, "Mutilate") return end
                    end
                end
            end
        end
        -- # Cooldowns
        -- actions.cds=marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|combo_points.deficit>=5
        -- actions.cds+=/vendetta,if=target.time_to_die<20
        -- actions.cds+=/vendetta,if=artifact.urge_to_kill.enabled&dot.rupture.ticking&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains<5)&(energy<55|time<10|spell_targets.fan_of_knives>=2)
        -- actions.cds+=/vendetta,if=!artifact.urge_to_kill.enabled&dot.rupture.ticking&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains<1)
        -- actions.cds+=/vanish,if=talent.subterfuge.enabled&combo_points<=2&!dot.rupture.exsanguinated|talent.shadow_focus.enabled&!dot.rupture.exsanguinated&combo_points.deficit>=2

        -- # Exsanguinate Combo
        -- actions.exsang_combo=vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1&gcd.remains=0&energy>=25
        -- actions.exsang_combo+=/rupture,if=combo_points>=cp_max_spend&(!talent.nightstalker.enabled|buff.vanish.up|cooldown.vanish.remains>15)&cooldown.exsanguinate.remains<1
        -- actions.exsang_combo+=/exsanguinate,if=prev_gcd.rupture&dot.rupture.remains>22+4*talent.deeper_stratagem.enabled&cooldown.vanish.remains>10
        -- actions.exsang_combo+=/call_action_list,name=garrote,if=spell_targets.fan_of_knives<=8-artifact.bag_of_tricks.enabled
        -- actions.exsang_combo+=/hemorrhage,if=spell_targets.fan_of_knives>=2&!ticking
        -- actions.exsang_combo+=/call_action_list,name=build

        -- # Garrote
        -- actions.garrote=pool_resource,for_next=1
        -- actions.garrote+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&!ticking&combo_points.deficit>=1&spell_targets.fan_of_knives>=2
        -- actions.garrote+=/pool_resource,for_next=1
        -- actions.garrote+=/garrote,if=combo_points.deficit>=1&!exsanguinated

        -- # Exsanguinated Finishers
        -- actions.exsang=rupture,cycle_targets=1,max_cycle_targets=14-2*artifact.bag_of_tricks.enabled,if=!ticking&combo_points>=cp_max_spend-1&spell_targets.fan_of_knives>1&target.time_to_die-remains>6
        -- actions.exsang+=/rupture,if=combo_points>=cp_max_spend&ticks_remain<2
        -- actions.exsang+=/death_from_above,if=combo_points>=cp_max_spend-1&(dot.rupture.remains>3|dot.rupture.remains>2&spell_targets.fan_of_knives>=3)&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6+2*debuff.vendetta.up)
        -- actions.exsang+=/envenom,if=combo_points>=cp_max_spend-1&(dot.rupture.remains>3|dot.rupture.remains>2&spell_targets.fan_of_knives>=3)&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6+2*debuff.vendetta.up)

        -- # Finishers
        -- actions.finish=rupture,cycle_targets=1,max_cycle_targets=14-2*artifact.bag_of_tricks.enabled,if=!ticking&combo_points>=cp_max_spend-1&spell_targets.fan_of_knives>1&target.time_to_die-remains>6
        -- actions.finish+=/rupture,if=combo_points>=cp_max_spend-1&refreshable&!exsanguinated
        -- actions.finish+=/death_from_above,if=combo_points>=cp_max_spend-1&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
        -- actions.finish+=/envenom,if=combo_points>=cp_max_spend-1&!dot.rupture.refreshable&buff.elaborate_planning.remains<2&energy.deficit<40&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
        -- actions.finish+=/envenom,if=combo_points>=cp_max_spend&!dot.rupture.refreshable&buff.elaborate_planning.remains<2&cooldown.garrote.remains<1&(artifact.bag_of_tricks.enabled|spell_targets.fan_of_knives<=6)
    end

    -- todo: create Assassination Rogue

    do -- Outlaw
        local rollTheBonesTable = {
            193356, -- Broadsides            193356
            193357, -- Shark Infested Waters 193357
            193358, -- Grand Melee           193358
            193359, -- True Bearing          193359
            199600, -- Buried Treasure       199600
            199603, -- Jolly Roger           199603
        }
        local function rollTheBones(mode)
            if mode == "duration" then
                for i = 1, #rollTheBonesTable do
                    if GS.Aura("player", rollTheBonesTable[i]) then return (select(7, GS.Aura("player", rollTheBonesTable[i]))-GetTime()) end
                end
                return 0
            elseif mode == "count" then
                local count = 0
                for i = 1, #rollTheBonesTable do
                    if GS.Aura("player", rollTheBonesTable[i]) then count = count + 1 end
                end
                return count
            end
        end

        -- talents=1010023
        -- artifact=44:136683:137472:137365:0:1052:1:1054:1:1057:1:1060:3:1061:6:1064:3:1065:3:1066:3:1348:1
        local adrenaline_rush       =  13750
        local ambush                =   8676
        local broadsides            = 193356
        local buried_treasure       = 199600
        local cannonball_barrage    = 185767
        local ghostly_strike        = 196937
        local grand_melee           = 193358
        local jolly_roger           = 199603
        local killing_spree         =  51690
        local opportunity           = 195627
        local pistol_shot           = 185763
        local roll_the_bones        = 193316
        local run_through           =   2098
        local saber_slash           = 193315
        local shark_infested_waters = 193357
        local slice_and_dice        =   5171
        local true_bearing          = 193359
        local check = nil

        local between_the_eyes = 0 -- verify: Outlaw Rogue
        local greenskins_waterlogged_wristcuffs = 0 -- verify: Outlaw Rogue
        local thraxis_tricksy_treads = 0 -- verify: Outlaw Rogue
        
        function GS.ROGUE2() -- todo: add sprint legendary
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    do -- call_action_list,name = bf
                        -- actions.bf=cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2|spell_targets.blade_flurry<2&buff.blade_flurry.up
                        -- actions.bf+=/blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
                    end
                    do -- call_action_list,name=cds
                        if GS.CDs then
                            -- actions=potion,name=deadly_grace,if=buff.bloodlust.react|target.time_to_die<=25|buff.adrenaline_rush.up
                            -- actions.cds+=/use_item,slot=trinket2
                            if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                            if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                            if GS.SIR(arcane_torrent) and energy("deficit") > 40 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Rogue") return end
                        end
                        if GS.Talent61 and GS.SIR(cannonball_barrage) and #GS.SmartAoE(35, 6, true, true) >= 1 then
                            GS.SmartAoE(35, 6, true)
                            GS.Cast(_, cannonball_barrage, rotationXC, rotationYC, rotationZC, _, "Cannonball Barrage")
                            return
                        end
                        if GS.CDs then
                            if GS.SIR(adrenaline_rush) and not GS.Aura("player", adrenaline_rush) then GS.Cast("player", adrenaline_rush, _, _, _, _, "Adrenaline Rush") return end
                        end
                        if (not GSR.TieMarkedForDeath or GS.CDs) and GS.Talent72 and GS.SIR(marked_for_death) then
                            table.sort(GS.MobTargets, GS.SortMobTargetsByLowestTTD)
                            check = combo_points("deficit") >= 4+((GS.Talent31 or GS.Talent32) and 1 or 0)
                            for i = 1, mobTargetsSize do
                                rotationUnitIterator = GS.MobTargets[i]
                                if GS.SCA(marked_for_death, rotationUnitIterator) and (check or GS.GetTTD(rotationUnitIterator) < combo_points("deficit")) then GS.Cast(rotationUnitIterator, marked_for_death, _, _, _, _, "Marked for Death") return end
                            end
                        end
                        if GS.CDs then
                            -- actions+=/sprint,if=equipped.thraxis_tricksy_treads&combo_points>=action.run_through.cp_max_spend-1-(buff.broadsides.up&buff.jolly_roger.up)+cooldown.death_from_above.up
                        end
                        -- actions+=/curse_of_the_dreadblades,if=combo_points.deficit>=4
                    end
                    do -- call_action_list,name = stealth
                        if GS.SCA(ambush) then GS.Cast(_, ambush, _, _, _, _, "Ambush") return end
                        if GS.CDs then
                            if GetNumGroupMembers() > 1 and GS.SpellCDDuration(global_cooldown) == 0 and not IsStealthed() and combo_points("deficit") >= 2 + (GS.Talent11 and not GS.Aura("target", ghostly_strike, "", "PLAYER") and 2 or 0) + (GS.Aura("player", broadsides) and 1 or 0) and energy() > 60 and not GS.Aura("player", jolly_roger) and artifact.hidden_blade.enabled and not GS.Aura("player", curse_of_the_dreadblades) then
                                if GS.SIR(vanish.spell) then GS.Cast(_, vanish.spell, _, _, _, _, "Vanish") return end
                                if GS.SIR(shadowmeld) then GS.Cast(_, shadowmeld, _, _, _, _, "Shadowmeld") return end
                            end
                        end
                    end
                    if GS.Talent73 and GS.SCA(death_from_above) and energy("tomax") > 2 and combo_points >= ((GS.Talent31 and 6 or 5)-(GS.Aura("player", broadsides) and GS.Aura("player", jolly_roger) and 1 or 0)) then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                    if GS.Talent71 then
                        if GS.SIR(slice_and_dice) and combo_points() >= 5 and GS.AuraRemaining("player", slice_and_dice, GS.GetTTD()) and GS.AuraRemaining("player", slice_and_dice, (1+combo_points())*1.8) then GS.Cast("player", slice_and_dice, _, _, _, _, "Slice and Dice") return end
                    else
                        if GS.SIR(roll_the_bones) and combo_points() >= 5 and rollTheBones("duration") < GS.GetTTD() and (rollTheBones("duration") <= 3 or rollTheBones("count") <= 1 and (not IsEquippedItem(thraxis_tricksy_treads or not GS.Aura("player", true_bearing)))) then GS.Cast("player", roll_the_bones, _, _, _, _, "Roll The Bones") return end
                    end
                    if GS.CDs and GS.Talent63 and GS.SCA(killing_spree) and ((energy("deficit"))/GetPowerRegen() > 5 or energy() < 15) then GS.Cast(_, killing_spree, _, _, _, _, "Killing Spree") return end
                    

                    if combo_points() >= (GS.Talent31 and 5 or 4) - (GS.Aura("player", broadsides) and GS.Aura("player", jolly_roger) and 1 or 0) + (GS.Talent73 and GS.SpellCDDuration(death_from_above) == 0 and 1 or 0) then
                        if GS.SCA(between_the_eyes) and IsEquippedItem(greenskins_waterlogged_wristcuffs) and GS.Aura("player", shark_infested_waters) then GS.Cast(_, between_the_eyes, _, _, _, _, "Between the Eyes") return end
                        if GS.SCA(run_through) and (not GS.Talent73 or energy("tomax") < GS.SpellCDDuration(death_from_above)+3.5) then GS.Cast(_, run_through, _, _, _, _, "Run Through") return end
                    else
                        if GS.Talent11 and GS.SCA(ghostly_strike) and GS.AuraRemaining("target", ghostly_strike, 4.5, "", "PLAYER") then GS.Cast(_, ghostly_strike, _, _, _, _, "Ghostly Strike") return end
                        if GS.SCA(pistol_shot) and GS.Aura("player", opportunity) and (energy("deficit")/GetPowerRegen()) > 2 then GS.Cast(_, pistol_shot, _, _, _, _, "Pistol Shot") return end
                        if GS.SCA(saber_slash) then GS.Cast(_, saber_slash, _, _, _, _, "Saber Slash") return end
                    end
                end
            end
        end
    end

    do -- Subtlety
        -- talents=2210011
        -- artifact=17:141277:133122:141277:0:851:1:852:3:853:3:854:3:858:3:859:3:860:3:862:1:864:1:1349:1
        local backstab              =     53
        local eneveloping_shadows   = 206237
        local eviscerate            = 196819
        local gloomblade            = 200758
        local nightblade            = 195452
        local shadow_blades         = 121471
        local shadow_dance          =        {spell = 185313, buff = 185422}
        local shadowstrike          = 185438
        local shuriken_storm        = 197835
        local symbols_of_death      = 212283
        local the_dreadlords_deceit = 228224 -- buff, verify: Subtlety Rogue
        local check = nil

        function GS.ROGUE3()
            if UnitAffectingCombat("player") then
                GS.MultiDoT("Nightblade")
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.CDs then -- call_action_list,name=cds
                        -- actions.cds=potion,name=deadly_grace,if=buff.bloodlust.react|target.time_to_die<=25|buff.shadow_blades.up
                        -- actions.cds+=/use_item,slot=trinket2
                        if IsStealthed() or GS.Aura("player", shadow_dance.buff) then
                            if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                            if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                            if GS.SIR(arcane_torrent) and energy("deficit") > 70 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Rogue") return end
                        end
                        if GS.SIR(shadow_blades) and not GS.Aura("player", shadow_blades) then GS.Cast(_, shadow_blades, _, _, _, _, "Shadow Blades") return end
                        -- actions.cds+=/goremaws_bite,if=(combo_points.deficit>=2&energy.deficit>55&time<10)|(combo_points.deficit>=4&energy.deficit>45)|target.time_to_die<8
                    end
                    if (not GSR.TieMarkedForDeath or GS.CDs) and GS.Talent72 and GS.SIR(marked_for_death) then
                        table.sort(GS.MobTargets, GS.SortMobTargetsByLowestTTD)
                        check = combo_points("deficit") >= 4+((GS.Talent31 or GS.Talent32) and 1 or 0)
                        for i = 1, mobTargetsSize do
                            rotationUnitIterator = GS.MobTargets[i]
                            if GS.SCA(marked_for_death, rotationUnitIterator) and (check or GS.GetTTD(rotationUnitIterator) < combo_points("deficit")) then GS.Cast(rotationUnitIterator, marked_for_death, _, _, _, _, "Marked for Death") return end
                        end
                    end
                    if (IsStealthed() or GS.Aura("player", shadow_dance.buff) or GS.Aura("player", shadowmeld)) then -- run_action_list,name=stealthed
                        if GS.SIR(symbols_of_death) and not GS.Aura("player", shadowmeld) and GS.AuraRemaining("player", symbols_of_death, GS.GetTTD()-4) and GS.AuraRemaining("player", symbols_of_death, 10.5) and not GS.Aura("player", shadowmeld) then GS.Cast(_, symbols_of_death, _, _, _, _, "Symbols of Death") return end
                        if combo_points() >= 5 then
                            if GS.Talent63 and GS.SIR(enveloping_shadows) and GS.AuraRemaining("player", enveloping_shadows, GS.GetTTD()) and GS.AuraRemaining("player", enveloping_shadows, 6*combo_points()*0.3) then GS.Cast(_, enveloping_shadows, _, _, _, _, "Enveloping Shadows") return end
                            if GS.AoE and GS.Talent73 and GS.SCA(death_from_above) and GS.PlayerCount(8) >= 10 then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                            if not GS.AoE then
                                if GS.SCA(nightblade) and GS.GetTTD() < math.huge and GS.GetTTD() > 10 and GS.AuraRemaining("target", nightblade, 4.8, "", "PLAYER") then GS.Cast(_, nightblade, _, _, _, _, "Nightblade") return end
                            else
                                table.sort(GS.MobTargets, GS.SortMobTargetsByHighestTTD)
                                for i = 1, mobTargetsSize do
                                    rotationUnitIterator = GS.MobTargets[i]
                                    if GS.GetTTD(rotationUnitIterator) > 10 then
                                        if GS.GetTTD(rotationUnitIterator) == math.huge then break end
                                        if GS.SCA(nightblade, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, nightblade, 4.8, "", "PLAYER") then GS.Cast(rotationUnitIterator, nightblade, _, _, _, _, "Nightblade: Cleave Highest TTD") return end
                                    else
                                        break
                                    end
                                end
                            end
                            if GS.Talent73 and GS.SCA(death_from_above) then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                            if GS.SCA(eviscerate) then GS.Cast(_, eviscerate, _, _, _, _, "Eviscerate") return end
                        end
                        if GS.AoE and GS.SIR(shuriken_storm) and not GS.Aura("player", shadowmeld) and (combo_points("deficit") >= 3 and GS.PlayerCount(10, false, 3, ">=") or GS.AuraStacks("player", the_dreadlords_deceit, 29)) then GS.Cast(_, shuriken_storm, _, _, _, _, "Shuriken Storm: Stealthed") return end
                        if GS.SCA(shadowstrike) then GS.Cast(_, shadowstrike, _, _, _, _, "Shadowstrike") return end
                        return
                    end
                    if combo_points() >= 5 or GS.AoE and combo_points >= 4 and GS.PlayerCount(10, _, 3, "inclusive", 4)  then -- call_action_list,name=finish
                        if GS.Talent63 and GS.SIR(enveloping_shadows) and GS.AuraRemaining("player", enveloping_shadows, GS.GetTTD()) and GS.AuraRemaining("player", enveloping_shadows, combo_points()*1.8) then GS.Cast(_, enveloping_shadows, _, _, _, _, "Enveloping Shadows") return end
                        if GS.AoE and GS.Talent73 and GS.SCA(death_from_above) and GS.PlayerCount(8) >= 10 then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                        if not GS.AoE then
                            if GS.SCA(nightblade) and GS.GetTTD() < math.huge and GS.GetTTD() > 10 and GS.AuraRemaining("target", nightblade, 4.8, "", "PLAYER") then GS.Cast(_, nightblade, _, _, _, _, "Nightblade") return end
                        else
                            table.sort(GS.MobTargets, GS.SortMobTargetsByHighestTTD)
                            for i = 1, mobTargetsSize do
                                rotationUnitIterator = GS.MobTargets[i]
                                if GS.GetTTD(rotationUnitIterator) > 10 then
                                    if GS.GetTTD(rotationUnitIterator) == math.huge then break end
                                    if not GS.AuraRemaining(rotationUnitIterator, nightblade, 4.8, "", "PLAYER") then
                                        break
                                    elseif GS.SCA(nightblade, rotationUnitIterator) then
                                        GS.Cast(rotationUnitIterator, nightblade, _, _, _, _, "Nightblade: Cleave Highest TTD")
                                        return
                                    end
                                else
                                    break
                                end
                            end
                        end
                        if GS.Talent73 and GS.SCA(death_from_above) then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                        if GS.SCA(eviscerate) then GS.Cast(_, eviscerate, _, _, _, _, "Eviscerate") return end
                    end
                    if combo_points("deficit") >= 2+(GS.Talent61 and 1 or 0) and (energy("deficit") <= 20 or energy("deficit") <= 45 and GS.Talent71 or GS.SIR(shadowmeld) and not GS.SIR(vanish) and GetSpellCharges(shadow_dance.spell) <= 1) then -- Stealth CDs
                        if GS.SIR(shadow_dance.spell) and GetSpellCharges(shadow_dance.spell) >= 3 then GS.Cast(_, shadow_dance, _, _, _, _, "Shadow Dance: Capped Charges") return end
                        if GS.CDs and GetNumGroupMembers() > 1 and GS.SIR(vanish) then GS.Cast(_, vanish, _, _, _, _, "Vanish") return end
                        if GS.SIR(shadow_dance.spell) and GetSpellCharges(shadow_dance.spell) >= 2 then GS.Cast(_, shadow_dance, _, _, _, _, "Shadow Dance: Prevent Capped") return end
                        if GS.CDs and GetNumGroupMembers() > 1 and GS.SIR(shadowmeld) and energy < 40 then if toggleLog then GS.Log("Pooling for Shadowmeld"); toggleLog = false end return end
                        if GS.CDs and GetNumGroupMembers() > 1 and GS.SIR(shadowmeld) and energy() >= 40 then GS.Cast(_, shadowmeld, _, _, _, _, "Shadowmeld") return end
                        if GS.SIR(shadow_dance.spell) then GS.Cast(_, shadow_dance, _, _, _, _, "Shadow Dance") return end
                    end
                    if energy("deficit") <= 20 or energy("deficit") <= 45 and GS.Talent71 then -- Builder
                        if GS.AoE and GS.SIR(shuriken_storm) and GS.PlayerCount(10) >= 2 then GS.Cast(_, shuriken_storm, _, _, _, _, "Shuriken Storm: Cleave") return end
                        if GS.Talent13 then
                            if GS.SCA(gloomblade) then GS.Cast(_, gloomblade, _, _, _, _, "Gloomblade") return end
                        else
                            if GS.SCA(backstab) then GS.Cast(_, backstab, _, _, _, _, "Backstab") return end
                        end
                    end
                end
            end
        end
    end
end