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

local max_sprite_width = 96
local globals = {
	ground_level = 385,
	colors = {
		white = 0,
		grey = 1,
		red = 2,
		pink = 3,
		darkbrown = 4,
		brown = 5,
		orange = 6,
		yellow = 7,
		darkgreen = 8,
		green = 9,
		lightgreen = 10,
		nightblue = 11,
		seablue = 12,
		skyblue = 13,
		cloudblue = 14,
		void = 15,
	},
	maxspritewidth = max_sprite_width,
	screenheight = 400,
	screenwidth = 640,
	viewportheight = 400,
	viewportwidth = 640 - 2 * max_sprite_width,
	dino_speed = 20,
	bird_speed = 25,
}

return globals
