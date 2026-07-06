--[[
    Components/Page.lua

    Uma página da interface. Cada Page:
    - Aparece como um item na Sidebar (ícone + texto)
    - Pode conter várias Sections, cada uma também listada na Sidebar
      como sub-item colapsável (estilo árvore)
    - Tem um container de conteúdo (ScrollingFrame) mostrado na área
      central quando a página está ativa

    A Page NÃO se desenha na sidebar sozinha — ela expõe os dados
    (título, ícone, seções) e o App/Sidebar cuidam da navegação.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine
    local Widget = Library.Core.Widget

    local Page = setmetatable({}, { __index = Widget })
    Page.__index = Page

    function Page.new(config)
        config = config or {}
        local theme = Library.Theme:Get()

        -- container de conteúdo da página (fica no Content do App)
        local self = Widget.new("ScrollingFrame", {
            Name = "Page_" .. (config.Title or "Page"),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = theme.Colors.ElementBorder,
            ScrollBarImageTransparency = 0.3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = config.Parent,
        })
        setmetatable(self, Page)

        self.Title = config.Title or "Page"
        self.Icon = config.Icon  -- rbxassetid ou nil
        self.Sections = {}
        self._sectionWidgets = {}

        RenderEngine:ApplyPadding(self.Instance, { All = theme.Layout.ContentPadding })

        RenderEngine:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, theme.Layout.SectionGap),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Instance,
        })

        return self
    end

    -- Cria uma Section, registra para a sidebar e devolve para encadear
    function Page:AddSection(config)
        config = config or {}
        config.Parent = self.Instance
        local section = Library.Components.Section.new(config)
        section.Title = config.Title or ("Seção " .. (#self.Sections + 1))
        section.Icon = config.Icon
        table.insert(self.Sections, section)
        return section
    end

    function Page:SetActive(active)
        self:SetVisible(active)
    end

    return Page
end
