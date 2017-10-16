import std.variant : Algebraic;
import std.stdio;
import std.conv;
import std.array : array;
import std.algorithm : equal;

enum VERSION = "1.5";
enum LEFT_MARGIN = "            ";

alias Label = Algebraic!(string, string[], bool, int);

struct OPcode
{
    ubyte legal;
    string name;
    byte bytes;
    ubyte cycles;
    byte addressing_mode;
}

immutable(OPcode[int]) opcodes;
Label[string] registers;

shared static this()
{
    opcodes = [// byte => legal, text, bytes, cycles, addressing mode
    0x00 : OPcode(0, "BRK", 1, 0, 0), 0x01 : OPcode(0, "ORA", 2, 6, 7), 0x02
        : OPcode(1, "KIL", 1, 0, 0), 0x03 : OPcode(1, "SLO", 2, 8, 7), 0x04
        : OPcode(1, "NOP", 2, 3, 4), 0x05 : OPcode(0, "ORA", 2, 3, 4), 0x06
        : OPcode(0, "ASL", 2, 5, 4), 0x07 : OPcode(1, "SLO", 2, 5, 4), 0x08
        : OPcode(0, "PHP", 1, 3, 0), 0x09 : OPcode(0, "ORA", 2, 2, 0), 0x0A
        : OPcode(0, "ASL", 1, 2, 0), 0x0B : OPcode(1, "ANC", 2, 2, 0), 0x0C
        : OPcode(1, "NOP", 3, 4, 1), 0x0D : OPcode(0, "ORA", 3, 4, 1), 0x0E
        : OPcode(0, "ASL", 3, 6, 1), 0x0F : OPcode(1, "SLO", 3, 6, 1), 0x10
        : OPcode(0, "BPL", 2, 3, 0), 0x11 : OPcode(0, "ORA", 2, 5, 8), 0x12
        : OPcode(1, "KIL", 1, 0, 0), 0x13 : OPcode(1, "SLO", 2, 8, 8), 0x14
        : OPcode(1, "NOP", 2, 4, 5), 0x15 : OPcode(0, "ORA", 2, 4, 5), 0x16
        : OPcode(0, "ASL", 2, 6, 5), 0x17 : OPcode(1, "SLO", 2, 6, 5), 0x18
        : OPcode(0, "CLC", 1, 2, 0), 0x19 : OPcode(0, "ORA", 3, 4, 3), 0x1A
        : OPcode(1, "NOP", 1, 2, 0), 0x1B : OPcode(1, "SLO", 3, 7, 3), 0x1C
        : OPcode(1, "NOP", 3, 4, 2), 0x1D : OPcode(0, "ORA", 3, 4, 2), 0x1E
        : OPcode(0, "ASL", 3, 7, 2), 0x1F : OPcode(1, "SLO", 3, 7, 2), 0x20
        : OPcode(0, "JSR", 3, 6, 10), 0x21 : OPcode(0, "AND", 2, 6, 7), 0x22
        : OPcode(1, "KIL", 1, 0, 0), 0x23 : OPcode(1, "RLA", 2, 8, 7), 0x24
        : OPcode(0, "BIT", 2, 3, 4), 0x25 : OPcode(0, "AND", 2, 3, 4), 0x26
        : OPcode(0, "ROL", 2, 5, 4), 0x27 : OPcode(1, "RLA", 2, 5, 4), 0x28
        : OPcode(0, "PLP", 1, 4, 0), 0x29 : OPcode(0, "AND", 2, 2, 0), 0x2A
        : OPcode(0, "ROL", 1, 2, 0), 0x2B : OPcode(1, "ANC", 2, 2, 0), 0x2C
        : OPcode(0, "BIT", 3, 4, 1), 0x2D : OPcode(0, "AND", 3, 4, 1), 0x2E
        : OPcode(0, "ROL", 3, 6, 1), 0x2F : OPcode(1, "RLA", 3, 6, 1), 0x30
        : OPcode(0, "BMI", 2, 2, 0), 0x31 : OPcode(0, "AND", 2, 5, 8), 0x32
        : OPcode(1, "KIL", 1, 0, 0), 0x33 : OPcode(1, "RLA", 2, 8, 8), 0x34
        : OPcode(1, "NOP", 2, 4, 5), 0x35 : OPcode(0, "AND", 2, 4, 5), 0x36
        : OPcode(0, "ROL", 2, 6, 5), 0x37 : OPcode(1, "RLA", 2, 6, 5), 0x38
        : OPcode(0, "SEC", 1, 2, 0), 0x39 : OPcode(0, "AND", 3, 4, 3), 0x3A
        : OPcode(1, "NOP", 1, 2, 0), 0x3B : OPcode(1, "RLA", 3, 7, 3), 0x3C
        : OPcode(1, "NOP", 3, 4, 2), 0x3D : OPcode(0, "AND", 3, 4, 2), 0x3E
        : OPcode(0, "ROL", 3, 7, 2), 0x3F : OPcode(1, "RLA", 3, 7, 2), 0x40
        : OPcode(0, "RTI", 1, 6, 0), 0x41 : OPcode(0, "EOR", 2, 6, 7), 0x42
        : OPcode(1, "KIL", 1, 0, 0), 0x43 : OPcode(1, "SRE", 2, 8, 7), 0x44
        : OPcode(1, "NOP", 2, 3, 4), 0x45 : OPcode(0, "EOR", 2, 3, 4), 0x46
        : OPcode(0, "LSR", 2, 5, 4), 0x47 : OPcode(1, "SRE", 2, 5, 4), 0x48
        : OPcode(0, "PHA", 1, 3, 0), 0x49 : OPcode(0, "EOR", 2, 2, 0), 0x4A
        : OPcode(0, "LSR", 1, 2, 0), 0x4B : OPcode(1, "ALR", 2, 2, 0), 0x4C
        : OPcode(0, "JMP", 3, 3, 10), 0x4D : OPcode(0, "EOR", 3, 4, 1), 0x4E
        : OPcode(0, "LSR", 3, 6, 1), 0x4F : OPcode(1, "SRE", 3, 6, 1), 0x50
        : OPcode(0, "BVC", 2, 3, 0), 0x51 : OPcode(0, "EOR", 2, 5, 8), 0x52
        : OPcode(1, "KIL", 1, 0, 0), 0x53 : OPcode(1, "SRE", 2, 8, 8), 0x54
        : OPcode(1, "NOP", 2, 4, 5), 0x55 : OPcode(0, "EOR", 2, 4, 5), 0x56
        : OPcode(0, "LSR", 2, 6, 5), 0x57 : OPcode(1, "SRE", 2, 6, 5), 0x58
        : OPcode(0, "CLI", 1, 2, 0), 0x59 : OPcode(0, "EOR", 3, 4, 3), 0x5A
        : OPcode(1, "NOP", 1, 2, 0), 0x5B : OPcode(1, "SRE", 3, 7, 3), 0x5C
        : OPcode(1, "NOP", 3, 4, 2), 0x5D : OPcode(0, "EOR", 3, 4, 2), 0x5E
        : OPcode(0, "LSR", 3, 7, 2), 0x5F : OPcode(1, "SRE", 3, 7, 2), 0x60
        : OPcode(0, "RTS", 1, 6, 0), 0x61 : OPcode(0, "ADC", 2, 6, 7), 0x62
        : OPcode(1, "KIL", 1, 0, 0), 0x63 : OPcode(1, "RRA", 2, 8, 7), 0x64
        : OPcode(1, "NOP", 2, 3, 4), 0x65 : OPcode(0, "ADC", 2, 3, 4), 0x66
        : OPcode(0, "ROR", 2, 5, 4), 0x67 : OPcode(1, "RRA", 2, 5, 4), 0x68
        : OPcode(0, "PLA", 1, 4, 0), 0x69 : OPcode(0, "ADC", 2, 2, 0), 0x6A
        : OPcode(0, "ROR", 1, 2, 0), 0x6B : OPcode(1, "ARR", 2, 2, 0), 0x6C
        : OPcode(0, "JMP", 3, 5, 9), 0x6D : OPcode(0, "ADC", 3, 4, 1), 0x6E
        : OPcode(0, "ROR", 3, 6, 1), 0x6F : OPcode(1, "RRA", 3, 6, 1), 0x70
        : OPcode(0, "BVS", 2, 2, 0), 0x71 : OPcode(0, "ADC", 2, 5, 8), 0x72
        : OPcode(1, "KIL", 1, 0, 0), 0x73 : OPcode(1, "RRA", 2, 8, 8), 0x74
        : OPcode(1, "NOP", 2, 4, 5), 0x75 : OPcode(0, "ADC", 2, 4, 5), 0x76
        : OPcode(0, "ROR", 2, 6, 5), 0x77 : OPcode(1, "RRA", 2, 6, 5), 0x78
        : OPcode(0, "SEI", 1, 2, 0), 0x79 : OPcode(0, "ADC", 3, 4, 3), 0x7A
        : OPcode(1, "NOP", 1, 2, 0), 0x7B : OPcode(1, "RRA", 3, 7, 3), 0x7C
        : OPcode(1, "NOP", 3, 4, 2), 0x7D : OPcode(0, "ADC", 3, 4, 2), 0x7E
        : OPcode(0, "ROR", 3, 7, 2), 0x7F : OPcode(1, "RRA", 3, 7, 2), 0x80
        : OPcode(1, "NOP", 2, 2, 0), 0x81 : OPcode(0, "STA", 2, 6, 7), 0x82
        : OPcode(1, "NOP", 2, 2, 0), 0x83 : OPcode(1, "SAX", 2, 6, 7), 0x84
        : OPcode(0, "STY", 2, 3, 4), 0x85 : OPcode(0, "STA", 2, 3, 4), 0x86
        : OPcode(0, "STX", 2, 3, 4), 0x87 : OPcode(1, "SAX", 2, 3, 4), 0x88
        : OPcode(0, "DEY", 1, 2, 0), 0x89 : OPcode(1, "NOP", 2, 2, 0), 0x8A
        : OPcode(0, "TXA", 1, 2, 0), 0x8B : OPcode(1, "XAA", 2, 2, 0), 0x8C
        : OPcode(0, "STY", 3, 4, 1), 0x8D : OPcode(0, "STA", 3, 4, 1), 0x8E
        : OPcode(0, "STX", 3, 4, 1), 0x8F : OPcode(1, "SAX", 3, 4, 1), 0x90
        : OPcode(0, "BCC", 2, 3, 0), 0x91 : OPcode(0, "STA", 2, 6, 8), 0x92
        : OPcode(1, "KIL", 1, 0, 0), 0x93 : OPcode(1, "AHX", 2, 6, 8), 0x94
        : OPcode(0, "STY", 2, 4, 5), 0x95 : OPcode(0, "STA", 2, 4, 5), 0x96
        : OPcode(0, "STX", 2, 4, 6), 0x97 : OPcode(1, "SAX", 2, 4, 6), 0x98
        : OPcode(0, "TYA", 1, 2, 0), 0x99 : OPcode(0, "STA", 3, 5, 3), 0x9A
        : OPcode(0, "TXS", 1, 2, 0), 0x9B : OPcode(1, "TAS", 1, 5, 0), 0x9C
        : OPcode(1, "SHY", 3, 5, 2), 0x9D : OPcode(0, "STA", 3, 5, 2), 0x9E
        : OPcode(1, "SHX", 3, 5, 3), 0x9F : OPcode(1, "AHX", 3, 5, 3), 0xA0
        : OPcode(0, "LDY", 2, 2, 0), 0xA1 : OPcode(0, "LDA", 2, 6, 7), 0xA2
        : OPcode(0, "LDX", 2, 2, 0), 0xA3 : OPcode(1, "LAX", 2, 6, 7), 0xA4
        : OPcode(0, "LDY", 2, 3, 4), 0xA5 : OPcode(0, "LDA", 2, 3, 4), 0xA6
        : OPcode(0, "LDX", 2, 3, 4), 0xA7 : OPcode(1, "LAX", 2, 3, 4), 0xA8
        : OPcode(0, "TAY", 1, 2, 0), 0xA9 : OPcode(0, "LDA", 2, 2, 0), 0xAA
        : OPcode(0, "TAX", 1, 2, 0), 0xAB : OPcode(1, "LAX", 2, 2, 0), 0xAC
        : OPcode(0, "LDY", 3, 4, 1), 0xAD : OPcode(0, "LDA", 3, 4, 1), 0xAE
        : OPcode(0, "LDX", 3, 4, 1), 0xAF : OPcode(1, "LAX", 3, 4, 1), 0xB0
        : OPcode(0, "BCS", 2, 2, 0), 0xB1 : OPcode(0, "LDA", 2, 5, 8), 0xB2
        : OPcode(1, "KIL", 1, 0, 0), 0xB3 : OPcode(1, "LAX", 2, 5, 8), 0xB4
        : OPcode(0, "LDY", 2, 4, 5), 0xB5 : OPcode(0, "LDA", 2, 4, 5), 0xB6
        : OPcode(0, "LDX", 2, 4, 6), 0xB7 : OPcode(1, "LAX", 2, 4, 6), 0xB8
        : OPcode(0, "CLV", 1, 2, 0), 0xB9 : OPcode(0, "LDA", 3, 4, 3), 0xBA
        : OPcode(0, "TSX", 1, 2, 0), 0xBB : OPcode(1, "LAS", 3, 4, 3), 0xBC
        : OPcode(0, "LDY", 3, 4, 2), 0xBD : OPcode(0, "LDA", 3, 4, 2), 0xBE
        : OPcode(0, "LDX", 3, 4, 3), 0xBF : OPcode(1, "LAX", 3, 4, 3), 0xC0
        : OPcode(0, "CPY", 2, 2, 0), 0xC1 : OPcode(0, "CMP", 2, 6, 7), 0xC2
        : OPcode(1, "NOP", 2, 2, 0), 0xC3 : OPcode(1, "DCP", 2, 8, 7), 0xC4
        : OPcode(0, "CPY", 2, 3, 4), 0xC5 : OPcode(0, "CMP", 2, 3, 4), 0xC6
        : OPcode(0, "DEC", 2, 5, 4), 0xC7 : OPcode(1, "DCP", 2, 5, 4), 0xC8
        : OPcode(0, "INY", 1, 2, 0), 0xC9 : OPcode(0, "CMP", 2, 2, 0), 0xCA
        : OPcode(0, "DEX", 1, 2, 0), 0xCB : OPcode(1, "AXS", 2, 2, 0), 0xCC
        : OPcode(0, "CPY", 3, 4, 1), 0xCD : OPcode(0, "CMP", 3, 4, 1), 0xCE
        : OPcode(0, "DEC", 3, 6, 1), 0xCF : OPcode(1, "DCP", 3, 6, 1), 0xD0
        : OPcode(0, "BNE", 2, 3, 0), 0xD1 : OPcode(0, "CMP", 2, 5, 8), 0xD2
        : OPcode(1, "KIL", 1, 0, 0), 0xD3 : OPcode(1, "DCP", 2, 8, 8), 0xD4
        : OPcode(1, "NOP", 2, 4, 5), 0xD5 : OPcode(0, "CMP", 2, 4, 5), 0xD6
        : OPcode(0, "DEC", 2, 6, 5), 0xD7 : OPcode(1, "DCP", 2, 6, 5), 0xD8
        : OPcode(0, "CLD", 1, 2, 0), 0xD9 : OPcode(0, "CMP", 3, 4, 3), 0xDA
        : OPcode(1, "NOP", 1, 2, 0), 0xDB : OPcode(1, "DCP", 3, 7, 3), 0xDC
        : OPcode(1, "NOP", 3, 4, 2), 0xDD : OPcode(0, "CMP", 3, 4, 2), 0xDE
        : OPcode(0, "DEC", 3, 7, 2), 0xDF : OPcode(1, "DCP", 3, 7, 2), 0xE0
        : OPcode(0, "CPX", 2, 2, 0), 0xE1 : OPcode(0, "SBC", 2, 6, 7), 0xE2
        : OPcode(1, "NOP", 2, 2, 0), 0xE3 : OPcode(1, "ISC", 2, 8, 7), 0xE4
        : OPcode(0, "CPX", 2, 3, 4), 0xE5 : OPcode(0, "SBC", 2, 3, 4), 0xE6
        : OPcode(0, "INC", 2, 5, 4), 0xE7 : OPcode(1, "ISC", 2, 5, 4), 0xE8
        : OPcode(0, "INX", 1, 2, 0), 0xE9 : OPcode(0, "SBC", 2, 2, 0), 0xEA
        : OPcode(0, "NOP", 1, 2, 0), 0xEB : OPcode(1, "SBC", 2, 2, 0), 0xEC
        : OPcode(0, "CPX", 3, 4, 1), 0xED : OPcode(0, "SBC", 3, 4, 1), 0xEE
        : OPcode(0, "INC", 3, 6, 1), 0xEF : OPcode(1, "ISC", 3, 6, 1), 0xF0
        : OPcode(0, "BEQ", 2, 2, 0), 0xF1 : OPcode(0, "SBC", 2, 5, 8), 0xF2
        : OPcode(1, "KIL", 1, 0, 0), 0xF3 : OPcode(1, "ISC", 2, 8, 8), 0xF4
        : OPcode(1, "NOP", 2, 4, 5), 0xF5 : OPcode(0, "SBC", 2, 4, 5), 0xF6
        : OPcode(0, "INC", 2, 6, 5), 0xF7 : OPcode(1, "ISC", 2, 6, 5), 0xF8
        : OPcode(0, "SED", 1, 2, 0), 0xF9 : OPcode(0, "SBC", 3, 4, 3), 0xFA
        : OPcode(1, "NOP", 1, 2, 0), 0xFB : OPcode(1, "ISC", 3, 7, 3), 0xFC
        : OPcode(1, "NOP", 3, 4, 2), 0xFD : OPcode(0, "SBC", 3, 4, 2), 0xFE
        : OPcode(0, "INC", 3, 7, 2), 0xFF : OPcode(1, "ISC", 3, 7, 2)];

    registers = ["2000" : Label("PPUCTRL"), "2001" : Label("PPUMASK"), "2002"
        : Label("PPUSTATUS"), "2003" : Label("OAMADDR"), "2004" : Label("OAMDATA"),
        "2005" : Label("PPUSCROLL"), "2006" : Label("PPUADDR"), "2007"
        : Label("PPUDATA"), "4000" : Label("SQ1_VOL"), "4001" : Label("SQ1_SWEEP"),
        "4002" : Label("SQ1_LO"), "4003" : Label("SQ1_HI"), "4004"
        : Label("SQ2_VOL"), "4005" : Label("SQ2_SWEEP"), "4006" : Label("SQ2_LO"),
        "4007" : Label("SQ2_HI"), "4008" : Label("TRI_LINEAR"), "400A"
        : Label("TRI_LO"), "400B" : Label("TRI_HI"), "400C" : Label("NOISE_VOL"),
        "400E" : Label("NOISE_LO"), "400F" : Label("NOISE_HI"), "4010"
        : Label("DMC_FREQ"), "4011" : Label("DMC_RAW"), "4012" : Label("DMC_START"),
        "4013" : Label("DMC_LEN"), "4014" : Label("OAM_DMA"), "4015"
        : Label("SND_CHN"), "4016" : Label("JOY1"), "4017" : Label("JOY2"),];
}

enum STR_PAD_RIGHT = 0;
enum STR_PAD_LEFT = 1;

string str_pad(string input, size_t pad_length, char pad_string = ' ', int pad_type = STR_PAD_RIGHT)
{
    import std.string : leftJustify, rightJustify;

    string result;
    switch (pad_type)
    {
    case STR_PAD_LEFT:
        result = input.rightJustify(pad_length, pad_string);
        break;
    case STR_PAD_RIGHT:
    default:
        result = input.leftJustify(pad_length, pad_string);
    }

    return result;
}

AA aaUnion(AA)(AA lft, AA rht)
{
    auto newAA = lft.dup;
    foreach (key, item; rht)
    {
        if (key !in newAA)
        {
            newAA[key] = item;
        }
    }

    return newAA;
}

auto origin = 0x8000;
size_t labelLen = 0;

// used for branch opcodes
string addressOffset(int value, int offset)
{
    offset += 2; // length of brance command
    if (offset > 0x80)
    {
        offset = offset - 0x100;
    }

    return str_pad(uint(value + offset).toChars!(16).array, 4, '0', STR_PAD_LEFT);
}

bool isValidLabel(string addr)
{
    int iaddr = parse!(int)(addr, 16);
    return (iaddr >= origin && iaddr < 0xFFFA);
}

bool addValidLabel(string addr, ref Label[string] labels)
{
    if (isValidLabel(addr) && !(addr in labels))
    {
        labels[addr] = true;
        return true;
    }
    return false;
}

void addVector(string vector, string str, ref Label[string] labels)
{
    import std.algorithm : canFind, equal;

    auto label = vector in labels;
    if (label)
    {
        if (label.peek!bool)
        {
            *label = str;
        }
        else if (label.peek!(string[]))
        {
            auto labelValue = label.get!(string[]);
            if (!labelValue.canFind(str))
            {
                labelValue ~= str;
            }
        }
        else if (!equal(label.get!string, str))
        {
            labels[vector] = Label([label.get!string, str]);
        }
    }
    else
    {
        labels[vector] = Label(str);
    }
}

string wordStr(ubyte[] str)
{
    return dechex_pad(cast(int) str[1]) ~ dechex_pad(cast(int) str[0]);
}

// make sure hex values have leading zeros
string dechex_pad(int dec, int len = 2)
{
    import std.conv : toChars;

    if (dec > 0xFF)
    {
        len = 4;
    }
    else if (dec > 0xFFFF)
    {
        len = 6;
    }

    return str_pad(uint(dec).toChars!(16).array, len, '0', STR_PAD_LEFT);
}

// make sure binary values have leading zeros
string decbin_pad(int dec, size_t len = 8)
{

    if (dec > 0xFF)
    {
        len = 16;
    }
    else if (dec > 0xFFFF)
    {
        len = 32;
    }

    return str_pad(uint(dec).toChars!(2).array, len, '0', STR_PAD_LEFT);
}

string str_repeat(char c, size_t num)
{
    import std.range : repeat;

    return c.repeat(num).array.idup;
}

string commentLine(size_t len = 80)
{
    import std.range : repeat, array;

    return ";" ~ str_repeat('-', len - 1) ~ "\n";
}

string commentHeader(string text, bool initialNL = true, bool initialLine = true)
{
    import std.array : appender;

    auto ret = appender!(string);
    ret ~= (initialNL ? "\n" : "");
    ret ~= (initialLine ? commentLine() : "");
    ret ~= "; ";
    ret ~= text;
    ret ~= "\n" ~ commentLine();
    return ret.data;
}

auto strToHex(string str, bool fancy = false)
{
    import std.array : appender;

    auto len = str.length;
    auto ret = appender!string();

    for (size_t i = 0; i < len; ++i)
    {
        ret ~= (fancy ? "$" : "");
        ret ~= dechex_pad(str[i]);

        if (i < len - 1)
        {
            ret ~= (fancy ? "," : "");
            ret ~= " ";
        }
    }
    return ret.data;
}

struct HeaderInfo
{
    char[] head;
    ubyte prg;
    ubyte chr;
    ubyte ctrl_1;
    ubyte ctrl_2;
    char[] tail;
    ubyte mirroring;
    ubyte sram;
    ubyte trainer;
    ubyte fourscreen;
    ubyte romtype;
    ubyte mapper;
}

auto getHeaderInfo(File file)
{
    auto oldloc = file.tell();

    auto data = file.rawRead(new ubyte[16]);
    auto head = cast(char[]) data[0 .. 4];

    if (head == "NES\x1A")
    {
        auto info = new HeaderInfo(head, data[4], data[5], data[6], data[7],
                cast(char[]) data[8 .. $]);

        info.mirroring = info.ctrl_1 & 0b00000001;
        info.sram = (info.ctrl_1 & 0b0000010) >> 1;
        info.trainer = (info.ctrl_1 & 0b00000100) >> 2;
        info.fourscreen = (info.ctrl_1 & 0b00001000) >> 3;

        info.romtype = info.ctrl_2 & 0b00000011;

        info.mapper = ((info.ctrl_1 & 0b11110000) >> 4) + info.ctrl_2 & 0b00001111;
        return info;
    }
    else
    {
        file.seek(oldloc);
        return null;
    }
}

string processHeaderInfo(HeaderInfo* info)
{
    import std.array : appender;

    auto pad = 30 + labelLen;
    auto ret = appender!string();

    if (info)
    {
        //ret ~= commentLine();
        ret ~= commentHeader("iNES Header");
        ret ~= str_pad(LEFT_MARGIN ~ ".db \"NES\", $1A", pad) ~ " ; Header\n";
        ret ~= str_pad(LEFT_MARGIN ~ ".db " ~ info.prg.to!string, pad) ~ " ; " ~ info.prg.to!string
            ~ " x 16k PRG banks\n";
        ret ~= str_pad(LEFT_MARGIN ~ ".db " ~ info.chr.to!string, pad) ~ " ; " ~ info.chr.to!string
            ~ " x 8k CHR banks\n";
        ret ~= str_pad(LEFT_MARGIN ~ ".db %" ~ decbin_pad(info.ctrl_1), pad) ~ " ; Mirroring: " ~ (
                info.mirroring ? "Vertical" : "Horizontal") ~ "\n";
        ret ~= str_repeat(' ', pad) ~ " ; SRAM: " ~ (info.sram ? "Enabled" : "Not used") ~ "\n";
        ret ~= str_repeat(' ', pad) ~ " ; 512k Trainer: " ~ (info.trainer
                ? "Enabled" : "Not used") ~ "\n";
        ret ~= str_repeat(' ', pad) ~ " ; 4 Screen VRAM: " ~ (info.fourscreen
                ? "Enabled" : "Not used") ~ "\n";
        ret ~= str_repeat(' ', pad) ~ " ; Mapper: " ~ info.mapper.to!string ~ "\n";

        string romtype = "";
        switch (info.romtype)
        {
        case 0:
            romtype = "NES";
            break;
        case 1:
            romtype = "VS Unisystem";
            break;
        case 2:
            romtype = "Playchoice 10";
            break;
        default:
            assert(0, "Wrong RomType");
        }
        ret ~= str_pad(LEFT_MARGIN ~ ".db %" ~ decbin_pad(info.ctrl_2), pad)
            ~ " ; RomType: " ~ romtype ~ "\n";
        ret ~= str_pad(LEFT_MARGIN ~ ".hex " ~ strToHex(info.tail[0 .. 4].idup), pad)
            ~ " ; iNES Tail \n";
        ret ~= str_pad(LEFT_MARGIN ~ ".hex " ~ strToHex(info.tail[4 .. $].idup), pad) ~ "  \n";

        return ret.data;
    }

    return null;
}

auto toLittleEndianStr(string str)
{
    import std.array : appender;

    auto res = appender!string();
    if (str.length < 4)
    {
        return "00 00";
    }

    res ~= str[2];
    res ~= str[3];
    res ~= " ";
    res ~= str[0];
    res ~= str[1];
    return res.data;
}

auto processVectors(string nmi, string reset, string break_)
{
    import std.array : appender;

    auto marginLen = LEFT_MARGIN.length;
    auto pad = 30 + marginLen;

    auto ret = appender!string();
    ret ~= commentHeader("Vector Table");
    auto line1 = str_pad("vectors:", marginLen);
    line1 ~= ".dw nmi";
    ret ~= str_pad(line1, pad) ~ " ; $fffa: " ~ toLittleEndianStr(nmi) ~ "     Vector table\n";
    ret ~= str_pad(LEFT_MARGIN ~ ".dw reset", pad) ~ " ; $fffc: " ~ toLittleEndianStr(
            reset) ~ "     Vector table\n";
    ret ~= str_pad(LEFT_MARGIN ~ ".dw irq", pad) ~ " ; $fffe: " ~ toLittleEndianStr(
            break_) ~ "     Vector table\n";

    return ret.data;
}

int baseToDec(string str)
{
    import std.algorithm : equal;

    if (str[0] == '$')
        str = str[1 .. $];
    else if (str[0 .. 2].equal("0x"))
        str = str[2 .. $];

    return parse!(int)(str, 16);
}

auto readLabels(string filename)
{
    import std.file : read;

    auto arr = readLabelText(cast(string) read(filename));
    return arr;
}

auto readLabelText(string str)
{
    import std.regex;
    import std.algorithm : strip;
    import std.uni : isWhite;
    import std.string : toLower;

    Label[string] arr;
    int len = 0;
    int thislen = 0;
    auto re = regex(r";.*$", "m");

    str = str.replaceAll(re, "");
    //'%^\s*([a-zA-Z0-9_\-\+\@]*)\s*\=\s*([\$\%]*)([a-fA-F0-9]*)%m'
    re = regex(r"^\s*([a-zA-Z0-9_-\+@]*)\s*=\s*([\$%]*)([a-fA-F0-9]*)", "m");
    auto matches = str.matchAll(re);

    foreach (m; matches)
    {
        thislen = cast(int) m[1].strip!(isWhite).length;

        if (thislen > len)
        {
            len = thislen;
        }

        if (thislen > 0)
        {
            string key;
            string s = m[3];
            if (!m[2].length)
            {
                key = dechex_pad(s.parse!(int)(16));
            }
            else if (m[2] == "%")
            {
                key = dechex_pad(s.parse!(int)(2));
            }

            arr[key.toLower] = Label(m[1]);
        }
    }

    arr["maxLength"] = Label(len);
    return arr;
}

string outputLabels(Label[string] arr, string text)
{
    import std.array : appender;

    auto ret = appender!string();
    ret ~= commentHeader(text);

    foreach (n, v; arr)
    {
        if (n == "maxLength")
        {
            continue;
        }

        if (parse!(typeof(origin))(n, 16) < origin)
        {
            ret ~= str_pad(v.get!string, 20) ~ " = $" ~ n ~ "\n";
        }
    }

    return ret.data;
}

void outputHelp(string[] args, string text = null)
{
    import core.stdc.stdlib : exit;

    writeln(q"ENDOFSTRING
Usage:

disasm6 <file> [-t <file>] [-o #] [-l <file>] [-cdl <file>] [-cdlo #] [-d] [-i]
         [-h] [-c] [-p #] [-r] [-lc] [-uc] [-fs #] [-cs #] [-fe #] [-ce <#>]
         [-len #] [-iw] [-m2]

  <file>                The file to disassemble
  t     target <file>   Target output filename (default is input filename.asm)
  o     origin #        Set the program origin.
                           (default: 0x8000 for 32k roms, 0xC000 for 16k roms)
  l     labels <file>   Load user defined labels from file
  cdl   cdl <file>      Use a code/data log generated by FCEUX
  cdlo  cdloffset #     Set the offset of the cdl file
  d     nodetect        Disable 16kb prg size detection
  i     ignoreheader    Do not look for iNES header
  h     noheader        Do not include iNES header (if found) in disassembly
  c     chr             Export CHR-ROM as file and include in disassembly
  p     passes #        Maximum number of passes (default: 9)
  r     registers       Use default NES registers
  lc    lowercase       Use lowercase mnemonics [default]
  uc    uppercase       Use uppercase mnemonics
  fs    filestart       Start reading at a specific file location
  cs    codestart       Start reading at a specific code location
  fe    fileend         Stop reading at a specific file location
  ce    codeend         Stop reading at a specific code location
  len   length          Number of bytes to read
  iw    ignorewrites    Ignore writes to \$8000 - \$FFFF
  m2    mapper2         Enable mapper 2 (UxROM) support
ENDOFSTRING");

    writeln("\n" ~ (text ? "\nERROR: " ~ text : ""));
    exit(text.length ? 1 : 0);
}

bool isCounterLabel(int a, Label[string] labels)
{
    import std.regex;

    string addr = dechex_pad(a);

    if (auto laddr = addr in labels)
    {
        if (laddr.peek!string && laddr.get!string.matchFirst(r"^([^\+-]+)[\+-][0-9]+"))
        {
            return false;
        }

        return true;
    }
    return false;

}

int main(string[] args)
{
    import std.datetime;
    import std.range : repeat, appender;
    import std.file : isFile;
    import std.path : stripExtension, baseName;
    import std.string : toLower;
    import std.conv : to, parse;

    // Program start
    auto time_start = StopWatch(AutoStart.yes);

    immutable head = "DISASM6 v" ~ VERSION
        ~ " - A NES-oriented 6502 disassembler - Created by Frantik 2015";
    writeln("\n" ~ head ~ "\n" ~ '-'.repeat(79).array);
    string filename;

    if (args.length < 2)
    {
        outputHelp(args);
    }
    else if (!isFile(args[1]))
    {
        outputHelp(args, "File not found or it is not a file\n");
    }
    else
    {
        filename = args[1];
    }

    origin = 0x8000;
    auto showHeader = true;
    auto includeChr = false;
    auto includeReg = false;
    auto originOverride = false;
    auto noDetect = false;
    auto shortname = filename.stripExtension.baseName;
    string labelFile = null;
    string cdlFilename = null;
    auto ignoreHeader = false;
    auto fileStart = 0;
    auto fileStartOverride = false;
    auto fileLength = 0x10000;
    auto lengthOverride = false;
    auto fileEnd = 0;
    auto fileEndOverride = false;
    auto codeStart = 0;
    auto codeStartOverride = false;
    auto codeEnd = 0;
    auto codeEndOverride = false;
    auto cdlOffset = 0;
    auto ignoreWrites = false;
    auto useLowerCase = true;
    auto usingMapper2 = false;
    auto lastPass = 9;
    size_t marginLen = LEFT_MARGIN.length;

    // check command line params
    for (size_t i = 2; i < args.length; i++)
    {
        string nextParam = null;

        if (args.length > i + 1 && args[i + 1][0 .. 1] != "-")
        {
            nextParam = args[i + 1];
        }

        switch (args[i].toLower)
        {
        case "-o":
        case "-origin":

            if (nextParam is null)
            {
                outputHelp(args, "Must specify a valid origin");
            }

            origin = baseToDec(args[++i]);
            originOverride = true;
            break;

        case "-cs":
        case "-codestart":

            if (nextParam is null)
            {
                outputHelp(args, "Must specify a valid code start location ");
            }

            codeStart = baseToDec(args[++i]);
            codeStartOverride = true;

            break;

        case "-fs":
        case "-filestart":

            if (nextParam is null)
            {
                outputHelp(args, "Must specify a valid file start location ");
            }

            fileStart = baseToDec(args[++i]);
            fileStartOverride = true;
            break;

        case "-len":
        case "-length":
            if (nextParam is null)
            {
                outputHelp(args, "Must specify a valid length to read");
            }

            fileLength = baseToDec(args[++i]); // this will be tweaked later
            lengthOverride = true;
            break;

        case "-fe":
        case "-fileend":

            if (nextParam is null)
            {
                outputHelp(args, "Must specify a valid file end location ");
            }

            fileEnd = baseToDec(args[++i]);
            fileEndOverride = true;
            break;

        case "-ce":
        case "-codeend":

            if (nextParam is null)
            {
                outputHelp(args, "Must specify a valid code end location ");
            }

            fileLength = baseToDec(args[++i]); // will NOT be tweaked since lengthOverride isn't enable
            codeEndOverride = true;
            break;

        case "-h":
        case "-noheader":
            showHeader = false;
            break;

        case "-i":
        case "-ignoreheader":
            ignoreHeader = true;
            break;

        case "-c":
        case "-chr":
            includeChr = true;
            break;

        case "-r":
        case "-registers":
            includeReg = true;
            break;

        case "-t":
        case "-target":
            import std.regex : regex, replaceFirst;

            if (nextParam is null)
            {
                outputHelp(args, "You must specify a target file");
            }

            shortname = args[++i].replaceFirst(regex(r"[^a-zA-Z0-9_\-\. ]"),
                    "").stripExtension.baseName;

            break;

        case "-p":
        case "-passes":
            import std.string : isNumeric;

            if (nextParam is null || !isNumeric(nextParam))
            {
                outputHelp(args, "You must specify a number of passes");
            }

            lastPass = args[++i].to!int;
            break;

        case "-nodetect":
        case "-d":
            noDetect = true;
            break;

        case "-l":
        case "-labels":
            if (nextParam is null || !isFile(nextParam))
            {
                outputHelp(args, "You must specify a valid file");
            }

            labelFile = args[++i];
            break;

        case "-cdl":
            if (nextParam is null || !isFile(nextParam))
            {
                outputHelp(args, "You must specify a valid file");
            }

            cdlFilename = args[++i];
            break;

        case "-cdlo":
        case "-cdloffset":
            if (nextParam is null)
            {
                outputHelp(args, "You must specify a valid offset for the CDL");
            }

            cdlOffset = baseToDec(args[++i]);
            break;

        case "-lc":
        case "-lowercase":
            useLowerCase = true;

            break;

        case "-cc":
        case "-uppercase":
            useLowerCase = false;

            break;

        case "-iw":
        case "-ignorewrites":

            ignoreWrites = true;
            break;

        case "-m2":
        case "-mapper2":

            usingMapper2 = true;
            break;
        default:
            outputHelp(args, "Unknown parametr: " ~ args[i].toLower);
        }

    }

    if (fileEndOverride)
    {
        fileLength = fileStart + fileEnd;
        lengthOverride = true;
    }

    auto file = File(filename, "r");

    auto pass = 1;

    Label[string] oldLabels;

    Label[string] initLabels = [
        "fffa" : Label("vectors"), "fffc" : Label(true), "fffe" : Label(true),
    ];
    Label[string] fileLabels;

    if (includeReg)
    {
        initLabels = initLabels.aaUnion(registers);
    }

    int labelLen = 0;
    if (labelFile !is null)
    {
        fileLabels = readLabels(labelFile);

        //auto mapperArr = fileLabels["mapperArr"];
        //fileLabels.remove("mapperArr");

        labelLen = fileLabels["maxLength"].get!int - 10;
        labelLen = labelLen < 0 ? 0 : labelLen;
        fileLabels.remove("maxLength");
        initLabels = initLabels.aaUnion(fileLabels);
    }

    File cdlFile;
    ubyte cdlByte = 0;
    if (cdlFilename !is null)
    {
        cdlFile = File(cdlFilename, "r");
    }

    string header;
    string theOldLabel = "";
    auto theText = appender!string();
    theText ~= commentHeader(
            filename.baseName ~ " disasembled by DISASM6 v" ~ VERSION, false);
    auto invalidCounter = 0;

    int prgBank = 0;
    ubyte oldPrg = 0;
    string theLabel = "";
    Label[string] labels;
    Label[string] oldPrgLabels;
    HeaderInfo* headerInfo;
    string nmi, reset, break_;

    //  This loop is done x times
    //  The first pass we just collect addesses
    //  The next passes we look for new addresses
    //
    //  The last pass we build the actual output
    while (pass <= lastPass)
    {
        if (pass < 3)
        {
            labels = initLabels.dup;
        }
        auto prgLabels = initLabels.dup;

        auto counter = origin;

        if (fileStartOverride && !codeStartOverride)
        {
            file.seek(fileStart);
        }

        if (!ignoreHeader)
        {
            headerInfo = getHeaderInfo(file);
        }

        if (codeStartOverride)
        {
            file.seek(fileStart);
        }

        if (headerInfo)
        {
            oldPrg = headerInfo.prg;
        }
        else
        {

        }

        ubyte newPrg = 0;
        auto oldDidDrawLine = false;

        // do this stuff only on the first pass
        if (pass == 1)
        {
            oldDidDrawLine = false;
            oldLabels = labels.dup;

            // check for 16k roms
            if (!noDetect)
            {
                newPrg = 0;
                if (headerInfo && headerInfo.prg == 2)
                {
                    auto prg0 = file.rawRead(new ubyte[0x4000]);
                    auto prg1 = file.rawRead(new ubyte[0x4000]);
                    file.seek(fileStart + 0x10);

                    if (equal(prg0, prg1) && headerInfo.mapper == 0)
                    {
                        writeln(
                                "PRG Banks 0 and 1 are identical, 16k PRG suspected, use -d to disable check");
                        newPrg = 1;
                        origin = originOverride ? origin : 0xc000;

                        if (cdlFilename !is null)
                        {
                            cdlOffset += 0x4000;
                        }
                    }
                }
                else if (headerInfo && headerInfo.prg == 1)
                {
                    origin = originOverride ? origin : 0xc000;
                }
            }

            writeln("Using Origin: 0x" ~ dechex_pad(origin) ~ "\n");

            if (headerInfo !is null)
            {
                writeln("NES Header Found - " ~ (showHeader
                        ? "included in disassembly" : "not included"));
            }

            if (labelFile !is null)
            {
                writeln("Using user defined labels");
            }

            if (includeReg)
            {
                writeln("Using NES registers");
            }

            if (cdlFilename !is null)
            {
                writeln("Using code/data log");
            }

            if (ignoreWrites !is false)
            {
                writeln("Writes to PRG will not create labels");
            }

            if (usingMapper2 !is false)
            {
                writeln("Mapper 2 (UxROM) support enabled");
            }

            if (fileStartOverride && !codeStartOverride)
            {
                writeln("Starting at file location 0x" ~ dechex_pad(fileStart));
            }

            if (codeStartOverride)
            {
                fileStart = codeStart - origin + (headerInfo ? 10 : 0);
                origin = codeStart;
                originOverride = true;

                fileStartOverride = true;
                file.seek(fileStart);

                cdlOffset += fileStart - (headerInfo ? 10 : 0);

                writeln("Starting at code location $" ~ dechex_pad(fileStart));
            }

            if (lengthOverride)
            {
                writeln("Reading 0x" ~ dechex_pad(fileLength) ~ " bytes");

                fileLength += origin - (headerInfo ? 0x10 : 0);
            }

            if (includeChr && headerInfo !is null)
            {
                //writeln "Using CHR-ROM\n";
            }

            writeln();
        }

        if (cdlFilename !is null)
        {
            cdlFile.seek(cdlOffset);
        }

        // if 16k rom, update prg info
        if (newPrg)
        {
            headerInfo.prg = newPrg;
        }

        // do this stuff only on the lass pass
        if (pass == lastPass)
        {

            if (labelFile !is null)
            {
                theText ~= outputLabels(fileLabels, "User Defined Labels");
            }

            if (includeReg)
            {
                theText ~= outputLabels(registers, "Registers");
            }

            header = processHeaderInfo(headerInfo);

            if (header !is null && showHeader)
            {
                theText ~= header;
            }

            theText ~= commentHeader("Program Origin");
            theText ~= str_pad(LEFT_MARGIN ~ ".org $" ~ dechex_pad(counter), 30 + labelLen)
                ~ " ; Set program counter\n";
            theText ~= commentHeader("ROM Start");

        }

        // read the file
        // each pass of this loop completes one line of output

        counter = origin;
        writeln("Starting pass " ~ pass.to!string ~ " " ~ (pass == lastPass ? "(final) " : "")
                ~ "... ");
        auto didMoveCdlPtr = false;

        while (!file.eof && counter < fileLength)
        {
            auto add = false;
            auto invalidText = "Invalid Opcode";
            auto didDrawLine = false;

            // handle mapper 2
            if (usingMapper2 && headerInfo && headerInfo.mapper == 2
                    && counter == 0xC000 && prgBank < (headerInfo.prg - 1))
            {
                counter = 0x8000;
                prgBank++;

                if (pass == lastPass)
                {
                    theText ~= commentHeader("PRG Bank " ~ prgBank.to!string);
                    theText ~= LEFT_MARGIN ~ ".base 0x8000\n";
                    theText ~= commentLine();
                }
                continue;

            }

            // handle vectors

            if (pass < lastPass && counter == 0xFFFA)
            {
                nmi = wordStr(file.rawRead(new ubyte[2]));
                reset = wordStr(file.rawRead(new ubyte[2]));
                break_ = wordStr(file.rawRead(new ubyte[2]));

                addVector(nmi, "nmi", labels);
                addVector(reset, "reset", labels);
                addVector(break_, "irq", labels);

                prgLabels[nmi] = true;
                prgLabels[reset] = true;
                prgLabels[break_] = true;

                counter += 6;
                continue;
            }
            else if (pass == lastPass && counter == 0xFFFA)
            {
                theText ~= processVectors(nmi, reset, break_);
                file.rawRead(new char[6]);
                counter += 6;

                continue;
            }

            //read opcode
            int opcode = file.rawRead(new ubyte[1])[0];

            // OPcode members
            //ubyte legal;
            //string name;
            //ubyte bytes;
            //ubyte cycles;
            //ubyte addressing_mode;

            if (opcode !in opcodes)
            {
                writeln(opcode);
                return 2;
            }

            OPcode opcodeData = opcodes[opcode];
            auto isInvalid = opcodeData.legal;
            auto mnemonic = opcodeData.name;
            auto byteLen = opcodeData.bytes;
            auto addressingType = opcodeData.addressing_mode;

            bool isDataByte = false;
            auto dataStr = "Suspected data";
            ubyte newCdlByte = 0;
            string counter_pad;

            // check code/data log - if data, don' process as an opcode
            if (cdlFilename !is null)
            {
                newCdlByte = cdlFile.rawRead(new ubyte[1])[0];

                // draw line between data and code
                if (pass == lastPass && !oldDidDrawLine && counter != origin
                        && newCdlByte != 0 && ((newCdlByte & 0b00000001) != (cdlByte & 0b00000001)))
                {
                    theText ~= "\n" ~ commentLine();

                    didDrawLine = true;
                }

                // check if the CDL byte is known, if known, copy, otherwise do some checks
                if (newCdlByte != 0)
                {
                    cdlByte = newCdlByte;
                }
                // if byte is zero and we're at a program label, assume code
            else if (dechex_pad(counter) in oldPrgLabels)
                {
                    cdlByte = 0b00000001;
                }
                // if byte is zero and we're at a label, but not program, assume data (only on 2nd pass)
            else if (dechex_pad(counter) in oldLabels && pass > 1)
                {
                    cdlByte = 0b00000010;
                }
                // else assume program code

                // data byte
                if (((cdlByte & 0b00000010) >> 1) && !(cdlByte & 0b00000001))
                {

                    counter_pad = dechex_pad(counter);

                    if (isCounterLabel(counter, oldLabels))
                    {
                        writeln("get string 1");
                        theOldLabel = (oldLabels[counter_pad].peek!bool
                                && oldLabels[counter_pad].get!bool) ? "__" ~ counter_pad
                            : oldLabels[counter_pad].get!string;

                        //$theOldLabel = preg_replace('%^([^\+\-]+)[\+\-][0-9]+%', '$1', $theOldLabel);
                    }

                    if (equal(theOldLabel[$ - 9 .. $], "JumpTable"))
                    {
                        byteLen = 2;
                        mnemonic = ".word";
                        addressingType = 11;
                        isInvalid = 0;
                        //fseek($file, ftell($file) - 1);
                    }
                    else if (equal(theOldLabel[$ - 8 .. $], "RTSTable"))
                    {

                        byteLen = 2;
                        mnemonic = ".word";
                        addressingType = 12;
                        isInvalid = 0;

                    } /*
                else if (substr($theOldLabel, -8) == 'TableLow')
                {
                   $byteLen = 1;
                   $mnemonic = '.byte';
                   $addressingType = 13;
                   $isInvalid = 0;
                }
                else if (substr($theOldLabel, -9) == 'TableHigh')
                {
                   $byteLen = 1;
                   $mnemonic = '.byte';
                   $addressingType = 14;
                   $isInvalid = 0;
                }  */
                    else
                    {
                        byteLen = 4;
                        //writeln substr($theLabel, -11);
                        mnemonic = "";
                        addressingType = -1;
                        isInvalid = 1;
                    }
                    isDataByte = true;
                    dataStr = "Data";
                }
            }
            else
            {
                theOldLabel = ""; // Reset 'theOldLabel' when we are no longer in a known data byte
            }

            auto readBytes = byteLen - 1;
            ubyte[] bytes = [];
            string byteStr = "";
            string trailer = "";
            string hextext = dechex_pad(opcode);

            string[] byteArr = [hextext];

            // read 1 or 2 byte paramters for the opcode
            if (readBytes > 0)
            {
                if (pass >= 1)
                {
                    size_t cdlPos;

                    if (cdlFilename !is null)
                    {
                        cdlPos = cdlFile.tell;
                        didMoveCdlPtr = false;
                    }
                    // check to see if a label exists in this opcode.. if so then usually it's data
                    for (byte i = 1; i <= readBytes; i++)
                    {
                        if (isCounterLabel(counter + i, oldLabels) //if (isset($oldLabels[dechex_pad($counter + $i)])
                             || counter + i >= 0xFFFA
                                || (counter + i >= fileLength) || (usingMapper2 && headerInfo && headerInfo.mapper == 2
                                    && counter + i > 0xBFFF && prgBank < headerInfo.prg - 1)) // if counter in the vectors

                                    {
                            invalidCounter = 0;
                            readBytes = i - 1;
                            isInvalid = 1;
                            byteLen = i;
                            addressingType = -1;
                            continue;
                        }

                        // if this byte marked as data in cdl; check if next bytes are code
                        if (cdlFilename !is null && isDataByte)
                        {
                            newCdlByte = cdlFile.rawRead(new ubyte[1])[0];
                            didMoveCdlPtr = true;
                            if (newCdlByte & 0b00000001)
                            {
                                invalidCounter = 0;
                                readBytes = i - 1;
                                isInvalid = 1;
                                byteLen = i;
                                addressingType = -1;
                                continue;
                            }
                        }
                    }

                    if (didMoveCdlPtr && cdlFilename !is null)
                    {
                        cdlFile.seek(cdlPos);
                    }

                }

                if (readBytes > 0) // if readbytes is still > 0 after above
                {
                    bytes = file.rawRead(new ubyte[readBytes]);

                    if (cdlFilename !is null)
                    {
                        auto cdlBytes = cdlFile.rawRead(new ubyte[readBytes]);
                    }

                    for (size_t j = 0; j < readBytes; j++)
                    {
                        byteArr ~= dechex_pad(bytes[j]);
                        hextext ~= " " ~ byteArr[j + 1];
                    }

                    if (addressingType == 12)
                    {
                        byteStr = (byteArr.length > 1 ? byteArr[1] : "") ~ byteArr[0];
                        byteStr = dechex_pad(byteStr.parse!(int)(16) + 1);
                        //writeln " $counter $addressingType $byteStr ";
                        //print_r($byteArr);
                    }
                    else if (addressingType == 11)
                    {
                        byteStr = (byteArr.length > 1 ? byteArr[1] : "") ~ byteArr[0];
                    }
                    else
                    {
                        byteStr = (byteArr.length > 2 ? byteArr[2] : "") ~ byteArr[1];
                    }
                }
            }

            // ASM6 seems to do some optimization and won't allow absolute addr mode
            // when using $00xx.. it turns it into $xx
            // so instead we'll use .hex
            if (readBytes == 2 && byteStr[0 .. 2] == "00" && addressingType > 0
                    && addressingType < 9// && $addressingType != 9
                     && addressingType != 3)
            {
                isInvalid = 1;
                invalidText = "Bad Addr Mode";
            }

            // add label to list
            auto oldByteStr = byteStr;
            string lbl = "$";
            if (addressingType > 0 && isValidLabel(byteStr) && !(ignoreWrites
                    && mnemonic[0 .. 2] == "ST" && (byteStr.parse!int(16) < 0x8000))) // do not add labels when writing to PRG
                    {

                lbl = "__";

                if (pass < lastPass && isInvalid != 1)
                {

                    addValidLabel(byteStr, labels);
                }

            }

            oldByteStr = byteStr;

            //    $byteStrDec = (dechex_pad($byteStr);
            auto newByteStr = lbl ~ byteStr;

            auto oldLabelPtr = byteStr in oldLabels;
            if (oldLabelPtr && lbl.length)
            {
                newByteStr = (oldLabelPtr.peek!bool && oldLabelPtr.get!bool) ? newByteStr
                    : (oldLabelPtr.peek!string ? oldLabelPtr.get!string : "Array");
            }

            // lets check for various addressing types to figure out how to format the text
            switch (addressingType)
            {

            case 0: // Implicit/Accumulator/Immediate
                byteStr = (readBytes > 0 ? "#$" ~ byteStr : "");
                break;

            case 10: .. case 12:
                if (!isInvalid)
                {
                    addValidLabel(byteStr, prgLabels);
                }
                goto case;
            case 1: // Absolute
            case 4: // Zero Page

                byteStr = newByteStr;

                if (addressingType == 12)
                {
                    byteStr ~= "-1";
                }

                break;

            case 2: // Absolute X
            case 5: // Zero Page X
                byteStr = newByteStr ~ ",x";
                break;

            case 3: // Absolute Y
            case 6: // Zero Page Y
                byteStr = newByteStr ~ ",y";
                break;

            case 7: // Indrect X
                byteStr = "(" ~ newByteStr ~ ",x)";
                break;

            case 8: // Indirect Y
                byteStr = "(" ~ newByteStr ~ "),y";
                break;

            case 9: // Indirect Jump
                byteStr = "(" ~ newByteStr ~ ")";
                break;
            default:
                break;
            }

            // now lets cover specific mnemonics

            switch (mnemonic)
            {
                // handle branches
            case "BCC":
            case "BCS":
            case "BEQ":
            case "BMI":
            case "BNE":
            case "BPL":
            case "BVC":
            case "BVS":
                oldByteStr = oldByteStr.length ? oldByteStr : "0";
                string addr = addressOffset(counter, oldByteStr.parse!int(16));

                auto isInvalidBranch = false;

                if (pass < lastPass && !isInvalid && !isInvalidBranch)
                {
                    addValidLabel(addr, labels);
                    addValidLabel(addr, prgLabels);
                }

                if (!isInvalidBranch && isValidLabel(addr))
                {
                    auto str = addr in labels;
                    if (str && str.peek!string)
                    {
                        byteStr = str.get!string;
                    }
                    else
                    {

                        byteStr = "__" ~ addr;
                    }
                }
                else
                {
                    isInvalid = true;
                    invalidText = "Illegal Branch";
                }

                break;

                // add some space after RTS/JMP
            case "RTS":
            case "RTI":
            case "JMP":
                if (!isInvalid)
                {
                    trailer = "\n" ~ commentLine();
                    didDrawLine = true;
                }
                break;
            default:
                break;

            }

            // only deal with output on last pass
            if (pass == lastPass)
            {
                string oldMnemonicStr = "";
                if (isInvalid)
                {
                    oldMnemonicStr = addressingType == -1 ? dataStr
                        : (invalidText ~ " - " ~ mnemonic ~ " " ~ byteStr);
                    mnemonic = ".hex";
                    byteStr = hextext;

                }
                counter_pad = dechex_pad(counter);
                if (auto oldLabel = counter_pad in oldLabels)
                {
                    import std.algorithm : countUntil;

                    size_t leng = 1;
                    auto labelValueArr = oldLabel.peek!(string[]);
                    if (labelValueArr)
                    {
                        leng = labelValueArr.length;

                    }

                    for (size_t i = 0; i < leng; i++)
                    {
                        if (labelValueArr)
                        {
                            theLabel = (*labelValueArr)[i];
                        }
                        else
                        {
                            theLabel = (oldLabel.peek!bool && oldLabel.get!bool) ? "__" ~ counter_pad
                                : oldLabel.get!string;

                        }

                        // if label has a + or - in it but doesn't start with one
                        // then don't show it
                        // if not 0 or false
                        if (theLabel.countUntil('+') != -1 || theLabel.countUntil('-') != -1)
                        {
                            writeln(theLabel);
                            writeln(theLabel.countUntil('+'));
                            theText ~= LEFT_MARGIN;
                            continue;
                        }

                        switch (theLabel)
                        {
                        case "irq":
                            theText ~= commentHeader("irq/brk vector", !(oldDidDrawLine
                                    || didDrawLine), !(oldDidDrawLine || didDrawLine));
                            break;

                        case "nmi":
                        case "reset":
                            theText ~= commentHeader("theLabel vector", !(oldDidDrawLine
                                    || didDrawLine), !(oldDidDrawLine || didDrawLine));
                            break;
                        default:
                            break;

                        }

                        if (theLabel.length >= marginLen - 1)
                        {
                            theText ~= (oldDidDrawLine || didDrawLine
                                    || (counter == origin) ? "" : "\n") ~ "theLabel:\n"
                                ~ LEFT_MARGIN;
                        }
                        else
                        {
                            theText ~= str_pad(theLabel ~ ":", marginLen);
                        }

                    }

                }
                else
                {
                    theText ~= LEFT_MARGIN;
                }

                //line = array_key_exists(dechex_pad(counter), oldLabels) ? '__' ~ dechex_pad(counter) .':' : '       ';
                string line = (useLowerCase ? mnemonic.toLower : mnemonic) ~ " " ~ byteStr;
                line = str_pad(line, 30 - marginLen + labelLen);
                line ~= " ; $" ~ dechex_pad(counter) ~ ": " ~ hextext;
                line = str_pad(line, (isDataByte ? 54 : 50) - marginLen + labelLen);
                line ~= (isInvalid ? oldMnemonicStr : "");
                line ~= "\n" ~ trailer;
                theText ~= line;

            }
            counter += byteLen;
            oldDidDrawLine = didDrawLine;
        } // end line by line loop

        if (pass < lastPass && oldLabels.length && labels == oldLabels)
        {
            lastPass = pass + 1;
        }
        /*else if(pass < lastPass)
       {
          writeln "pass < lastPass && oldLabels !== false && labels == oldLabels (" ~ print_r(labels == oldLabels,true);
          file_put_contents('out', print_r(labels,true) ~ print_r(oldLabels, true));
          file_put_contents('out2', print_r(array_diff_assoc(labels, oldLabels),true));
       }*/

        if (pass < lastPass)
        {

            oldLabels = labels.dup;
            oldPrgLabels = prgLabels.dup;
            file.rewind;
        }

        writeln("complete");
        pass++;
    }

    if (includeChr && headerInfo)
    {

        file.seek(oldPrg * 0x4000 + 0x10);

        char[] chr = [];

        while (!file.eof)
        {
            chr ~= file.rawRead(new char[1024]);
        }

        theText ~= "\n";
        theText ~= commentLine();
        theText ~= "; CHR-ROM";
        theText ~= "\n";
        theText ~= commentLine();

        string incLine = LEFT_MARGIN ~ ".incbin " ~ shortname ~ ".chr";
        theText ~= str_pad(incLine, 30 + labelLen);
        theText ~= " ; Include CHR-ROM\n";

        chr.toFile(shortname ~ ".chr");
        write("\nCHR-ROM exported as " ~ shortname ~ ".chr");

    }
    else if (includeChr)
    {
        write("\nCHR-ROM cannot be exported without iNES header data");
        if (ignoreHeader)
        {
            write("\nTry disabling -ignoreheader if you wish to export CHR-ROM data");
        }
    }

    theText.data.toFile(shortname ~ ".asm");

    time_start.stop();
    auto time = time_start.peek().msecs / 1e3;

    writefln("\nDisassembly %s.asm generated in %s seconds\n", shortname, time);
    return 0;
}