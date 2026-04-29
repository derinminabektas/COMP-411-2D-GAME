Player = {}
Player.__index = Player

Player.imgRun1 = love.graphics.newImage('assets/sprites/PlayerLeft.png')
Player.imgRun2 = love.graphics.newImage('assets/sprites/PlayerRight.png')
Player.imgDuck1 = love.graphics.newImage('assets/sprites/PlayerDuckLeft.png')
Player.imgDuck2 = love.graphics.newImage('assets/sprites/PlayerDuckRight.png')

function Player.create(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = Player.imgRun1:getWidth()
    self.height = Player.imgRun1:getHeight()
    self.healthLevel = 5
    self.lives = 3
    self.score = 0
    self.startX = x
    self.startY = y
    self.isCrouching = false
    self.currentHitboxHeight = self.height
    self.animTimer = 0
    self.animFrame = 1
    self.shootCooldown = 0
    self.shootRate = 0.4
    self.dy = 0
    self.gravity = 800
    self.jumpForce = -250
    self.isGrounded = true
    return self
end

function Player:update(dt)
    local speed = 90
    self.score = self.score + (5 * dt)

    if self.shootCooldown > 0 then
        self.shootCooldown = self.shootCooldown - dt
    end

    self.animTimer = self.animTimer + dt
    if self.animTimer > 0.15 then
        self.animTimer = 0
        self.animFrame = self.animFrame == 1 and 2 or 1
    end

    if (love.keyboard.isDown('up') or love.keyboard.isDown('w')) and self.isGrounded then
        self.dy = self.jumpForce
        self.isGrounded = false
    end

    self.dy = self.dy + self.gravity * dt
    self.y = self.y + self.dy * dt

    if self.y >= self.startY then
        self.y = self.startY
        self.dy = 0
        self.isGrounded = true
    end

    if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
        self.isCrouching = true
        self.currentHitboxHeight = self.height / 2
    else
        self.isCrouching = false
        self.currentHitboxHeight = self.height
    end

    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        self.x = self.x - speed * dt
    elseif love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        self.x = self.x + speed * dt
    end

    self.x = math.max(0, math.min(VIRTUAL_WIDTH - self.width, self.x))
end

function Player:takeDamage()
    self.healthLevel = self.healthLevel - 1
    if self.healthLevel <= 0 then
        self.lives = self.lives - 1
        if self.lives > 0 then
            self.x, self.y = self.startX, self.startY
            self.healthLevel = 5
        else
            Gamestate.switch(GameOver, math.floor(self.score))
        end
    end
end

function Player:draw(isNight)
    love.graphics.setColor(1, 1, 1)
    local currentImage
    if self.isCrouching then
        currentImage = self.animFrame == 1 and Player.imgDuck1 or Player.imgDuck2
    else
        currentImage = self.animFrame == 1 and Player.imgRun1 or Player.imgRun2
    end
    local drawY = self.y + (self.height - currentImage:getHeight())
    love.graphics.draw(currentImage, self.x, drawY)
end

return Player
