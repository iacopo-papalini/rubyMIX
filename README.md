rubyMIX
=======

A Ruby didactic implementation of the MIX Virtual Machine + MIXAL assembly language, from D. E. Knuth 'The Art of Computer Programming'


Known issues
------------

* Not all instructions implemented:
    * missing floating point operation
    * incomplete implementation I/O operations
    * missing Shift, MOV and other operations
* Assembler not yet complete
    * Literal constants missing (=A+B=)

* Assembly format more relaxed than the original one (no fixed length fields)
* ALF constants must use underscore '_' instead of blank



Usage
-----

*rubyMIX* comes as a command line program.