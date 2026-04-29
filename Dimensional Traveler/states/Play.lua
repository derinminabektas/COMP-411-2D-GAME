Play = {}

local function checkCollision(a, b)
    local a_height = a.currentHitboxHeight or a.height
    local b_height = b.currentHitboxHeight or b.height
    local a_y = a.y + (a.height - a_height)
    local b_y = b.y + (b.height - b_height)
    return a.x < b.x + b.width and b.x < a.x + a.width and a_y < b_y + b_height and b_y < a_y + a_height
end

function Play:enter()
    self.player = Player.create(40, VIRTUAL_HEIGHT - 62) 
    self.bullets = {}
    self.enemies = {}
    
    self.enemiesKilledInWave = 0
    self.bossActive = false
    
    table.insert(self.enemies, Enemy.create(VIRTUAL_WIDTH + 20, VIRTUAL_HEIGHT - 80))

    self.highScores = HighScore.loadScores()

    self.bg_clouds = love.graphics.newImage('assets/sprites/Background_Clouds.png')
    self.bg_horizon = love.graphics.newImage('assets/sprites/Background_Horizon.png')
    self.bg_cactus = love.graphics.newImage('assets/sprites/Background_Cactus.png')
    self.bg_ground = love.graphics.newImage('assets/sprites/Background_Ground.png')

    self.scroll_clouds = 0
    self.scroll_horizon = 0
    self.scroll_cactus = 0
    self.scroll_ground = 0

    self.isNight = false 

    self.nightShader = love.graphics.newShader[[
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            vec4 p = Texel(tex, tc);
            return vec4(1.0 - p.r, 1.0 - p.g, 1.0 - p.b, p.a) * color;
        }
    ]]
end

function Play:keypressed(key)
    if key == 'p' then
        Gamestate.switch(Pause, self)
    elseif key == 'escape' then
        Gamestate.switch(Menu)
    elseif key == 'space' then
        if self.player.shootCooldown <= 0 then
            local bullet = Bullet.create(self.player.x + self.player.width, self.player.y + self.player.height / 2, 1)
            bullet.isPlayer = true 
            table.insert(self.bullets, bullet)
            
            
            self.player.shootCooldown = self.player.shootRate
        end
    end
end

function Play:update(dt)
    local moveDir = 0
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
        moveDir = 1
    elseif love.keyboard.isDown('left') or love.keyboard.isDown('a') then
        moveDir = -1
    end

    self.scroll_clouds = (self.scroll_clouds + 10 * moveDir * dt) % self.bg_clouds:getWidth()
    self.scroll_horizon = (self.scroll_horizon + 25 * moveDir * dt) % self.bg_horizon:getWidth()
    self.scroll_cactus = (self.scroll_cactus + 50 * moveDir * dt) % self.bg_cactus:getWidth()
    self.scroll_ground = (self.scroll_ground + 90 * moveDir * dt) % self.bg_ground:getWidth()

    self.player:update(dt)

    if not self.bossActive then
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            enemy:update(dt, self.player, self.bullets)
            
            if not enemy.dead and checkCollision(self.player, enemy) then
                self.player:takeDamage()
                enemy.dead = true 
            end

            if enemy.dead then
                table.remove(self.enemies, i)
                self.enemiesKilledInWave = self.enemiesKilledInWave + 1
            end
        end

        if #self.enemies == 0 then
            if self.enemiesKilledInWave < 5 then
                table.insert(self.enemies, Enemy.create(VIRTUAL_WIDTH + 20, VIRTUAL_HEIGHT - 80)) 
            else
                self.bossActive = true
                self.boss = Boss.create(VIRTUAL_WIDTH + 40, VIRTUAL_HEIGHT - 80)
                self.boss.health = self.isNight and 15 or 10
                self.boss.speed = self.isNight and 50 or 30
                self.bullets = {} 
            end
        end

    else
        self.boss:update(dt, self.player, self.bullets)

        if self.boss.health <= 0 then
            self.player.score = self.player.score + 50 
            self.isNight = not self.isNight 
            
            self.bossActive = false
            self.enemiesKilledInWave = 0
            self.bullets = {}
            self.enemies = {}
        end
    end

    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        bullet:update(dt)
        
        if bullet.isPlayer then
            if not self.bossActive then
                for _, enemy in ipairs(self.enemies) do
                    if not enemy.dead and checkCollision(bullet, enemy) then
                        enemy:takeDamage(self.player)
                        bullet.dead = true
                    end
                end
            else
                if checkCollision(bullet, self.boss) then
                    self.boss.health = self.boss.health - 1
                    bullet.dead = true
                end
            end
        else
            if checkCollision(bullet, self.player) then
                self.player:takeDamage()
                bullet.dead = true
            end
        end

        if bullet.dead then
            table.remove(self.bullets, i)
        end
    end
end

function Play:draw()
    local bgColor = self.isNight and {0.05, 0.05, 0.05} or {1, 1, 1}
    love.graphics.clear(bgColor)

    if self.isNight then
        love.graphics.setShader(self.nightShader)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.bg_clouds, -math.floor(self.scroll_clouds), 0)
    love.graphics.draw(self.bg_clouds, -math.floor(self.scroll_clouds) + self.bg_clouds:getWidth(), 0)
    love.graphics.draw(self.bg_horizon, -math.floor(self.scroll_horizon), 0)
    love.graphics.draw(self.bg_horizon, -math.floor(self.scroll_horizon) + self.bg_horizon:getWidth(), 0)
    love.graphics.draw(self.bg_cactus, -math.floor(self.scroll_cactus), 0)
    love.graphics.draw(self.bg_cactus, -math.floor(self.scroll_cactus) + self.bg_cactus:getWidth(), 0)
    love.graphics.draw(self.bg_ground, -math.floor(self.scroll_ground), 0)
    love.graphics.draw(self.bg_ground, -math.floor(self.scroll_ground) + self.bg_ground:getWidth(), 0)

    if not self.bossActive then
        for _, enemy in ipairs(self.enemies) do
            enemy:draw(self.isNight)
        end
    else
        self.boss:draw(self.isNight)
    end

    self.player:draw(self.isNight)

    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end

    love.graphics.setShader()
    self:drawHUD()
end

function Play:drawHUD()
    love.graphics.setFont(gFonts.small)
    local textColor = self.isNight and {1, 1, 1} or {0.1, 0.1, 0.1}
    love.graphics.setColor(textColor)
    
    love.graphics.print('Lives: ' .. self.player.lives, 8, 8)
    love.graphics.print('Score: ' .. math.floor(self.player.score), 8, 22)
    
    love.graphics.setColor(1, 1, 1)
end