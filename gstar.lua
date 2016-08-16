-- AceConfig, AceGUI = LibStub("AceConfig-3.0"), LibStub("AceGUI-3.0")
local AC, ACD = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")

local GS = {}
GSD = {}
local _ = nil

-- Main Stuff
    GS.PreventExecution = false
    GS.SpellThrottle = 0
    GS.WaitForCombatLog = 0

    function GS.MainFrameEvents(self, originalEvent, ...)
        if originalEvent == "PLAYER_ENTERING_WORLD" then
            GS.PreventExecution = true
            table.wipe(GS.MobTargets)
            table.wipe(GS.AllyTargets)
            GS.MonitorAnimationToggle("off")
            return
        elseif originalEvent == "LOADING_SCREEN_DISABLED" then
            GS.PreventExecution = false
            GS.Start  = false
            GS.MonitorAnimationToggle("off")
            return
        elseif originalEvent == "PLAYER_SPECIALIZATION_CHANGED" then
            GS.Spec = GetSpecialization()
            GS.CacheTalents()
            return
        elseif originalEvent == "PLAYER_TALENT_UPDATE" then
            GS.CacheTalents()
            return
        end
    end

    function GS.CombatFrameCreation()
        if not GSCombatFrame then GS.CombatFrame = CreateFrame("Frame", "GSCombatFrame", GSMainFrame) end
        GSCombatFrame:SetScript("OnUpdate", GS.ExecuteRotation)
    end

    function GS.ExecuteRotation()
        if not FireHack or GS.PreventExecution or not GS.Start or UnitIsDeadOrGhost("player") then return end
        if not GS.RanOnce then
            if not ReadFile(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\Revision.txt") then
                GS.CheckUpdateFailed("no local file")
            else
                DownloadURL("raw.githubusercontent.com", "/g1zstar/GStar-Rotations/master/Revision.txt", true, GS.CheckUpdate, GS.DownloadURLFailed)
            end
            GS.RanOnce = true
        end

        if GSR.RaFFollow then
            GS.RaFQuesting()
        end

        if GS.Spec and GSR.Class and GSR.LevelingRAF and GS[GSR.Class..GS.Spec.."90"] then
            GS.rotationCacheCounter = GS.rotationCacheCounter + 1
            GS[GSR.Class..GS.Spec.."90"]()
            return
        elseif GS.Spec and GSR.Class and GS[GSR.Class..GS.Spec] then
            GS.rotationCacheCounter = GS.rotationCacheCounter + 1
            GS[GSR.Class..GS.Spec]()
            return
        elseif not GS.Spec and GSR.Class and GS[GSR.Class] then
            GS.rotationCacheCounter = GS.rotationCacheCounter + 1
            GS[GSR.Class]()
            return
        else
            print("No such specialization and class combo available.")
            GS.Start = false
            GS.MonitorAnimationToggle("off")
            return
        end
    end

    function GS.CombatInformationFrameCreation()
        GS.MobTargetsPreliminary, GS.MobTargets = {}, {}
        GS.AllyTargets = {}
        GS.TTDM, GS.TTD = {}, {}
        GS.DebugTable = {debugStack = "", pointer = 0, nameOfTarget = "", ogSpell = 0, Spell = "", x = 0, y = 0, z = 0, interrupt = "", time = 0, timeSinceLast = 0, reason = ""}

        if not GSCombatInfoFrame then GS.InformationGatheringFrame = CreateFrame("Frame", "GSCombatInfoFrame", GSMainFrame) end
        GSCombatInfoFrame:RegisterEvent("PLAYER_DEAD")
        GSCombatInfoFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        GSCombatInfoFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        GSCombatInfoFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        -- GSCombatInfoFrame:RegisterEvent("COMBAT_LOG_EVENT")
        GSCombatInfoFrame:SetScript("OnEvent", GS.CombatInformationFrameEvents) -- This responds to the combat log
        GSCombatInfoFrame:SetScript("OnUpdate", GS.CombatInformationFrameCuration) -- this gathers information about mobs
    end

    function GS.HealingTooltipFrameCreation()
        if not GSHealingTooltipFrame then
            GS.HealingTooltipFrame = CreateFrame("GameTooltip", "GSHealingTooltipFrame", nil, "GameTooltipTemplate")
            GSHealingTooltipFrame:SetOwner(UIParent, "ANCHOR_NONE")
        end
    end

    function GS.MonitorFrameCreation()
        if not GSMonitorParentFrame then
            GS.MonitorParentFrame = CreateFrame("Frame", "GSMonitorParentFrame", UIParent)
            GSMonitorParentFrame:SetFrameStrata("MEDIUM")
            GSMonitorParentFrame:SetWidth("64")
            GSMonitorParentFrame:SetHeight("64")

            if GSR.MonitorX and GSR.MonitorY then
                GSMonitorParentFrame:ClearAllPoints()
                GSMonitorParentFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", GSR.MonitorX, GSR.MonitorY)
            else
                GSMonitorParentFrame:ClearAllPoints()
                GSMonitorParentFrame:SetPoint("CENTER")
            end

            GS.MonitorTexture = GSMonitorParentFrame:CreateTexture("GSMonitorTexture")
            GSMonitorTexture:SetTexture(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\GStarMonitor.tga")
            GSMonitorTexture:SetAllPoints(GSMonitorParentFrame)

            GSAoEOnTexture = GSMonitorParentFrame:CreateTexture("GSAoEOnTexture")
            GSAoEOffTexture = GSMonitorParentFrame:CreateTexture("GSAoEOffTexture")
            GSAoEOnTexture:SetTexture(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\eyes.tga")
            GSAoEOffTexture:SetTexture(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\no.tga")

            GSAoEOnTexture:SetPoint("RIGHT", -10, 3)
            GSAoEOnTexture:SetSize(20, 20)
            GSAoEOffTexture:SetPoint("RIGHT", -10, 3)
            GSAoEOffTexture:SetSize(20, 20)

            GSCDsOnTexture = GSMonitorParentFrame:CreateTexture("GSCDsOnTexture")
            GSCDsOffTexture = GSMonitorParentFrame:CreateTexture("GSCDsOffTexture")
            GSCDsOnTexture:SetTexture(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\eyes.tga")
            GSCDsOffTexture:SetTexture(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\no.tga")

            GSCDsOnTexture:SetPoint("BOTTOMRIGHT", -10, 4)
            GSCDsOnTexture:SetSize(20, 20)
            GSCDsOffTexture:SetPoint("BOTTOMRIGHT", -10, 4)
            GSCDsOffTexture:SetSize(20, 20)

            GSMonitorParentFrame:SetMovable(1)
            GSMonitorParentFrame:EnableMouse(true)
            GSMonitorParentFrame:RegisterForDrag("LeftButton")
        end
        GSMonitorParentFrame:SetScript("OnMouseDown", function() if GSAoEOffTexture:IsMouseOver() then GS.ToggleAoE() elseif GSCDsOffTexture:IsMouseOver() then GS.ToggleCDs() end end)
        GSMonitorParentFrame:SetScript("OnDragStart", GSMonitorParentFrame.StartMoving)
        GSMonitorParentFrame:SetScript("OnDragStop", function(self) local variableX, variableY = self:GetRect(); GS.SaveToGSR("MonitorX", variableX); GS.SaveToGSR("MonitorY", variableY); GSMonitorParentFrame:StopMovingOrSizing() end)
        GSAoEOnTexture:Hide()
        GSCDsOnTexture:Hide()
    end

    function GS.MonitorAnimation(self, elapsed)
        if GS.AoE then
            if not GSAoEOnTexture:IsVisible() or GSAoEOffTexture:IsVisible() then
                GSAoEOnTexture:Show()
                GSAoEOffTexture:Hide()
            end
            AnimateTexCoords(GSAoEOnTexture, 512, 256, 64, 64, 29, elapsed, 0.029)
        elseif GSAoEOnTexture:IsVisible() or not GSAoEOffTexture:IsVisible() then
            GSAoEOffTexture:Show()
            GSAoEOnTexture:Hide()
        end
        if GS.CDs then
            if not GSCDsOnTexture:IsVisible() or GSCDsOffTexture:IsVisible() then
                GSCDsOnTexture:Show()
                GSCDsOffTexture:Hide()
            end
            AnimateTexCoords(GSCDsOnTexture, 512, 256, 64, 64, 29, elapsed, 0.029)
        elseif GSCDsOnTexture:IsVisible() or not GSCDsOffTexture:IsVisible() then
            GSCDsOnTexture:Hide()
            GSCDsOffTexture:Show()
        end
    end

    function GS.MonitorAnimationToggle(argument)
        if argument == "off" then
            GSMonitorParentFrame:SetScript("OnUpdate", nil)
            GSMonitorParentFrame:Hide()
        end
        if argument == "on" then
            GSMonitorParentFrame:SetScript("OnUpdate", GS.MonitorAnimation)
            GSMonitorParentFrame:Show()
        end
    end

    function GS.SaveToGSR(i,v)
        GSR[i] = v
        SetCharacterCustomVariable("GSR", GSR)
    end

    function GS.Log(message)
        if GSR.Dev.Logging then
            GS.File = ReadFile("C:\\Garrison.json")
            local debugStack = string.gsub(debugstack(2, 100, 100), '%[string "local function GetScriptName %(%) return "gst..."%]', "line")
            debugStack = string.gsub(debugStack, "\n", ", ")
            WriteFile("C:\\Garrison.json", GS.File..",\n{\n\t"..message.."\n\t\"time\":"..GetTime()..",\n\t\"Line Number\": "..debugStack.."\n}")
        end
    end

    -- Rotation toggles
        function GSD.RotationToggle(command)
            command = command:lower()

            if command == "toggle" or command == "t" then
                GS.Start = not GS.Start
                GS.MonitorAnimationToggle(GS.Start and "on" or "off")
                print("GStar Rotations: "..(GS.Start and "On" or "Off"))
                return true
            end

            if command == "aoe" then GS.ToggleAoE() return true end

            if command == "cds" then GS.ToggleCDs() return true end

            if command == "debug" or command == "d" then
                for k,v in pairs(GS) do
                    GSD[k] = v
                end
                return true
            end

            if command == "wipe" or command == "w" then
                print("GStar Rotations: Reloading Files")
                GSCombatFrame:SetScript("OnUpdate", nil)
                GSCombatInfoFrame:SetScript("OnEvent", nil)
                GSCombatInfoFrame:SetScript("OnUpdate", nil)
                GSMainFrame:SetScript("OnEvent", nil)
                GSMonitorParentFrame:SetScript("OnDragStart", nil)
                GSMonitorParentFrame:SetScript("OnDragStop", nil)
                GSMonitorParentFrame:SetScript("OnMouseDown", nil)
                GSMonitorParentFrame:SetScript("OnUpdate", nil)
                GS = nil
                GSD = nil
                LoadScript("GStar Rotations\\gstar.lua")
                return true
            end

            if command == "options" then
                ACD:Open("GS_Settings")
                return true
            end
        end

        function GS.ToggleAoE()
            GS.AoE = not GS.AoE
            print("GStar Rotations: AoE now "..(GS.AoE and "on" or "off")..".")
        end

        function GS.ToggleCDs()
            GS.CDs = not GS.CDs
            print("GStar Rotations: CDs now "..(GS.CDs and "on" or "off")..".")
        end

        function GSD.ToggleInterrupt()
            GS.SaveToGSR("Interrupt", not GSR.Interrupt)
            print("GStar Rotations: Interrupt now "..(GSR.Interrupt and "on" or "off")..".")
        end

-- Meat
    local rotationUnitIterator, rotationUnitPlaceholder = nil, nil
    local rotationXC, rotationYC, rotationZC
    local mobTargetsSize, allyTargetsSize = 0, 0
    local auraTable = {}
    local toggleLog = false
    local healingStringPlaceholderOne, healingStringPlaceholderTwo = "", ""
    GS.rotationCacheCounter = 0
    GS.SpellNotKnown, GS.SpellOutranged = {}, {}
    GS.CombatStart = math.huge
    GS.Talent11, GS.Talent12, GS.Talent13, GS.Talent21, GS.Talent22, GS.Talent23, GS.Talent31, GS.Talent32, GS.Talent33, GS.Talent41, GS.Talent42, GS.Talent43, GS.Talent51, GS.Talent52, GS.Talent53, GS.Talent61, GS.Talent62, GS.Talent63, GS.Talent71, GS.Talent72, GS.Talent73 = false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false

    GS.SkipLoS = {
        76585, -- Ragewing
        77692, -- Kromog
        77182, -- Oregorger
    }
    GS.MobNamesToIgnore = {
        "Unknown",
        "Manifestation",
        "Kor'Kron Cannon",
        "Spike Mine",
        "Prismatic Crystal",
    }
    GS.MobTypesToIgnore = {
        "Critter",
        "Critter nil",
        "Wild Pet",
        "Pet",
        "Totem",
        "Not specified",
    }
    GS.MobTargetsAurasToIgnore = {
        "Arcane Protection",
        "Water Bubble",
    }
    GS.AllyTargetsAurasToIgnore = {}

    GS.BossList = {}
    -- todo: should healing dummies be under this?
    -- todo: should tanking dummies be under this?
    -- todo: should dummies inside dungeons and raids be under this?
    GS.DummiesID = {
        31144, -- 080
        31146, -- ???
        32541, -- 055
        32542, -- 065
        32545, -- 055
        32546, -- 080
        32543, -- 075
        32666, -- 060
        32667, -- 070
        46647, -- 085
        67127, -- 090
        79414, -- 095 Talador
        87317, -- 100 Garrison (Mage Tower?)
        87318, -- 102 Garrison (Lunarfall)
        87320, -- ??? Alliance Ashran and Garrison (Lunarfall) Dummy
        -- 87321, -- 100 Alliance Ashran Healing Dummy
        -- 87322, -- 102 Alliance Ashran Tanking Dummy
        -- 87329, -- ??? Alliance Ashran Tanking Dummy
        87760, -- 100 Garrison (Frostwall)
        87761, -- 102 Garrison (Frostwall)
        87762, -- ??? Horde Ashran and Garrison (Frostwall) Dummy
        -- 88288, -- 102 Garrison (Frostwall) Tanking Dummy
        -- 88289, -- 100 Garrison Healing Dummy (Frostwall)
        -- 88314, -- 102 Garrison (Lunarfall) Tanking Dummy
        -- 88316, -- 100 Garrison Healing Dummy (Lunarfall)
        -- 88835, -- 100 Horde Ashran Healing Dummy
        -- 88836, -- 102 Horde Ashran Tanking Dummy
        -- 88837, -- ??? Horde Ashran Tanking Dummy
        88967, -- 100 Garrison
        89078, -- ??? Garrison
        -- 89321, -- 100 Garrison Healing Dummy
        -- Unknown Location Commented out for now
            -- 24792, -- ???
            -- 30527, -- ???
            -- 79987, -- ???
        -- Dungeons Commented out for now
            -- 17578, -- 001 The Shattered Halls
            -- 60197, -- 001 Scarlet Monastery
            -- 64446, -- 001 Scarlet Monastery
        -- Raids Commented out for now
            -- 70245, -- ??? Throne of Thunder
            -- 93828, -- 102 Hellfire Citadel
        -- Starting Zone Dummies Commented out for now
            -- 44171, -- 003
            -- 44389, -- 003
            -- 44548, -- 003
            -- 44614, -- 003
            -- 44703, -- 003
            -- 44794, -- 003
            -- 44820, -- 003
            -- 44848, -- 003
            -- 44937, -- 003
            -- 48304, -- 003
        -- Added in Legion Patches
            --  92164, -- ??? Training Dummy <Damage>
            --  92165, -- ??? Dungeoneer's Training Dummy <Damage>
            --  92166, -- ??? Raider's Training Dummy <Damage>
            --  92167, -- ??? Training Dummy <Healing>
            --  92168, -- ??? Dungeoneer's Training Dummy <Tanking>
            --  92169, -- ??? Raider's Training Dummy <Tanking>
            --  96442, -- ??? Training Dummy <Damage>
            --  97668, -- ??? Boxer's Training Dummy
            --  98581, -- ??? Prepfoot Training Dummy
            -- 107557, -- ??? Training Dummy <Healing>
            -- 108420, -- ??? Training Dummy
            -- 109595, -- ??? Training Dummy
            -- 111824, -- ??? Training Dummy
            -- 113858, -- ??? Training Dummy <Damage>
            -- 113859, -- ??? Dungeoneer's Training Dummy <Damage>
            -- 113860, -- ??? Raider's Training Dummy <Damage>
            -- 113862, -- ??? Training Dummy <Damage>
            -- 113863, -- ??? Dungeoneer's Training Dummy <Damage>
            -- 113864, -- ??? Raider's Training Dummy <Damage>
            -- 113871, -- ??? Bombardier's Training Dummy <Damage>
            -- 113963, -- ??? Raider's Training Dummy <Damage>
            -- 113964, -- ??? Raider's Training Dummy <Tanking>
            -- 113966, -- ??? Dungeoneer's Training Dummy <Damage>
            -- 113967, -- ??? Training Dummy <Healing>
            -- 114832, -- ??? PvP Training Dummy
            -- 114840, -- ??? PvP Training Dummy
    }
    GS.Dummies = {
        "Training Bag",
        "Training Dummy",
        "Dungeoneer's Training Dummy",
        "Raider's Training Dummy",
        "Initiate's Training Dummy",
        "Disciple's Training Dummy",
        "Veterans's Training Dummy",
        "Ebon Knight's Training Dummy",
        "Highlord's Nemesis Trainer",
        "Small Illusionary Amber-Weaver",
        "Large Illusionary Amber-Weaver",
        "Small Illusionary Mystic",
        "Large Illusionary Mystic",
        "Small Illusionary Guardian",
        "Large Illusionary Guardian",
        "Small Illusionary Slayer",
        "Large Illusionary Slayer",
        "Small Illusionary Varmint",
        "Large Illusionary Varmint",
        "Small Illusionary Banana-Tosser",
        "Large Illusionary Banana-Tosser",
    }
    GS.MobsThatInterrupt = {
        "Thok the Bloodthirsty",
        "Pol",
        "Franzok",
        "Grom'kar Firemender",
    }

    GS.SpellData = {
        AffectedByHaste = {key = {}, value = {}, size = 19},
        SpellNameRange = {
            "Insanity",
            "Expel Harm",
            "MMMarked Shot"
        },
        SpellRange = {
            40,
            40,
            40,
        },
        Execute = {
            111240, -- Dispatch
            17877, -- Shadowburn
        }
    }
    GS.DoTThrottleList = {
        34914, -- Vampiric Touch
        157736, -- Immolate
        348, -- Immolate
    }
    GS.SpellKnownTransformTable = {
        [106830] = 106832
    }
    -- Paladin
        GS.SpellData.AffectedByHaste.key[1] = 20473 -- Holy Shock
        GS.SpellData.AffectedByHaste.key[2] = 20271 -- Judgment
        GS.SpellData.AffectedByHaste.key[3] = 35395 -- CS
        GS.SpellData.AffectedByHaste.key[4] = 53595 -- HotR
        GS.SpellData.AffectedByHaste.key[5] = 26573 -- Consecration
        GS.SpellData.AffectedByHaste.key[6] = 119072 -- Holy Wrath
        GS.SpellData.AffectedByHaste.key[7] = 31935 -- Avenger's Shield
        GS.SpellData.AffectedByHaste.key[8] = 53600 -- SotR
        GS.SpellData.AffectedByHaste.key[9] = 879 -- Exorcism
        GS.SpellData.AffectedByHaste.key[10] = 122032 -- Exorcism
        GS.SpellData.AffectedByHaste.key[11] = 24275 -- Hammer of Wrath
            GS.SpellData.AffectedByHaste.value[1] = 6
            GS.SpellData.AffectedByHaste.value[2] = 6
            GS.SpellData.AffectedByHaste.value[3] = 4.5
            GS.SpellData.AffectedByHaste.value[4] = 4.5
            GS.SpellData.AffectedByHaste.value[5] = 9
            GS.SpellData.AffectedByHaste.value[6] = 15
            GS.SpellData.AffectedByHaste.value[7] = 15
            GS.SpellData.AffectedByHaste.value[8] = 1.5
            GS.SpellData.AffectedByHaste.value[9] = 15
            GS.SpellData.AffectedByHaste.value[10] = 15
            GS.SpellData.AffectedByHaste.value[11] = 6

    -- Shaman
        GS.SpellData.AffectedByHaste.key[12] = 17364 -- Stormstrike
        GS.SpellData.AffectedByHaste.key[13] = 115356 -- Windstrike
        GS.SpellData.AffectedByHaste.key[14] = 60103 -- Lava Lash
        GS.SpellData.AffectedByHaste.key[15] = 8050 -- Flame Shock
        GS.SpellData.AffectedByHaste.key[16] = 8056 -- Frost Shock
        GS.SpellData.AffectedByHaste.key[17] = 8042 -- Earth Shock
        GS.SpellData.AffectedByHaste.key[18] = 73680 -- Unleash Elements
        GS.SpellData.AffectedByHaste.key[19] = 1535 -- Fire Nova
            GS.SpellData.AffectedByHaste.value[12] = 7.5
            GS.SpellData.AffectedByHaste.value[13] = 7.5
            GS.SpellData.AffectedByHaste.value[14] = 10.5
            GS.SpellData.AffectedByHaste.value[15] = 6
            GS.SpellData.AffectedByHaste.value[16] = 6
            GS.SpellData.AffectedByHaste.value[17] = 6
            GS.SpellData.AffectedByHaste.value[18] = 15
            GS.SpellData.AffectedByHaste.value[19] = 4.5

    GS.Warrior = {}
    GS.Paladin = {
    }
    GS.Rogue = {
        cpMaxSpend = 5
    }
    GS.Priest = {
        Voidform = {},
        ApparitionsInFlight = 0
    }
    GS.Monk = {
        lastCast = 0
    }
    GS.Druid = {
        RakeMultiplier = {}
    }

    function GS.CacheTalents()
        for i = 1, 7 do
            for v = 1, 3 do
                GS["Talent"..i..v] = GS.PlayerHasTalent(i, v)
            end
        end
    end

    function GS.IncreaseRotationCacheCounter()
        GS.rotationCacheCounter = GS.rotationCacheCounter + 1
    end

    function GS.RaFQuesting()
        if GetNumGroupMembers() < 6 and ObjectExists("focus") then
            AssistUnit("focus")
            if GS.Distance("focus") > 1 then
                MoveTo(ObjectPosition("focus"))
            elseif not UnitUsingVehicle("player") then
                FaceDirection(ObjectFacing("focus"))
                if UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDeadOrGhost("target") then StartAttack() end
            end
        end
    end

    function GS.CheckUpdate(Revision)
        if ReadFile(GetFireHackDirectory().."\\Scripts\\GStar Rotations\\Revision.txt") < Revision then print("GStar Rotations: Update Available") return end
    end

    function GS.CheckUpdateFailed(reason)
        if reason == "no local file" then
            print("GStar Rotations: No Revision.txt found in "..GetFireHackDirectory().."\\Scripts\\GStar Rotations\\\nCannot check for updates.")
        end
    end

    function GS.DownloadURLFailed()
        print("GStar Rotations: Could not check for updates due to failure in DownloadURL().\nCannot check for updates.")
    end

    function GS.CombatInformationFrameEvents(self, registeredEvent, ...)
        if not FireHack or GS.PreventExecution then return end
        -- if registeredEvent == "PLAYER_DEAD" then
        -- identical
        -- end
        --[[else]]
        if registeredEvent == "PLAYER_REGEN_DISABLED" then
            GS.CombatStart = GetTime()
            GS.SpellNotKnown  = {}
            GS.SpellOutranged = {}
            GS.CacheTalents()
            GS.Rogue.cpMaxSpend = (GS.Talent31 and 6 or 5)
            -- identical
            return
        elseif registeredEvent == "PLAYER_REGEN_ENABLED" then
            -- GS.Monk.lastCast = 0
            return
        elseif registeredEvent == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timeNow = GetTime()
            local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, failedType = ...

            -- if event == "UNIT_DIED" then
            -- throttled projectile disjointed due to unit death goes in here
            -- end

            if sourceName ~= UnitName("player") and not tContains(GS.MobsThatInterrupt, sourceName) then return end

            if GS.WaitForCombatLog then GS.WaitForCombatLog = false end

            if event == "SPELL_CAST_START" then  -- MobsThatInterrupt functionality would go in here + healing and projectile throttles
                -- GS.SpellThrottle = (GetTime()+math.random(40, 240)*.001)

                -- Priest

                return
            end
            if event == "SPELL_CAST_FAILED" then  -- unthrottle        functionality would go in here + queueing
                if failedType ~= "Another action is in progress" and failedType ~= "Not yet recovered" and failedType ~= "You can't do that yet" then
                    GS.SpellThrottle = 0
                    -- GS.LastTargetCast = nil
                    GS.Log(spellName..": Unthrottling "..failedType)
                end

                return
            end
            if event == "SPELL_CAST_SUCCESS" then  -- unthrottle        functionality would go in here + queueing success + healing and multi-step throttle
                if spellID ~= 147193 then
                    GS.SpellThrottle = (GetTime()+math.random(20, 60)*.001)+GS.SpellCDDuration(61304)
                end

                if GSR.Class == "MONK" and GS.Spec == 3 --[[and spellID ~= roll and spellID ~= energizing_elixir]] then
                    GS.Monk.lastCast = spellID
                end

                -- Priest
                    if spellID == 147193 and GS.Talent52 then
                        GS.Priest.ApparitionsInFlight = GS.Priest.ApparitionsInFlight + 1
                        return
                    end

                return
            end
            if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" then -- aura detection stuff goes in here eg: hunter steady focus and mob specific dot throttles
                -- Priest
                    if spellID == 34914 then
                        -- GS.Priest.VampiricTouchTarget = nil
                        GS.DoTThrottle = nil
                        return
                    end
                    if spellID == 194249 then -- Entered Void Form
                        GS.Priest.Voidform.PreviousStackTime = timeNow
                        GS.Priest.Voidform.VoidTorrentStart  = nil
                        GS.Priest.Voidform.DispersionStart   = nil
                        GS.Priest.Voidform.DrainStacks       = 1
                        GS.Priest.Voidform.StartTime         = timeNow
                        GS.Priest.Voidform.TotalStacks       = 1
                        GS.Priest.Voidform.VoidTorrentStacks = 0
                        GS.Priest.Voidform.DispersionStacks  = 0
                        return
                    end
                    if spellID == 212570 then -- StM
                        GS.Priest.Voidform.StMActivated = true
                        GS.Priest.Voidform.StMStart = timeNow
                        return
                    end
                    if spellID == 205065 then -- Void Torrent
                        GS.Priest.Voidform.VoidTorrentStart = timeNow
                        return
                    end
                    if spellID == 47585 then -- Dispersion
                        GS.Priest.Voidform.DispersionStart = timeNow
                        return
                    end

                -- Warlock
                    if spellID == 157736 then -- Immolate
                        GS.DoTThrottle = nil
                        return
                    end

                return
            end

            if event == "SPELL_AURA_APPLIED_DOSE" then -- Never seen this before. it's used for buffs that gain stacks without refreshing duration aka void form (mongoose bite?)
                -- Priest
                    if spellID == 194249 then -- Gained Void Form Stack
                        GS.Priest.Voidform.PreviousStackTime = timeNow
                        GS.Priest.Voidform.TotalStacks       = GS.Priest.Voidform.TotalStacks + 1
                        
                        if GS.Priest.Voidform.VoidTorrentStart == nil and GS.Priest.Voidform.DispersionStart == nil then
                            GS.Priest.Voidform.DrainStacks       = GS.Priest.Voidform.DrainStacks       + 1
                        elseif GS.Priest.Voidform.VoidTorrentStart ~= nil then
                            GS.Priest.Voidform.VoidTorrentStacks = GS.Priest.Voidform.VoidTorrentStacks + 1
                        else
                            GS.Priest.Voidform.DispersionStacks  = GS.Priest.Voidform.DispersionStacks  + 1
                        end
                        return
                    end

                return
            end

            if event == "SPELL_AURA_REMOVED" then
                -- Priest
                    if spellID == 194249 then -- Exited Void Form
                        GS.Priest.Voidform.VoidTorrentStart  = nil
                        GS.Priest.Voidform.DispersionStart   = nil
                        GS.Priest.Voidform.DrainStacks       = 0
                        GS.Priest.Voidform.StartTime         = nil
                        GS.Priest.Voidform.TotalStacks       = 0
                        GS.Priest.Voidform.VoidTorrentStacks = 0
                        GS.Priest.Voidform.DispersionStacks  = 0
                        return
                    end
                    if spellID == 212570 then -- StM
                        GS.Priest.Voidform.StMActivated = false
                        return
                    end
                    if spellID == 205065 and GS.Priest.Voidform.VoidTorrentStart ~= nil then -- Void Torrent
                        GS.Priest.Voidform.VoidTorrentStart = nil
                        return
                    end
                    if spellID == 47585 and GS.Priest.Voidform.DispersionStart ~= nil then -- Dispersion
                        GS.Priest.Voidform.DispersionStart = nil
                        return
                    end

                return
            end

            if event == "SPELL_DAMAGE" then -- projectile unthrottles would go in here
                -- Priest
                    if spellID == 148859 and GS.Talent52 then
                        GS.Priest.ApparitionsInFlight = GS.Priest.ApparitionsInFlight - 1
                        return
                    end
                return
            end

            if event == "SPELL_PERIODIC_DAMAGE" then
                -- General
                    if GS.InterruptNextTick and GS.InterruptNextTick == spellName then -- Interrupt Channeling On Tick
                        SpellStopCasting()
                        GS.InterruptNextTick = nil
                        return
                    end

                return
            end
        end
    end

    function GS.CombatInformationFrameCuration()
        if not FireHack or GS.PreventExecution or UnitIsDeadOrGhost("player") then return end

        if not GSR.Mobs and #GS.MobTargets > 0 then table.wipe(GS.MobTargets) end
        if not GSR.Healing and #GS.AllyTargets > 0 then table.wipe(GS.AllyTargets) end

        local unitPlaceholder = nil

        mobTargetsSize = #GS.MobTargets
        allyTargetsSize = #GS.AllyTargets

        for i = 1, ObjectCount() do
            unitPlaceholder = ObjectWithIndex(i)
            if (not GSR.Mobs or not tContains(GS.MobTargets, unitPlaceholder)) and (not GSR.Healing or GS.AllyNotDuplicate(unitPlaceholder)) -- make sure it isn't a duplicate
            and ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) -- make sure it exists
            and (bit.band(ObjectType(unitPlaceholder), 0x8) > 0--[[ or bit.band(ObjectType(unitPlaceholder), 0x10) > 0]]) -- make sure it's a mob or player
            -- and (not GSR.Mobs or not tContains(GS.MobNamesToIgnore, UnitName(unitPlaceholder)) and not tContains(GS.MobTypesToIgnore, UnitCreatureType(unitPlaceholder)) and GS.MobTargetsAuraBlacklist(unitPlaceholder)) -- make sure it's not something we want to ignore todo: make the aura blacklist function
            -- and (not GSR.Healing or GS.AllyTargetsAuraBlacklist(unitPlaceholder)) -- make sure it's not something we want to ignore
            then
                if not GSR.PvPMode and --[[GSR.Mobs and]] bit.band(ObjectType(unitPlaceholder), 0x8) > 0 and bit.band(ObjectType(unitPlaceholder), 0x10) == 0 then -- mobs
                    if GSR.Healing and UnitInParty(unitPlaceholder) then -- friendly mobs
                        if GS.AllyTargetsAuraBlacklist(unitPlaceholder) then
                            GS.AllyTargets[allyTargetsSize+1] = {Player = unitPlaceholder, Stats = {Position = {true,true,true}}, Role = UnitGroupRolesAssigned(unitPlaceholder)}
                            allyTargetsSize = allyTargetsSize + 1
                        end
                    elseif GSR.Mobs and not UnitInParty(unitPlaceholder) and GS.Health(unitPlaceholder) > 0 and UnitCanAttack("player", unitPlaceholder) then -- hostile mobs
                        if not tContains(GS.MobNamesToIgnore, UnitName(unitPlaceholder)) and not tContains(GS.MobTypesToIgnore, UnitCreatureType(unitPlaceholder)) and GS.MobTargetsAuraBlacklist(unitPlaceholder) then
                            GS.MobTargets[mobTargetsSize+1] = unitPlaceholder
                            mobTargetsSize = mobTargetsSize + 1
                        end
                    end
                elseif GSR.PvPMode and GSR.Mobs and bit.band(ObjectType(unitPlaceholder), 0x10) > 0 and UnitCanAttack("player", unitPlaceholder) then -- enemy players
                    if not tContains(GS.MobNamesToIgnore, UnitName(unitPlaceholder)) and not tContains(GS.MobTypesToIgnore, UnitCreatureType(unitPlaceholder)) and GS.MobTargetsAuraBlacklist(unitPlaceholder) then
                    end
                elseif GSR.Healing and bit.band(ObjectType(unitPlaceholder), 0x10) > 0 and UnitInParty(unitPlaceholder) then -- friendly players
                    if GS.AllyTargetsAuraBlacklist(unitPlaceholder) then
                        GS.AllyTargets[allyTargetsSize+1] = {Player = unitPlaceholder, Stats = {Position = {true,true,true}}, Role = UnitGroupRolesAssigned(unitPlaceholder)}
                        allyTargetsSize = allyTargetsSize + 1
                    end
                end
            end
        end

        for i = 1, mobTargetsSize do
            unitPlaceholder = GS.MobTargets[i]
            if not GSR.Mobs or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or GS.Health(unitPlaceholder) == 0 or not UnitCanAttack("player", unitPlaceholder) or not GS.MobTargetsAuraBlacklist(unitPlaceholder) then _G["removeMobTargets"..i] = true end
        end
        for i = mobTargetsSize, 1, -1 do
            if _G["removeMobTargets"..i] then
                table.remove(GS.MobTargets, i)
                _G["removeMobTargets"..i] = false
            end
        end
        -- for i = 1, allyTargetsSize do
        --  unitPlaceholder = GS.AllyTargets.Player
        --  if not GSR.Healing or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or GS.Health(unitPlaceholder) == 0 or UnitName(unitPlaceholder) == "Unknown" then _G["removeAllyTargets"..i] = true end
        -- end
        -- for i = allyTargetsSize, 1, -1 do
        --  if _G["removeAllyTargets"..i] then
        --      table.remove(GS.AllyTargets, i)
        --      _G["removeAllyTargets"..i] = false
        --  end
        -- end

        mobTargetsSize = #GS.MobTargets
        allyTargetsSize = #GS.AllyTargets

        for i = 1, mobTargetsSize do
            unitPlaceholder = GS.MobTargets[i]
            if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and (UnitAffectingCombat(unitPlaceholder) or tContains(GS.Dummies, UnitName(unitPlaceholder))) then
                GS.TTDF(unitPlaceholder)
            end
        end

        for k,v in pairs(GS.TTD) do if not ObjectExists(k) or not UnitExists(k) or GS.Health(k) == 0 or not UnitCanAttack("player", k) or not GS.MobTargetsAuraBlacklist(k) then GS.TTD[k] = nil end end
    end

    function GS.AllyNotDuplicate(unitPassed)
        for i = 1, allyTargetsSize do
            unit = GS.AllyTargets[i].Player
            if unit == unitPassed then return false end
        end
        return true
    end

    -- ripped from CommanderSirow of the wowace forums
    function GS.TTDF(unit) -- keep updated: see if this can be optimized
        -- Setup trigger (once)
        if not nMaxSamples then
            -- User variables
            nMaxSamples = 15             -- Max number of samples
            nScanThrottle = 0.5             -- Time between samples
        end

        -- Training Dummy alternate between 4 and 200 for cooldowns
        if tContains(GS.Dummies, UnitName(unit)) then
            if not GSR.DummyTTDMode or GSR.DummyTTDMode == 1 then
                if (not GS.TTD[unit] or GS.TTD[unit] == 200) then GS.TTD[unit] = 4 return else GS.TTD[unit] = 200 return end
            elseif GSR.DummyTTDMode == 2 then
                GS.TTD[unit] = 4
                return
            else
                GS.TTD[unit] = 200
                return
            end
        end

        -- if health = 0 then set time to death to negative
        if GS.Health(unit) == 0 then GS.TTD[unit] = -1 return end

        -- Query current time (throttle updating over time)
        local nTime = GetTime()
        if not GS.TTDM[unit] or nTime - GS.TTDM[unit].nLastScan >= nScanThrottle then
            -- Current data
            local data = GS.Health(unit)

            if not GS.TTDM[unit] then GS.TTDM[unit] = {start = nTime, index = 1, maxvalue = GS.Health(unit, max)/2, values = {}, nLastScan = nTime, estimate = nil} end

            -- Remember current time
            GS.TTDM[unit].nLastScan = nTime

            if GS.TTDM[unit].index > nMaxSamples then GS.TTDM[unit].index = 1 end
            -- Save new data (Use relative values to prevent "overflow")
            GS.TTDM[unit].values[GS.TTDM[unit].index] = {dmg = data - GS.TTDM[unit].maxvalue, time = nTime - GS.TTDM[unit].start}

            if #GS.TTDM[unit].values >= 2 then
                -- Estimation variables
                local SS_xy, SS_xx, x_M, y_M = 0, 0, 0, 0

                -- Calc pre-solution values
                for i = 1, #GS.TTDM[unit].values do
                    z = GS.TTDM[unit].values[i]
                    -- Calc mean value
                    x_M = x_M + z.time / #GS.TTDM[unit].values
                    y_M = y_M + z.dmg / #GS.TTDM[unit].values

                    -- Calc sum of squares
                    SS_xx = SS_xx + z.time * z.time
                    SS_xy = SS_xy + z.time * z.dmg
                end
                -- for i = 1, #GS.TTDM[unit].values do
                --     -- Calc mean value
                --     x_M = x_M + GS.TTDM[unit].values[i].time / #GS.TTDM[unit].values
                --     y_M = y_M + GS.TTDM[unit].values[i].dmg / #GS.TTDM[unit].values

                --     -- Calc sum of squares
                --     SS_xx = SS_xx + GS.TTDM[unit].values[i].time * GS.TTDM[unit].values[i].time
                --     SS_xy = SS_xy + GS.TTDM[unit].values[i].time * GS.TTDM[unit].values[i].dmg
                -- end

                -- Few last addition to mean value / sum of squares
                SS_xx = SS_xx - #GS.TTDM[unit].values * x_M * x_M
                SS_xy = SS_xy - #GS.TTDM[unit].values * x_M * y_M

                -- Results
                local a_0, a_1, x = 0, 0, 0

                -- Calc a_0, a_1 of linear interpolation (data_y = a_1 * data_x + a_0)
                a_1 = SS_xy / SS_xx
                a_0 = y_M - a_1 * x_M

                -- Find zero-point (Switch back to absolute values)
                a_0 = a_0 + GS.TTDM[unit].maxvalue
                x = - (a_0 / a_1)

                -- Valid/Usable solution
                if a_1 and a_1 < 1 and a_0 and a_0 > 0 and x and x > 0 then
                    GS.TTDM[unit].estimate = x + GS.TTDM[unit].start
                    -- Fallback
                else
                    GS.TTDM[unit].estimate = nil
                end

                -- Not enough data
            else
                GS.TTDM[unit].estimate = nil
            end
            GS.TTDM[unit].index = GS.TTDM[unit].index + 1 -- enable
        end

        if not GS.TTDM[unit].estimate then
            GS.TTD[unit] = math.huge
        elseif nTime > GS.TTDM[unit].estimate then
            GS.TTD[unit] = -1
        else
            GS.TTD[unit] = GS.TTDM[unit].estimate-nTime
        end
    end
    -- ripped from CommanderSirow of the wowace forums

-- Bread
    GS.SavedReturns = {
        SIR = {rotationCacheCounter = 0},
        SCA = {rotationCacheCounter = 0},
        SpellIsUsable = {rotationCacheCounter = 0},
        SpellIsUsableExecute = {rotationCacheCounter = 0},
        SpellCDDuration = {rotationCacheCounter = 0},
        PoolCheck = {rotationCacheCounter = 0},
        InRange = {rotationCacheCounter = 0},
        InRangeNew = {rotationCacheCounter = 0},
        FracCalc = {rotationCacheCounter = 0},
        GCD = {rotationCacheCounter = 0},
        IsCAOCH = {rotationCacheCounter = 0},
        IsCA = {rotationCacheCounter = 0},
        IsCH = {rotationCacheCounter = 0},
    }
    -- Combat Check Functions
        function GS.ValidTarget()
            if ObjectExists("target")
        and UnitExists("target")
            and UnitCanAttack("player", "target")
            and (tContains(GS.Dummies, UnitName("target")) or GS.Health("target") > 1)
            and not UnitIsDead("target")
            and GS.MobTargetsAuraBlacklist("target")
            and (not GSR.CCed or not GS.UnitIsCCed("target"))
            then
                return true
            else
                return false
            end
        end

        function GS.UnitIsTappedByPlayer(mob)
            if UnitTarget("player") and mob == UnitTarget("player") then return true end
            if UnitAffectingCombat(mob) and UnitTarget(mob) then
                local mobTarget = UnitTarget(mob)
                mobTarget = UnitCreator(mobTarget) or mobTarget
                if UnitInParty(mobTarget) then return true end
            end
            return false
        end

        function GS.MobTargetsAuraBlacklist(object)
            local auraToCheck = nil
            for i = 1, #GS.MobTargetsAurasToIgnore do
                auraToCheck = GS.MobTargetsAurasToIgnore[i]
                if GS.Aura(object, auraToCheck) then return false end
            end
            return true
        end

        function GS.AllyTargetsAuraBlacklist(object)
            local auraToCheck = nil
            for i = 1, #GS.AllyTargetsAurasToIgnore do
                auraToCheck = GS.AllyTargetsAurasToIgnore[i]
                if GS.Aura(object, auraToCheck) then return false end
            end
            return true
        end

    -- Gear Functions
        do
            local whisper_of_the_nathrezim = 137020
            function GS.IsEquipped(itemID) -- todo: implement this
                return false
            end
        end

    -- Sorting Functions
        function GS.SortMobTargetsByLowestHealth(a,b)
            return not GS.MobTargetsAuraBlacklist(a) and false or not GS.MobTargetsAuraBlacklist(b) and true or GS.Health(a) < GS.Health(b)
        end

        function GS.SortMobTargetsByHighestTTD(a,b)
            return not GS.GetTTD(a) > GS.GetTTD(b)
        end

        function GS.SortMobTargetsByLowestTTD(a,b)
            return not GS.GetTTD(a) < GS.GetTTD(b)
        end

        function GS.SortMobTargetsByLowestDistance(a,b)
            return not UnitExists(a) and false or not UnitExists(b) and true or GS.Distance(a)-UnitCombatReach(a) < GS.Distance(b)-UnitCombatReach(b)
        end

        function GS.SortMobTargetsByLowestDeadlyPoison(a, b)
            return not GS.Aura(a, 2818, "", "PLAYER") and true or not GS.Aura(b, 2818, "", "PLAYER") and false or (select(7, GS.Aura(a, 2818, "", "PLAYER"))-GetTime()) < (select(7, GS.Aura(b, 2818, "", "PLAYER"))-GetTime())
        end

        function GS.SortAllyTargetsByGreatestDeficit(a,b)
            return (GS.Health(a.Player, _, _, true) > GS.Health(b.Player, _, _, true) or GS.Health(a.Player, _, _, true) == GS.Health(b.Player, _, _, true) and UnitGroupRolesAssigned(a.Player) == "TANK")
        end

        function GS.SortAllyTargetsByLowestDeficit(a,b)
            return (GS.Health(a.Player, _, _, true) < GS.Health(b.Player, _, _, true) or GS.Health(a.Player, _, _, true) == GS.Health(b.Player, _, _, true) and UnitGroupRolesAssigned(a.Player) == "TANK")
        end

        function GS.SortAllyTargetsByTankHealerDamagerNone(a,b)
            return (UnitGroupRolesAssigned(a.Player) == "TANK" and true or UnitGroupRolesAssigned(a.Player) == "HEALER" and UnitGroupRolesAssigned(b.Player) ~= "TANK" and true or UnitGroupRolesAssigned(a.Player) == "DAMAGER" and UnitGroupRolesAssigned(b.Player) ~= "TANK" and UnitGroupRolesAssigned(b.Player) ~= "HEALER" and true or false)
        end

        function GS.SortAllyTargetsByLowestDistance(a,b)
            return not UnitExists(a.Player) and false or not UnitExists(b.Player) and true or GS.Distance(a.Player) < GS.Distance(b.Player)
        end

    -- Unit Functions
        function GS.IsCAOCH(unit)
            if not unit then unit = "player" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.IsCAOCH.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.IsCAOCH[GS.rotationCacheCounter..unitPointer] then return GS.SavedReturns.IsCAOCH[GS.rotationCacheCounter..unitPointer] end
            end
            if ObjectExists(unit) and UnitExists(unit) and (UnitCastingInfo(unit) or UnitChannelInfo(unit)) then GS.SavedReturns.IsCAOCH[GS.rotationCacheCounter..unitPointer] = true return true else GS.SavedReturns.IsCAOCH[GS.rotationCacheCounter..unitPointer] = false return false end
        end

        function GS.IsCA(unit)
            if not unit then unit = "player" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.IsCA.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.IsCA[GS.rotationCacheCounter..unitPointer] then return GS.SavedReturns.IsCA[GS.rotationCacheCounter..unitPointer] end
            end
            if ObjectExists(unit) and UnitExists(unit) and UnitCastingInfo(unit) then GS.SavedReturns.IsCA[GS.rotationCacheCounter..unitPointer] = true return true else GS.SavedReturns.IsCA[GS.rotationCacheCounter..unitPointer] = false return false end
        end

        function GS.IsCH(unit)
            if not unit then unit = "player" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.IsCH.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.IsCH[GS.rotationCacheCounter..unitPointer] then return GS.SavedReturns.IsCH[GS.rotationCacheCounter..unitPointer] end
            end
            if ObjectExists(unit) and UnitExists(unit) and UnitChannelInfo(unit) then GS.SavedReturns.IsCH[GS.rotationCacheCounter..unitPointer] = true return true else GS.SavedReturns.IsCH[GS.rotationCacheCounter..unitPointer] = false return false end
        end

        function GS.Distance(target, base) -- compares distance between two objects if base == nil than base = player
            if not target then target = "target" end
            if not tonumber(target) and string.len(target) >= 6 and string.sub(target, 1, 6) == "Player" then target = "player" end
            if not base or type(base) == "string" and string.len(base) >= 6 and string.sub(base, 1, 6) == "Player" then base = "player" end
            local X1, Y1, Z1 = ObjectPosition(target)
            local X2, Y2, Z2 = nil, nil, nil
            X2, Y2, Z2 = ObjectPosition(base)

            return math.sqrt(((X2 - X1) ^ 2) + ((Y2 - Y1) ^ 2) + ((Z2 - Z1) ^ 2))
        end

        function GS.UnitIsBoss(unit) -- checks the defined boss list todo: change to unit ids
            if not unit then unit = "target" end
            if ObjectExists(unit) and UnitExists(unit) then
                if tContains(GS.BossList, UnitName(unit)) then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end

        function GS.LOS(guid, other, increase)
            other = other or "player"
            if not ObjectExists(guid) or not ObjectExists(other) then return false end
            if tContains(GS.SkipLoS, GS.GetUnitID(guid)) or tContains(GS.SkipLoS, GS.GetUnitID(other)) then return true end
            local X1, Y1, Z1 = ObjectPosition(guid)
            local X2, Y2, Z2 = ObjectPosition(other)
            return not TraceLine(X1, Y1, Z1  + (increase or 2), X2, Y2, Z2 + (increase or 2), 0x10);
        end

        function GS.GetTTD(guid)
            if not guid then guid = "target" end
            return GS.TTD[ObjectPointer(guid)] or math.huge
        end

        function GS.GetUnitID(guid)
            if ObjectExists(guid) and UnitExists(guid) then
                local id = select(6,strsplit("-", UnitGUID(guid) or ""))
                return tonumber(id)
            end
            return 0
        end

    -- Spell Functions
        function GS.PlayerHasTalent(tier, column) -- checks to see if you have the talent in your active spec
            return select(4,GetTalentInfo(tier, column, GetActiveSpecGroup()))
        end

        function GS.SpellCDDuration(spell, max)
            local maxString = tostring(max)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SpellCDDuration.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString] then return GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString] end
            end
            local start, duration = GetSpellCooldown(spell)
            if max then
                for i = 1, GS.SpellData.AffectedByHaste.size do
                    if GS.SpellData.AffectedByHaste.key[i] == spell then return GS.SpellData.AffectedByHaste.value[i]/(1+GetHaste()*.01) end
                end
                GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString] = GetSpellBaseCooldown(spell)*.001
                return GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString]
            elseif start == 0 then
                GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString] = 0
                return 0
            else
                GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString] = (start + duration - GetTime())
                return GS.SavedReturns.SpellCDDuration[GS.rotationCacheCounter..spell..maxString]
            end
        end

        function GS.ChargeCD(spell)
            if GetSpellCharges(spell) == select(2, GetSpellCharges(spell)) then return 0 end
            return select(4, GetSpellCharges(spell))-(GetTime()-select(3, GetSpellCharges(spell)))
        end

        function GS.CastTime(spell)
            return (select(4, GetSpellInfo(spell))*0.001)
        end

        function GS.SIR(spell, execute)
            local executeString = tostring(execute)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SIR.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.SIR[GS.rotationCacheCounter..spell..executeString] then return GS.SavedReturns.SIR[GS.rotationCacheCounter..spell..executeString] end
            end
            if type(spell) ~= "string" and type(spell) ~= "number" then return false end
            local spellTransform = 0; if GS.SpellKnownTransformTable[spell] then spellTransform = GS.SpellKnownTransformTable[spell] end
            if not (type(spellTransform ~= 0 and spellTransform or spell) == "number" and GetSpellInfo(GetSpellInfo(spellTransform ~= 0 and spellTransform or spell)) or type(spellTransform ~= 0 and spellTransform or spell) == "string" and GetSpellLink(spellTransform ~= 0 and spellTransform or spell) or IsSpellKnown(spellTransform ~= 0 and spellTransform or spell)) then
                if not GS.SpellNotKnown[spellTransform ~= 0 and spellTransform or spell] then
                    GS.SpellNotKnown[spellTransform ~= 0 and spellTransform or spell] = true
                    GS.Log("Spell not known: "..(spellTransform ~= 0 and spellTransform or spell).." Please Verify.")
                end
                GS.SavedReturns.SIR[GS.rotationCacheCounter..spell..executeString] = false
                return false
            end
            -- if (type(spell) == "number" and GetSpellInfo(GetSpellInfo(spell)) or type(spell) == "string" and GetSpellLink(spell) or IsSpellKnown(spell) or spell == 77758 --[[or UnitLevel("player") == 100]]) -- thrash bear
            --[[and]] --[[if]]if GS.SpellCDDuration(spell) <= 0
            and (execute and GS.SpellIsUsableExecute(spell) or GS.SpellIsUsable(spell))
            and (not GSR.Thok or GS.ThokThrottle < GetTime() or select(4, GetSpellInfo(spell)) <= 0 or GS.ThokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001)) -- bottom aurar are ice floes , Kil'jaedens cunning, spiritwalker's grace
            and (UnitMovementFlags("player") == 0 or select(4, GetSpellInfo(spell)) <= 0 or spell == 77767 or spell == 56641 or spell == aimed_shot or spell == 2948 or not GS.AuraRemaining("player", 108839, (select(4, GetSpellInfo(spell))*0.001)) or not GS.AuraRemaining("player", 79206, (select(4, GetSpellInfo(spell))*0.001)))
            -- Ice Floes, SpiritWalker's Grace
            then
                GS.SavedReturns.SIR[GS.rotationCacheCounter..spell..executeString] = true
                return true
            else
                GS.SavedReturns.SIR[GS.rotationCacheCounter..spell..executeString] = false
                return false
            end
        end

        function GS.SCA(spell, unit, casting, execute)
            local castingString, executeString = tostring(casting), tostring(execute)
            if not unit then unit = "target" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SCA.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.SCA[GS.rotationCacheCounter..spell..unitPointer..castingString..executeString] then return GS.SavedReturns.SCA[GS.rotationCacheCounter..spell..unitPointer..castingString..executeString] end
            end
            if tContains(GS.DoTThrottleList, spell) and unit == GS.DoTThrottle then GS.SavedReturns.SCA[GS.rotationCacheCounter..spell..unitPointer..castingString..executeString] = false return false end
            if string.sub(unit, 1, 6) == "Player" then unit = ObjectPointer("player") end
            if ObjectExists(unit) and UnitExists(unit)
            and GS.SIR(spell, execute)
            and (GS.InRange(spell, unit) or UnitName(unit) == "Al'Akir") -- fixme: inrange needs an overhaul in the distant future, example Al'Akir @framework @notimportant
            and (not GS.IsCAOCH("player") or casting--[[ and UnitChannelInfo("player") ~= GetSpellInfo(spell) and UnitCastingInfo("player") ~= GetSpellInfo(spell)]])
            and (not GSR.Thok or GS.ThokThrottle < GetTime() or GS.ThokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001))
            and (not GSR.LoS or GS.LOS(unit)) -- fixme: LOS @framework
            and (not GSR.CCed or not GS.UnitIsCCed(unit))
            then
                GS.SavedReturns.SCA[GS.rotationCacheCounter..spell..unitPointer..castingString..executeString] = true
                return true
            else
                GS.SavedReturns.SCA[GS.rotationCacheCounter..spell..unitPointer..castingString..executeString] = false
                return false
            end
        end

        function GS.SpellIsUsable(spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SpellIsUsable.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.SpellIsUsable[GS.rotationCacheCounter..spell] then return GS.SavedReturns.SpellIsUsable[GS.rotationCacheCounter..spell] end
            end
            local isUsable, notEnoughMana = IsUsableSpell(spell)
            if isUsable and not notEnoughMana then
                GS.SavedReturns.SpellIsUsable[GS.rotationCacheCounter..spell] = true
                return true
            else
                GS.SavedReturns.SpellIsUsable[GS.rotationCacheCounter..spell] = false
                return false
            end
        end

        function GS.SpellIsUsableExecute(spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SpellIsUsableExecute.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.SpellIsUsableExecute[GS.rotationCacheCounter..spell] then return GS.SavedReturns.SpellIsUsableExecute[GS.rotationCacheCounter..spell] end
            end
            local isUsable, notEnoughMana = IsUsableSpell(spell)
            if not notEnoughMana then
                GS.SavedReturns.SpellIsUsableExecute[GS.rotationCacheCounter..spell] = true
                return true
            else
                GS.SavedReturns.SpellIsUsableExecute[GS.rotationCacheCounter..spell] = false
                return false
            end
        end

        function GS.PoolCheck(spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.PoolCheck.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.PoolCheck[GS.rotationCacheCounter..spell] then return GS.SavedReturns.PoolCheck[GS.rotationCacheCounter..spell] end
            end
            local isUsable, notEnoughMana = IsUsableSpell(spell)
            if GS.SpellCDDuration(spell) <= 0
            and not isUsable
            and notEnoughMana
            then
                GS.SavedReturns.PoolCheck[GS.rotationCacheCounter..spell] = true
                return true
            else
                GS.SavedReturns.PoolCheck[GS.rotationCacheCounter..spell] = false
                return false
            end
        end

        function GS.InRangeNew(spell, unit)
            if not unit then unit = "target" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.InRangeNew.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.InRangeNew[GS.rotationCacheCounter..spell..unitPointer] then return GS.SavedReturns.InRangeNew[GS.rotationCacheCounter..spell..unitPointer] end
            end
            local spellToString
            -- if tonumber(spell) then spellToString = GetSpellInfo(spell) end
            local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spell)
            if ObjectExists(unit) and UnitExists(unit) and GS.Health(unit) > 0 then
                if maxRange <= 5 then -- Melee Attack
                    local combatReach = UnitCombatReach("player")+UnitCombatReach("target")
                    local movingBenefit = 0
                    -- local movingBenefit = (UnitMovementFlags("player") > 0 and UnitMovementFlags("target") > 0 and (8/3) or 0)
                    GS.SavedReturns.InRangeNew[GS.rotationCacheCounter..spell..unitPointer] = (GS.Distance("target") < ((5 > (combatReach+4/3) and 5 or combatReach+4/3) + movingBenefit))
                    return GS.Distance("target") < ((5 > (combatReach+4/3) and 5 or combatReach+4/3) + movingBenefit)
                elseif minRange == 0 then
                    local movingBenefit = 0
                    -- local movingBenefit = (UnitMovementFlags("player") > 0 and UnitMovementFlags("target") > 0 and (8/3) or 0)
                elseif minRange > 0 then
                    local movingBenefit = 0
                    -- local movingBenefit = (UnitMovementFlags("player") > 0 and UnitMovementFlags("target") > 0 and (8/3) or 0)
                end
            end
        end

        function GS.InRange(spell, unit)
            if not unit then unit = "target" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.InRange.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] then return GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] end
            end
            local spellToString

            if tonumber(spell) then spellToString = GetSpellInfo(spell) end

            if ObjectExists(unit) and UnitExists(unit) and GS.Health(unit) > 0 then
                local inRange = IsSpellInRange(spellToString, unit)

                if inRange == 1 then
                    GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] = true
                    return true
                elseif inRange == 0 then
                    if not GS.SpellOutranged[spell] then
                        GS.SpellOutranged[spell] = true
                        GS.Log("Spell out of Range: "..spell.." Please Verify.")
                    end
                    GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] = false
                    return false
                elseif (tContains(GS.SpellData.SpellNameRange, spellToString) or tContains(GS.SpellData.SpellNameRange, "MM"..spellToString)) then
                    for i = 1, #GS.SpellData.SpellNameRange do
                        if GS.SpellData.SpellNameRange[i] == spellToString then
                            GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] = (GS.Distance(unit) <= GS.SpellData.SpellRange[i])
                            return GS.Distance(unit) <= GS.SpellData.SpellRange[i]
                        elseif GS.SpellData.SpellNameRange[i] == "MM"..spellToString then
                            GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] = (GS.Distance(unit) <= (GS.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100)))
                            return GS.Distance(unit) <= (GS.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100))
                        end
                    end
                -- elseif FindSpellBookSlotBySpellID(spell) then
                --     return IsSpellInRange(FindSpellBookSlotBySpellID(spell), "spell", unit) == 1
                else
                    for i = 1, 200 do
                        if GetSpellBookItemName(i, "spell") == spellToString then
                            if IsSpellInRange(i, "spell", unit) == 1 then
                                GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] = true
                                return true
                            else
                                if not GS.SpellOutranged[spell] then
                                    GS.SpellOutranged[spell] = true
                                    GS.Log("Spell out of Range: "..spell.." Please Verify.")
                                end
                                GS.SavedReturns.InRange[GS.rotationCacheCounter..spell..unitPointer] = false
                                return false
                            end
                        end
                    end
                    if not GS.SpellOutranged[spell] then
                        GS.SpellOutranged[spell] = true
                        GS.Log("Spell has no range: "..spell.." Please Verify and add Custom.")
                    end
                end
            end
        end

        function GS.FracCalc(mode, spell) -- todo: add normal spells and support hasted ones
            if GSR.Dev.CachedFunctions and GS.SavedReturns.FracCalc.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.FracCalc[GS.rotationCacheCounter..mode..spell] then return GS.SavedReturns.FracCalc[GS.rotationCacheCounter..mode..spell] end
            end
            if mode == "spell" then
                local spellFrac = 0
                local cur, max, start, duration = GetSpellCharges(spell)

                if cur then
                    if cur >= 1 then spellFrac = spellFrac + cur end
                    if spellFrac == max then return spellFrac end
                    spellFrac = spellFrac + (GetTime()-start)/duration
                    GS.SavedReturns.FracCalc[GS.rotationCacheCounter..mode..spell] = spellFrac
                    return spellFrac
                else
                    return print("Tried to calculate fraction of a non charge based skill")
                end
            elseif mode == "rune" then
            end
        end

    -- Healing Functions
        function GS.LowestPlayer(range, mode)
            local unitPlaceholder = nil
            local lowestPercentSoFar = 101
            local lowestMobSoFar = nil
            table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)

            for i = 1, allyTargetsSize do
                unitPlaceholder = GS.AllyTargets[i].Player
                if ObjectExists(unitPlaceholder)
                and (not range or GS.Distance(unitPlaceholder) <= range)
                and --[[GS.Health(unitPlaceholder) ~= 0]] not UnitIsDeadOrGhost(unitPlaceholder) and GS.Health(unitPlaceholder, _, true) <= lowestPercentSoFar
                and (not mode or mode == "CH" and GS.Aura(unitPlaceholder, 61295, "", "PLAYER") or mode == "RENEW" and not GS.Aura(unitPlaceholder, 139, "", "PLAYER") and (GS.Health(unitPlaceholder, _, true) < 100 or UnitGroupRolesAssigned(unitPlaceholder) == "TANK"))
                then
                    lowestMobSoFar = unitPlaceholder
                    lowestPercentSoFar = GS.Health(unitPlaceholder, _, true)
                end
            end

            return lowestMobSoFar
        end

        function GS.HealingAmount(spell) -- todo: make sure each one of these works
            GSHealingTooltipFrame:ClearLines()
            GSHealingTooltipFrame:SetSpellByID(61304)
            GSHealingTooltipFrame:SetAlpha(0)
            if GSHealingTooltipFrameTextLeft1:GetText() ~= "Global Cooldown" then
                GSHealingTooltipFrame:SetOwner(UIParent)
                GSHealingTooltipFrame:SetAlpha(0)
            end
            GSHealingTooltipFrame:ClearLines()
            if spell == "Enveloping Mist" then
                GSHealingTooltipFrame:SetSpellByID(124682)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Effuse" then
                GSHealingTooltipFrame:SetSpellByID(116694)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Vivify" then
                GSHealingTooltipFrame:SetSpellByID(116670)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d[,.]?%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Essence Font" then
                GSHealingTooltipFrame:SetSpellByID(191837)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d[,.]?%d[,.]?%d+[,.]%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Mistwalk" then
                GSHealingTooltipFrame:SetSpellByID(197945)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Zen Pulse" then
                GSHealingTooltipFrame:SetSpellByID(124081)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Chi Burst" then
                GSHealingTooltipFrame:SetSpellByID(123986)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne, healingStringPlaceholderTwo = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "(%d[,.]?%d[,.]?%d+[,.]?%d*).-(%d[,.]?%d[,.]?%d+[,.]?%d*)")
                healingStringPlaceholderTwo = string.gsub(healingStringPlaceholderTwo, "%D", "")
                return tonumber(healingStringPlaceholderTwo)
            elseif spell == "Refreshing Jade Wind" then
                GSHealingTooltipFrame:SetSpellByID(196725)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            
            elseif spell == "Penance" then
                GSHealingTooltipFrame:SetSpellByID(47540)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d* he")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            elseif spell == "Plea" then
                GSHealingTooltipFrame:SetSpellByID(200829)
                GSHealingTooltipFrame:SetAlpha(0)
                healingStringPlaceholderOne = string.match(GSHealingTooltipFrameTextLeft4:GetText(), "%d+[,.]?%d*")
                healingStringPlaceholderOne = string.gsub(healingStringPlaceholderOne, "%D", "")
                return tonumber(healingStringPlaceholderOne)
            end
        end

    -- Resources
        function GS.Health(guid, max, percent, deficit) -- returns the units max health if max is true, percentage remaining if percent is true and max is false, deficit if deficit is true, or current health
            if max then
                return UnitHealthMax(guid)
            elseif percent then
                return UnitHealth(guid)/UnitHealthMax(guid)*100
            elseif deficit then
                return UnitHealthMax(guid)-UnitHealth(guid)
            else
                return UnitHealth(guid)
            end
        end

        function GS.PM() return UnitPower("player")/UnitPowerMax("player")*100 end -- return percentage of mana or default power

        function GS.PP(mode) -- Returns Primary Resources, modes are max or deficit otherwise current, Excluding Chi and Combo Points Use GS.CP(mode)
            local vPower = nil
            if GSR.Class == "WARRIOR" then vPower = 1 end -- Rage
            if GSR.Class == "PALADIN" and GS.Spec == 3 then vPower = 9 end -- Holy Power
            if GSR.Class == "HUNTER" then vPower = 2 end -- Focus
            if GSR.Class == "ROGUE" then vPower = 3 end -- Energy Use GS.CP() for Combo Points
            if GSR.Class == "PRIEST" and GS.Spec == 3 then vPower = 13 end -- Insanity
            if GSR.Class == "SHAMAN" and GS.Spec ~= 3 then vPower = 11 end -- Maelstrom
            if GSR.Class == "MAGE" and GS.Spec == 1 then vPower = 16 end -- Arcane Charges
            if GSR.Class == "WARLOCK" then vPower = 7 end -- Soul Shards
            if GSR.Class == "MONK" and GS.Spec == 1 then vPower = 3 end -- Energy
            if GSR.Class == "MONK" and GS.Spec == 3 then vPower = 3 end -- Energy
            if GSR.Class == "DRUID" and GS.Spec == 1 then vPower = 8 end -- Astral Power
            if GSR.Class == "DRUID" and GS.Spec == 2 then vPower = 3 end -- Energy Use GS.CP() for Combo Points
            if GSR.Class == "DRUID" and GS.Spec == 3 then vPower = 1 end -- Rage
            -- DEMON HUNTER
            if GSR.Class == "DEATHKNIGHT" then vPower = 6 end -- Runic Power
            if not vPower then vPower = 0 end
            if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) else return UnitPower("player", vPower) end
        end

        function GS.CP(mode) -- Returns Chi and Combo Points, modes are max or deficit otherwise current, for Primary Resources Use GS.PP(mode)
            local vPower = (GSR.Class == "MONK" and 12 or 4)
            if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) else return UnitPower("player", vPower) end
        end

        function GS.GCD()
            if GSR.Class..GS.Spec == "MONK3" then return 1 end
            if GSR.Dev.CachedFunctions and GS.SavedReturns.GCD.rotationCacheCounter == GS.rotationCacheCounter then
                if GS.SavedReturns.GCD[GS.rotationCacheCounter.."Result"] then return GS.SavedReturns.GCD[GS.rotationCacheCounter.."Result"] end
            end
            GS.SavedReturns.GCD[GS.rotationCacheCounter.."Result"] = math.max((1.5/(1+GetHaste()*.01)), 0.75)
            return math.max((1.5/(1+GetHaste()*.01)), 0.75)
        end

    -- Aura Functions
        function GS.Aura(guid, ...) -- Example GS.Aura("target", 1234, "", "PLAYER") everything past the 2nd argument is not required
            for i = 1, select("#", ...) do
                auraTable[i] = select(i, ...)
            end

            for i = select("#", ...)+1, #auraTable do
                auraTable[i] = nil
            end

            if type(auraTable[1]) == "number" then auraTable[1] = GetSpellInfo(auraTable[1]) end
            if type(guid) == "string" and string.sub(guid, 1, 6) == "Player" then guid = "player" end

            if not ObjectExists(guid) or not UnitExists(guid) then return false end

            -- return UnitBuff(guid, unpack(auraTable)) or UnitDebuff(guid, unpack(auraTable)) or UnitAura(guid, unpack(auraTable))
            if UnitBuff(guid, unpack(auraTable)) then return UnitBuff(guid, unpack(auraTable)) elseif UnitDebuff(guid, unpack(auraTable)) then return UnitDebuff(guid, unpack(auraTable)) else return UnitAura(guid, unpack(auraTable)) end
        end

        function GS.AuraRemaining(unit, buff, time, ...) -- ... is the same as above, this checks for <= the time argument. if you want greater than, than do "not GS.AuraRemaining", this will return true if the aura isn't there
            if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
            if ObjectExists(unit) and UnitExists(unit) then
                if tonumber(buff) then buff = GetSpellInfo(buff) end
                local name, _, _, _, _, _, expires = GS.Aura(unit, buff, ...)
                if not name then return true
                elseif (expires-GetTime()) <= time then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end

        function GS.AuraStacks(unit, buff, stacks, ...) -- ... is the same as above, this checks for >= stacks argument, if you want less than, than do "not GS.AuraStacks", this will return false if the aura isn't there
            if type(unit) == "string" and string.sub(unit, 1, 6) == "Player" then unit = "player" end
            if ObjectExists(unit) and UnitExists(unit) then
                if tonumber(buff) then buff = GetSpellInfo(buff) end
                local name, _, _, count = GS.Aura(unit, buff, ...)
                if not name then return false end
                if count >= stacks then
                    return true
                else
                    return false
                end
            else
                return false
            end
        end

        function GS.Bloodlust(remaining)
            if remaining then
                return ((GS.Aura("player", 80353) and not GS.AuraRemaining("player", 80353, remaining))
                        or (GS.Aura("player", 2825) and not GS.AuraRemaining("player", 2825, remaining))
                        or (GS.Aura("player", 32182) and not GS.AuraRemaining("player", 32182, remaining))
                        or (GS.Aura("player", 90355) and not GS.AuraRemaining("player", 90355, remaining))
                        or (GS.Aura("player", 160452) and not GS.AuraRemaining("player", 160452, remaining))
                        or (GS.Aura("player", 146555) and not GS.AuraRemaining("player", 146555, remaining))
                        or (GS.Aura("player", 178207) and not GS.AuraRemaining("player", 178207, remaining)))
            end
            if GS.Aura("player", 80353) or GS.Aura("player", 2825) or GS.Aura("player", 32182) or GS.Aura("player", 90355) or GS.Aura("player", 160452) or GS.Aura("player", 146555) or GS.Aura("player", 178207) then
                return true
            else
                return false
            end
        end

    -- AoE Functions
        function GS.PlayerAoECount(yards, tapped)
            local GMobCount = 0
            local unitPlaceholder = nil

            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
            end

            return GMobCount
        end

        function GS.TargetAoECount(yards, tapped)
            if not ObjectExists("target") or not UnitExists("target") or UnitHealth("target") == 0 then return 0 end

            local GMobCount = 0
            local unitPlaceholder = nil

            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder, "target") <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
            end

            if GMobCount == 0 then return 1 else return GMobCount end
        end

        function GS.PlayerCount(yards, tapped, goal, mode, goal2)
            local GMobCount = 0
            local unitPlaceholder = nil

            if mode == "==" then
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount > goal then return false end
                end
                return GMobCount == goal
            elseif mode == "<=" then
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount > goal then return false end
                end
                return GMobCount <= goal
            elseif mode == "<" then
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount >= goal then return false end
                end
                return GMobCount < goal
            elseif mode == ">=" then
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount >= goal then return true end
                end
                return false
            elseif mode == ">" then
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount > goal then return true end
                end
                return false
            elseif mode == "~=" then
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount > goal then return true end
                end
                if GMobCount < goal then return true end
                return false
            elseif mode == "inclusive" then
                local higherGoal = math.max(goal, goal2)
                local lowerGoal = math.min(goal, goal2)
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                        GMobCount = GMobCount + 1
                    end
                    if GMobCount > higherGoal then return false end
                end
                if GMobCount < lowerGoal then return false end
                return true
            end
            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder) <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
            end

            return GMobCount
        end

        function GS.TargetCount(yards, tapped)
            if not ObjectExists("target") or not UnitExists("target") or UnitHealth("target") == 0 then return 0 end

            local GMobCount = 0
            local unitPlaceholder = nil

            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder, "target") <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
            end

            if GMobCount == 0 then return 1 else return GMobCount end
        end

        function GS.FocusCount(yards, tapped)
            if not ObjectExists("focus") or not UnitExists("focus") or UnitHealth("focus") == 0 then return 0 end

            local GMobCount = 0
            local unitPlaceholder = nil

            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder, "focus") <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
            end

            return GMobCount
        end

        function GS.BeastCleaveCount(yards, tapped)
            local GMobCount = 0
            local unitPlaceholder = nil

            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) and GS.Distance(unitPlaceholder, "pet") <= yards+UnitCombatReach(unitPlaceholder) and (GS.UnitIsTappedByPlayer(unitPlaceholder) or not tapped) then
                    GMobCount = GMobCount + 1
                end
            end

            return GMobCount
        end

        function GS.PullAllies(reach)
            if allyTargetsSize == 0 then return {} end
            local unitPlaceholder = nil
            local units = {}
            local unitsSize = 0
            for i = 1, allyTargetsSize do
                unitPlaceholder = GS.AllyTargets[i].Player
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                    if GS.Distance(unitPlaceholder) <= reach then
                        units[unitsSize+1] = unitPlaceholder
                        unitsSize = unitsSize + 1
                    end
                end
            end
            return units
        end

        function GS.SmartAoEFriendly(reach, size, tableX, outsideRotation)
            local units = GS.PullAllies(reach)
            local win = 0
            local winners = {}
            for _, enemy in ipairs(units) do
                local preliminary = {} -- new
                local neighbors = 0
                for _, neighbor in ipairs(units) do
                    if GS.Distance(enemy, neighbor) <= size then
                        table.insert(preliminary, neighbor)
                        neighbors = neighbors + 1
                    end
                end
                if neighbors >= win and neighbors > 0 then
                    winners = preliminary
                    -- table.insert(winners, enemy)
                    win = neighbors
                end
            end
            if tableX then return winners end
            rotationXC, rotationYC, rotationZC = GS.AvgPosObjects(winners)
            if outsideRotation then return rotationXC, rotationYC, rotationZC end
            return true
        end

        function GS.PullEnemies(reach, tapped, combatreach) -- gets enemies in an AoE
            if mobTargetsSize == 0 then return {} end
            local unitPlaceholder = nil
            local units = {}
            local unitsSize = 0
            for i = 1, mobTargetsSize do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                    if GS.Distance(unitPlaceholder) <= reach+(combatreach and UnitCombatReach(unitPlaceholder) or 0) and (not tapped or GS.UnitIsTappedByPlayer(unitPlaceholder) or tContains(GS.Dummies, UnitName(unitPlaceholder))) then
                        units[unitsSize+1] = unitPlaceholder
                        unitsSize = unitsSize + 1
                    end
                end
            end
            return units
        end

        function GS.SmartAoE(reach, size, tapped, tableX, outsideRotation) -- smart aoe placement --[[credits to phelps a.k.a doc|brown]]
            local units = GS.PullEnemies(reach, tapped)
            local win = 0
            local winners = {}
            for _, enemy in ipairs(units) do
                local preliminary = {} -- new
                local neighbors = 0
                for _, neighbor in ipairs(units) do
                    if GS.Distance(enemy, neighbor) <= size then
                        table.insert(preliminary, neighbor) -- new
                        neighbors = neighbors + 1
                    end
                end
                if neighbors >= win and neighbors > 0 then
                    winners = preliminary
                    -- table.insert(winners, enemy)
                    win = neighbors
                end
            end
            if tableX then return winners end
            rotationXC, rotationYC, rotationZC = GS.AvgPosObjects(winners)
            if outsideRotation then return rotationXC, rotationYC, rotationZC end
            return true
            -- return GS.AvgPosObjects(winners)
        end -- use it like this: GS.Cast(nil, 104232, GSmartAoE(35, 8))

        function GS.AvgPosObjects(table)
            local Total = #table;
            local X, Y, Z = 0, 0, 0;

            if Total == 0 then return nil, nil, nil end

            for Key, ThisObject in pairs(table) do
                if ThisObject then
                    local ThisX, ThisY, ThisZ = ObjectPosition(ThisObject);
                    if ThisX and ThisY then
                        X = X + ThisX;
                        Y = Y + ThisY;
                        Z = Z + ThisZ;
                    end
                end
            end

            X = X / Total;
            Y = Y / Total;
            Z = Z / Total;
            return X, Y, Z;
        end

        function GS.DoTCached(obj, table)
            local table1, table2 = "t"..table, "tNoObject"..table
            if tContains(GS[table1], obj) or tContains(GS[table2], obj) then return false else return true end
        end

        function GS.MultiDoT(spell, range)
            local unitPlaceholder = nil
            local spelltable = string.gsub(spell, "%s", "")
            spelltable = string.gsub(spelltable, ":", "")

            if not GS["tNoObject"..spelltable] then GS["tNoObject"..spelltable] = {} end
            if not GS["t"..spelltable] then GS["t"..spelltable] = {} end

            for i = #GS["tNoObject"..spelltable], 1, -1 do -- delete don't belong
                unitPlaceholder = GS["tNoObject"..spelltable][i]
                if not tContains(GS.MobTargets, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or range and range < GS.Distance(obj) then
                    table.remove(GS["tNoObject"..spelltable], i) -- preliminaries
                else -- check for aura
                    local name = GS.Aura(unitPlaceholder, spell, "", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Lunar", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Solar", "PLAYER")
                    if name then table.remove(GS["tNoObject"..spelltable], i) end -- aura is there
                end
            end
            for i = #GS["t"..spelltable], 1, -1 do -- delete don't belong
                unitPlaceholder = GS["t"..spelltable][i]
                if not tContains(GS.MobTargets, unitPlaceholder) or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or range and range < GS.Distance(unitPlaceholder) then table.remove(GS["t"..spelltable], i) -- preliminaries
                else
                    local name = GS.Aura(unitPlaceholder, spell, "", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Lunar", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Solar", "PLAYER")
                    if not name then table.remove(GS["t"..spelltable], i) end -- aura is not there
                end
            end

            for i = 1, #GS.MobTargets do
                unitPlaceholder = GS.MobTargets[i]
                if ObjectExists(unitPlaceholder) and UnitExists(unitPlaceholder) then
                    local unitPlaceholder = GS.MobTargets[i]
                    if GS.DoTCached(unitPlaceholder, spelltable)
                    and (GS.UnitIsTappedByPlayer(unitPlaceholder) or tContains(GS.Dummies, UnitName(unitPlaceholder)))
                    and (not range or range >= GS.Distance(unitPlaceholder)+GS.CombatReach(unitPlaceholder)) then
                        local name = GS.Aura(unitPlaceholder, spell, "", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Feral, Guardian", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Metamorphosis", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Lunar", "PLAYER") or GS.Aura(unitPlaceholder, spell, "Solar", "PLAYER")
                        if name then table.insert(GS["t"..spelltable], unitPlaceholder) end
                        if not name and --[[GS.Distance(unitPlaceholder) <= 50 and ]]UnitCanAttack("player", unitPlaceholder) --[[and GS.LOS(unitPlaceholder)]] then table.insert(GS["tNoObject"..spelltable], unitPlaceholder) end -- fixme: LOS @framework
                    end
                end
            end
        end

    -- Cast Functions
        function GS.Cast(guid, Name, x, y, z, interrupt, reason)
            if GS.WaitForCombatLog then return end
            local name = Name
            if type(Name) == "number" then Name = GetSpellInfo(Name) end

            if UnitChannelInfo("player") then
                local spell = UnitChannelInfo("player")

                if type(interrupt) == "string" and interrupt ~= "SpellToInterrupt" then
                    if interrupt == "chain" and spell == Name then GS.Log("Going to Chain.") end
                    if spell == interrupt then SpellStopCasting() end
                    if interrupt == "nextTick" then
                        GS.InterruptNextTick = spell
                        return
                    end
                    if ("nextTick "..spell) == interrupt then
                        GS.InterruptNextTick = string.gsub(interrupt, "nextTick ", "")
                        return
                    end
                elseif type(interrupt) == "table" then
                    if tContains(interrupt, spell) then SpellStopCasting() end
                elseif interrupt == "all" then
                    SpellStopCasting()
                elseif type(interrupt) == "number" then
                    if name == interrupt then SpellStopCasting() end
                elseif interrupt ~= "SpellToInterrupt" and interrupt ~= nil then
                    return
                end
            elseif UnitCastingInfo("player") then
                local spell = UnitCastingInfo("player")
                if type(interrupt) == "string" and interrupt ~= "SpellToInterrupt" then
                    if spell == interrupt then SpellStopCasting() end
                elseif type(interrupt) == "table" then
                    if tContains(interrupt, spell) then SpellStopCasting() end
                elseif interrupt == "all" then
                    SpellStopCasting()
                elseif type(interrupt) == "number" then
                    if name == interrupt then SpellStopCasting() end
                elseif interrupt ~= "SpellToInterrupt" and interrupt ~= nil then
                    return
                end
            end

            if not guid then guid = "target" end
            if UnitGUID("player") == guid then guid = "player" end

            if tContains(GS.DoTThrottleList, name) then GS.DoTThrottle = guid end
            if not guid then
                CastSpellByName(Name)
            else
                CastSpellByName(Name, guid)
            end

            if IsAoEPending() then
                if x and y and z then
                    CastAtPosition(x + math.random(-0.01, 0.01), y + math.random(-0.01, 0.01), z + math.random(-0.01, 0.01))
                else
                    rotationXC, rotationYC, rotationZC = ObjectPosition(guid)
                    CastAtPosition(rotationXC + math.random(-0.01, 0.01), rotationYC + math.random(-0.01, 0.01), rotationZC + math.random(-0.01, 0.01))
                end
                if IsAoEPending() then
                    CancelPendingSpell()
                    return
                end
            end
            -- debug stuff
            if GSR.Dev and GSR.Dev.CastInformation then
                lsuWA = name
                GS.DebugTable["debugStack"] = string.gsub(debugstack(2, 100, 100), '%[string "local function GetScriptName %(%) return "gst..."%]', "line")
                -- GS.DebugTable["debugStack"] = string.gsub(string.gsub(debugstack(2, 100, 100), GetFireHackDirectory().."\Scripts\GStar Rotations\\GStar.lua", "line"), "\n$", "")
                GS.DebugTable["pointer"] = guid or "N/A"
                if GS.DebugTable["pointer"] ~= "N/A" then GS.DebugTable["nameOfTarget"] = UnitName(guid) else GS.DebugTable["nameOfTarget"] = "N/A" end
                GS.DebugTable["ogSpell"] = name
                GS.DebugTable["Spell"] = Name
                GS.DebugTable["x"] = x or "N/A"
                GS.DebugTable["y"] = y or "N/A"
                GS.DebugTable["z"] = z or "N/A"
                GS.DebugTable["interrupt"] = interrupt or "N/A"
                GS.DebugTable["rotationCacheCounter"] = GS.rotationCacheCounter
                GS.DebugTable["timeSinceLast"] = GS.DebugTable["time"] and (GetTime() - GS.DebugTable["time"]) or 0
                GS.DebugTable["time"] = GetTime()
                GS.DebugTable["reason"] = reason or "N/A"
                -- GS.DebugTable["performance"] = debugprofilestop()-timedebug
                if GSR.Dev.DevWatch then
                    if tContains(GS.SpellIDWatchTable, name) then SlashCmdList["DUMP"]("GS.DebugTable") end
                end
                if GSR.Dev.Logging then
                    GS.File = ReadFile("C:\\Garrison.json")
                    GS.tempStr = json.encode(GS.DebugTable, {indent=true})
                    WriteFile("C:\\Garrison.json", GS.File..",\n"..GS.tempStr)
                end
            end
            GS.WaitForCombatLog = true
            -- GS.SpellThrottle = GetTime()+.234 -- Waits 14.04 frames
            GS.InterruptNextTick = nil
            toggleLog = true
            return true
        end

        function GS.Interrupt()
        end

    -- Class Functions
        -- Paladin
            function GS.TTHPG()
                local gcd = GS.SpellCDDuration(61304)
                local cs = GS.SpellCDDuration(35395)
                local judg = GS.SpellCDDuration(20271)
                local wrath = GS.SpellCDDuration(119072)
                local shield = GS.SpellCDDuration(31935)

                local generator = cs
                for i = 1, 4 do
                    if i == 1 then
                        if cs > judg then generator = judg end
                    elseif i == 2 then
                        if GS.Talent52 and generator > wrath then generator = wrath end
                    elseif i == 3 then
                        if GS.Aura("player", 85416) and generator > shield then generator = shield end
                    elseif i == 4 then
                        if gcd > generator then generator = gcd end
                    end
                    if generator == 0 then break end
                end
                return generator
            end
        
        -- Hunter
            function GS.CheckSerpentSting()
                table.sort(GS.MobTargets, GS.SortMobTargetsByLowestDistance)
                local unitPlaceholder = nil
                local counter = 0
                for i = 1, mobTargetsSize do
                    unitPlaceholder = GS.MobTargets[i]
                    if UnitExists(unitPlaceholder) then
                        if GS.Distance(unitPlaceholder)-UnitCombatReach(unitPlaceholder) <= 8 then
                            if GS.AuraRemaining(unitPlaceholder, 118253, GS.GCD(), "", "PLAYER") then counter = counter + 1 end
                        else
                            break
                        end
                    end
                end

                if counter >= 3 then return true else return false end
            end

        -- Rogue
            do
                local rollTheBonesTable = {
                    193356, -- Broadsides            193356
                    193357, -- Shark Infested Waters 193357
                    193358, -- Grand Melee           193358
                    193359, -- True Bearing          193359
                    199600, -- Buried Treasure       199600
                    199603, -- Jolly Roger           199603
                }
                function GS.RollTheBones(mode)
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
            end

        -- Priest
            function GS.VoidformInsanity(mode)
                if mode == "drain" then
                    return 9+(GS.Priest.Voidform.DrainStacks-1)/2
                elseif mode == "count" then
                    return GS.Priest.Voidform.DrainStacks
                end
            end

        -- Monk
            local jadeSerpentStatue = nil
            function GS.FindJadeSerpentStatue()
                if not GetTotemInfo(1) then return false end
                local unitPlaceholder = nil
                for i = 1, ObjectCount() do
                    unitPlaceholder = ObjectWithIndex(i)
                    if UnitName(unitPlaceholder) == "Jade Serpent Statue" and UnitCreator(unitPlaceholder) == ObjectPointer("player") then return unitPlaceholder end
                end
                return false
            end

            function GS.CheckJadeSerpentStatuePosition(statue, range)
                if not statue then return false end
                local unitPlaceholder = nil
                local counter = 0
                counter = 0
                for i = 1, allyTargetsSize do
                    unitPlaceholder = GS.AllyTargets[i].Player
                    if GS.Distance(unitPlaceholder, statue) <= range then counter = counter + 1 end
                end
                return counter >= #GS.SmartAoEFriendly(40, range, true)
            end


        -- Druid
            function GS.RakeCurrentMultiplier()
                local multiplier = 1
                if GS.Aura("player", 5217) then multiplier = multiplier * 1.15 end
                if GS.Aura("player", 52610) then multiplier = multiplier * 1.25 end
                if GS.Aura("player", 145152) then multiplier = multiplier * 1.5 end
                if GS.Aura("player", 5215) or GS.Aura("player", 102543) --[[shadowmeld]] then multiplier = multiplier * 2 end
                return multiplier
            end

        -- Death Knight
            function GS.NumberOfAvailableRunes()
                local counter = 0
                for i = 1, 6 do
                    if GetRuneCount(i) == 1 then counter = counter + 1 end
                end
                return counter
            end

-- Start Your Engines
    -- GS.MainFrameCreation()
    do
        if not GS.MainFrame then
            GSR = GetCharacterCustomVariable("GSR") or {Dev = {hide = true}, }

            if not GSMainFrame then
                GS.MainFrame = CreateFrame("Frame", "GSMainFrame", nil)
                GSMainFrame:RegisterEvent("PLAYER_LOGIN")
                GSMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
                GSMainFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
                GSMainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
                GSMainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
            end
            GSMainFrame:SetScript("OnEvent", GS.MainFrameEvents)

            GS.MonitorFrameCreation(); GS.MonitorAnimationToggle("off")
            GS.CombatFrameCreation()
            GS.CombatInformationFrameCreation()
            if not GSHealingTooltipFrame then GS.HealingTooltipFrameCreation() end

            GS.SaveToGSR("Class", (GSR.Class or select(2, UnitClass("player"))))
            GS.SaveToGSR("Race",  (GSR.Race  or select(2, UnitRace ("player"))))
            GS.Spec   = GS.Spec   or GetSpecialization()
        end
    end

-- WARRIOR ARMS
-- PALADIN RETRIBUTION
-- HUNTER BEAST MASTERY
-- ROGUE ASSASSINATION
-- PRIEST DISCIPLINE
-- SHAMAN ELEMENTAL
-- MAGE FROST
-- WARLOCK AFFLICTION
-- MONK WINDWALKER
-- DRUID FERAL
-- DEMON HUNTER
-- DEATH KNIGHT UNHOLY

-- Rotations
    do
        local berserking = 26297 -- todo: verify
        
        -- Warriors
            do
                local arcane_torrent =  69179 -- todo: verify
                local avatar         = 107574
                local battle_cry     =   1719
                local berserker_rage =  18499
                local blood_fury     =  20572
                local heroic_charge  =    nil
                local rage           =  GS.PP
                local shockwave      =  46968
                local stone_heart    = 225947 -- todo: verify
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
                    -- local precise_strikes    = 209493 -- todo: verify
                    local ravager            = 152277
                    local rend               =    772
                    local shattered_defenses = 209706 -- todo: verify
                    local slam               =   1464
                    local warbreaker         = 209577 -- todo: verify
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
                        GSHealingTooltipFrame:SetSpellByID(12294)
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
                                -- actions+=/potion,name=draenic_strength,if=(target.health.pct<20&buff.battle_cry.up)|target.time_to_die<25
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
                                if GS.Talent12 and GS.SCA(7384) then GS.Cast(_, 7384, _, _, _, _, "Overpower") return end
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
                    local dragon_roar   = 118000 -- todo: verify buff is same
                    local enrage        = 184362
                    local execute       =   5308
                    local furious_slash = 100130
                    local juggernaut    =        {buff = 201009} -- todo: verify
                    local massacre      = 206316 -- todo: verify
                    local meat_cleaver  =  85739
                    local odyns_fury    = 205545 -- todo: verify
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
                                    -- actions+=/potion,name=draenic_strength,if=(target.health.pct<20&buff.battle_cry.up)|target.time_to_die<=30
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
                                if GS.Talent32 and GS.Talent73 and GS.SIR(berserker_rage) and GS.SpellCDDuration(dragon_roar) == 0 and not GS.Aura("player", enrage) then GS.Cast(_, berserker_rage, _, _, _, _, "Berserker Rage: Not Enraged, Dragon Roar Cooled Off") return end
                                if GS.SCA(rampage) and (rage() > 95 or GS.Aura("player", massacre)) then GS.Cast(_, rampage, _, _, _, _, "Rampage: Dump|Free") return end
                                if not GS.Talent63 and GS.SIR(whirlwind) and GS.Distance("target") < 8+UnitCombatReach("target") and GS.Aura("player", wrecking_ball) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: Wrecking Ball, Inner Rage Not Talented") return end
                                if GS.SCA(raging_blow) and GS.Aura("player", enrage) then GS.Cast(_, raging_blow, _, _, _, _, "Raging Blow: Enraged") return end
                                if GS.SIR(whirlwind) and GS.Distance("target") < 8+UnitCombatReach("target") and GS.Aura("player", wrecking_ball) and GS.Aura("player", enrage) then GS.Cast(_, whirlwind, _, _, _, _, "Whirlwind: Wrecking Ball Enraged") return end
                                if GS.SCA(execute) and (GS.Aura("player", enrage) or GS.Aura("player", battle_cry) or GS.Aura("player", stone_heart)) then GS.Cast(_, execute, _, _, _, _, "Execute: Enraged|Battle Cry|Stone Heart") return end
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
                                -- actions.prot+=/potion,name=draenic_strength,if=(incoming_damage_2500ms>health.max*0.15&!buff.potion.up)|target.time_to_die<=25

                                if GS.AoE and GS.PlayerCount(8, false, 3, ">=") then
                                    -- actions.prot_aoe=battle_cry
                                    -- actions.prot_aoe+=/demoralizing_shout,if=talent.booming_voice.enabled&rage<=50
                                    -- actions.prot_aoe+=/ravager,if=talent.ravager.enabled
                                    if GS.SCA(shield_slam) then GS.Cast(_, shield_slam, _, _, _, _, "Shield Slam: AoE") return end
                                    if GS.SCA(revenge) then GS.Cast(_, revenge, _, _, _, _, "Revenge: AoE") return end
                                    if GS.SIR(thunder_clap) then GS.Cast(_, thunder_clap, _, _, _, _, "Thunder Clap") return end
                                    if GS.SCA(devastate) then GS.Cast(_, devastate, _, _, _, _, "Devastate: AoE") return end
                                    return
                                end
                                -- actions.prot+=/battle_cry
                                -- actions.prot+=/demoralizing_shout,if=talent.booming_voice.enabled&rage<=50
                                -- actions.prot+=/ravager,if=talent.ravager.enabled
                                if GS.SCA(shield_slam) then GS.Cast(_, shield_slam, _, _, _, _, "Shield Slam") return end
                                if GS.SCA(revenge) then GS.Cast(_, revenge, _, _, _, _, "Revenge") return end
                                if GS.SCA(devastate) then GS.Cast(_, devastate, _, _, _, _, "Devastate") return end

                            end
                        end
                    end
                end
            end

        -- Paladins
            do
                local crusader_strike = 35395
                local judgment = 20271
                -- todo: verify Holy Paladin
                -- todo: verify Protection Paladin

                do -- Protection
                    function GS.PALADIN2()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                if GS.SCA(20271, "target", interruptCasting) and GS.ChargeCD(53600) > 0 then GS.Cast("target", 20271, false, false, false, "SpellToInterrupt") return end
                                if GS.SIR(26573) then GS.Cast("target", 26573, false, false, false, "SpellToInterrupt") return end
                                if GS.SCA(31935, "target", interruptCasting) then GS.Cast("target", 31935, false, false, false, "SpellToInterrupt") return end
                                if GS.Talent12 then
                                    if GS.SCA(204019, "target", interruptCasting) then GS.Cast("target", 204019, false, false, false, "SpellToInterrupt") return end
                                else
                                    if GS.SCA(53595, "target", interruptCasting) then GS.Cast("target", 53595, false, false, false, "SpellToInterrupt") return end
                                end
                            end
                        end
                    end
                end

                do -- Retribution
                    -- talents=1112112
                    -- artifact=2:136717:137316:136717:0:40:1:41:3:42:3:50:3:51:3:53:6:350:1:353:1:1275:1
                    local avenging_wrath           =  31884
                    local blade_of_justice         = 184575
                    local blade_of_wrath           = 202270
                    local consecration             = 205228
                    local crusade                  = 224668
                    local divine_hammer            = 198034
                    local divine_purpose           = 223819 -- todo: verify
                    local divine_storm             =  53385
                    local execution_sentence       = 213757
                    local holy_wrath               = 210220
                    local justicars_vengeance      = 215661
                    local rebuke                   =  96231
                    local templars_verdict         =  85256
                    local whisper_of_the_nathrezim =        {item = 137020, buff = nil} -- todo: verify
                    local zeal                     = 217020
                    
                    function GS.PALADIN3()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                StartAttack("target")
                                -- actions+=/rebuke
                                if GS.CDs then
                                    -- actions+=/potion,name=the_old_war
                                    -- actions+=/holy_wrath
                                    if not GS.Talent72 then
                                        if GS.SIR(avenging_wrath) then GS.Cast(_, avenging_wrath, _, _, _, _, "Avenging Wrath") return end
                                    else
                                        if GS.SIR(crusade) and GS.PP() >= 5 then GS.Cast(_, crusade, _, _, _, _, "Crusade") return end
                                    end
                                    -- actions+=/wake_of_ashes,if=holy_power>=0&time<2
                                    -- actions+=/arcane_torrent
                                end
                                if GS.Talent41 then -- Virtue's Blade
                                    if GS.Aura("target", 197277, "", "PLAYER") then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                            if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose + 5 HP") return end
                                            if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                                        end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not GS.IsEquipped(whisper_of_the_nathrezim) then
                                            if GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose + 5 HP") return end
                                        end
                                        if GS.SCA(templars_verdict) then
                                            if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose + 5 HP") return end
                                            if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                                        end
                                    end
                                    -- actions.VB+=/divine_storm,if=holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                                    -- actions.VB+=/justicars_vengeance,if=holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
                                    -- actions.VB+=/templars_verdict,if=holy_power>=3&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                                    -- actions.VB+=/wake_of_ashes,if=holy_power<=1|(holy_power<=2&cooldown.blade_of_justice.remains>gcd&(cooldown.zeal.charges_fractional<=0.67|cooldown.crusader_strike.charges_fractional<=0.67))
                                    if GS.Talent22 then
                                        if GS.SCA(zeal) and GetSpellCharges(zeal) == 2 and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal: Capped Charges") return end
                                    else
                                        if GS.SCA(35395) and GetSpellCharges(35395) == 2 and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike: Capped Charges") return end
                                    end
                                    if GS.SCA(blade_of_justice) and (GS.PP() <= 2 or GS.PP() <= 3 and GS.FracCalc("spell", GS.Talent22 and zeal or 35395) <= 1.34) then GS.Cast(_, blade_of_justice, _, _, _, _, "Blade of Justice") return end
                                    if GS.SCA(20271) and (GS.PP() >= 3 or GS.FracCalc("spell", GS.Talent22 and zeal or 35395) <= 1.67 and GS.SpellCDDuration(blade_of_justice) > GS.GCD() or GS.Talent23 and GS.Health("target", _, true) > 50) then GS.Cast(_, 20271, _, _, _, _, "Judgment: HP|Crusader Strike Capped Charges|Talented 50%+") return end
                                    if GS.Talent13 and GS.SIR(consecration) and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, consecration, _, _, _, _, "Consecration") return end
                                    if GS.Aura("target", 197277, "", "PLAYER") then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                            if GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose") return end
                                            if GS.Aura("player", 209785) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump Fires of Justice") return end
                                            if GS.PP() >= 4 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                                        end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and not GS.IsEquipped(whisper_of_the_nathrezim) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance") return end
                                        if GS.SCA(templars_verdict) then
                                            if GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose") return end
                                            if GS.Aura("player", 209785) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Fires of Justice") return end
                                            if GS.PP() >= 4 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                                        end
                                    end
                                    if GS.Talent22 then
                                        if GS.SCA(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal") return end
                                    else
                                        if GS.SCA(35395) and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike") return end
                                    end
                                    if GS.AoE and GS.PP() >= 3 and GS.SIR(divine_storm) and GS.Aura("target", 197277, "", "PLAYER") and GS.PlayerCount(8, _, 2, ">=") and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm") return end
                                    if GS.PP() >= 3 and GS.SCA(templars_verdict) and GS.Aura("target", 197277, "", "PLAYER") and GS.PP() >= 3 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict") return end
                                elseif GS.Talent42 then -- Blade of Wrath
                                    if GS.Aura("target", 197277, "", "PLAYER") then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                            if GS.Talent21 and GS.AuraRemaining("target", 197277, GS.GCD(), "", "PLAYER") then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Judgment Last GCD") return end
                                            if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose + 5 HP") return end
                                            if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                                        end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not GS.IsEquipped(whisper_of_the_nathrezim) then
                                            if GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose + 5 HP") return end
                                        end
                                        if GS.SCA(templars_verdict) then
                                            if GS.Talent21 and GS.AuraRemaining("target", 197277, GS.GCD(), "", "PLAYER") then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Judgment Last GCD") return end
                                            if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose + 5 HP") return end
                                            if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                                        end
                                    end
                                    -- actions.BoW+=/divine_storm,if=holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                                    -- actions.BoW+=/justicars_vengeance,if=holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
                                    -- if GS.SCA(templars_verdict) and GS.PP() >= 3 and (GS.SpellCDDuration(wake_of_ashes) < GS.GCD()*2 and artifact.wake_of_ashes.enabled or GS.Aura("player", 207635) and GS.AuraRemaining("player", 207635, GS.GCD())) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Wake of Ashes Dump HP|Whisper of the Nathrezim About to Expire") return end
                                    -- actions.BoW+=/wake_of_ashes,if=holy_power<=1|(holy_power<=2&cooldown.blade_of_wrath.remains>gcd&(cooldown.zeal.charges_fractional<=0.67|cooldown.crusader_strike.charges_fractional<=0.67))
                                    if GS.Talent21 and GS.Aura("target", 197277, "", "PLAYER") and GS.Aura("player", divine_purpose) then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, _, 2, ">=") then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump Divine Purpose") return end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and not GS.IsEquipped(whisper_of_the_nathrezim) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Dump Divine Purpose") return end
                                        if GS.SCA(templars_verdict) and GS.Aura("target", 197277, "", "PLAYER") then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Divine Purpose") return end
                                    end
                                    if GS.Talent22 then
                                        if GS.SCA(zeal) and GetSpellCharges(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal: Capped Charges") return end
                                    else
                                        if GS.SCA(35395) and GetSpellCharges(35395) == 2 and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike: Capped Charges") return end
                                    end
                                    if GS.SCA(blade_of_wrath) and (GS.PP() <= 2 or GS.PP() <= 3 and GS.FracCalc("spell", GS.Talent22 and zeal or 35395) <= 1.34) then GS.Cast(_, blade_of_wrath, _, _, _, _, "Blade of Wrath") return end
                                    if GS.Talent21 and GS.SCA(35395) and GetSpellCharges(35395) == 2 and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike: Capped Charges") return end
                                    if GS.SCA(20271) then GS.Cast(_, 20271, _, _, _, _, "Judgment") return end
                                    if GS.Talent13 and GS.SIR(consecration) and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, consecration, _, _, _, _, "Consecration") return end
                                    if GS.Aura("target", 197277, "", "PLAYER") then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                            if GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose") return end
                                            if GS.Aura("player", 209785) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump Fires of Justice") return end
                                            if (GS.PP() >= 4 or GS.Talent71) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP|Fish for Divine Purpose") return end
                                        end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and not GS.IsEquipped(whisper_of_the_nathrezim) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance") return end
                                        if GS.SCA(templars_verdict) then
                                            if GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose") return end
                                            if GS.Aura("player", 209785) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Fires of Justice") return end
                                            if (GS.PP() >= 4 or GS.Talent71) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*4) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP|Fish for Divine Purpose") return end
                                        end
                                    end
                                    if GS.Talent22 then
                                        if GS.SCA(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal") return end
                                    else
                                        if GS.SCA(35395) and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike") return end
                                    end

                                    if GS.AoE and GS.PP() >= 3 and GS.SIR(divine_storm) and GS.Aura("target", 197277, "", "PLAYER") and GS.PlayerCount(8, _, 2, ">=") and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm") return end
                                    if GS.PP() >= 3 and GS.SCA(templars_verdict) and GS.Aura("target", 197277, "", "PLAYER") and GS.PP() >= 3 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict") return end
                                elseif GS.Talent43 then -- Divine Hammer
                                    if GS.Aura("target", 197277, "", "PLAYER") then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                            if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose + 5 HP") return end
                                            if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump HP") return end
                                        end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not GS.IsEquipped(whisper_of_the_nathrezim) then
                                            if GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose + 5 HP") return end
                                        end
                                        if GS.SCA(templars_verdict) then
                                            if GS.Aura("player", divine_purpose) and GS.AuraRemaining("player", divine_purpose, GS.GCD()*2) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose About to Expire") return end
                                            if GS.PP() >= 5 and GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose + 5 HP") return end
                                            if GS.PP() >= 5 and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*3) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump HP") return end
                                        end
                                    end
                                    -- actions.DH+=/divine_storm,if=holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                                    -- actions.DH+=/justicars_vengeance,if=holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
                                    -- actions.DH+=/templars_verdict,if=holy_power>=3&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
                                    -- actions.DH+=/wake_of_ashes,if=holy_power<=1|(holy_power<=2&cooldown.divine_hammer.remains>gcd&(cooldown.zeal.charges_fractional<=0.67|cooldown.crusader_strike.charges_fractional<=0.67))
                                    if GS.Talent22 then
                                        if GS.SCA(zeal) and GetSpellCharges(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal: Capped Charges") return end
                                    else
                                        if GS.SCA(35395) and GetSpellCharges(35395) == 2 and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike: Capped Charges") return end
                                    end
                                    if GS.SIR(divine_hammer) and GS.PP() <= 3 then GS.Cast(_, divine_hammer, _, _, _, _, "Divine Hammer") return end
                                    if GS.Talent21 and GS.SCA(35395) and GetSpellCharges(35395) == 2 and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike: Capped Charges") return end
                                    if GS.SCA(20271) then GS.Cast(_, 20271, _, _, _, _, "Judgment") return end
                                    if GS.Talent13 and GS.SIR(consecration) and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, consecration, _, _, _, _, "Consecration") return end
                                    if GS.Aura("target", 197277, "", "PLAYER") then
                                        if GS.AoE and GS.SIR(divine_storm) and GS.PlayerCount(8, false, 2, ">=") then
                                            if GS.Aura("player", divine_purpose) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Divine Purpose") return end
                                            if GS.Aura("player", 209785) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm: Dump Fires of Justice") return end
                                            if (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*6) then GS.Cast(_, divine_storm, _, _, _, _, "Divine Storm") return end
                                        end
                                        if GS.Talent51 and GS.SCA(justicars_vengeance) and GS.Aura("player", divine_purpose) and not GS.IsEquipped(whisper_of_the_nathrezim) then GS.Cast(_, justicars_vengeance, _, _, _, _, "Justicar's Vengeance: Divine Purpose") return end
                                        if GS.SCA(templars_verdict) then
                                            if GS.Aura("player", divine_purpose) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Divine Purpose") return end
                                            if GS.Aura("player", 209785) and (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*5) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict: Dump Fires of Justice") return end
                                            if (not GS.Talent72 or GS.SpellCDDuration(crusade) > GS.GCD()*6) then GS.Cast(_, templars_verdict, _, _, _, _, "Templar's Verdict") return end
                                        end
                                    end
                                    if GS.Talent22 then
                                        if GS.SCA(zeal) and GS.PP() <= 4 then GS.Cast(_, zeal, _, _, _, _, "Zeal") return end
                                    else
                                        if GS.SCA(35395) and GS.PP() <= 4 then GS.Cast(_, 35395, _, _, _, _, "Crusader Strike") return end
                                    end
                                end
                            end
                        end
                    end
                end
            end

        -- Hunters
            do
                local focus = GS.PP
                local arcane_torrent = 80483 -- todo: verify
                local blood_fury = 20572
                local a_murder_of_crows = 131894
                local barrage = 120360
                local multishot = 2643

                do -- Beast Mastery
                    -- talents=1102012
                    -- artifact=56:0:0:0:0:869:3:872:3:874:3:875:3:878:1:881:1:882:1:1095:3:1336:1
                    local aspect_of_the_wild = 193530
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
                                    -- actions+=/use_item,name=moonlit_prism
                                    if GS.SIR(arcane_torrent) and focus("deficit") >= 30 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Hunter") return end
                                    if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                end
                                if GS.Talent61 and GS.SCA(a_murder_of_crows) then GS.Cast(_, a_murder_of_crows, _, _, _, _, "A Murder of Crows") return end
                                if GS.CDs and GS.Talent71 and GS.SIR(stampede) and (GS.Bloodlust() or GS.UnitIsBoss("target") and GS.GetTTD() <= 15) then GS.Cast("target", stampede, _, _, _, _, "Stampede") return end
                                if GS.SpellCDDuration(bestial_wrath) > 2 then
                                    if not GS.Talent22 then
                                        if GS.SCA(dire_beast) then GS.Cast(_, dire_beast, _, _, _, _, "Dire Beast") return end
                                    else
                                        if GS.SCA(dire_frenzy) then GS.Cast(_, dire_frenzy, _, _, _, _, "Dire Frenzy") return end
                                    end
                                end
                                if GS.CDs and GS.SIR(aspect_of_the_wild) and GS.Aura("player", bestial_wrath) then GS.Cast(_, aspect_of_the_wild, _, _, _, _, "Aspect of the Wild") return end
                                if GS.Talent62 and GS.SIR(barrage) and (GS.AoE and GS.TargetCount(8) > 1 or GS.TargetCount(8) == 1 and focus() > 90) then GS.Cast(_, barrage, _, _, _, _, "Barrage") return end
                                -- actions+=/titans_thunder,if=cooldown.dire_beast.remains>=3|talent.dire_frenzy.enabled
                                if GS.SIR(bestial_wrath) then GS.Cast(_, bestial_wrath, _, _, _, _, "Bestial Wrath") return end
                                if GS.AoE and GS.SCA(multishot) and GS.TargetCount(8) >= 3 and not GS.Aura("pet", 118455) then GS.Cast(_, multishot, _, _, _, _, "Multi-Shot: Beast Cleave") return end
                                if GS.SIR(kill_command) then
                                    if GSR.KillCommandPet then
                                        if UnitExists("pettarget") and GS.Distance("pet", "pettarget") < 25 then GS.Cast("pettarget", kill_command, _, _, _, _, "Kill Command: Pet") return end
                                    else
                                        if GS.Distance("target", "pet") < 25 then GS.Cast(_, kill_command, _, _, _, _, "Kill Command") return end
                                    end
                                end
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
                    local bullseye = 204090 -- todo: verify
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
                                    -- actions+=/use_item,name=moonlit_prism
                                    if GS.SIR(arcane_torrent) and focus("deficit") >= 30 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Hunter") return end
                                    if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    if GS.SIR(trueshot) and (GS.GetTTD() < math.huge and GS.GetTTD() > 195 or GS.UnitIsBoss() and GS.Health("target", _, true) < 5 or GS.AuraStacks("player", bullseye, 16)) then GS.Cast(_, trueshot, _, _, _, _, "Trueshot") return end
                                end
                                if GS.SCA(marked_shot) and not GS.Talent71 and GS.DebugTable["ogSpell"] == 206817 and GS.Aura("target", hunters_mark, "", "PLAYER") then GS.Cast(_, marked_shot, _, _, _, _, "Marked Shot: Sentinel") return end
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
                                    -- actions+=/use_item,name=moonlit_prism
                                end
                                if GS.SIR(explosive_trap) then GS.Cast(_, explosive_trap, _, _, _, _, "Explosive Trap") return end
                                if GS.Talent62 and GS.SCA(dragonsfire_grenade) then GS.Cast(_, dragonsfire_grenade, _, _, _, _, "Dragonsfire Grenade") return end
                                if GS.Talent63 and GS.AoE then
                                    if GS.PlayerCount(8) >= 3 then
                                        if GS.SIR(carve) and GS.CheckSerpentSting() then GS.Cast(_, carve, _, _, _, _, "Carve: Serpent Sting") return end
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
                                -- actions+=/fury_of_the_eagle,if=buff.mongoose_fury.up&buff.mongoose_fury.remains<=gcd.max*2
                                if GS.SCA(mongoose_bite) and (GS.Aura("player", mongoose_fury) --[[or cooldown.fury_of_the_eagle.remains<5]] or GetSpellCharges(mongoose_bite) == 3) then GS.Cast(_, mongoose_bite, _, _, _, _, "Mongoose Bite") return end
                                -- actions+=/steel_trap
                                if GS.Talent21 and GS.SCA(a_murder_of_crows) then GS.Cast(_, a_murder_of_crows, _, _, _, _, "A Murder of Crows") return end
                                if GS.SCA(lacerate) and (GS.Aura("target", lacerate, "", "PLAYER") and GS.AuraRemaining("target", lacerate, 3, "", "PLAYER") or --[[GS.UnitIsBoss("target")]]GS.GetTTD() < math.huge and GS.GetTTD() >= 5) then GS.Cast(_, lacerate, _, _, _, _, "Lacerate") return end
                                if GS.Talent23 and GS.SIR(snake_hunter) and GetSpellCharges(mongoose_bite) == 0--[[<= 1]] and not GS.AuraRemaining("player", mongoose_fury, GS.GCD()*4) then GS.Cast(_, snake_hunter, _, _, _, _, "Snake Hunter") return end
                                if GS.SCA(flanking_strike) and focus() >= 55 and (GS.Talent13 and not GS.AuraRemaining("player", moknathal_tactics, 3) or not GS.Talent13) then GS.Cast(_, flanking_strike, _, _, _, _, "Flanking Strike") return end
                                if GS.AoE then
                                    if GS.Talent61 then
                                        if GS.SIR(butchery) and GS.PlayerCount(8) >= 2 then GS.Cast(_, butchery, _, _, _, _, "Butchery") return end
                                    else
                                        if GS.SIR(carve) and GS.PlayerCount(8) >= 4 then GS.Cast(_, carve, _, _, _, _, "Carve") return end
                                    end
                                end
                                -- actions+=/spitting_cobra
                                if GS.Talent12 and GS.SCA(throwing_axes) then GS.Cast(_, throwing_axes, _, _, _, _, "Throwing Axes") return end
                                if GS.SCA(raptor_strike) and focus() > 75 - GS.SpellCDDuration(flanking_strike) * GetPowerRegen() then GS.Cast(_, raptor_strike, _, _, _, _, "Raptor Strike") return end
                            end
                        end
                    end
                end
            end

        -- Rogues
            do
                local blood_fury = 20572
                local arcane_torrent = 25046
                local vanish = {spell = 1856}
                local stealth = {spell = 1784}
                local marked_for_death = 137619
                local death_from_above = 152150

                do -- Assassination
                    function GS.ROGUE1()
                        -- talents=3110131
                        -- artifact=43:0:0:0:0:323:3:325:3:328:3:330:3:331:2:332:1:337:1:346:1:347:1:1276:1

                        -- # This default action priority list is automatically created based on your character.
                        -- # It is a attempt to provide you with a action list that is both simple and practicable,
                        -- # while resulting in a meaningful and good simulation. It may not result in the absolutely highest possible dps.
                        -- # Feel free to edit, adapt and improve it to your own needs.
                        -- # SimulationCraft is always looking for updates and improvements to the default action lists.

                        -- # Executed before combat begins. Accepts non-harmful actions only.

                        -- actions.precombat=flask,type=flask_of_the_seventh_demon
                        -- actions.precombat+=/augmentation,type=defiled
                        -- actions.precombat+=/food,type=seedbattered_fish_plate
                        -- # Snapshot raid buffed stats before combat begins and pre-potting is done.
                        -- actions.precombat+=/snapshot_stats
                        -- actions.precombat+=/apply_poison
                        -- actions.precombat+=/stealth
                        -- actions.precombat+=/potion,name=draenic_agility
                        -- actions.precombat+=/marked_for_death

                        -- # Executed every time the actor is available.

                        -- actions=potion,name=draenic_agility,if=buff.bloodlust.react|target.time_to_die<=25|debuff.vendetta.up
                        -- actions+=/blood_fury,if=debuff.vendetta.up
                        -- actions+=/berserking,if=debuff.vendetta.up
                        -- actions+=/arcane_torrent,if=debuff.vendetta.up&energy.deficit>50&!dot.rupture.exsanguinated&(cooldown.exsanguinate.remains>3|!artifact.urge_to_kill.enabled)
                        -- actions+=/call_action_list,name=cds
                        -- actions+=/rupture,if=combo_points>=2&!ticking&time<10&!artifact.urge_to_kill.enabled
                        -- actions+=/rupture,if=combo_points>=4&!ticking
                        -- actions+=/kingsbane,if=buff.vendetta.up|cooldown.vendetta.remains>30
                        -- actions+=/run_action_list,name=exsang_combo,if=cooldown.exsanguinate.remains<3&talent.exsanguinate.enabled
                        -- actions+=/call_action_list,name=garrote,if=spell_targets.fan_of_knives<=7
                        -- actions+=/call_action_list,name=exsang,if=dot.rupture.exsanguinated&spell_targets.fan_of_knives<=2
                        -- actions+=/call_action_list,name=finish
                        -- actions+=/call_action_list,name=build

                        -- #  Cooldowns
                        -- actions.cds=marked_for_death,cycle_targets=1,target_if=min:target.time_to_die,if=combo_points.deficit>=5
                        -- actions.cds+=/vendetta,if=target.time_to_die<20|artifact.urge_to_kill.enabled&dot.rupture.ticking&cooldown.exsanguinate.remains<8&(energy<55|time<10|spell_targets.fan_of_knives>=2)
                        -- actions.cds+=/vendetta,if=target.time_to_die<20|!artifact.urge_to_kill.enabled&dot.rupture.ticking&cooldown.exsanguinate.remains<1
                        -- actions.cds+=/vanish,if=talent.subterfuge.enabled&combo_points<=2&!dot.rupture.exsanguinated
                        -- actions.cds+=/vanish,if=talent.shadow_focus.enabled&!dot.rupture.exsanguinated&combo_points.deficit>=2

                        -- #  Exsanguinate Combo
                        -- actions.exsang_combo=vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1&gcd.remains=0&energy>=25
                        -- actions.exsang_combo+=/rupture,if=combo_points>=cp_max_spend&(buff.vanish.up|cooldown.vanish.remains>15)&cooldown.exsanguinate.remains<1
                        -- actions.exsang_combo+=/exsanguinate,if=prev_gcd.rupture&dot.rupture.remains>25+4*talent.deeper_stratagem.enabled&cooldown.vanish.remains>10
                        -- actions.exsang_combo+=/call_action_list,name=garrote,if=spell_targets.fan_of_knives<=7
                        -- actions.exsang_combo+=/hemorrhage,if=spell_targets.fan_of_knives>=2&!ticking
                        -- actions.exsang_combo+=/fan_of_knives,if=spell_targets>=2
                        -- actions.exsang_combo+=/hemorrhage,if=combo_points.deficit=1|combo_points.deficit<=1&remains<10
                        -- actions.exsang_combo+=/mutilate,if=combo_points.deficit<=1
                        -- actions.exsang_combo+=/call_action_list,name=build

                        -- #  Garrote
                        -- actions.garrote=pool_resource,for_next=1
                        -- actions.garrote+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&!ticking&combo_points.deficit>=1&spell_targets.fan_of_knives>=2
                        -- actions.garrote+=/pool_resource,for_next=1
                        -- actions.garrote+=/garrote,if=combo_points.deficit>=1&!exsanguinated

                        -- #  Exsanguinated Rotation
                        -- actions.exsang=rupture,if=combo_points>=cp_max_spend&ticks_remain<2
                        -- actions.exsang+=/death_from_above,if=combo_points>=cp_max_spend-1&dot.rupture.remains>3
                        -- actions.exsang+=/envenom,if=combo_points>=cp_max_spend-1&dot.rupture.remains>3
                        -- actions.exsang+=/hemorrhage,if=combo_points.deficit>=1&debuff.hemorrhage.remains<1
                        -- actions.exsang+=/hemorrhage,if=combo_points.deficit<=1
                        -- actions.exsang+=/pool_resource,for_next=1
                        -- actions.exsang+=/mutilate,if=combo_points.deficit>=2

                        -- #  Finishers
                        -- actions.finish=rupture,cycle_targets=1,if=!ticking&combo_points>=cp_max_spend&spell_targets.fan_of_knives>1&target.time_to_die-remains>6
                        -- actions.finish+=/rupture,if=combo_points>=cp_max_spend&refreshable&!exsanguinated
                        -- actions.finish+=/death_from_above,if=combo_points>=cp_max_spend-1&spell_targets.fan_of_knives<=6
                        -- actions.finish+=/envenom,if=combo_points>=cp_max_spend-1&!dot.rupture.refreshable&buff.elaborate_planning.remains<2&energy.deficit<40&spell_targets.fan_of_knives<=6
                        -- actions.finish+=/envenom,if=combo_points>=cp_max_spend&!dot.rupture.refreshable&buff.elaborate_planning.remains<2&cooldown.garrote.remains<1&spell_targets.fan_of_knives<=6

                        -- actions.build=hemorrhage,cycle_targets=1,if=combo_points.deficit>=1&refreshable&dot.rupture.remains>6&spell_targets.fan_of_knives>1&spell_targets.fan_of_knives<=4
                        -- actions.build+=/fan_of_knives,if=spell_targets>1&(combo_points.deficit>=1|spell_targets>=7)
                        -- actions.build+=/hemorrhage,if=(combo_points.deficit>=1&refreshable)|(combo_points.deficit=1&dot.rupture.refreshable)
                        -- actions.build+=/mutilate,if=combo_points.deficit>=2&cooldown.garrote.remains>2
                    end
                end

                -- todo: verify Assassination Rogue

                do -- Outlaw
                    -- talents=2010022
                    -- artifact=44:0:0:0:0:1052:1:1054:1:1057:1:1060:3:1061:3:1064:3:1065:3:1066:3:1348:1
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
                    
                    function GS.ROGUE2()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                -- actions=potion,name=draenic_agility,if=buff.bloodlust.react|target.time_to_die<=25|buff.adrenaline_rush.up
                                -- actions+=/blade_flurry,if=(spell_targets.blade_flurry>=2&!buff.blade_flurry.up)|(spell_targets.blade_flurry<2&buff.blade_flurry.up)
                                if GS.CDs then
                                    if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    if GS.SIR(arcane_torrent) and GS.PP("deficit") > 40 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Rogue") return end
                                    if GS.SIR(adrenaline_rush) and not GS.Aura("player", adrenaline_rush) then GS.Cast("player", adrenaline_rush, _, _, _, _, "Adrenaline Rush") return end
                                end
                                if GS.PoolCheck(ambush) then return end
                                if GS.SCA(ambush) then GS.Cast(_, ambush, _, _, _, _, "Ambush") return end
                                if GS.CDs then
                                    if GetNumGroupMembers() > 1 and GS.SpellCDDuration(61304) == 0 and not IsStealthed() then
                                        if GS.SIR(1856) and GS.CP("deficit") >= 2 then
                                            if GS.PP() < 60 then
                                                return
                                            else
                                                GS.Cast(_, 1856, _, _, _, _, "Vanish")
                                                return
                                            end
                                        end
                                        if GS.SIR(58984) and GS.CP("deficit") >= 2 then
                                            if GS.PP() < 60 then
                                                return
                                            else
                                                GS.Cast(_, 58984, _, _, _, _, "Shadowmeld")
                                                return
                                            end
                                        end
                                    end
                                end
                                if GS.Talent71 then
                                    if GS.SIR(slice_and_dice) and GS.CP() >= 5 and GS.AuraRemaining("player", slice_and_dice, GS.GetTTD()) and GS.AuraRemaining("player", slice_and_dice, 6) then GS.Cast("player", slice_and_dice, _, _, _, _, "Slice and Dice") return end
                                else
                                    if GS.SIR(roll_the_bones) and GS.CP() >= 5 and GS.RollTheBones("duration") < GS.GetTTD() and (GS.RollTheBones("duration") < 3 or GS.RollTheBones("duration") < 10.8/GS.RollTheBones("count") or GS.RollTheBones("count") <= 1 or GS.RollTheBones("count") == 2 and GS.Aura("player", grand_melee) and GS.Aura("player", buried_treasure)) then GS.Cast("player", roll_the_bones, _, _, _, _, "Roll The Bones") return end
                                end
                                if GS.CDs and GS.Talent63 and GS.SCA(killing_spree) and ((GS.PP("deficit"))/GetPowerRegen() > 5 or GS.PP() < 15) then GS.Cast(_, killing_spree, _, _, _, _, "Killing Spree") return end
                                if GS.Talent61 and GS.SIR(cannonball_barrage) and #GS.SmartAoE(35, 6, true, true) >= 1 then
                                    GS.SmartAoE(35, 6, true)
                                    GS.Cast(_, cannonball_barrage, rotationXC, rotationYC, rotationZC, _, "Cannonball Barrage")
                                    return
                                end
                                -- actions+=/curse_of_the_dreadblades,if=combo_points.deficit>=4
                                if GS.Talent72 and GS.SIR(marked_for_death) and GS.CP("deficit") >= 4+(GS.Talent31 and 1 or 0) then
                                    table.sort(GS.MobTargets, GS.SortMobTargetsByLowestTTD)
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(marked_for_death, rotationUnitIterator) then GS.Cast(rotationUnitIterator, marked_for_death, _, _, _, _, "Marked for Death") return end
                                    end
                                end
                                if GS.CP() >= 5 + (GS.Talent31 and 1 or 0) then
                                    if GS.Talent73 and GS.SCA(death_from_above) then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                                    if GS.SCA(run_through) then GS.Cast(_, run_through, _, _, _, _, "Run Through") return end
                                else
                                    if GS.Talent11 and GS.SCA(ghostly_strike) and GS.AuraRemaining("target", ghostly_strike, 4.5, "", "PLAYER") then GS.Cast(_, ghostly_strike, _, _, _, _, "Ghostly Strike") return end
                                    if GS.SCA(pistol_shot) and GS.Aura("player", opportunity) and GS.PP() < 60 then GS.Cast(_, pistol_shot, _, _, _, _, "Pistol Shot") return end
                                    if GS.SCA(saber_slash) then GS.Cast(_, saber_slash, _, _, _, _, "Saber Slash") return end
                                end
                            end
                        end
                    end
                end

                do -- Subtlety
                    -- talents=2210011
                    -- artifact=17:0:0:0:0:851:1:852:3:854:3:858:3:859:3:860:3:862:1:864:1:1349:1
                    local backstab            =     53
                    local eneveloping_shadows = 206237
                    local eviscerate          = 196819
                    local gloomblade          = 200758
                    local nightblade          = 195452
                    local shadow_blades       = 121471
                    local shadow_dance        =        {spell = 185313, buff = 185422}
                    local shadowstrike        = 185438
                    local shuriken_storm      = 197835
                    local symbols_of_death    = 212283

                    function GS.ROGUE3()
                        if UnitAffectingCombat("player") then
                            GS.MultiDoT("Nightblade")
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                -- actions=potion,name=draenic_agility,if=buff.bloodlust.react|target.time_to_die<=25|buff.shadow_blades.up
                                if GS.CDs and (IsStealthed() or GS.Aura("player", shadow_dance.buff)) then
                                    if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial AP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    if GS.SIR(arcane_torrent) and GS.PP("deficit") > 70 then GS.Cast(_, arcane_torrent, _, _, _, _, "Arcane Torrent Belf Racial Rogue") return end
                                    if GS.SIR(shadow_blades) and not GS.Aura("player", shadow_blades) and GS.PP("deficit") < 20 then GS.Cast(_, shadow_blades, _, _, _, _, "Shadow Blades") return end
                                end
                                -- actions+=/goremaws_bite,if=(combo_points.max-combo_points>=2&energy.deficit>55&time<10)|(combo_points.max-combo_points>=4&energy.deficit>45)|target.time_to_die<8
                                if GS.SIR(symbols_of_death) and GS.AuraRemaining("player", symbols_of_death, GS.GetTTD()) and GS.AuraRemaining("player", symbols_of_death, 10.5) then GS.Cast(_, symbols_of_death, _, _, _, _, "Symbols of Death") return end -- todo: handle ttd better
                                if GS.AoE and GS.SIR(shuriken_storm) and (IsStealthed() or GS.Aura("player", shadow_dance.buff)) then
                                    if (GS.Talent61 and GS.CP("deficit") >= 3 and GS.PlayerCount(10) >= 7) or (--[[!buff.death.up&]] GS.CP("deficit") >= 2 and (not GS.Talent61 and GS.PlayerCount(10) >= 4 or GS.PlayerCount(10) >= 8)) then
                                        GS.Cast(_, shuriken_storm, _, _, _, _, "Shuriken Storm: AoE")
                                        return
                                    end
                                end
                                if GS.SCA(shadowstrike) and GS.CP("deficit") >= 2 then GS.Cast(_, shadowstrike, _, _, _, _, "Shadowstrike") return end
                                if GS.CDs and GS.SIR(1856) and (GS.CP("deficit") >= 3 and GetSpellCharges(shadow_dance.spell) < 2 or GS.UnitIsBoss("target") and GS.GetTTD() < 8) then
                                    if GS.PP("deficit") > (GS.Talent71 and 30 or 0) then
                                        return
                                    else
                                        GS.Cast(_, 1856, _, _, _, _, "Vanish")
                                        return
                                    end
                                end
                                if GS.SIR(shadow_dance.spell) and GS.CP("deficit") >= 2 and (GS.SpellCDDuration(1856) > 0 and GS.AuraRemaining("player", symbols_of_death, 10.5) or GetSpellCharges(shadow_dance.spell) >= 2 or GS.UnitIsBoss("target") and GS.GetTTD() < 25) then
                                    if GS.PP("deficit") > (GS.Talent71 and 30 or 0) then
                                        return
                                    else
                                        GS.Cast(_, shadow_dance.spell, _, _, _, _, "Shadow Dance")
                                        return
                                    end
                                end
                                if GS.SIR(58984) and GS.PP() > 40 and GS.CP("deficit") >= 3 and not (GS.Aura("player", shadow_dance.buff) or IsStealthed()) then GS.Cast(_, 58984, _, _, _, _, "Shadowmeld") return end
                                if GS.Talent63 and GS.SIR(enveloping_shadows) and GS.AuraRemaining("player", enveloping_shadows, GS.GetTTD()) and (GS.AuraRemaining("player", enveloping_shadows, (10.8 + (GS.Talent31 and 1.8 or 0))) and GS.CP() >= 5 + (GS.Talent31 and 1 or 0) or GS.AuraRemaining("player", enveloping_shadows, 6)) then GS.Cast(_, enveloping_shadows, _, _, _, _, "Enveloping Shadows") return end
                                if GS.Talent72 and GS.SIR(marked_for_death) and GS.CP("deficit") >= 4+(GS.Talent31 and 1 or 0) then
                                    table.sort(GS.MobTargets, GS.SortMobTargetsByLowestTTD)
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(marked_for_death, rotationUnitIterator) then GS.Cast(rotationUnitIterator, marked_for_death, _, _, _, _, "Marked for Death") return end
                                    end
                                end
                                if GS.CP() >= 5 then -- finishers
                                    if GS.AoE and GS.Talent73 and GS.SCA(death_from_above) and GS.PlayerCount(8) >= 10 then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                                    if GS.SCA(nightblade) and GS.AuraRemaining("target", nightblade, (GS.Talent31 and 5.4 or 4.8)) then GS.Cast(_, nightblade, _, _, _, _, "Nightblade") return end
                                    if GS.AoE and GS.SIR(nightblade) and #GS["tNightblade"] < 6 then
                                        table.sort(GS.MobTargets, GS.SortMobTargetsByHighestTTD)
                                        for i = 1, mobTargetsSize do
                                            rotationUnitIterator = GS.MobTargets[i]
                                            if GS.GetTTD(rotationUnitIterator) > 6 then
                                                if GS.SCA(nightblade, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, nightblade, (GS.Talent31 and 5.4 or 4.8)) then GS.Cast(rotationUnitIterator, nightblade, _, _, _, _, "Nightblade: AoE") return end
                                            else
                                                break
                                            end
                                        end
                                    end
                                    if GS.Talent73 and GS.SCA(death_from_above) then GS.Cast(_, death_from_above, _, _, _, _, "Death from Above") return end
                                    if GS.SCA(eviscerate) then GS.Cast(_, eviscerate, _, _, _, _, "Eviscerate") return end
                                else -- Generators
                                    if GS.AoE and GS.SIR(shuriken_storm) and GS.PlayerCount(10) >= 2 then GS.Cast(_, shuriken_storm, _, _, _, _, "Shuriken Storm: Cleave") return end
                                    if (GS.PP("deficit"))/GetPowerRegen() < 2.5 then
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
            end

        -- Priests
            do
                -- todo: verify Discipline Priest
                -- todo: verify Holy Priest

                do -- Shadow
                    -- talents=1211111
                    -- artifact=47:142063:142057:142063:0:764:1:767:3:768:1:770:1:771:3:772:3:774:3:775:3:777:3:1347:1

                    function GS.PRIEST3()
                        if UnitAffectingCombat("player") then
                            GS.MultiDoT("Shadow Word: Pain")
                            GS.MultiDoT("Vampiric Touch")
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                -- actions=use_item,slot=trinket2
                                -- actions+=/potion,name=deadly_grace,if=buff.bloodlust.react|target.time_to_die<=40

                                if GS.Aura("player", 194249) then -- VF
                                    if GS.Aura("player", 193223) then -- StM
                                        if GS.Talent62 and GS.SIR(205385) then
                                            GS.SmartAoE(40, 8)
                                            GS.Cast(_, 205385, rotationXC, rotationYC, rotationZC, "nextTick", "Shadow Crash")
                                            return
                                        end
                                        if GS.Talent63 and GS.SCA(200174, "target", true) then GS.Cast(_, 200174, _, _, _, "nextTick", "Mindbender") return end
                                        if GS.CDs and GS.SIR(47585) and not GS.Aura("player", 10060) and not GS.Aura("player", berserking) and not GS.Bloodlust() then GS.Cast(_, 47585, _, _, _, "nextTick", "Dispersion: Pause Void Form Stacks") return end
                                        if GS.CDs and GS.Talent61 and GS.SIR(10060) and GS.AuraStacks("player", 194249, 10) then GS.Cast(_, 10060, _, _, _, "nextTick", "Power Infusion: Voidform") return end
                                        -- actions.s2m+=/berserking,if=buff.voidform.stack>=10
                                        if GS.SIR(205448) then
                                            if GS.SCA(205448, "target", true) and GS.GetTTD() > 10 then
                                                if GS.Aura("target", 589, "", "PLAYER") and GS.Aura("target", 34914, "", "PLAYER") and GS.AuraRemaining("target", 589, 3.5*GS.GCD(), "", "PLAYER") and GS.AuraRemaining("target", 34914, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain and Vampiric Touch") return end
                                                if GS.Aura("target", 589, "", "PLAYER") and GS.AuraRemaining("target", 589, 3.5*GS.GCD(), "", "PLAYER") and (GS.Talent52 or GS.Talent53) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                                if GS.Aura("target", 34914, "", "PLAYER") and GS.AuraRemaining("target", 34914, 3.5*GS.GCD()) and (GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]]) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Vampiric Touch") return end
                                                -- actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1    
                                            end
                                            if GS.AoE then
                                                table.sort(GS.tShadowWordPain, GS.SortMobTargetsByHighestTTD)
                                                table.sort(GS.tVampiricTouch, GS.SortMobTargetsByHighestTTD)
                                                for i = 1, #GS.tShadowWordPain do
                                                    rotationUnitIterator = GS.tShadowWordPain[i]
                                                    if GS.GetTTD(rotationUnitIterator) > 10 then
                                                        if GS.SCA(205448, rotationUnitIterator, true) then
                                                            if GS.AuraRemaining(rotationUnitIterator, 589, 3.5*GS.GCD(), "", "PLAYER") and GS.Aura(rotationUnitIterator, 34914, "", "PLAYER") and GS.AuraRemaining(rotationUnitIterator, 34914, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, 228260, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Shadow Word Pain and Vampiric Touch") return end
                                                            if (GS.Talent52 or GS.Talent53) and GS.AuraRemaining(rotationUnitIterator, 589, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                                        end
                                                    else
                                                        break
                                                    end
                                                end

                                                if GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]] then
                                                    for i = 1, #GS.tVampiricTouch do
                                                        rotationUnitIterator = GS.tVampiricTouch[i]
                                                        if GS.GetTTD(rotationUnitIterator) > 10 then
                                                            if GS.SCA(205448, rotationUnitIterator, true) then
                                                                if GS.AuraRemaining(rotationUnitIterator, 34914, 3.5*GS.GCD()) then GS.Cast(rotationUnitIterator, 228260, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Vampiric Touch") return end
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
                                            --                 if GS.SCA(205448, rotationUnitIterator, true) then
                                            --                     actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1
                                            --                 end
                                            --             else
                                            --                 break
                                            --             end
                                                --     end
                                                -- end
                                            end
                                        end
                                        if GS.SCA(205448, "target", true) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt") return end
                                        -- actions.s2m+=/void_torrent
                                        -- actions.s2m+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100
                                        -- actions.s2m+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+90)<100
                                        if GS.SCA(8092, "target", true) then GS.Cast(_, 8092, _, _, _, "nextTick", "Mind Blast") return end
                                        if GS.SCA(32379, "target", true) and GetSpellCharges(32379) == 2 then GS.Cast(_, 32379, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                                        if GS.CDs and not GS.Talent63 and GS.SCA(34433, "target", true) and GS.AuraStacks("player", 194249, 16) then GS.Cast(_, 34433, _, _, _, "nextTick", "Shadowfiend") return end
                                        if GS.Talent13 and GS.SCA(205351, "target", true) and (GS.PP()-(GS.VoidformInsanity("drain")*GS.GCD())+75) < 100 then GS.Cast(_, 205351, _, _, _, "nextTick", "Shadow Word Void: Voidform") return end
                                        if GS.SIR(589) then
                                            if GS.SCA(589, "target", true) and not GS.Aura("target", 589, "", "PLAYER") then
                                                GS.Cast(_, 589, _, _, _, "nextTick", "Shadow Word Pain: Not Up")
                                                return
                                            elseif GS.AoE then
                                                for i = 1, mobTargetsSize do
                                                    rotationUnitIterator = GS.MobTargets[i]
                                                    if GS.SCA(589, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, 589, "", "PLAYER") then GS.Cast(rotationUnitIterator, 589, _, _, _, "nextTick", "Shadow Word Pain: AoE Not Up") return end
                                                end
                                            end
                                        end
                                        if GS.SIR(34914) then
                                            if GS.SCA(34914, "target", true) and not GS.Aura("target", 34914, "", "PLAYER") then
                                                GS.Cast(_, 34914, _, _, _, "nextTick", "Vampiric Touch: Not Up")
                                                return
                                            elseif GS.AoE then
                                                for i = 1, mobTargetsSize do
                                                    rotationUnitIterator = GS.MobTargets[i]
                                                    if GS.SCA(34914, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, 34914, "", "PLAYER") then GS.Cast(rotationUnitIterator, 34914, _, _, _, "nextTick", "Vampiric Touch: Not Up") return end
                                                end
                                            end
                                        end
                                        if GS.SpellCDDuration(205448) < (GS.GCD()*0.75) then if toggleLog then GS.Log("Waiting for Void Bolt"); toggleLog = false end return end
                                        if GS.AoE and GS.SCA(48045, "target", true) and GS.TargetCount(10) >= 3 then GS.Cast(_, 48045, _, _, _, "nextTick Mind Flay", "Mind Sear") return end
                                        if not GS.Talent72 then
                                            if GS.SCA(15407, "target", true) and UnitChannelInfo("player") and (select(6, UnitChannelInfo("player"))/1000-GetTime()) <= (.75/(1+GetHaste()*.01)) then GS.Cast(_, 15407, _, _, _, "chain", "Mind Flay: Chain") return end
                                            if GS.SCA(15407) then GS.Cast(_, 15407, _, _, _, _, "Mind Flay") return end
                                        else
                                            if GS.SCA(73510) then GS.Cast(_, 73510, _, _, _, _, "Mind Spike") return end
                                        end
                                        if GS.SCA(589) then GS.Cast(_, 589, _, _, _, _, "Shadow Word: Pain") return end
                                        return
                                    end
                                    -- #vf
                                    -- if GS.CDs and GS.Talent73 and GS.SIR(193223) and GS.UnitIsBoss("target") and GS.PP() >= 25 and (GS.SpellCDDuration(205448) == 0 --[[or cooldown.void_torrent.up or cooldown.shadow_word_death.up]] or GS.Aura("player", 124430)) and GS.Health("target", _, true) < 30 then GS.Cast(_, 193223, _, _, _, _, "Surrender to Madness") return end
                                    -- actions.vf=surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)&target.time_to_die<=45+((raw_haste_pct*100)*(2+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank)))-buff.insanity_drain_stacks.stack
                                    if GS.Talent62 and GS.SIR(205385) then
                                        GS.SmartAoE(40, 8)
                                        GS.Cast(_, 205385, rotationXC, rotationYC, rotationZC, "nextTick", "Shadow Crash")
                                        return
                                    end
                                    if GS.Talent63 and GS.SCA(200174, "target", true) then GS.Cast(_, 200174, _, _, _, "nextTick", "Mindbender") return end
                                    -- if GS.CDs and GS.SIR(47585) and not GS.Aura("player", 10060) and not GS.Aura("player", berserking) and not GS.Bloodlust() --[[and artifact.void_torrent.rank]] then GS.Cast(_, 47585, _, _, _, "nextTick", "Dispersion: Pause Void Form Stacks") return end
                                    if GS.CDs and GS.Talent61 and GS.SIR(10060) and GS.AuraStacks("player", 194249, 10) and GS.VoidformInsanity("count") <= 30 then GS.Cast(_, 10060, _, _, _, _, "Power Infusion: Voidform") return end
                                    -- actions.vf+=/berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.stack<=20
                                    if GS.SIR(205448) then
                                        if GS.SCA(205448, "target", true) and GS.GetTTD() > 10 then
                                            if GS.Aura("target", 589, "", "PLAYER") and GS.Aura("target", 34914, "", "PLAYER") and GS.AuraRemaining("target", 589, 3.5*GS.GCD(), "", "PLAYER") and GS.AuraRemaining("target", 34914, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain and Vampiric Touch") return end
                                            if GS.Aura("target", 589, "", "PLAYER") and GS.AuraRemaining("target", 589, 3.5*GS.GCD(), "", "PLAYER") and (GS.Talent52 or GS.Talent53) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                            if GS.Aura("target", 34914, "", "PLAYER") and GS.AuraRemaining("target", 34914, 3.5*GS.GCD()) and (GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]]) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Vampiric Touch") return end
                                            -- actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1    
                                        end
                                        if GS.AoE then
                                            table.sort(GS.tShadowWordPain, GS.SortMobTargetsByHighestTTD)
                                            table.sort(GS.tVampiricTouch, GS.SortMobTargetsByHighestTTD)
                                            for i = 1, #GS.tShadowWordPain do
                                                rotationUnitIterator = GS.tShadowWordPain[i]
                                                if GS.GetTTD(rotationUnitIterator) > 10 then
                                                    if GS.SCA(205448, rotationUnitIterator, true) then
                                                        if GS.AuraRemaining(rotationUnitIterator, 589, 3.5*GS.GCD(), "", "PLAYER") and GS.Aura(rotationUnitIterator, 34914, "", "PLAYER") and GS.AuraRemaining(rotationUnitIterator, 34914, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, 228260, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Shadow Word Pain and Vampiric Touch") return end
                                                        if (GS.Talent52 or GS.Talent53) and GS.AuraRemaining(rotationUnitIterator, 589, 3.5*GS.GCD(), "", "PLAYER") then GS.Cast(rotationUnitIterator, 228260, _, _, _, "nextTick", "Void Bolt: Refresh Shadow Word Pain, Auspicious Spirits or Shadowy Insight Talented") return end
                                                    end
                                                else
                                                    break
                                                end
                                            end

                                            if GS.Talent51 --[[or GS.Talent52 and artifact.unleash_the_shadows.rank]] then
                                                for i = 1, #GS.tVampiricTouch do
                                                    rotationUnitIterator = GS.tVampiricTouch[i]
                                                    if GS.GetTTD(rotationUnitIterator) > 10 then
                                                        if GS.SCA(205448, rotationUnitIterator, true) then
                                                            if GS.AuraRemaining(rotationUnitIterator, 34914, 3.5*GS.GCD()) then GS.Cast(rotationUnitIterator, 228260, _, _, _, "nextTick", "Void Bolt: AoE, Refresh Vampiric Touch") return end
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
                                        --                 if GS.SCA(205448, rotationUnitIterator, true) then
                                        --                     actions.s2m+=/void_bolt,if=dot.shadow_word_pain.remains<3.5*gcd&artifact.sphere_of_insanity.rank&target.time_to_die>10,cycle_targets=1
                                        --                 end
                                        --             else
                                        --                 break
                                        --             end
                                            --     end
                                            -- end
                                        end
                                    end
                                    if GS.SCA(205448, "target", true) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Bolt") return end
                                    -- actions.vf+=/void_torrent
                                    if GS.SIR(32379, true) then
                                        if GS.Talent42 then
                                            -- actions.vf+=/shadow_word_death,if=!talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+10)<100
                                        else
                                            -- actions.vf+=/shadow_word_death,if=talent.reaper_of_souls.enabled&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100
                                        end
                                    end
                                    if GS.SCA(8092, "target", true) then GS.Cast(_, 8092, _, _, _, "nextTick", "Mind Blast") return end
                                    if GS.SCA(32379, "target", true) and GetSpellCharges(32379) == 2 then GS.Cast(_, 32379, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                                    if GS.CDs and not GS.Talent63 and GS.SCA(34433, "target", true) and GS.AuraStacks("player", 194249, 16) then GS.Cast(_, 34433, _, _, _, "nextTick", "Shadowfiend") return end
                                    if GS.Talent13 and GS.SCA(205351, "target", true) and (GS.PP()-(GS.VoidformInsanity("drain")*GS.GCD()+25)) < 100 then GS.Cast(_, 205351, _, _, _, _, "Shadow Word Void: Voidform") return end
                                    -- actions.s2m+=/shadow_word_pain,if=!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
                                    -- actions.s2m+=/vampiric_touch,if=!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
                                    -- actions.s2m+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
                                    -- actions.s2m+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
                                    -- actions.s2m+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
                                    if GS.SpellCDDuration(205448) < (GS.GCD()*0.75) then if toggleLog then GS.Log("Waiting for Void Bolt"); toggleLog = false end return end
                                    if GS.AoE and GS.SCA(48045, "target", true) and GS.TargetCount(10) >= 3 then GS.Cast(_, 48045, _, _, _, "nextTick Mind Flay", "Mind Sear") return end
                                    if not GS.Talent72 then
                                        if GS.SCA(15407, "target", true) and UnitChannelInfo("player") and (select(6, UnitChannelInfo("player"))/1000-GetTime()) <= (.75/(1+GetHaste()*.01)) then GS.Cast(_, 15407, _, _, _, "chain", "Mind Flay: Chain") return end
                                        if GS.SCA(15407) then GS.Cast(_, 15407, _, _, _, _, "Mind Flay") return end
                                    else
                                        if GS.SCA(73510) then GS.Cast(_, 73510, _, _, _, _, "Mind Spike") return end
                                    end
                                    if GS.SCA(589) then GS.Cast(_, 589, _, _, _, _, "Shadow Word: Pain") return end
                                    return
                                end

                                if GS.CDs and GS.Talent73 and GS.SIR(193223) and GS.UnitIsBoss("target") and GS.Health("target", _, true) < 30 then GS.Cast(_, 193223, _, _, _, _, "Surrender to Madness") return end
                                if GS.Talent63 and GS.SCA(200174, "target", true) then GS.Cast(_, 200174, _, _, _, "nextTick", "Mindbender") return end
                                if GS.SCA(589, "target", true) and GS.AuraRemaining("target", 589, ((3+4/3)*GS.GCD())) then GS.Cast(_, 589, _, _, _, "nextTick", "Shadow Word Pain: 4.3r*GCD") return end
                                if GS.SCA(34914, "target", true) and GS.AuraRemaining("target", 34914, ((3+4/3)*GS.GCD())) then GS.Cast(_, 34914, _, _, _, "nextTick", "Vampiric Touch: 4.3r*GCD") return end
                                if GS.SIR(228260) and (GS.PP() >= 85 or GS.Talent52 and GS.PP() >= (80-GS.Priest.ApparitionsInFlight*4)) then GS.Cast(_, 228260, _, _, _, "nextTick", "Void Eruption") return end
                                if GS.Talent62 and GS.SIR(205385) then
                                    GS.SmartAoE(40, 8)
                                    GS.Cast(_, 205385, rotationXC, rotationYC, rotationZC, "nextTick", "Shadow Crash")
                                    return
                                end
                                -- if GS.Talent63 and GS.SCA(200174, "target", true) --[[and set_bonus.tier18_2pc]] then GS.Cast(_, 200174, _, _, _, "nextTick", "Mindbender: T18 2PC") return end
                                if GS.SIR(589) and GS.Talent71 and GS.PP() >= 70 then
                                    if GS.SCA(589, "target", true) and not GS.Aura("target", 589, "", "PLAYER") then
                                        GS.Cast(_, 589, _, _, _, "nextTick", "Shadow Word Pain: Not Up")
                                        return
                                    elseif GS.AoE then
                                        for i = 1, mobTargetsSize do
                                            rotationUnitIterator = GS.MobTargets[i]
                                            if GS.SCA(589, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, 589, "", "PLAYER") then GS.Cast(rotationUnitIterator, 589, _, _, _, "nextTick", "Shadow Word Pain: AoE Not Up") return end
                                        end
                                    end
                                end
                                if GS.SIR(34914) and GS.Talent71 and GS.PP() >= 70 then
                                    if GS.SCA(34914, "target", true) and not GS.Aura("target", 34914, "", "PLAYER") then
                                        GS.Cast(_, 34914, _, _, _, "nextTick", "Vampiric Touch: Not Up")
                                        return
                                    elseif GS.AoE then
                                        for i = 1, mobTargetsSize do
                                            rotationUnitIterator = GS.MobTargets[i]
                                            if GS.SCA(34914, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, 34914, "", "PLAYER") then GS.Cast(rotationUnitIterator, 34914, _, _, _, "nextTick", "Vampiric Touch: Not Up") return end
                                        end
                                    end
                                end
                                if GS.SCA(32379, "target", true) and GetSpellCharges(32379) == 2 then
                                    if not GS.Talent42 then
                                        if GS.PP() <= 90 then GS.Cast(_, 32379, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                                    else
                                        if GS.PP() <= 70 then GS.Cast(_, 32379, _, _, _, "nextTick", "Shadow Word Death: Capped Charges") return end
                                    end
                                end
                                if GS.SCA(8092, "target", true) and GS.Talent71 and (GS.PP() <= 81 or GS.PP() <= 75.2 and GS.Talent12) then GS.Cast(_, 8092, _, _, _, "nextTick", "Mind Blast: Without Capping Insainity") return end
                                if GS.SCA(8092, "target", true) and (not GS.Talent71 or GS.PP() <= 96 or GS.PP() <= 95.2 and GS.Talent12) then GS.Cast(_, 8092, _, _, _, "nextTick", "Mind Blast: Without Capping") return end
                                -- actions.main+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
                                -- actions.main+=/vampiric_touch,if=!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
                                -- actions.main+=/shadow_word_pain,if=!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
                                if GS.Talent13 and GS.SCA(205351, "target", true) and (GS.PP() <= 70 and GS.Talent71 or GS.PP() <= 85 and not GS.Talent71) then GS.Cast(_, 205351, _, _, _, "nextTick", "Shadow Word Void") return end
                                if GS.AoE and GS.SCA(48045, "target", true) and GS.TargetCount(10) >= 3 then GS.Cast(_, 48045, _, _, _, "nextTick Mind Flay", "Mind Sear") return end
                                if not GS.Talent72 then
                                    if GS.SCA(15407, "target", true) and UnitChannelInfo("player") and (select(6, UnitChannelInfo("player"))/1000-GetTime()) <= (.75/(1+GetHaste()*.01)) then GS.Cast(_, 15407, _, _, _, "chain", "Mind Flay: Chain") return end
                                    if GS.SCA(15407) then GS.Cast(_, 15407, _, _, _, _, "Mind Flay") return end
                                else
                                    if GS.SCA(73510) then GS.Cast(_, 73510, _, _, _, _, "Mind Spike") return end
                                end
                                if GS.SCA(589) then GS.Cast(_, 589, _, _, _, _, "Shadow Word: Pain") return end
                            end
                        end
                    end
                end

            end

        -- Shamans
            do
                -- todo: verify Elemental Shaman

                do -- Enhancement
                    -- talents=3003112
                    -- artifact=41:0:0:0:0:899:1:901:1:902:1:903:1:904:1:905:1:909:3:910:3:911:3:912:3:1351:1
                    
                    function GS.SHAMAN2()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                -- actions=wind_shear
                                -- actions+=/auto_attack
                                if GS.CDs then
                                    if GS.SIR(51533) then GS.Cast(_, 51533, _, _, _, _, "Feral Spirit") return end
                                    -- actions+=/use_item,slot=trinket2
                                    -- actions+=/potion,name=draenic_agility,if=pet.feral_spirit.remains>10|pet.frost_wolf.remains>5|pet.fiery_wolf.remains>5|pet.lightning_wolf.remains>5|target.time_to_die<=30
                                    if GS.SIR(berserking) and (GS.Aura("player", 114051) or not GS.Talent71 or UnitLevel("player") < 100) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    if GS.SIR(33697) then GS.Cast(_, 33697, _, _, _, _, "Blood Fury Orc Racial ASP") return end
                                end
                                if GS.Talent13 and GS.SCA(201897) and (GS.AuraRemaining("player", 218825, GS.GCD()) or GS.FracCalc("spell", 201897) >= 1.75) then GS.Cast(_, 201897, _, _, _, _, "Boulderfist: Buff Not Up or Prevent Charges Cap") return end
                                if GS.Talent43 and GS.SCA(196834) and GS.AuraRemaining("player", 196834, GS.GCD()) then GS.Cast(_, 196834, _, _, _, _, "Frostbrand: Low Buff") return end
                                if GS.SCA(193796) and GS.AuraRemaining("player", 194084, GS.GCD()) then GS.Cast(_, 193796, _, _, _, _, "Flametongue: Low Buff") return end
                                if GS.Talent11 and GS.SCA(201898) then GS.Cast(_, 201898, _, _, _, _, "Windsong") return end
                                if GS.CDs and GS.Talent71 and GS.SIR(114051) then GS.Cast(_, 114051, _, _, _, _, "Ascendance") return end
                                if GS.Talent62 and not GS.Aura("player", 197211) then GS.Cast(_, 197211, _, _, _, _, "Fury of Air: Not Up") return end
                                -- actions+=/doom_winds
                                if GS.AoE and GS.SIR(187874) and GS.TargetCount(8) >= 3 then GS.Cast(_, 187874, _, _, _, _, "Crash Lightning: AoE") return end
                                if GS.Aura("player", 114051) then
                                    if GS.SCA(115356) then GS.Cast(_, 115356, _, _, _, _, "Windstrike") return end
                                else
                                    if GS.SCA(17364) then GS.Cast(_, 17364, _, _, _, _, "Stormstrike") return end
                                end
                                if GS.Talent43 and GS.SCA(196834) and GS.AuraRemaining("player", 196834, 4.8) then GS.Cast(_, 196834, _, _, _, _, "Frostbrand") return end
                                if GS.SCA(193796) and GS.AuraRemaining("player", 194084, 4.8) then GS.Cast(_, 193796, _, _, _, _, "Flametongue: Buff") return end
                                if GS.Talent52 and GS.SCA(187837) and GS.PP() >= 60 then GS.Cast(_, 187837, _, _, _, _, "Lightning Bolt: Overcharge") return end
                                if GS.SCA(60103) and GS.Aura("player", 215785) then GS.Cast(_, 60103, _, _, _, _, "Lava Lash: Hot Hand") return end
                                if GS.Talent73 and GS.SCA(188089) then GS.Cast(_, 188089, _, _, _, _, "Earthen Spike") return end
                                if GS.SIR(187874) and (GS.AoE and GS.TargetCount(8) > 1 or GS.Talent61 or GS.SpellCDDuration(51533) > 110) then GS.Cast(_, 187874, _, _, _, _, "Crash Lightning") return end
                                -- actions+=/sundering
                                if GS.SCA(60103) and GS.PP() >= 90 then GS.Cast(_, 60103, _, _, _, _, "Lava Lash: Dump Maelstrom") return end
                                if not GS.Talent13 and GS.SCA(193786) then GS.Cast(_, 193786, _, _, _, _, "Rockbiter") return end
                                if GS.SCA(193796) then GS.Cast(_, 193796, _, _, _, _, "Flametongue") return end
                                if GS.Talent13 and GS.SCA(201897) then GS.Cast(_, 201897, _, _, _, _, "Boulderfist") return end
                            end
                        end
                    end
                end

                -- todo: verify Restoration Shaman
            end

        -- Mages
            do
                -- todo: verify Arcane Mage
                -- todo: verify Fire Mage
                -- todo: verify Frost Mage
            end

        -- Warlocks
            do
                function GS.WARLOCK190()
                end
                -- todo: verify Affliction Warlock
                -- todo: verify Demonology Warlock
                -- todo: verify Destruction Warlock
            end

        -- Monks
            do
                local blood_fury = 33697
                -- todo: verify Brewmaster Monk
                -- todo: verify Mistweaver Monk

                function GS.MONK190()
                    if UnitAffectingCombat("player") or UnitAffectingCombat("focus") then
                        if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                            if GS.SCA(121253, "target") then GS.Cast(_, 121253, _, _, _, _, "Keg Smash") return end
                            if GS.SCA(205523, "target") then GS.Cast(_, 205523, _, _, _, _, "Blackout Strike") return end
                            if GS.SCA(100780, "target") and (GS.PP()-25)+GetPowerRegen()*(GS.SpellCDDuration(121253)) > 40 then GS.Cast(_, 100780, _, _, _, _, "Tiger Palm") return end
                        end
                    end
                end

                function GS.MistweaverRenewingMist()
                    if GS.SIR(115151) then
                        table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)
                        for i = 1, allyTargetsSize do
                            rotationUnitIterator = GS.AllyTargets[i].Player
                            -- if GS.Health(rotationUnitIterator, _, true) < 100 or UnitGroupRolesAssigned(rotationUnitIterator) == "TANK" then 
                                if GS.SCA(115151, rotationUnitIterator, true) and --[[not GS.Aura(rotationUnitIterator, 119611, "", "PLAYER")]]GS.AuraRemaining(rotationUnitIterator, 119611, 6, "", "PLAYER") then
                                    if GS.SIR(116680) and (GS.Talent73 or not GS.Aura("player", 197206)) then GS.Cast(_, 116680, _, _, _, "Soothing Mist", "Thunder Focus Tea: Renewing Mist") return end
                                    GS.Cast(rotationUnitIterator, 115151, _, _, _, "Soothing Mist", "Renewing Mist: Greatest Deficit")
                                    return
                                end
                            -- else
                                -- break
                            -- end
                        end
                    else
                        return false
                    end
                end

                function GS.MistweaverEssenceFont90()
                    if GS.SIR(191837) then
                        local essenceFontMax = GS.HealingAmount("Essence Font")
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
                        if healingAmount >= 3*essenceFontMax*GSR.EssenceFontPercent then GS.Cast(_, 191837, _, _, _, "Soothing Mist", "Essence Font") return end
                    else
                        return false
                    end
                end

                GS.MistweaverVivifyTable = {}

                function GS.MistweaverVivify()
                    if GS.SIR(116670) and allyTargetsSize > 1 then
                        local vivifyMax = GS.HealingAmount("Vivify")
                        local currentHealingAmount, greatestHealingAmount, chosenTarget = 0, (GSR.VivifyPercent*vivifyMax-1), nil
                        local tempCount, tempGUID = 0, nil
                        table.sort(GS.AllyTargets, GS.SortAllyTargetsByLowestDistance)
                        table.wipe(GS.MistweaverVivifyTable)
                        for i = 1, allyTargetsSize do
                            rotationUnitIterator = GS.AllyTargets[i].Player
                            tempCount = 0
                            if GS.SCA(116670, rotationUnitIterator, true) then
                                currentHealingAmount = math.min(GS.Health(rotationUnitIterator, _, _, true), vivifyMax)
                                if i == 1 then
                                    for v = (i+1), allyTargetsSize do
                                        if GS.Health(GS.AllyTargets[v].Player, _, true) < 100 then currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[v].Player, _, _, true), vivifyMax); tempCount = temptCount + 1 end
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
                                            if GS.Health(GS.AllyTargets[j].Player, _, true) < 100 and not GS.MistweaverVivifyTable[j] then
                                                for k = (i+1), allyTargetsSize do
                                                    if GS.Health(GS.AllyTargets[k].Player, _, true) < 100 and not GS.MistweaverVivifyTable[k] then tempGUID = GS.AllyTargets[k].Player break end
                                                end
                                                if GS.Distance(GS.AllyTargets[j].Player, rotationUnitIterator) <= GS.Distance(tempGUID, rotationUnitIterator) then
                                                    GS.MistweaverVivifyTable[j] = true
                                                    tempCount = tempCount + 1
                                                    currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[j].Player, _, _, true), vivifyMax)
                                                end
                                                tempGUID = nil
                                                break
                                            else
                                                GS.MistweaverVivifyTable[j] = true
                                            end
                                        end
                                        if tempCount < 2 then
                                            for k = (i+1), allyTargetsSize do
                                                if GS.Health(GS.AllyTargets[k].Player, _, true) < 100 and not GS.MistweaverVivifyTable[k] then
                                                    for j = (i-1), 1, -1 do
                                                        if GS.Health(GS.AllyTargets[j].Player, _, true) < 100 and not GS.MistweaverVivifyTable[j] then tempGUID = GS.AllyTargets[j].Player break end
                                                    end
                                                    if GS.Distance(GS.AllyTargets[k].Player, rotationUnitIterator) <= GS.Distance(tempGUID, rotationUnitIterator) then
                                                        GS.MistweaverVivifyTable[k] = true
                                                        tempCount = tempCount + 1
                                                        currentHealingAmount = currentHealingAmount + math.min(GS.Health(GS.AllyTargets[k].Player, _, _, true), vivifyMax)
                                                    end
                                                    tempGUID = nil
                                                    break
                                                else
                                                    GS.MistweaverVivifyTable[k] = true
                                                end
                                            end
                                        end
                                    until (tempCount >= 2 or #GS.MistweaverVivifyTable == allyTargetsSize-1)
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

                function GS.MistweaverHealingElixirs90()
                    if GS.Talent51 and GS.SIR(122281) then
                        if GS.Health("player", _, true) < 85 then GS.Cast(_, 122281, _, _, _, "Soothing Mist", "Healing Elixir") return end
                    else
                        return false
                    end
                end

                function GS.MistweaverZenPulse90()
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

                function GS.MistweaverEnvelopingMist()
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

                function GS.MistweaverFistVivify()
                end

                function GS.MistweaverEffuse()
                    if GS.SIR(116694) then
                        table.sort(GS.AllyTargets, GS.SortAllyTargetsByGreatestDeficit)
                        for i = 1, allyTargetsSize do
                            rotationUnitIterator = GS.AllyTargets[i].Player
                            if GS.Health(rotationUnitIterator, _, _, true) >= GS.HealingAmount("Effuse")*GSR.EffusePercent then
                                if GS.SCA(116694, rotationUnitIterator, true) and not GS.Aura(rotationUnitIterator, 115175, "", "PLAYER") then GS.Cast(rotationUnitIterator, 116694, _, _, _, "Soothing Mist", "Effuse") return end
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

                function GS.MONK290() -- Mistweaver
                    if UnitAffectingCombat("player") or UnitExists("focus") and UnitAffectingCombat("focus") then
                        if GetTime() > GS.SpellThrottle then
                            -- Renewing Mist 115151 , Buff 119611
                            -- Effuse 116694
                            -- Enveloping Mist 124682, Buff 124682
                            -- Vivify 116670, Uplifting Trance Proc 197206
                            -- Essence Font 191837
                            -- Thunder Focus Tea 116680

                            GS.MistweaverHealingElixirs90()
                            GS.MistweaverRenewingMist()
                            -- GS.MistweaverEssenceFont90()
                            -- GS.MistweaverVivify()
                            -- GS.MistweaverZenPulse90()
                            -- GS.MistweaverEnvelopingMist()
                            -- GS.MistweaverEffuse()
                            if (GS.Talent32 or GS.Talent73) and not GS.Aura("player", 116680) then GS.Fistweave() end
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

                    function GS.MONK3()
                        if UnitAffectingCombat("player") then
                            if GS.IsCH() then return end
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                if GS.CDs then
                                    if GS.Talent62 and GS.SCA(123904) then GS.Cast(_, 123904, _, _, _, _, "Invoke Xuen, the White Tiger") return end
                                    -- actions+=/potion,name=virmens_bite,if=buff.bloodlust.react|target.time_to_die<=60
                                    if GS.SIR(blood_fury) then GS.Cast(_, blood_fury, _, _, _, _, "Blood Fury Orc Racial ASP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    if GS.SIR(129597) and GS.CP("deficit") >= 1 then GS.Cast(_, 129597, _, _, _, _, "Arcane Torrent Belf Racial Monk") return end
                                    if GS.SCA(touch_of_death) then GS.Cast(_, touch_of_death, _, _, _, _, "Touch of Death") return end
                                        -- actions+=/touch_of_death,if=!artifact.gale_burst.enabled
                                        -- actions+=/touch_of_death,if=artifact.gale_burst.enabled&cooldown.strike_of_the_windlord.up&!talent.serenity.enabled&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
                                        -- actions+=/touch_of_death,if=artifact.gale_burst.enabled&cooldown.strike_of_the_windlord.up&talent.serenity.enabled&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
                                    if not GS.Talent73 and GS.SIR(storm_earth_and_fire) and not GS.Aura("player", storm_earth_and_fire) and GS.SpellCDDuration(fists_of_fury) <= 9 and GS.SpellCDDuration(rising_sun_kick) <= 5 then GS.Cast(_, storm_earth_and_fire, _, _, _, _, "Storm, Earth, and Fire") return end
                                        -- actions+=/storm_earth_and_fire,if=artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.up&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
                                        -- actions+=/storm_earth_and_fire,if=!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=9&cooldown.rising_sun_kick.remains<=5
                                    if GS.Talent73 and GS.SIR(serenity) and GS.SpellCDDuration(fists_of_fury) <= 3 and GS.SpellCDDuration(rising_sun_kick) < 8 then GS.Cast(_, serenity, _, _, _, _, "Serenity") return end
                                        -- actions+=/serenity,if=artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.up&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
                                        -- actions+=/serenity,if=!artifact.strike_of_the_windlord.enabled&cooldown.fists_of_fury.remains<=3&cooldown.rising_sun_kick.remains<8
                                end
                                if GS.Talent31 and GS.SIR(energizing_elixir) and GS.PP("deficit") > 0 and GS.CP() <= 1 and not GS.Aura("player", serenity) then GS.Cast(_, energizing_elixir, _, _, _, _, "Energizing Elixir") return end
                                if GS.Talent61 and GS.SIR(rushing_jade_wind) and GS.Aura("player", serenity) and GS.Monk.lastCast ~= rushing_jade_wind then GS.Cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind: Free Serenity") return end
                                -- actions+=/strike_of_the_windlord,if=artifact.strike_of_the_windlord.enabled
                                if GS.Talent72 and GS.SIR(whirling_dragon_punch) and not GS.IsCH() and GS.Distance("target") < 8+UnitCombatReach("target") then GS.Cast(_, whirling_dragon_punch, _, _, _, _, "Whirling Dragon Punch") return end
                                if GS.SCA(fists_of_fury) then GS.Cast(_, fists_of_fury, _, _, _, _, "Fists of Fury") return end
                                if (not GS.AoE or GS.PlayerCount(8) < 3) then -- Single Target
                                    if GS.SCA(rising_sun_kick) then GS.Cast(_, rising_sun_kick, _, _, _, _, "Rising Sun Kick") return end
                                    -- actions.st+=/strike_of_the_windlord
                                    if GS.Talent61 and GS.SIR(rushing_jade_wind) and GS.CP() > 1 and GS.Monk.lastCast ~= rushing_jade_wind then GS.Cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
                                    if GS.Talent13 and GS.SCA(chi_wave) and (((GS.PP("deficit"))/GetPowerRegen()) > 2 or not GS.Aura("player", serenity)) then GS.Cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
                                    if GS.Talent11 and GS.SIR(chi_burst) and (GS.PP("deficit")/GetPowerRegen() > 2 or not GS.Aura("player", serenity)) then GS.Cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
                                    if GS.SCA(blackout_kick) and (GS.CP() > 1 or GS.Aura("player", blackout_kick_combo)) and not GS.Aura("player", serenity) and GS.Monk.lastCast ~= blackout_kick then GS.Cast(_, blackout_kick, _, _, _, _, "Blackout Kick") return end
                                    if GS.SCA(tiger_palm) and not GS.Aura("player", serenity) and GS.CP() <= 2 and (GS.Monk.lastCast ~= tiger_palm) then GS.Cast(_, tiger_palm, _, _, _, _, "Tiger Palm") return end
                                else -- AoE
                                    if GS.SIR(101546) and GS.Monk.lastCast ~= 101546 then GS.Cast(_, 101546, _, _, _, _, "Spinning Crane Kick") return end
                                    -- actions.aoe+=/strike_of_the_windlord
                                    if GS.Talent61 and GS.SIR(rushing_jade_wind) and GS.CP() >= 2 and GS.Monk.lastCast ~= rushing_jade_wind then GS.Cast(_, rushing_jade_wind, _, _, _, _, "Rushing Jade Wind") return end
                                    if GS.Talent13 and GS.SCA(chi_wave) and (((GS.PP("deficit"))/GetPowerRegen()) > 2 or not GS.Aura("player", serenity)) then GS.Cast(_, chi_wave, _, _, _, _, "Chi Wave") return end
                                    if GS.Talent11 and GS.SIR(chi_burst) and (GS.PP("deficit")/GetPowerRegen() > 2 or not GS.Aura("player", serenity)) then GS.Cast("target", chi_burst, false, false, false, "SpellToInterrupt", "Chi Burst") return end
                                    if GS.SCA(tiger_palm) and not GS.Aura("player", serenity) and GS.CP() <= 2 and GS.Monk.lastCast ~= tiger_palm then GS.Cast(_, tiger_palm, _, _, _, _, "Tiger Palm") return end
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

        -- Druids
            do
                do -- Balance
                    -- talents=2200221
                    -- artifact=59:0:0:0:0:1035:3:1036:3:1039:2:1040:3:1042:3:1044:1:1046:1:1047:1:1049:1:1294:1
                    local astral_communion    = 202359
                    local blessing_of_anshe   = 202739
                    local blessing_of_elune   = 202737
                    local celestial_alignment = 194223
                    local fury_of_elune       = 202770
                    local incarnation         = 102560
                    local lunar_empowerment   = 164547
                    local lunar_strike        = 194153
                    local moonfire            =        {spell = 8921, debuff = 164812}
                    local solar_empowerment   = 164545
                    local solar_wrath         = 190984
                    local starsurge           =  78674
                    local stellar_flare       = 202347
                    local sunfire             =        {spell = 93402, debuff = 164815}
                    local warrior_of_elune    = 202425
                    
                    function GS.DRUID1()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                if GS.CDs and GS.Aura("player", (GS.Talent52 and incarnation or celestial_alignment)) then
                                    -- actions=potion,name=draenic_intellect
                                    -- actions+=/berserking
                                end
                                if GS.Talent71 and (GS.Aura("player", fury_of_elune) or GS.CDs and GS.UnitIsBoss("target") and GS.SpellCDDuration(fury_of_elune) < GS.GetTTD()) then -- Fury of Elune Rotation
                                    if GS.PP() >= 95 and GS.SpellCDDuration(fury_of_elune) <= GS.GCD() then
                                        if GS.Talent52 then
                                            if GS.SIR(incarnation) then GS.Cast(_, incarnation, _, _, _, _, "Incarnation: Fury of Elune Time") return end
                                        else
                                            if GS.SIR(celestial_alignment) then GS.Cast(_, celestial_alignment, _, _, _, _, "Celestial Alignment: Fury of Elune Time") return end
                                        end
                                        if GS.SIR(fury_of_elune) then GS.Cast(_, fury_of_elune, _, _, _, _, "Fury of Elune") return end -- todo: handle the aoe part later
                                    end
                                    -- actions.fury_of_elune+=/new_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=90))
                                    -- actions.fury_of_elune+=/half_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=80))
                                    -- actions.fury_of_elune+=/full_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=60))
                                    if GS.Talent62 and GS.SIR(astral_communion) and GS.PP() <= 25 then GS.Cast(_, astral_communion, _, _, _, _, "Astral Communion: Fury of Elune") return end
                                    if GS.Talent12 and GS.SIR(warrior_of_elune) and (GS.Aura("player", fury_of_elune) or GS.SpellCDDuration(fury_of_elune) >= 35 and GS.Aura("player", lunar_empowerment)) then GS.Cast(_, warrior_of_elune, _, _, _, _, "Warrior of Elune: Fury of Elune") return end
                                    if GS.SCA(lunar_strike) and GS.Aura("player", warrior_of_elune) and (GS.PP() <= 90 or GS.PP() <= 85 and GS.Aura("player", (GS.Talent52 and incarnation or celestial_alignment))) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Fury of Elune") return end
                                    -- actions.fury_of_elune+=/new_moon,if=astral_power<=90&buff.fury_of_elune_up.up
                                    -- actions.fury_of_elune+=/half_moon,if=astral_power<=80&buff.fury_of_elune_up.up&astral_power>cast_time*12
                                    -- actions.fury_of_elune+=/full_moon,if=astral_power<=60&buff.fury_of_elune_up.up&astral_power>cast_time*12
                                    if not GS.Aura("player", fury_of_elune) then
                                        if GS.SCA(moonfire.spell) and GS.AuraRemaining("target", moonfire.debuff, 6.6, "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire: Fury of Elune") return end
                                        if GS.SCA(sunfire.spell) and GS.AuraRemaining("target", sunfire.debuff, 5.4, "Solar", "PLAYER") then GS.Cast(_, sunfire.spell, _, _, _, _, "Sunfire: Fury of Elune") return end
                                    end
                                    if GS.Talent53 and GS.SCA(stellar_flare) and GS.AuraRemaining("target", stellar_flare, 7.2, "", "PLAYER") then GS.Cast(_, stellar_flare, _, _, _, _, "Stellar Flare: Refresh") return end
                                    if GS.SCA(starsurge) and not GS.Aura("player", fury_of_elune) and (GS.PP() >= 92 and GS.SpellCDDuration(fury_of_elune) > GS.GCD()*3 or GS.SpellCDDuration(warrior_of_elune) <= 5 and GS.SpellCDDuration(fury_of_elune) >= 35 and not GS.AuraStacks("player", lunar_empowerment, 2)) then GS.Cast(_, starsurge, _, _, _, _, "Starsurge: Fury of Elune") return end
                                    if GS.SCA(solar_wrath) and GS.Aura("player", solar_empowerment) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Empowered") return end
                                    if GS.SCA(lunar_strike) and (GS.AuraStacks("player", lunar_empowerment, 3) or GS.Aura("player", lunar_empowerment) and GS.AuraRemaining("player", lunar_empowerment, 5)) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Fury of Elune") return end
                                    if GS.SCA(solar_wrath) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath") return end
                                end
                                -- actions+=/new_moon,if=(charges=2&recharge_time<5)|charges=3
                                -- actions+=/half_moon,if=(charges=2&recharge_time<5)|charges=3|(target.time_to_die<15&charges=2)
                                -- actions+=/full_moon,if=(charges=2&recharge_time<5)|charges=3|target.time_to_die<15
                                if GS.Talent53 and GS.SCA(stellar_flare) and GS.AuraRemaining("target", stellar_flare, 7.2, "", "PLAYER") then GS.Cast(_, stellar_flare, _, _, _, _, "Stellar Flare: Refresh") return end
                                if GS.SCA(moonfire.spell) and GS.AuraRemaining("target", moonfire.debuff, (GS.Talent73 and 3 or 6.6), "Lunar", "PLAYER") then GS.Cast(_, moonfire.spell, _, _, _, _, "Moonfire") return end
                                if GS.SCA(sunfire.spell) and GS.AuraRemaining("target", sunfire.debuff, (GS.Talent73 and 5.4 or 3), "Solar", "PLAYER") then GS.Cast(_, sunfire.spell, _, _, _, _, "Sunfire") return end
                                if GS.CDs then
                                    if GS.Talent62 and GS.SIR(astral_communion) and GS.PP("deficit") >= 75 then GS.Cast(_, astral_communion, _, _, _, _, "Astral Communion") return end
                                    if GS.PP() >= 40 then
                                        if GS.Talent52 then
                                            if GS.SIR(incarnation) then GS.Cast(_, incarnation, _, _, _, _, "Incarnation") return end
                                        else
                                            if GS.SIR(celestial_alignment) then GS.Cast(_, celestial_alignment, _, _, _, _, "Celestial Alignment") return end
                                        end
                                    end
                                end
                                if GS.SCA(solar_wrath) and GS.AuraStacks("player", solar_empowerment, 3) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Capped Empowered") return end
                                if GS.SCA(lunar_strike) and GS.AuraStacks("player", lunar_empowerment, 3) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Capped Empowered") return end
                                if GS.Aura("player", (GS.Talent52 and incarnation or celestial_alignment)) then -- Celestial Alignment or Incarnation Rotation
                                    if GS.SCA(starsurge) then GS.Cast(_, starsurge, _, _, _, _, "Starsurge") return end
                                    if GS.Talent12 and GS.SIR(warrior_of_elune) and GS.AuraStacks("player", lunar_empowerment, 2) and GS.PP() <= (GS.Aura("player", blessing_of_elune) and 58 or 70) then GS.Cast(_, warrior_of_elune, _, _, _, _, "Warrior of Elune") return end
                                    if GS.SCA(lunar_strike) and GS.Aura("player", warrior_of_elune) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Instant Warrior Of Elune") return end
                                    if GS.SCA(solar_wrath) and GS.Aura("player", solar_empowerment) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Empowered") return end
                                    if GS.SCA(lunar_strike) and GS.Aura("player", lunar_empowerment) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Empowered") return end
                                    if GS.Talent73 and GS.SCA(solar_wrath) and GS.AuraRemaining("target", sunfire.debuff, 5, "Solar", "PLAYER") and not GS.AuraRemaining("target", sunfire.debuff, GS.CastTime(solar_wrath), "Solar", "PLAYER") then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Extend Sunfire") return end
                                    if GS.Talent73 and GS.SCA(lunar_strike) and GS.AuraRemaining("target", moonfire.debuff, 5, "Lunar", "PLAYER") and not GS.AuraRemaining("target", moonfire.debuff, GS.CastTime(lunar_strike), "Lunar", "PLAYER") then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Extend Moonfire") return end
                                    if GS.SCA(solar_wrath) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath") return end
                                end

                                -- actions.single_target=new_moon,if=astral_power<=90
                                -- actions.single_target+=/half_moon,if=astral_power<=80
                                -- actions.single_target+=/full_moon,if=astral_power<=60
                                if GS.SCA(starsurge) then GS.Cast(_, starsurge, _, _, _, _, "Starsurge") return end
                                if GS.Talent12 and GS.SIR(warrior_of_elune) and GS.AuraStacks("player", lunar_empowerment, 2) and GS.PP() <= (GS.Aura("player", blessing_of_elune) and 72 or 80) then GS.Cast(_, warrior_of_elune, _, _, _, _, "Warrior of Elune") return end
                                if GS.SCA(lunar_strike) and GS.Aura("player", warrior_of_elune) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Instant Warrior Of Elune") return end
                                if GS.SCA(solar_wrath) and GS.Aura("player", solar_empowerment) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Empowered") return end
                                if GS.SCA(lunar_strike) and GS.Aura("player", lunar_empowerment) then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Empowered") return end
                                if GS.Talent73 and GS.SCA(solar_wrath) and GS.AuraRemaining("target", sunfire.debuff, 5, "Solar", "PLAYER") and not GS.AuraRemaining("target", sunfire.debuff, GS.CastTime(solar_wrath), "Solar", "PLAYER") then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath: Extend Sunfire") return end
                                if GS.Talent73 and GS.SCA(lunar_strike) and GS.AuraRemaining("target", moonfire.debuff, 5, "Lunar", "PLAYER") and not GS.AuraRemaining("target", moonfire.debuff, GS.CastTime(lunar_strike), "Lunar", "PLAYER") then GS.Cast(_, lunar_strike, _, _, _, _, "Lunar Strike: Extend Moonfire") return end
                                if GS.SCA(solar_wrath) then GS.Cast(_, solar_wrath, _, _, _, _, "Solar Wrath") return end
                            end
                        end
                    end
                end

                do -- Feral
                    -- talents=3323323
                    -- artifact=58:0:0:0:0:1153:1:1156:1:1157:1:1158:1:1161:3:1163:2:1164:3:1165:3:1166:3:1327:1
                    local feralPlaceHolderOne, feralPlaceHolderTwo = false, false
                    function GS.DRUID2()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                if GS.SCA(1822) and GS.Aura("player", 5215) then
                                    GS.Druid.RakeMultiplier[ObjectPointer("target")] = GS.RakeCurrentMultiplier()
                                    GS.Cast(_, 1822, _, _, _, _, "Rake: Prowl")
                                    return
                                end
                                if GS.Talent63 and GS.SIR(202060) and GS.CP() == 0 --[[and (not artifact.ashamanes_bite.enabled or not dota.ashamanes_rip.ticking)]] then
                                    if GS.PP() < 50 then
                                        return
                                    else
                                        GS.Cast(_, 202060, _, _, _, _, "Elune's Guidance")
                                        return
                                    end
                                end
                                if GS.CDs then
                                    if not GS.Talent52 then
                                        if GS.SIR(106951) and GS.Aura("player", 5217) then GS.Cast(_, 106951, _, _, _, _, "Berserk") return end
                                    else
                                        if GS.SIR(102543) and GS.SpellCDDuration(5217) < 1 then GS.Cast(_, 102543, _, _, _, _, "Incarnation: Tiger's Fury Almost Up") return end
                                    end
                                    -- actions+=/use_item,slot=trinket2,if=(prev.tigers_fury&(target.time_to_die>trinket.stat.any.cooldown|target.time_to_die<45))|prev.berserk|(buff.incarnation.up&time<10)
                                    -- actions+=/potion,name=draenic_agility,if=((buff.berserk.remains>10|buff.incarnation.remains>20)&(target.time_to_die<180|(trinket.proc.all.react&target.health.pct<25)))|target.time_to_die<=40
                                    if GS.SIR(berserking) and GS.SIR(5217) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                end
                                if GS.SIR(5217) and GS.SpellCDDuration(61304) == 0 then
                                    if (not GS.Aura("player", 135700) and GS.PP("deficit") >= 60 or GS.PP("deficit") >= 80 --[[or t18_class_trinket and GS.Aura("player", 106951)]]) then GS.Cast(_, 5217, _, _, _, _, "Tiger's Fury") return end
                                    if GS.Talent61 and (GetTime()-GS.CombatStart) < 10 and GS.CP() == 5 then GS.Cast(_, 5217, _, _, _, _, "Tiger's Fury") return end
                                end
                                if GS.CDs and GS.Talent52 and GS.SIR(102543) and ((GS.PP("deficit"))/GetPowerRegen()) > 1 then GS.Cast(_, 102543, _, _, _, _, "Incarnation") return end
                                if GS.SIR(22568) then
                                    if GS.SCA(22568) and GS.Aura("target", 1079, "", "PLAYER") and GS.AuraRemaining("target", 1079, 3, "", "PLAYER") and GS.Health("target", _, true) < 25 then GS.Cast(_, 22568, _, _, _, _, "Ferocious Bite: Blood in the Water") return end
                                    if GS.AoE and GS.SIR(22568) then
                                        for i = 1, mobTargetsSize do
                                            rotationUnitIterator = GS.MobTargets[i]
                                            if GS.SCA(22568, rotationUnitIterator) and GS.Aura(rotationUnitIterator, 1079, "", "PLAYER") and GS.AuraRemaining(rotationUnitIterator, 1079, 3, "", "PLAYER") and GS.Health(rotationUnitIterator, _, true) < 25 then GS.Cast(rotationUnitIterator, 22568, _, _, _, _, "Ferocious Bite: Blood in the Water") return end
                                        end
                                    end
                                end
                                if GS.Talent72 and GS.SIR(5185) and GS.Aura("player", 69369) and (GS.CP() >= 4 --[[and not set_bonus.tier18_4pc]] or GS.CP() == 5 or GS.AuraRemaining("player", 69369, 1.5)) then GS.Cast("player", 5185, _, _, _, _, "Healing Touch: Bloodtalons") return end
                                if GS.Talent53 and GS.SIR(52610) and not GS.Aura("player", 52610) then GS.Cast(_, 52610, _, _, _, _, "Savage Roar: Not Up") return end
                                -- -- actions+=/thrash_cat,if=set_bonus.tier18_4pc&buff.clearcasting.react&remains<=duration*0.3&combo_points+buff.bloodtalons.stack!=6
                                if GS.AoE and (--[[GS.PlayerCount(8) >=2 and set_bonus.tier17_2pc or ]]GS.PlayerCount(8) >= 4) and GS.SpellCDDuration(106830) == 0 then
                                    feralPlaceHolderOne = GS.Talent62 and 3 or 4.5
                                    feralPlaceHolderTwo = false
                                    if GS.AuraRemaining("target", 106830, feralPlaceHolderOne, "Feral, Guardian", "PLAYER") and GS.Distance("target") <= 8+UnitCombatReach("target") then
                                        feralPlaceHolderTwo = true
                                    else
                                        for i = 1, mobTargetsSize do
                                            rotationUnitIterator = GS.MobTargets[i]
                                            if GS.AuraRemaining(rotationUnitIterator, 106830, feralPlaceHolderOne, "Feral, Guardian", "PLAYER") and GS.Distance(rotationUnitIterator) <= 8+UnitCombatReach(rotationUnitIterator) then
                                                feralPlaceHolderTwo = true
                                                break
                                            end
                                        end
                                    end
                                    if feralPlaceHolderTwo then
                                        if GS.PoolCheck(106830) then return end
                                        if GS.SIR(106830) then GS.Cast(_, 106830, _, _, _, _, "Thrash") return end
                                    end
                                end
                                if GS.CP() == 5 then
                                    if GS.SIR(1079) then
                                        feralPlaceHolderOne = GS.Talent62 and 4.8 or 7.2
                                        if GS.SCA(1079) and GS.AuraRemaining("target", 1079, feralPlaceHolderOne, "", "PLAYER") and (GS.Health("target", _, true) > 25 or not GS.Aura("target", 1079, "", "PLAYER")) then GS.Cast(_, 1079, _, _, _, _, "Rip") return end
                                        if GS.AoE then
                                            for i = 1, mobTargetsSize do
                                                rotationUnitIterator = GS.MobTargets[i]
                                                if GS.SCA(1079, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, 1079, feralPlaceHolderOne, "", "PLAYER") and (GS.Health(rotationUnitIterator, _, true) > 25 or not GS.Aura(rotationUnitIterator, 1079, "", "PLAYER")) then GS.Cast(rotationUnitIterator, 1079, _, _, _, _, "Rip: AoE") return end
                                            end
                                        end
                                    end
                                    if GS.Talent53 and GS.SIR(52610) and GS.AuraRemaining("player", 52610, 7.2) and (GS.Health("target", _, true) < 25 or ((GS.PP("deficit"))/GetPowerRegen()) < 1 or GS.Aura("player", 106951) or GS.Aura("player", 102543) or GS.AuraRemaining("target", 155722, 1.5, "", "PLAYER") or GS.Talent63 and GS.SpellCDDuration(202060) > 40 or GS.SpellCDDuration(5217) < 3 or GS.Talent73 and GS.Aura("player", 135700)) then
                                        --                                                                                        Execute                                        Energy Cap                                   Berserk                      Incarnation                  Rake < 1.5                                               Elune's Guidance                                                     Tiger's Fury Almost Up               Clearcasting
                                        GS.Cast(_, 52610, _, _, _, _, "Savage Roar")
                                        return
                                    end
                                    if GS.SIR(22568) and GS.PP() >= 50 then
                                        feralPlaceHolderOne, feralPlaceHolderTwo = false, false
                                        if GS.Talent61 then feralPlaceHolderOne = true end
                                        if (GS.SpellCDDuration(5217) < 3 or ((GS.PP("deficit"))/GetPowerRegen()) < 1 or GS.Aura("player", 106951) or GS.Aura("player", 102543) or GS.Talent63 and GS.SpellCDDuration(202060) > 40 or GS.Talent73 and GS.Aura("player", 135700)) then
                                            feralPlaceHolderTwo = true
                                        end
                                        if GS.SCA(22568) and (feralPlaceHolderOne or GS.Health("target", _, true) < 25) and (feralPlaceHolderTwo or GS.AuraRemaining("target", 155722, 1.5, "", "PLAYER")) then
                                            GS.Cast(_, 22568, _, _, _, _, "Ferocious Bite: Blood in the Water")
                                            return
                                        elseif GS.AoE then
                                            for i = 1, mobTargetsSize do
                                                rotationUnitIterator = GS.MobTargets[i]
                                                if GS.SCA(22568, rotationUnitIterator) and (feralPlaceHolderOne or GS.Health(rotationUnitIterator, _, true) < 25) and (feralPlaceHolderTwo or GS.AuraRemaining(rotationUnitIterator, 155722, 1.5, "", "PLAYER")) then
                                                    GS.Cast(rotationUnitIterator, 22568, _, _, _, _, "Ferocious Bite: AoE Blood in the Water")
                                                    return
                                                end
                                            end
                                        end
                                        if GS.SCA(22568) and (GS.Aura("player", 106951) or GS.Aura("player", 102543) or GS.SpellCDDuration(5217) < 3 or GS.Talent63 and GS.SpellCDDuration(202060) > 40) then GS.Cast(_, 22568, _, _, _, _, "Ferocious Bite") return end
                                        if GS.SCA(22568) and ((GS.PP("deficit"))/GetPowerRegen()) < 1 then GS.Cast(_, 22568, _, _, _, _, "Ferocious Bite: Prevent Energy Cap") return end
                                    end
                                end
                                if GS.Talent53 and GS.SIR(52610) and GS.AuraRemaining("player", 52610, 1) then GS.Cast(_, 52610, _, _, _, _, "Savage Roar: Less Than GCD") return end
                                -- -- actions+=/ashamanes_frenzy,if=time<10&dot.rake.ticking&!talent.elunes_guidance.enabled
                                if GS.CP() < 5 then
                                    if GS.SIR(1822) then
                                        feralPlaceHolderOne = GS.Talent62 and (2/(1+GetHaste()*.01)) or 3/(1+GetHaste()*.01)
                                        if GS.SCA(1822) and GS.AuraRemaining("target", 155722, feralPlaceHolderOne, "", "PLAYER") and (((not GS.AoE or GS.PlayerCount(8) < 3) and 3 or 6) < GS.GetTTD() - (GS.Aura("target", 155722, "", "PLAYER") and (select(7, GS.Aura("target", 155722, "", "PLAYER"))-GetTime()) or 0)) then
                                            GS.Druid.RakeMultiplier[ObjectPointer("target")] = GS.RakeCurrentMultiplier()
                                            GS.Cast(_, 1822, _, _, _, _, "Rake: Last Tick")
                                            return
                                        elseif GS.AoE then
                                            for i = 1, mobTargetsSize do
                                                rotationUnitIterator = GS.MobTargets[i]
                                                if GS.SCA(1822, rotationUnitIterator) then
                                                    if GS.AuraRemaining(rotationUnitIterator, 155722, feralPlaceHolderOne, "", "PLAYER")
                                                    and (((not GS.AoE or GS.PlayerCount(8) < 3) and 3 or 6) < GS.GetTTD(rotationUnitIterator) - (GS.Aura(rotationUnitIterator, 155722, "", "PLAYER") and (select(7, GS.Aura(rotationUnitIterator, 155722, "", "PLAYER"))-GetTime()) or 0))
                                                    then
                                                        GS.Druid.RakeMultiplier[ObjectPointer(rotationUnitIterator)] = GS.RakeCurrentMultiplier()
                                                        GS.Cast(rotationUnitIterator, 1822, _, _, _, _, "Rake: Last Tick")
                                                        return
                                                    end
                                                end
                                            end
                                        end

                                        feralPlaceHolderOne = GS.Talent62 and 3 or 4.5

                                        if GS.SCA(1822) and GS.AuraRemaining("target", 155722, feralPlaceHolderOne, "", "PLAYER") and (GS.RakeCurrentMultiplier() >= (GS.Druid.RakeMultiplier[ObjectPointer("target")] or 0) or GS.Talent72 and (GS.Aura("player", 145152) or not GS.Aura("player", 69369))) and (GS.GetTTD()-(GS.Aura("target", 155722, "", "PLAYER") and (select(7, GS.Aura("target", 155722, "", "PLAYER"))-GetTime()) or 0) > ((not GS.AoE or GS.PlayerCount(8) < 3) and 3 or 6)) then
                                            GS.Druid.RakeMultiplier[ObjectPointer("target")] = GS.RakeCurrentMultiplier()
                                            GS.Cast(_, 1822, _, _, _, _, "Rake: Refreshable")
                                            return
                                        elseif GS.AoE then
                                            for i = 1, mobTargetsSize do
                                                rotationUnitIterator = GS.MobTargets[i]
                                                if GS.SCA(1822, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, 155722, feralPlaceHolderOne, "", "PLAYER") and (GS.RakeCurrentMultiplier() >= (GS.Druid.RakeMultiplier[ObjectPointer(rotationUnitIterator)] or 0) or GS.Talent72 and (GS.Aura("player", 145152) or not GS.Aura("player", 69369))) and (GS.GetTTD(rotationUnitIterator)-(GS.Aura(rotationUnitIterator, 155722, "", "PLAYER") and (select(7, GS.Aura(rotationUnitIterator, 155722, "", "PLAYER"))-GetTime()) or 0) > (GS.PlayerCount(8) < 3 and 3 or 6)) then
                                                    GS.Druid.RakeMultiplier[ObjectPointer(rotationUnitIterator)] = GS.RakeCurrentMultiplier()
                                                    GS.Cast(rotationUnitIterator, 1822, _, _, _, _, "Rake: Refreshable")
                                                    return
                                                end
                                            end
                                        end
                                    end
                                    if GS.Talent13 and GS.SIR(155625) and GS.PlayerCount(8) <= 5 then
                                        if GS.SCA(155625) and GS.AuraRemaining("target", 155625, 4.2, "", "PLAYER") and GS.GetTTD()-(GS.Aura("target", 155625, "", "PLAYER") and (select(7, GS.Aura("target", 155625, "", "PLAYER"))-GetTime()) or 0) > 2/(1+GetHaste()*.01)*5 then
                                            GS.Cast(_, 155625, _, _, _, _, "Moonfire")
                                            return
                                        elseif GS.AoE then
                                            for i = 1, mobTargetsSize do
                                                rotationUnitIterator = GS.MobTargets[i]
                                                if GS.SCA(155625, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, 155625, 4.2, "", "PLAYER") and GS.GetTTD(rotationUnitIterator)-(GS.Aura(rotationUnitIterator, 155625, "", "PLAYER") and (select(7, GS.Aura(rotationUnitIterator, 155625, "", "PLAYER"))-GetTime()) or 0) > 2/(1+GetHaste()*.01)*5 then
                                                    GS.Cast(rotationUnitIterator, 155625, _, _, _, _, "Moonfire")
                                                    return
                                                end
                                            end
                                        end
                                    end
                                end
                                if GS.AoE and GS.PlayerCount(8) >= 2 and GS.SpellCDDuration(106830) == 0 then
                                    feralPlaceHolderOne = GS.Talent62 and 3 or 4.5
                                    feralPlaceHolderTwo = false
                                    if GS.AuraRemaining("target", 106830, feralPlaceHolderOne, "Feral, Guardian", "PLAYER") and GS.Distance("target") <= 8+UnitCombatReach("target") then
                                        feralPlaceHolderTwo = true
                                    else
                                        for i = 1, mobTargetsSize do
                                            rotationUnitIterator = GS.MobTargets[i]
                                            if GS.AuraRemaining(rotationUnitIterator, 106830, feralPlaceHolderOne, "Feral, Guardian", "PLAYER") and GS.Distance(rotationUnitIterator) <= 8+UnitCombatReach(rotationUnitIterator) then
                                                feralPlaceHolderTwo = true
                                                break
                                            end
                                        end
                                    end
                                    if feralPlaceHolderTwo then
                                        if GS.PoolCheck(106830) then if toggleLog then GS.Log("Pooling for Thrash"); toggleLog = false end return end
                                        if GS.SIR(106830) then toggleLog = true; GS.Cast(_, 106830, _, _, _, _, "Thrash") return end
                                    end
                                end
                                if GS.CP() < 5 then
                                    -- actions.generator=ashamanes_frenzy,if=combo_points<=2&buff.elunes_guidance.down
                                    if GS.AoE then
                                        if GS.Talent71 then
                                            if GS.SpellCDDuration(202028) == 0 then
                                                -- actions.generator+=/pool_resource,for_next=1
                                                -- actions.generator+=/brutal_slash,if=spell_targets.brutal_slash>desired_targets
                                                -- actions.generator+=/pool_resource,for_next=1
                                                -- actions.generator+=/brutal_slash,if=active_enemies>=2&raid_event.adds.exists&raid_event.adds.in>(1+max_charges-charges_fractional)*15
                                                -- actions.generator+=/pool_resource,for_next=1
                                                -- actions.generator+=/brutal_slash,if=active_enemies>=2&!raid_event.adds.exists&(charges_fractional>2.66&time>10)
                                            end
                                        else
                                            if GS.SIR(106785) and GS.PlayerCount(8) >= 4 then GS.Cast(_, 106785, _, _, _, _, "Swipe") return end
                                        end
                                    end
                                    if GS.SCA(5221) and (not GS.AoE or GS.PlayerCount(8) <= 3 or GS.Talent71)  then GS.Cast(_, 5221, _, _, _, _, "Shred") return end
                                end
                            end
                        end
                    end
                end

                do -- Guardian
                    -- talents=3323323
                    -- artifact=57:0:0:0:0:948:3:949:3:950:3:951:3:952:3:953:3:954:3:955:3:956:3:957:1:958:1:959:1:960:1:961:1:962:1:979:1:1334:1

                    function GS.DRUID3()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                StartAttack()
                                if GSR.Interrupt then GS.Interrupt() end
                                
                                if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                -- actions+=/use_item,slot=trinket2
                                -- actions+=/barkskin
                                -- actions+=/bristling_fur,if=buff.ironfur.remains<2&rage<40
                                -- actions+=/ironfur,if=buff.ironfur.down|rage.deficit<25
                                -- actions+=/frenzied_regeneration,if=!ticking&incoming_damage_6s%health.max>0.25+(2-charges_fractional)*0.15
                                if GS.Talent73 and not GS.Aura("player", 158792) then
                                    if GS.SCA(80313) then GS.Cast(_, 80313, _, _, _, _, "Pulverize") return end
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(80313, rotationUnitIterator) then GS.Cast(rotationUnitIterator, 80313, _, _, _, _, "Pulverize") return end
                                    end
                                end
                                if GS.SCA(33917) then GS.Cast(_, 33917, _, _, _, _, "Mangle") return end
                                if GS.Talent73 and GS.AuraRemaining("player", 158792, GS.GCD()) then
                                    if GS.SCA(80313) then GS.Cast(_, 80313, _, _, _, _, "Pulverize") return end
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(80313, rotationUnitIterator) then GS.Cast(rotationUnitIterator, 80313, _, _, _, _, "Pulverize") return end
                                    end
                                end
                                -- actions+=/lunar_beam
                                -- actions+=/incarnation
                                if GS.AoE and GS.SIR(77758) and GS.PlayerCount(8) >= 2 then GS.Cast(_, 77758, _, _, _, _, "Thrash: AoE") return end
                                if GS.Talent73 and GS.AuraRemaining("player", 158792, 3.6) then
                                    if GS.SCA(80313) then GS.Cast(_, 80313, _, _, _, _, "Pulverize") return end
                                    for i = 1, mobTargetsSize do
                                        rotationUnitIterator = GS.MobTargets[i]
                                        if GS.SCA(80313, rotationUnitIterator) then GS.Cast(rotationUnitIterator, 80313, _, _, _, _, "Pulverize") return end
                                    end
                                end
                                if GS.Talent73 and GS.SIR(77758) and GS.PlayerCount(8) > 0 and GS.AuraRemaining("player", 158792, 3.6) then GS.Cast(_, 77758, _, _, _, _, "Thrash: Pulverize Running Out") return end
                                if GS.SCA(8921) and not GS.Aura("target", 164812, "Lunar", "PLAYER") then GS.Cast(_, 8921, _, _, _, _, "Moonfire: Not Up") return end
                                for i = 1, mobTargetsSize do
                                    rotationUnitIterator = GS.MobTargets[i]
                                    if GS.UnitIsTappedByPlayer(rotationUnitIterator) and GS.SCA(8921, rotationUnitIterator) and not GS.Aura(rotationUnitIterator, 164812, "Lunar", "PLAYER") then GS.Cast(rotationUnitIterator, 8921, _, _, _, _, "Moonfire: AoE Not Up") return end
                                end
                                if GS.SCA(8921) and GS.AuraRemaining("target", 164812, 3.6, "Lunar", "PLAYER") then GS.Cast(_, 8921, _, _, _, _, "Moonfire: Low Duration") return end
                                for i = 1, mobTargetsSize do
                                    rotationUnitIterator = GS.MobTargets[i]
                                    if GS.UnitIsTappedByPlayer(rotationUnitIterator) and GS.SCA(8921, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, 164812, 3.6, "Lunar", "PLAYER") then GS.Cast(rotationUnitIterator, 8921, _, _, _, _, "Moonfire: AoE Low Duration") return end
                                end
                                if GS.SCA(8921) and GS.AuraRemaining("target", 164812, 7.2, "Lunar", "PLAYER") then GS.Cast(_, 8921, _, _, _, _, "Moonfire: Medium Duration") return end
                                for i = 1, mobTargetsSize do
                                    rotationUnitIterator = GS.MobTargets[i]
                                    if GS.UnitIsTappedByPlayer(rotationUnitIterator) and GS.SCA(8921, rotationUnitIterator) and GS.AuraRemaining(rotationUnitIterator, 164812, 7.2, "Lunar", "PLAYER") then GS.Cast(rotationUnitIterator, 8921, _, _, _, _, "Moonfire: AoE Medium Duration") return end
                                end
                                if GS.SCA(8921) then GS.Cast(_, 8921, _, _, _, _, "Moonfire") return end
                            end
                        end
                    end
                end
                -- todo: verify Restoration Druid
            end

        -- Demon Hunters
            do
                -- todo: verify Havoc Demon Hunter
                -- todo: verify Vengeance Demon Hunter
                -- todo: verify Blood Death Knight
            end

        -- Death Knights
            do
                do -- Frost
                    -- talents=1130023
                    -- artifact=12:0:0:0:0:108:3:110:2:113:3:114:3:119:1:120:1:122:1:123:1:1090:3:1332:1

                    function GS.DEATHKNIGHT2()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                actions=auto_attack
                                if GS.CDs then
                                    if GS.SIR(50613) and GS.PP("deficit") > 20 then GS.Cast(_, 50613, _, _, _, _, "Arcane Torrent Belf Racial") return end
                                    if GS.SIR(20572) and (not GS.Talent72 or GS.Aura("player", 152279)) then GS.Cast(_, 20572, _, _, _, _, "Blood Fury Orc Racial AP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    -- actions+=/use_item,slot=trinket2
                                    -- actions+=/potion,name=draenic_strength,if=cooldown.pillar_of_frost.remains<5&cooldown.thorasus_the_stone_heart_of_draenor.remains<10
                                    if GS.SIR(51271) then GS.Cast(_, 51271, _, _, _, _, "Pillar of Frost") return end
                                    -- actions+=/sindragosas_fury
                                    if GS.Talent71 and GS.SIR(207256) then GS.Cast(_, 207256, _, _, _, _, "Obliteration") return end
                                    if GS.Talent72 and GS.SIR(152279) and GS.PP() >= 80 then GS.Cast(_, 152279, _, _, _, _, "Breath of Sindragosa") return end
                                end
                                if GS.Aura("player", 152279) then -- Breath of Sindragosa Rotation
                                    if GS.Talent73 and GS.SIR(194913) then GS.Cast(_, 194913, _, _, _, _, "Glacial Advance") return end
                                    if GS.Talent61 and GS.SCA(207230) and (GS.Aura("player", 51124) or GS.AoE and GS.PlayerCount(8) >= 4) then GS.Cast(_, 207230, _, _, _, _, "Frostscythe") return end
                                    if GS.SCA(49020) and GS.Aura("player", 51124) then GS.Cast(_, 49020, _, _, _, _, "Obliterate: Killing Machine") return end
                                    if GS.AoE and GS.SIR(196770) and GS.PlayerCount(8) >= 2 then GS.Cast(_, 196770, _, _, _, _, "Remorseless Winter") return end
                                    if GS.SCA(49020) then GS.Cast(_, 49020, _, _, _, _, "Obliterate") return end
                                    if GS.Talent22 then
                                        if GS.Talent61 and GS.SCA(207230) then GS.Cast(_, 207230, _, _, _, _, "Frostscythe: Frozen Pulse") return end
                                        if GS.SCA(49184) then GS.Cast(_, 49184, _, _, _, _, "Howling Blast: Frozen Pulse") return end
                                    end
                                    if GS.SCA(49184) and not GS.Aura("target", 55095, "", "PLAYER") then GS.Cast(_, 49184, _, _, _, _, "Howling Blast: Frost Fever") return end
                                    if GS.Talent23 and GS.SIR(57330) then GS.Cast(_, 57330, _, _, _, _, "Horn of Winter") return end
                                    if not GS.Talent32 then
                                        if GS.SIR(47568) then GS.Cast(_, 47568, _, _, _, _, "Empower Rune Weapon") return end
                                    else
                                        if GS.SIR(207127) then GS.Cast(_, 207127, _, _, _, _, "Hungering Rune Weapon") return end
                                    end
                                    if GS.SCA(49184) and GS.Aura("player", 59052) then GS.Cast(_, 49184, _, _, _, _, "Howling Blast: Rime") return end
                                end
                                if GS.SCA(49184) and not GS.Aura("target", 55095, "", "PLAYER") then GS.Cast(_, 49184, _, _, _, _, "Howling Blast: Frost Fever") return end
                                if GS.SCA(49184) and GS.Aura("player", 59052) then GS.Cast(_, 49184, _, _, _, _, "Howling Blast: Rime") return end
                                if GS.SCA(49143) and GS.PP() >= 80 then GS.Cast(_, 49143, _, _, _, _, "Frost Strike: Dump RP") return end
                                if GS.Talent73 and GS.SIR(194913) then GS.Cast(_, 194913, _, _, _, _, "Glacial Advance") return end
                                if GS.Talent61 and GS.SIR(207230) and GS.PlayerCount(8) >= 1 and (GS.Aura("player", 51124) or GS.AoE and GS.PlayerCount(8) >= 4) then GS.Cast(_, 207230, _, _, _, _, "Frostscythe") return end
                                if GS.SCA(49020) and GS.Aura("player", 51124) then GS.Cast(_, 49020, _, _, _, _, "Obliterate: Killing Machine") return end
                                if GS.AoE and GS.SIR(196770) and GS.PlayerCount(8) >= 2 then GS.Cast(_, 196770, _, _, _, _, "Remorseless Winter") return end
                                if GS.SCA(49020) then GS.Cast(_, 49020, _, _, _, _, "Obliterate") return end
                                if GS.Talent22 then
                                    if GS.Talent61 and GS.SCA(207230) then GS.Cast(_, 207230, _, _, _, _, "Frostscythe: Frozen Pulse") return end
                                    if GS.SCA(49184) then GS.Cast(_, 49184, _, _, _, _, "Howling Blast: Frozen Pulse") return end
                                end
                                if GS.Talent72 then
                                    if GS.SCA(49143) and GS.SpellCDDuration(152279) > 15 then GS.Cast(_, 49143, _, _, _, _, "Frost Strike: Breath of Sindragosa Not Up") return end
                                else
                                    if GS.SCA(49143) then GS.Cast(_, 49143, _, _, _, _, "Frost Strike") return end
                                end
                                if GS.Talent72 then
                                    if GS.SpellCDDuration(152279) > 15 then
                                        if GS.Talent23 and GS.SIR(57330) then GS.Cast(_, 57330, _, _, _, _, "Horn of Winter: Breath of Sindragosa Not Up") return end
                                        if not GS.Talent32 then
                                            if GS.SIR(47568) then GS.Cast(_, 47568, _, _, _, _, "Empower Rune Weapon") return end
                                        else
                                            if GS.SIR(207127) then GS.Cast(_, 207127, _, _, _, _, "Hungering Rune Weapon") return end
                                        end
                                    end
                                else
                                    if GS.Talent23 and GS.SIR(57330) then GS.Cast(_, 57330, _, _, _, _, "Horn of Winter") return end
                                    if not GS.Talent32 then
                                        if GS.SIR(47568) then GS.Cast(_, 47568, _, _, _, _, "Empower Rune Weapon") return end
                                    else
                                        if GS.SIR(207127) then GS.Cast(_, 207127, _, _, _, _, "Hungering Rune Weapon") return end
                                    end
                                end
                            end
                        end
                    end
                end

                do -- Unholy
                    -- talents=3330021
                    -- artifact=16:0:0:0:0:149:1:152:1:153:1:157:3:158:3:264:3:266:3:1119:3:1333:1
                    
                    function GS.DEATHKNIGHT3()
                        if UnitAffectingCombat("player") then
                            if GS.ValidTarget() and (not GSR.ChaosMode or GetTime() > GS.SpellThrottle) then
                                -- actions=auto_attack
                                if GS.CDs then
                                    if GS.SIR(50613) and GS.PP("deficit") > 20 then GS.Cast(_, 50613, _, _, _, _, "Arcane Torrent Belf Racial") return end
                                    if GS.SIR(20572) then GS.Cast(_, 20572, _, _, _, _, "Blood Fury Orc Racial AP") return end
                                    if GS.SIR(berserking) then GS.Cast(_, berserking, _, _, _, _, "Berserking Troll Racial") return end
                                    -- actions+=/use_item,slot=trinket2
                                    -- actions+=/potion,name=draenic_strength,if=cooldown.summon_gargoyle.remains>165&!talent.dark_arbiter.enabled
                                    -- actions+=/potion,name=draenic_strength,if=cooldown.dark_arbiter.remains>165&talent.dark_arbiter.enabled
                                end
                                if GS.SCA(77575) and not GS.Aura("target", 191587, "", "PLAYER") then GS.Cast(_, 77575, _, _, _, _, "Outbreak: Virulent Plague Not Up") return end
                                if GS.SIR(63560) then GS.Cast(_, 63560, _, _, _, _, "Dark Transformation") return end
                                if GS.Talent23 and GS.SIR(194918) then GS.Cast(_, 194918, _, _, _, _, "Blighted Rune Weapon") return end
                                if GS.Talent71 and GS.SpellCDDuration(207349) > 165 then -- Val'kyr Rotation
                                    if GS.SCA(47541) then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Valkyr") return end
                                    if GS.AoE and GS.PlayerCount(8) >= 2 then
                                        if not GS.Talent72 and GS.SIR(43265) then
                                            if #GS.SmartAoE(30, 8, true, true) >= 2 then
                                                GS.SmartAoE(30, 8)
                                                GS.Cast(_, 43265, rotationXC, rotationYC, rotationZC, _, "Death and Decay")
                                                return
                                            end
                                        end
                                        -- actions.aoe+=/epidemic,if=spell_targets.epidemic>4
                                        if not GS.Talent33 then
                                            if GS.SCA(55090) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and 43265 or 152280)) > 20 then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: DnD AoE") return end
                                        else
                                            if GS.SCA(207311) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and 43265 or 152280)) > 20 then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: DnD AoE") return end
                                        end
                                        -- actions.aoe+=/epidemic,if=spell_targets.epidemic>2
                                    end
                                    if GS.SCA(85948) and not GS.AuraStacks("target", 194310, 7, "", "PLAYER") then GS.Cast(_, 85948, _, _, _, _, "Festering Strike: 6 or Less Festering Wounds") return end
                                    if not GS.Talent33 then
                                        if GS.SCA(55090) then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: Val'kyr, Pop Festering Wounds") return end
                                    else
                                        if GS.SCA(207311) then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: Val'kyr, Pop Festering Wounds") return end
                                    end
                                end
                                if GS.CDs then
                                    if GS.Talent71 then
                                        if GS.SIR(207349) and GS.PP() > 80 then GS.Cast(_, 207349, _, _, _, _, "Dark Arbiter") return end
                                    else
                                        if GS.SIR(49206) then GS.Cast(_, 49206, _, _, _, _, "Summon Gargoyle") return end
                                    end
                                end
                                if GS.SIR(47541) then
                                    if GS.SCA(47541) and GS.PP() > 80 then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Dump RP") return end
                                    if GS.Talent71 then
                                        if GS.SCA(47541) and GS.Aura("player", 81340) and GS.SpellCDDuration(207349) > 5 then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Sudden Doom, Dark Arbiter Not Up") return end
                                    else
                                        if GS.SCA(47541) and GS.Aura("player", 81340) then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Sudden Doom") return end
                                    end
                                end
                                if GS.Talent73 then
                                    if GS.SCA(130736) and GS.AuraStacks("target", 194310, 3, "", "PLAYER") then GS.Cast(_, 130736, _, _, _, _, "Soul Reaper") return end
                                    if GS.Aura("target", 130736, "", "PLAYER") then
                                        if GS.SCA(85948) and not GS.Aura("target", 194310, "", "PLAYER") then GS.Cast(_, 85948, _, _, _, _, "Festering Strike: Soul Reaper No Festering Wounds") return end
                                        if GS.Aura("target", 194310, "", "PLAYER") then
                                            if not GS.Talent33 then
                                                if GS.SCA(55090) then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: Soul Reaper Pop Festering Wounds") return end
                                            else
                                                if GS.SCA(207311) then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: Soul Reaper Pop Festering Wounds") return end
                                            end
                                        end
                                    end
                                end
                                if GS.Talent72 and GS.SIR(152280) then
                                    GS.SmartAoE(30, 8)
                                    GS.Cast(_, 152280, rotationXC, rotationYC, rotationZC, _, "Defile")
                                    return
                                end
                                if GS.AoE and GS.PlayerCount(8) >= 2 then
                                    if not GS.Talent72 and GS.SIR(43265) then
                                        if #GS.SmartAoE(30, 8, true, true) >= 2 then
                                            GS.SmartAoE(30, 8)
                                            GS.Cast(_, 43265, rotationXC, rotationYC, rotationZC, _, "Death and Decay")
                                            return
                                        end
                                    end
                                    -- actions.aoe+=/epidemic,if=spell_targets.epidemic>4
                                    if not GS.Talent33 then
                                        if GS.SCA(55090) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and 43265 or 152280)) > 20 then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: DnD AoE") return end
                                    else
                                        if GS.SCA(207311) and GS.TargetCount(8) >= 2 and GS.SpellCDDuration((not GS.Talent72 and 43265 or 152280)) > 20 then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: DnD AoE") return end
                                    end
                                    -- actions.aoe+=/epidemic,if=spell_targets.epidemic>2
                                end
                                if GS.SCA(85948) and not GS.AuraStacks("target", 194310, 5, "", "PLAYER") then GS.Cast(_, 85948, _, _, _, _, "Festering Strike: 4 or Less Festering Wounds") return end
                                if not GS.Talent33 then
                                    if GS.SCA(55090) and GS.Aura("player", 216974) then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: Necrosis") return end
                                    if GS.SCA(55090) and GS.Aura("player", 53365) then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: Unholy Strength") return end
                                    if GS.SCA(55090) and GS.NumberOfAvailableRunes() >= 3 then GS.Cast(_, 55090, _, _, _, _, "Scourge Strike: 3 or more Runes Available") return end
                                else
                                    if GS.SCA(207311) and GS.Aura("player", 216974) then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: Necrosis") return end
                                    if GS.SCA(207311) and GS.Aura("player", 53365) then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: Unholy Strength") return end
                                    if GS.SCA(207311) and GS.NumberOfAvailableRunes() >= 3 then GS.Cast(_, 207311, _, _, _, _, "Clawing Shadows: 3 or more Runes Available") return end
                                end
                                if GS.SIR(47541) then
                                    if GS.Talent61 then
                                        if GS.Talent71 then
                                            if GS.SCA(47541) and not GS.Aura("pet", 63560) and GS.SpellCDDuration(207349) > 15 then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Reduce Dark Transformation CD, Dark Arbiter Not Up") return end
                                        else
                                            if GS.SCA(47541) and not GS.Aura("pet", 63560) then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Reduce Dark Transformation CD") return end
                                        end
                                    end
                                    if GS.Talent71 then
                                        if GS.SCA(47541) and GS.SpellCDDuration(207349) > 15 then GS.Cast(_, 47541, _, _, _, _, "Death Coil: Dark Arbiter Not Up") return end
                                    elseif not GS.Talent61 then
                                        if GS.SCA(47541) then GS.Cast(_, 47541, _, _, _, _, "Death Coil") return end
                                    end
                                end
                            end
                        end
                    end
                end
            end
    end

-- Rotations Unverified
    -- if GS.SIR(20572) then GS.Cast(_, 20572, _, _, _, _, "Blood Fury Orc Racial AP") return end
    -- if GS.SIR(33697) then GS.Cast(_, 33697, _, _, _, _, "Blood Fury Orc Racial ASP") return end
    -- if GS.SIR(33702) then GS.Cast(_, 33702, _, _, _, _, "Blood Fury Orc Racial SP") return end
    -- if GS.SIR(26297) then GS.Cast(_, 26297, _, _, _, _, "Berserking Troll Racial") return end
    -- if GS.SIR() and GS.PP("deficit") >= 30 then GS.Cast(_, , _, _, _, _, "Arcane Torrent Belf Racial ") return end
    -- if GS.SIR(80483) and GS.PP("deficit") >= 30 then GS.Cast(_, 80483, _, _, _, _, "Arcane Torrent Belf Racial") return end


-- Ace Stuff
    local options = {
        type = "group",
        name = "GStar Rotations Settings",
        args = {
            General = {
                name = "General Settings",
                type = "group",
                order = 1,
                args = {
                    InterruptTrainer = {
                        order = 10,
                        type = "toggle",
                        name = "Interrupt",
                        desc = "Use automatic interrupt?",
                        descStyle = "inline",
                        get = function() return GSR.Interrupt end,
                        set = function(i, v) GS.SaveToGSR("Interrupt", v) end
                    },
                    TauntTrainer = {
                        order = 11,
                        type = "toggle",
                        name = "Taunt",
                        desc = "Use automatic taunt?\n(Set other tank as focus.)",
                        descStyle = "inline",
                        get = function() return GSR.Taunt end,
                        set = function(i,v) GS.SaveToGSR("Taunt", v) end
                    },
                    ThokThrottle = {
                        order = 12,
                        type = "toggle",
                        name = "Thok",
                        desc = "Use automatic stop casting? (Not 100% success rate.)",
                        descStyle = "inline",
                        get = function() return GSR.Thok end,
                        set = function(i,v) GS.SaveToGSR("Thok", v) end
                    },
                    ChaosMode = {
                        order = 13,
                        type = "toggle",
                        name = "Chaos Mode",
                        get = function() return GSR.ChaosMode end,
                        set = function(i,v) GS.SaveToGSR("ChaosMode", v) end
                    },
                    LOS = {
                        order = 13,
                        type = "toggle",
                        name = "LoS",
                        desc = "blargh",
                        get = function() return GSR.LoS end,
                        set = function(i,v) GS.SaveToGSR("LoS", v) end
                    },
                    CC = {
                        order = 13,
                        type = "toggle",
                        name = "Check CC?",
                        get = function() return GSR.CCed end,
                        set = function(i,v) GS.SaveToGSR("CCed", v) end
                    },
                    Dummy = {
                        order = 14,
                        type = "select",
                        name = "Dummy TTD",
                        values = {"Mixed Mode", "Execute", "Healthy"},
                        get = function() return GSR.DummyTTDMode or 1 end,
                        set = function(i,v) GS.SaveToGSR("DummyTTDMode", v) end
                    },
                    Newline2 = {
                        order = 15,
                        type = "header",
                        name = ""
                    },
                    DAMAGING = {
                        order = 16,
                        type = "toggle",
                        name = "DPS",
                        desc = "Enable this if you're using this addon to dps.",
                        descStyle = "inline",
                        get = function() return GSR.Mobs end,
                        set = function(i,v) GS.SaveToGSR("Mobs", v) end
                    },
                    Healing = {
                        order = 17,
                        type = "toggle",
                        name = "Healing",
                        desc = "Enable this if you're using this addon to heal.",
                        descStyle = "inline",
                        get = function() return GSR.Healing end,
                        set = function(i,v) GS.SaveToGSR("Healing", v) end
                    },
                    Newline1 = {
                        order = 18,
                        type ="header",
                        name = ""
                    },
                    PvP = {
                        order = 19,
                        type = "toggle",
                        name = "PvP Toggle",
                        desc = "Enable this if you're using this addon in PvP; if you're using it for PvE then disable this.",
                        descStyle = "inline",
                        get = function() return GSR.PvPMode end,
                        set = function(i,v) GS.SaveToGSR("PvPMode", v) end
                    },
                    RaFLeveling = {
                        order = 20,
                        type = "toggle",
                        name = "Level 90 Leveling",
                        desc = "Enable this if you're using this addon to RaF up to level 90; disable if you're at level 90 and are leveling higher.",
                        descStyle = "inline",
                        get = function() return GSR.LevelingRAF end,
                        set = function(i,v) GS.SaveToGSR("LevelingRAF", v) end
                    },
                    Newline3 = {
                        order = 21,
                        type = "header",
                        name = ""
                    },
                    RunTutorial = {
                        order = 10000,
                        type = "execute",
                        name = "Run Tutorial",
                        func = function() GS.TextBox("tutorial", true) end
                    },
                }
            },
            Paladin = {
                name = "Paladin Settings",
                type = "group",
                order = 2,
                hidden = function() return GSR.Class ~= "PALADIN" end,
                args = {
                    DivineProtection = {
                        order = 111,
                        type = "toggle",
                        name = "Divine Protection Auto Use for Protection",
                        get = function() return GSR.DivineProtection end,
                        set = function(i,v) GS.SaveToGSR("DivineProtection", v) end,
                        hidden = function() return GS.Spec ~= 2 end,
                    },
                    ModeProtection = {
                        order = 112,
                        type = "select",
                        name = "Protection Rotation Mode",
                        values = {"Mixed Mode","Max DPS","Max Survival"},
                        get = function() return GSR.ProtectionPaladinMode or 1 end,
                        set = function(i,v) GS.SaveToGSR("ProtectionPaladinMode", v) end,
                        hidden = function() return GS.Spec ~= 2 end,
                    },
                    ModeHoly = {
                        order = 211,
                        type = "toggle",
                        name = "Beacon Swap",
                        get = function() return GSR.BeaconHolyPaladin end,
                        set = function(i,v) GS.SaveToGSR("BeaconHolyPaladin", v) end
                    },
                    WoGPercent = {
                        order = 212,
                        type = "range",
                        name = "Word of Glory Percent",
                        desc = "Also applies to Eternal Flame",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.WordOfGloryPercent end,
                        set = function(i,v) GS.SaveToGSR("WordOfGloryPercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                    LoDPercent = {
                        order = 213,
                        type = "range",
                        name = "Light of Dawn Percent",
                        min = 0,
                        max = 6,
                        softMin = 1,
                        softMax = 5,
                        get = function() return GSR.LightOfDawnPercent end,
                        set = function(i,v) GS.SaveToGSR("LightOfDawnPercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                    HRPercent = {
                        order = 214,
                        type = "range",
                        name = "Holy Radiance Percent",
                        min = 0,
                        max = 4,
                        softMin = 2,
                        softMax = 3,
                        get = function() return GSR.HolyRadiancePercent end,
                        set = function(i,v) GS.SaveToGSR("HolyRadiancePercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                    FoLPercent = {
                        order = 215,
                        type = "range",
                        name = "Flash of Light Percent",
                        desc = "Target's Percent Health",
                        min = 0,
                        max = 100,
                        softMin = 0,
                        softMax = 50,
                        get = function() return GSR.FlashOfLightPercent end,
                        set = function(i,v) GS.SaveToGSR("FlashOfLightPercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                }
            },
            Warrior = {
                name = "Warrior Settings",
                type = "group",
                order = 3,
                hidden = function() return GSR.Class ~= "WARRIOR" end,
                args = {
                    GladStance = {
                        order = 210,
                        type = "toggle",
                        name = "Gladiator Stance",
                        get = function () return GSR.GladStance end,
                        set = function(i, v) GS.SaveToGSR("GladStance", v) end
                    },
                    Newline1 = {
                        order = 211,
                        type ="header",
                        name = ""
                    },
                }
            },
            Priest = {
                name = "Priest Settings",
                type = "group",
                order = 4,
                hidden = function() return GSR.Class ~= "PRIEST" end,
                args = {
                    DPSorHeal = {
                        order = 1,
                        type = "select",
                        name = "Rotation Mode",
                        values = {"Healing","DPS"},
                        get = function() return GSR.PriestHolyMode or 1 end,
                        set = function(i,v) GS.SaveToGSR("PriestHolyMode", v) end
                    },
                    Newline1 = {
                        order = 2,
                        type = "header",
                        name = ""
                    },
                    Penance = {
                        order = 3,
                        type = "range",
                        name = "Penance Percent",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.PenancePercent end,
                        set = function(i,v) GS.SaveToGSR("PenancePercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                    HolyNova = {
                        order = 3,
                        type = "range",
                        name = "Holy Nova Percent",
                        min = 0,
                        max = 5,
                        softMin = 2.5,
                        softMax = 5,
                        get = function() return GSR.HolyNovaPercent end,
                        set = function(i,v) GS.SaveToGSR("HolyNovaPercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                    CircleOfHealing = {
                        order = 3,
                        type = "range",
                        name = "Circle of Healing Percent",
                        min = 0,
                        max = 5,
                        softMin = 2.5,
                        softMax = 5,
                        get = function() return GSR.CircleOfHealingPercent end,
                        set = function(i,v) GS.SaveToGSR("CircleOfHealingPercent", v) end,
                        hidden = function() return GS.Spec ~= 2 end,
                    },
                    BindingHeal = {
                        order = 3,
                        type = "range",
                        name = "Binding Heal Percent",
                        min = 0,
                        max = 2,
                        softMin = 1,
                        softMax = 2,
                        get = function() return GSR.BindingHealPercent end,
                        set = function(i,v) GS.SaveToGSR("BindingHealPercent", v) end,
                        hidden = function() return GS.Spec ~= 2 end,
                    },
                    PrayerOfHealing = {
                        order = 4,
                        type = "range",
                        name = "Prayer of Healing Percent",
                        min = 0,
                        max = 5,
                        softMin = 2.5,
                        softMax = 5,
                        get = function() return GSR.PrayerOfHealingPercent end,
                        set = function(i,v) GS.SaveToGSR("PrayerOfHealingPercent", v) end,
                    },
                    FlashHealDisc = {
                        order = 5,
                        type = "range",
                        name = "Flash Heal Percent",
                        desc = "Target's Percent Health",
                        min = 0,
                        max = 100,
                        softMin = 0,
                        softMax = 50,
                        get = function() return GSR.DiscFlashHealPercent end,
                        set = function(i,v) GS.SaveToGSR("DiscFlashHealPercent", v) end,
                        hidden = function() return GS.Spec ~= 1 end,
                    },
                    FlashHealHoly = {
                        order = 5,
                        type = "range",
                        name = "Flash Heal Percent",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.HolyFlashHealPercent end,
                        set = function(i,v) GS.SaveToGSR("HolyFlashHealPercent", v) end,
                        hidden = function() return GS.Spec ~= 2 end,
                    },
                    HealHoly = {
                        order = 6,
                        type = "range",
                        name = "Serendipity Heal Percent",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.HolyHealPercent end,
                        set = function(i,v) GS.SaveToGSR("HolyHealPercent", v) end,
                        hidden = function() return GS.Spec ~= 2 end,
                    },
                }
            },
            Warlock = {
                name = "Warlock Settings",
                type = "group",
                order = 2,
                hidden = function() return GSR.Class ~= "WARLOCK" end,
                args = {
                    FocusDrainSoul = {
                        order = 1,
                        type = "toggle",
                        name = "Focus Target Drain Soul",
                        desc = "Focus your target with Drain Soul no matter what",
                        descStyle = "inline",
                        get = function() return GSR.DrainSoulFocus end,
                        set = function(i,v) GS.SaveToGSR("DrainSoulFocus", v) end
                    }
                }
            },
            Druid = {
                name = "Druid Settings",
                type = "group",
                order = 2,
                hidden = function() return GSR.Class ~= "DRUID" end,
                args = {
                    Swiftmend = {
                        order = 1,
                        type = "range",
                        name = "Swiftmend Percent",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.SwiftmendPercent end,
                        set = function(i,v) GS.SaveToGSR("SwiftmendPercent", v) end,
                        hidden = function() return GS.Spec ~= 4 end,
                    },
                    Regrowth = {
                        order = 2,
                        type = "range",
                        name = "Regrowth Percent",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.RegrowthPercent end,
                        set = function(i,v) GS.SaveToGSR("RegrowthPercent", v) end,
                        hidden = function() return GS.Spec ~= 4 end,
                    }
                }
            },
            Shaman = {
                name = "Shaman Settings",
                type = "group",
                order = 2,
                hidden = function() return GSR.Class ~= "SHAMAN" end,
                args = {
                    HealingWave = {
                        order = 1,
                        name = "Healing Wave Percent",
                        type = "range",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.HealingWavePercent end,
                        set = function(i,v) GS.SaveToGSR("HealingWavePercent", v) end,
                        hidden = function() return GS.Spec ~= 3 end,
                    },
                    HealingSurge = {
                        order = 2,
                        name = "Healing Surge Percent",
                        desc = "Target's Health Percent",
                        descStyle = "inline",
                        type = "range",
                        min = 0,
                        max = 100,
                        softMin = 0,
                        softMax = 50,
                        get = function() return GSR.HealingSurgePercent end,
                        set = function(i,v) GS.SaveToGSR("HealingSurgePercent", v) end,
                        hidden = function() return GS.Spec ~= 3 end,
                    },
                    Riptide = {
                        order = 3,
                        name = "Riptide Percent",
                        type = "range",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.RiptidePercent end,
                        set = function(i,v) GS.SaveToGSR("RiptidePercent", v) end,
                        hidden = function() return GS.Spec ~= 3 end,
                    },
                }
            },
            Monk = {
                name = "Monk Settings",
                type = "group",
                order = 2,
                hidden = function() return GSR.Class ~= "MONK" end,
                args = {
                    Effuse = {
                        order = 1,
                        name = "Effuse Percent",
                        type = "range",
                        min = 0,
                        max = 10,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.EffusePercent end,
                        set = function(i,v) GS.SaveToGSR("EffusePercent", v) end,
                        -- hidden = function() return GS.Spec ~= 2 end
                    },
                    EnvelopingMist = {
                        order = 2,
                        name = "Enveloping Mist Percent",
                        type = "range",
                        min = 0,
                        max = 1,
                        softMin = .5,
                        softMax = 1,
                        get = function() return GSR.EnvelopingMistPercent end,
                        set = function(i,v) GS.SaveToGSR("EnvelopingMistPercent", v) end,
                        -- hidden = function() return GS.Spec ~= 2 end
                    },
                    EssenceFont = {
                        order = 4,
                        name = "Essence Font Percent",
                        type = "range",
                        min = 0,
                        max = 6,
                        softMin = 3,
                        softMax = 6,
                        get = function() return GSR.EssenceFontPercent end,
                        set = function(i,v) GS.SaveToGSR("EssenceFontPercent", v) end,
                        -- hidden = function() return GS.Spec ~= 2 end
                    },
                    Vivify = {
                        order = 3,
                        name = "Vivify Percent",
                        type = "range",
                        min = 0,
                        max = 3,
                        softMin = 1.5,
                        softMax = 3,
                        get = function() return GSR.VivifyPercent end,
                        set = function(i,v) GS.SaveToGSR("VivifyPercent", v) end,
                        -- hidden = function() return GS.Spec ~= 2 end
                    },
                },
            },
            Hunter = {
                name = "Hunter Settings",
                type = "group",
                order = 2,
                hidden = function() return GSR.Class ~= "HUNTER" end,
                args = {
                    KillCommandPet = {
                        order = 1,
                        name = "Kill Command Pet's Target",
                        type = "toggle",
                        get = function() return GSR.KillCommandPet end,
                        set = function(i,v) GS.SaveToGSR("KillCommandPet", v) end
                    },
                },
            },
            Debug = {
                name = "Debug Settings",
                type = "group",
                order = 5,
                hidden = function() return GSR.Dev.hide end,
                args = {
                    Log = {
                        order = 1,
                        type = "toggle",
                        name = "Log",
                        get = function() return GSR.Dev.Logging end,
                        set = function(i,v) GSR.Dev.Logging = v end
                    },
                    CastDebug = {
                        order = 2,
                        type = "toggle",
                        name = "Save Cast Information",
                        get = function() return GSR.Dev.CastInformation end,
                        set = function(i,v) GSR.Dev.CastInformation = v end
                    },
                    DevWatch = {
                        order = 3,
                        type = "toggle",
                        name = "Watch for Events",
                        get = function() return GSR.Dev.DevWatch end,
                        set = function(i,v) GSR.Dev.DevWatch = v end
                    },
                    Cache = {
                        order = 4,
                        type = "toggle",
                        name = "Cache Functions",
                        get = function() return GSR.Dev.CachedFunctions end,
                        set = function(i,v) GSR.Dev.CachedFunctions = v end
                    },
                    RaFFollow = {
                        order = 5,
                        type = "toggle",
                        name = "RaF Combat",
                        get = function() return GSR.RaFFollow end,
                        set = function(i,v) GSR.RaFFollow = v end
                    }
                }
            }
        }
    }

    AC:RegisterOptionsTable("GS_Settings", options)

-- Rotations Legion (based off amr for now)