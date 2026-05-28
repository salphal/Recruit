-- HanHua_QuickInput.lua
-- 快捷输入配置，JSON 风格的 Lua 表，方便修改
-- 修改后 /reload 生效

if not HH_QuickInput then HH_QuickInput = {} end

-- prefix: 活动（开团副本信息，按阶段分组展示）
HH_QuickInput.prefix = {
    label = "活动",
    groups = {
        {
            label = "P1",
            options = {
                'MC全通百元团',
                'MC后四摸奖全拍百元团',
                'MC10人项链摸奖',
            },
        },
        {
            label = "P2",
            options = {
                'NAXX双龙百元团',
                'P2双龙摸奖全拍百元团',
                '毒蛇134摸奖全拍百元团',
                '毒蛇134风暴1摸奖全拍百元团',
            },
        },
        {
            label = "P3",
            options = {
                'TOC+ZUG百元团',
            },
        },
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
                "猫D",
                "WQZ",
                "ZQS",
                "KBZ",
                "BDK",
                "XDK",
                "战斗贼",
                "刺杀贼",
                "敏锐贼",
            },
        },
        {
            label = "远程DPS",
            options = {
                "鸟D",
                "AM",
                "恶魔术",
                "元素萨",
                "LR",
                "冰法",
                "火法",
                "奥法",
                "痛苦术",
                "毁灭术",
                "射击猎",
                "兽王猎",
                "生存猎",
            },
        },
        {
            label = "泛称",
            options = {
                "TN",
                "DPS",
                "远程",
                "近战",
                "T",
                "N",
            },
        },
    },
}

-- suffix: 备注（某些职业位置已满，分组展示，多选后用 "/" 拼接）
HH_QuickInput.suffix = {
    label = "备注",
    groups = {
        {
            label = "位置已满",
            options = {
                "T满",
                "N满",
                "TN满",
                "近战满",
                "远程满",
            },
        },
        {
            label = "可包",
            options = {
                "锭可包",
                "眼可包",
                "项链可包",
                "锭眼可包",
                "锭眼项链可包",
                "项链升级可包",
                "风剑可包",
                "风剑升级可包",
                "片可包",
                "橙杖升级可包",
                "橙匕可包",
            },
        },
        {
            label = "价格",
            options = {
                "2.5w锅",
                "2.5w减半",
                "3w锅",
                "3w减半",
            },
        },
        {
            label = "特殊",
            options = {
                "鱼1",
                "特殊1",
            },
        },
    },
}
