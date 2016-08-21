GS = GSD.RotationToggle("d")
do
    local blood_fury = 33697

    -- todo: create Elemental Shaman

    do -- Enhancement
        -- talents=3003112
        -- artifact=41:0:0:0:0:899:1:901:1:902:1:903:1:904:1:905:1:909:3:910:3:911:3:912:3:1351:1
        local feral_spirit = 51533
        local ascendance = 114051
        local boulderfist = 201897
        local frostbrand = 196834
        local flametongue = {spell = 193796, buff = 194084}
        local windsong = 201898
        local fury_of_air = 197211
        local crash_lightning = 187874
        local windstrike = 115356
        local stormstrike = 17364
        local lightning_bolt = 187837
        local lava_lash = 60103
        local earthen_spike = 188089
        local hot_hand = 215785
        local rockbiter = 193786
        
        function GS.SHAMAN2()
            if UnitAffectingCombat("player") or GSR.RaFFollow and UnitExists("focus") and UnitAffectingCombat("focus") then
                if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                    -- actions=wind_shear
                    -- actions+=/auto_attack
                    if GS.CDs then
                        if GS.SIR(feral_spirit) then GS.Cast(_, feral_spirit, _, _, _, _, "Feral Spirit") return end
                        -- actions+=/use_item,slot=trinket2
                        -- actions+=/potion,name=deadly_grace,if=pet.feral_spirit.remains>10|pet.frost_wolf.remains>5|pet.fiery_wolf.remains>5|pet.lightning_wolf.remains>5|target.time_to_die<=30
                        if GS.SIR(berserking) and (GS.Aura("player", ascendance) or not GS.Talent71 or UnitLevel("player") < 100) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                        if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial ASP") return end
                    end
                    if GS.Talent13 and GS.SCA(boulderfist) and (GS.AuraRemaining("player", 218825, GS.GCD()) or GS.FracCalc("spell", boulderfist) >= 1.75) then GS.Cast(_, boulderfist, _, _, _, _, "Boulderfist: Buff Not Up or Prevent Charges Cap") return end
                    if GS.Talent43 and GS.SCA(frostbrand) and GS.AuraRemaining("player", frostbrand, GS.GCD()) then GS.Cast(_, frostbrand, _, _, _, _, "Frostbrand: Low Buff") return end
                    if GS.SCA(flametongue.spell) and GS.AuraRemaining("player", flametongue.buff, GS.GCD()) then GS.Cast(_, flametongue.spell, _, _, _, _, "Flametongue: Low Buff") return end
                    if GS.Talent11 and GS.SCA(windsong) then GS.Cast(_, windsong, _, _, _, _, "Windsong") return end
                    if GS.CDs and GS.Talent71 and GS.SIR(ascendance) then GS.Cast(_, ascendance, _, _, _, _, "Ascendance") return end
                    if GS.Talent62 and GS.SIR(fury_of_air) and not GS.Aura("player", fury_of_air) then GS.Cast(_, fury_of_air, _, _, _, _, "Fury of Air: Not Up") return end
                    -- actions+=/doom_winds
                    if GS.AoE and GS.SIR(crash_lightning) and GS.PlayerCount(8) >= 3 then GS.Cast(_, crash_lightning, _, _, _, _, "Crash Lightning: AoE") return end
                    if GS.Aura("player", ascendance) then
                        if GS.SCA(windstrike) then GS.Cast(_, windstrike, _, _, _, _, "Windstrike") return end
                    else
                        if GS.SCA(stormstrike) then GS.Cast(_, stormstrike, _, _, _, _, "Stormstrike") return end
                    end
                    if GS.Talent43 and GS.SCA(frostbrand) and GS.AuraRemaining("player", frostbrand, 4.8) then GS.Cast(_, frostbrand, _, _, _, _, "Frostbrand") return end
                    if GS.SCA(flametongue.spell) and GS.AuraRemaining("player", flametongue.buff, 4.8) then GS.Cast(_, flametongue.spell, _, _, _, _, "Flametongue: Buff") return end
                    if GS.Talent52 and GS.SCA(lightning_bolt) and GS.PP() >= 60 then GS.Cast(_, lightning_bolt, _, _, _, _, "Lightning Bolt: Overcharge") return end
                    if GS.SCA(lava_lash) and GS.Aura("player", hot_hand) then GS.Cast(_, lava_lash, _, _, _, _, "Lava Lash: Hot Hand") return end
                    if GS.Talent73 and GS.SCA(earthen_spike) then GS.Cast(_, earthen_spike, _, _, _, _, "Earthen Spike") return end
                    if GS.SIR(crash_lightning) and (GS.AoE and GS.PlayerCount(8) > 1 or GS.Talent61 or GS.SpellCDDuration(feral_spirit) > 110) then GS.Cast(_, crash_lightning, _, _, _, _, "Crash Lightning") return end
                    -- actions+=/sundering
                    if GS.SCA(lava_lash) and GS.PP() >= 90 then GS.Cast(_, lava_lash, _, _, _, _, "Lava Lash: Dump Maelstrom") return end
                    if not GS.Talent13 and GS.SCA(rockbiter) then GS.Cast(_, rockbiter, _, _, _, _, "Rockbiter") return end
                    if GS.SCA(flametongue.spell) then GS.Cast(_, flametongue.spell, _, _, _, _, "Flametongue") return end
                    if GS.Talent13 and GS.SCA(boulderfist) then GS.Cast(_, boulderfist, _, _, _, _, "Boulderfist") return end
                end
            end
        end
    end

    -- todo: create Restoration Shaman
end