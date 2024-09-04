# MIT License

# Copyright (c) 2024 Abeer Vaishnav

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import numpy as np
from PIL import Image


def load_image(img_absolute_path: str):
    image = Image.open(img_absolute_path)
    width, height = image.size
    pixels = np.array(image)[:, :, :3]

    if pixels is None:
        raise RuntimeError(f"Cannot load the image `{img_absolute_path}`")

    # Create empty 2D list
    pixels_avg = np.sum(pixels, axis=2) / 3
    pixels_reversed = np.ones(
        (height, width)) * 255 - pixels_avg  # Reversed luminosity
    img_data = pixels_reversed / 255

    # thresholding
    img_data[img_data >= 0.5] = 1
    img_data[img_data < 0.5] = 0
    img_data_str = "".join(
        str(int(pix)) for pix in np.reshape(img_data, height * width))

    return img_data_str, width


def scale_bmp(bmp_bin_data: str, bmp_width: int,
              scale_factor: tuple[int, int]) -> str:
    if bmp_width % 8 != 0:
        print("Error: `bmp_width` should be multiple of 8.")
        return ""

    if not isinstance(scale_factor, tuple):
        print("Error: `scale_factor` should be a valid tuple. "
              "Provide a tuple with integer X and Y scale factors.")
        return ""

    bmp_bin_list = [int(bit) for bit in bmp_bin_data]
    num_rows = int(len(bmp_bin_list) / bmp_width)

    bmp_bin_resized = np.resize(bmp_bin_list, (num_rows, bmp_width))
    bmp_bin_scaled = bmp_bin_resized.repeat(scale_factor[1],
                                            axis=0).repeat(scale_factor[0],
                                                           axis=1)
    print(bmp_bin_scaled.shape, num_rows, bmp_width)

    bmp_bin_scaled_resized = np.resize(
        bmp_bin_scaled,
        num_rows * bmp_width * scale_factor[0] * scale_factor[1],
    )
    print(bmp_bin_scaled_resized.shape)

    bmp_bin_scaled_bytes = np.resize(
        bmp_bin_scaled_resized,
        (int(num_rows * bmp_width * scale_factor[0] * scale_factor[1] / 8), 8))
    print(bmp_bin_scaled_bytes.shape)

    bmp_bytes_scaled = [
        f"{int(''.join(str(bit) for bit in byt), 2):0>2x}"
        for byt in bmp_bin_scaled_bytes
    ]
    return '\\\\x' + '\\\\x'.join(bmp_bytes_scaled)


## Example usage:

# bmp_data, bmp_width = load_image("/absolute/path/to/image.png")

# new_bmp = scale_bmp(bmp_bin_data=bmp_data, bmp_width=bmp_width, scale_factor=(1, 1))
# print(new_bmp)

## Copy the out of this, and paste the hex string in the lua file
