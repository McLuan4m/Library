--[[
    Theme/DefaultTheme.lua

    Paleta e tokens visuais padrão. Qualquer Componente deve
    consumir cores/fontes SOMENTE através do ThemeManager,
    nunca com valores fixos no próprio componente.
]]

return {
    Name = "Default",

    Colors = {
        WindowBackground   = Color3.fromRGB(24, 24, 27),
        WindowBorder       = Color3.fromRGB(45, 45, 50),
        TitleBarBackground = Color3.fromRGB(30, 30, 34),

        Accent             = Color3.fromRGB(88, 101, 242),
        AccentHover        = Color3.fromRGB(108, 121, 255),

        Text               = Color3.fromRGB(235, 235, 240),
        TextMuted          = Color3.fromRGB(150, 150, 160),

        ElementBackground  = Color3.fromRGB(35, 35, 40),
        ElementBackgroundHover = Color3.fromRGB(45, 45, 52),
        ElementBorder      = Color3.fromRGB(55, 55, 62),

        ToggleOn           = Color3.fromRGB(88, 101, 242),
        ToggleOff          = Color3.fromRGB(60, 60, 66),
    },

    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,

    TextSize = 14,
    TitleTextSize = 15,

    CornerRadius = UDim.new(0, 6),
    BorderThickness = 1,

    AnimationSpeed = 0.18,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
}
