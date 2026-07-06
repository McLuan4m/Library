--[[
    Components/Button.lua

    Botão clicável com feedback visual (hover/click) animado via
    RenderEngine:Animate, e Signal próprio para o callback OnClick.
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

        local self = Widget.new("TextButton", {
            Name = "Button",
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = theme.Colors.ElementBackground,
            AutoButtonColor = false,
            Text = config.Text or "Button",
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            Parent = config.Parent,
        })
        setmetatable(self, Button)

        RenderEngine:ApplyCorner(self.Instance)
        RenderEngine:ApplyStroke(self.Instance)

        self.Clicked = Signal.new()

        self.Maid:Add(self.Instance.MouseEnter:Connect(function()
            RenderEngine:Animate(self.Instance, {
                BackgroundColor3 = Library.Theme:Get().Colors.ElementBackgroundHover,
            })
        end))

        self.Maid:Add(self.Instance.MouseLeave:Connect(function()
            RenderEngine:Animate(self.Instance, {
                BackgroundColor3 = Library.Theme:Get().Colors.ElementBackground,
            })
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
            BackgroundColor3 = theme.Colors.ElementBackground,
            TextColor3 = theme.Colors.Text,
            Font = theme.Font,
        })
    end

    return Button
end
