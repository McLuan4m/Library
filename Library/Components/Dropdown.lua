--[[
    Components/Dropdown.lua

    Lista suspensa de opções. Ao clicar, expande/recolhe um painel
    com botões de opção; ao selecionar, fecha e dispara Signal/Callback.
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
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            ClipsDescendants = false,
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
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = theme.Colors.ElementBackground,
            AutoButtonColor = false,
            Text = "",
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Head)
        RenderEngine:ApplyStroke(self.Head)

        self.HeadLabel = RenderEngine:Create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Text = tostring(self.Value or "Selecione"),
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.Colors.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Head,
        })

        self.Panel = RenderEngine:Create("Frame", {
            Name = "Panel",
            Size = UDim2.new(1, 0, 0, #options * 28),
            Position = UDim2.new(0, 0, 0, 36),
            BackgroundColor3 = theme.Colors.ElementBackground,
            Visible = false,
            ZIndex = 5,
            Parent = self.Instance,
        })
        RenderEngine:ApplyCorner(self.Panel)
        RenderEngine:ApplyStroke(self.Panel)

        self.PanelLayout = RenderEngine:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Panel,
        })

        self._optionButtons = {}
        for _, optionValue in ipairs(options) do
            local optBtn = RenderEngine:Create("TextButton", {
                Name = "Option",
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = tostring(optionValue),
                Font = theme.Font,
                TextSize = theme.TextSize,
                TextColor3 = theme.Colors.TextMuted,
                ZIndex = 6,
                Parent = self.Panel,
            })
            table.insert(self._optionButtons, optBtn)

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
        RenderEngine:Update(self.Panel, { Visible = open })
    end

    function Dropdown:Select(value)
        self.Value = value
        RenderEngine:Update(self.HeadLabel, { Text = tostring(value) })
        self.Changed:Fire(value)
        if self._callback then
            task.spawn(self._callback, value)
        end
    end

    function Dropdown:ApplyTheme(theme)
        RenderEngine:Update(self.Head, { BackgroundColor3 = theme.Colors.ElementBackground })
        RenderEngine:Update(self.HeadLabel, { TextColor3 = theme.Colors.Text, Font = theme.Font })
        RenderEngine:Update(self.Panel, { BackgroundColor3 = theme.Colors.ElementBackground })
    end

    return Dropdown
end
