HighScore = {}

local HIGH_SCORE_FILE = 'highscores.txt'

function HighScore:enter()
    self.scores = self.loadScores()
end

function HighScore:keypressed(key)
    if key == 'escape' or key == 'return' or key == 'enter' then
        Gamestate.switch(Menu)
    end
end

function HighScore:draw()
    love.graphics.clear(0.05, 0.05, 0.1)
    love.graphics.setFont(gFonts.large)
    love.graphics.printf('High Scores', 0, 20, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts.medium)
    for i = 1, 3 do
        local s = self.scores[i] or {name="---", score=0}
        love.graphics.printf(i .. '. ' .. s.name .. '  ' .. s.score, 0, 40 + i * 22, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(gFonts.small)
    love.graphics.printf('Press Enter or Escape to return', 0, VIRTUAL_HEIGHT - 24, VIRTUAL_WIDTH, 'center')
end

function HighScore.loadScores()
    local scores = {}
    if love.filesystem.getInfo(HIGH_SCORE_FILE) then
        for line in love.filesystem.lines(HIGH_SCORE_FILE) do
            local name, score = line:match("(%S+)%s+(%d+)")
            if name and score then
                table.insert(scores, {name = name, score = tonumber(score)})
            end
        end
    end
    while #scores < 3 do
        table.insert(scores, {name = "---", score = 0})
    end
    return scores
end

function HighScore.saveScores(scores)
    local data = ''
    for i = 1, 3 do
        local s = scores[i] or {name="---", score=0}
        data = data .. s.name .. ' ' .. s.score .. '\n'
    end
    love.filesystem.write(HIGH_SCORE_FILE, data)
end

return HighScore