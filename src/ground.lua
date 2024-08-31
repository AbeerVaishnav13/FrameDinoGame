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

local function _new_ground()
	local ground = {}

	ground.__min_x = 1
	ground.__bumps = {}
	ground.__vel_x = -globals.dino_speed
	ground.__bump_freq = 40
	ground.__dirt_data = string.rep("\\xFF", math.ceil(5 * 5 / 8))
	ground.__dirt_pos = {
		{ x = 12, y = globals.ground_level + math.random(5, 15) },
		{ x = 38, y = globals.ground_level + math.random(5, 15) },
		{ x = 63, y = globals.ground_level + math.random(5, 15) },
		{ x = 78, y = globals.ground_level + math.random(5, 15) },
		{ x = 119, y = globals.ground_level + math.random(5, 15) },
		{ x = 128, y = globals.ground_level + math.random(5, 15) },
		{ x = 157, y = globals.ground_level + math.random(5, 15) },
		{ x = 169, y = globals.ground_level + math.random(5, 15) },
		{ x = 209, y = globals.ground_level + math.random(5, 15) },
		{ x = 223, y = globals.ground_level + math.random(5, 15) },
		{ x = 244, y = globals.ground_level + math.random(5, 15) },
		{ x = 293, y = globals.ground_level + math.random(5, 15) },
		{ x = 291, y = globals.ground_level + math.random(5, 15) },
		{ x = 325, y = globals.ground_level + math.random(5, 15) },
		{ x = 347, y = globals.ground_level + math.random(5, 15) },
		{ x = 385, y = globals.ground_level + math.random(5, 15) },
		{ x = 415, y = globals.ground_level + math.random(5, 15) },
		{ x = 437, y = globals.ground_level + math.random(5, 15) },
		{ x = 458, y = globals.ground_level + math.random(5, 15) },
		{ x = 485, y = globals.ground_level + math.random(5, 15) },
		{ x = 497, y = globals.ground_level + math.random(5, 15) },
		{ x = 533, y = globals.ground_level + math.random(5, 15) },
		{ x = 555, y = globals.ground_level + math.random(5, 15) },
		{ x = 585, y = globals.ground_level + math.random(5, 15) },
		{ x = 621, y = globals.ground_level + math.random(5, 15) },
		{ x = 635, y = globals.ground_level + math.random(5, 15) },
	}

	function ground:draw()
		frame.display.bitmap(
			1,
			globals.ground_level,
			sprites.ground.width,
			2,
			globals.colors.brown,
			sprites.ground.image
		)
		for i = 1, #self.__dirt_pos, 1 do
			frame.display.bitmap(
				self.__dirt_pos[i].x,
				self.__dirt_pos[i].y,
				5,
				2,
				globals.colors.brown,
				self.__dirt_data
			)
		end
		for i = 1, #self.__bumps, 1 do
			frame.display.bitmap(
				self.__bumps[i].pos.x,
				self.__bumps[i].pos.y,
				sprites.bump.width,
				2,
				globals.colors.brown,
				self.__bumps[i].sprite
			)
		end
	end

	function ground:__update_pos(pos, reset)
		pos.x = pos.x + self.__vel_x
		if pos.x <= self.__min_x and reset then
			pos.x = globals.screenwidth
		end
		return pos
	end

	function ground:__update_dirt_pos()
		for i = 1, #self.__dirt_pos, 1 do
			self.__dirt_pos[i] = self:__update_pos(self.__dirt_pos[i], true)
		end
	end

	function ground:__update_bump_pos_and_clean()
		local bumps_to_remove = {}
		for i = 1, #self.__bumps, 1 do
			self.__bumps[i].pos = self:__update_pos(self.__bumps[i].pos, false)

			if self.__bumps[i].pos.x <= 1 then
				table.insert(bumps_to_remove, i)
			end
		end

		for _, i in ipairs(bumps_to_remove) do
			table.remove(self.__bumps, i)
		end
	end

	function ground:__add_new_bumps(frames)
		if frames % self.__bump_freq == 17 and math.random(1, 2) == 1 then
			local bump_idx = math.random(1, 2)
			table.insert(self.__bumps, {
				sprite = sprites.bump.images[bump_idx],
				pos = { x = globals.screenwidth, y = globals.ground_level - sprites.bump.offset[bump_idx] },
			})
		end
	end

	function ground:increase_difficulty(score)
		if score > 100 then
			self:set_speed(25)
		elseif score > 200 then
			self:set_speed(30)
		elseif score > 400 then
			self:set_speed(45)
		end
	end

	function ground:update(dino, frames, score)
		if not dino.hit then
			self:__update_dirt_pos()
			self:__add_new_bumps(frames)
			self:__update_bump_pos_and_clean()
			self:increase_difficulty(score)
		end
	end

	function ground:set_speed(new_speed)
		self.__vel_x = -new_speed
	end

	return ground
end

Ground = {
	new_ground = _new_ground,
}
return Ground
