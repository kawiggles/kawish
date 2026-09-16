# IDEAS FOR KAWISH
Welcome to my github. If you're a potential employer, stop reading here.

If you're my parents, wtf are you doing here!?

I'm high as balls right now and had some IDEAS about shells, so here they are.

## Why not make it fucking modal?
VIMMMMM BAYBE. You switch between command mode and navigation mode. The annoying part of a shell is moving around. We've got a whole bunch of tools for it, like zoxide and fzf and autocomplete/histfiles/atuin. But it's still annoying af to deal with. You know what feels nice to move around in? Vim. And that's because Vim differentiates between moving around mode and actually writing mode. Why not do the same?

The idea is basically that we either use the main shell processing function, or, depending on the key (likely Esc "\033 \e" <- that's for you later Kawika), if the key is pressed it switches to a different mode, which is essentially a different module with a different input reading and parsing function. Navigation will be one key at a time, with each key performing a dedicated movement function (like go up a level, 1 for 1st item alphabetically sorted.., forwards and backwards in history, left and right in directory, and of course a way to just call ripgrep and fzf. 

So I'll make a toml config file. Basically a way to customize keybinds. I'll actually create something akin to vim macros because that's what'll be happening as a result of implementing this. I'll need to have a way of replaying key bindings, so I need to take the vim approach. Anyways, still need to get the basic lexer done, so we'll hold off on design until I can at least cd places.

## Why not add types?
This is idea number two, and the aim is to address my number one problem with scripting: it's difficult to write good scripts. What I mean by this is far too often a variable name is incorrect or an argument is off or something else, and a script will fail halfway through without giving a clear indication as to why.

The problems with this are that there's no good way for you to know whether you've made a mistake while writing the script. Me no likey. So let's do the typescript thing and add types!

Part one is the types. Everything will be a string by default to make things compatible with stdin and stdout. We'll have a thin wrapper which converts between the primitive types and pure strings. Variables will by default be strings (similar to bash), but I'll add syntax for declaring typed variables. Then, I'll introduce structs. Structs will essentially just be a convenient way for wrapping variables and typing the collection, but even that basic kind of type is really powerful, see C. 

Part two is aliases, specifically functions. We're getting rid of positional parameters; both input and output will be strictly typed. This is because aliases are individual system dependent, meaning I don't have to worry about cross compatibility when it comes to functions and aliases, so I can make the typing system super strict. We'll also have errors as types, because scripts need to be able to error handle, and that's not easy. I hate powershell try/catch.

One thing you'll do whenever you build a type is also write functions serializing and deserializing that type to and from raw strings, so it works with piping and such. Might make that part of the declaration, might make it happen automatically. 

The idea is that you can "compile" the script before running it, basically type/error checking it to make sure it runs properly. That feature alone would eliminate some problems from scripting.
