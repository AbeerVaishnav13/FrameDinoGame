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

from aioconsole import ainput
from frameutils import Bluetooth
import asyncio
import os
from pathlib import Path

async def main():
    file_path = Path(__file__)
    src_path = file_path.parent.parent.absolute() / "src"
    scripts_to_upload = [
        str(src_path / src_file) for src_file in os.listdir(src_path)
    ]

    # Uncomment if you want faster upload times by not uploading
    # the "sprites.lua" file if there are no changes to that file
    # scripts_to_upload.remove(str(src_path / "sprites.lua"))

    # Connect to bluetooth and upload file
    b = Bluetooth()
    await b.connect(print_response_handler=ble_print_response_handler)
    await b.send_break_signal()

    print("Uploading game...")

    for file in scripts_to_upload:
        await b.upload_file(file, file_name=file.split('/')[-1])
        await asyncio.sleep(0.1)

    await b.send_reset_signal()

    # Wait until a keypress
    await ainput("Press enter to exit")

    await b.disconnect()


loop = asyncio.new_event_loop()
loop.run_until_complete(main())
