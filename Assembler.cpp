#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <bitset>
#include <map>
#include <algorithm>

using namespace std;

int regToInt(string reg);
int immedToBin(string immed);

int errorCount = 0;
int lineCount = 0;

// pipelined CPU no longer takes all 0 initial instruction

int main() {
    ifstream programFile("program.txt");
    ofstream memFile("memory.mem");

    string instructionIn;
    string instructionOut;
    string aluop;
    string ra;
    string rb;
    string rt;
    string funct;
    string immed;
    string jumpLimit;
    
    map<string, int> functMap = {
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
    };

    if (!programFile.is_open()){
        cerr << "Can't open file";
        return 1;
    }
    
    int intRT, intRA, intRB, immedInt;
    bitset<3> binRT, binRA, binRB;
    bitset<8> immedBin;
    memFile << "0000000000000000 //padding" << endl;
    while (getline(programFile, instructionIn)){
        lineCount += 1;
        stringstream ss(instructionIn);
        getline(ss, funct, ' ');
        
        switch (functMap[funct]) {
            case 0: // SB
                getline(ss, rt, ',');
                getline(ss, immed);
                intRT = regToInt(rt);
                immedInt = stoi(immed);
                binRT = bitset<3>(intRT);
                immedBin = bitset<8>(immedInt);
                memFile << "10000" << binRT.to_string() << immedBin.to_string() << " // "<< funct << " " << rt << "," << immed  << endl; 
                break;   

            case 1: // LB
                getline(ss, rt, ',');
                getline(ss, immed);
                intRT = regToInt(rt);
                immedInt = stoi(immed);
                binRT = bitset<3>(intRT);
                immedBin = bitset<8>(immedInt);
                memFile << "10001" << binRT.to_string() << immedBin.to_string() << " // "<< funct << " " << rt << "," << immed << endl; 
                break;   

            case 2: // LI
                getline(ss, rt, ',');
                getline(ss, immed);
                intRT = regToInt(rt);
                immedInt = stoi(immed);
                binRT = bitset<3>(intRT);
                immedBin = bitset<8>(immedInt);
                memFile << "01000" << binRT.to_string() << immedBin.to_string() << " // "<< funct << " " << rt << "," << immed << endl; 
                break;  

            case 3: // DISPLAY
                getline(ss, rt, ',');                
                intRT = regToInt(rt);                
                binRT = bitset<3>(intRT);
                memFile << "11000" << binRT.to_string() << "00000000" << " // "<< funct << " " << rt << endl; 
                break;  

            case 4: // LINK
                getline(ss, immed);
                immedInt = stoi(immed);
                immedBin = bitset<8>(immedInt);
                memFile << "10010000" << immedBin.to_string() << " // "<< funct << " " << immed << endl; 
                break;  

            case 5: // JUMP
                getline(ss, rt, ',');
                getline(ss, immed);
                intRT = stoi(rt);
                intRB = stoi(immed);
                binRT = bitset<3>(intRT);
                immedBin = bitset<8>(intRB);
                memFile << "10011" << binRT.to_string() << immedBin.to_string() << " // "<< funct << " " << rt << "," << immed << endl; 
                break;  

            case 6: // BEQ
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = stoi(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "10100" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  
			// ALU operations, bad register outputs please check all instances outputs
            case 7: // AND
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00000" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  

            case 8: // OR
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00001" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  

            case 9: // ADD
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00010" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  

            case 10: // SUB
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00011" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  

            case 11: // SLT
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00100" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  

            case 12: // NOR
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00101" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  

            case 13: // SETEQUAL
                getline(ss, rt, ','); 
                getline(ss, ra, ',');
                getline(ss, rb);
                intRT = regToInt(rt);
                intRA = regToInt(ra);
                intRB = regToInt(rb);
                binRT = bitset<3>(intRT);
                binRA = bitset<3>(intRA);
                binRB = bitset<3>(intRB);
                memFile << "00110" << binRT.to_string() << "00" << binRA.to_string() << binRB.to_string() << " // "<< funct << " " << rt << "," << ra << "," << rb << endl; 
                break;  
        }
    }
    memFile << "// line count: " << lineCount << " (not including padding)" << endl;
	memFile << "// error count: " << errorCount << endl;
    memFile << "0000000000000000 //padding (initialize remaining instruction memory to all 0's)" << endl;
    for (int i = 0; i < (255 - lineCount - 1); i++){
        memFile << "0000000000000000" << endl;
    }
    programFile.close();
    memFile.close();
    return 0;
}

int regToInt(string reg){
	int intReg;
	reg.erase(remove(reg.begin(), reg.end(), ' '), reg.end());
    if (reg == "R0") intReg = 0;
    else if (reg == "R1") intReg = 1;
    else if (reg == "R2") intReg = 2;
    else if (reg == "R3") intReg = 3;
    else if (reg == "R4") intReg = 4;
    else if (reg == "R5") intReg = 5;
    else if (reg == "R6") intReg = 6;
    else if (reg == "R7") intReg = 7;
	else {
		cout << "Error! Invalid Register on line "<< lineCount << endl;
		errorCount += 1;
	}
	
    return intReg;
}
