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

local function _new_dino(pos_x)
	local dino = {}

	dino.__max_y = globals.ground_level - sprites.dino.height
	dino.pos = { x = pos_x, y = dino.__max_y }
	dino.size = { width = sprites.dino.width, height = sprites.dino.height }
	dino.__vel_y = 0
	dino.__acc_y = 8
	dino.__frame_div = 4

	dino.hit = false

	function dino:draw(frames)
		local dino_idx = self.hit and 1 or math.floor((frames / self.__frame_div) % 2) + 1
		local dino_sprite = sprites.dino.images[dino_idx]
		frame.display.bitmap(
			self.pos.x,
			self.pos.y,
			sprites.dino.width,
			2,
			self.hit and globals.colors.red or globals.colors.orange,
			dino_sprite
		)
	end

	function dino:update()
		if self.hit then
			self.__vel_y = 0
			self.__acc_y = 0
		else
			self.pos.y = self.pos.y + self.__vel_y
			self.__vel_y = self.__vel_y + self.__acc_y

			if self.pos.y >= self.__max_y then
				self.pos.y = self.__max_y
			end
		end
	end

	function dino:jump()
		if self.pos.y == self.__max_y and not self.hit then
			self.__vel_y = -50
		end
	end

	function dino:reset()
		self.hit = false
		self.__acc_y = 8
	end

	return dino
end

Dino = {
	new_dino = _new_dino,
}
return Dino
