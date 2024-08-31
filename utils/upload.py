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


# TODO: replace this method with built-in method once this PR is resolved
#       https://github.com/brilliantlabsAR/frame-utilities-for-python/pull/18
async def upload_file(b: Bluetooth, file: str, file_name="main.lua"):
    """
    Uploads a file as file_name. If the file exists, it will be overwritten.
    """

    await b.send_break_signal()

    if os.path.exists(file):
        with open(file, 'r') as f:
            file = f.read()

    file = file.replace("\n", "\\n")
    file = file.replace("'", "\\'")
    file = file.replace('"', '\\"')

    await b.send_lua(f"f=frame.file.open('{file_name}','w');print(nil)",
                     await_print=True)

    index: int = 0
    chunkSize: int = b.max_lua_payload() - 22

    while index < len(file):
        if index + chunkSize > len(file):
            chunkSize = len(file) - index

        # Don't split on an escape character
        while file[index + chunkSize - 1] == '\\':
            chunkSize -= 1

        chunk: str = file[index:index + chunkSize]

        await b.send_lua(f'f:write("{chunk}");print(nil)', await_print=True)

        index += chunkSize

    await b.send_lua("f:close();print(nil)", await_print=True)


def ble_print_response_handler(message):
    if message != "nil":
        print(message)


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
        # TODO: replace this method with b.upload_file once this PR is resolved
        #       https://github.com/brilliantlabsAR/frame-utilities-for-python/pull/18
        await upload_file(b, file, file_name=file.split('/')[-1])
        await asyncio.sleep(0.1)

    await b.send_reset_signal()

    # Wait until a keypress
    await ainput("Press enter to exit")

    await b.disconnect()


loop = asyncio.new_event_loop()
loop.run_until_complete(main())
