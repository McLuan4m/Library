--[[
    Theme/DefaultTheme.lua

    Paleta e tokens visuais padrão. Qualquer Componente deve
    consumir cores/fontes/spacing SOMENTE através do ThemeManager,
    nunca com valores fixos no próprio componente.

    Tema "Midnight": dark mode moderno, com fundo em tons de
    azul-grafite, acento índigo vibrante, tipografia clara e
    hierarquia de superfícies bem definida (window > surface >
    element), no estilo de dashboards/ImGui contemporâneos.
]]

return {
    Name = "Midnight",

    Colors = {
        -- Superfícies (da mais funda para a mais alta)
        WindowBackground       = Color3.fromRGB(18, 18, 24),
        Surface                = Color3.fromRGB(24, 24, 32),
        TitleBarBackground     = Color3.fromRGB(21, 21, 28),

        -- Bordas / divisores
        WindowBorder           = Color3.fromRGB(38, 38, 50),
        Divider                = Color3.fromRGB(32, 32, 42),
        ElementBorder          = Color3.fromRGB(44, 44, 58),
        ElementBorderHover     = Color3.fromRGB(70, 78, 130),

        -- Acento
        Accent                 = Color3.fromRGB(99, 102, 241),  -- indigo
        AccentHover            = Color3.fromRGB(129, 132, 248),
        AccentMuted            = Color3.fromRGB(67, 70, 170),
        AccentGlow             = Color3.fromRGB(99, 102, 241),

        -- Texto
        Text                   = Color3.fromRGB(237, 238, 245),
        TextMuted              = Color3.fromRGB(148, 150, 168),
        TextDim                = Color3.fromRGB(96, 98, 116),

        -- Elementos interativos
        ElementBackground      = Color3.fromRGB(30, 30, 40),
        ElementBackgroundHover = Color3.fromRGB(38, 38, 52),
        ElementBackgroundActive= Color3.fromRGB(44, 44, 60),

        -- Estados
        ToggleOn               = Color3.fromRGB(99, 102, 241),
        ToggleOff              = Color3.fromRGB(48, 48, 62),
        Knob                   = Color3.fromRGB(245, 245, 250),

        -- Feedback semântico (para uso futuro: notificações etc.)
        Success                = Color3.fromRGB(52, 211, 153),
        Warning                = Color3.fromRGB(251, 191, 36),
        Danger                 = Color3.fromRGB(248, 113, 113),
    },

    -- Tipografia
    Font          = Enum.Font.Gotham,
    FontMedium    = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,

    TextSize      = 13,
    TitleTextSize = 15,
    SubtitleTextSize = 12,

    -- Formas
    CornerRadius        = UDim.new(0, 8),
    ElementCornerRadius = UDim.new(0, 6),
    BorderThickness     = 1,

    -- Espaçamento (escala consistente)
    Spacing = {
        XS = 4,
        SM = 8,
        MD = 12,
        LG = 16,
        XL = 24,
    },

    ElementHeight = 34,
    TitleBarHeight = 44,

    -- Layout do app (sidebar + topbar + content)
    Layout = {
        TopbarHeight   = 48,
        SidebarWidth   = 190,
        SidebarItemHeight = 34,
        SidebarSubItemHeight = 30,
        SidebarIndent  = 22,   -- recuo das seções sob uma página
        ContentPadding = 18,
        SectionGap     = 14,
    },

    -- Cores extras do app
    -- (mantidas aqui para retemação; usam as mesmas famílias do tema)
    AppColors = {
        SidebarBackground = Color3.fromRGB(21, 21, 28),
        TopbarBackground  = Color3.fromRGB(21, 21, 28),
        ContentBackground = Color3.fromRGB(16, 16, 22),
        NavItemHover      = Color3.fromRGB(30, 30, 42),
        NavItemActive     = Color3.fromRGB(35, 36, 58),
        NavActiveBar      = Color3.fromRGB(99, 102, 241),
    },

    -- Sombra da janela
    Shadow = {
        Enabled     = true,
        Transparency = 0.55,
        Size        = 40,   -- quanto a sombra "vaza" além da janela
    },

    -- Animação
    AnimationSpeed  = 0.16,
    AnimationSpeedFast = 0.09,
    EasingStyle     = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out,
}
