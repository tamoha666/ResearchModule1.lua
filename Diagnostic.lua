-- Bee Swarm Simulator Token Diagnostic Tool
-- Запусти через: loadstring(game:HttpGet('https://raw.githubusercontent.com/ВАШ_АККАУНТ/ВАШ_РЕПОЗИТОРИЙ/main/Diagnostic.lua'))()

local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

print("\n" .. string.rep("=", 60))
print("🔍 BEE SWARM TOKEN DIAGNOSTIC TOOL v1.0")
print(string.rep("=", 60))
print("Инструкция:")
print("1. Зайди на любое поле (Sunflower Field, Pineapple Patch и т.д.)")
print("2. Подожди 30-60 секунд пока пчёлы выбросят токены")
print("3. Смотри в консоль инжектора - там появятся названия объектов")
print(string.rep("=", 60))

-- Функция для поиска всех объектов, похожих на токены
function ScanForTokens()
    print("\n📡 СКАНИРУЮ ОБЪЕКТЫ...")
    
    local foundTokens = {}
    local allObjects = {}
    
    -- Сканируем всё в Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
            local name = obj.Name
            local className = obj.ClassName
            
            -- Проверяем, похож ли объект на токен
            local isToken = false
            local reasons = {}
            
            -- Критерии для токенов:
            if name:lower():find("token") then table.insert(reasons, "название содержит 'token'") end
            if name:lower():find("boost") then table.insert(reasons, "название содержит 'boost'") end
            if name:lower():find("orb") then table.insert(reasons, "название содержит 'orb'") end
            if name:lower():find("ball") then table.insert(reasons, "название содержит 'ball'") end
            if name:lower():find("pickup") then table.insert(reasons, "название содержит 'pickup'") end
            if name:lower():find("collect") then table.insert(reasons, "название содержит 'collect'") end
            if name:lower():find("power") then table.insert(reasons, "название содержит 'power'") end
            if name:lower():find("ability") then table.insert(reasons, "название содержит 'ability'") end
            
            -- Проверяем цвет (токены обычно яркие)
            if obj:FindFirstChild("Color") then
                local color = obj.Color
                -- Яркие цвета (красный, синий, жёлтый, зелёный)
                if color.r > 0.8 or color.g > 0.8 or color.b > 0.8 then
                    table.insert(reasons, "яркий цвет: " .. math.floor(color.r*255) .. "," .. math.floor(color.g*255) .. "," .. math.floor(color.b*255))
                end
            end
            
            if #reasons > 0 then
                isToken = true
                table.insert(foundTokens, {
                    Object = obj,
                    Name = name,
                    Class = className,
                    Reasons = reasons,
                    Position = obj.Position
                })
            end
            
            -- Записываем все объекты для статистики
            table.insert(allObjects, {
                Name = name,
                Class = className
            })
        end
    end
    
    -- Выводим результаты
    print("📊 СТАТИСТИКА:")
    print("Всего объектов в Workspace: " .. #allObjects)
    print("Найдено кандидатов в токены: " .. #foundTokens)
    
    if #foundTokens > 0 then
        print("\n🎯 ВОЗМОЖНЫЕ ТОКЕНЫ:")
        for i, token in ipairs(foundTokens) do
            print(string.format("%d. %s (%s)", i, token.Name, token.Class))
            print("   Причины: " .. table.concat(token.Reasons, ", "))
            print("   Позиция: " .. math.floor(token.Position.X) .. ", " .. math.floor(token.Position.Y) .. ", " .. math.floor(token.Position.Z))
        end
    else
        print("\n⚠️ Токены не найдены!")
        print("Подожди пока пчёлы выбросят токены или зайди на другое поле.")
    end
    
    -- Анализ имён всех объектов (топ 20 самых частых)
    local nameCounts = {}
    for _, obj in ipairs(allObjects) do
        nameCounts[obj.Name] = (nameCounts[obj.Name] or 0) + 1
    end
    
    -- Сортируем по частоте
    local sortedNames = {}
    for name, count in pairs(nameCounts) do
        table.insert(sortedNames, {name = name, count = count})
    end
    
    table.sort(sortedNames, function(a, b) return a.count > b.count end)
    
    print("\n🏆 ТОП-20 САМЫХ ЧАСТЫХ ОБЪЕКТОВ:")
    for i = 1, math.min(20, #sortedNames) do
        print(string.format("%2d. %-30s - %d раз", i, sortedNames[i].name, sortedNames[i].count))
    end
    
    return foundTokens
end

-- Функция мониторинга новых объектов в реальном времени
function StartRealTimeMonitoring(duration)
    print("\n⏱️ ЗАПУСК РЕАЛЬНОГО МОНИТОРИНГА (" .. duration .. " секунд)")
    print("Подожди пока пчёлы выбросят токены...")
    
    local newTokens = {}
    local startTime = tick()
    
    -- Подписываемся на появление новых объектов
    local connection = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
            local name = obj.Name:lower()
            
            -- Проверяем, похож ли на токен
            if name:find("token") or name:find("boost") or name:find("orb") 
               or name:find("ball") or name:find("pickup") then
                
                local found = false
                for _, t in ipairs(newTokens) do
                    if t.Object == obj then
                        found = true
                        break
                    end
                end
                
                if not found then
                    table.insert(newTokens, {
                        Object = obj,
                        Name = obj.Name,
                        Class = obj.ClassName,
                        Time = tick()
                    })
                    
                    print("[НОВЫЙ ОБЪЕКТ] " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    print("   Время появления: " .. math.floor(tick() - startTime) .. " сек")
                    
                    -- Проверяем цвет
                    if obj:FindFirstChild("Color") then
                        local color = obj.Color
                        print("   Цвет: " .. math.floor(color.r*255) .. "," .. math.floor(color.g*255) .. "," .. math.floor(color.b*255))
                    end
                    
                    -- Проверяем размер
                    print("   Размер: " .. math.floor(obj.Size.X) .. "x" .. math.floor(obj.Size.Y) .. "x" .. math.floor(obj.Size.Z))
                end
            end
        end
    end)
    
    -- Таймер
    local timer = 0
    while timer < duration do
        wait(1)
        timer = timer + 1
        
        -- Каждые 10 секунд показываем статус
        if timer % 10 == 0 then
            print("⏳ Мониторинг: " .. timer .. "/" .. duration .. " сек, найдено объектов: " .. #newTokens)
        end
    end
    
    -- Останавливаем мониторинг
    connection:Disconnect()
    
    print("\n📊 ИТОГИ МОНИТОРИНГА:")
    print("Время мониторинга: " .. duration .. " секунд")
    print("Найдено новых объектов: " .. #newTokens)
    
    if #newTokens > 0 then
        print("\n🎯 САМЫЕ ВЕРОЯТНЫЕ ТОКЕНЫ:")
        -- Группируем по имени
        local nameGroups = {}
        for _, token in ipairs(newTokens) do
            nameGroups[token.Name] = (nameGroups[token.Name] or 0) + 1
        end
        
        for name, count in pairs(nameGroups) do
            print("   " .. name .. " - " .. count .. " раз")
        end
        
        print("\n💡 РЕКОМЕНДАЦИЯ:")
        print("   Используй в основном скрипте объект: \"" .. newTokens[1].Name .. "\"")
    else
        print("\n⚠️ За время мониторинга токены не появились")
        print("   Попробуй:")
        print("   1. Подождать дольше (пчёлы могут быть неактивны)")
        print("   2. Сменить поле")
        print("   3. Активировать способности пчёл для генерации токенов")
    end
    
    return newTokens
end

-- Функция тестового сбора токенов
function TestTokenCollection()
    print("\n🔄 ТЕСТ СБОРА ТОКЕНОВ")
    print("Пытаемся собрать ближайшие объекты...")
    
    local character = Player.Character
    if not character then
        print("❌ Персонаж не найден")
        return
    end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        print("❌ HumanoidRootPart не найден")
        return
    end
    
    local collected = 0
    local attempts = 0
    
    -- Пробуем разные методы сбора
    local methods = {
        {"FireServer с именем объекта", function(token)
            if game:GetService("ReplicatedStorage"):FindFirstChild("Events") then
                for _, event in pairs(game:GetService("ReplicatedStorage").Events:GetChildren()) do
                    if event:IsA("RemoteEvent") then
                        pcall(function()
                            event:FireServer(token.Name, token.Position)
                            return true
                        end)
                    end
                end
            end
            return false
        end},
        
        {"TouchInterest", function(token)
            pcall(function()
                firetouchinterest(root, token, 0)
                firetouchinterest(root, token, 1)
                return true
            end)
            return false
        end},
        
        {"ProximityPrompt", function(token)
            if token:FindFirstChildWhichIsA("ProximityPrompt") then
                pcall(function()
                    fireproximityprompt(token:FindFirstChildWhichIsA("ProximityPrompt"))
                    return true
                end)
            end
            return false
        end},
        
        {"CFrame телепорт", function(token)
            pcall(function()
                root.CFrame = CFrame.new(token.Position + Vector3.new(0, 3, 0))
                return true
            end)
            return false
        end}
    }
    
    -- Ищем токены рядом
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if (name:find("token") or name:find("boost") or name:find("orb")) then
                local distance = (root.Position - obj.Position).Magnitude
                if distance < 50 then
                    attempts = attempts + 1
                    print("\nПробую собрать: " .. obj.Name .. " (расстояние: " .. math.floor(distance) .. ")")
                    
                    for i, method in ipairs(methods) do
                        local success = method[2](obj)
                        if success then
                            print("   ✅ Метод \"" .. method[1] .. "\" сработал")
                            collected = collected + 1
                            break
                        else
                            print("   ❌ Метод \"" .. method[1] .. "\" не сработал")
                        end
                    end
                    
                    wait(0.5)
                end
            end
        end
    end
    
    print("\n📊 РЕЗУЛЬТАТЫ ТЕСТА:")
    print("Найдено токенов рядом: " .. attempts)
    print("Успешно собрано: " .. collected)
    
    if collected > 0 then
        print("🎉 Найден рабочий метод сбора!")
    else
        print("⚠️ Ни один метод не сработал автоматически")
        print("   Нужно определить правильный метод вручную")
    end
end

-- Главное меню
function ShowMenu()
    print("\n" .. string.rep("=", 60))
    print("📱 ГЛАВНОЕ МЕНЮ ДИАГНОСТИКИ")
    print(string.rep("=", 60))
    print("1. 🔍 Быстрое сканирование объектов")
    print("2. ⏱️ Реальный мониторинг (60 секунд)")
    print("3. 🎯 Расширенный мониторинг (120 секунд)")
    print("4. 🧪 Тестовый сбор токенов")
    print("5. 📊 Статистика всех объектов")
    print("6. 🚪 Выход")
    print(string.rep("=", 60))
    
    -- В реальном инжекторе нужно вводить через rconsole или подобное
    -- Для простоты сделаем автоматическое выполнение всех тестов
    
    print("\n🚀 ЗАПУСКАЮ ПОЛНУЮ ДИАГНОСТИКУ...")
    
    -- Тест 1: Быстрое сканирование
    local tokens = ScanForTokens()
    
    -- Тест 2: Реальный мониторинг (30 секунд)
    if #tokens == 0 then
        print("\n" .. string.rep("-", 60))
        print("Запускаю мониторинг на 30 секунд...")
        StartRealTimeMonitoring(30)
    end
    
    -- Тест 3: Тестовый сбор
    print("\n" .. string.rep("-", 60))
    TestTokenCollection()
    
    -- Финальные рекомендации
    print("\n" .. string.rep("=", 60))
    print("📝 ИНСТРУКЦИЯ ДЛЯ ОСНОВНОГО СКРИПТА:")
    print(string.rep("=", 60))
    print("1. Скопируй самое частое название токена из результатов выше")
    print("2. Сообщи это название мне")
    print("3. Я добавлю автоматический сбор в основной скрипт")
    print("")
    print("💡 Пример того, что нужно сообщить:")
    print("   'Название токена: BoostToken'")
    print("   или 'Название токена: RedOrb'")
    print("   или 'Название токена: AbilityPickup'")
    print(string.rep("=", 60))
    
    -- Автоматический поиск наиболее вероятного названия
    local allNames = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name
            if name:lower():find("token") or name:lower():find("boost") or name:lower():find("orb") then
                allNames[name] = (allNames[name] or 0) + 1
            end
        end
    end
    
    if next(allNames) then
        print("\n🎲 САМЫЕ ВЕРОЯТНЫЕ НАЗВАНИЯ ТОКЕНОВ:")
        for name, count in pairs(allNames) do
            print("   " .. name .. " - " .. count .. " шт")
        end
    end
end

-- Запускаем диагностику
ShowMenu()

-- Сохраняем скрипт активным на 2 минуты для мониторинга
print("\n⏰ Диагностика завершена. Скрипт останется активным 120 секунд для наблюдения.")
print("Нажми F9 чтобы закрыть консоль инжектора когда закончишь.")

wait(120)
print("\n✅ Диагностика завершена. Можешь закрыть консоль.")
