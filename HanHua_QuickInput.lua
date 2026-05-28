-- HanHua_QuickInput.lua
-- 快捷输入配置，JSON 风格的 Lua 表，方便修改
-- 修改后 /reload 生效

if not HH_QuickInput then HH_QuickInput = {} end

-- prefix: 活动（开团副本信息）
HH_QuickInput.prefix = {
    label = "活动",
    options = {
        -- P1
        -- P2
        -- P3
        -- P4
    },
}

-- content: 职业招募（多选，按分组展示，勾选后用 "/" 拼接，前面加前缀 "来 "）
HH_QuickInput.content = {
    label = "职业",
    prefix = "来 ",
    groups = {
        {
            label = "T",
            options = {
                "FQ",
                "DKT",
                "熊T",
                "防战",
            },
        },
        {
            label = "N",
            options = {
                "NQ",
                "奶萨",
                "奶D",
                "JLM",
                "神牧",
            },
        },
        {
            label = "近战DPS",
            options = {
                "CJQ",
                "BDK",
                "XDK",
                "猫D",
                "WQZ",
                "KBZ",
                "增强萨",
                "战斗贼",
                "刺杀贼",
                "敏锐贼",
            },
        },
        {
            label = "远程DPS",
            options = {
                "鸟D",
                "火法",
                "奥法",
                "冰法",
                "痛苦术",
                "恶魔术",
                "毁灭术",
                "元素萨",
                "射击猎",
                "兽王猎",
                "生存猎",
                "暗牧",
            },
        },
        {
            label = "泛称",
            options = {
                "T",
                "N",
                "DPS",
                "TN",
                "远程",
                "近战",
            },
        },
    },
}

-- suffix: 备注（某些职业位置已满）
HH_QuickInput.suffix = {
    label = "备注",
    options = {
        "T满",
        "N满",
        "TN满",
        "近战满",
        "远程满",
    },
}
