--[[
    Components/Label.lua

    Texto sem interação. Suporta variantes via config.Variant:
    - "section" : título de seção em caixa alta, esmaecido (separador visual)
    - "title"   : texto de destaque em negrito
    - default   : texto normal esmaecido
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget

    local Label = setmetatable({}, { __index = Widget })
    Label.__index = Label

    function Label.new(config)
        config = config or {}
        local theme = Library.Theme:Get()
        local variant = config.Variant or "default"

        local font = theme.Font
        local color = theme.Colors.TextMuted
        local size = theme.TextSize
        local text = config.Text or "Label"
        local height = 20

        if variant == "section" then
            font = theme.FontBold
            color = theme.Colors.TextDim
            size = 11
            text = string.upper(text)
            height = 22
        elseif variant == "title" then
            font = theme.FontBold
            color = theme.Colors.Text
            size = theme.TitleTextSize
            height = 24
        end

        local self = Widget.new("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, 0, 0, height),
            BackgroundTransparency = 1,
            Text = text,
            Font = font,
            TextSize = size,
            TextColor3 = color,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Bottom,
            Parent = config.Parent,
        })
        setmetatable(self, Label)

        self._variant = variant

        -- letter spacing simulado para section (via RichText não dá, então
        -- mantemos simples; a caixa alta já cria a separação visual desejada)

        return self
    end

    function Label:SetText(text)
        if self._variant == "section" then text = string.upper(text) end
        RenderEngine:Update(self.Instance, { Text = text })
    end

    function Label:ApplyTheme(theme)
        local color = theme.Colors.TextMuted
        if self._variant == "section" then color = theme.Colors.TextDim
        elseif self._variant == "title" then color = theme.Colors.Text end
        RenderEngine:Update(self.Instance, { TextColor3 = color })
    end

    return Label
end
