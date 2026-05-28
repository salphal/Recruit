-- HanHua.lua - 主入口 / 界面构建
-- 依赖: HanHua_Util, HanHua_Channels, HanHua_Send, HanHua_History, HanHua_QuickPanel
local AddonName, ADDONSELF = ...

local function HanHuaUI()
    HHdb = HHdb or {}
    if not HHdb.v110 then
        HHdb.channels = nil
        HHdb.v110 = true
    end
    HHdb.channels = HHdb.channels or {}
    HHdb.history = HHdb.history or {}
    HHdb.auto = HHdb.auto or false
    HHdb.editGtuan = HHdb.editGtuan or ""
    HHdb.editPrefix = HHdb.editPrefix or ""
    HHdb.editTuanbu = HHdb.editTuanbu or ""
    HHdb.editMiddle = HHdb.editMiddle or ""
    HHdb.editSuffix = HHdb.editSuffix or ""
    HHdb.savedTemplates = HHdb.savedTemplates or {}
    HHdb.hiddenTemplates = HHdb.hiddenTemplates or {}
    -- 从旧版单输入框迁移
    if HHdb.edit and HHdb.edit ~= "" and HHdb.editMiddle == "" then
        HHdb.editMiddle = HHdb.edit
    end
    HHdb.edit = nil

    -- 去重
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
    HH.MainFrame:SetSize(280, 130)
    HH.MainFrame:SetMovable(true)
    HH.MainFrame:SetToplevel(true)
    HH.MainFrame:SetClampedToScreen(true)

    HH.Frame2 = CreateFrame("Frame", nil, HH.MainFrame)
    if HHdb.Frame2 == "Hide" then
        HH.Frame2:Hide()
    end

    -- 按钮
    do
        -- ★ 主按钮
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
        local modFrame = CreateFrame("Frame")
        modFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
        modFrame:SetScript("OnEvent", function(self, event, enter)
            if (enter == "LALT" or enter == "RALT") and bt.OnEnter then
                OnEnter(bt)
            end
        end)

        -- 发送
        do
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
        end

        -- 清空内容
        do
            local bt = CreateFrame("Button", nil, HH.MainFrame, "UIPanelButtonTemplate")
            bt:SetSize(80, 20)
            bt:SetPoint("LEFT", HH.button.send, "RIGHT", 3, 0)
            bt:SetText("清空内容")
            bt:SetClampedToScreen(true)
            bt:SetScript("OnClick", function()
                HH.editGtuan:SetText("")
                HH.editPrefix:SetText("")
                HH.editTuanbu:SetText("")
                HH.editMiddle:SetText("")
                HH.editSuffix:SetText("")
                HHdb.editGtuan = ""
                HHdb.editPrefix = ""
                HHdb.editTuanbu = ""
                HHdb.editMiddle = ""
                HHdb.editSuffix = ""
                if HH.ClearQuickInput then HH.ClearQuickInput() end
                PlaySound(HH.sound1)
            end)
            bt:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine("清空输入框", 1, 1, 1)
                GameTooltip:Show()
            end)
            bt:SetScript("OnLeave", GameTooltip_Hide)
            HH.button.clear = bt
        end

        -- 清空历史
        do
            local bt = CreateFrame("Button", nil, HH.MainFrame, "UIPanelButtonTemplate")
            bt:SetSize(80, 20)
            bt:SetPoint("LEFT", HH.button.clear, "RIGHT", 3, 0)
            bt:SetText("清空历史")
            bt:SetClampedToScreen(true)
            bt:SetScript("OnClick", function()
                HHdb.history = {}
                HH.UpdateHistoryList()
                PlaySound(HH.sound1)
            end)
            bt:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine("清空所有历史记录", 1, 1, 1)
                GameTooltip:Show()
            end)
            bt:SetScript("OnLeave", GameTooltip_Hide)
            HH.button.clearHistory = bt
        end

        -- 自动
        do
            local bt = CreateFrame("CheckButton", nil, HH.MainFrame, "ChatConfigCheckButtonTemplate")
            bt:SetSize(20, 20)
            bt:SetPoint("LEFT", HH.button.clearHistory, "RIGHT", 3, 0)
            bt.Text:SetPoint("LEFT", bt, "RIGHT", -2, 0)
            bt.Text:SetText("自动")
            bt:SetChecked(HHdb.auto)
            bt:SetScript("OnClick", function(self)
                HHdb.auto = self:GetChecked()
                PlaySound(HH.sound1)
            end)
            bt:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine("CD结束后自动发送", 1, 1, 1)
                GameTooltip:Show()
            end)
            bt:SetScript("OnLeave", GameTooltip_Hide)
        end

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

    -- 输入框
    do
        local f = CreateFrame("Frame", nil, HH.Frame2, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetSize(HH.FRAME_WIDTH, HH.FRAME_HEIGHT)
        f:SetPoint("BOTTOMLEFT", HH.button.send, "TOPLEFT", 0, 3)
        f:SetClampedToScreen(true)
        HH.FrameEdit = f

        local previewLabel = f:CreateFontString(nil, "ARTWORK")
        previewLabel:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5)
        previewLabel:SetHeight(14)
        previewLabel:SetFontObject(GameFontNormalSmall2)
        previewLabel:SetTextColor(0, 1, 0)
        previewLabel:SetJustifyH("LEFT")

        local previewContent = f:CreateFontString(nil, "ARTWORK")
        previewContent:SetPoint("TOPLEFT", previewLabel, "BOTTOMLEFT", 0, -2)
        previewContent:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, 0)
        previewContent:SetHeight(80)
        previewContent:SetFontObject(GameFontNormalSmall2)
        previewContent:SetTextColor(0, 1, 0)
        previewContent:SetJustifyH("LEFT")
        previewContent:SetJustifyV("TOP")
        previewContent:SetSpacing(2)
        previewContent:SetWordWrap(true)
        previewContent:SetNonSpaceWrap(true)

        local function UpdatePreview()
            if not HH.editGtuan or not HH.editPrefix or not HH.editTuanbu or not HH.editMiddle or not HH.editSuffix then return end
            local t = (HH.editGtuan:GetText() .. "-" .. HH.editPrefix:GetText() .. "-" .. HH.editTuanbu:GetText() .. "-" .. HH.editMiddle:GetText() .. "-" .. HH.editSuffix:GetText()):match("^%-*(.-)%-*$"):gsub("%-+", "-")
            previewContent:SetText(t)
            previewLabel:SetText("最终:(" .. #t .. ")")
        end

        local function MakeEditBox(anchor, label, field, max, dbField, rows, yOff)
            yOff = yOff or -6
            local rowH = 18
            local editH = rows * rowH

            local lab = f:CreateFontString(nil, "ARTWORK")
            lab:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)
            lab:SetHeight(14)
            lab:SetFontObject(GameFontNormalSmall2)
            lab:SetJustifyH("LEFT")
            local savedText = HHdb[dbField] or ""
            lab:SetText(label .. " (" .. #savedText .. "/" .. max .. ")")

            local edit = CreateFrame("EditBox", nil, f)
            edit:SetPoint("TOPLEFT", lab, "BOTTOMLEFT", 0, -2)
            edit:SetPoint("TOPRIGHT", -6, 0)
            edit:SetHeight(editH)
            edit:SetJustifyH("LEFT")
            edit:SetMaxBytes(max + 1)
            edit:SetAutoFocus(false)
            edit:SetMultiLine(true)
            edit:EnableMouse(true)
            edit:SetTextInsets(3, 3, 0, 0)
            edit:SetFontObject(GameFontNormalSmall2)
            edit:SetTextColor(1, 1, 1)
            edit:SetText(HHdb[dbField] or "")
            edit._label = lab
            HH[field] = edit

            edit:SetScript("OnTextChanged", function(self)
                local text = self:GetText()
                if not text then
                    HHdb[dbField] = ""
                    lab:SetText(label .. " (0/" .. max .. ")")
                    UpdatePreview()
                    return
                end
                if text:find("\n") then
                    self:SetText(text:gsub("\n", ""))
                    return
                end
                HHdb[dbField] = text
                lab:SetText(label .. " (" .. #text .. "/" .. max .. ")")
                UpdatePreview()
            end)
            edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

            return edit
        end

        local last = previewContent
        last = MakeEditBox(last, "G团信息", "editGtuan", HH.GTUAN_MAX, "editGtuan", 1)
        last = MakeEditBox(last, "活动", "editPrefix", HH.PREFIX_MAX, "editPrefix", 2)
        -- 保存为模版按钮
        do
            local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            btn:SetSize(60, 14)
            btn:SetText("存模版")
            btn:SetPoint("LEFT", HH.editPrefix._label, "RIGHT", 4, 0)
            btn:SetScript("OnClick", function()
                local text = HH.editPrefix:GetText()
                if text == "" then
                    SendSystemMessage("活动内容为空，无法保存")
                    return
                end
                for _, t in ipairs(HHdb.savedTemplates) do
                    if t == text then
                        SendSystemMessage("该模版已存在")
                        return
                    end
                end
                tinsert(HHdb.savedTemplates, text)
                SendSystemMessage("已保存模版: " .. text)
                if HH.activeTab and HH.tabDefs and HH.tabDefs[HH.activeTab] and HH.tabDefs[HH.activeTab].key == "prefix" then
                    RefreshQuickInput(HH_QuickInput)
                end
            end)
        end
        last = MakeEditBox(last, "团补信息", "editTuanbu", HH.TUANBU_MAX, "editTuanbu", 1)
        last = MakeEditBox(last, "职业", "editMiddle", HH.MIDDLE_MAX, "editMiddle", 4)
        last = MakeEditBox(last, "备注", "editSuffix", HH.SUFFIX_MAX, "editSuffix", 2)

        f:SetScript("OnMouseDown", function(self)
            HH.editGtuan:SetFocus()
        end)

        UpdatePreview()
    end

    -- 快捷输入
    if HH_QuickInput then
        HH.BuildQuickPanel(HH.Frame2)
    end

    -- 历史记录
    HH.FrameHistory = CreateFrame("Frame", nil, HH.Frame2)
    HH.FrameHistory:Hide()
    HH.historyButtons = {}
    HH.UpdateHistoryList()

    hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)
        if not frame.checkBoxTable or not frame.checkBoxTable[1] or not frame.checkBoxTable[1].channelID then
            return
        end
        HH.UpdateChannel()
    end)

    hooksecurefunc('QuestLogTitleButton_OnClick', function(self)
        if HH.editGtuan:HasFocus() or HH.editPrefix:HasFocus() or HH.editTuanbu:HasFocus() or HH.editMiddle:HasFocus() or HH.editSuffix:HasFocus() then
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
                HH.editMiddle:Insert(gsub(self:GetText(), " *(.*)", "%1"));
            end
            QuestLog_Update();
        end
    end)
end

local frameAL = CreateFrame("Frame")
frameAL:RegisterEvent("ADDON_LOADED")
frameAL:SetScript("OnEvent", function(self, event, addonName)
    if addonName == AddonName then
        HanHuaUI()
    end
end)

local framePL = CreateFrame("Frame")
framePL:RegisterEvent("PLAYER_LOGIN")
framePL:SetScript("OnEvent", function(self)
    HH.MainFrame:ClearAllPoints()
    HH.MainFrame:SetPoint(HHdb.point[1], HHdb.point[2], HHdb.point[3], HHdb.point[4], HHdb.point[5])
end)
