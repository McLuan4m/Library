--[[
    Core/RenderEngine.lua

    Camada central de renderização. NENHUM componente deve chamar
    Instance.new(...) diretamente — tudo passa pelo RenderEngine,
    que:

    - Cria e destrói Instances (Frame, TextLabel, UICorner, UIStroke...)
    - Aplica Dirty Flags: só atualiza propriedades que mudaram
    - Gerencia Z-Order (LayoutOrder / ZIndex)
    - Aplica tema (cores, fontes) de forma centralizada
    - Controla animações via TweenService
    - Reaproveita instances quando possível (pool simples)

    Fluxo:
    Component -> Widget -> RenderEngine -> Instance real na tela
]]

return function(Library)
    local Services = Library.Services
    local TweenService = Services.TweenService

    local RenderEngine = {}
    RenderEngine._pool = {}        -- pool de instances reaproveitáveis por tipo
    RenderEngine._zCounter = 0     -- controla ordem de criação/ZIndex global

    -- Cria (ou reaproveita do pool) uma Instance do tipo pedido
    function RenderEngine:Create(className, props, children)
        local inst

        local pool = self._pool[className]
        if pool and #pool > 0 then
            inst = table.remove(pool)
        else
            inst = Instance.new(className)
        end

        self._zCounter += 1
        if inst:IsA("GuiObject") then
            inst.ZIndex = props and props.ZIndex or self._zCounter
        end

        if props then
            self:Update(inst, props)
        end

        if children then
            for _, child in ipairs(children) do
                child.Parent = inst
            end
        end

        return inst
    end

    -- Atualiza SOMENTE propriedades que realmente mudaram (dirty flag simples)
    function RenderEngine:Update(inst, props)
        for key, value in pairs(props) do
            if key ~= "ZIndex" then
                local ok, current = pcall(function() return inst[key] end)
                if not ok or current ~= value then
                    inst[key] = value
                end
            end
        end
    end

    -- Devolve a instance ao pool em vez de destruir de fato (object pooling)
    function RenderEngine:Recycle(inst)
        if not inst then return end
        local className = inst.ClassName
        self._pool[className] = self._pool[className] or {}

        inst.Parent = nil
        table.insert(self._pool[className], inst)
    end

    -- Destrói definitivamente (usar quando não faz sentido reaproveitar)
    function RenderEngine:Destroy(inst)
        if inst then
            inst:Destroy()
        end
    end

    -- Anima propriedades usando o tema ativo para duração/easing por padrão
    function RenderEngine:Animate(inst, goalProps, overrideInfo)
        local theme = Library.Theme:Get()
        local info = overrideInfo or TweenInfo.new(
            theme.AnimationSpeed,
            theme.EasingStyle,
            theme.EasingDirection
        )
        local tween = TweenService:Create(inst, info, goalProps)
        tween:Play()
        return tween
    end

    -- Helper para aplicar cantos arredondados de acordo com o tema
    function RenderEngine:ApplyCorner(inst, radius)
        local theme = Library.Theme:Get()
        return self:Create("UICorner", {
            CornerRadius = radius or theme.CornerRadius,
            Parent = inst,
        })
    end

    -- Helper para aplicar borda de acordo com o tema
    function RenderEngine:ApplyStroke(inst, color, thickness)
        local theme = Library.Theme:Get()
        return self:Create("UIStroke", {
            Color = color or theme.Colors.ElementBorder,
            Thickness = thickness or theme.BorderThickness,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = inst,
        })
    end

    -- Aplica padding interno uniforme (ou por lado) usando a escala do tema
    function RenderEngine:ApplyPadding(inst, padding)
        padding = padding or {}
        return self:Create("UIPadding", {
            PaddingTop    = UDim.new(0, padding.Top or padding.All or 0),
            PaddingBottom = UDim.new(0, padding.Bottom or padding.All or 0),
            PaddingLeft   = UDim.new(0, padding.Left or padding.All or 0),
            PaddingRight  = UDim.new(0, padding.Right or padding.All or 0),
            Parent = inst,
        })
    end

    -- Aplica um gradiente sutil vertical (dá profundidade às superfícies)
    function RenderEngine:ApplyGradient(inst, topColor, bottomColor, rotation)
        return self:Create("UIGradient", {
            Color = ColorSequence.new(topColor, bottomColor),
            Rotation = rotation or 90,
            Parent = inst,
        })
    end

    -- Cria uma sombra "drop shadow" atrás de `target`, usando uma imagem
    -- de glow radial. Fica em um ZIndex abaixo do alvo.
    function RenderEngine:ApplyShadow(target, config)
        config = config or {}
        local theme = Library.Theme:Get()
        local size = config.Size or theme.Shadow.Size

        local shadow = self:Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, size, 1, size),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6014261993", -- glow radial suave (asset padrão)
            ImageColor3 = config.Color or Color3.fromRGB(0, 0, 0),
            ImageTransparency = config.Transparency or theme.Shadow.Transparency,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = 0,
            Parent = target,
        })
        return shadow
    end

    -- Aplica um "glow" colorido ao redor de um elemento via UIStroke.
    -- Retorna o stroke para que possa ser animado (transparência) no hover.
    function RenderEngine:ApplyGlow(inst, color, thickness)
        local theme = Library.Theme:Get()
        local glow = self:Create("UIStroke", {
            Name = "Glow",
            Color = color or theme.Colors.AccentGlow,
            Thickness = thickness or 1.5,
            Transparency = 1,   -- começa invisível; anima no hover
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = inst,
        })
        return glow
    end

    -- Anima a entrada de um elemento: desliza levemente de baixo + fade.
    -- offset = deslocamento inicial em pixels (padrão 8). delay escalona.
    function RenderEngine:SlideIn(inst, delay, offset)
        offset = offset or 8
        delay = delay or 0
        local theme = Library.Theme:Get()

        local finalPos = inst.Position
        inst.Position = finalPos + UDim2.fromOffset(0, offset)

        task.delay(delay, function()
            if inst and inst.Parent then
                TweenService:Create(inst,
                    TweenInfo.new(theme.AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    { Position = finalPos }
                ):Play()
            end
        end)
    end

    -- Cria uma animação de "respiração" (pulse) que fica em loop suave.
    -- Alterna uma propriedade entre dois valores indefinidamente.
    -- Retorna uma função para parar o loop.
    function RenderEngine:Pulse(inst, prop, valueA, valueB, period)
        period = period or 1.6
        local running = true
        local info = TweenInfo.new(period, Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut, -1, true)  -- -1 = repete, true = reverte
        local tween = TweenService:Create(inst, info, { [prop] = valueB })
        inst[prop] = valueA
        tween:Play()
        return function()
            running = false
            tween:Cancel()
        end
    end

    return RenderEngine
end
