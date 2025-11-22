/*
* Copyright (C) 2025 Omega493

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <https://www.gnu.org/licenses/>.
*/

// This is more of a wrapper to generate a build.ninja file
#include <iostream>
#include <fstream>
#include <string>
#include <array>
#include <filesystem>
#include <cstdlib>
#include <vector>

namespace {
    const std::string ASSEMBLER{ "nasm" };
    const std::string ASSEMBLER_FLAGS{ "-f win64" };
    const std::string LINKER{ "g++" };
}

bool is_command_available(const std::string& cmd) {
    std::string check_cmd = "where " + cmd + " > nul 2>&1";
    int result = std::system(check_cmd.c_str());
    return result == 0;
}

void create_ninja(const std::string& source, const std::string& obj, const std::string& executable) {
    std::ofstream ninja("build.ninja");
    ninja.exceptions(std::ofstream::failbit | std::ofstream::badbit);

    ninja << "assembler = " << ASSEMBLER << '\n';
    ninja << "assemblerFlags = " << ASSEMBLER_FLAGS << "\n\n";
    ninja << "linker = " << LINKER << '\n';

    ninja << "rule assemble\n";
    ninja << "  command = $assembler $assemblerFlags $in -o $out\n";
    ninja << "  description = Building NASM object $out\n\n";

    ninja << "rule link\n";
    ninja << "  command = $linker $in -o $out\n";
    ninja << "  description = Linking executable $out\n\n";

    ninja << "build " << obj << ": assemble " << source << "\n";
    ninja << "build " << executable << ": link " << obj << "\n\n";

    ninja << "default " << executable << "\n";
    
    ninja.close(); 
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cout << "Usage: build <filename>.asm" << std::endl;
        return 1;
    }

    try {
        std::filesystem::path source(argv[1]);

        if (!std::filesystem::exists(source)) {
            std::cerr << "Error: Unable to find source file `" << source << "`" << std::endl;
            return 1;
        }

        std::filesystem::path obj{ source };
        obj.replace_extension(".obj");

        std::filesystem::path executable{ source };
        executable.replace_extension(".exe");

        if (std::filesystem::exists(executable)) {
            auto source_time = std::filesystem::last_write_time(source);
            auto exe_time = std::filesystem::last_write_time(executable);

            if (source_time <= exe_time) {
                std::cout << "[BuildManager] No work to do." << std::endl;
                return 0;
            }
        }

        if (!is_command_available(ASSEMBLER)) {
            throw std::runtime_error("Assembler '" + ASSEMBLER + "' not found in PATH.");
        }
        if (!is_command_available(LINKER)) {
            throw std::runtime_error("Linker '" + LINKER + "' not found in PATH.");
        }

        std::cout << "[BuildManager] Configuring build for `" << source.filename() << "`\n";
        
        create_ninja(source.string(), obj.string(), executable.string());

        std::cout << "[BuildManager] Invoking ninja" << std::endl;
        
        _putenv_s("TERM", "dumb");

        FILE* pipe = _popen("ninja", "r");
        if (!pipe) {
            throw std::runtime_error("Failed to invoke ninja");
        }

        std::array<char, 1024> buffer;
        bool is_newline{ true };

        while (fgets(buffer.data(), static_cast<int>(buffer.size()), pipe) != nullptr) {
            const std::string line{ buffer.data() };

            if (line.find("ninja: no work to do") != std::string::npos) {
                std::cout << "[BuildManager] No work to do." << std::endl;
                _pclose(pipe); 
                return 0;
            }
            
            if (is_newline) {
                std::cout << "  " << line;
            } else {
                std::cout << line;
            }

            if (!line.empty() && line.back() == '\n') {
                is_newline = true;
            } else {
                is_newline = false;
            }
        }

        int result{ _pclose(pipe) };

        if (result) {
            std::cerr << "[BuildManager] Build failed." << std::endl;
            return 1;
        } else {
            std::cout << "[BuildManager] Build complete." << std::endl;
            return 0;
        }
    }
    catch (const std::filesystem::filesystem_error& e) {
        std::cerr << "Filesystem Error: " << e.what() << std::endl;
        return 1;
    }
    catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    catch (...) {
        std::cerr << "Unknown error occurred." << std::endl;
        return 1;
    }
}