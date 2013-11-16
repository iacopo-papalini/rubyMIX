rubyMIX
=======

A Ruby didactic implementation of the MIX Virtual Machine + MIXAL assembly language, from D. E. Knuth 'The Art of Computer Programming'


Known issues
------------

* Not all instructions implemented:
    * missing floating point operation
    * missing I/O operations
    * missing alphanumeric symbols operations
    * missing Shift operations
    * Local symbols missing ([0-9][BHF])
    * ALF meta instruction missing
    * Literal constants missing (=A+B=)

* Assembly format more relaxed than the original one (no fixed length fields)
* Future references can be used inside arbitrary expressions, not only alone