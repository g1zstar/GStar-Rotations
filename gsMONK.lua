GS = GSD.RotationToggle("d")
do
    local blood_fury = 33697
    -- todo: create Brewmaster Monk
    -- todo: create Mistweaver Monk

    do -- Brewmaster
        function GS.MONK1()
            if UnitAffectingCombat("player") or UnitAffectingCombat("focus") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.Talent13 and GS.SCA(115098, "player") then GS.Cast("player", 115098, _, _, _, _, "Chi Wave") return end
                    if GS.Talent72 and GS.SCA(205523) then GS.Cast(_, 205523, _, _, _, _, "Blackout Strike: Blackout Combo") return end
                    if GS.SCA(121253) then GS.Cast(_, 121253, _, _, _, _, "Keg Smash") return end
                    if GS.AoE and GS.PlayerCount(8, _, 2, ">=") then
                        if GS.Talent11 and GS.SIR(123986) then GS.Cast(_, 123986, _, _, _, _, "Chi Burst") return end
                        if GS.SIR(115181) and GS.Aura("target", 121253, "", "PLAYER") then GS.Cast(_, 115181, _, _, _, _, "Breath of Fire: AoE") return end
                        if GS.Talent61 and GS.SIR(116847) then GS.Cast(_, 116847, _, _, _, _, "Rushing Jade Wind") return end
                    end
                    if GS.SCA(100780) and GS.PP() >= 65 then GS.Cast(_, 100780, _, _, _, _, "Tiger Palm") return end
                    if GS.SCA(205523) then GS.Cast(_, 205523, _, _, _, _, "Blackout Strike") return end
                    if GS.Talent61 and GS.SIR(116847) then GS.Cast(_, 116847, _, _, _, _, "Rushing Jade Wind") return end
                    if GS.SIR(115181) and GS.Aura("target", 121253, "", "PLAYER") and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, 115181, _, _, _, _, "Breath of Fire") return end
                end
            end
        end
    end
    
    do -- Mistweaver
        local function findJadeSerpentStatue()
            if not GetTotemInfo(1) then return false end
            local unitPlaceholder = nil
            for i = 1, ObjectCount() do
                unitPlaceholder = ObjectWithIndex(i)
                if UnitName(unitPlaceholder) == "Jade Serpent Statue" and UnitCreator(unitPlaceholder) == ObjectPointer("player") then return unitPlaceholder end
            end
            return false
        end

        local function checkJadeSerpentStatuePosition(statue, range)
            if not statue then return false end
            local unitPlaceholder = nil
            local counter = 0
            for i = 1, allyTargetsSize do
                unitPlaceholder = GS.AllyTargets[i].Player
                if ObjectExists(unitPlaceholder) and GS.Distance(unitPlaceholder, statue) <= range then counter = counter + 1 end
            end
            return counter >= #GS.SmartAoEFriendly(40, range, true)
        end

        local function healingElixirs()
            if GS.Talent51 and GS.SIR(122281) then
                if GS.Health("player", _, true) < 85 then GS.Cast(_, 122281, _, _, _, _, "Healing Elixir") return end
            else
                return false
            end
        end

        function GS.Monk.ZenPulse()
            if GS.Talent12 and GS.SIR(124081) then
                if UnitExists("focus") and GS.SCA(124081, "focus", true) then
                    local mobCount = GS.FocusCount(8)
                    local healingAmount = mobCount*GS.HealingAmount("Zen Pulse")
                    if (GS.Health("focus", _, _, true) > GS.HealingAmount("Enveloping Mist") and healingAmount > GS.HealingAmount("Enveloping Mist") or GS.Aura("focus", 124682, "", "PLAYER") and healingAmount > GS.HealingAmount("Effuse") and GS.Health("focus", _, _, true) > GS.HealingAmount("Effuse")) then
                        if GS.SCA(124081, "focus", true) then GS.Cast("focus", 124081, _, _, _, "Soothing Mist", "Zen Pulse: RaF") return end
                    else
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
        end

        function GS.Monk.RenewingMist()
            if GS.SIR(115151) then
                table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)
                for i = 1, allyTargetsSize do
                    rotationUnitIterator = GS.AllyTargets[i].Player
                    if GS.SCA(115151, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, 119611, "", "PLAYER") --[[GS.AuraRemaining(rotationUnitIterator, 119611, 6, "", "PLAYER")]] then
                        if GS.SIR(116680) then GS.Cast(_, 116680, _, _, _, "Soothing Mist", "Thunder Focus Tea: Renewing Mist") return end
                        GS.Cast(rotationUnitIterator, 115151, _, _, _, "Soothing Mist", "Renewing Mist: Greatest Deficit")
                        return
                    end
                end
            else
                return false
            end
        end

        function GS.Monk.EssenceFont()
            if GS.SIR(191837) and UnitChannelInfo("player") ~= "Essence Font" then
                local essenceFontMax = GS.HealingAmount("Essence Font")*3
                local healingCounter, healingAmount = 0, 0
                table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)
                for i = 1, allyTargetsSize do
                    rotationUnitIterator = GS.AllyTargets[i].Player
                    if GS.Distance(rotationUnitIterator) < 25 then
                        healingCounter = healingCounter + 1
                        healingAmount = healingAmount + math.min(essenceFontMax, GS.Health(rotationUnitIterator, _, _, true))
                    end
                    if healingCounter >= 6 then break end
                end
                if healingAmount >= essenceFontMax*GSR.EssenceFontPercent then GS.Cast(_, 191837, _, _, _, "Soothing Mist", "Essence Font") return end
            else
                return false
            end
        end

        local vivifyTable = {}
        function GS.Monk.Vivify()
            if GS.SIR(116670) and allyTargetsSize > 1 then
                local vivifyMax = GS.HealingAmount("Vivify")
                local currentHealingAmount, greatestHealingAmount, chosenTarget = 0, (GSR.VivifyPercent*vivifyMax-1), nil
                local tempCount, tempGUID = 0, nil
                table.sort(GS.AllyTargets, GS.SortAllyTargetsByLowestDistance)
                table.wipe(vivifyTable)
                for i = 1, allyTargetsSize do
                    rotationUnitIterator = GS.AllyTargets[i].Player
                    tempCount = 0
                    if GS.SCA(116670, rotationUnitIterator, true) then
                        currentHealingAmount = math.min(GS.Health(rotationUnitIterator, _, _, true), vivifyMax)
                        if i == 1 then
                            for v = (i+1), allyTargetsSize do
                                if GS.Health(GS.AllyTargets[v].Player, _, true) < 100 then currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[v].Player, _, _, true), vivifyMax); tempCount = tempCount + 1 end
                                if tempCount >= 2 then break end
                            end
                        elseif i == allyTargetsSize then
                            currentHealingAmount = math.min(vivifyMax, GS.Health(rotationUnitIterator, _, _, true))
                            for v = (allyTargetsSize-1), 1, -1 do
                                if GS.Health(GS.AllyTargets[v].Player, _, true) < 100 then currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[v].Player, _, _, true), vivifyMax); tempCount = temptCount + 1 end
                                if tempCount >= 2 then break end
                            end
                        else
                            currentHealingAmount = math.min(GS.Health(rotationUnitIterator, _, _, true), vivifyMax)
                            repeat
                                for j = (i-1), 1, -1 do
                                    if GS.Health(GS.AllyTargets[j].Player, _, true) < 100 and not vivifyTable[j] then
                                        for k = (i+1), allyTargetsSize do
                                            if GS.Health(GS.AllyTargets[k].Player, _, true) < 100 and not vivifyTable[k] then tempGUID = GS.AllyTargets[k].Player break end
                                        end
                                        if GS.Distance(GS.AllyTargets[j].Player, rotationUnitIterator) <= GS.Distance(tempGUID, rotationUnitIterator) then
                                            vivifyTable[j] = true
                                            tempCount = tempCount + 1
                                            currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[j].Player, _, _, true), vivifyMax)
                                        end
                                        tempGUID = nil
                                        break
                                    else
                                        vivifyTable[j] = true
                                    end
                                end
                                if tempCount < 2 then
                                    for k = (i+1), allyTargetsSize do
                                        if GS.Health(GS.AllyTargets[k].Player, _, true) < 100 and not vivifyTable[k] then
                                            for j = (i-1), 1, -1 do
                                                if GS.Health(GS.AllyTargets[j].Player, _, true) < 100 and not vivifyTable[j] then tempGUID = GS.AllyTargets[j].Player break end
                                            end
                                            if GS.Distance(GS.AllyTargets[k].Player, rotationUnitIterator) <= GS.Distance(tempGUID, rotationUnitIterator) then
                                                vivifyTable[k] = true
                                                tempCount = tempCount + 1
                                                currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[k].Player, _, _, true), vivifyMax)
                                            end
                                            tempGUID = nil
                                            break
                                        else
                                            vivifyTable[k] = true
                                        end
                                    end
                                end
                            until (tempCount >= 2 or #vivifyTable == allyTargetsSize-1)
                        end
                        if currentHealingAmount > greatestHealingAmount then
                            greatestHealingAmount = currentHealingAmount
                            chosenTarget = rotationUnitIterator
                        end
                    end
                end
                if chosenTarget then
                    if GS.SIR(116680) and GS.Aura("player", 197206) then GS.Cast(_, 116680, _, _, _, "Soothing Mist", "Thunder Focus Tea: Vivify Uptrance") return end
                    GS.Cast(chosenTarget, 116670, _, _, _, "Soothing Mist", "Vivify")
                    return
                end
            else
                return false
            end
        end

        function GS.Monk.EnvelopingMist()
            if GS.SIR(124682) then
                table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)
                for i = 1, allyTargetsSize do
                    rotationUnitIterator = GS.AllyTargets[i].Player
                    if GS.Health(rotationUnitIterator, _, _, true) >= GS.HealingAmount("Enveloping Mist")*GSR.EnvelopingMistPercent then
                        if GS.SCA(124682, rotationUnitIterator, true) and GS.AuraRemaining(rotationUnitIterator, 124682, (GS.Talent33 and 2.1 or 1.8), "", "PLAYER") then GS.Cast(rotationUnitIterator, 124682, _, _, _, "Soothing Mist", "Enveloping Mist") return end
                    else
                        break
                    end
                end
                return false
            else
                return false
            end
        end

        function GS.Monk.Effuse()
            if GS.SIR(116694) then
                table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)
                for i = 1, allyTargetsSize do
                    rotationUnitIterator = GS.AllyTargets[i].Player
                    if GS.Health(rotationUnitIterator, _, _, true) >= GS.HealingAmount("Effuse")*GSR.EffusePercent then
                        if GS.Talent63 and GS.IsCH() and GS.Monk.SoothingMistTarget == UnitGUID(rotationUnitIterator) or not GS.Talent63 and GS.Aura(rotationUnitIterator, 115175, "", "PLAYER") then break end
                        if GS.SCA(116694, rotationUnitIterator, true) then GS.Cast(rotationUnitIterator, 116694, _, _, _, "Soothing Mist", "Effuse") return end
                    else
                        break
                    end
                end
                return false
            else
                return false
            end
        end
        
        function GS.Fistweave()
            -- if UnitAffectingCombat("player") or UnitExists("focus") and UnitAffectingCombat("focus") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.SCA(107428, "target", true) and (not GS.Talent73 or GS.SpellCDDuration(116680) > GS.GCD()) then GS.Cast(_, 107428, _, _, _, "Soothing Mist", "Rising Sun Kick: Fistweave") return end
                    if GS.SCA(100784, "target", true) and (not GS.Talent32 or GS.AuraStacks("player", 202090, 3)) and GS.SpellCDDuration(107428) > GS.GCD() then GS.Cast(_, 100784, _, _, _, "Soothing Mist", "Blackout Kick: Fistweave") return end
                    if GS.SCA(100780, "target", true) and not GS.AuraStacks("player", 202090, 3) then GS.Cast(_, 100780, _, _, _, "Soothing Mist", "Tiger Palm: Fistweave") return end
                end
            -- end
        end

        function GS.MONK290() -- Mistweaver todo: fix vivify crash
            if UnitAffectingCombat("player") or UnitExists("focus") and UnitAffectingCombat("focus") then
                if GetTime() > GS.SpellThrottle and not GS.IsCA() then
                    -- Renewing Mist 115151 , Buff 119611
                    -- Effuse 116694
                    -- Enveloping Mist 124682, Buff 124682
                    -- Vivify 116670, Uplifting Trance Proc 197206
                    -- Essence Font 191837
                    -- Thunder Focus Tea 116680

                    if GS.Talent63 and GS.SIR(115313) and (not findJadeSerpentStatue() or not checkJadeSerpentStatuePosition(findJadeSerpentStatue(), 40)) then
                        GS.SmartAoEFriendly(40, 40)
                        GS.Cast("player", 115313, rotationXC, rotationYC, rotationZC, "Soothing Mist", "Jade Serpent Statue")
                        return
                    end
                    
                    if GetNumGroupMembers() < 6 then
                        healingElixirs()
                        GS.Monk.ZenPulse()
                        GS.Monk.RenewingMist()
                        GS.Monk.EssenceFont()
                        -- GS.Monk.Vivify()
                        GS.Monk.EnvelopingMist()
                        GS.Monk.Effuse()
                    else
                        -- GS.Monk.HealingElixirs()
                        -- GS.Monk.RenewingMist()

                        -- GS.Monk.ZenPulse()
                        -- GS.Monk.EssenceFont()
                        -- GS.Monk.Vivify()
                        -- GS.Monk.EnvelopingMist()
                        -- GS.Monk.Effuse()
                    end
                    -- if (GS.Talent32 or GS.Talent73) and not GS.Aura("player", 116680) then GS.Fistweave() end
                end
            end
        end
    end

    do -- Windwalker
        -- talents=3020022
        -- artifact=50:0:0:0:0:800:3:821:3:824:3:828:1:829:3:831:1:832:1:833:1:1094:3:1341:1
        local touch_of_death = 115080
        local storm_earth_and_fire = 137639
        local serenity = 152173
        local fists_of_fury = 113656
        local rising_sun_kick = 107428
        local energizing_elixir = 115288
        local rushing_jade_wind = 116847
        local whirling_dragon_punch = 152175
        local chi_wave = 115098
        local chi_burst = 123986
        local blackout_kick = 100784
        local blackout_kick_combo = 116768
        local tiger_palm = 100780
        local invoke_xuen_the_white_tiger = 123904
        local arcane_torrent = 129597
        local spinning_crane_kick = 101546

        function GS.MONK3()
            if UnitAffectingCombat("player") then
                if GS.IsCH() then return end
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.CDs then
                        if GS.Talent62 and GS.SCA(invoke_xuen_the_white_tiger) then GS.Cast(_, invoke_xuen_the_white_tiger, _, _, _, _, "Invoke Xuen, the White Tiger") return end
                        -- actions+=/potion,name=deadly_grace,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
                        if GS.SCA(touch_of_death) then GS.Cast(_, touch_of_death, _, _, _, _, "Touch of Death") return end
                            -- actions+=/touch_of_death,if=!artifact.gale_burst.enabled
                            -- actions+=/touch_of_death,if=artifact.gale_burst.enabled&cooldown.strike_of_the_windlord.remains<8&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
                        if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial ASP") return end
                        if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                        if GS.SIR(arcane_torrent) and GS.CP("deficit") >= 1 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Monk") return end
                        if not GS.Talent73 and GS.SIR(storm_earth_and_fire) and not GS.Aura("player", storm_earth_and_fire) and GS.SpellCDDuration(fists_of_fury) <= 9 and GS.SpellCDDuration(rising_sun_kick) <= 5 then GS.Cast(_, storm_earth_and_fire, _, _, _, _, "Storm, Earth, and Fire") return end
                            -- actions+=/storm_earth_and_fire,if=artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<14&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
                            -- actions+=/storm_earth_and_fire,if=!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
                        if GS.Talent73 and GS.SIR(serenity) and GS.SpellCDDuration(fists_of_fury) <= 3 and GS.SpellCDDuration(rising_sun_kick) < 8 then GS.Cast(_, serenity, _, _, _, _, "Serenity") return end
                            -- actions+=/serenity,if=artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains<7&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
                            -- actions+=/serenity,if=!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
                    end
                    if GS.Talent31 and GS.SIR(energizing_elixir) and GS.PP("deficit") > 0 and GS.CP() <= 1 and not GS.Aura("player", serenity) then GS.Cast(_, energizing_elixir, _, _, _, _, "Energizing Elixir") return end
                    if GS.Talent61 and GS.SIR(rushing_jade_wind) and GS.Aura("player", serenity) and GS.Monk.LastCast ~= rushing_jade_wind then GS.Cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind: Free Serenity") return end
                    -- actions+=/strike_of_the_windlord
                    if GS.Talent72 and GS.SIR(whirling_dragon_punch) and not GS.IsCH() and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, whirling_dragon_punch, _, _, _, _, "Whirling Dragon Punch") return end
                    if GS.SCA(fists_of_fury) then GS.Cast(_, fists_of_fury, _, _, _, _, "Fists of Fury") return end
                    if (not GS.AoE or GS.PlayerCount(8) < 3) then -- Single Target
                        if GS.SCA(rising_sun_kick) then GS.Cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
                        if GS.Talent61 and GS.SIR(rushing_jade_wind) and GS.CP() > 1 and GS.Monk.LastCast ~= rushing_jade_wind then GS.Cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
                        if GS.Talent13 and GS.SCA(chi_wave) and (((GS.PP("deficit"))/GetPowerRegen()) > 2 or not GS.Aura("player", serenity)) then GS.Cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
                        if GS.Talent11 and GS.SIR(chi_burst) and (GS.PP("deficit")/GetPowerRegen() > 2 or not GS.Aura("player", serenity)) then GS.Cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
                        if GS.SCA(blackout_kick) and (GS.CP() > 1 or GS.Aura("player", blackout_kick_combo)) and not GS.Aura("player", serenity) and GS.Monk.LastCast ~= blackout_kick then GS.Cast(_, blackout_kick, _, _, _, _, "Blackout Kick") return end
                        if GS.SCA(tiger_palm) and not GS.Aura("player", serenity) and GS.CP() <= 2 and (GS.Monk.LastCast ~= tiger_palm) then GS.Cast(_, tiger_palm, _, _, _, _, "Tiger Palm") return end
                    else -- AoE
                        if GS.SIR(spinning_crane_kick) and GS.Monk.LastCast ~= spinning_crane_kick then GS.Cast(_, spinning_crane_kick, _, _, _, _, "Spinning Crane Kick") return end
                        -- actions.aoe+=/strike_of_the_windlord
                        if GS.Talent61 and GS.SIR(rushing_jade_wind) and GS.CP() >= 2 and GS.Monk.LastCast ~= rushing_jade_wind then GS.Cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
                        if GS.Talent13 and GS.SCA(chi_wave) and (((GS.PP("deficit"))/GetPowerRegen()) > 2 or not GS.Aura("player", serenity)) then GS.Cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
                        if GS.Talent11 and GS.SIR(chi_burst) and (GS.PP("deficit")/GetPowerRegen() > 2 or not GS.Aura("player", serenity)) then GS.Cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
                        if GS.SCA(tiger_palm) and not GS.Aura("player", serenity) and GS.CP() <= 2 and GS.Monk.LastCast ~= tiger_palm then GS.Cast(_, tiger_palm, _, _, _, _, "Tiger Palm") return end
                    end
                    -- actions.opener=blood_fury
                    -- actions.opener+=/berserking
                    -- actions.opener+=/arcane_torrent,if=chi.max-chi>=1
                    -- actions.opener+=/fists_of_fury,if=buff.serenity.up&buff.serenity.remains<1.5
                    -- if GS.SCA(107428) then GS.Cast(_, 107428, _, _, _, _, "Rising Sun Kick") return end
                    -- actions.opener+=/blackout_kick,if=chi.max-chi<=1&cooldown.chi_brew.up|buff.serenity.up
                    -- actions.opener+=/serenity,if=chi.max-chi<=2
                    -- actions.opener+=/tiger_palm,if=chi.max-chi>=2&!buff.serenity.up
                end
            end
        end
    end
end