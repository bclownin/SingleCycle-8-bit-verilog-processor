def registerToBin(regIn):
   regDec = int(''.join(filter(str.isdigit, regIn)))
   regBin = bin(regDec)[2:]
   extended_regBin = regBin.zfill(3)
   return extended_regBin

def immedToBin(immedIn):
    immedBin = bin(int(immedIn))[2:]
    extended_immedBin = immedBin.zfill(8)
    return extended_immedBin

def lineToString(line):
    lineString = " //" 
    for i in line:
        lineString = lineString + " " + i
    lineString = lineString + "\n"
    return lineString

programIn = open("program.txt", "r")
Lines = programIn.readlines()
"""
        {"SB", 0},
        {"LB", 1},
        {"LI", 2},
        {"DISPLAY", 3},
        {"LINK", 4},
        {"JUMP", 5},
        {"BEQ", 6},
        {"AND", 7},
        {"OR", 8},
        {"ADD", 9},
        {"SUB", 10},
        {"SLT", 11},
        {"NOR", 12},
        {"SETEQUAL", 13},
"""
memoryFile = open("memory.mem", "w")
memoryFile.write("0000000000000000\n")
lineCount = 0

for line in Lines:
    lineCount = lineCount + 1
    line = line.split()
    if line[0] == "SB":
        memoryFile.write("10000" + registerToBin(line[1]) + immedToBin(line[2]) + lineToString(line))

    elif line[0] == "LB":
        memoryFile.write("10001" + registerToBin(line[1]) + immedToBin(line[2]) + lineToString(line))

    elif line[0] == "LI":
        memoryFile.write("01000" + registerToBin(line[1]) + immedToBin(line[2]) + lineToString(line))

    elif line[0] == "DISPLAY":
        memoryFile.write("11000" + registerToBin(line[1]) + "00000000" + lineToString(line))

    elif line[0] == "LINK":
        memoryFile.write("10010000" + immedToBin(line[1]) + lineToString(line))

    elif line[0] == "JUMP":
        memoryFile.write("10011" + registerToBin(line[1]) + immedToBin(line[2]) + lineToString(line))
        
    elif line[0] == "BEQ":
        memoryFile.write("10100" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3]) + lineToString(line))

    elif line[0] == "AND":
        memoryFile.write("00000" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

    elif line[0] == "OR":
        memoryFile.write("00001" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

    elif line[0] == "ADD":
        memoryFile.write("00010" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

    elif line[0] == "SUB":
        memoryFile.write("00011" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

    elif line[0] == "SLT":
        memoryFile.write("00100" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

    elif line[0] == "NOR":
        memoryFile.write("00101" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

    elif line[0] == "SETEQUAL":
        memoryFile.write("00110" + registerToBin(line[1]) + "00" + registerToBin(line[2]) + registerToBin(line[3])+ lineToString(line))

#out of for loop
memoryFile.write("//Line count: " + str(lineCount) + "\n")
for i in range ((254 - lineCount)):
    memoryFile.write("0000000000000000\n")