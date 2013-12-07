rubyMIX
=======

A Ruby didactic implementation of the MIX Virtual Machine + MIXAL assembly language, from D. E. Knuth 'The Art of Computer Programming' (TAOCP from now on)


Known issues
------------

* Not all instructions implemented:
    * missing floating point operation
    * incomplete implementation I/O operations
    * missing rarely used operations

* Assembly format more relaxed than the original one (no fixed length fields)
* ALF constants must use underscore '_' instead of blank


Usage
-----

**rubyMIX** comes as a command line program: in order to use it you should

* perform the `git clone` command
* execute `rake` command in the working copy root directory

### Running interactively

* launch `bin/mix`

At this point you have an interactive console through which you can load assembly programs and run them.
For example typing `load examples/2-500primes.mix` (files path are autocompleted) you will load a copy of the program that calculates the 500 first prime numbers, as described in *TAOCP* from page 147.

By issuing the `debug on` command you will see a lot of debugging information, `debug off` turns the debugging output off.

You can inspect the machine status using the following commands:

* `dump n:m` with `m` > `n`: will show the memory locations (as words) from `n` to `m`
* `text n:m` with `m` > `n`: like `dump` but shows the memory bytes as characters (undefined output for locations having bytes with values that do not represent characters)
* `long n:m` with `m` > `n`: like `dump` but shows the memory bytes as long integers
* `code n:m` with `m` > `n`: like `dump` but disassembles the given locations and shows the corresponding MIXAL instructions
* `next n`: shows the next `n` instructions, starting from current `ip` (instruction pointer) value.
* `ra`, `rx`, `ri[1-6]`: shows the contents of the specified register, as word
* `text ra`, `text rx`, `text ri[1-6]`: shows the contents of the specified register, as string
* `long ra`, `long rx`, `long ri[1-6]`: shows the contents of the specified register, as long

Issuing an empty line as command produces the execution of a single clock of the CPU and repeats the last command.

In order to launch the execution of the program you should issue the `run` command. If followed by an integer, the execution will stop once the `ip` value is equal to the given number.

For example `run 3015` will execute the program until the instruction at location 3015 will be the next runnable instruction.

### Running non interactively

* launch `bin/mix -e /path/to/program`

The runtime will assemble the specified program, initialize accordingly the virtual machine and run the program, sending the output to stdout.

### Handling I/O

By default, the only I/O device working is the line printer, that is mapped over STDIO.

If you want to bind another device use the `bind` command:

* `bind id [file]` with `id` an integer between 0 and 20 and file a file name, or either STDIN or STDOUT
