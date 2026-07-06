--[[
    Components/Label.lua

    Texto simples, sem interação.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget

    local Label = setmetatable({}, { __index = Widget })
    Label.__index = Label

    function Label.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        local self = Widget.new("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = config.Text or "Label",
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = config.Parent,
        })
        setmetatable(self, Label)

        return self
    end

    function Label:SetText(text)
        RenderEngine:Update(self.Instance, { Text = text })
    end

    function Label:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, {
            Font = theme.Font,
            TextColor3 = theme.Colors.TextMuted,
        })
    end

    return Label
end
