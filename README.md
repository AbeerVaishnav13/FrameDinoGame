# FrameDinoGame
The famous Dino Game for Frame AR Glasses by [Brilliant Labs](https://brilliant.xyz)

## Demo Video
[![YouTube](http://i.ytimg.com/vi/TxkqQ3RnQxE/hqdefault.jpg)](https://www.youtube.com/watch?v=TxkqQ3RnQxE)
[![YouTube](http://i.ytimg.com/vi/PbFKlvCr71M/hqdefault.jpg)](https://www.youtube.com/watch?v=PbFKlvCr71M)

## Project directories
- **src:** contains the Lua source for the game that would be uploaded to Frame for running the game.
- **utils:** contains utility files for:
    - Uploading the Lua source code to Frame (__upload.py__)
    - Generating bitmap string needed for Frame to display bitmap images (__bmp_gen.py__)

## Dependencies
- The project requires:
    - `numpy` and `pillow` for `bmp_gen.py`
    - `frameutils` and `aioconsole` for `upload.py`

- To install all dependencies, run the following in a conda or pyenv environment:
```bash
pip install -U numpy pillow framutils aioconsole
```

## Playing the game
To play the game, it first needs to be uploaded to your Frame glasses.

1. Clone this GitHub repository:
```bash
git clone https://github.com/AbeerVaishnav13/FrameDinoGame.git
```
2. Change your directory to `FrameDinoGame` repository.
3. Follow the setup instructions [here](https://docs.brilliant.xyz/frame/frame/#how-do-i-connect-to-my-frame-for-the-first-time) to reset your Frame.
4. Run the file `utils/upload.py` to upload all the files to your Frame glasses.
```bash
python ./utils/upload.py
```
5. A dialog box should open up asking to pair to your Frame glasses. Click **Connect**.
6. Now you should see string `Uploading game...` printed. It might take a minute or so to upload everything as it's a big project.
7. After the code is fully uploaded, you should see the **Dino Game** run on your Frame glasses!
8. Chill, relax, and enjoy playing! :D

## Usage of Bitmap generator Utility
Please refer to the `Example Usage` at the end of `utils/bmp_gen.py` file.
