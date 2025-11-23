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
#include <stdexcept>
#include <exception>
#include <algorithm>
#include <cstdlib>
#include <cstdio>
#include <cctype>

namespace {
    const std::string ASSEMBLER{ "nasm" };
    const std::string ASSEMBLER_FLAGS{ "-f win64" };
    const std::string LINKER{ "g++" };

    bool is_command_available(const std::string& cmd) {
        const std::string check_cmd{ "where " + cmd + " > nul 2>&1" };
        const int result{ std::system(check_cmd.c_str()) };
        return result == 0;
    }

    bool iequals(const std::string& a, const std::string& b) {
        if (a.size() != b.size()) return false;
        return std::equal(a.begin(), a.end(), b.begin(),
            [](const unsigned char c1, const unsigned char c2) {
                return std::tolower(c1) == std::tolower(c2);
            }
        );
    }

    std::string ninja_path(const std::filesystem::path& path) {
        const std::string str{ path.generic_string() };
        std::string result{};
        result.reserve(str.size());

        for (char c : str) {
            if (c == ' ' || c == ':') {
                result += '$';
            }
            result += c;
        }
        return result;
    }

    void create_ninja(const std::filesystem::path& source_path, const std::filesystem::path& obj_path, const std::filesystem::path& exe_path) {
        std::ofstream ninja("build.ninja");
        ninja.exceptions(std::ofstream::failbit | std::ofstream::badbit);

        ninja << "assembler = " << ASSEMBLER << '\n'
            << "assemblerFlags = " << ASSEMBLER_FLAGS << "\n\n"
            << "linker = " << LINKER << "\n\n"
            << "rule assemble\n"
            << "  command = $assembler $assemblerFlags $in -o $out\n"
            << "  description = Building NASM object $desc\n\n"
            << "rule link\n"
            << "  command = $linker $in -o $out\n"
            << "  description = Linking executable $desc\n\n";

        const std::string ninja_source{ ninja_path(source_path) };
        const std::string ninja_obj{ ninja_path(obj_path) };
        const std::string ninja_exe{ ninja_path(exe_path) };

        ninja << "build " << ninja_obj << ": assemble " << ninja_source << "\n"
            << "  desc = " << obj_path.filename().string() << "\n\n"
            << "build " << ninja_exe << ": link " << ninja_obj << "\n"
            << "  desc = " << exe_path.filename().string() << "\n\n"
            << "default " << ninja_exe << "\n";

        ninja.close();
    }

    struct ProgramArgs {
        std::filesystem::path source;
        bool move_up{ false };
    };

    ProgramArgs parse_args(int argc, char* argv[]) {
        if (argc < 2) throw std::runtime_error("Usage: build <filename>.asm [--move=true|false]");

        ProgramArgs args;
        args.source = std::filesystem::absolute(argv[1]);

        for (int i{ 2 }; i < argc; ++i) {
            const std::string arg{ argv[i] };
            if (arg.find("--move=") == 0) {
                const std::string val = arg.substr(7);
                if (val == "true") args.move_up = true;
                else if (val == "false") args.move_up = false;
            }
        }
        return args;
    }
}

int main(int argc, char* argv[]) {
    try {
        const ProgramArgs args{ parse_args(argc, argv) };

        if (!std::filesystem::exists(args.source)) {
            std::cerr << "Error: Unable to find source file `" << args.source << '`' << std::endl;
            return 1;
        }

        {
            // Scoped bcs this particular name isn't used anywhere other than the following if block.
            // So, we destroy it as soon as the check is complete.
            const std::string ext{ args.source.extension().string() };
            if (!iequals(ext, ".asm") && !iequals(ext, ".nasm") && !iequals(ext, ".s")) {
                std::cerr << "Error: Invalid extension `" << ext << "`. Expected .asm, .nasm, or .s" << std::endl;
                return 1;
            }
        }

        if (!is_command_available(ASSEMBLER)) {
            throw std::runtime_error("Assembler '" + ASSEMBLER + "' not found in PATH.");
        }
        if (!is_command_available(LINKER)) {
            throw std::runtime_error("Linker '" + LINKER + "' not found in PATH.");
        }

        std::filesystem::path source_dir{ args.source.parent_path() };

        std::filesystem::path build_root;
        const std::string stem{ args.source.stem().string() };

        if (args.move_up) {
            if (source_dir.has_parent_path()) build_root = source_dir.parent_path() / "build";
            else build_root = source_dir / "build";
        }
        else build_root = source_dir / "build";

        std::filesystem::path artifact_dir{ build_root / stem };
        std::filesystem::create_directories(artifact_dir);

        std::filesystem::current_path(artifact_dir);

        std::filesystem::path obj{ artifact_dir / (stem + ".obj") };
        std::filesystem::path executable{ artifact_dir / (stem + ".exe") };

        if (std::filesystem::exists(executable)) {
            if (std::filesystem::last_write_time(args.source) <= std::filesystem::last_write_time(executable)) {
                std::cout << "[BuildManager] No work to do." << std::endl;
                return 0;
            }
        }

        std::cout << "[BuildManager] Configuring build for " << args.source.filename().string() << "\n";

        {
            // Scoped bcs the paths here are unused anywhere other than the function invocation.
            // So, we destroy them after the function call.
            std::filesystem::path rel_source = std::filesystem::relative(args.source, artifact_dir);

            create_ninja(rel_source, obj, executable);
        }

        std::cout << "[BuildManager] Invoking ninja" << '\n';

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

            if (is_newline) std::cout << "  " << line;
            else std::cout << line;

            if (!line.empty() && line.back() == '\n') is_newline = true;
            else is_newline = false;
        }

        const int result{ _pclose(pipe) };

        if (result) {
            std::cerr << "[BuildManager] Build failed." << std::endl;
            return 1;
        }
        else {
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