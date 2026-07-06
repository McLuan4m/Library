--[[
    Components/Slider.lua

    Slider numérico arrastável, visual refinado:
    - Label à esquerda + valor em "pill" à direita
    - Track fino com fill na cor de acento
    - Knob circular com borda, cresce levemente no hover/drag
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
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundTransparency = 1,
            Parent = config.Parent,
        })
        setmetatable(self, Slider)

        self.Min, self.Max, self.Step = min, max, step
        self.Value = default
        self.Changed = Signal.new()
        self._callback = config.Callback
        self._baseText = config.Text or "Slider"
        self._suffix = config.Suffix or ""

        self.Label = RenderEngine:Create("TextLabel", {
            Size = UDim2.new(1, -70, 0, 18),
            Position = UDim2.fromOffset(theme.Spacing.XS, 2),
            BackgroundTransparency = 1,
            Text = self._baseText,
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance,
        })

        -- Pill com o valor atual (à direita)
        self.ValuePill = RenderEngine:Create("Frame", {
            Name = "ValuePill",
            Size = UDim2.fromOffset(58, 20),
            Position = UDim2.new(1, -58, 0, 1),
            BackgroundColor3 = theme.Colors.ElementBackground,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.ValuePill, UDim.new(0, 5))
        RenderEngine:ApplyStroke(self.ValuePill, theme.Colors.ElementBorder)

        self.ValueLabel = RenderEngine:Create("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = tostring(default) .. self._suffix,
            Font = theme.FontMedium,
            TextSize = 12,
            TextColor3 = theme.Colors.Accent,
            Parent = self.ValuePill,
        })

        self.Track = RenderEngine:Create("Frame", {
            Name = "Track",
            Size = UDim2.new(1, -theme.Spacing.XS, 0, 5),
            Position = UDim2.fromOffset(theme.Spacing.XS, 32),
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

        self.Knob = RenderEngine:Create("Frame", {
            Name = "Knob",
            Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
            BackgroundColor3 = theme.Colors.Knob,
            Parent = self.Track,
        })
        RenderEngine:ApplyCorner(self.Knob, UDim.new(1, 0))
        RenderEngine:ApplyStroke(self.Knob, theme.Colors.Accent, 2)

        -- Hitbox invisível maior para facilitar o clique/drag na track
        self.Hitbox = RenderEngine:Create("TextButton", {
            Name = "Hitbox",
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 0.5, -12),
            BackgroundTransparency = 1,
            Text = "",
            Parent = self.Track,
        })

        local dragging = false

        local function setFromAlpha(alpha)
            alpha = math.clamp(alpha, 0, 1)
            local value = round(min + (max - min) * alpha, step)
            value = math.clamp(value, min, max)
            self:Set(value)
        end

        local function beginDrag()
            dragging = true
            RenderEngine:Animate(self.Knob, { Size = UDim2.fromOffset(18, 18), Position = UDim2.new(
                (self.Value - min) / (max - min), -9, 0.5, -9) }, TweenInfo.new(theme.AnimationSpeedFast))
        end
        local function endDrag()
            if not dragging then return end
            dragging = false
            RenderEngine:Animate(self.Knob, { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(
                (self.Value - min) / (max - min), -7, 0.5, -7) }, TweenInfo.new(theme.AnimationSpeedFast))
        end

        self.Maid:Add(self.Hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                beginDrag()
                local trackPos = self.Track.AbsolutePosition.X
                local trackSize = self.Track.AbsoluteSize.X
                setFromAlpha((input.Position.X - trackPos) / trackSize)
            end
        end))

        self.Maid:Add(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end))

        self.Maid:Add(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local trackPos = self.Track.AbsolutePosition.X
                local trackSize = self.Track.AbsoluteSize.X
                setFromAlpha((input.Position.X - trackPos) / trackSize)
            end
        end))

        return self
    end

    function Slider:Set(value)
        value = math.clamp(value, self.Min, self.Max)
        self.Value = value
        local alpha = (value - self.Min) / (self.Max - self.Min)

        -- metade da largura atual do knob (14 normal, 18 durante o drag)
        local half = (self.Knob.Size.X.Offset) / 2

        RenderEngine:Animate(self.Fill, { Size = UDim2.new(alpha, 0, 1, 0) },
            TweenInfo.new(0.06))
        RenderEngine:Update(self.Knob, {
            Position = UDim2.new(alpha, -half, 0.5, -half),
        })
        RenderEngine:Update(self.ValueLabel, { Text = tostring(value) .. self._suffix })

        self.Changed:Fire(value)
        if self._callback then
            task.spawn(self._callback, value)
        end
    end

    function Slider:ApplyTheme(theme)
        RenderEngine:Update(self.Label, { TextColor3 = theme.Colors.Text, Font = theme.Font })
        RenderEngine:Update(self.Track, { BackgroundColor3 = theme.Colors.ElementBackground })
        RenderEngine:Update(self.Fill, { BackgroundColor3 = theme.Colors.Accent })
        RenderEngine:Update(self.ValueLabel, { TextColor3 = theme.Colors.Accent })
    end

    return Slider
end
