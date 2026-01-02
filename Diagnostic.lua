-- Bee Swarm Simulator Token Finder (GUI Version)
-- Загрузи этот файл как Diagnostic.lua в свой репозиторий

local Player = game:GetService("Players").LocalPlayer

-- Создаём видимое окно диагностики
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TokenDiagnostic"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "🔍 ДИАГНОСТИКА ТОКЕНОВ BEE SWARM"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Поле вывода логов
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(0.95, 0, 0.7, 0)
LogFrame.Position = UDim2.new(0.025, 0, 0.12, 0)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogFrame.BackgroundTransparency = 0.2
LogFrame.ScrollBarThickness = 8
LogFrame.Parent = MainFrame

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogFrame

-- Контейнер для текста
local LogContainer = Instance.new("TextLabel")
LogContainer.Name = "LogText"
LogContainer.Size = UDim2.new(1, -10, 0, 1000)
LogContainer.Position = UDim2.new(0, 5, 0, 5)
LogContainer.BackgroundTransparency = 1
LogContainer.TextColor3 = Color3.fromRGB(200, 200, 255)
LogContainer.TextSize = 14
LogContainer.Font = Enum.Font.Code
LogContainer.TextXAlignment = Enum.TextXAlignment.Left
LogContainer.TextYAlignment = Enum.TextYAlignment.Top
LogContainer.TextWrapped = true
LogContainer.Text = "=== ДИАГНОСТИКА ЗАПУЩЕНА ===\n"
LogContainer.Parent = LogFrame

-- Функция добавления текста в лог
function AddLog(text, color)
    color = color or Color3.fromRGB(200, 200, 255)
    
    local timeStr = "[" .. os.date("%H:%M:%S") .. "] "
    local coloredText = "<font color='rgb(" .. 
        math.floor(color.r * 255) .. "," .. 
        math.floor(color.g * 255) .. "," .. 
        math.floor(color.b * 255) .. 
        ")'>" .. timeStr .. text .. "</font><br/>"
    
    LogContainer.Text = LogContainer.Text .. coloredText
    
    -- Автопрокрутка вниз
    wait(0.01)
    LogFrame.CanvasPosition = Vector2.new(0, LogContainer.AbsoluteSize.Y)
end

-- Создаём кнопки
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(0.95, 0, 0, 120)
ButtonContainer.Position = UDim2.new(0.025, 0, 0.84, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

-- Функция создания кнопки
function CreateButton(text, xPos, yPos, callback, color)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0.3, 0, 0, 35)
    button.Position = UDim2.new(xPos, 0, yPos, 0)
    button.BackgroundColor3 = color or Color3.fromRGB(60, 60, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = ButtonContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Создаём кнопки действий
CreateButton("📡 Сканировать", 0, 0, function()
    AddLog("Запуск сканирования объектов...", Color3.fromRGB(100, 200, 255))
    ScanForTokens()
end, Color3.fromRGB(0, 100, 200))

CreateButton("🎯 Найти токены", 0.34, 0, function()
    AddLog("Поиск токенов вокруг...", Color3.fromRGB(100, 200, 255))
    FindNearbyTokens()
end, Color3.fromRGB(0, 150, 100))

CreateButton("⏱️ Мониторинг", 0.68, 0, function()
    AddLog("Запуск мониторинга на 60 сек...", Color3.fromRGB(100, 200, 255))
    StartMonitoring(60)
end, Color3.fromRGB(150, 100, 0))

CreateButton("🧪 Тест сбора", 0, 0.4, function()
    AddLog("Тестирование методов сбора...", Color3.fromRGB(100, 200, 255))
    TestCollectionMethods()
end, Color3.fromRGB(150, 0, 150))

CreateButton("🗑️ Очистить лог", 0.34, 0.4, function()
    LogContainer.Text = "=== ЛОГ ОЧИЩЕН ===\n"
    AddLog("Лог очищен", Color3.fromRGB(255, 100, 100))
end, Color3.fromRGB(200, 50, 50))

CreateButton("❌ Закрыть", 0.68, 0.4, function()
    ScreenGui:Destroy()
end, Color3.fromRGB(200, 0, 0))

-- Функция сканирования объектов
function ScanForTokens()
    AddLog("🔍 Анализирую объекты в игре...", Color3.fromRGB(255, 255, 100))
    
    local objects = {}
    local tokenCandidates = {}
    
    -- Собираем все объекты
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            table.insert(objects, {
                Name = obj.Name,
                Class = obj.ClassName
            })
            
            -- Проверяем, похож ли на токен
            local nameLower = obj.Name:lower()
            if nameLower:find("token") or nameLower:find("boost") or 
               nameLower:find("orb") or nameLower:find("ball") then
                table.insert(tokenCandidates, obj)
            end
        end
    end
    
    AddLog("Найдено объектов: " .. #objects, Color3.fromRGB(100, 255, 100))
    AddLog("Кандидатов в токены: " .. #tokenCandidates, Color3.fromRGB(255, 200, 100))
    
    if #tokenCandidates > 0 then
        AddLog("🎯 ВОЗМОЖНЫЕ ТОКЕНЫ:", Color3.fromRGB(255, 255, 0))
        
        -- Группируем по названиям
        local nameCount = {}
        for _, obj in ipairs(tokenCandidates) do
            nameCount[obj.Name] = (nameCount[obj.Name] or 0) + 1
        end
        
        -- Сортируем
        local sortedNames = {}
        for name, count in pairs(nameCount) do
            table.insert(sortedNames, {name = name, count = count})
        end
        
        table.sort(sortedNames, function(a, b) return a.count > b.count end)
        
        for i, data in ipairs(sortedNames) do
            AddLog("  " .. data.name .. " - " .. data.count .. " шт", Color3.fromRGB(200, 200, 255))
        end
        
        AddLog("💡 СКОПИРУЙ ЭТО НАЗВАНИЕ МНЕ: " .. sortedNames[1].name, Color3.fromRGB(0, 255, 0))
    else
        AddLog("⚠️ Кандидаты не найдены. Попробуй зайти на поле.", Color3.fromRGB(255, 100, 100))
    end
    
    -- Топ общих объектов
    local allNames = {}
    for _, obj in ipairs(objects) do
        allNames[obj.Name] = (allNames[obj.Name] or 0) + 1
    end
    
    local topNames = {}
    for name, count in pairs(allNames) do
        table.insert(topNames, {name = name, count = count})
    end
    
    table.sort(topNames, function(a, b) return a.count > b.count end)
    
    AddLog("\n📊 ТОП-10 ОБЪЕКТОВ В ИГРЕ:", Color3.fromRGB(100, 200, 255))
    for i = 1, math.min(10, #topNames) do
        AddLog(string.format("%2d. %-25s - %4d шт", 
            i, topNames[i].name, topNames[i].count), Color3.fromRGB(180, 180, 255))
    end
end

-- Функция поиска ближайших токенов
function FindNearbyTokens()
    local character = Player.Character
    if not character then
        AddLog("❌ Персонаж не найден", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        AddLog("❌ Не могу найти корневую часть", Color3.fromRGB(255, 100, 100))
        return
    end
    
    AddLog("🔎 Ищу токены в радиусе 50 studs...", Color3.fromRGB(255, 200, 100))
    
    local foundTokens = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local distance = (root.Position - obj.Position).Magnitude
            if distance < 50 then
                local nameLower = obj.Name:lower()
                if nameLower:find("token") or nameLower:find("boost") or 
                   nameLower:find("orb") or nameLower:find("ball") then
                    
                    table.insert(foundTokens, {
                        object = obj,
                        name = obj.Name,
                        distance = distance,
                        position = obj.Position
                    })
                end
            end
        end
    end
    
    AddLog("Найдено токенов рядом: " .. #foundTokens, Color3.fromRGB(100, 255, 100))
    
    if #foundTokens > 0 then
        -- Сортируем по расстоянию
        table.sort(foundTokens, function(a, b) return a.distance < b.distance end)
        
        for i, token in ipairs(foundTokens) do
            AddLog(string.format("%d. %s (расстояние: %d)", 
                i, token.name, math.floor(token.distance)), Color3.fromRGB(200, 255, 200))
        end
    else
        AddLog("Рядом нет токенов. Подойди ближе к полю.", Color3.fromRGB(255, 150, 100))
    end
end

-- Функция мониторинга в реальном времени
function StartMonitoring(duration)
    AddLog("🎥 Начинаю мониторинг новых объектов...", Color3.fromRGB(255, 200, 0))
    AddLog("Время мониторинга: " .. duration .. " сек", Color3.fromRGB(200, 200, 255))
    
    local newObjects = {}
    local startTime = tick()
    
    -- Отслеживаем новые объекты
    local connection = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then
            local nameLower = obj.Name:lower()
            
            if nameLower:find("token") or nameLower:find("boost") or 
               nameLower:find("orb") or nameLower:find("ball") then
                
                -- Проверяем, не добавляли ли уже
                local alreadyAdded = false
                for _, addedObj in ipairs(newObjects) do
                    if addedObj.object == obj then
                        alreadyAdded = true
                        break
                    end
                end
                
                if not alreadyAdded then
                    table.insert(newObjects, {
                        object = obj,
                        name = obj.Name,
                        time = tick() - startTime
                    })
                    
                    AddLog("🆕 Появился: " .. obj.Name .. " (через " .. 
                        math.floor(tick() - startTime) .. " сек)", Color3.fromRGB(0, 255, 0))
                end
            end
        end
    end)
    
    -- Таймер
    spawn(function()
        for i = 1, duration do
            wait(1)
            if i % 10 == 0 then
                AddLog("⏱️ Мониторинг: " .. i .. "/" .. duration .. " сек", 
                    Color3.fromRGB(150, 150, 255))
            end
        end
        
        -- Останавливаем мониторинг
        connection:Disconnect()
        
        AddLog("✅ Мониторинг завершён!", Color3.fromRGB(100, 255, 100))
        AddLog("Всего новых объектов: " .. #newObjects, Color3.fromRGB(255, 255, 100))
        
        if #newObjects > 0 then
            AddLog("🎯 САМЫЕ ЧАСТЫЕ НАЗВАНИЯ:", Color3.fromRGB(255, 200, 0))
            
            local nameCount = {}
            for _, objData in ipairs(newObjects) do
                nameCount[objData.name] = (nameCount[objData.name] or 0) + 1
            end
            
            for name, count in pairs(nameCount) do
                AddLog("  " .. name .. " - " .. count .. " раз", Color3.fromRGB(200, 255, 200))
            end
        end
    end)
end

-- Функция тестирования методов сбора
function TestCollectionMethods()
    AddLog("🧪 Тестирую методы сбора...", Color3.fromRGB(255, 150, 0))
    
    local character = Player.Character
    if not character then
        AddLog("❌ Персонаж не найден", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        AddLog("❌ HumanoidRootPart не найден", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Ищем ближайший объект для теста
    local testObject = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nameLower = obj.Name:lower()
            if nameLower:find("token") or nameLower:find("boost") then
                testObject = obj
                break
            end
        end
    end
    
    if not testObject then
        AddLog("⚠️ Не нашёл объект для теста", Color3.fromRGB(255, 150, 100))
        AddLog("Подойди к полю с токенами", Color3.fromRGB(255, 150, 100))
        return
    end
    
    AddLog("Тестирую объект: " .. testObject.Name, Color3.fromRGB(255, 255, 100))
    
    -- Тест 1: TouchInterest
    AddLog("Проверяю TouchInterest...", Color3.fromRGB(200, 200, 255))
    pcall(function()
        firetouchinterest(root, testObject, 0)
        firetouchinterest(root, testObject, 1)
        AddLog("  ✅ TouchInterest выполнен", Color3.fromRGB(100, 255, 100))
    end)
    
    -- Тест 2: ProximityPrompt
    AddLog("Проверяю ProximityPrompt...", Color3.fromRGB(200, 200, 255))
    if testObject:FindFirstChildWhichIsA("ProximityPrompt") then
        pcall(function()
            fireproximityprompt(testObject:FindFirstChildWhichIsA("ProximityPrompt"))
            AddLog("  ✅ ProximityPrompt найден и активирован", Color3.fromRGB(100, 255, 100))
        end)
    else
        AddLog("  ❌ ProximityPrompt не найден", Color3.fromRGB(255, 100, 100))
    end
    
    -- Тест 3: RemoteEvents
    AddLog("Проверяю RemoteEvents...", Color3.fromRGB(200, 200, 255))
    if game:GetService("ReplicatedStorage"):FindFirstChild("Events") then
        local events = game:GetService("ReplicatedStorage").Events
        for _, event in pairs(events:GetChildren()) do
            if event:IsA("RemoteEvent") then
                pcall(function()
                    event:FireServer(testObject.Name, testObject.Position)
                    AddLog("  ✅ Отправлен запрос к: " .. event.Name, Color3.fromRGB(100, 255, 100))
                end)
            end
        end
    else
        AddLog("  ❌ Папка Events не найдена", Color3.fromRGB(255, 100, 100))
    end
    
    AddLog("✅ Тестирование завершено", Color3.fromRGB(100, 255, 100))
end

-- Автоматически запускаем сканирование при старте
wait(1)
AddLog("🚀 Диагностический инструмент загружен!", Color3.fromRGB(0, 255, 0))
AddLog("Инструкция:", Color3.fromRGB(255, 255, 100))
AddLog("1. Зайди на поле (Sunflower, Pineapple и т.д.)", Color3.fromRGB(200, 200, 255))
AddLog("2. Нажми 'Сканировать'", Color3.fromRGB(200, 200, 255))
AddLog("3. Подожди пока пчёлы выбросят токены", Color3.fromRGB(200, 200, 255))
AddLog("4. Нажми 'Мониторинг' для отслеживания", Color3.fromRGB(200, 200, 255))
AddLog("5. Сообщи мне название токена из лога", Color3.fromRGB(255, 255, 0))
AddLog("", Color3.fromRGB(200, 200, 255))

-- Авто-сканирование через 3 секунды
wait(3)
AddLog("⏰ Автоматически сканирую через 3 секунды...", Color3.fromRGB(255, 200, 0))
wait(3)
ScanForTokens()
