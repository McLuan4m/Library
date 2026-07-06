--[[
    Components/Section.lua

    Um grupo de controles dentro de uma Page. Renderiza como um "card"
    com título opcional e um container interno que aceita os componentes
    (Button, Toggle, Slider, Dropdown, Label) via os mesmos métodos AddXxx.

    Suporta layout em grade: config.Columns define quantas colunas os
    controles ocupam (padrão 1 = lista vertical).
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget
    local LayoutSys = Library.Core.Layout

    local Section = setmetatable({}, { __index = Widget })
    Section.__index = Section

    function Section.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        local self = Widget.new("Frame", {
            Name = "Section",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Colors.Surface,
            BorderSizePixel = 0,
            Parent = config.Parent,
        })
        setmetatable(self, Section)

        self._columns = config.Columns or 1

        RenderEngine:ApplyCorner(self.Instance, theme.CornerRadius)
        RenderEngine:ApplyStroke(self.Instance, theme.Colors.WindowBorder)
        RenderEngine:ApplyPadding(self.Instance, { All = theme.Spacing.MD })

        -- UIScale usado para a animação de entrada (independente do layout)
        self._scale = RenderEngine:Create("UIScale", {
            Scale = 1,
            Parent = self.Instance,
        })

        -- layout vertical do card: [título] depois [container de controles]
        RenderEngine:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, theme.Spacing.SM),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Instance,
        })

        if config.Title then
            self.TitleLabel = RenderEngine:Create("TextLabel", {
                Name = "SectionTitle",
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = config.Title,
                Font = theme.FontBold,
                TextSize = theme.TextSize,
                TextColor3 = theme.Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 0,
                Parent = self.Instance,
            })
        end

        -- container onde os controles são realmente colocados
        self.Body = RenderEngine:Create("Frame", {
            Name = "Body",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Parent = self.Instance,
        })

        if self._columns > 1 then
            LayoutSys:Grid(self.Body, self._columns, theme.ElementHeight, theme.Spacing.SM)
        else
            LayoutSys:VList(self.Body, theme.Spacing.SM)
        end

        return self
    end

    function Section:ApplyTheme(theme)
        RenderEngine:Update(self.Instance, { BackgroundColor3 = theme.Colors.Surface })
        if self.TitleLabel then
            RenderEngine:Update(self.TitleLabel, { TextColor3 = theme.Colors.Text })
        end
    end

    -- Animação de entrada: leve "pop" de escala (0.96 -> 1) com delay.
    -- Usada pela Page para criar o efeito de cascata (stagger).
    function Section:PlayEntrance(delay)
        if not self._scale then return end
        local theme = Library.Theme:Get()
        self._scale.Scale = 0.96
        task.delay(delay or 0, function()
            if self._scale and self._scale.Parent then
                RenderEngine:Animate(self._scale, { Scale = 1 },
                    TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
            end
        end)
    end

    -- Métodos de conveniência (delegam ao Body)
    function Section:AddButton(c)   c = c or {}; c.Parent = self.Body; return Library.Components.Button.new(c) end
    function Section:AddToggle(c)   c = c or {}; c.Parent = self.Body; return Library.Components.Toggle.new(c) end
    function Section:AddSlider(c)   c = c or {}; c.Parent = self.Body; return Library.Components.Slider.new(c) end
    function Section:AddDropdown(c) c = c or {}; c.Parent = self.Body; return Library.Components.Dropdown.new(c) end
    function Section:AddLabel(c)    c = c or {}; c.Parent = self.Body; return Library.Components.Label.new(c) end

    return Section
end
