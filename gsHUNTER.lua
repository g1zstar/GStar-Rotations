GS = GSD.RotationToggle("d")
do
    local focus = GS.PP
    local arcane_torrent = 80483 -- verify: Hunter
    local blood_fury = 20572
    local a_murder_of_crows = 131894
    local barrage = 120360
    local multishot = 2643

    do -- Beast Mastery
        -- talents=1102012
        -- artifact=56:0:0:0:0:869:3:872:3:874:3:875:3:878:1:881:1:882:1:1095:3:1336:1
        local aspect_of_the_wild = 193530
        local beast_cleave       = 118455
        local bestial_wrath      =  19574
        local chimaera_shot      =  53209
        local cobra_shot         = 193455
        local dire_beast         = 120679
        local dire_frenzy        = 217200
        local kill_command       =  34026
        local stampede           = 201430

        function GS.HUNTER1()
            if UnitAffectingCombat("player") then
                if GS.IsCH() then return end
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.CDs then
                        if GS.SIR(arcane_torrent) and focus("deficit") >= 30 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Hunter") return end
                        if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                        if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                    end
                    if GS.Talent61 and GS.SCA(a_murder_of_crows) then GS.Cast(_, a_murder_of_crows, _, _, _, _, "A Murder of Crows") return end
                    if GS.CDs and GS.Talent71 and GS.SIR(stampede) and (GS.Bloodlust() or GS.Aura("player", bestial_wrath) or GS.SpellCDDuration(bestial_wrath) <= 2 or GS.UnitIsBoss("target") and GS.GetTTD() <= 14) then GS.Cast("target", stampede, _, _, _, _, "Stampede") return end
                    if GS.SpellCDDuration(bestial_wrath) > 2 then
                        if not GS.Talent22 then
                            if GS.SCA(dire_beast) then GS.Cast(_, dire_beast, _, _, _, _, "Dire Beast") return end
                        else
                            if GS.SCA(dire_frenzy) then GS.Cast(_, dire_frenzy, _, _, _, _, "Dire Frenzy") return end
                        end
                    end
                    if GS.CDs and GS.SIR(aspect_of_the_wild) and GS.Aura("player", bestial_wrath) then GS.Cast(_, aspect_of_the_wild, _, _, _, _, "Aspect of the Wild") return end
                    if GS.Talent62 and GS.SIR(barrage) and (GS.AoE and GS.TargetCount(8) > 1 or GS.TargetCount(8) == 1 and focus() > 90) then GS.Cast(_, barrage, _, _, _, _, "Barrage") return end
                    -- actions+=/titans_thunder,if=cooldown.dire_beast.remains>=3|buff.bestial_wrath.up&pet.dire_beast.active
                    if GS.SIR(bestial_wrath) then GS.Cast(_, bestial_wrath, _, _, _, _, "Bestial Wrath") return end
                    if GS.AoE and GS.SCA(multishot) and GS.TargetCount(8) > 4 and GS.AuraRemaining("pet", beast_cleave, GS.GCD()) then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot: Beast Cleave") return end
                    if GS.SIR(kill_command) then
                        if GSR.KillCommandPet then
                            if UnitExists("pettarget") and GS.Distance("pet", "pettarget") < 25 then GS.Cast("pettarget", kill_command, _, _, _, _, "Kill Command: Pet") return end
                        else
                            if GS.Distance("target", "pet") < 25 then GS.Cast(_, kill_command, _, _, _, _, "Kill Command") return end
                        end
                    end
                    if GS.AoE and GS.SCA(multishot) and GS.TargetCount(8) > 1 and GS.AuraRemaining("pet", beast_cleave, GS.GCD()*2) then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot: Beast Cleave") return end
                    if GS.Talent23 and GS.SCA(chimaera_shot) and focus() < 90 then GS.Cast(_, chimaera_shot, _, _, _, _, "Chimaera Shot") return end
                    if GS.SCA(cobra_shot) and (GS.Talent72 and (GS.SpellCDDuration(bestial_wrath) >= 4 and GS.Aura("player", bestial_wrath) and GS.SpellCDDuration(kill_command) >= 2 or focus() > 119) or not GS.Talent72 and focus() > 90) then GS.Cast(_, cobra_shot, _, _, _, _, "Cobra Shot") return end
                end
            end
        end
    end

    do -- Marksmanship
        -- talents=1103021
        -- artifact=55:0:0:0:0:307:1:308:1:310:1:312:3:313:2:315:3:319:3:320:3:322:1:1337:1
        local aimed_shot = 19434
        local arcane_shot = 185358
        local black_arrow = 194599
        local bullseye = 204090 -- verify: Marksmanship Hunter
        local hunters_mark = 185365
        local marked_shot = 185901
        local marking_targets = 223138
        local piercing_shot = 198670
        local sentinel = 206817
        local sidewinders = 214579
        local steady_focus = 193534
        local true_aim = 199803
        local trueshot = 193526
        local vulnerable = 187131

        function GS.HUNTER2()
            if UnitAffectingCombat("player")  then
                if GS.IsCH() then return end
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack("target")
                    if GS.CDs then
                        if GS.SIR(arcane_torrent) and focus("deficit") >= 30 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Hunter") return end
                        if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                        if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                        if GS.SIR(trueshot) and (GS.GetTTD() < math.huge and GS.GetTTD() > 195 or GS.UnitIsBoss() and GS.Health("target", _, true) < 5 or GS.AuraStacks("player", bullseye, 16)) then GS.Cast(_, trueshot, _, _, _, _, "Trueshot") return end
                    end
                    if GS.SCA(marked_shot) and not GS.Talent71 and GS.DebugTable["ogSpell"] == sentinel and GS.Aura("target", hunters_mark, "", "PLAYER") then GS.Cast(_, marked_shot, _, _, _, _, "Marked Shot: Sentinel") return end
                    if GS.Talent13 and GS.Health("target", _, true) > 80 and (not GS.AoE or not GS.Talent62 or GS.TargetCount(8) == 1) then
                        -- actions.careful_aim=windburst
                        if GS.SCA(arcane_shot) and (GS.Talent12 and not GS.Aura("player", steady_focus) or GS.Talent23 and (not GS.Aura("target", true_aim, "", "PLAYER") and focus("deficit")/GetPowerRegen() >= 2 or GS.AuraRemaining("target", true_aim, 2, "", "PLAYER"))) then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot: Careful Aim, Steady Focus|True Aim") return end
                        if GS.SCA(marked_shot) and (GS.Talent71 and (not GS.Talent43 or GS.AuraRemaining("target", vulnerable, 2, "", "PLAYER")) or not GS.Talent71) then GS.Cast(_, marked_shot, _, _, _, _, "Marked Shot: Careful Aim") return end
                        if GS.SCA(aimed_shot) and not GS.Aura("target", hunters_mark, "", "PLAYER") and not GS.AuraRemaining("target", vulnerable, GS.CastTime(aimed_shot), "", "PLAYER") then GS.Cast(_, aimed_shot, _, _, _, _, "Aimed Shot: Careful Aim") return end
                        if not GS.Talent71 then
                            if GS.AoE and GS.SCA(multishot) and GS.TargetCount(8) > 1 and (GS.Aura("player", marking_targets) or focus("deficit")/GetPowerRegen() >= 2) then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot: Careful Aim") return end
                            if GS.SCA(arcane_shot) and (GS.Aura("player", marking_targets) or focus("deficit")/GetPowerRegen() >= 2) then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot: Careful Aim") return end
                        else
                            if GS.SCA(sidewinders) and not GS.Aura("target", hunters_mark, "", "PLAYER") and (GS.Aura("player", marking_targets) or GS.Aura("player", trueshot) or GetSpellCharges(sidewinders) == 2 or focus() < 80 and GetSpellCharges(sidewinders) <= 1 and GS.ChargeCD(sidewinders) <= 5) then GS.Cast(_, sidewinders, _, _, _, _, "Sidewinders: Careful Aim") return end
                        end
                    end
                    if GS.Talent61 then
                        if GS.SCA(a_murder_of_crows) then GS.Cast(_, a_murder_of_crows, _, _, _, _, "A Murder of Crows") return end
                    elseif GS.Talent62 then
                        if GS.SCA(barrage) then GS.Cast(_, barrage, _, _, _, _, "Barrage") return end
                    end
                    if GS.Talent72 and not GS.Talent43 and focus() > 50 then GS.Cast(_, piercing_shot, _, _, _, _, "Piercing Shot: Patientless Sniper") return end
                    -- actions+=/windburst
                    if not GS.Talent43 then
                        if not GS.Talent71 then
                            if GS.AoE and GS.TargetCount(8) > 1 and GS.SCA(multishot) and not GS.AuraStacks("target", vulnerable, 3, "", "PLAYER") and GS.Aura("player", marking_targets) and not GS.Aura("target", hunters_mark, "", "PLAYER") then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot") return end
                            if GS.SCA(arcane_shot) and not GS.AuraStacks("target", vulnerable, 3, "", "PLAYER") and GS.Aura("player", marking_targets) and not GS.Aura("target", hunters_mark, "", "PLAYER") then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot: Mark Targets To Build 3 Vulnerable Stacks") return end
                        end
                        if GS.SCA(marked_shot) and (not GS.AuraStacks("target", vulnerable, 3, "", "PLAYER") or GS.AuraRemaining("target", hunters_mark, 5, "", "PLAYER") or focus() < 50 or focus() > 80) then GS.Cast(_, marked_shot, _, _, _, _, "Marked Shot: Build Vulnerable Stacks|Hunter's Mark About to Expire|Focus Management") end
                        if GS.AoE and GS.Talent42 and not GS.Talent71 and GS.SCA(sentinel) and not GS.Aura("target", hunters_mark, "", "PLAYER") and GS.TargetCount(8) > 1 then GS.Cast(_, sentinel, _, _, _, _, "Sentinel") return end
                        -- actions.patientless+=/explosive_shot
                        if GS.SCA(aimed_shot) and not GS.Aura("target", hunters_mark, "", "PLAYER") and not GS.AuraRemaining("target", vulnerable, GS.CastTime(aimed_shot), "", "PLAYER") then GS.Cast(_, aimed_shot, _, _, _, _, "Aimed Shot") return end
                        if GS.SCA(marked_shot) and not GS.AuraRemaining("target", hunters_mark, 5, "", "PLAYER") then GS.Cast(_, marked_shot, _, _, _, _, "Marked Shot") end
                        if GS.Talent22 and GS.SCA(black_arrow) then GS.Cast(_, black_arrow, _, _, _, _, "Black Arrow: Patientless") return end
                        if not GS.Talent71 then
                            if GS.AoE and GS.TargetCount(8) > 1 and GS.SCA(multishot) and GetPowerRegen()*(GS.CastTime(aimed_shot)+GS.GCD()) <= focus("deficit") then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot") return end
                            if GS.SCA(arcane_shot) and GetPowerRegen()*(GS.CastTime(aimed_shot)+GS.GCD()) <= focus("deficit") then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot") return end
                        end
                    end
                    if not GS.Talent71 then
                        if GS.SCA(arcane_shot) and GS.Talent23 and not GS.AuraStacks("target", true_aim, 1, "", "PLAYER") and focus("deficit")/GetPowerRegen() >= 2 then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot: True Aim") return end
                        if GS.AoE and GS.SCA(multishot) and GS.TargetCount(8) > 1  and GS.Talent12 and not GS.Aura("player", steady_focus) and (focus("deficit")/GetPowerRegen()) >= 2 then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot: Steady Focus") return end
                        if GS.SCA(arcane_shot) and GS.Talent12 and not GS.Aura("player", steady_focus) and focus("deficit")/GetPowerRegen() >= 2 then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot: Steady Focus") return end
                    else
                        if GS.AoE and GS.SCA(sidewinders) and GS.PlayerCount(8, _, 1, ">") and not GS.Aura("target", hunters_mark, "", "PLAYER") and (GS.Aura("player", marking_targets) or GS.Aura("player", trueshot) or GetSpellCharges(sidewinders) == 2 or focus() < 80 and GetSpellCharges(sidewinders) <= 1 and GS.ChargeCD(sidewinders) <= 5) then GS.Cast(_, sidewinders, _, _, _, _, "Sidewinders: AoE Mark") return end
                    end
                    -- actions+=/explosive_shot
                    if GS.Talent72 and GS.Talent43 and focus() > 80 then GS.Cast(_, piercing_shot, _, _, _, _, "Piercing Shot: Patient Sniper") return end
                    if GS.SCA(marked_shot) and (GS.Talent71 and (not GS.Talent43 or GS.AuraRemaining("target", vulnerable, 2, "", "PLAYER")) or not GS.Talent71) then GS.Cast(_, marked_shot, _, _, _, _, "Marked Shot") return end
                    if GS.SCA(aimed_shot) and not GS.AuraRemaining("target", vulnerable, GS.CastTime(aimed_shot), "", "PLAYER") and (focus()+GetPowerRegen()*GS.CastTime(aimed_shot) > 80 or not GS.Aura("target", hunters_mark, "", "PLAYER")) then GS.Cast(_, aimed_shot, _, _, _, _, "Aimed Shot") return end
                    if GS.Talent22 and GS.SCA(black_arrow) then GS.Cast(_, black_arrow, _, _, _, _, "Black Arrow") return end
                    if not GS.Talent71 then
                        if GS.AoE and GS.SCA(multishot) and GS.TargetCount(8) > 1 and (not GS.Aura("target", hunters_mark, "", "PLAYER") and not GS.Aura("player", marking_targets) and (GS.GCD()+GS.CastTime(aimed_shot))*GetPowerRegen() <= focus("deficit")) then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot") return end
                        if GS.SCA(arcane_shot) and (not GS.Aura("target", hunters_mark, "", "PLAYER") and GS.Aura("player", marking_targets) or focus("deficit")/GetPowerRegen() >= 2) then GS.Cast(_, arcane_shot, _, _, _, _, "Arcane Shot") return end
                    else
                        if GS.SCA(sidewinders) and not GS.Aura("target", hunters_mark, "", "PLAYER") and (GS.Aura("player", marking_targets) or GS.Aura("player", trueshot) or GetSpellCharges(sidewinders) == 2 or focus() < 80 and GetSpellCharges(sidewinders) <= 1 and GS.ChargeCD(sidewinders) <= 5) then GS.Cast(_, sidewinders, _, _, _, _, "Sidewinders") return end
                    end
                end
            end
        end
    end

    do -- Survival
        local function checkSerpentSting()
            table.sort(GS.MobTargets, GS.SortMobTargetsByLowestDistance)
            local unitPlaceholder = nil
            local counter = 0
            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if UnitExists(unitPlaceholder) then
                    if GS.Distance(unitPlaceholder)-UnitCombatReach(unitPlaceholder) <= 8 then
                        if GS.AuraRemaining(unitPlaceholder, 118253, GS.GCD(), "", "PLAYER") then return true end
                    else
                        break
                    end
                end
            end
            return false
        end

        -- talents=3302022
        -- artifact=34:0:0:0:0:1068:1:1070:2:1072:3:1073:3:1075:3:1076:3:1080:1:1082:1:1084:1:1338:1
        local a_murder_of_crows = 206505
        local explosive_trap = 191433
        local dragonsfire_grenade = 194855
        local carve = 187708
        local raptor_strike = 186270
        local serpent_sting = 118253
        local moknathal_tactics = 201081
        local aspect_of_the_eagle = 186289
        local mongoose_bite = 190928
        local mongoose_fury = 190931
        local lacerate = 185855
        local snake_hunter = 201078
        local flanking_strike = 202800
        local butchery = 212436
        local throwing_axes = 200163

        function GS.HUNTER3()
            if UnitAffectingCombat("player") then
                if GS.IsCH() then return end
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    if GS.CDs then
                        if GS.SIR(arcane_torrent) and focus("deficit") >= 30 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Hunter") return end
                        if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                        if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                    end
                    -- actions+=/steel_trap
                    if GS.SIR(explosive_trap) then GS.Cast(_, explosive_trap, _, _, _, _, "Explosive Trap") return end
                    if GS.Talent62 and GS.SCA(dragonsfire_grenade) then GS.Cast(_, dragonsfire_grenade, _, _, _, _, "Dragonsfire Grenade") return end
                    -- actions+=/caltrops
                    if GS.Talent63 and GS.AoE then
                        if GS.PlayerCount(8) >= 3 then
                            if GS.SIR(carve) and checkSerpentSting() then GS.Cast(_, carve, _, _, _, _, "Carve: Serpent Sting") return end
                        elseif GS.PlayerCount(8) == 2 then
                            if GS.SCA(raptor_strike) and GS.AuraRemaining("target", serpent_sting, GS.GCD()) then GS.Cast(_, raptor_strike, _, _, _, _, "Raptor Strike: Serpent Sting") return end
                            for i = 1, mobTargetsSize do
                                rotationUnitIterator = GS.MobTargets[i]
                                if GS.SCA(raptor_strike, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, serpent_sting, GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, raptor_strike, _, _, _, _, "Raptor Strike: Serpent Sting") return end
                            end
                        end
                    end
                    if GS.Talent13 and GS.SCA(raptor_strike) and GS.AuraRemaining("player", moknathal_tactics, GS.GCD()) then GS.Cast(_, raptor_strike, _, _, _, _, "Raptor Strike: Mok'Nathal Tactics") return end
                    if GS.CDs and GS.SIR(aspect_of_the_eagle) and GS.SIR(mongoose_bite) then GS.Cast("player", aspect_of_the_eagle, _, _, _, _, "Aspect of the Eagle") return end
                    -- actions+=/fury_of_the_eagle,if=buff.mongoose_fury.up&(buff.mongoose_fury.stack=6|action.mongoose_bite.charges=0&cooldown.snake_hunter.remains|buff.mongoose_fury.remains<=gcd.max*2)
                    if GS.SCA(mongoose_bite) and (GS.Aura("player", aspect_of_the_eagle) and (GetSpellCharges(mongoose_bite) >= 2 or GetSpellCharges(mongoose_bite) >= 1 and GS.ChargeCD(mongoose_bite) <= 2) or GS.Aura("player", mongoose_fury) --[[or cooldown.fury_of_the_eagle.remains<5]] or GetSpellCharges(mongoose_bite) == 3) then GS.Cast(_, mongoose_bite, _, _, _, _, "Mongoose Bite") return end
                    if GS.Talent21 and GS.SCA(a_murder_of_crows) then GS.Cast(_, a_murder_of_crows, _, _, _, _, "A Murder of Crows") return end
                    if GS.SCA(lacerate) and (GS.Aura("target", lacerate, "", "PLAYER") and GS.AuraRemaining("target", lacerate, 3, "", "PLAYER") or --[[GS.UnitIsBoss("target")]]GS.GetTTD() < math.huge and GS.GetTTD() >= 5) then GS.Cast(_, lacerate, _, _, _, _, "Lacerate") return end
                    if GS.Talent23 and GS.SIR(snake_hunter) and (GetSpellCharges(mongoose_bite) <= 1 and not GS.AuraRemaining("player", mongoose_fury, GS.GCD()*4) or GetSpellCharges(mongoose_bite) == 0 and GS.Aura("player", aspect_of_the_eagle)) then GS.Cast(_, snake_hunter, _, _, _, _, "Snake Hunter") return end
                    if GS.SCA(flanking_strike) and (GS.Talent13 and not GS.AuraRemaining("player", moknathal_tactics, 3) or not GS.Talent13) then GS.Cast(_, flanking_strike, _, _, _, _, "Flanking Strike") return end
                    if GS.AoE then
                        if GS.Talent61 then
                            if GS.SIR(butchery) and GS.PlayerCount(8) >= 2 then GS.Cast(_, butchery, _, _, _, _, "Butchery") return end
                        else
                            if GS.SIR(carve) and GS.PlayerCount(8) >= 4 then GS.Cast(_, carve, _, _, _, _, "Carve") return end
                        end
                    end
                    -- actions+=/spitting_cobra
                    if GS.Talent12 then
                        if GS.SCA(throwing_axes) then GS.Cast(_, throwing_axes, _, _, _, _, "Throwing Axes") return end
                    else
                        if GS.SCA(raptor_strike) and focus() > 75 - GS.SpellCDDuration(flanking_strike) * GetPowerRegen() then GS.Cast(_, raptor_strike, _, _, _, _, "Raptor Strike") return end
                    end
                end
            end
        end
    end
end