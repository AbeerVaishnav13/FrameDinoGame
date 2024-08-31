-- MIT License

-- Copyright (c) 2024 Abeer Vaishnav

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local sprites = require("sprites")
local globals = require("globals")
local Dino = require("dino")
local Ground = require("ground")
local ObstacleGen = require("obstacle_gen")

local function _new_game()
	game = {}
	game.frames = 0
	game.score = 0
	game.state = "INTRO"
	game.__state_types = { "INTRO", "PLAY", "OVER" }
	game.__game_over_messages = { "   OUCH!    ", "THAT HURT...", "...OH NO... ", " TRY AGAIN? ", "  OUCHIE!   " }
	game.__random_game_over_message = game.__game_over_messages[math.random(1, #game.__game_over_messages)]

	game.dino = Dino.new_dino(50)
	game.ground = Ground.new_ground()
	game.obs_gen = ObstacleGen.new_obstacle_generator()

	function game:init()
		frame.imu.tap_callback(function()
			if game.state == "INTRO" then
				game.state = "PLAY"
			elseif game.state == "PLAY" then
				self.dino:jump()
			elseif game.state == "OVER" then
				game:reset()
			else
				error("Error: Invalid game state!")
			end
		end)
	end

	function game:render_and_tick()
		frame.display.show()
		frame.sleep(0.04)
		self.frames = (self.frames + 1) % 150
	end

	function game:set_viewport()
		local viewport_block = string.rep("\\xFF", math.ceil(20 * (globals.screenheight / 2) / 8))
		frame.display.bitmap(1, globals.screenheight / 2, 20, 2, 15, viewport_block)
	end

	function game:display_score()
		frame.display.text("Score: " .. tostring(self.score), 1, 50, { color = "YELLOW", spacing = 6 })
	end

	function game:intro()
		if self.state == "INTRO" then
			frame.display.text("DINO GAME", 200, 150, { color = "GREEN", spacing = 8 })
			frame.display.text("Tap to Start!", 200, 300, { color = "WHITE", spacing = 8 })
		end
	end

	function game:play()
		self.ground:update(self.dino, self.frames, self.score)
		self.ground:draw()

		self.dino:update()
		self.dino:draw(self.frames)

		if self.state == "PLAY" then
			if self.dino.hit then
				self.state = "OVER"
			else
				if self.frames % 2 == 0 then
					self.score = self.score + 1
				end
			end
			self.obs_gen:update(self.dino, self.frames, self.score)
			self.obs_gen:draw(self.frames)
			self:set_viewport()
			self:display_score()
		end
	end

	function game:over()
		if self.state == "OVER" then
			self.obs_gen:draw(self.frames)
			self:set_viewport()
			self:display_score()
			frame.display.text(self.__random_game_over_message, 200, 150, { color = "RED", spacing = 8 })
			frame.display.bitmap(300, 250, sprites.button.width, 2, globals.colors.green, sprites.button.retry)
		end
	end

	function game:reset()
		self.frames = 0
		self.score = 0
		self.state = "INTRO"
		self.obs_gen:reset()
		self.dino:reset()
		self.__random_game_over_message = self.__game_over_messages[math.random(1, #self.__game_over_messages)]
	end

	return game
end

Game = {
	new_game = _new_game,
}
return Game
