--[[
    Components/Toggle.lua

    Switch on/off com estado interno e Signal de mudança.
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

        local self = Widget.new("Frame", {
            Name = "Toggle",
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Parent = config.Parent,
        })
        setmetatable(self, Toggle)

        self.Value = config.Default or false
        self.Changed = Signal.new()
        self._callback = config.Callback

        self.Label = RenderEngine:Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = config.Text or "Toggle",
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance,
        })

        self.Track = RenderEngine:Create("TextButton", {
            Name = "Track",
            Size = UDim2.fromOffset(40, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = self.Value and theme.Colors.ToggleOn or theme.Colors.ToggleOff,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Track, UDim.new(1, 0))

        self.Knob = RenderEngine:Create("Frame", {
            Name = "Knob",
            Size = UDim2.fromOffset(16, 16),
            Position = self.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Parent = self.Track,
        })
        RenderEngine:ApplyCorner(self.Knob, UDim.new(1, 0))

        self.Maid:Add(self.Track.MouseButton1Click:Connect(function()
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
            Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        })

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
    end

    return Toggle
end
