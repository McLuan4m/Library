--[[
    Components/Dropdown.lua

    Lista suspensa refinada:
    - Head com label, valor selecionado e seta (rotaciona ao abrir)
    - Painel com fade-in, opções com hover, marcação da opção ativa
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local Signal = Library.Utility.Signal

    local Dropdown = setmetatable({}, { __index = Widget })
    Dropdown.__index = Dropdown

    function Dropdown.new(config)
        config = config or {}
        local theme = Library.Theme:Get()
        local options = config.Options or {}

        local self = Widget.new("Frame", {
            Name = "Dropdown",
            Size = UDim2.new(1, 0, 0, theme.ElementHeight),
            BackgroundTransparency = 1,
            ClipsDescendants = false,
            ZIndex = 4,
            Parent = config.Parent,
        })
        setmetatable(self, Dropdown)

        self.Options = options
        self.Value = config.Default or options[1]
        self.Changed = Signal.new()
        self._callback = config.Callback
        self._open = false

        self.Head = RenderEngine:Create("TextButton", {
            Name = "Head",
            Size = UDim2.new(1, 0, 0, theme.ElementHeight),
            BackgroundColor3 = theme.Colors.ElementBackground,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 4,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Head, theme.ElementCornerRadius)
        self._headStroke = RenderEngine:ApplyStroke(self.Head, theme.Colors.ElementBorder)

        -- rótulo do campo (config.Text) — opcional, aparece esmaecido à esquerda
        if config.Text then
            RenderEngine:Create("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.fromOffset(theme.Spacing.MD, 0),
                BackgroundTransparency = 1,
                Text = config.Text,
                Font = theme.Font,
                TextSize = theme.TextSize,
                TextColor3 = theme.Colors.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = self.Head,
            })
        end

        self.HeadLabel = RenderEngine:Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.fromOffset(config.Text and 0 or theme.Spacing.MD, 0),
            BackgroundTransparency = 1,
            Text = tostring(self.Value or "Selecione"),
            Font = theme.FontMedium,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = config.Text and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = self.Head,
        })
        if config.Text then
            RenderEngine:Update(self.HeadLabel, { Size = UDim2.new(1, -40 - theme.Spacing.MD, 1, 0) })
        end

        self.Arrow = RenderEngine:Create("TextLabel", {
            Name = "Arrow",
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -26, 0.5, -10),
            BackgroundTransparency = 1,
            Text = "▾",
            Font = theme.Font,
            TextSize = 12,
            TextColor3 = theme.Colors.TextMuted,
            ZIndex = 5,
            Parent = self.Head,
        })

        self.Panel = RenderEngine:Create("Frame", {
            Name = "Panel",
            Size = UDim2.new(1, 0, 0, #options * 30 + 8),
            Position = UDim2.new(0, 0, 0, theme.ElementHeight + 6),
            BackgroundColor3 = theme.Colors.Surface,
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 20,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Panel, theme.ElementCornerRadius)
        self._panelStroke = RenderEngine:ApplyStroke(self.Panel, theme.Colors.ElementBorder)
        RenderEngine:ApplyPadding(self.Panel, { All = 4 })

        RenderEngine:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            Parent = self.Panel,
        })

        self._optionButtons = {}
        for _, optionValue in ipairs(options) do
            local optBtn = RenderEngine:Create("TextButton", {
                Name = "Option",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = theme.Colors.Accent,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "  " .. tostring(optionValue),
                Font = theme.Font,
                TextSize = theme.TextSize,
                TextColor3 = optionValue == self.Value and theme.Colors.Text or theme.Colors.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 21,
                Parent = self.Panel,
            })
            RenderEngine:ApplyCorner(optBtn, UDim.new(0, 4))
            self._optionButtons[optionValue] = optBtn

            self.Maid:Add(optBtn.MouseEnter:Connect(function()
                RenderEngine:Animate(optBtn, {
                    BackgroundTransparency = 0.85,
                    BackgroundColor3 = Library.Theme:Get().Colors.Accent,
                }, TweenInfo.new(theme.AnimationSpeedFast))
            end))
            self.Maid:Add(optBtn.MouseLeave:Connect(function()
                RenderEngine:Animate(optBtn, { BackgroundTransparency = 1 },
                    TweenInfo.new(theme.AnimationSpeedFast))
            end))
            self.Maid:Add(optBtn.MouseButton1Click:Connect(function()
                self:Select(optionValue)
                self:Toggle(false)
            end))
        end

        self.Maid:Add(self.Head.MouseButton1Click:Connect(function()
            self:Toggle(not self._open)
        end))

        return self
    end

    function Dropdown:Toggle(open)
        self._open = open
        local theme = Library.Theme:Get()

        RenderEngine:Animate(self.Arrow, { Rotation = open and 180 or 0 })
        RenderEngine:Animate(self.Head, {
            BackgroundColor3 = open and theme.Colors.ElementBackgroundHover or theme.Colors.ElementBackground,
        })
        if self._headStroke then
            RenderEngine:Animate(self._headStroke, {
                Color = open and theme.Colors.Accent or theme.Colors.ElementBorder,
            })
        end

        if open then
            self.Panel.Visible = true
            RenderEngine:Animate(self.Panel, { BackgroundTransparency = 0 })
            if self._panelStroke then
                RenderEngine:Update(self._panelStroke, { Transparency = 0 })
            end
        else
            local tween = RenderEngine:Animate(self.Panel, { BackgroundTransparency = 1 })
            tween.Completed:Once(function()
                if not self._open then self.Panel.Visible = false end
            end)
        end
    end

    function Dropdown:Select(value)
        self.Value = value
        local theme = Library.Theme:Get()
        RenderEngine:Update(self.HeadLabel, { Text = tostring(value) })

        for optValue, btn in pairs(self._optionButtons) do
            RenderEngine:Update(btn, {
                TextColor3 = optValue == value and theme.Colors.Text or theme.Colors.TextMuted,
            })
        end

        self.Changed:Fire(value)
        if self._callback then
            task.spawn(self._callback, value)
        end
    end

    function Dropdown:ApplyTheme(theme)
        RenderEngine:Update(self.Head, { BackgroundColor3 = theme.Colors.ElementBackground })
        RenderEngine:Update(self.HeadLabel, { TextColor3 = theme.Colors.Text, Font = theme.FontMedium })
        RenderEngine:Update(self.Panel, { BackgroundColor3 = theme.Colors.Surface })
    end

    return Dropdown
end
