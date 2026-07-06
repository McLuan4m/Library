--[[
    Components/Slider.lua

    Slider numérico arrastável (min/max/default), com Signal de
    mudança e callback opcional.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local Signal = Library.Utility.Signal
    local Services = Library.Services
    local UserInputService = Services.UserInputService

    local Slider = setmetatable({}, { __index = Widget })
    Slider.__index = Slider

    local function round(n, step)
        step = step or 1
        return math.floor((n / step) + 0.5) * step
    end

    function Slider.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        local min = config.Min or 0
        local max = config.Max or 100
        local step = config.Step or 1
        local default = config.Default or min

        local self = Widget.new("Frame", {
            Name = "Slider",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = config.Parent,
        })
        setmetatable(self, Slider)

        self.Min, self.Max, self.Step = min, max, step
        self.Value = default
        self.Changed = Signal.new()
        self._callback = config.Callback

        self.Label = RenderEngine:Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = (config.Text or "Slider") .. ": " .. tostring(default),
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance,
        })

        self.Track = RenderEngine:Create("Frame", {
            Name = "Track",
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.fromOffset(0, 24),
            BackgroundColor3 = theme.Colors.ElementBackground,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Track, UDim.new(1, 0))

        self.Fill = RenderEngine:Create("Frame", {
            Name = "Fill",
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
            BackgroundColor3 = theme.Colors.Accent,
            Parent = self.Track,
        })
        RenderEngine:ApplyCorner(self.Fill, UDim.new(1, 0))

        self.Knob = RenderEngine:Create("TextButton", {
            Name = "Knob",
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
            Text = "",
            BackgroundColor3 = Color3.new(1, 1, 1),
            Parent = self.Track,
        })
        RenderEngine:ApplyCorner(self.Knob, UDim.new(1, 0))

        local dragging = false

        local function setFromAlpha(alpha)
            alpha = math.clamp(alpha, 0, 1)
            local rawValue = min + (max - min) * alpha
            local value = round(rawValue, step)
            value = math.clamp(value, min, max)
            self:Set(value, true)
        end

        self.Maid:Add(self.Knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end))

        self.Maid:Add(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))

        self.Maid:Add(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local trackPos = self.Track.AbsolutePosition.X
                local trackSize = self.Track.AbsoluteSize.X
                local alpha = (input.Position.X - trackPos) / trackSize
                setFromAlpha(alpha)
            end
        end))

        return self
    end

    function Slider:Set(value, skipCallback)
        value = math.clamp(value, self.Min, self.Max)
        self.Value = value
        local alpha = (value - self.Min) / (self.Max - self.Min)

        RenderEngine:Update(self.Fill, { Size = UDim2.new(alpha, 0, 1, 0) })
        RenderEngine:Update(self.Knob, { Position = UDim2.new(alpha, -7, 0.5, -7) })

        local baseText = self.Label.Text:match("^(.-):") or "Slider"
        RenderEngine:Update(self.Label, { Text = baseText .. ": " .. tostring(value) })

        self.Changed:Fire(value)
        if self._callback then
            task.spawn(self._callback, value)
        end
    end

    function Slider:ApplyTheme(theme)
        RenderEngine:Update(self.Label, { TextColor3 = theme.Colors.Text, Font = theme.Font })
        RenderEngine:Update(self.Track, { BackgroundColor3 = theme.Colors.ElementBackground })
        RenderEngine:Update(self.Fill, { BackgroundColor3 = theme.Colors.Accent })
    end

    return Slider
end
