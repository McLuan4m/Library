--[[
    Components/Button.lua

    Botão clicável com feedback visual refinado:
    - Hover suave (background + borda acendem)
    - "press" com leve encolhimento
    - Variante de acento (config.Primary = true) preenchida na cor de destaque
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local Signal = Library.Utility.Signal

    local Button = setmetatable({}, { __index = Widget })
    Button.__index = Button

    function Button.new(config)
        config = config or {}
        local theme = Library.Theme:Get()
        local primary = config.Primary == true

        local bg = primary and theme.Colors.Accent or theme.Colors.ElementBackground
        local txt = primary and Color3.fromRGB(255, 255, 255) or theme.Colors.Text

        local self = Widget.new("TextButton", {
            Name = "Button",
            Size = UDim2.new(1, 0, 0, theme.ElementHeight),
            BackgroundColor3 = bg,
            AutoButtonColor = false,
            Text = config.Text or "Button",
            Font = theme.FontMedium,
            TextSize = theme.TextSize,
            TextColor3 = txt,
            Parent = config.Parent,
        })
        setmetatable(self, Button)

        self._primary = primary
        RenderEngine:ApplyCorner(self.Instance, theme.ElementCornerRadius)

        if not primary then
            self._stroke = RenderEngine:ApplyStroke(self.Instance, theme.Colors.ElementBorder)
        end

        self.Clicked = Signal.new()

        self.Maid:Add(self.Instance.MouseEnter:Connect(function()
            local t = Library.Theme:Get()
            RenderEngine:Animate(self.Instance, {
                BackgroundColor3 = primary and t.Colors.AccentHover or t.Colors.ElementBackgroundHover,
            })
            if self._stroke then
                RenderEngine:Animate(self._stroke, { Color = t.Colors.ElementBorderHover })
            end
        end))

        self.Maid:Add(self.Instance.MouseLeave:Connect(function()
            local t = Library.Theme:Get()
            RenderEngine:Animate(self.Instance, {
                BackgroundColor3 = primary and t.Colors.Accent or t.Colors.ElementBackground,
            })
            if self._stroke then
                RenderEngine:Animate(self._stroke, { Color = t.Colors.ElementBorder })
            end
        end))

        -- feedback de "press"
        self.Maid:Add(self.Instance.MouseButton1Down:Connect(function()
            local t = Library.Theme:Get()
            RenderEngine:Animate(self.Instance, {
                BackgroundColor3 = primary and t.Colors.AccentMuted or t.Colors.ElementBackgroundActive,
            }, TweenInfo.new(theme.AnimationSpeedFast))
        end))

        self.Maid:Add(self.Instance.MouseButton1Click:Connect(function()
            self.Clicked:Fire()
            if config.Callback then
                task.spawn(config.Callback)
            end
        end))

        return self
    end

    function Button:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, {
            BackgroundColor3 = self._primary and theme.Colors.Accent or theme.Colors.ElementBackground,
            TextColor3 = self._primary and Color3.fromRGB(255,255,255) or theme.Colors.Text,
            Font = theme.FontMedium,
        })
    end

    return Button
end
