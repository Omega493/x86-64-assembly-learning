# x86-64-assembly-learning

Me learning x86-64 Assembly

These codes are developed on a 64-bit Windows 11, for 64-bit Windows 11. Other OSes are not meant to execute them.

To run each code, you'd need an assembler, and a linker. I personally use [nasm](https://www.nasm.us/) as the assembler and `g++` as the linker.

Make sure the path's to your nasm and g++ installation are set as one of your system's environment variables.

- To assemble and link each code, you can just type this command in a Windows Terminal / PowerShell session (replace `<filename>` with the name of the file you want to assemble):
    ```powershell
    nasm -f win64 "<filename>.asm" -o "program.obj"; g++ "program.obj" -o "program.exe"
    ```

- Alternatively, you can use the `build_manager.cpp` source to create a custom build manager for this specific use case. For this, you need to also have the [ninja build system installed](https://github.com/ninja-build/ninja/releases). Simply download the latest binary from their GitHub, extract it and make sure the path to ninja is in your system's environment variables.
  - Compile the CXX source (you can replace `build.exe` with anything you like):
    ```powershell
    g++ "build_manager.cpp" -o "build.exe" -std=c++20
    ```
    In this step, you can also add the optional optimization flags, such as `-O3`:
    ```powershell
    g++ "build_manager.cpp" -o "build.exe" -std=c++20 -O3
    ```
  - Now execute the build manager (replace `build` if you had changed the name of the executable in the previous step):
    ```powershell
    ./build <filename>.asm
    ```
    where `<filename>` is the original filename of the assembly source code. The build manager supports `.asm`, `.nasm`, and `.s` extensions. It will create a `build/` directory containing the artifacts.
    
    You can also use the optional flag `--move=true` to create the build folder in the parent directory:
    ```powershell
    ./build <filename>.asm --move=true
    ```

- To execute:
  - If you used only nasm and g++:
    ```powershell
    ./program.exe
    ```
  - If you used the custom build manager:
    ```powershell
    ./build/<filename>/<filename>.exe
    ```
    where `<filename>` is the name of your source file (without extension). The build manager creates a subdirectory inside `build/` matching the source name to keep artifacts isolated.

- Some may set a return code. To access those, just use:
```powershell
echo $lastexitcode
```