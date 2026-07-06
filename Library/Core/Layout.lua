--[[
    Core/Layout.lua

    Sistema de layout reutilizável. Abstrai UIGridLayout, UIListLayout
    e UITableLayout do Roblox por trás de uma API única, para que os
    componentes solicitem "grade de N colunas", "lista vertical", etc.
    sem lidar com os detalhes de cada layout nativo.

    Todos os valores de espaçamento vêm do tema (theme.Spacing / theme.Layout),
    garantindo alinhamento e ritmo visual consistentes em toda a UI.
]]

return function(Library)
    local RenderEngine = Library.Core.RenderEngine

    local Layout = {}

    -- Lista vertical simples (o caso mais comum: empilhar controles)
    function Layout:VList(parent, gap)
        local theme = Library.Theme:Get()
        return RenderEngine:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, gap or theme.Spacing.SM),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = parent,
        })
    end

    -- Lista horizontal (ex: linha de botões, itens da topbar)
    function Layout:HList(parent, gap, align)
        local theme = Library.Theme:Get()
        return RenderEngine:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, gap or theme.Spacing.SM),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
            Parent = parent,
        })
    end

    -- Grade de N colunas com células de mesma largura. As células se
    -- redimensionam para preencher a largura disponível (responsivo).
    -- cellHeight em pixels; columns = número de colunas.
    function Layout:Grid(parent, columns, cellHeight, gap)
        local theme = Library.Theme:Get()
        gap = gap or theme.Spacing.SM
        columns = columns or 2

        -- calcula a fração de largura por célula descontando os gaps
        local totalGap = gap * (columns - 1)
        local grid = RenderEngine:Create("UIGridLayout", {
            CellSize = UDim2.new(1 / columns, -(totalGap / columns), 0, cellHeight or theme.ElementHeight),
            CellPadding = UDim2.fromOffset(gap, gap),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirectionMaxCells = columns,
            Parent = parent,
        })
        return grid
    end

    -- Ajuda a manter proporção: usa UIAspectRatioConstraint quando útil
    function Layout:AspectRatio(inst, ratio)
        return RenderEngine:Create("UIAspectRatioConstraint", {
            AspectRatio = ratio,
            Parent = inst,
        })
    end

    return Layout
end
