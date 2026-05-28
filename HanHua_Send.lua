-- HanHua_Send.lua - 发送逻辑
-- 依赖: HH (Util), HHdb, HH.editPrefix/Middle/Suffix, HH.button.send, HH.UpdateHistoryList
local AddonName, ADDONSELF = ...

local lastText
function HH.Send()
    local bt = HH.button.send
    if not bt:IsEnabled() then return end
    if not next(HHdb.channels) then return end
    local text = (HH.editGtuan:GetText() .. "-" .. HH.editPrefix:GetText() .. "-" .. HH.editTuanbu:GetText() .. "-" .. HH.editMiddle:GetText() .. "-" .. HH.editSuffix:GetText())
        :match("^%-*(.-)%-*$"):gsub("%-+", "-")
    if text == "" then
        SendSystemMessage("当前喊话内容为空")
        return
    end
    local hasChannel
    for _, v in pairs(HHdb.channels) do
        if v.join then
            if v.yell then
                C_Timer.After(0, function()
                    SendChatMessage(text, "YELL")
                end)
            else
                C_Timer.After(0, function()
                    SendChatMessage(text, "CHANNEL", nil, v.channelID)
                end)
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
                if HHdb.auto then
                    C_Timer.After(0, HH.Send)
                end
            end
        end)
    end

    local historyItem = { g = HH.editGtuan:GetText(), p = HH.editPrefix:GetText(), t = HH.editTuanbu:GetText(), m = HH.editMiddle:GetText(), s = HH.editSuffix:GetText() }
    local isNewText = true
    for _, entry in ipairs(HHdb.history) do
        local et = type(entry) == "table" and (entry.g or "") .. (entry.p or "") .. (entry.t or "") .. (entry.m or "") .. (entry.s or "") or entry
        if et == text then
            isNewText = false
            break
        end
    end
    if isNewText then
        tinsert(HHdb.history, 1, historyItem)
    end
    for i = #HHdb.history, 1, -1 do
        if i > HH.MAX_HISTORY then
            tremove(HHdb.history, i)
        end
    end
    HH.UpdateHistoryList()
    HH.editGtuan:ClearFocus()
    HH.editPrefix:ClearFocus()
    HH.editTuanbu:ClearFocus()
    HH.editMiddle:ClearFocus()
    HH.editSuffix:ClearFocus()
    PlaySound(HH.sound1)

    -- 同时修改集结号的活动说明
    local addonName = "MeetingHorn"
    if IsAddOnLoaded(addonName) then
        local MeetingHorn = LibStub("AceAddon-3.0"):GetAddon("MeetingHorn")
        local Manage = MeetingHorn.MainPanel.Manage.Creator
        Manage.Comment:SetMaxBytes(HH.maxBytes)
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

SlashCmdList["HANHUA"] = function()
    HH.Send()
end
SLASH_HANHUA1 = "/fasong"
