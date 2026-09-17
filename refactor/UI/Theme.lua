--!strict
-- SimpleSpy UI Refactor / Theme

local Theme = {
    Colors = {
        Background = Color3.fromRGB(10, 11, 14),
        Surface = Color3.fromRGB(16, 18, 23),
        Surface2 = Color3.fromRGB(21, 23, 29),
        Surface3 = Color3.fromRGB(27, 30, 37),
        Border = Color3.fromRGB(45, 49, 58),
        Accent = Color3.fromRGB(116, 92, 255),
        Success = Color3.fromRGB(66, 190, 120),
        Warning = Color3.fromRGB(230, 170, 70),
        Danger = Color3.fromRGB(224, 75, 91),
        Text = Color3.fromRGB(238, 240, 245),
        TextMuted = Color3.fromRGB(151, 157, 170),
        TextDim = Color3.fromRGB(105, 111, 124),
        Code = Color3.fromRGB(11, 13, 17),
    },
    Metrics = {
        MinWidth = 720,
        MinHeight = 430,
        DefaultWidth = 980,
        DefaultHeight = 610,
        TopbarHeight = 44,
        SidebarWidth = 250,
        Radius = 8,
        SmallRadius = 6,
        Padding = 12,
    },
    Motion = {
        Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    },
}

return Theme
