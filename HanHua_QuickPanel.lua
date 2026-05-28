-- HanHua_QuickPanel.lua - 快捷输入面板 (tab切换 + 滚动)
-- 依赖: HH (Util), HH_QuickInput, HHdb, HH.editPrefix/Middle/Suffix
local AddonName, ADDONSELF = ...

HH.activeTab = 1
HH.tabDefs = {
    { key = "gtuan",   name = "重要" },
    { key = "prefix",  name = "活动" },
    { key = "tuanbu",  name = "团补" },
    { key = "content", name = "职业" },
    { key = "suffix",  name = "备注" },
}
HH.contentChecked = {}
HH.suffixChecked = {}
HH.gtuanChecked = {}
HH.tuanbuChecked = {}
HH.createdWidgets = {}

-- 暴露给外部 (清空按钮等) 调用
function HH.ClearQuickInput()
    for k in pairs(HH.contentChecked) do HH.contentChecked[k] = nil end
    for k in pairs(HH.suffixChecked) do HH.suffixChecked[k] = nil end
    for k in pairs(HH.gtuanChecked) do HH.gtuanChecked[k] = nil end
    for k in pairs(HH.tuanbuChecked) do HH.tuanbuChecked[k] = nil end
    RefreshQuickInput(HH_QuickInput)
end

function RefreshQuickInput(qi)
    -- 隐藏旧控件
    for _, w in ipairs(HH.createdWidgets) do
        w:Hide()
        w:SetParent(nil)
    end
    wipe(HH.createdWidgets)

    local def = HH.tabDefs[HH.activeTab]
    local data = qi[def.key]
    if not data or not (data.options or data.groups) then return end

    local scrollChild = HH._scrollChild
    if not scrollChild then return end

    local xStart = 10
    local y = 0
    local yRow = 22
    local x = xStart
    local function add(w) tinsert(HH.createdWidgets, w); return w end
    local meas = scrollChild:CreateFontString(nil, "ARTWORK")
    meas:SetFont(STANDARD_TEXT_FONT, 12)
    local cw = scrollChild:GetWidth()

    if def.key == "prefix" or def.key == "gtuan" then
        local hidden = HHdb.hiddenTemplates or {}
        local delBtnW = 16
        local btnW = cw - xStart * 2 - delBtnW - 2

        local function renderItem(opt, source)
            local bt = add(CreateFrame("Button", nil, scrollChild))
            bt:SetSize(btnW, 18)
            bt:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", xStart, y)
            local displayText = opt
            meas:SetText(opt)
            local textW = meas:GetStringWidth()
            if textW > btnW - 4 then
                while #displayText > 0 do
                    displayText = string.sub(displayText, 1, -2)
                    meas:SetText(displayText .. "...")
                    if meas:GetStringWidth() <= btnW - 4 then break end
                end
                displayText = displayText .. "..."
            end
            local txt = bt:CreateFontString(nil, "ARTWORK")
            txt:SetPoint("LEFT", 0, 0)
            txt:SetFont(STANDARD_TEXT_FONT, 12)
            txt:SetText(displayText)
            txt:SetTextColor(1, 1, 1)
            bt:SetScript("OnClick", function()
                local target = def.key == "gtuan" and HH.editGtuan or HH.editPrefix
                target:SetText(opt)
            end)
            bt:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(opt, 0.6, 0.8, 1)
                GameTooltip:Show()
            end)
            bt:SetScript("OnLeave", GameTooltip_Hide)
            local del = add(CreateFrame("Button", nil, scrollChild))
            del:SetSize(delBtnW, 18)
            del:SetPoint("LEFT", bt, "RIGHT", 2, 0)
            local delTxt = del:CreateFontString(nil, "ARTWORK")
            delTxt:SetFont(STANDARD_TEXT_FONT, 12)
            delTxt:SetText("X")
            delTxt:SetTextColor(1, 0.3, 0.3)
            del:SetFontString(delTxt)
            del:SetScript("OnClick", function()
                if source == "builtin" then
                    HHdb.hiddenTemplates[opt] = true
                elseif def.key == "gtuan" then
                    for i, t in ipairs(HHdb.savedGtuanTemplates) do
                        if t == opt then
                            tremove(HHdb.savedGtuanTemplates, i)
                            break
                        end
                    end
                else
                    for i, t in ipairs(HHdb.savedTemplates) do
                        if t == opt then
                            tremove(HHdb.savedTemplates, i)
                            break
                        end
                    end
                end
                RefreshQuickInput(qi)
            end)
            del:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine("删除模版", 1, 0.3, 0.3)
                GameTooltip:Show()
            end)
            del:SetScript("OnLeave", GameTooltip_Hide)
            y = y - yRow
        end

        -- 分组渲染 (如果某组 label 是 "通用", 动态追加已保存的模版)
        if data.groups then
            local savedLookup = {}
            if def.key == "gtuan" then
                for _, v in ipairs(HHdb.savedGtuanTemplates or {}) do savedLookup[v] = true end
            else
                for _, v in ipairs(HHdb.savedTemplates or {}) do savedLookup[v] = true end
            end
            for _, group in ipairs(data.groups) do
                local visible = {}
                for _, opt in ipairs(group.options) do
                    if not hidden[opt] then
                        tinsert(visible, opt)
                    end
                end
                if group.label == "通用" then
                    for _, v in ipairs(def.key == "gtuan" and HHdb.savedGtuanTemplates or HHdb.savedTemplates or {}) do
                        if not hidden[v] then
                            tinsert(visible, v)
                        end
                    end
                end
                if #visible > 0 then
                    y = y - 6
                    local header = add(scrollChild:CreateFontString(nil, "ARTWORK"))
                    header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", xStart, y)
                    header:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                    header:SetText(group.label)
                    header:SetTextColor(1, 0.82, 0)
                    y = y - yRow
                    for _, opt in ipairs(visible) do
                        renderItem(opt, savedLookup[opt] and "saved" or "builtin")
                    end
                    y = y - 4
                end
            end
        else
            -- 旧版平铺模式 (无 groups 时)
            for _, opt in ipairs(data.options) do
                if not hidden[opt] then
                    renderItem(opt, "builtin")
                end
            end
        end
    elseif def.key == "content" or def.key == "suffix" or def.key == "tuanbu" then
        -- 职业 / 备注 / 团补: 按分组展示复选框网格
        local checkedTbl = def.key == "content" and HH.contentChecked or (def.key == "suffix" and HH.suffixChecked or HH.tuanbuChecked)
        local editBox = def.key == "content" and HH.editMiddle or (def.key == "suffix" and HH.editSuffix or HH.editTuanbu)
        local prefix = (def.key == "content" and data.prefix) or ""

        local function renderOptions(optList, yOffset)
            local gx = xStart
            for _, opt in ipairs(optList) do
                local bt = add(CreateFrame("CheckButton", nil, scrollChild, "ChatConfigCheckButtonTemplate"))
                bt:SetSize(16, 16)
                meas:SetText(opt)
                local textW = meas:GetStringWidth()
                local itemW = 16 + textW + 6
                if gx + itemW > cw then
                    gx = xStart
                    yOffset = yOffset - yRow
                end
                bt:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", gx, yOffset)
                bt:SetHitRectInsets(0, -20, 0, 0)
                bt.Text:SetPoint("LEFT", bt, "RIGHT", -1, 0)
                bt.Text:SetFont(STANDARD_TEXT_FONT, 12)
                bt.Text:SetText(opt)
                bt:SetChecked(checkedTbl[opt])
                bt:SetScript("OnClick", function(self)
                    checkedTbl[opt] = self:GetChecked()
                    local parts = {}
                    for _, group in ipairs(data.groups or {}) do
                        for _, o in ipairs(group.options) do
                            if checkedTbl[o] then tinsert(parts, o) end
                        end
                    end
                    if not data.groups then
                        for _, o in ipairs(data.options or {}) do
                            if checkedTbl[o] then tinsert(parts, o) end
                        end
                    end
                    if #parts > 0 then
                        editBox:SetText(prefix .. table.concat(parts, "/"))
                    else
                        editBox:SetText("")
                    end
                    PlaySound(HH.sound1)
                end)
                gx = gx + itemW + 4
            end
            return yOffset
        end

        if data.groups then
            for _, group in ipairs(data.groups) do
                y = y - 8
                local header = add(scrollChild:CreateFontString(nil, "ARTWORK"))
                header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", xStart, y)
                header:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                header:SetText(group.label)
                header:SetTextColor(1, 0.82, 0)
                y = y - yRow
                y = renderOptions(group.options, y)
                y = y - yRow
            end
        else
            y = renderOptions(data.options or {}, y)
        end
    end
    local h = -(y - yRow)
    if h < 1 then h = 1 end
    scrollChild:SetSize(cw, h)
end

function HH.BuildQuickPanel(parent)
    -- 容器
    local c = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    c:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    c:SetBackdropColor(0, 0, 0, 0.8)
    c:SetSize(HH.FRAME_WIDTH, HH.QI_HEIGHT)
    c:SetPoint("TOPLEFT", HH.button.send, "BOTTOMLEFT", 0, -36)

    -- Tab 栏
    local tabBarH = 28
    local tabs = {}
    local activeColor = { GameFontNormalSmall2:GetTextColor() }
    local inactiveColor = { 1, 1, 1 }

    for i, def in ipairs(HH.tabDefs) do
        local tab = CreateFrame("Button", nil, c)
        tab:SetSize(60, tabBarH)
        tab:SetPoint("TOPLEFT", c, "TOPLEFT", (i - 1) * 64, 0)
        local tabText = tab:CreateFontString(nil, "OVERLAY")
        tabText:SetFont(STANDARD_TEXT_FONT, 12)
        tabText:SetPoint("CENTER")
        tabText:SetText(def.name)
        tabText:SetTextColor(inactiveColor[1], inactiveColor[2], inactiveColor[3])
        tab:SetScript("OnClick", function()
            HH.activeTab = i
            for j, t in ipairs(tabs) do
                local c2 = j == i and activeColor or inactiveColor
                t.text:SetTextColor(c2[1], c2[2], c2[3])
            end
            RefreshQuickInput(HH_QuickInput)
        end)
        tab.text = tabText
        tabs[i] = tab
    end

    -- 灰色下边框
    local line = c:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.4, 0.4, 0.4, 0.6)
    line:SetPoint("TOPLEFT", c, "TOPLEFT", 0, -tabBarH)
    line:SetPoint("TOPRIGHT", c, "TOPRIGHT", 0, -tabBarH)
    line:SetHeight(1)

    -- 内容滚动区域
    local scrollFrame = CreateFrame("ScrollFrame", nil, c, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", c, "TOPLEFT", 0, -tabBarH - 2)
    scrollFrame:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", -2, 0)
    scrollFrame.ScrollBar:SetAlpha(0)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(HH.FRAME_WIDTH - 26, 1)
    scrollFrame:SetScrollChild(scrollChild)

    HH._scrollChild = scrollChild

    -- 初始激活
    tabs[1].text:SetTextColor(activeColor[1], activeColor[2], activeColor[3])
    RefreshQuickInput(HH_QuickInput)
end
