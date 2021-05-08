# Lane-Twister-TI-NSPIRE
Lane Twister is a quick game I made for the TI-Nspire CX Cas in lua.
Don't expect much. If anything, expect sloppy coding

# Hey, I wanna actually play the game, how do I play?

If you haven't already, go to [How to Download](#How-to-download) to install it into your calculator

> Note: This is for TI-Nspire CX Cas only. I haven't tested for CX II or any others.

Use up/down arrows to navigate or optionally, if you want to keep your fingers on the buttons, you can also use the 8 and 2 keys.

# Commands

(What's a real game without console commands?)

`Ctrl + trig v` or `?` will bring up the console

WARNING: If you open the console, your highscore will no longer be saved. To reverse these changes, type `!cheatsoff`

You can directly type lua functions to execute certain parts of the code in the game (see [List of functions you can poke and prod to](#List-of-functions-you-can-poke-and-prod-to))

### List of console commands:

* `!invc [new state]` - Toggles invincibilty, or turns it on or off
* `!score <score>` - Sets your new score
* `!level/lvl <level>` - Sets your level/speed
* `!cheatsoff` - Reverts changes from since you opened the console so you can save your highscore again without restarting app
And a more destructive command...
* `!reset` - Resets your highscore and starts from the beginning, if you find yourself bored, of course.

### List of functions you can poke and prod to:

By simply typing lua into the console, you can execute it, here are some functions you can manually invoke:

* `updateScore(string mode, int value)` - Updates score, `set` mode will set the score to be the value. `add` mode will add the value to the score.
* `restart()` - Restarts the current game (Note: does NOT reset the game like !reset does, also does not turn off cheats)
* `genRandomCars()` - Generates random cars
* `makeGameover()` - Game Over!

# How to download

Download Lane Twister.tns and transfer it into your calculator, from then, simply open it!

<!--
Sneaky fella
-->
