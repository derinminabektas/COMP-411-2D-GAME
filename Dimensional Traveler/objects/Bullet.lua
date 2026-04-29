Bullet = {}
Bullet.__index = Bullet

Bullet.img = love.graphics.newImage('assets/sprites/Bullet.png')

function Bullet.create(x, y, dir)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.dx = 240 * dir
    
    
    self.width = Bullet.img:getWidth()
    self.height = Bullet.img:getHeight()
    
    self.dead = false
    self.isPlayer = false 
    
    return self
end

function Bullet:update(dt)
    self.x = self.x + self.dx * dt
    if self.x < 0 or self.x > VIRTUAL_WIDTH then
        self.dead = true
    end
end

function Bullet:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Bullet.img, self.x, self.y)
end

return Bullet