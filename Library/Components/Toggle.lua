--[[
    Components/Toggle.lua

    Switch on/off dentro de uma "linha" clicável com hover.
    Visual refinado: track arredondado, knob com sombra sutil,
    transição suave de cor e posição.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local Signal = Library.Utility.Signal

    local Toggle = setmetatable({}, { __index = Widget })
    Toggle.__index = Toggle

    function Toggle.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        -- Row container (fundo clicável com hover)
        local self = Widget.new("TextButton", {
            Name = "Toggle",
            Size = UDim2.new(1, 0, 0, theme.ElementHeight),
            BackgroundColor3 = theme.Colors.ElementBackground,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            Parent = config.Parent,
        })
        setmetatable(self, Toggle)

        RenderEngine:ApplyCorner(self.Instance, theme.ElementCornerRadius)

        self.Value = config.Default or false
        self.Changed = Signal.new()
        self._callback = config.Callback

        self.Label = RenderEngine:Create("TextLabel", {
            Size = UDim2.new(1, -64, 1, 0),
            Position = UDim2.fromOffset(theme.Spacing.MD, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Toggle",
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance,
        })

        self.Track = RenderEngine:Create("Frame", {
            Name = "Track",
            Size = UDim2.fromOffset(40, 22),
            Position = UDim2.new(1, -(40 + theme.Spacing.MD), 0.5, -11),
            BackgroundColor3 = self.Value and theme.Colors.ToggleOn or theme.Colors.ToggleOff,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Track, UDim.new(1, 0))

        self.Knob = RenderEngine:Create("Frame", {
            Name = "Knob",
            Size = UDim2.fromOffset(16, 16),
            Position = self.Value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = theme.Colors.Knob,
            Parent = self.Track,
        })
        RenderEngine:ApplyCorner(self.Knob, UDim.new(1, 0))

        -- hover na linha inteira
        self.Maid:Add(self.Instance.MouseEnter:Connect(function()
            RenderEngine:Animate(self.Instance, {
                BackgroundTransparency = 0,
                BackgroundColor3 = Library.Theme:Get().Colors.ElementBackground,
            })
        end))
        self.Maid:Add(self.Instance.MouseLeave:Connect(function()
            RenderEngine:Animate(self.Instance, { BackgroundTransparency = 1 })
        end))

        self.Maid:Add(self.Instance.MouseButton1Click:Connect(function()
            self:Set(not self.Value)
        end))

        if config.Callback and self.Value then
            task.spawn(config.Callback, self.Value)
        end

        return self
    end

    function Toggle:Set(value)
        self.Value = value
        local theme = Library.Theme:Get()

        RenderEngine:Animate(self.Track, {
            BackgroundColor3 = value and theme.Colors.ToggleOn or theme.Colors.ToggleOff,
        })
        RenderEngine:Animate(self.Knob, {
            Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        }, TweenInfo.new(theme.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out))

        self.Changed:Fire(value)
        if self._callback then
            task.spawn(self._callback, value)
        end
    end

    function Toggle:ApplyTheme(theme)
        RenderEngine:Update(self.Label, { TextColor3 = theme.Colors.Text, Font = theme.Font })
        RenderEngine:Update(self.Track, {
            BackgroundColor3 = self.Value and theme.Colors.ToggleOn or theme.Colors.ToggleOff,
        })
        RenderEngine:Update(self.Knob, { BackgroundColor3 = theme.Colors.Knob })
    end

    return Toggle
end
