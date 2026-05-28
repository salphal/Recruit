local AddonName, ADDONSELF = ...

local pt                   = print
local GetAddOnMetadata     = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded        = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local LoadAddOn            = LoadAddOn or C_AddOns.LoadAddOn

BINDING_HEADER_HANHUA      = "HanHua喊话助手"
BINDING_NAME_FASONG        = "发送喊话"

HH                         = {}
HH.button                  = {}
HH.sound1                  = SOUNDKIT.GS_TITLE_OPTION_OK

HH.MAX_HISTORY             = 15
HH.SendColdTime            = 20
local maxBytes             = 168

HH.ver                     = "v" .. GetAddOnMetadata(AddonName, "Version")

-- 更新内容
do
    HH.update = {
        [[|cff00ff004月9日更新1.1.2版本]],
        [[喊话最大字符数从128增加至168]],
        [[适配时光服3.80.1]],
    }
end

local function Size(t)
    local s = 0
    for k, v in pairs(t) do
        if v ~= nil then s = s + 1 end
    end
    return s
end

local function RGB(hex)
    local red = string.sub(hex, 1, 2)
    local green = string.sub(hex, 3, 4)
    local blue = string.sub(hex, 5, 6)

    red = tonumber(red, 16) / 255
    green = tonumber(green, 16) / 255
    blue = tonumber(blue, 16) / 255
    return red, green, blue
end

local size = 12
local Green1 = "Green1" -- HH.FontGreen1
HH["Font" .. Green1] = CreateFont("HH.Font" .. Green1)
HH["Font" .. Green1]:SetTextColor(RGB("00FF00"))
HH["Font" .. Green1]:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

HH.FontDisabled = CreateFont("HH.FontDisabled")
HH.FontDisabled:SetTextColor(RGB("808080"))
HH.FontDisabled:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

HH.FontHilight = CreateFont("HH.FontHilight")
HH.FontHilight:SetTextColor(RGB("FFFFFF"))
HH.FontHilight:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

function HH.GetChannels()
    HH.channels = {}
    for _, v in pairs(HHdb.channels) do
        if v.yell then
            v.join = true
        else
            v.join = nil
        end
    end
    local channels = { GetChannelList() }
    for i = 1, #channels, 3 do
        if channels[i + 1] ~= "MeetingHorn" and channels[i + 1] ~= "BiaoGeYY" then
            local a = {
                channelID = channels[i],
                name = channels[i + 1],
                disabled = channels[i + 2],
            }
            tinsert(HH.channels, a)
            for name in pairs(HHdb.channels) do
                if name == a.name then
                    HHdb.channels[name] = { channelID = a.channelID, join = true }
                end
            end
        end
    end
end

local lastText
function HH.Send()
    local bt = HH.button.send
    if not bt:IsEnabled() then return end
    if not next(HHdb.channels) then return end
    local text = HH.edit:GetText()
    if text == "" then
        SendSystemMessage("当前喊话内容为空")
        return
    end
    local hasChannel
    for _, v in pairs(HHdb.channels) do
        if v.join then
            if v.yell then
                SendChatMessage(text, "YELL")
            else
                SendChatMessage(text, "CHANNEL", nil, v.channelID)
            end
            hasChannel = true
        end
    end
    if hasChannel then
        bt:SetEnabled(false)
        bt.timeElapsed = 0
        bt:SetScript("OnUpdate", function(self, elapsed)
            self.timeElapsed = self.timeElapsed + elapsed
            self:SetText(HH.SendColdTime - format("%d", self.timeElapsed))
            if self.timeElapsed >= HH.SendColdTime then
                self:SetEnabled(true)
                self:SetText("发送")
                self:SetScript("OnUpdate", nil)
            end
        end)
    end

    local isNewText = true
    for _, _text in ipairs(HHdb.history) do
        if text == _text then
            isNewText = false
            break
        end
    end
    if isNewText then
        tinsert(HHdb.history, 1, text)
    end
    for i = #HHdb.history, 1, -1 do
        if i > HH.MAX_HISTORY then
            tremove(HHdb.history, i)
        end
    end
    HH.UpdateHistoryList()
    HH.edit:ClearFocus()
    PlaySound(HH.sound1)

    -- 同时修改集结号的活动说明
    local addonName = "MeetingHorn"
    if IsAddOnLoaded(addonName) then
        local MeetingHorn = LibStub("AceAddon-3.0"):GetAddon("MeetingHorn")
        local Manage = MeetingHorn.MainPanel.Manage.Creator
        Manage.Comment:SetMaxBytes(maxBytes)
        Manage.Comment:SetText(text)
        local newText = Manage.Comment:GetText()
        if newText ~= lastText then
            if Manage.Activity:GetValue() then
                Manage:OnCreateClick()
            end
        end
        lastText = newText
    end
end

local function HanHuaUI()
    HHdb = HHdb or {}
    if not HHdb.v110 then
        HHdb.channels = nil
        HHdb.v110 = true
    end
    HHdb.channels = HHdb.channels or {}
    HHdb.history = HHdb.history or {}

    local same = {}
    for ii, text1 in ipairs(HHdb.history) do
        if not same[ii] then
            for i, text2 in ipairs(HHdb.history) do
                if ii ~= i and text1 == text2 then
                    same[ii] = true
                end
            end
        end
    end
    for i = #HHdb.history, 1, -1 do
        if same[i] then
            tremove(HHdb.history, i)
        end
    end

    HHdb.point = HHdb.point or { "CENTER", nil, "CENTER", 0, -200 }

    HH.MainFrame = CreateFrame("Frame", "HH.MainFrame", UIParent)
    HH.MainFrame:SetSize(280, 100)
    HH.MainFrame:SetMovable(true)
    HH.MainFrame:SetToplevel(true)
    HH.MainFrame:SetClampedToScreen(true)
    HH.Frame2 = CreateFrame("Frame", nil, HH.MainFrame)
    if HHdb.Frame2 == "Hide" then
        HH.Frame2:Hide()
    end

    do -- 按钮
        local bt = CreateFrame("Button", nil, HH.MainFrame, "UIPanelButtonTemplate")
        bt:SetSize(30, 20)
        bt:SetPoint("BOTTOMLEFT")
        bt:SetText("★")
        bt:SetMovable(true)
        bt:SetClampedToScreen(true)
        HH.button.main = bt
        bt:SetScript("OnMouseUp", function(self, enter)
            HH.MainFrame:StopMovingOrSizing()
            HHdb.point = { HH.MainFrame:GetPoint(1) }
        end)
        bt:SetScript("OnMouseDown", function(self, enter)
            if IsShiftKeyDown() then
                HH.MainFrame:StartMoving()
            else
                if HH.Frame2 and HH.Frame2:IsVisible() then
                    HH.Frame2:Hide()
                    HHdb.Frame2 = "Hide"
                else
                    HH.Frame2:Show()
                    HHdb.Frame2 = "Show"
                end
                PlaySound(HH.sound1)
            end
        end)
        local function OnEnter(self)
            self.OnEnter = true
            GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
            GameTooltip:ClearLines()
            if IsAltKeyDown() then
                GameTooltip:AddLine("更新记录", 1, 1, 1)
                GameTooltip:AddLine(" ", 1, 1, 1)
                for _, text in ipairs(HH.update) do
                    GameTooltip:AddLine(text, 1, .82, 0)
                end
            else
                GameTooltip:AddLine("喊话助手" .. HH.ver, 0, 1, 0)
                GameTooltip:AddLine("左键：缩小插件", 1, .82, 0)
                GameTooltip:AddLine("长按Shift：拖动位置", 1, .82, 0)
                GameTooltip:AddLine("长按ALT：显示更新记录", 1, .82, 0)
            end
            GameTooltip:Show()
        end
        bt:SetScript("OnEnter", OnEnter)
        bt:SetScript("OnLeave", function(self)
            self.OnEnter = false
            GameTooltip:Hide()
        end)
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("MODIFIER_STATE_CHANGED")
        frame:SetScript("OnEvent", function(self, event, enter)
            if (enter == "LALT" or enter == "RALT") and bt.OnEnter then
                OnEnter(bt)
            end
        end)

        -- 发送
        local bt = CreateFrame("Button", nil, HH.MainFrame, "UIPanelButtonTemplate")
        bt:SetSize(40, 20)
        bt:SetPoint("LEFT", HH.button.main, "RIGHT", 3, 0)
        bt:SetText("发送")
        bt:SetClampedToScreen(true)
        HH.button.send = bt
        bt:SetScript("OnClick", function(self)
            HH.Send()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(HH.button.main, "ANCHOR_LEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine("发送喊话", 1, 1, 1)
            GameTooltip:AddLine("快捷命令：/fasong", 1, .82, 0, true)
            GameTooltip:AddLine("游戏按键设置也可绑定快捷键。", 1, .82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)

        -- 历史
        local bt = CreateFrame("Button", nil, HH.Frame2)
        bt:SetSize(30, 20)
        bt:SetPoint("BOTTOM", HH.button.main, "TOP", 0, 3)
        bt:SetNormalFontObject(HH.FontGreen1)
        bt:SetDisabledFontObject(HH.FontDisabled)
        bt:SetHighlightFontObject(HH.FontHilight)
        bt:SetText("历史")
        bt:SetScript("OnClick", function(self)
            if HH.FrameHistory and HH.FrameHistory:IsVisible() then
                HH.FrameHistory:Hide()
            else
                HH.FrameHistory:Show()
            end
            PlaySound(HH.sound1)
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine("历史喊话记录", 1, 1, 1)
            GameTooltip:AddLine("右键点击使用按钮可以删除历史喊话。", 1, .82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    do -- 输入框
        local f = CreateFrame("Frame", nil, HH.Frame2, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", -- 工具提示边框
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetSize(HH.MainFrame:GetWidth() - 30, 80)
        f:SetPoint("BOTTOMLEFT", HH.button.send, "TOPLEFT", 0, 3)
        f:SetClampedToScreen(true)
        HH.FrameEdit = f
        f:SetScript("OnMouseDown", function(self)
            HH.edit:SetFocus()
        end)

        local edit = CreateFrame("EditBox", nil, HH.FrameEdit)
        edit:SetWidth(f:GetWidth())
        edit:SetHeight(f:GetHeight())
        edit:SetAutoFocus(false)
        edit:SetMaxBytes(maxBytes)
        edit:EnableMouse(true)
        edit:SetTextInsets(5, 5, 5, 0)
        edit:SetMultiLine(true)
        edit:SetFontObject(GameFontNormalSmall2)
        edit:SetTextColor(1, 1, 1)
        edit:SetText(HHdb.edit or "")
        HH.edit = edit
        local rightt = f:CreateFontString(nil, "ARTWORK")
        rightt:SetFontObject(GameFontNormalSmall2)
        rightt:SetTextColor(.5, .5, .5)
        rightt:SetPoint("BOTTOMRIGHT", -2, 2)
        edit:SetScript("OnTextChanged", function(self)
            local text = self:GetText()
            if text then
                if text:find("\n") then
                    self:SetText(text:gsub("\n", ""))
                    return
                end
                HHdb.edit = self:GetText()
                rightt:SetText(edit:GetMaxBytes() - strlen(text))
            end
        end)
        edit:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        edit:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)

        local f = CreateFrame("ScrollFrame", nil, HH.FrameEdit)
        f:SetWidth(HH.FrameEdit:GetWidth())
        f:SetHeight(HH.FrameEdit:GetHeight())
        f:SetPoint("TOPLEFT")
        f:SetScrollChild(edit)
    end

    do -- 频道
        HH.button.channel = {}

        function HH.UpdateChannel()
            HH.GetChannels()

            for _, bt in ipairs(HH.button.channel) do
                bt:Hide()
            end
            wipe(HH.button.channel)
            local right

            local function CreateButton(v)
                local bt = CreateFrame("CheckButton", nil, HH.Frame2, "ChatConfigCheckButtonTemplate")
                bt:SetSize(25, 25)
                bt:SetPoint("LEFT", right or HH.button.send, "RIGHT", right and 10 or 3, 0)
                bt.Text:SetPoint("LEFT", bt, "RIGHT", -2, 0)
                bt.Text:SetText(v.channelID)
                bt:SetHitRectInsets(0, -10, 0, 0)
                tinsert(HH.button.channel, bt)
                right = bt

                if v.disabled then
                    bt.Text:SetTextColor(0.5, 0.5, 0.5)
                end
                for name in pairs(HHdb.channels) do
                    if name == v.name then
                        bt:SetChecked(true)
                        break
                    end
                end

                bt:SetScript("OnClick", function(self)
                    local name = v.name
                    if self:GetChecked() then
                        HHdb.channels[name] = { channelID = v.channelID, join = true, yell = v.yell }
                    else
                        HHdb.channels[name] = nil
                    end
                    PlaySound(HH.sound1)
                end)
                bt:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                    GameTooltip:ClearLines()
                    if v.disabled then
                        GameTooltip:AddLine(v.name, .5, .5, .5, true)
                    else
                        GameTooltip:AddLine(v.name, 1, 1, 1, true)
                    end
                    GameTooltip:Show()
                end)
                bt:SetScript("OnLeave", GameTooltip_Hide)
            end
            CreateButton({ channelID = "Y", name = "大喊", yell = true })

            for _, v in ipairs(HH.channels) do
                CreateButton(v)
            end
        end

        local f = CreateFrame("Frame")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:RegisterEvent("CHANNEL_UI_UPDATE")
        f:SetScript("OnEvent", function(self, even, ...)
            C_Timer.After(0.5, function()
                HH.UpdateChannel()
            end)
        end)
    end

    do -- 历史记录
        HH.FrameHistory = CreateFrame("Frame", nil, HH.Frame2)
        HH.FrameHistory:Hide()
        HH.historyButtons = {}

        function HH.UpdateHistoryList()
            for i, bt in ipairs(HH.historyButtons) do
                bt:Hide()
            end
            wipe(HH.historyButtons)

            for i = 1, #HHdb.history do
                local bt = CreateFrame("Button", nil, HH.FrameHistory)
                bt:SetSize(30, 15)
                if i == 1 then
                    bt:SetPoint("BOTTOMRIGHT", HH.FrameEdit, "TOPLEFT", -2, 2)
                else
                    bt:SetPoint("BOTTOMRIGHT", HH.historyButtons[i - 1], "TOPRIGHT", 0, 2)
                end
                bt:SetNormalFontObject(HH.FontGreen1)
                bt:SetDisabledFontObject(HH.FontDisabled)
                bt:SetHighlightFontObject(HH.FontHilight)
                bt:RegisterForClicks("AnyUp")
                bt:SetText("使用")
                tinsert(HH.historyButtons, bt)
                bt:SetScript("OnClick", function(self, button)
                    if button == "LeftButton" then
                        if HHdb.history[i] and HHdb.history[i] ~= "" then
                            HH.edit:SetText(HHdb.history[i])
                        end
                    elseif button == "RightButton" then
                        tremove(HHdb.history, i)
                        HH.UpdateHistoryList()
                    end
                    PlaySound(HH.sound1)
                end)

                local text = bt:CreateFontString()
                text:SetPoint("LEFT", bt, "RIGHT", 3, 0)
                text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                text:SetText(HHdb.history[i] or "")
            end
        end

        HH.UpdateHistoryList()
    end

    hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
        if not frame.checkBoxTable or not frame.checkBoxTable[1] or not frame.checkBoxTable[1].channelID then
            return
        end
        HH.UpdateChannel()
    end)

    hooksecurefunc('QuestLogTitleButton_OnClick', function(self)
        if HH.edit:HasFocus() then
            local questName = self:GetText();
            local questIndex = self:GetID() + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
            if (IsShiftKeyDown()) then
                if (self.isHeader) then
                    return;
                end

                if (IsQuestWatched(questIndex)) then
                    local questID = GetQuestIDFromLogIndex(questIndex);
                    for index, value in ipairs(QUEST_WATCH_LIST) do
                        if (value.channelID == questID) then
                            tremove(QUEST_WATCH_LIST, index);
                        end
                    end
                    RemoveQuestWatch(questIndex);
                    QuestWatch_Update();
                else
                    AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE);
                    QuestWatch_Update();
                end
                HH.edit:Insert(gsub(self:GetText(), " *(.*)", "%1"));
            end
            QuestLog_Update();
        end
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == AddonName then
        HanHuaUI()
    end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self)
    HH.MainFrame:ClearAllPoints()
    HH.MainFrame:SetPoint(HHdb.point[1], HHdb.point[2], HHdb.point[3], HHdb.point[4], HHdb.point[5])
end)

SlashCmdList["HANHUA"] = function()
    HH.Send()
end
SLASH_HANHUA1 = "/fasong"
