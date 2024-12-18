`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2024 07:47:19 AM
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Control(
    output [15:0] LED,
    output [7:0] D1_SEG,
    output [3:0] D1_AN,
    input [15:0] SW,
    input [3:0] BTN,
    input clk
    );
    wire clk25;
    clkDivider sysClock (clk25, clk);
    
    //instruction_memory output
    wire [2:0] targetIn, AregIn, BregIn;
    wire [7:0] immed;
    wire [4:0] funct;
    wire [15:0] instr;
    
    //Sw_intruction output
    wire [2:0] SWtargetIn, SWAregIn, SWBregIn;
    wire [7:0] SWimmed;
    wire [4:0] SWfunct;
    wire [15:0] SWinstr;
    
    //ALU outputs
    wire [7:0] ALUresult;
    wire zeroFlag;
    wire overflow;
    
    //ALU inputs
    reg [2:0] ALUop;
    reg [7:0] alui_opA, alui_opB;
    
    //reg file input
    reg regWrite;
    reg [2:0] targetReg,Areg,Breg;
    reg [7:0] writeData;
    
    //reg file output
    wire [7:0] o_Areg, o_Breg;
    
    //mem file inputs
    reg memWrite = 0;
    reg [7:0] memDataIn = 0;
    reg [7:0] addressIn = 0;
    reg memReadWrite = 0;

    // mem file outputs
    wire [7:0] memDataOut;
    
    //7Seg signals
    reg [3:0] ones;
    reg [3:0] tens;
    reg [3:0] hundreds;
    wire [15:0] BCD_result_extended;
    wire [11:0] BCD_result;
    //reg [7:0] display_num;
    reg displayON = 0;
    
    //control signals
    reg [7:0] PC = 0;
    reg [7:0] PCnext = 0;
    reg SWmode = 0;
    reg writeDataSrc = 0;
    reg memDataSrc = 0;
    reg branch = 0;
    wire SWexe; //acts as SWmode 'clock'
    reg [7:0] jumpCount = 0;
    reg [7:0] jumpLimit = 8'hff;
    reg jumpEnable = 0;
    reg [7:0] PClink = 0;
    
    debouncer exe (SWexe, BTN[0], clk25);
    
    Instruction_Memory Instr (
    instr, 
    funct, 
    targetIn, 
    AregIn, 
    BregIn, 
    immed, 
    PC, 
    clk25);
    
    SW_Instruction_Memory SW_instr (
    SWinstr, 
    SWfunct, 
    SWtargetIn, 
    SWAregIn, 
    SWBregIn, 
    SWimmed, 
    SW, 
    SWmode, 
    SWexe,
    clk25);
    
    localparam ALU = 2'd0;
    localparam LI = 2'd1;
    localparam sevenseg = 2'd3;
    always @ (posedge clk25) begin 
        jumpCount <= jumpEnable ? (jumpCount + 1) : jumpCount;      
        if (PC == 8'd255)begin
            SWmode <= 1;
        end
        else begin
            PC <= SWmode ? 0 : PCnext;
        end
    end
    
always @ (*)begin
    regWrite = 0;
    memReadWrite = 0; 
    displayON = 0; 
    memDataSrc = 0;
    ALUop = 0;
    targetReg = 0;
    Areg = 0;
    Breg = 0;
    addressIn = 0;
    jumpLimit = jumpLimit;
    case (SWmode)
    0: begin
       case (funct[4:3])
	0: 	begin  //alu 
			ALUop = funct[2:0];
			targetReg = targetIn;
			Areg = AregIn;
			Breg = BregIn;
			regWrite = 1'd1;
			writeDataSrc = 1'b0;
		end
	1:  begin //li
		    regWrite = 1'd1;
            targetReg = targetIn;            
            writeDataSrc = 1'b1;
		end
	2: begin
		case (funct[2:0])
			0: begin //SW
				Areg = targetIn;
				memReadWrite = 1;
				addressIn = immed;
				memDataSrc = 0;
			   end
			1: begin //LW
				targetReg = targetIn;
				addressIn = immed;
				regWrite = 1;
				writeDataSrc = 0;
			   end
			2: begin //Link (store PC in dataMem[immed])
			     memReadWrite = 1; 
			     addressIn = immed;
			     memDataSrc = 1;
			     PClink = PC;
			   end  
			3: begin //JUMP (jumps to PC = dataMem[RT], limit = immed)
			     jumpLimit = immed;       
			     addressIn = targetIn; 
			     writeDataSrc = 0;
			   end
			4: begin //BEQ to PC @ dataMem[immed] 
			     Areg = AregIn;
			     Breg = BregIn;
			     ALUop = 3'b011;
			     addressIn = targetIn;
			     writeDataSrc = 0;
			   end
		  endcase
		end
	3: begin //7seg
			Areg = targetIn; // make Areg = targetIn (targetIn is the reg to display) then display Areg to B
            Breg = 0; //reg[0] == zeroReg. ALUop will be set to add 
            writeDataSrc = 1'b0;
            displayON = 1;
	   end
    endcase
    end      //end SWmode == 0 code        
    
    1: begin //begin SWmode == 1 code
        if (SWfunct == 5'b10000)begin //SW
            Areg = SWtargetIn;
            memReadWrite = 1;
            addressIn = SWimmed;
        end
        else if (SWfunct == 5'b10001)begin//LW
            targetReg = SWtargetIn;
            addressIn = SWimmed;
            regWrite = 1;
            writeDataSrc = 0;
        end
        else if (SWfunct[4:3] == ALU)begin //math/logic 
            ALUop = SWfunct[2:0];
            targetReg = SWtargetIn;
            Areg = SWAregIn;
            Breg = SWBregIn;
            regWrite = 1'd1;
            writeDataSrc = 1'b0;
        end
        else if (SWfunct[4:3] == LI)begin //LI
            regWrite = 1'd1;
            targetReg = SWtargetIn;            
            writeDataSrc = 1'b1;
        end  
        else if (SWfunct[4:3] == sevenseg) begin //display target reg to 7 seg
            Areg = SWtargetIn; // make Areg = targetIn (targetIn is the reg to display) then display Areg to B
            Breg = 0; //reg[0] == zeroReg. ALUop will be set to add 
            writeDataSrc = 1'b0;
            displayON = 1;
        end        
    end
    endcase
end

    dataMem m0 (
    .dataOut (memDataOut), 
    .dataIn (memDataIn), 
    .address (addressIn), 
    .memReadWrite (memReadWrite),
    .clk (clk25)
    );
    
    Registers r0 (o_Areg, o_Breg, Areg, Breg, targetReg, regWrite, writeData,clk25);
    always @(*)begin
        alui_opA = o_Areg;
        alui_opB = o_Breg;
        memDataIn = memDataSrc ? (PClink) : o_Areg;
    end
    
    ALU a0 (ALUresult, zeroFlag, overflow, alui_opA, alui_opB, ALUop, funct[4:3]);
    
    always @ (*) begin
        if ((((funct == 5'b10100) && zeroFlag)) || ((funct == 5'b10011) && (jumpLimit > jumpCount))) begin
            branch = 1;
        end
        else begin
            branch = 0;
        end
    end
    
    reg [7:0] branchTarget = 0;
    
    always @ (*)begin
         PCnext = PC + 1;
         branchTarget = memDataOut;
         jumpEnable = 0;
         if ((funct == 5'b10001) || (SWfunct == 5'b10001)) begin //LW
            writeData = memDataOut;
         end
         else if (writeDataSrc == LI) begin
            writeData = SWmode ? SWimmed : immed; //writedatasrc is 1 when doing an LI instruction
         end 
         else if (funct == 5'b10100)begin //BEQ
            PCnext = branch ? branchTarget : PC + 1;
            writeData = 0;
         end
         else if (funct == 5'b10011) begin //JUMP
            PCnext = branch ? branchTarget : PC + 1;
            jumpEnable = branch;
            writeData = 0;
         end
         else begin
            writeData = ALUresult;  
            
         end
    end 
   assign LED[15] = SWmode; 
   assign LED[14:12] = jumpCount;
   assign LED[11:9] = jumpLimit; 
   assign LED[8] = branch;
   assign LED[7:0] = PC;
   
   //bin2bcd module is taken from RealDigital.org
   //takes a 14 bit binary input and outputs 4 digit (16 bit) decimal out
   wire [13:0] extended = alui_opA; //expand alui_opA to 14 bits
   bin2bcd bcd (BCD_result_extended, extended);
   always @(BCD_result_extended) begin
   if (displayON == 1) begin
      ones = BCD_result_extended[3:0];
      tens = BCD_result_extended[7:4];
      hundreds = BCD_result_extended[11:8];
      end
      else begin
      ones = ones;
      tens = tens;
      hundreds = hundreds;
      end
   end
   
   timer_display d0 (D1_SEG, D1_AN, ones, tens, hundreds, clk);
endmodule

module SW_Instruction_Memory(
    output reg [15:0] instr,
    output reg [4:0] funct_o,
    output reg [2:0] target_o, Areg_o, Breg_o,
    output reg [7:0] immed_o,
    input [15:0] Switch,
    input SWmode,
    input SWexe,
    input clk
    );
    //in SWmode the instructions are read from the 16 input switches
    //SWmode sends instruction on posedge SWexe (push button on board)
    always @ (posedge clk)begin
        if ((SWmode == 1) && SWexe) begin
            funct_o = Switch[15:11];
            target_o = Switch[10:8];
            Areg_o = Switch[5:3];
            Breg_o = Switch[2:0];
            immed_o = Switch[7:0];
            instr = Switch;
        end
    end
endmodule

module Instruction_Memory(
    output [15:0] instr,
    output [4:0] funct_o,
    output [2:0] target_o, Areg_o, Breg_o,
    output [7:0] immed_o,
    input [7:0] PC,
    input clk
    );
    reg [15:0] instrMem [255:0];
    
    initial $readmemb("memory.mem", instrMem);
    
     assign funct_o = instrMem [PC][15:11];
     assign target_o = instrMem [PC][10:8];
     assign Areg_o = instrMem [PC][5:3];
     assign Breg_o = instrMem [PC][2:0];
     assign immed_o = instrMem [PC][7:0];
     assign instr = instrMem[PC];
    
endmodule

module debouncer(
output trans_dn, 
input switch_input, clk);
    
   reg state;  
   reg sync_0, sync_1; // For 2-bit SRG
   reg[19:0] count;    // Counter for debounce
   wire idle = (state == sync_1); // Is the state the same (i.e. idle)?
   wire finished = (count > 20'd1_000_000); // Done with count?

   always @ (posedge clk) begin   // 2-bit SRG
      sync_0 <= switch_input;
      sync_1 <= sync_0;
   end
	
   always @ (posedge clk) begin
      if (idle)
         count <= 20'b0;
      else begin
         count <= count + 20'b1;
         if (finished) // Wait for 1/100 s (10 ms.)
            state <= ~state;
      end
   end
	
   assign trans_dn = ~idle & finished & ~state;
   assign trans_up = ~idle & finished & state;
endmodule

module Registers(
output [7:0] dataA, dataB,
input [2:0] regA, regB, target,
input readWrite,
input [7:0] writeData,
input clk
    );   
    reg [7:0] regFile [0:7];
    always @ (posedge clk) begin
            if ((readWrite == 1) && (target != 0)) begin
            regFile[target] <= writeData;
        end
    end

    assign dataA = regFile[regA];
    assign dataB = regFile[regB];

endmodule

module ALU(
    output reg [7:0] result, 
    output zeroFlag, 
    output overflow,
    input [7:0] opA, opB, 
    input [2:0] ALUop,
    input [1:0] funct);    
    //ALUop functions
    /*   000 = AND
         001 = OR
         010 = ADD
         011 = Subtract
         100 = set less
         101 = NOR
         110 = set equal */    
    always @ (ALUop,opA, opB) begin
        if (funct == 2'd3)begin
            result = opA; //passthrough to 7 seg
        end
        else begin
        case (ALUop)
            0: result = opA & opB;
            1: result = opA | opB;
            2: result = opA + opB;
            3: result = opA - opB;
            4: result = opA < opB ? 8'd1: 0;
            5: result = ~(opA |opB);
            6: result = opA == opB ? 8'd1:0;
            default: result <= 0;
        endcase            
        end
    end
    assign zeroFlag = (result == 0);
    assign overflow = ((opA[7] == opB[7]) && (opA[7] != result[7]));
endmodule 

module dataMem(
output [7:0] dataOut,
input [7:0] dataIn,
input [7:0] address,
input memReadWrite,
input clk
);

reg [7:0] dataMem [255:0];
always @ (posedge clk) begin
    if (memReadWrite == 1)begin
        dataMem [address] <= dataIn;
    end
end
assign dataOut = dataMem [address];
       
endmodule

module bin2bcd(
   output reg [15:0] bcd,
   input [13:0] bin
   );
  
integer i;
	
always @(bin) begin
    bcd=0;		 	
    for (i=0;i<14;i=i+1) begin					//Iterate once for each bit in input number
        if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		//If any BCD digit is >= 5, add three
	if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
	if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
	if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
	bcd = {bcd[14:0],bin[13-i]};				//Shift one bit, and shift in proper bit from input 
    end
end
endmodule

module timer_display(
   output [7:0] Seg,
   output reg [3:0] Display,
   input [3:0] ones, tens, hundreds,
   input clk);
    
    reg [3:0] D;
    reg [2:0] state = 0;
	reg [23:0] prescaler; //17 needed?
    
    decoder_7_seg d (Seg, D);
   
    always @ (posedge clk) begin
	  prescaler <= prescaler + 24'b1;
	  if (prescaler == 24'd100000) begin //  100MHz/100,000 = 1 kHz
          prescaler <= 0;
          case (state)
                0: begin //inital state
                      D <= ones; 
                      Display <= 8'b11111110;
                   end
                1: begin //programming state
                      D <= tens; 
                      Display <= 8'b11111101;
                   end
                2: begin//running state
                      D <= hundreds; 
                      Display <= 8'b11111011;
                   end                
                default: begin
                      D <= 4'b1111;
                      Display <= 8'b11111111;
                   end
              endcase
              state <= state + 1;
              if (state == 8) begin
               state <= 0;
               end
        end
   end
endmodule

module decoder_7_seg(output reg [7:0] Seg, input [3:0] D);	
   always @(D)
      case (D) 
         4'd0:    Seg = 8'b11000000;
         4'd1:    Seg = 8'b11111001; 
         4'd2:    Seg = 8'b10100100; 
         4'd3:    Seg = 8'b10110000;
         4'd4:    Seg = 8'b10011001;
         4'd5:    Seg = 8'b10010010;
         4'd6:    Seg = 8'b10000010;
         4'd7:    Seg = 8'b11111000;
         4'd8:    Seg = 8'b10000000;
         4'd9:    Seg = 8'b10010000;
         default: Seg = 8'b10101111; 
      endcase
endmodule

module clkDivider(
    output clk25,
    input clk
    );
   reg [1:0] counter;
   reg clk25reg;
 always @ (posedge(clk))
 begin
     if (counter == 8'b11) begin
        counter <= 0;
        clk25reg <= ~clk25reg;
     end
     else begin
        counter <= counter + 1;
     end
end
assign clk25 = clk25reg;
endmodule
