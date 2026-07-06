--[[
    Components/Window.lua

    Janela principal da interface. Visual refinado:
    - Sombra (drop shadow) atrás da janela
    - Barra de título com ícone de "grip", título + subtítulo
    - Botão de fechar com hover
    - Divisor sutil abaixo do header
    - Área de conteúdo com ScrollingFrame + padding + list layout
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local EventManager = Library.Core.EventManager
    local Services = Library.Services

    local Window = setmetatable({}, { __index = Widget })
    Window.__index = Window

    function Window.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        local playerGui = Services.GetPlayerGui()

        local screenGui = RenderEngine:Create("ScreenGui", {
            Name = "LibraryWindow_" .. (config.Title or "Window"),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 999,
            Parent = playerGui,
        })

        local self = Widget.new("Frame", {
            Name = "Window",
            Size = config.Size or UDim2.fromOffset(520, 360),
            Position = config.Position or UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.Colors.WindowBackground,
            BorderSizePixel = 0,
            Parent = screenGui,
        })
        setmetatable(self, Window)

        self._screenGui = screenGui
        self.Maid:Add(screenGui)

        -- Sombra atrás da janela (fica em ZIndex 0)
        if theme.Shadow.Enabled then
            RenderEngine:ApplyShadow(self.Instance)
        end

        RenderEngine:ApplyCorner(self.Instance, theme.CornerRadius)
        self._stroke = RenderEngine:ApplyStroke(self.Instance, theme.Colors.WindowBorder)

        -- Gradiente sutil no fundo da janela para dar profundidade
        RenderEngine:ApplyGradient(
            self.Instance,
            theme.Colors.WindowBackground,
            Color3.fromRGB(
                math.max(0, theme.Colors.WindowBackground.R * 255 - 4),
                math.max(0, theme.Colors.WindowBackground.G * 255 - 4),
                math.max(0, theme.Colors.WindowBackground.B * 255 - 2)
            )
        )

        -- ===================== HEADER =====================
        self.TitleBar = RenderEngine:Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, theme.TitleBarHeight),
            BackgroundColor3 = theme.Colors.TitleBarBackground,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.TitleBar, theme.CornerRadius)

        -- "tampa" para que só os cantos de cima do header fiquem arredondados
        RenderEngine:Create("Frame", {
            Name = "HeaderMask",
            Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = theme.Colors.TitleBarBackground,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = self.TitleBar,
        })

        -- Ponto de acento (bolinha colorida à esquerda do título)
        self.AccentDot = RenderEngine:Create("Frame", {
            Name = "AccentDot",
            Size = UDim2.fromOffset(8, 8),
            Position = UDim2.new(0, theme.Spacing.LG, 0.5, -4),
            BackgroundColor3 = theme.Colors.Accent,
            ZIndex = 3,
            Parent = self.TitleBar,
        })
        RenderEngine:ApplyCorner(self.AccentDot, UDim.new(1, 0))

        local textLeft = theme.Spacing.LG + 8 + theme.Spacing.SM

        self.TitleLabel = RenderEngine:Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -textLeft - 40, 0, config.Subtitle and 18 or theme.TitleBarHeight),
            Position = config.Subtitle
                and UDim2.fromOffset(textLeft, 5)
                or UDim2.fromOffset(textLeft, 0),
            BackgroundTransparency = 1,
            Text = config.Title or "Window",
            Font = theme.FontBold,
            TextSize = theme.TitleTextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 3,
            Parent = self.TitleBar,
        })

        if config.Subtitle then
            self.SubtitleLabel = RenderEngine:Create("TextLabel", {
                Name = "Subtitle",
                Size = UDim2.new(1, -textLeft - 40, 0, 14),
                Position = UDim2.fromOffset(textLeft, 23),
                BackgroundTransparency = 1,
                Text = config.Subtitle,
                Font = theme.Font,
                TextSize = theme.SubtitleTextSize,
                TextColor3 = theme.Colors.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Parent = self.TitleBar,
            })
        end

        -- Botão de fechar
        self.CloseButton = RenderEngine:Create("TextButton", {
            Name = "Close",
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.new(1, -(28 + theme.Spacing.MD), 0.5, -14),
            BackgroundColor3 = theme.Colors.ElementBackground,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "✕",
            Font = theme.FontBold,
            TextSize = 14,
            TextColor3 = theme.Colors.TextMuted,
            ZIndex = 3,
            Parent = self.TitleBar,
        })
        RenderEngine:ApplyCorner(self.CloseButton, theme.ElementCornerRadius)

        self.Maid:Add(self.CloseButton.MouseEnter:Connect(function()
            RenderEngine:Animate(self.CloseButton, {
                BackgroundTransparency = 0,
                BackgroundColor3 = theme.Colors.Danger,
                TextColor3 = Color3.fromRGB(255, 255, 255),
            })
        end))
        self.Maid:Add(self.CloseButton.MouseLeave:Connect(function()
            RenderEngine:Animate(self.CloseButton, {
                BackgroundTransparency = 1,
                TextColor3 = theme.Colors.TextMuted,
            })
        end))
        self.Maid:Add(self.CloseButton.MouseButton1Click:Connect(function()
            self:Destroy()
        end))

        -- Divisor abaixo do header
        self.Divider = RenderEngine:Create("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, theme.TitleBarHeight),
            BackgroundColor3 = theme.Colors.Divider,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = self.Instance,
        })

        -- ===================== CONTEÚDO =====================
        self.Content = RenderEngine:Create("ScrollingFrame", {
            Name = "Content",
            Size = UDim2.new(1, 0, 1, -(theme.TitleBarHeight + 1)),
            Position = UDim2.fromOffset(0, theme.TitleBarHeight + 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Colors.ElementBorder,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 2,
            Parent = self.Instance,
        })

        RenderEngine:ApplyPadding(self.Content, { All = theme.Spacing.LG })

        self.Layout = RenderEngine:Create("UIListLayout", {
            Padding = UDim.new(0, theme.Spacing.SM),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Content,
        })

        -- Torna a janela arrastável pela barra de título
        EventManager:MakeDraggable(self.TitleBar, self.Instance, self.Maid)

        -- Animação de entrada (fade + leve zoom)
        self.Instance.Size = UDim2.fromOffset(
            (config.Size or UDim2.fromOffset(520, 360)).X.Offset * 0.96,
            (config.Size or UDim2.fromOffset(520, 360)).Y.Offset * 0.96
        )
        RenderEngine:Animate(self.Instance, {
            Size = config.Size or UDim2.fromOffset(520, 360),
        })

        return self
    end

    function Window:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, { BackgroundColor3 = theme.Colors.WindowBackground })
        RenderEngine:Update(self.TitleBar, { BackgroundColor3 = theme.Colors.TitleBarBackground })
        RenderEngine:Update(self.TitleLabel, {
            TextColor3 = theme.Colors.Text,
            Font = theme.FontBold,
        })
        if self.AccentDot then
            RenderEngine:Update(self.AccentDot, { BackgroundColor3 = theme.Colors.Accent })
        end
        if self.Divider then
            RenderEngine:Update(self.Divider, { BackgroundColor3 = theme.Colors.Divider })
        end
    end

    -- Métodos de conveniência
    function Window:AddButton(config)
        config = config or {}; config.Parent = self.Content
        return Library.Components.Button.new(config)
    end
    function Window:AddToggle(config)
        config = config or {}; config.Parent = self.Content
        return Library.Components.Toggle.new(config)
    end
    function Window:AddSlider(config)
        config = config or {}; config.Parent = self.Content
        return Library.Components.Slider.new(config)
    end
    function Window:AddDropdown(config)
        config = config or {}; config.Parent = self.Content
        return Library.Components.Dropdown.new(config)
    end
    function Window:AddLabel(config)
        config = config or {}; config.Parent = self.Content
        return Library.Components.Label.new(config)
    end

    return Window
end
