pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- text box example
-- by profpatonildo

--[[
**if you have trouble reading
this on pico 8's tiny screen,
select all the code and copy
it to a text editor**

how it works:

reading must be set to false
on _init(). this variable is
used to check when a text box
is currently being displayed
and is useful for diferentiating
game states.

tb_init(voice,string)
creates the text box and it's
properties. this is the function
you should call in your game
when you want to start a text
box. "voice" is a sfx number
and "string" is a table with
the messages you want to display
there is no automatic parsing
of the messages, so you will 
have to manually position empty
spaces with \n and check if the
message fits the box. check the
examples to have an idea of
how much text fits on the box.

tb_update() must be called on
_update() when reading is true.
this handles the text box behavior,
like advancing messages and
progressively displaying them,
in a typewriter effect.

tb_draw() draws the text box.
you can just put this on _draw()
and forget about it. no need
to do anything special with it,
since it is self contained.
--]]

function _init()
    reading=false -- global variable used to tell when the player is supposed to be reading from the text box. this is useful to change the game state (for example, freeze it) when the player is reading from a text box.
end

function _update()
    if reading then -- if tb_init has been called, reading will be true and a text box is being displayed to the player. it is important to do this check here because that way you can easily separete normal game actions to text box inputs.
        tb_update() -- handle the text box on every frame update.
    else
    -- if reading is false, then a text box is not being displayed. here you would put your normal game code. also, calls to brande new text boxes must be made only when reading is false, to avoid errors and conflicts.
        if (btnp(5)) tb_init(0,{"this is a test string. it is\nset to check if this is working\nproperly.","done! it seems to be working\nfine now! text boxes are great\nfor adventure and rpg games!"}) -- when calling for a new text box, you must pass two arguments to it: voice (the sfx played) and a table containing the strings to be printed. this table can have any number of strings separated with a comma.
        if (btnp(4)) tb_init(1,{"this is a higher pitch voice\nbecause i can speak in\ndifferent voices!","pretty cool, huh? this system\nis simple, but it can be put to\ngreat use!","i bet you are impressed! ♥"})
    end
end

function _draw()
    cls(3)
    local str="press 🅾️/z for message #1"
    print(str,64-#str*2,36,7)
    str="press ❎/x for message #2"
    print(str,64-#str*2,42,7)
    str="advance messages with ❎/x"
    print(str,64-#str*2,48,7)
    tb_draw() -- to draw text boxes, this function must be called. it is processed when reading is true, so there is no need to do a check here.
end
-->8
-- text box code

function tb_init(voice,string) -- this function starts and defines a text box.
    reading=true -- sets reading to true when a text box has been called.
    tb={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
    str=string, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
    voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
    i=1, -- index used to tell what string from tb.str to read.
    cur=0, -- buffer used to progressively show characters on the text box.
    char=0, -- current character to be drawn on the text box.
    x=0, -- x coordinate
    y=106, -- y coordginate
    w=127, -- text box width
    h=21, -- text box height
    col1=0, -- background color
    col2=7, -- border color
    col3=7, -- text color
    }
end

function tb_update()  -- this function handles the text box on every frame update.
    if tb.char<#tb.str[tb.i] then -- if the message has not been processed until it's last character:
        tb.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
        if tb.cur>0.9 then -- if the buffer is larger than 0.9:
            tb.char+=1 -- set next character to be drawn.
            tb.cur=0    -- reset the buffer.
            if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- play the voice sound effect.
        end
        if (btnp(5)) tb.char=#tb.str[tb.i] -- advance to the last character, to speed up the message.
    elseif btnp(5) then -- if already on the last message character and button ❎/x is pressed:
        if #tb.str>tb.i then -- if the number of strings to disay is larger than the current index (this means that there's another message to display next):
            tb.i+=1 -- increase the index, to display the next message on tb.str
            tb.cur=0 -- reset the buffer.
            tb.char=0 -- reset the character position.
        else -- if there are no more messages to display:
            reading=false -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
        end
    end
end

function tb_draw() -- this function draws the text box.
    if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
        rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- draw the background.
        rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- draw the border.
        print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- draw the text.
    end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
