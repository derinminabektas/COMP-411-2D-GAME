Boss = {}
Boss.__index = Boss

Boss.imgOpen = love.graphics.newImage('assets/sprites/BossOpen.png')
Boss.imgClosed = love.graphics.newImage('assets/sprites/BossClosed.png')

function Boss.create(x, y)
    local self = setmetatable({}, Boss)
    self.x = x
    self.y = y
    
    self.width = Boss.imgOpen:getWidth()
    self.height = Boss.imgOpen:getHeight()
    
    self.health = 10
    self.phase = 1
    self.dead = false
    
    self.speed = 30
    self.moveDir = -1 
    self.fireTimer = 0
    self.fireRate = 2.5
    
    self.animTimer = 0
    self.animFrame = 1
    
    return self
end

function Boss:update(dt, player, bullets)
    if self.dead then return end

    self:checkPhase()
    self:movePattern(dt, player)
    self:attackPattern(dt, player, bullets)
    
   
    self.animTimer = self.animTimer + dt
    local flapSpeed = self.phase == 1 and 0.3 or 0.15
    
    if self.animTimer > flapSpeed then
        self.animTimer = 0
        self.animFrame = self.animFrame == 1 and 2 or 1
    end
end

function Boss:checkPhase()
    if self.health <= 5 and self.phase == 1 then
        self.phase = 2
        self.fireRate = 1.2 
        self.speed = 70     
    end
    if self.health <= 0 then
        self.dead = true
    end
end

function Boss:movePattern(dt, player)
    local dist = math.abs(player.x - self.x)
    if dist < 60 then
        local escapeDir = (self.x < player.x) and -1 or 1
        self.x = self.x + (escapeDir * self.speed * 4 * dt)
    else
        self.x = self.x + (self.speed * self.moveDir * dt)
        if self.x < 150 then
            self.moveDir = 1
        elseif self.x > VIRTUAL_WIDTH - self.width then
            self.moveDir = -1
        end
    end
end

function Boss:attackPattern(dt, player, bullets)
    self.fireTimer = self.fireTimer + dt
    if self.fireTimer >= self.fireRate then
        local dir = (player.x < self.x) and -1 or 1
        if self.phase == 1 then
            table.insert(bullets, Bullet.create(self.x + self.width/2, self.y + self.height/2, dir))
        else
            self:fireSpread(bullets, dir)
        end
        self.fireTimer = 0 
    end
end

function Boss:fireSpread(bullets, dir)
    local b1 = Bullet.create(self.x + self.width/2, self.y, dir)
    local b2 = Bullet.create(self.x + self.width/2, self.y + self.height/2, dir)
    local b3 = Bullet.create(self.x + self.width/2, self.y + self.height, dir)
    table.insert(bullets, b1)
    table.insert(bullets, b2)
    table.insert(bullets, b3)
end

function Boss:draw(isNight)
    if self.dead then return end
    love.graphics.setColor(1, 1, 1)
    
    local currentImage = self.animFrame == 1 and Boss.imgOpen or Boss.imgClosed
    love.graphics.draw(currentImage, self.x, self.y)
end

return Boss