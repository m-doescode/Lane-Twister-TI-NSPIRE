-- By Majd Roaydi majdroaydi@hotmail.com

-- Globals

local window = platform.window

local img_green_car = image.new(_R.IMG.car_green)
local img_blue_car = image.new(_R.IMG.car_blue)
local car_size = { 443, 89 }

local lanes = { {}, {}, {} }
local player -- Will be set later (see Init)

local gameover = false
local mainmenu = true
local paused = true

local speed = 1

local score = 0
local level = 1
local hscore

local cheats = false

local console

-- Cheats

local invincible = false

-- Scores and generation
local timesincegen = 0
local scoresincelastlevel = 0

-- Class Definitions

function extends(subclass, superclass)
    return function(t, i) return subclass[i] or superclass[i] end
end

-- Car

local Car = {}
Car.__index = Car

function Car.new(x, lane, carcolor)
    local self = {}
    self.x = x
    self.carcolor = carcolor
    self.lane = lane
    table.insert(lanes[lane], self)
    return setmetatable(self, Car)
end

function Car:draw(gc)
    local img
    if self.carcolor == "blue" then
        img = img_blue_car
    elseif self.carcolor == "green" then
        img = img_green_car
    end
    gc:drawImage(img, self.x, window.height() / 2 + (self.lane - 2) * 50 - 22)
end

function Car:step()
end

-- Enemy Car

local EnemyCar = {}
EnemyCar.__index = extends(EnemyCar, Car)

function EnemyCar.new(lane)
    local self = Car.new(window.width(), lane, "blue")
    return setmetatable(self, EnemyCar)
end

function EnemyCar:step()
    self.x = self.x - speed
    if self.x <= -80 then
        for cari, car in pairs(lanes[self.lane]) do
            if car == self then
                lanes[self.lane][cari] = nil
            end
        end
    end
end

-- Player Car

local PlayerCar = {}
PlayerCar.__index = extends(PlayerCar, Car)

function PlayerCar.new()
    local self = Car.new(0, 2, "green")
    return setmetatable(self, PlayerCar)
end

-- Console (fun!)

local Console = {}
Console.__index = Console

function Console.new()
    local self = {}
    self.open = false
    self.text = ""
    local funcs = {
        reset = function()
            cheats = false
            hscore = 0
            var.store("highscore", 0)
            restart()
            invincible = false
        end;
        cheatsoff = function()
            cheats = false
            hscore = var.recall("highscore")
            if hscore == nil then
                hscore = 0
            end
            invincible = false
            restart()
        end;
        score = function(scorein)
            score = tonumber(scorein)
        end;
        level = function(levelin)
            level = tonumber(levelin)
        end;
        invc = function(invcin)
            if invcin == nil then
                invcin = not invincible
            end
            invincible = invcin
        end;
    }
    -- Aliases
    funcs.lvl = funcs.level;
    self.funcs = funcs
    return setmetatable(self, Console)
end

function Console:setOpen(open)
    self.open = open
    paused = open
    if not open then
        self.text = ""
    end
    window.invalidate()
end

function Console:isOpen()
    return self.open
end

function Console:charIn(char)
    self.text = self.text..char
    window.invalidate()
end

function Console:backspace()
    if #self.text >=  1 then
        self.text = self.text:sub(1, #self.text - 1)
    end
end

function Console:enter()
    if self.text:sub(1,1) ~= "!" then
        local func = loadstring(self.text)
        if not func then
            print("Failed to execute: "..self.text)
            self:setOpen(false)
            return
        end
        local succ, err = pcall(func)
        print("Executed '"..self.text.."' success: "..tostring(succ))
        if not succ then
            print(err)
        end
    else
        local args = self.text:sub(2):split(" ")
        local func = self.funcs[args[1]]
        if func ~= nil then
            table.remove(args, 1)
            func(unpack(args))
        else
            print("Nonexistent function " .. self.text)
        end
    end
    self:setOpen(false)
end

function Console:draw(gc)
    drawStringBottom(gc, "> " .. self.text, 0, 15)
end

-- Init

function init()
    timesincegen = 0
    scoresincelastlevel = 0
    score = 0
    level = 1
    for lane = 1,3 do
        for cari, _ in pairs(lanes[lane]) do
            lanes[lane][cari] = nil
        end
    end

    player = PlayerCar.new()

    genRandomCars()
end

function on.activate()
    hscore = var.recall("highscore")
    if hscore == nil then
        hscore = 0
    end
    console = Console.new()
    var.monitor("highscore")
    init()
end

-- Functions

function nroot(root, num)
  return num^(1/root)
end

function makeGameover()
    gameover = true
    paused = true
end

function unpause()
    gameover = false
    mainmenu = false
    paused = false
end

function updateScore(mode, amount)
    if amount == nil then
        amount = mode
        mode = "set"
    end
    if mode == "set" then
        score = amount
    elseif mode == "add" then
        score = score + amount
    end
    if score > hscore then
        hscore = score
        if not cheats then
            var.store("highscore", hscore)
        end
    end
end

function genRandomCars()
    EnemyCar.new(math.random(1,3))
end

function drawStringBottom(gc, text, x, offset)
    local height = gc:getStringHeight(text)
    gc:drawString(text, x, window.height() - (height + offset))
end

function drawStringCentered(gc, text, x, y)
    local width = gc:getStringWidth(text)
    gc:drawString(text, x - width / 2, y)
end

function checkCollision()
    if invincible then
        return false
    end
    local lane = player.lane
    for _, car in pairs(lanes[lane]) do
        if car.x < 89 and car.x > -89 and car.carcolor == "blue" then
            return true
        end
    end
    return false
end

function restart()
    unpause()
    init()
end

-- Events

function on.paint(gc)
    if cheats then
        if console:isOpen() then
            console:draw(gc)
        end

        gc:setColorRGB(255, 0, 0)
        gc:drawString("WARNING: Cheats are on, scores aren't saved!", 0, 0)
        gc:setColorRGB(0, 0, 0)
    end

    for lane = 1,3 do
        for _, car in pairs(lanes[lane]) do
            car:draw(gc)
        end
    end

    gc:drawString("Score: "..score, 0, 25)
    gc:drawString("High Score: "..hscore, 0, 45)
    gc:drawString("Level: "..level, 0, 65)

    if paused then
        local wcenter = window.width() / 2
        local hcenter = window.height() / 2
        gc:setColorRGB(0xFFFFFF)
        gc:fillRect(wcenter - 150, hcenter - 50, 250, 100)
        gc:setColorRGB(0x000000)
        if gameover then
            drawStringCentered(gc, "Game Over! Try Again?", wcenter, hcenter - 40)
            drawStringCentered(gc, "Ctrl+S to save High Score", wcenter, hcenter -10)
            drawStringCentered(gc, "Press enter key to restart", wcenter, hcenter + 20)
        elseif mainmenu then
            drawStringCentered(gc, "Lane Twister", wcenter, hcenter - 40)
            drawStringCentered(gc, "Press enter key to start!", wcenter, hcenter + 20)
        else
            drawStringCentered(gc, "Paused", wcenter, hcenter - 40)
            drawStringCentered(gc, "Press enter key to unpause", wcenter, hcenter + 20)
        end
    end

    drawStringBottom(gc, "by Majd Roaydi, majdroaydi@hotmail.com", 0, 0)
end

function on.timer()
    if scoresincelastlevel >= level * 5 then
        level = level + 1
        scoresincelastlevel = 0
    end
    speed = level * 2 + 2
    if paused then
        return
    end
    if gameover then
        return
    end

    timesincegen = timesincegen + 1
    if timesincegen > (89 * 2 + 32) / speed then
        scoresincelastlevel = scoresincelastlevel + 1
        timesincegen = 0
        genRandomCars()
        updateScore("add", 1)
    end

    for i = 1,3 do
        for _, car in pairs(lanes[i]) do
            car:step()
        end
    end
    local playerColliding = checkCollision()
    if playerColliding then
        makeGameover()
    end

    window.invalidate()
end

timer.start(0.04)

-- Keys

function on.enterKey()
    if cheats and console:isOpen() then
        console:enter()
        return
    end
    if gameover or mainmenu then
        unpause()
        restart()
        return
    end
    paused = not paused
    window.invalidate()
end

function on.getSymbolList()
    return {key = keyt}
end

function on.charIn(key)
    if cheats and console:isOpen() then
        console:charIn(key)
        return
    end
    if paused then
        return
    end
    key = tostring(key):sub(1,1)
    if key == "8" then
        on.arrowUp()
    elseif key == "2" then
        on.arrowDown()
    end
end

function on.arrowUp()
    if paused then
        return
    end
    if player.lane > 1 then
        player.lane = player.lane - 1
    end
end

function on.arrowDown()
    if paused then
        return
    end
    if player.lane < 3 then
        player.lane = player.lane + 1
    end
end

-- Cheats

function on.help()
    cheats = true
    console:setOpen(true)
end

function on.escapeKey()
    if cheats and console:isOpen() then
        console:setOpen(false)
        return
    end
    window.invalidate()
end

function on.backspaceKey()
    if cheats and console:isOpen() then
        console:backspace()
    end
    window.invalidate()
end

-- Anti-cheat (-ish)

function on.varChange(vars)
    return -1 -- Never accept
end
