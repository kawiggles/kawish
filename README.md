# kawish
A toy shell written in Zig. The implementation is extremely simple; it works by using the std.posix.system library to directly call Linux syscalls. As such, this shell is compatible only with Linux, but it shouldn't be too difficult to port to other operating systems later.

## The Loop
The shell continuously reads from stdin, which are essentially newline terminated strings formatted by the terminal emulator's pseudo-shell. Right now, the shell simply breaks the string into tokens delimited by whitespace. The environmental PATH is iterated through with the first token (the binary name) to locate the binary. If located, the process forks, and the child process calls `execve()` with the absolute path to the binary, the command's input string broken into an array of char pointers delimited by whitespace and null terminated, and the environment as retrieved by std.c.environ.

## Future Plans
There is still a ton of work to be done on this project, including but not limited to:
- `cd` and the notion of the working directory as a whle
    - Related is the potential for other navigation means, like zoxide built in
- variables
- pipes and redirects
- conditional logic
- `~/.kawishrc`
