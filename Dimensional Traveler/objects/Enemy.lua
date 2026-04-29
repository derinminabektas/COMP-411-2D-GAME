Enemy = {}
Enemy.__index = Enemy

Enemy.imgOpen = love.graphics.newImage('assets/sprites/EnemyOpen.png')
Enemy.imgClosed = love.graphics.newImage('assets/sprites/EnemyClosed.png')

function Enemy.create(x, y)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    
    self.width = Enemy.imgOpen:getWidth()
    self.height = Enemy.imgOpen:getHeight()
    
    self.fireTimer = 0
    self.fireRate = 2 
    self.speed = 40
    self.health = 3 
    self.dead = false 
    
    self.animTimer = 0
    self.animFrame = 1
    
    return self
end

function Enemy:update(dt, player, bullets)
    if self.dead then return end


    self.animTimer = self.animTimer + dt
    if self.animTimer > 0.2 then
        self.animTimer = 0
        self.animFrame = self.animFrame == 1 and 2 or 1
    end

    if player.x < self.x then
        self.x = self.x - self.speed * dt
    elseif player.x > self.x then
        self.x = self.x + self.speed * dt
    end

    self.fireTimer = self.fireTimer + dt
    if self:canSeePlayer(player) and self.fireTimer >= self.fireRate then
        local dir = (player.x < self.x) and -1 or 1
        table.insert(bullets, Bullet.create(self.x + (self.width / 2), self.y + (self.height / 2), dir))
        self.fireTimer = 0
    end
end

function Enemy:canSeePlayer(player)
    return math.abs(player.x - self.x) < 300
end

function Enemy:takeDamage(player)
    self.health = self.health - 1
    if self.health <= 0 and not self.dead then
        self.dead = true
        if player then player.score = player.score + 10 end
    end
end

function Enemy:draw(isNight)
    if self.dead then return end
    love.graphics.setColor(1, 1, 1)
    
    local currentImage = self.animFrame == 1 and Enemy.imgOpen or Enemy.imgClosed
    love.graphics.draw(currentImage, self.x, self.y)
end

return Enemy