# Library

Biblioteca de UI para Roblox, estilo ImGui, escrita inteiramente em Luau,
usando **Instances nativas do Roblox** (`Frame`, `TextLabel`, `UICorner`,
`TweenService` etc.) — não usa a Drawing API.

## Estrutura

```
Library/
├── init.lua          <- ponto de entrada / loader remoto
├── Core/             <- RenderEngine, Widget base, EventManager
├── Components/       <- Window, Button, Toggle, Slider, Dropdown, Label
├── Theme/             <- DefaultTheme, ThemeManager
├── Utility/          <- Signal, Maid
├── Services/         <- acesso centralizado a game:GetService
└── Assets/           <- ícones e recursos estáticos (futuro)
```

## Como publicar no GitHub

1. Crie um repositório (ex: `SEU_USUARIO/SEU_REPO`).
2. Faça upload de toda a pasta `Library/` mantendo a estrutura acima.
3. Abra `init.lua` e ajuste a constante `BASE_URL` para apontar para o
   **raw** do seu repositório e branch corretos, por exemplo:

   ```lua
   local BASE_URL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Library/"
   ```

4. Faça commit e push. Pronto — a partir daí, qualquer alteração em um
   módulo interno é refletida automaticamente para quem carregar a
   Library (sem precisar mudar nada no lado do usuário final).

## Como o carregamento remoto funciona

O `init.lua` não é um bundle único: ele é um **loader**. Ao ser executado,
ele busca cada submódulo individualmente via `game:HttpGet` seguindo a
mesma árvore de pastas do repositório, compila cada um com `loadstring`
e monta a tabela `Library` na ordem correta de dependências:

```
Utility -> Services -> Theme -> Core -> Components
```

Isso preserva a estrutura modular pedida (init.lua enxuto, cada
responsabilidade em seu próprio arquivo) mesmo sendo carregado 100%
remotamente, sem exigir que o usuário baixe nada manualmente.

## Uso pelo usuário final

```lua
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/Library/init.lua"
))()

local Window = Library:CreateWindow({
    Title = "Professional UI",
    Size = UDim2.fromOffset(480, 320),
})

Window:AddLabel({ Text = "Configurações" })

Window:AddButton({
    Text = "Executar ação",
    Callback = function()
        print("Botão clicado!")
    end,
})

Window:AddToggle({
    Text = "Ativar recurso",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

Window:AddSlider({
    Text = "Velocidade",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 1,
    Callback = function(value)
        print("Slider:", value)
    end,
})

Window:AddDropdown({
    Text = "Modo",
    Options = { "Fácil", "Normal", "Difícil" },
    Default = "Normal",
    Callback = function(value)
        print("Selecionado:", value)
    end,
})
```

## Trocando o tema

```lua
local MeuTema = table.clone(Library:GetTheme())
MeuTema.Colors.Accent = Color3.fromRGB(255, 80, 80)
Library:SetTheme(MeuTema)
```

Todos os componentes já registrados se atualizam automaticamente
(via `ThemeManager`), sem precisar recriar a interface.

## Arquitetura interna (resumo)

```
Component (Window, Button, Slider...)
        │
        ▼
Widget (Core/Widget.lua) — base com Maid + registro de tema
        │
        ▼
RenderEngine (Core/RenderEngine.lua) — cria/atualiza/recicla Instances,
                                        aplica dirty flags e animações
        │
        ▼
Instance real do Roblox (Frame, TextLabel, UICorner...)
        │
        ▼
PlayerGui / Tela
```

Nenhum componente chama `Instance.new` diretamente — tudo passa pelo
`RenderEngine`, o que mantém a lógica de UI desacoplada da camada de
renderização e facilita trocar/otimizar essa camada no futuro sem
alterar os componentes.

## Ambiente de desenvolvimento local (preview)

Como a renderização usa Instances reais do Roblox (não Drawing API),
o preview mais fiel continua sendo o **Roblox Studio** com um script
local chamando `Library:CreateWindow(...)`. Para agilizar iteração sem
reabrir o Studio a cada mudança, recomenda-se usar uma extensão de
sincronização de arquivos (ex: Rojo) apontando para esta mesma pasta
`Library/`, mantendo Studio aberto com auto-reload dos scripts.
