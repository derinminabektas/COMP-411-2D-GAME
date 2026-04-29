GameOver = {}

function GameOver:enter(previousScore)
    self.previousScore = previousScore or 0
    self.selection = 1
    self.options = {'Retry', 'Main Menu'}
    
    self.playerName = ""
    self.nameEntered = false
end

function GameOver:update(dt)
end

function GameOver:saveScore()
    local scores = HighScore.loadScores()
    

    local finalName = self.playerName
    if finalName == "" then finalName = " " end
    
    table.insert(scores, {name = finalName, score = self.previousScore})
    table.sort(scores, function(a, b) return a.score > b.score end)
    
    while #scores > 3 do
        table.remove(scores)
    end
    
    HighScore.saveScores(scores)
end

function GameOver:keypressed(key)
    if not self.nameEntered then
        
        if key == 'backspace' then
        
            self.playerName = string.sub(self.playerName, 1, -2)
        elseif (key == 'return' or key == 'enter') then
          
            if #self.playerName > 0 then
                self.nameEntered = true
                self:saveScore()
            end
        
        elseif type(key) == "string" and key:match("^[a-z0-9]$") then
            if #self.playerName < 10 then
                self.playerName = self.playerName .. string.upper(key)
            end
        end
    else
        
        if key == 'up' or key == 'w' or key == 'down' or key == 's' then
            self.selection = 3 - self.selection
        elseif key == 'return' or key == 'enter' then
            if self.selection == 1 then
                Gamestate.switch(Play)
            else
                Gamestate.switch(Menu)
            end
        end
    end
end

function GameOver:draw()
    love.graphics.clear(0.1, 0, 0)
    love.graphics.setFont(gFonts.large)
    love.graphics.printf('Game Over', 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts.small)
    love.graphics.printf('Final Score: ' .. self.previousScore, 0, 55, VIRTUAL_WIDTH, 'center')

    if not self.nameEntered then
       
        love.graphics.printf('Type Your Name ', 0, 85, VIRTUAL_WIDTH, 'center')
        
       
        love.graphics.setFont(gFonts.medium)
        local blink = (math.floor(love.timer.getTime() * 2) % 2 == 0) and "_" or ""
        love.graphics.printf(self.playerName .. blink, 0, 105, VIRTUAL_WIDTH, 'center')
        
        love.graphics.setFont(gFonts.small)
        love.graphics.printf('Press ENTER to Save', 0, 135, VIRTUAL_WIDTH, 'center')
    else
       
        love.graphics.setFont(gFonts.medium)
        for i, option in ipairs(self.options) do
            local y = 90 + (i - 1) * 20
            if i == self.selection then
                love.graphics.setColor(0.8, 0.9, 0.4)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(option, 0, y, VIRTUAL_WIDTH, 'center')
        end
        love.graphics.setColor(1, 1, 1)
    end
end