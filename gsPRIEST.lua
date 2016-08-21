GS = GSD.RotationToggle("d")
do
    -- todo: create Discipline Priest
    -- todo: create Holy Priest

    do -- Shadow
        local function voidformInsanity(mode)
            if mode == "drain" then
                return 9+(GS.Priest.Voidform.DrainStacks-1)/2
            elseif mode == "count" then
                return GS.Priest.Voidform.DrainStacks
            end
        end

        -- talents=1211111
        -- artifact=47:142063:142057:142063:0:764:1:767:3:768:1:770:1:771:3:772:3:774:3:775:3:777:3:1347:1
        local voidform = 194249
        local surrender_to_madness = 193223
        local shadow_crash = 205385
        local mindbender = 200174
        local dispersion = 47585
        local power_infusion = 10060
        local void_bolt = 205448
        local void_eruption = 228260
        local shadow_word_pain = 589
        local vampiric_touch = 34914
        local mind_blast = 8092
        local shadow_word_death = 32379
        local shadowfiend = 34433
        local shadow_word_void = 205351
        local mind_sear = 48045
        local mind_flay = 15407
        local mind_spike = 73510

        function GS.PRIEST3() -- todo: check vampiric touch throttling
            if UnitAffectingCombat("player") then
                GS.MultiDoT("Shadow Word: Pain")
                GS.MultiDoT("Vampiric Touch")
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    -- actions=use_item,slot=trinket2
                    -- actions+=/potion,name=deadly_grace,if=buff.bloodlust.react|target.time_to_die<=40

                    if GS.Aura("player", voidform) then -- VF
                        if GS.Aura("player", surrender_to_madness) then -- StM
                            if GS.Talent62 and GS.SIR(shadow_crash) then
                                GS.SmartAoE(40, 8)
                                GS.Cast(_, shadow_crash, rotationXC, rotationYC, rotationZC, "nextTick", "Shadow Crash")
                                return
                            end
                            if GS.Talent63 and GS.SCA(mindbender, "target", true) then GS.Cast(_, mindbender, _, _, _, "nextTick", "Mindbender") return end
                            if GS.CDs and GS.SIR(dispersion) and not GS.Aura("player", power_infusion) and not GS.Aura("player", berserking) and not GS.Bloodlust() then GS.Cast(_, dispersion, _, _, _, "nextTick", "Dispersion: Pause Void Form Stacks") return end
                            if GS.CDs and GS.Talent61 and GS.SIR(power_infusion) and GS.AuraStacks("player", voidform, 10) then GS.Cast(_, power_infusion, _, _, _, "nextTick", "Power Infusion: Voidform") return end
                            -- actions.s2m+=/berserking,if=buff.voidform.stack>=10
                            if GS.SIR(void_bolt) then
                                if GS.SCA(void_bolt, "target", true) and GS.GetTTD() > 10 then
                                    if GS.Aura("target", shadow_word_pain, "", "PLAYER") and GS.Aura("target", vampiric_touch, "", "PLAYER") and GS.AuraRemaining("target", shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") and GS.AuraRemaining("target", vampiric_touch, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain and Vampiric Touch") return end
                                    if GS.Aura("target", shadow_word_pain, "", "PLAYER") and GS.AuraRemaining("target", shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") and (GS.Talent52 or GS.Talent53) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                    if GS.Aura("target", vampiric_touch, "", "PLAYER") and GS.AuraRemaining("target", vampiric_touch, 3.5*GS.GCD()) and (GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]]) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Vampiric Touch") return end
                                    -- actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1    
                                end
                                if GS.AoE then
                                    table.sort(GS.tShadowWordPain, GS.SortMobTargetsByHighestTTD)
                                    table.sort(GS.tVampiricTouch, GS.SortMobTargetsByHighestTTD)
                                    for i = 1, #GS.tShadowWordPain do
                                        rotationUnitIterator = GS.tShadowWordPain[i]
                                        if GS.GetTTD(rotationUnitIterator) > 10 then
                                            if GS.SCA(void_bolt, rotationUnitIterator, true) then
                                                if GS.AuraRemaining(rotationUnitIterator, shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") and GS.Aura(rotationUnitIterator, vampiric_touch, "", "PLAYER") and GS.AuraRemaining(rotationUnitIterator, vampiric_touch, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, void_eruption, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Shadow Word Pain and Vampiric Touch") return end
                                                if (GS.Talent52 or GS.Talent53) and GS.AuraRemaining(rotationUnitIterator, shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                            end
                                        else
                                            break
                                        end
                                    end

                                    if GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]] then
                                        for i = 1, #GS.tVampiricTouch do
                                            rotationUnitIterator = GS.tVampiricTouch[i]
                                            if GS.GetTTD(rotationUnitIterator) > 10 then
                                                if GS.SCA(void_bolt, rotationUnitIterator, true) then
                                                    if GS.AuraRemaining(rotationUnitIterator, vampiric_touch, 3.5*GS.GCD()) then GS.Cast(rotationUnitIterator, void_eruption, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Vampiric Touch") return end
                                                end
                                            else
                                                break
                                            end
                                        end
                                    end

                                    -- if artifact.sphere_of_insanity.rank then
                                    --     for i = 1, #GS.tShadowWordPain do
                                    --         rotationUnitIterator = GS.tShadowWordPain[i]
                                --             if GS.GetTTD(rotationUnitIterator) > 10 then
                                --                 if GS.SCA(void_bolt, rotationUnitIterator, true) then
                                --                     actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1
                                --                 end
                                --             else
                                --                 break
                                --             end
                                    --     end
                                    -- end
                                end
                            end
                            if GS.SCA(void_bolt, "target", true) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt") return end
                            -- actions.s2m+=/void_torrent
                            -- actions.s2m+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100
                            -- actions.s2m+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+90)<100
                            if GS.SCA(mind_blast, "target", true) then GS.Cast(_, mind_blast, _, _, _, "nextTick", "Mind Blast") return end
                            if GS.SCA(shadow_word_death, "target", true) and GetSpellCharges(shadow_word_death) == 2 then GS.Cast(_, shadow_word_death, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                            if GS.CDs and not GS.Talent63 and GS.SCA(shadowfiend, "target", true) and GS.AuraStacks("player", voidform, 16) then GS.Cast(_, shadowfiend, _, _, _, "nextTick", "Shadowfiend") return end
                            if GS.Talent13 and GS.SCA(shadow_word_void, "target", true) and (GS.PP()-(voidformInsanity("drain")*GS.GCD())+75) < 100 then GS.Cast(_, shadow_word_void, _, _, _, "nextTick", "Shadow Word Void: Voidform") return end
                            if GS.SIR(shadow_word_pain) then
                                if GS.SCA(shadow_word_pain, "target", true) and not GS.Aura("target", shadow_word_pain, "", "PLAYER") then
                                    GS.Cast(_, shadow_word_pain, _, _, _, "nextTick", "Shadow Word Pain: Not Up")
                                    return
                                elseif GS.AoE then
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(shadow_word_pain, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, shadow_word_pain, "", "PLAYER") then GS.Cast(rotationUnitIterator, shadow_word_pain, _, _, _, "nextTick", "Shadow Word Pain: AoE Not Up") return end
                                    end
                                end
                            end
                            if GS.SIR(vampiric_touch) then
                                if GS.SCA(vampiric_touch, "target", true) and not GS.Aura("target", vampiric_touch, "", "PLAYER") then
                                    GS.Cast(_, vampiric_touch, _, _, _, "nextTick", "Vampiric Touch: Not Up")
                                    return
                                elseif GS.AoE then
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(vampiric_touch, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, vampiric_touch, "", "PLAYER") then GS.Cast(rotationUnitIterator, vampiric_touch, _, _, _, "nextTick", "Vampiric Touch: Not Up") return end
                                    end
                                end
                            end
                            if GS.SpellCDDuration(void_bolt) < (GS.GCD()*0.75) then if toggleLog then GS.Log("Waiting for Void Bolt"); toggleLog = false end return end
                            if GS.AoE and GS.SCA(mind_sear, "target", true) and GS.TargetCount(10) >= 3 then GS.Cast(_, mind_sear, _, _, _, "nextTick Mind Flay", "Mind Sear") return end
                            if not GS.Talent72 then
                                if GS.SCA(mind_flay, "target", true) and UnitChannelInfo("player") and (select(6, UnitChannelInfo("player"))/1000-GetTime()) <= (.75/(1+GetHaste()*.01)) then GS.Cast(_, mind_flay, _, _, _, "chain", "Mind Flay: Chain") return end
                                if GS.SCA(mind_flay) then GS.Cast(_, mind_flay, _, _, _, _, "Mind Flay") return end
                            else
                                if GS.SCA(mind_spike) then GS.Cast(_, mind_spike, _, _, _, _, "Mind Spike") return end
                            end
                            if GS.SCA(shadow_word_pain) then GS.Cast(_, shadow_word_pain, _, _, _, _, "Shadow Word: Pain") return end
                            return
                        end
                        -- #vf
                        -- actions.vf=surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)&target.time_to_die<=0.8*(45+((raw_haste_pct*100)*(2+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank))))-(buff.insanity_drain_stacks.stack+25*nonexecute_actors_pct)
                        if GS.Talent62 and GS.SIR(shadow_crash) then
                            GS.SmartAoE(40, 8)
                            GS.Cast(_, shadow_crash, rotationXC, rotationYC, rotationZC, "nextTick", "Shadow Crash")
                            return
                        end
                        if GS.Talent63 and GS.SCA(mindbender, "target", true) then GS.Cast(_, mindbender, _, _, _, "nextTick", "Mindbender") return end
                        -- if GS.CDs and GS.SIR(dispersion) and not GS.Aura("player", power_infusion) and not GS.Aura("player", berserking) and not GS.Bloodlust() --[[and artifact.void_torrent.rank]] then GS.Cast(_, dispersion, _, _, _, "nextTick", "Dispersion: Pause Void Form Stacks") return end
                        if GS.CDs and GS.Talent61 and GS.SIR(power_infusion) and GS.AuraStacks("player", voidform, 10) and voidformInsanity("count") <= 30 then GS.Cast(_, power_infusion, _, _, _, _, "Power Infusion: Voidform") return end
                        -- actions.vf+=/berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.stack<=20
                        if GS.SIR(void_bolt) then
                            if GS.SCA(void_bolt, "target", true) and GS.GetTTD() > 10 then
                                if GS.Aura("target", shadow_word_pain, "", "PLAYER") and GS.Aura("target", vampiric_touch, "", "PLAYER") and GS.AuraRemaining("target", shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") and GS.AuraRemaining("target", vampiric_touch, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain and Vampiric Touch") return end
                                if GS.Aura("target", shadow_word_pain, "", "PLAYER") and GS.AuraRemaining("target", shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") and (GS.Talent52 or GS.Talent53) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                if GS.Aura("target", vampiric_touch, "", "PLAYER") and GS.AuraRemaining("target", vampiric_touch, 3.5*GS.GCD()) and (GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]]) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Vampiric Touch") return end
                                -- actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1    
                            end
                            if GS.AoE then
                                table.sort(GS.tShadowWordPain, GS.SortMobTargetsByHighestTTD)
                                table.sort(GS.tVampiricTouch, GS.SortMobTargetsByHighestTTD)
                                for i = 1, #GS.tShadowWordPain do
                                    rotationUnitIterator = GS.tShadowWordPain[i]
                                    if GS.GetTTD(rotationUnitIterator) > 10 then
                                        if GS.SCA(void_bolt, rotationUnitIterator, true) then
                                            if GS.AuraRemaining(rotationUnitIterator, shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") and GS.Aura(rotationUnitIterator, vampiric_touch, "", "PLAYER") and GS.AuraRemaining(rotationUnitIterator, vampiric_touch, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, void_eruption, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Shadow Word Pain and Vampiric Touch") return end
                                            if (GS.Talent52 or GS.Talent53) and GS.AuraRemaining(rotationUnitIterator, shadow_word_pain, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, void_eruption, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                        end
                                    else
                                        break
                                    end
                                end

                                if GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]] then
                                    for i = 1, #GS.tVampiricTouch do
                                        rotationUnitIterator = GS.tVampiricTouch[i]
                                        if GS.GetTTD(rotationUnitIterator) > 10 then
                                            if GS.SCA(void_bolt, rotationUnitIterator, true) then
                                                if GS.AuraRemaining(rotationUnitIterator, vampiric_touch, 3.5*GS.GCD()) then GS.Cast(rotationUnitIterator, void_eruption, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Vampiric Touch") return end
                                            end
                                        else
                                            break
                                        end
                                    end
                                end

                                -- if artifact.sphere_of_insanity.rank then
                                --     for i = 1, #GS.tShadowWordPain do
                                --         rotationUnitIterator = GS.tShadowWordPain[i]
                            --             if GS.GetTTD(rotationUnitIterator) > 10 then
                            --                 if GS.SCA(void_bolt, rotationUnitIterator, true) then
                            --                     actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1
                            --                 end
                            --             else
                            --                 break
                            --             end
                                --     end
                                -- end
                            end
                        end
                        if GS.SCA(void_bolt, "target", true) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Bolt") return end
                        -- actions.vf+=/void_torrent
                        if GS.SIR(shadow_word_death, true) then
                            if GS.Talent42 then
                                -- actions.vf+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+10)<100
                            else
                                -- actions.vf+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100
                            end
                        end
                        if GS.SCA(mind_blast, "target", true) then GS.Cast(_, mind_blast, _, _, _, "nextTick", "Mind Blast") return end
                        if GS.SCA(shadow_word_death, "target", true) and GetSpellCharges(shadow_word_death) == 2 then GS.Cast(_, shadow_word_death, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                        if GS.CDs and not GS.Talent63 and GS.SCA(shadowfiend, "target", true) and GS.AuraStacks("player", voidform, 16) then GS.Cast(_, shadowfiend, _, _, _, "nextTick", "Shadowfiend") return end
                        if GS.Talent13 and GS.SCA(shadow_word_void, "target", true) and (GS.PP()-(voidformInsanity("drain")*GS.GCD()+25)) < 100 then GS.Cast(_, shadow_word_void, _, _, _, _, "Shadow Word Void: Voidform") return end
                        -- actions.s2m+=/shadow_word_pain,if=!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
                        -- actions.s2m+=/vampiric_touch,if=!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
                        -- actions.s2m+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
                        -- actions.s2m+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
                        -- actions.s2m+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
                        if GS.SpellCDDuration(void_bolt) < (GS.GCD()*0.75) then if toggleLog then GS.Log("Waiting for Void Bolt"); toggleLog = false end return end
                        if GS.AoE and GS.SCA(mind_sear, "target", true) and GS.TargetCount(10) >= 3 then GS.Cast(_, mind_sear, _, _, _, "nextTick Mind Flay", "Mind Sear") return end
                        if not GS.Talent72 then
                            if GS.SCA(mind_flay, "target", true) and UnitChannelInfo("player") and (select(6, UnitChannelInfo("player"))/1000-GetTime()) <= (.75/(1+GetHaste()*.01)) then GS.Cast(_, mind_flay, _, _, _, "chain", "Mind Flay: Chain") return end
                            if GS.SCA(mind_flay) then GS.Cast(_, mind_flay, _, _, _, _, "Mind Flay") return end
                        else
                            if GS.SCA(mind_spike) then GS.Cast(_, mind_spike, _, _, _, _, "Mind Spike") return end
                        end
                        if GS.SCA(shadow_word_pain) then GS.Cast(_, shadow_word_pain, _, _, _, _, "Shadow Word: Pain") return end
                        return
                    end

                    -- actions.main=surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=0.8*(45+((raw_haste_pct*100)*(2+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank))))-(25*nonexecute_actors_pct)
                    if GS.Talent63 and GS.SCA(mindbender, "target", true) then GS.Cast(_, mindbender, _, _, _, "nextTick", "Mindbender") return end
                    if GS.SCA(shadow_word_pain, "target", true) and GS.AuraRemaining("target", shadow_word_pain, ((3+4/3)*GS.GCD())) then GS.Cast(_, shadow_word_pain, _, _, _, "nextTick", "Shadow Word Pain: 4.3r*GCD") return end
                    if GS.SCA(vampiric_touch, "target", true) and GS.AuraRemaining("target", vampiric_touch, ((3+4/3)*GS.GCD())) then GS.Cast(_, vampiric_touch, _, _, _, "nextTick", "Vampiric Touch: 4.3r*GCD") return end
                    if GS.SIR(void_eruption) and (GS.PP() >= 85 or GS.Talent52 and GS.PP() >= (80-GS.Priest.ApparitionsInFlight*4)) then GS.Cast(_, void_eruption, _, _, _, "nextTick", "Void Eruption") return end
                    if GS.Talent62 and GS.SIR(shadow_crash) then
                        GS.SmartAoE(40, 8)
                        GS.Cast(_, shadow_crash, rotationXC, rotationYC, rotationZC, "nextTick", "Shadow Crash")
                        return
                    end
                    -- if GS.Talent63 and GS.SCA(mindbender, "target", true) --[[and set_bonus.tier18_2pc]] then GS.Cast(_, mindbender, _, _, _, "nextTick", "Mindbender: T18 2PC") return end
                    if GS.SIR(shadow_word_pain) and GS.Talent71 and GS.PP() >= 70 then
                        if GS.SCA(shadow_word_pain, "target", true) and not GS.Aura("target", shadow_word_pain, "", "PLAYER") then
                            GS.Cast(_, shadow_word_pain, _, _, _, "nextTick", "Shadow Word Pain: Not Up")
                            return
                        elseif GS.AoE then
                            for i = 1, mobTargetsSize do
                                rotationUnitIterator = GS.MobTargets[i]
                                if GS.SCA(shadow_word_pain, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, shadow_word_pain, "", "PLAYER") then GS.Cast(rotationUnitIterator, shadow_word_pain, _, _, _, "nextTick", "Shadow Word Pain: AoE Not Up") return end
                            end
                        end
                    end
                    if GS.SIR(vampiric_touch) and GS.Talent71 and GS.PP() >= 70 then
                        if GS.SCA(vampiric_touch, "target", true) and not GS.Aura("target", vampiric_touch, "", "PLAYER") then
                            GS.Cast(_, vampiric_touch, _, _, _, "nextTick", "Vampiric Touch: Not Up")
                            return
                        elseif GS.AoE then
                            for i = 1, mobTargetsSize do
                                rotationUnitIterator = GS.MobTargets[i]
                                if GS.SCA(vampiric_touch, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, vampiric_touch, "", "PLAYER") then GS.Cast(rotationUnitIterator, vampiric_touch, _, _, _, "nextTick", "Vampiric Touch: Not Up") return end
                            end
                        end
                    end
                    if GS.SCA(shadow_word_death, "target", true) and GetSpellCharges(shadow_word_death) == 2 then
                        if not GS.Talent42 then
                            if GS.PP() <= 90 then GS.Cast(_, shadow_word_death, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                        else
                            if GS.PP() <= 70 then GS.Cast(_, shadow_word_death, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                        end
                    end
                    if GS.SCA(mind_blast, "target", true) and GS.Talent71 and (GS.PP() <= 81 or GS.PP() <= 75.2 and GS.Talent12) then GS.Cast(_, mind_blast, _, _, _, "nextTick", "Mind Blast: Without Capping Insanity") return end
                    if GS.SCA(mind_blast, "target", true) and (not GS.Talent71 or GS.PP() <= 96 or GS.PP() <= 95.2 and GS.Talent12) then GS.Cast(_, mind_blast, _, _, _, "nextTick", "Mind Blast: Without Capping") return end
                    -- actions.main+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
                    -- actions.main+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
                    -- actions.main+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
                    if GS.Talent13 and GS.SCA(shadow_word_void, "target", true) and (GS.PP() <= 70 and GS.Talent71 or GS.PP() <= 85 and not GS.Talent71) then GS.Cast(_, shadow_word_void, _, _, _, "nextTick", "Shadow Word Void") return end
                    if GS.AoE and GS.SCA(mind_sear, "target", true) and GS.TargetCount(10) >= 3 then GS.Cast(_, mind_sear, _, _, _, "nextTick Mind Flay", "Mind Sear") return end
                    if not GS.Talent72 then
                        if GS.SCA(mind_flay, "target", true) and UnitChannelInfo("player") and (select(6, UnitChannelInfo("player"))/1000-GetTime()) <= (.75/(1+GetHaste()*.01)) then GS.Cast(_, mind_flay, _, _, _, "chain", "Mind Flay: Chain") return end
                        if GS.SCA(mind_flay) then GS.Cast(_, mind_flay, _, _, _, _, "Mind Flay") return end
                    else
                        if GS.SCA(mind_spike) then GS.Cast(_, mind_spike, _, _, _, _, "Mind Spike") return end
                    end
                    if GS.SCA(shadow_word_pain) then GS.Cast(_, shadow_word_pain, _, _, _, _, "Shadow Word: Pain") return end
                end
            end
        end
    end
end