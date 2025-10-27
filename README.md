# x86-64-assembly-learning

Me learning x86-64 Assembly

These codes are developed on a 64-bit Windows 11, for 64-bit Windows 11. Other OSes are not meant to execute them.

To run each code, you'd need an assembler, and a linker. I personally use [nasm](https://www.nasm.us/) as the assembler and `g++` as the linker.

Make sure the path's to your nasm and g++ installation are set as one of your system's environment variables.

To assemble and link each code, you can just type this command in a Windows Terminal / PowerShell session (replace `<filename>` with the name of the file you want to assemble):

```powershell
nasm -f win64 "<filename>.asm" -o "program.obj"; g++ "program.obj" -o "program.exe"
```

To execute:

```powershell
./program.exe
```

Some may set a return code. To access those, just use:

```powershell
echo $lastexitcode
```