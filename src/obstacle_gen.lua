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

local function _new_obstacle_generator()
	obstacle_gen = {}
	obstacle_gen.__bird_params = {
		max_y = globals.ground_level - sprites.bird.height,
		vel_x = -globals.bird_speed,
		frame_div = 5,
	}
	obstacle_gen.__cactus_params = {
		vel_x = -globals.dino_speed,
	}
	obstacle_gen.__min_x = 1
	obstacle_gen.__obstacles = {}
	obstacle_gen.__obs_types = { "cactus", "bird" }
	obstacle_gen.__obstacle_freq = 2 * 20
	obstacle_gen.__freeze_frame = false

	function obstacle_gen:draw_bird(bird, frames)
		local bird_idx = self.__freeze_frame and 1 or math.floor((frames / self.__bird_params.frame_div) % 2) + 1
		local bird_sprite = sprites.bird.images[bird_idx]
		local bird_offset = bird_idx == 1 and 0 or sprites.bird.frame_offset
		frame.display.bitmap(
			bird.pos.x,
			bird.pos.y + bird_offset,
			sprites.bird.width,
			2,
			globals.colors.skyblue,
			bird_sprite
		)
	end

	function obstacle_gen:draw_cactus(cactus)
		frame.display.bitmap(
			cactus.pos.x,
			cactus.pos.y,
			sprites.cactus.widths[cactus.image_idx],
			2,
			globals.colors.darkgreen,
			sprites.cactus.images[cactus.image_idx]
		)
	end

	function obstacle_gen:draw(frames)
		for _, obs in ipairs(self.__obstacles) do
			if obs.type == "cactus" then
				self:draw_cactus(obs)
			else
				self:draw_bird(obs, frames)
			end
		end
	end

	function obstacle_gen:__update_pos(obs)
		local vel_x = (obs.type == "cactus") and self.__cactus_params.vel_x or self.__bird_params.vel_x
		obs.pos.x = obs.pos.x + vel_x
	end

	function obstacle_gen:__add_new_obstacle(frames)
		if (frames % self.__obstacle_freq == 7) and (#self.__obstacles < 3) then
			local obs = self.__obs_types[(math.random(1, 5) == 1) and 2 or 1]
			local cactus_idx = math.random(1, 3)
			table.insert(self.__obstacles, {
				type = obs,
				image_idx = (obs == "cactus" and cactus_idx or 0),
				pos = (obs == "cactus") and {
					x = globals.screenwidth - sprites.cactus.widths[cactus_idx] / 2,
					y = globals.ground_level - sprites.cactus.heights[cactus_idx],
				} or {
					x = globals.screenwidth - sprites.bird.width / 2,
					y = (math.random(1, 3) == 1) and math.random(100, 200)
						or math.random(275, self.__bird_params.max_y),
				},
			})
		end
	end

	function obstacle_gen:collision_check(dino, obs)
		local obs_sprite = sprites[obs.type]
		local obs_width = (obs.type == "cactus") and obs_sprite.widths[obs.image_idx] or obs_sprite.width
		local obs_height = (obs.type == "cactus") and obs_sprite.heights[obs.image_idx] or obs_sprite.height
		dino.hit = (
			obs.pos.x < dino.pos.x + dino.size.width - 25
			and obs.pos.x + obs_width > dino.pos.x
			and obs.pos.y < dino.pos.y + dino.size.height
			and obs.pos.y + obs_height > dino.pos.y
		)
	end

	function obstacle_gen:__update_obs_pos_and_cleanup(dino)
		local obs_to_remove = {}
		for i = 1, #self.__obstacles, 1 do
			self:__update_pos(self.__obstacles[i])
			if self.__obstacles[i].pos.x <= 1 then
				table.insert(obs_to_remove, i)
			end
			self:collision_check(dino, self.__obstacles[i])
		end
		for _, i in ipairs(obs_to_remove) do
			table.remove(self.__obstacles, i)
		end
	end

	function obstacle_gen:increase_difficulty(score)
		if score > 100 then
			self:set_cactus_speed(25)
			self:set_freq(2 * 17)
			self:set_bird_speed(30)
		elseif score > 200 then
			self:set_cactus_speed(30)
			self:set_bird_speed(40)
		elseif score > 400 then
			self:set_cactus_speed(45)
			self:set_freq(2 * 20)
			self:set_bird_speed(50)
		end
	end

	function obstacle_gen:update(dino, frames, score)
		if dino.hit then
			self.__freeze_frame = true
		else
			self:__add_new_obstacle(frames)
			self:__update_obs_pos_and_cleanup(dino)
			self:increase_difficulty(score)
		end
	end

	function obstacle_gen:set_freq(new_freq)
		self.__obstacle_freq = new_freq
	end

	function obstacle_gen:set_cactus_speed(new_speed)
		self.__cactus_params.vel_x = -new_speed
	end

	function obstacle_gen:set_bird_speed(new_speed)
		self.__bird_params.vel_x = -new_speed
	end

	function obstacle_gen:reset()
		self.__obstacles = {}
		self.__freeze_frame = false
	end

	return obstacle_gen
end

ObstacleGen = {
	new_obstacle_generator = _new_obstacle_generator,
}
return ObstacleGen
