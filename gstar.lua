-- AceConfig, AceGUI = LibStub("AceConfig-3.0"), LibStub("AceGUI-3.0")
local AC, ACD = LibStub("AceConfig-3.0"), LibStub("AceConfigDialog-3.0")

local GS = {}
GSD = {}
local _ = nil

-- Main Stuff
    GS.PreventExecution = false
    GS.SpellThrottle = 0
    GS.WaitForCombatLog = false

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

        if GSR.LevelingRAF and GS.Spec and GSR.Class and GS[GSR.Class..GS.Spec.."90"] then
            GS.RotationCacheCounter = GS.RotationCacheCounter + 1
            GS[GSR.Class..GS.Spec.."90"]()
            return
        elseif GS.Spec and GSR.Class and GS[GSR.Class..GS.Spec] then
            GS.RotationCacheCounter = GS.RotationCacheCounter + 1
            GS[GSR.Class..GS.Spec]()
            return
        elseif not GS.Spec and GSR.Class and GS[GSR.Class] then
            GS.RotationCacheCounter = GS.RotationCacheCounter + 1
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
        GS.DebugTable = {}
        -- debugStack = "", pointer = 0, nameOfTarget = "", ogSpell = 0, Spell = "", x = 0, y = 0, z = 0, interrupt = "", time = 0, timeSinceLast = 0, reason = ""

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
            GSMonitorTexture:SetTexture("Interface\\Textures\\GStarMonitor.tga") -- GetFireHackDirectory().."\\Scripts\\GStar Rotations\\GStarMonitor.tga"
            GSMonitorTexture:SetAllPoints(GSMonitorParentFrame)

            GSAoEOnTexture = GSMonitorParentFrame:CreateTexture("GSAoEOnTexture")
            GSAoEOffTexture = GSMonitorParentFrame:CreateTexture("GSAoEOffTexture")
            GSAoEOnTexture:SetTexture("Interface\\Textures\\eyes.tga")
            GSAoEOffTexture:SetTexture("Interface\\Textures\\no.tga")

            GSAoEOnTexture:SetPoint("RIGHT", -10, 3)
            GSAoEOnTexture:SetSize(20, 20)
            GSAoEOffTexture:SetPoint("RIGHT", -10, 3)
            GSAoEOffTexture:SetSize(20, 20)

            GSCDsOnTexture = GSMonitorParentFrame:CreateTexture("GSCDsOnTexture")
            GSCDsOffTexture = GSMonitorParentFrame:CreateTexture("GSCDsOffTexture")
            GSCDsOnTexture:SetTexture("Interface\\Textures\\eyes.tga")
            GSCDsOffTexture:SetTexture("Interface\\Textures\\no.tga")

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
                -- for k,v in pairs(GS) do
                --     GSD[k] = v
                -- end
                -- return true
                return GS
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
    GS.RotationCacheCounter = 0
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
    -- todo: populate with boss IDs
    GS.BossList = {}
    -- todo: should healing/tanking/instance dummies be under this?
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
        "Blade Dancer Illianna",
    }

    GS.SpellData = {
        AffectedByHaste = {Key = {}, Value = {}, Size = 19},
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
        GS.SpellData.AffectedByHaste.Key[1] = 20473 -- Holy Shock
        GS.SpellData.AffectedByHaste.Key[2] = 20271 -- Judgment
        GS.SpellData.AffectedByHaste.Key[3] = 35395 -- CS
        GS.SpellData.AffectedByHaste.Key[4] = 53595 -- HotR
        GS.SpellData.AffectedByHaste.Key[5] = 26573 -- Consecration
        GS.SpellData.AffectedByHaste.Key[6] = 119072 -- Holy Wrath
        GS.SpellData.AffectedByHaste.Key[7] = 31935 -- Avenger's Shield
        GS.SpellData.AffectedByHaste.Key[8] = 53600 -- SotR
        GS.SpellData.AffectedByHaste.Key[9] = 879 -- Exorcism
        GS.SpellData.AffectedByHaste.Key[10] = 122032 -- Exorcism
        GS.SpellData.AffectedByHaste.Key[11] = 24275 -- Hammer of Wrath
            GS.SpellData.AffectedByHaste.Value[1] = 6
            GS.SpellData.AffectedByHaste.Value[2] = 6
            GS.SpellData.AffectedByHaste.Value[3] = 4.5
            GS.SpellData.AffectedByHaste.Value[4] = 4.5
            GS.SpellData.AffectedByHaste.Value[5] = 9
            GS.SpellData.AffectedByHaste.Value[6] = 15
            GS.SpellData.AffectedByHaste.Value[7] = 15
            GS.SpellData.AffectedByHaste.Value[8] = 1.5
            GS.SpellData.AffectedByHaste.Value[9] = 15
            GS.SpellData.AffectedByHaste.Value[10] = 15
            GS.SpellData.AffectedByHaste.Value[11] = 6

    -- Shaman
        GS.SpellData.AffectedByHaste.Key[12] = 17364 -- Stormstrike
        GS.SpellData.AffectedByHaste.Key[13] = 115356 -- Windstrike
        GS.SpellData.AffectedByHaste.Key[14] = 60103 -- Lava Lash
        GS.SpellData.AffectedByHaste.Key[15] = 8050 -- Flame Shock
        GS.SpellData.AffectedByHaste.Key[16] = 8056 -- Frost Shock
        GS.SpellData.AffectedByHaste.Key[17] = 8042 -- Earth Shock
        GS.SpellData.AffectedByHaste.Key[18] = 73680 -- Unleash Elements
        GS.SpellData.AffectedByHaste.Key[19] = 1535 -- Fire Nova
            GS.SpellData.AffectedByHaste.Value[12] = 7.5
            GS.SpellData.AffectedByHaste.Value[13] = 7.5
            GS.SpellData.AffectedByHaste.Value[14] = 10.5
            GS.SpellData.AffectedByHaste.Value[15] = 6
            GS.SpellData.AffectedByHaste.Value[16] = 6
            GS.SpellData.AffectedByHaste.Value[17] = 6
            GS.SpellData.AffectedByHaste.Value[18] = 15
            GS.SpellData.AffectedByHaste.Value[19] = 4.5

    GS.Warrior = {}
    GS.Paladin = {
    }
    GS.Rogue = {
    }
    GS.Priest = {
        Voidform = {},
        ApparitionsInFlight = 0
    }
    GS.Monk = {
        LastCast = 0,
        SoothingMistTarget = 0,
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
        GS.RotationCacheCounter = GS.RotationCacheCounter + 1
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
            -- identical
            return
        elseif registeredEvent == "PLAYER_REGEN_ENABLED" then
            -- GS.Monk.LastCast = 0
            return
        elseif registeredEvent == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timeNow = GetTime()
            local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, failedType = ...

            -- if event == "UNIT_DIED" then
            -- throttled projectile disjointed due to unit death goes in here
            -- end

            if sourceName ~= UnitName("player") and not tContains(GS.MobsThatInterrupt, sourceName) then return end

            if event == "SPELL_CAST_START" then  -- MobsThatInterrupt functionality would go in here + healing and projectile throttles
                return
            end
            if event == "SPELL_CAST_FAILED" then
                if failedType ~= "Another action is in progress" and failedType ~= "Not yet recovered" and failedType ~= "You can't do that yet" then
                    GS.SpellThrottle = 0
                    -- GS.LastTargetCast = nil
                    GS.Log(spellName..": Unthrottling "..failedType)
                end

                return
            end
            if event == "SPELL_CAST_SUCCESS" then 
                if GS.WaitForCombatLog then GS.WaitForCombatLog = false end
                
                if spellID ~= 147193 then -- Ghosts shadow priests
                    GS.SpellThrottle = (GetTime()+math.random(20, 60)*.001)+GS.SpellCDDuration(61304)
                end

                -- Priest
                    if spellID == 147193 and GS.Talent52 then
                        GS.Priest.ApparitionsInFlight = GS.Priest.ApparitionsInFlight + 1
                        return
                    end

                -- Monk
                    if spellID == 115175 then
                        GS.Monk.SoothingMistTarget = destGUID
                        return
                    end

                    if GSR.Class == "MONK" and GS.Spec == 3 and tContains(GS.Monk.HitComboTable, spellID) then
                        GS.Monk.LastCast = spellID
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
        for i = 1, allyTargetsSize do
         unitPlaceholder = GS.AllyTargets[i].Player
         if not GSR.Healing or not ObjectExists(unitPlaceholder) or not UnitExists(unitPlaceholder) or GS.Health(unitPlaceholder) == 0 or UnitName(unitPlaceholder) == "Unknown" then _G["removeAllyTargets"..i] = true end
        end
        for i = allyTargetsSize, 1, -1 do
         if _G["removeAllyTargets"..i] then
             table.remove(GS.AllyTargets, i)
             _G["removeAllyTargets"..i] = false
         end
        end

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
        SIR = {RotationCacheCounter = 0},
        SCA = {RotationCacheCounter = 0},
        SpellIsUsable = {RotationCacheCounter = 0},
        SpellIsUsableExecute = {RotationCacheCounter = 0},
        SpellCDDuration = {RotationCacheCounter = 0},
        PoolCheck = {RotationCacheCounter = 0},
        InRange = {RotationCacheCounter = 0},
        InRangeNew = {RotationCacheCounter = 0},
        FracCalc = {RotationCacheCounter = 0},
        GCD = {RotationCacheCounter = 0},
        IsCAOCH = {RotationCacheCounter = 0},
        IsCA = {RotationCacheCounter = 0},
        IsCH = {RotationCacheCounter = 0},
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

        GS.MobTargetsAurasToIgnore = {
            "Arcane Protection",
            "Water Bubble",
        }
        function GS.MobTargetsAuraBlacklist(object)
            local auraToCheck = nil
            for i = 1, #GS.MobTargetsAurasToIgnore do
                auraToCheck = GS.MobTargetsAurasToIgnore[i]
                if GS.Aura(object, auraToCheck) then return false end
            end
            return true
        end

        GS.AllyTargetsAurasToIgnore = {
            
        }
        function GS.AllyTargetsAuraBlacklist(object)
            local auraToCheck = nil
            for i = 1, #GS.AllyTargetsAurasToIgnore do
                auraToCheck = GS.AllyTargetsAurasToIgnore[i]
                if GS.Aura(object, auraToCheck) then return false end
            end
            return true
        end

    -- Gear Functions

    -- Sorting Functions
        function GS.SortMobTargetsByLowestHealth(a,b)
            return not GS.MobTargetsAuraBlacklist(a) and false or not GS.MobTargetsAuraBlacklist(b) and true or GS.Health(a) < GS.Health(b)
        end

        function GS.SortMobTargetsByHighestTTD(a,b)
            return GS.GetTTD(a) == math.huge and false or GS.GetTTD(b) == math.huge and true or GS.GetTTD(a) > GS.GetTTD(b)
        end

        function GS.SortMobTargetsByLowestTTD(a,b)
            return GS.GetTTD(a) < GS.GetTTD(b)
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
            if GSR.Dev.CachedFunctions and GS.SavedReturns.IsCAOCH.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.IsCAOCH[GS.RotationCacheCounter..unitPointer] then return GS.SavedReturns.IsCAOCH[GS.RotationCacheCounter..unitPointer] end
            end
            if ObjectExists(unit) and UnitExists(unit) and (UnitCastingInfo(unit) or UnitChannelInfo(unit)) then GS.SavedReturns.IsCAOCH[GS.RotationCacheCounter..unitPointer] = true return true else GS.SavedReturns.IsCAOCH[GS.RotationCacheCounter..unitPointer] = false return false end
        end

        function GS.IsCA(unit)
            if not unit then unit = "player" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.IsCA.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.IsCA[GS.RotationCacheCounter..unitPointer] then return GS.SavedReturns.IsCA[GS.RotationCacheCounter..unitPointer] end
            end
            if ObjectExists(unit) and UnitExists(unit) and UnitCastingInfo(unit) then GS.SavedReturns.IsCA[GS.RotationCacheCounter..unitPointer] = true return true else GS.SavedReturns.IsCA[GS.RotationCacheCounter..unitPointer] = false return false end
        end

        function GS.IsCH(unit)
            if not unit then unit = "player" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.IsCH.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.IsCH[GS.RotationCacheCounter..unitPointer] then return GS.SavedReturns.IsCH[GS.RotationCacheCounter..unitPointer] end
            end
            if ObjectExists(unit) and UnitExists(unit) and UnitChannelInfo(unit) then GS.SavedReturns.IsCH[GS.RotationCacheCounter..unitPointer] = true return true else GS.SavedReturns.IsCH[GS.RotationCacheCounter..unitPointer] = false return false end
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

        function GS.UnitIsBoss(unit) -- checks the defined boss list
            if not unit then unit = "target" end
            if ObjectExists(unit) and UnitExists(unit) then
                if tContains(GS.BossList, GS.GetUnitID(unit)) then
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
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SpellCDDuration.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString] then return GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString] end
            end
            local start, duration = GetSpellCooldown(spell)
            if max then
                for i = 1, GS.SpellData.AffectedByHaste.Size do
                    if GS.SpellData.AffectedByHaste.Key[i] == spell then return GS.SpellData.AffectedByHaste.Value[i]/(1+GetHaste()*.01) end
                end
                GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString] = GetSpellBaseCooldown(spell)*.001
                return GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString]
            elseif start == 0 then
                GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString] = 0
                return 0
            else
                GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString] = (start + duration - GetTime())
                return GS.SavedReturns.SpellCDDuration[GS.RotationCacheCounter..spell..maxString]
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
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SIR.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.SIR[GS.RotationCacheCounter..spell..executeString] then return GS.SavedReturns.SIR[GS.RotationCacheCounter..spell..executeString] end
            end
            if type(spell) ~= "string" and type(spell) ~= "number" then return false end
            local spellTransform = 0; if GS.SpellKnownTransformTable[spell] then spellTransform = GS.SpellKnownTransformTable[spell] end
            if not (type(spellTransform ~= 0 and spellTransform or spell) == "number" and GetSpellInfo(GetSpellInfo(spellTransform ~= 0 and spellTransform or spell)) or type(spellTransform ~= 0 and spellTransform or spell) == "string" and GetSpellLink(spellTransform ~= 0 and spellTransform or spell) or IsSpellKnown(spellTransform ~= 0 and spellTransform or spell)) then
                if not GS.SpellNotKnown[spellTransform ~= 0 and spellTransform or spell] then
                    GS.SpellNotKnown[spellTransform ~= 0 and spellTransform or spell] = true
                    GS.Log("Spell not known: "..(spellTransform ~= 0 and spellTransform or spell).." Please Verify.")
                end
                GS.SavedReturns.SIR[GS.RotationCacheCounter..spell..executeString] = false
                return false
            end
            -- if (type(spell) == "number" and GetSpellInfo(GetSpellInfo(spell)) or type(spell) == "string" and GetSpellLink(spell) or IsSpellKnown(spell) or spell == 77758 --[[or UnitLevel("player") == 100]]) -- thrash bear
            --[[and]] --[[if]]if GS.SpellCDDuration(spell) <= 0
            and (execute and GS.SpellIsUsableExecute(spell) or GS.SpellIsUsable(spell))
            and (not GSR.Thok or GS.ThokThrottle < GetTime() or select(4, GetSpellInfo(spell)) <= 0 or GS.ThokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001)) -- bottom aurar are ice floes , Kil'jaedens cunning, spiritwalker's grace
            and (UnitMovementFlags("player") == 0 or select(4, GetSpellInfo(spell)) <= 0 or spell == 77767 or spell == 56641 or spell == aimed_shot or spell == 2948 or not GS.AuraRemaining("player", 108839, (select(4, GetSpellInfo(spell))*0.001)) or not GS.AuraRemaining("player", 79206, (select(4, GetSpellInfo(spell))*0.001)))
            -- Ice Floes, SpiritWalker's Grace
            then
                GS.SavedReturns.SIR[GS.RotationCacheCounter..spell..executeString] = true
                return true
            else
                GS.SavedReturns.SIR[GS.RotationCacheCounter..spell..executeString] = false
                return false
            end
        end

        function GS.SCA(spell, unit, casting, execute)
            local castingString, executeString = tostring(casting), tostring(execute)
            if not unit then unit = "target" end
            if not ObjectExists(unit) then return false end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SCA.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.SCA[GS.RotationCacheCounter..spell..unitPointer..castingString..executeString] then return GS.SavedReturns.SCA[GS.RotationCacheCounter..spell..unitPointer..castingString..executeString] end
            end
            if tContains(GS.DoTThrottleList, spell) and unit == GS.DoTThrottle then GS.SavedReturns.SCA[GS.RotationCacheCounter..spell..unitPointer..castingString..executeString] = false return false end
            if string.sub(unit, 1, 6) == "Player" then unit = ObjectPointer("player") end
            if UnitExists(unit)
            and GS.SIR(spell, execute)
            and (GS.InRange(spell, unit) or UnitName(unit) == "Al'Akir") -- fixme: inrange needs an overhaul in the distant future, example Al'Akir @framework @notimportant
            and (not GS.IsCAOCH("player") or casting--[[ and UnitChannelInfo("player") ~= GetSpellInfo(spell) and UnitCastingInfo("player") ~= GetSpellInfo(spell)]])
            and (not GSR.Thok or GS.ThokThrottle < GetTime() or GS.ThokThrottle > GetTime()+(select(4, GetSpellInfo(spell))*0.001))
            and (not GSR.LoS or GS.LOS(unit)) -- fixme: LOS @framework
            and (not GSR.CCed or not GS.UnitIsCCed(unit))
            then
                GS.SavedReturns.SCA[GS.RotationCacheCounter..spell..unitPointer..castingString..executeString] = true
                return true
            else
                GS.SavedReturns.SCA[GS.RotationCacheCounter..spell..unitPointer..castingString..executeString] = false
                return false
            end
        end

        function GS.SpellIsUsable(spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SpellIsUsable.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.SpellIsUsable[GS.RotationCacheCounter..spell] then return GS.SavedReturns.SpellIsUsable[GS.RotationCacheCounter..spell] end
            end
            local isUsable, notEnoughMana = IsUsableSpell(spell)
            if isUsable and not notEnoughMana then
                GS.SavedReturns.SpellIsUsable[GS.RotationCacheCounter..spell] = true
                return true
            else
                GS.SavedReturns.SpellIsUsable[GS.RotationCacheCounter..spell] = false
                return false
            end
        end

        function GS.SpellIsUsableExecute(spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.SpellIsUsableExecute.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.SpellIsUsableExecute[GS.RotationCacheCounter..spell] then return GS.SavedReturns.SpellIsUsableExecute[GS.RotationCacheCounter..spell] end
            end
            local isUsable, notEnoughMana = IsUsableSpell(spell)
            if not notEnoughMana then
                GS.SavedReturns.SpellIsUsableExecute[GS.RotationCacheCounter..spell] = true
                return true
            else
                GS.SavedReturns.SpellIsUsableExecute[GS.RotationCacheCounter..spell] = false
                return false
            end
        end

        function GS.PoolCheck(spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.PoolCheck.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.PoolCheck[GS.RotationCacheCounter..spell] then return GS.SavedReturns.PoolCheck[GS.RotationCacheCounter..spell] end
            end
            local isUsable, notEnoughMana = IsUsableSpell(spell)
            if GS.SpellCDDuration(spell) <= 0
            and not isUsable
            and notEnoughMana
            then
                GS.SavedReturns.PoolCheck[GS.RotationCacheCounter..spell] = true
                return true
            else
                GS.SavedReturns.PoolCheck[GS.RotationCacheCounter..spell] = false
                return false
            end
        end

        function GS.InRangeNew(spell, unit)
            if not unit then unit = "target" end
            local unitPointer = ObjectPointer(unit)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.InRangeNew.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.InRangeNew[GS.RotationCacheCounter..spell..unitPointer] then return GS.SavedReturns.InRangeNew[GS.RotationCacheCounter..spell..unitPointer] end
            end
            local spellToString
            -- if tonumber(spell) then spellToString = GetSpellInfo(spell) end
            local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spell)
            if ObjectExists(unit) and UnitExists(unit) and GS.Health(unit) > 0 then
                if maxRange <= 5 then -- Melee Attack
                    local combatReach = UnitCombatReach("player")+UnitCombatReach("target")
                    local movingBenefit = 0
                    -- local movingBenefit = (UnitMovementFlags("player") > 0 and UnitMovementFlags("target") > 0 and (8/3) or 0)
                    GS.SavedReturns.InRangeNew[GS.RotationCacheCounter..spell..unitPointer] = (GS.Distance("target") < ((5 > (combatReach+4/3) and 5 or combatReach+4/3) + movingBenefit))
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
            if GSR.Dev.CachedFunctions and GS.SavedReturns.InRange.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] then return GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] end
            end
            local spellToString

            if tonumber(spell) then spellToString = GetSpellInfo(spell) end

            if ObjectExists(unit) and UnitExists(unit) and GS.Health(unit) > 0 then
                local inRange = IsSpellInRange(spellToString, unit)

                if inRange == 1 then
                    GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] = true
                    return true
                elseif inRange == 0 then
                    if not GS.SpellOutranged[spell] then
                        GS.SpellOutranged[spell] = true
                        GS.Log("Spell out of Range: "..spell.." Please Verify.")
                    end
                    GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] = false
                    return false
                elseif (tContains(GS.SpellData.SpellNameRange, spellToString) or tContains(GS.SpellData.SpellNameRange, "MM"..spellToString)) then
                    for i = 1, #GS.SpellData.SpellNameRange do
                        if GS.SpellData.SpellNameRange[i] == spellToString then
                            GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] = (GS.Distance(unit) <= GS.SpellData.SpellRange[i])
                            return GS.Distance(unit) <= GS.SpellData.SpellRange[i]
                        elseif GS.SpellData.SpellNameRange[i] == "MM"..spellToString then
                            GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] = (GS.Distance(unit) <= (GS.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100)))
                            return GS.Distance(unit) <= (GS.SpellData.SpellRange[i]*(1+GetMasteryEffect()/100))
                        end
                    end
                -- elseif FindSpellBookSlotBySpellID(spell) then
                --     return IsSpellInRange(FindSpellBookSlotBySpellID(spell), "spell", unit) == 1
                else
                    for i = 1, 200 do
                        if GetSpellBookItemName(i, "spell") == spellToString then
                            if IsSpellInRange(i, "spell", unit) == 1 then
                                GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] = true
                                return true
                            else
                                if not GS.SpellOutranged[spell] then
                                    GS.SpellOutranged[spell] = true
                                    GS.Log("Spell out of Range: "..spell.." Please Verify.")
                                end
                                GS.SavedReturns.InRange[GS.RotationCacheCounter..spell..unitPointer] = false
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

        function GS.FracCalc(mode, spell)
            if GSR.Dev.CachedFunctions and GS.SavedReturns.FracCalc.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.FracCalc[GS.RotationCacheCounter..mode..spell] then return GS.SavedReturns.FracCalc[GS.RotationCacheCounter..mode..spell] end
            end
            if mode == "spell" then
                local spellFrac = 0
                local cur, max, start, duration = GetSpellCharges(spell)

                if cur then
                    if cur >= 1 then spellFrac = spellFrac + cur end
                    if spellFrac == max then return spellFrac end
                    spellFrac = spellFrac + (GetTime()-start)/duration
                    GS.SavedReturns.FracCalc[GS.RotationCacheCounter..mode..spell] = spellFrac
                    return spellFrac
                else
                    -- local start, duration = GetSpellCooldown(spell)
                    -- if start == 0 then return 1 end
                    -- spellFrac = (GetTime()-start)/duration
                    -- GS.SavedReturns.FracCalc[GS.RotationCacheCounter..mode..spell] = spellFrac
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

        function GS.HealingAmount(spell)
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
            if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) elseif mode == "tomax" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower))/GetPowerRegen() else return UnitPower("player", vPower) end
        end

        function GS.CP(mode) -- Returns Chi and Combo Points, modes are max or deficit otherwise current, for Primary Resources Use GS.PP(mode)
            local vPower = (GSR.Class == "MONK" and 12 or 4)
            if mode == "max" then return UnitPowerMax("player", vPower) elseif mode == "deficit" then return (UnitPowerMax("player", vPower)-UnitPower("player", vPower)) else return UnitPower("player", vPower) end
        end

        function GS.GCD()
            if GSR.Class..GS.Spec == "MONK3" then return 1 end
            if GSR.Dev.CachedFunctions and GS.SavedReturns.GCD.RotationCacheCounter == GS.RotationCacheCounter then
                if GS.SavedReturns.GCD[GS.RotationCacheCounter.."Result"] then return GS.SavedReturns.GCD[GS.RotationCacheCounter.."Result"] end
            end
            GS.SavedReturns.GCD[GS.RotationCacheCounter.."Result"] = math.max((1.5/(1+GetHaste()*.01)), 0.75)
            return math.max((1.5/(1+GetHaste()*.01)), 0.75)
        end

        function GS.SimCSpellHaste()
            return 1/(1+GetHaste()*.01)
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
                GS.DebugTable["RotationCacheCounter"] = GS.RotationCacheCounter
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

        function GS.Interrupt() -- todo: implement
        end

    -- Class Functions
        -- Monk
            do
                GS.Monk.HitComboTable = {
                    100784, -- Blackout Kick
                    117952, -- Crackling Jade Lightning
                    113656, -- Fists of Fury
                    101545, -- Flying Serpent Kick
                    107428, -- Rising Sun Kick
                    101546, -- Spinning Crane Kick
                    100780, -- Tiger Palm
                    115080, -- Touch of Death

                    123986, -- Chi Burst
                    115098, -- Chi Wave
                    116847, -- Rushing Jade Wind
                    152175, -- Whirling Dragon Punch
                }
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
            GS.CacheTalents()

            if GSR.Class and not GSD.Class then
                LoadScript("GStar Rotations\\gs"..GSR.Class..".lua")
                GSD.Class = true
            end
        end
    end

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
                        max = 10,
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