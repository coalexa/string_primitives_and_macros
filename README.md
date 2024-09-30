# String Primitives and Macros

Portfolio project for Computer Architecture and Assembly Language

# Description

This program asks the user to input 10 signed integers, validates that the user input is a valid number, and that the user input is small enough to fit inside a 32 bit register. User input is entered as a string using the `mGetString` macro and converted to a numeric value using the `RealVal` procedure. The sum and average of the numbers are then calculated and printed to the console along with a list of the entered numbers. Values are printed to console using the `mDisplayString` macro and the `WriteVal` procedure which converts the numeric values back to ASCII characters.

## Macros

`mGetString`: Displays a prompt and reads user input.

`mDisplayString`: Prints the string stored in memory from `mGetString`.

`mResetString`: Restores a string to an empty string.

## Procs

`ReadVal`: Obtains user input in the form of a string of digits then converts the string of ASCII digits to its numeric SDWORD value. Validates user input.

`WriteVal`: Converts the numeric SDWORD value to a string of ASCII digits then prints the string to the console.

## Requirements
- `ReadInt`, `ReadDec`, `WriteInt`, `WriteDec` are not allowed.
- Conversion routines must appropriately use `LODSB` and/or `STOSB` operators for dealing with strings.
- All procedure parameters must be passed on the runtime stack.
- Strings must be passed by reference.
- Prompts, identifying strings, and other memory locations must be passed by address to the macros.
- Used registers must be saved and restored.
- The stack frame must be cleaned up by the called procedure.
- Procedures must not reference data segment variables by name.
- Must use register indirect addressing for SDWORD array elements and base + offset addressing for accessing parameters on the stack.
- Procedures may use local variables.
