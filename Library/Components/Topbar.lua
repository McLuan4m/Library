--[[
    Components/Topbar.lua

    Barra superior: logo (opcional) + nome da library à esquerda,
    e uma área à direita reservada para ações futuras (botões, status).
    Também serve como "handle" para arrastar a janela inteira.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget

    local Topbar = setmetatable({}, { __index = Widget })
    Topbar.__index = Topbar

    function Topbar.new(config)
        config = config or {}
        local theme = Library.Theme:Get()
        local L = theme.Layout

        local self = Widget.new("Frame", {
            Name = "Topbar",
            Size = UDim2.new(1, 0, 0, L.TopbarHeight),
            BackgroundColor3 = theme.AppColors.TopbarBackground,
            BorderSizePixel = 0,
            Parent = config.Parent,
        })
        setmetatable(self, Topbar)

        -- divisor inferior
        RenderEngine:Create("Frame", {
            Name = "BottomBorder",
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = theme.Colors.Divider,
            BorderSizePixel = 0,
            Parent = self.Instance,
        })

        local x = theme.Spacing.LG

        -- logo (opcional)
        if config.Logo then
            self.Logo = RenderEngine:Create("ImageLabel", {
                Name = "Logo",
                Size = UDim2.fromOffset(22, 22),
                Position = UDim2.new(0, x, 0.5, -11),
                BackgroundTransparency = 1,
                Image = config.Logo,
                Parent = self.Instance,
            })
            x = x + 22 + theme.Spacing.SM
        else
            -- ponto de acento como "logo" padrão
            self.AccentDot = RenderEngine:Create("Frame", {
                Name = "AccentDot",
                Size = UDim2.fromOffset(10, 10),
                Position = UDim2.new(0, x, 0.5, -5),
                BackgroundColor3 = theme.Colors.Accent,
                Parent = self.Instance,
            })
            RenderEngine:ApplyCorner(self.AccentDot, UDim.new(1, 0))

            -- glow suave ao redor do dot, com respiração lenta (dá "vida")
            local dotGlow = RenderEngine:ApplyGlow(self.AccentDot, theme.Colors.AccentGlow, 2)
            self._stopPulse = RenderEngine:Pulse(dotGlow, "Transparency", 0.2, 0.75, 1.8)
            self.Maid:Add(function() if self._stopPulse then self._stopPulse() end end)

            x = x + 10 + theme.Spacing.SM
        end

        self.NameLabel = RenderEngine:Create("TextLabel", {
            Name = "Name",
            Size = UDim2.new(0, 200, 1, 0),
            Position = UDim2.fromOffset(x, 0),
            BackgroundTransparency = 1,
            Text = config.Name or "Library",
            Font = theme.FontBold,
            TextSize = theme.TitleTextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance,
        })

        -- área de ações à direita (container vazio para uso futuro)
        self.Actions = RenderEngine:Create("Frame", {
            Name = "Actions",
            Size = UDim2.new(0, 200, 1, 0),
            Position = UDim2.new(1, -200 - theme.Spacing.SM, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.Instance,
        })
        RenderEngine:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, theme.Spacing.SM),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Actions,
        })

        -- botão de fechar
        self.CloseButton = RenderEngine:Create("TextButton", {
            Name = "Close",
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.new(1, -(28 + theme.Spacing.MD), 0.5, -14),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "✕",
            Font = theme.FontBold,
            TextSize = 14,
            TextColor3 = theme.Colors.TextMuted,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.CloseButton, theme.ElementCornerRadius)

        self.Maid:Add(self.CloseButton.MouseEnter:Connect(function()
            RenderEngine:Animate(self.CloseButton, { BackgroundTransparency = 0,
                BackgroundColor3 = theme.Colors.Danger, TextColor3 = Color3.new(1,1,1) })
        end))
        self.Maid:Add(self.CloseButton.MouseLeave:Connect(function()
            RenderEngine:Animate(self.CloseButton, { BackgroundTransparency = 1,
                TextColor3 = theme.Colors.TextMuted })
        end))

        return self
    end

    function Topbar:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, { BackgroundColor3 = theme.AppColors.TopbarBackground })
        RenderEngine:Update(self.NameLabel, { TextColor3 = theme.Colors.Text })
        if self.AccentDot then
            RenderEngine:Update(self.AccentDot, { BackgroundColor3 = theme.Colors.Accent })
        end
    end

    return Topbar
end
