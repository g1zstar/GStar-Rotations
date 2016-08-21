GS = GSD.RotationToggle("d")
do
    do -- Affliction
        function GS.WARLOCK190()
        end

        function GSD.SpreadCorruption()
            for i = 1, mobTargetsSize do
                rotationUnitIterator = GS.MobTargets[i]
                if GS.SCA(172, rotationUnitIterator) and not GS.Aura(rotationUnitIterator, 146739, "", "PLAYER") then GS.Cast(rotationUnitIterator, 172, false, false, false, "SpellToInterrupt") return end
            end
        end
    end
    -- todo: create Affliction Warlock
    -- todo: create Demonology Warlock
    -- todo: create Destruction Warlock
    do -- Destruction
    end
end