#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <map>
#include <iomanip>
#include <cstdint>

struct InstInfo {
    std::string type;
    uint8_t opcode;
    uint8_t funct3;
    uint8_t funct7;
};

uint32_t parseReg(const std::string& reg) {
    if (reg.empty() || reg[0] != 'x') {
        throw std::invalid_argument("Invalid register format: " + reg);
    }
    try {
        return std::stoi(reg.substr(1));
    } catch (const std::exception& e) {
        throw std::invalid_argument("Failed to parse register " + reg + ": " + e.what());
    }
}

int main() {
    std::map<std::string, InstInfo> instMap{
        {"add",  {"R", 0x33, 0x0, 0x00}},
        {"sub",  {"R", 0x33, 0x0, 0x20}},
        {"and",  {"R", 0x33, 0x7, 0x00}},
        {"or",   {"R", 0x33, 0x6, 0x00}},
        {"xor",  {"R", 0x33, 0x4, 0x00}},
        {"addi", {"I", 0x13, 0x0, 0x00}},
        {"andi", {"I", 0x13, 0x7, 0x00}},
        {"ori",  {"I", 0x13, 0x6, 0x00}},
        {"xori", {"I", 0x13, 0x4, 0x00}}
    };

    std::ifstream infile("program.asm");
    std::ofstream outfile("program.hex");
    std::string line;

    if (!infile.is_open()) {
        std::cerr << "Error: Could not open program.asm" << std::endl;
        return 1;
    }

    while (std::getline(infile, line)) {
        if (line.empty() || line.find("//") == 0) continue;

        for (char &c : line) if (c == ',') c = ' ';

        std::stringstream ss(line);
        std::string mnemonic, rd_s, rs1_s, rs2_or_imm_s;
        ss >> mnemonic >> rd_s >> rs1_s >> rs2_or_imm_s;

        if (mnemonic.empty()) continue;

        if(instMap.find(mnemonic) == instMap.end()) {
            std::cerr << "Warning: Unknown instruction " << mnemonic << std::endl;
            continue;
        }

        try {
            InstInfo info = instMap[mnemonic];
            uint32_t instruction = 0;
            uint32_t rd = parseReg(rd_s);
            uint32_t rs1 = parseReg(rs1_s);

            if (info.type == "R") {
                // R-type: [funct7][rs2][rs1][funct3][rd][opcode]
                uint32_t rs2 = parseReg(rs2_or_imm_s);
                instruction = (static_cast<uint32_t>(info.funct7) << 25) |
                              (rs2 << 20) | (rs1 << 15) |
                              (static_cast<uint32_t>(info.funct3) << 12) |
                              (rd << 7) | info.opcode;
            } else if (info.type == "I") {
                // I-type: [imm][rs1][funct3][rd][opcode]
                int32_t imm = std::stoi(rs2_or_imm_s);
                uint32_t imm_u = static_cast<uint32_t>(imm) & 0xFFF;
                instruction = (imm_u << 20) | (rs1 << 15) |
                              (static_cast<uint32_t>(info.funct3) << 12) |
                              (rd << 7) | info.opcode;
            }

            outfile << std::setfill('0') << std::setw(8) << std::hex << instruction << std::endl;
        } catch (const std::exception& e) {
            std::cerr << "Error parsing line: " << line << std::endl;
            std::cerr << "Exception: " << e.what() << std::endl;
            return 1;
        }
    }

    std::cout << "Assembly complete. Generated program.hex" << std::endl;
    return 0;
}
