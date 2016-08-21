GS = GSD.RotationToggle("d")
do
    local crusader_strike = 35395
    -- todo: create Holy Paladin
    -- todo: create Protection Paladin

    do -- Protection
    end

    do -- Retribution
        -- talents=1112112
        -- artifact=2:136717:137316:136717:0:40:1:41:3:42:3:50:3:51:3:53:6:350:1:353:1:1275:1
        local the_fires_of_justice     = 209785
        local avenging_wrath           =  31884
        local blade_of_justice         = 184575
        local blade_of_wrath           = 202270
        local consecration             = 205228
        local crusade                  = 224668
        local divine_hammer            = 198034
        local divine_purpose           = 223819 -- verify: Retribution Paladin
        local divine_storm             =  53385
        local execution_sentence       = 213757
        local holy_wrath               = 210220
        local judgment                 =        {spell = 20271, debuff = 197277}
        local justicars_vengeance      = 215661
        local rebuke                   =  96231
        local templars_verdict         =  85256
        local whisper_of_the_nathrezim =        {item = 137020, buff = nil} -- verify: Retribution Paladin
        local zeal                     = 217020
        
        function GS.PALADIN3()
            if UnitAffectingCombat("player") then
                if GS.ValidTarget() and (GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    StartAttack("target")
                    -- actions+=/rebuke
                    if GS.CDs then
                        -- actions+=/potion,name=deadly_grace,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up|target.time_to_die<=40)
                        -- actions+=/use_item,name=faulty_countermeasure,if=(buff.avenging_wrath.up|buff.crusade.up)
                        -- actions+=/holy_wrath
                        if not GS.Talent72 then
                            if GS.SIR(avenging_wrath) then GS.Cast(_, avenging_wrath, _, _, _, _, "Avenging Wrath") return end
                        else
                            if GS.SIR(crusade) and GS.PP() >= 5 then GS.Cast(_, crusade, _, _, _, _, "Crusade") return end
                        end
                    end
                    -- actions+=/wake_of_ashes,if=holy_power>=0&time<2
                    if GS.Talent12 and GS.SCA(execution_sentence) and (not GS.AoE or GS.PlayerCount(8, _, 3, "<=") and (GS.SpellCDDuration(judgment.spell) < GS.GCD()*4.5 or not GS.AuraRemaining(target, judgment.debuff, GS.GCD()*4.67, "", "PLAYER")) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*2)) then GS.Cast(_, execution_sentence, _, _, _, _, "Execution Sentence") return end
                    if GS.CDs then
                        -- actions+=/arcane_torrent
                    end
                    if GS.Talent41 then -- Virtue's Blade
                        if GS.Aura("target", judgment.debuff, "", "PLAYER") then
                            if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose + 5 HP") return end
                                if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                            end
                            if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not IsEquippedItem(whisper_of_the_nathrezim.item) then
                                if GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose + 5 HP") return end
                            end
                            if GS.SCA(templars_verdict) then
                                if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose + 5 HP") return end
                                if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                            end
                            -- actions.VB+=/divine_storm,if=holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                            -- actions.VB+=/justicars_vengeance,if=holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
                            -- actions.VB+=/templars_verdict,if=holy_power>=3&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                        end
                        -- actions.VB+=/wake_of_ashes,if=holy_power=0|holy_power=1&cooldown.blade_of_justice.remains>gcd|holy_power=2&(cooldown.zeal.charges_fractional<=0.34|cooldown.crusader_strike.charges_fractional<=0.34)
                        if GS.Talent22 then
                            if GS.SCA(zeal) and GetSpellCharges(zeal) == 2 and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal: Capped Charges") return end
                        else
                            if GS.SCA(crusader_strike) and GetSpellCharges(crusader_strike) == 2 and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike: Capped Charges") return end
                        end
                        if GS.SCA(blade_of_justice) and (GS.PP() <= 2 or GS.PP() <= 3 and GS.FracCalc("spell", GS.Talent22 and zeal or crusader_strike) <= 1.34) then GS.Cast(_, blade_of_justice, _, _, _, _, "Blade of Justice") return end
                        if GS.SCA(judgment.spell) and (GS.PP() >= 3 or GS.FracCalc("spell", GS.Talent22 and zeal or crusader_strike) <= 1.67 and GS.SpellCDDuration(blade_of_justice) > GS.GCD() or GS.Talent23 and GS.Health("target", _, true) > 50) then GS.Cast(_, judgment.spell, _, _, _, _, "Judgment: HP|Crusader Strike Capped Charges|Talented 50%+") return end
                        if GS.Talent13 and GS.SIR(consecration) and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, consecration, _, _, _, _, "Consecration") return end
                        if GS.Aura("target", judgment.debuff, "", "PLAYER") then
                            if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                if GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose") return end
                                if GS.Aura("player", the_fires_of_justice) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump Fires of Justice") return end
                                if GS.PP() >= 4 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                            end
                            if GS.Talent51 and GS.SCA(justicars_vengeance) and not IsEquippedItem(whisper_of_the_nathrezim.item) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance") return end
                            if GS.SCA(templars_verdict) then
                                if GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose") return end
                                if GS.Aura("player", the_fires_of_justice) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Fires of Justice") return end
                                if GS.PP() >= 4 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                            end
                        end
                        if GS.Talent22 then
                            if GS.SCA(zeal) and GS.PP() <= 2 then GS.Cast(_, zeal, _, _, _, _, "Zeal") return end
                        else
                            if GS.SCA(crusader_strike) and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike") return end
                        end
                        if GS.AoE and GS.PP() >= 3 and GS.SIR(divine_storm) and GS.Aura("target", judgment.debuff, "", "PLAYER") and GS.PlayerCount(8, _, 2, ">=") and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm") return end
                        if GS.PP() >= 3 and GS.SCA(templars_verdict) and GS.Aura("target", judgment.debuff, "", "PLAYER") and GS.PP() >= 3 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict") return end
                    elseif GS.Talent42 then -- Blade of Wrath
                        if GS.Aura("target", judgment.debuff, "", "PLAYER") then
                            if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose + 5 HP") return end
                                if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                            end
                            if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not IsEquippedItem(whisper_of_the_nathrezim.item) then
                                if GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose + 5 HP") return end
                            end
                            if GS.SCA(templars_verdict) then
                                if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose + 5 HP") return end
                                if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                            end
                            -- actions.BoW+=/divine_storm,if=holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                            -- actions.BoW+=/justicars_vengeance,if=holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
                            -- if GS.SCA(templars_verdict) and GS.PP() >= 3 and (GS.SpellCDDuration(wake_of_ashes) < GS.GCD()*2 and artifact.wake_of_ashes.enabled or GS.Aura("player", 207635) and GS.AuraRemaining("player", 207635, GS.GCD())) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Wake of Ashes Dump HP|Whisper of the Nathrezim About to Expire") return end
                        end
                        -- actions.BoW+=/wake_of_ashes,if=holy_power=0|holy_power=1&cooldown.blade_of_wrath.remains>gcd|holy_power=2&(cooldown.zeal.charges_fractional<=0.67|cooldown.crusader_strike.charges_fractional<=0.67)
                        if GS.Talent22 then
                            if GS.SCA(zeal) and GetSpellCharges(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal: Capped Charges") return end
                        else
                            if GS.SCA(crusader_strike) and GetSpellCharges(crusader_strike) == 2 and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike: Capped Charges") return end
                        end
                        if GS.SCA(blade_of_wrath) and (GS.PP() <= 2 or GS.PP() <= 3 and GS.FracCalc("spell", GS.Talent22 and zeal or crusader_strike) <= 1.34) then GS.Cast(_, blade_of_wrath, _, _, _, _, "Blade of Wrath") return end
                        if GS.Talent21 and GS.SCA(crusader_strike) and GetSpellCharges(crusader_strike) == 2 and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike: Capped Charges") return end
                        if GS.SCA(judgment.spell) then GS.Cast(_, judgment.spell, _, _, _, _, "Judgment") return end
                        if GS.Talent13 and GS.SIR(consecration) and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, consecration, _, _, _, _, "Consecration") return end
                        if GS.Aura("target", judgment.debuff, "", "PLAYER") then
                            if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                if GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose") return end
                                if GS.PP() >= 4 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                            end
                            if GS.Talent51 and GS.SCA(justicars_vengeance) and not IsEquippedItem(whisper_of_the_nathrezim.item) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance") return end
                            if GS.SCA(templars_verdict) then
                                if GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose") return end
                                if GS.Aura("player", the_fires_of_justice) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Fires of Justice") return end
                                if not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4 then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP|Fish for Divine Purpose") return end
                            end
                        end
                        if GS.Talent22 then
                            if GS.SCA(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal") return end
                        else
                            if GS.SCA(crusader_strike) and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike") return end
                        end
                    elseif GS.Talent43 then -- Divine Hammer
                        if GS.Aura("target", judgment.debuff, "", "PLAYER") then
                            if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose + 5 HP") return end
                                if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                            end
                            if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not IsEquippedItem(whisper_of_the_nathrezim.item) then
                                if GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose + 5 HP") return end
                            end
                            if GS.SCA(templars_verdict) then
                                if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose About to Expire") return end
                                if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose + 5 HP") return end
                                if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                            end
                            -- actions.DH+=/divine_storm,if=holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*3)
                            -- actions.DH+=/justicars_vengeance,if=holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
                            -- actions.DH+=/templars_verdict,if=holy_power>=3&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*3)
                        end
                        -- actions.DH+=/wake_of_ashes,if=holy_power<=1
                        if GS.Talent22 then
                            if GS.SCA(zeal) and GetSpellCharges(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal: Capped Charges") return end
                        else
                            if GS.SCA(crusader_strike) and GetSpellCharges(crusader_strike) == 2 and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike: Capped Charges") return end
                        end
                        if GS.SIR(divine_hammer) and GS.PP() <= 3 then GS.Cast(_, divine_hammer, _, _, _, _, "Divine Hammer") return end
                        if GS.SCA(judgment.spell) then GS.Cast(_, judgment.spell, _, _, _, _, "Judgment") return end
                        if GS.Talent13 and GS.SIR(consecration) and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, consecration, _, _, _, _, "Consecration") return end
                        if GS.Aura("target", judgment.debuff, "", "PLAYER") then
                            if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                if GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose") return end
                                if (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm") return end
                            end
                            if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not IsEquippedItem(whisper_of_the_nathrezim.item) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose") return end
                            if GS.SCA(templars_verdict) then
                                if GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose") return end
                                if GS.Aura("player", the_fires_of_justice) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Fires of Justice") return end
                                if (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*6) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict") return end
                            end
                        end
                        if GS.Talent22 then
                            if GS.SCA(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal") return end
                        else
                            if GS.SCA(crusader_strike) and GS.PP() <= 4 then GS.Cast(_, crusader_strike, _, _, _, _, "Crusader Strike") return end
                        end
                    end
                end
            end
        end
    end
end