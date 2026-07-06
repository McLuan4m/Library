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
            Parent = inst,
        })
    end

    return RenderEngine
end
