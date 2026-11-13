local ADDON_NAME = "YY_GunSound"

-- ==========================================
-- 1. 다국어(한/영) 브랜드 텍스트 설정
-- ==========================================
local L = {
    TITLE = "|cff00ffcc[YYing]|r GunSound",
    ENABLE = "Enable Custom Gun Sound",
    LOAD_SND = "Play Reload Sound (GunLoad)",
    HIDE_MM = "Hide Minimap Button",
    SELECT_SET = "1. Select Sound Folder (set1 ~ set5):",
    FIRE_VOL = "2. GunFire Volume:",
    LOAD_VOL = "3. GunLoad Volume (Reload):",
    TEST_BTN = "Test Sound",
    FOOTER = "|cff888888Created by YeoYuING (youtube.com/@yying1)|r",
    LOAD_MSG = "|cff00ffcc[YY_GunSound]|r Loaded! Click Minimap button or type |cffffd100/yygun|r.",
    MM_HIDDEN_MSG = "|cff00ffcc[YY_GunSound]|r Minimap button hidden. Type |cffffd100/yygun|r to open options.",
    TT_TITLE = "|cff00ffcc[YYing]|r GunSound",
    TT_LEFT = "|cffffffffLeft-Click:|r Open/Close Options",
    TT_RIGHT = "|cffffffffRight-Click:|r Test Current Sound",
    TT_SRIGHT = "|cffffffffShift + Right-Click:|r Hide Minimap Button",
    TT_DRAG = "|cffffffffDrag:|r Move Minimap Button",
    STATUS_ON = "|cff00ff00Enabled|r",
    STATUS_OFF = "|cffff0000Muted|r"
}

if GetLocale() == "koKR" then
    L.TITLE = "|cff00ffcc[여유잉]|r 총소리 설정"
    L.ENABLE = "커스텀 총소리 켜기 (체크 해제 시 무음)"
    L.LOAD_SND = "장전 소리(GunLoad) 함께 재생"
    L.HIDE_MM = "미니맵 버튼 숨기기 (/yygun 또는 /총소리)"
    L.SELECT_SET = "1. 총소리 테마 폴더 선택 (set1 ~ set5):"
    L.FIRE_VOL = "2. 발사 소리(GunFire) 볼륨 선택:"
    L.LOAD_VOL = "3. 장전 소리(GunLoad) 볼륨 선택:"
    L.TEST_BTN = "현재 설정 소리 테스트"
    L.FOOTER = "|cff888888제작: 여유잉 YeoYuING (youtube.com/@yying1)|r"
    L.LOAD_MSG = "|cff00ffcc[여유잉 총소리]|r 로드 완료! 미니맵 아이콘 클릭 또는 |cffffd100/yygun|r, |cffffd100/총소리|r 를 입력하세요."
    L.MM_HIDDEN_MSG = "|cff00ffcc[여유잉 총소리]|r 미니맵 버튼이 숨겨졌습니다. |cffffd100/yygun|r 또는 |cffffd100/총소리|r 입력 시 열립니다."
    L.TT_TITLE = "|cff00ffcc[여유잉]|r 총소리 설정 (YY_GunSound)"
    L.TT_LEFT = "|cffffffff좌클릭:|r 옵션 창 열기 / 닫기"
    L.TT_RIGHT = "|cffffffff우클릭:|r 현재 총소리 테스트 재생"
    L.TT_SRIGHT = "|cffffffffShift + 우클릭:|r 미니맵 버튼 숨기기"
    L.TT_DRAG = "|cffffffff드래그:|r 미니맵 버튼 위치 이동"
    L.STATUS_ON = "|cff00ff00활성화됨|r"
    L.STATUS_OFF = "|cffff0000무음(꺼짐)|r"
end

-- ==========================================
-- 2. 기본 총소리 음소거 ID 목록 및 초기 설정값
-- ==========================================
local gunSoundIDs = {
    567635, 567636, 567637, 567638, 567639, 567640,
    567653, 567654, 567655, 567656, 567657, 567658,
    567659, 567660, 567661, 567662, 567663, 567664,
    567665, 567666, 567667, 567668, 567669, 567670,
    567671, 567672, 567673, 567674, 567675, 567676,
    567677, 567678, 567679, 567680, 567681, 567682,
    567683, 567715, 567716, 567717, 567718, 567719,
    567720, 567721, 567722, 567723, 567724, 567725,
    567726, 567727, 567728, 567729, 567730, 567731, 567732
}

local defaults = {
    enabled = true,
    enableLoad = true,
    hideMinimap = false,
    soundSet = 1,
    fireVolStep = 100,
    loadVolStep = 75,
    minimapPos = 225
}

local optionsFrame
local minimapBtn
local cbHideMM

local function UpdateMinimapVisibility()
    if minimapBtn then
        if YY_GunSoundDB.hideMinimap then minimapBtn:Hide() else minimapBtn:Show() end
    end
    if cbHideMM then cbHideMM:SetChecked(YY_GunSoundDB.hideMinimap) end
end

-- ==========================================
-- 3. 4단계 볼륨별 WAV 재생 함수
-- ==========================================
local lastFireTime = 0
local lastLoadTime = 0

local function PlayCustomLoad()
    if not YY_GunSoundDB.enabled or not YY_GunSoundDB.enableLoad then return end
    local now = GetTime()
    if now - lastLoadTime > 0.2 then
        lastLoadTime = now
        local rand = math.random(1, 3)
        local setFolder = "set" .. (YY_GunSoundDB.soundSet or 1)
        local vol = YY_GunSoundDB.loadVolStep or 75
        local path = "Interface\\AddOns\\" .. ADDON_NAME .. "\\" .. setFolder .. "\\GunLoad0" .. rand .. "_" .. vol .. ".wav"
        PlaySoundFile(path, "Master")
    end
end

local function PlayCustomFire()
    if not YY_GunSoundDB.enabled then return end
    local now = GetTime()
    if now - lastFireTime > 0.15 then
        lastFireTime = now
        local rand = math.random(1, 3)
        local setFolder = "set" .. (YY_GunSoundDB.soundSet or 1)
        local vol = YY_GunSoundDB.fireVolStep or 100
        local path = "Interface\\AddOns\\" .. ADDON_NAME .. "\\" .. setFolder .. "\\GunFire0" .. rand .. "_" .. vol .. ".wav"
        PlaySoundFile(path, "Master")
        
        if YY_GunSoundDB.enableLoad then
            C_Timer.After(0.35, function()
                PlayCustomLoad()
            end)
        end
    end
end

-- ==========================================
-- 4. 옵션 창 UI (/yygun, /총소리)
-- ==========================================
local function ToggleOptionsGUI()
    if not optionsFrame then
        local f = CreateFrame("Frame", "YY_GunSoundOptionsFrame", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(310, 360)
        f:SetPoint("CENTER")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:Hide()

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("LEFT", f.TitleBg, "LEFT", 10, 0)
        f.title:SetText(L.TITLE)

        local cbEnable = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        cbEnable:SetPoint("TOPLEFT", 20, -35)
        cbEnable.text:SetText(L.ENABLE)
        cbEnable:SetChecked(YY_GunSoundDB.enabled)
        cbEnable:SetScript("OnClick", function(self) YY_GunSoundDB.enabled = self:GetChecked() end)

        local cbLoad = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        cbLoad:SetPoint("TOPLEFT", 20, -63)
        cbLoad.text:SetText(L.LOAD_SND)
        cbLoad:SetChecked(YY_GunSoundDB.enableLoad)
        cbLoad:SetScript("OnClick", function(self) YY_GunSoundDB.enableLoad = self:GetChecked() end)

        cbHideMM = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        cbHideMM:SetPoint("TOPLEFT", 20, -91)
        cbHideMM.text:SetText(L.HIDE_MM)
        cbHideMM:SetChecked(YY_GunSoundDB.hideMinimap)
        cbHideMM:SetScript("OnClick", function(self)
            YY_GunSoundDB.hideMinimap = self:GetChecked()
            UpdateMinimapVisibility()
        end)

        -- [1] 폴더 선택 버튼 (set1 ~ set5)
        local setLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        setLabel:SetPoint("TOPLEFT", 22, -128)
        setLabel:SetText(L.SELECT_SET)

        local setBtns = {}
        for i = 1, 5 do
            local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            btn:SetSize(50, 25)
            btn:SetPoint("TOPLEFT", 20 + (i-1)*54, -146)
            btn:SetText("Set " .. i)
            btn:SetScript("OnClick", function()
                YY_GunSoundDB.soundSet = i
                for _, b in ipairs(setBtns) do b:Enable() end
                btn:Disable()
                lastFireTime = 0
                PlayCustomFire()
            end)
            if YY_GunSoundDB.soundSet == i then btn:Disable() end
            table.insert(setBtns, btn)
        end

        local volSteps = {25, 50, 75, 100}

        -- [2] 발사 소리 볼륨 선택 버튼
        local fireLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fireLabel:SetPoint("TOPLEFT", 22, -184)
        fireLabel:SetText(L.FIRE_VOL)

        local fireBtns = {}
        for i, v in ipairs(volSteps) do
            local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            btn:SetSize(64, 25)
            btn:SetPoint("TOPLEFT", 20 + (i-1)*68, -202)
            btn:SetText(v .. "%")
            btn:SetScript("OnClick", function()
                YY_GunSoundDB.fireVolStep = v
                for _, b in ipairs(fireBtns) do b:Enable() end
                btn:Disable()
                lastFireTime = 0
                PlayCustomFire()
            end)
            if YY_GunSoundDB.fireVolStep == v then btn:Disable() end
            table.insert(fireBtns, btn)
        end

        -- [3] 장전 소리 볼륨 선택 버튼
        local loadLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        loadLabel:SetPoint("TOPLEFT", 22, -240)
        loadLabel:SetText(L.LOAD_VOL)

        local loadBtns = {}
        for i, v in ipairs(volSteps) do
            local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            btn:SetSize(64, 25)
            btn:SetPoint("TOPLEFT", 20 + (i-1)*68, -258)
            btn:SetText(v .. "%")
            btn:SetScript("OnClick", function()
                YY_GunSoundDB.loadVolStep = v
                for _, b in ipairs(loadBtns) do b:Enable() end
                btn:Disable()
                lastLoadTime = 0
                PlayCustomLoad()
            end)
            if YY_GunSoundDB.loadVolStep == v then btn:Disable() end
            table.insert(loadBtns, btn)
        end

        -- 테스트 버튼
        local testBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        testBtn:SetSize(160, 26)
        testBtn:SetPoint("BOTTOM", 0, 32)
        testBtn:SetText(L.TEST_BTN)
        testBtn:SetScript("OnClick", function()
            lastFireTime = 0
            PlayCustomFire()
        end)

        -- 하단 여유잉 채널 워터마크
        local footer = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        footer:SetPoint("BOTTOM", 0, 12)
        footer:SetText(L.FOOTER)

        optionsFrame = f
    end

    if optionsFrame:IsShown() then
        optionsFrame:Hide()
    else
        UpdateMinimapVisibility()
        optionsFrame:Show()
    end
end

-- 슬래시 명령어 (/yygun, /여유잉, /총소리, /mgs 모두 호환)
SLASH_YYGUNSOUND1 = "/yygun"
SLASH_YYGUNSOUND2 = "/여유잉"
SLASH_YYGUNSOUND3 = "/총소리"
SLASH_YYGUNSOUND4 = "/mgs"
SlashCmdList["YYGUNSOUND"] = ToggleOptionsGUI

-- ==========================================
-- 5. 미니맵 버튼 생성 및 드래그 회전 로직
-- ==========================================
local function CreateMinimapButton()
    if minimapBtn then return end

    local btn = CreateFrame("Button", "YY_GunSoundMinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\Ability_Hunter_SniperShot")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    btn.icon = icon

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, 0)

    local function UpdatePosition()
        local angle = math.rad(YY_GunSoundDB.minimapPos or 225)
        local x = math.cos(angle) * 100
        local y = math.sin(angle) * 100
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            YY_GunSoundDB.minimapPos = math.deg(math.atan2(py - my, px - mx)) % 360
            UpdatePosition()
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            ToggleOptionsGUI()
        elseif button == "RightButton" then
            if IsShiftKeyDown() then
                YY_GunSoundDB.hideMinimap = true
                UpdateMinimapVisibility()
                print(L.MM_HIDDEN_MSG)
            else
                lastFireTime = 0
                PlayCustomFire()
            end
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(L.TT_TITLE)
        local status = YY_GunSoundDB.enabled and L.STATUS_ON or L.STATUS_OFF
        GameTooltip:AddLine("Status: " .. status .. " (|cffffd100Set " .. (YY_GunSoundDB.soundSet or 1) .. "|r)")
        GameTooltip:AddLine("Fire: |cff00ff00" .. (YY_GunSoundDB.fireVolStep or 100) .. "%|r / Load: |cff00ff00" .. (YY_GunSoundDB.loadVolStep or 75) .. "%|r")
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.TT_LEFT)
        GameTooltip:AddLine(L.TT_RIGHT)
        GameTooltip:AddLine(L.TT_SRIGHT)
        GameTooltip:AddLine(L.TT_DRAG)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    UpdatePosition()
    minimapBtn = btn
    UpdateMinimapVisibility()
end

-- ==========================================
-- 6. 사격 이벤트 감지 및 초기화
-- ==========================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

eventFrame:SetScript("OnEvent", function(self, event, arg1, _, spellID)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        if not YY_GunSoundDB then YY_GunSoundDB = {} end
        for k, v in pairs(defaults) do
            if YY_GunSoundDB[k] == nil then YY_GunSoundDB[k] = v end
        end
        CreateMinimapButton()
    elseif event == "PLAYER_ENTERING_WORLD" then
        for _, id in ipairs(gunSoundIDs) do MuteSoundFile(id) end
        print(L.LOAD_MSG)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif arg1 == "player" then
        if event == "UNIT_SPELLCAST_START" then
            PlayCustomLoad()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            if spellID == 75 or
               spellID == 19434 or spellID == 20900 or spellID == 20901 or spellID == 20902 or spellID == 20903 or spellID == 20904 or
               spellID == 2643 or spellID == 14288 or spellID == 14289 or spellID == 14290 or spellID == 25294 or
               spellID == 3044 or spellID == 14281 or spellID == 14282 or spellID == 14283 or spellID == 14284 or spellID == 14285 or spellID == 14286 or spellID == 14287 or
               spellID == 1978 or spellID == 13549 or spellID == 13550 or spellID == 13551 or spellID == 13552 or spellID == 13553 or spellID == 13554 or spellID == 13555 or spellID == 25295 or
               spellID == 5116 or spellID == 19503 or spellID == 20736 or spellID == 19801 or
               spellID == 3034 or spellID == 14275 or spellID == 14276 or spellID == 14277 or spellID == 3043 then
                PlayCustomFire()
            end
        end
    end
end)