module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit
writeData,
outPc,
output5,
output7,
output15;

	
	
wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write data input of Register File
out31;

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc;	//current instruction
wire [31:0] dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
nout,	//Neg output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0, 
zSignal, nSignal, mux3signal2,mux3signal1,mux3signal0,signal31,linkaddressignal,signal29,pc4signal,addresmemorysignal;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

wire [31:0] jmor; 

wire [31:0] jspal;

wire nSignal_q, zSignal_q;

integer i;

// datamemory connections

always @(negedge clk)
//write data to memory
if (instruc[31:26] == 6'h13)
begin 
//sum stores address,datab stores the value to be written
datmem[jspal[31:0]+3]=adder1out[7:0];
datmem[jspal[31:0]+2]=adder1out[15:8];
datmem[jspal[31:0]+1]=adder1out[23:16];
datmem[jspal[31:0]]=adder1out[31:24];
end

always @(posedge clk)
if (memwrite && instruc[31:26] != 6'h13)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];


// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2


assign jmor = dataa | datab;

assign jspal = registerfile[29];

always @(posedge clk) begin
if (((regdest == 1) && (instruc[5:0] == 6'h37)) || ((nout == 1) && (instruc[31:26] == 6'h27)))
registerfile[31] = adder1out;
else if (regdest == 1 && instruc[5:0] == 6'h04) //Function code is the same as another function code 
registerfile[out31] = datab << dataa;
else if (regwrite == 1)
 registerfile[out31]= writeData;
 else
 registerfile[out31] = registerfile[out31];//Write data to register
end
//read data from memory, sum stores address
 
assign dpack = (((zout == 1) && (inst31_26 == 6'h20)) ? {datmem[extad[5:0]],datmem[extad[5:0]+1],datmem[extad[5:0]+2],datmem[extad[5:0]+3]} : (((regdest == 1) && (instruc[5:0] == 6'h37)) ?  {datmem[jmor[5:0]],datmem[jmor[5:0]+1],datmem[jmor[5:0]+2],datmem[jmor[5:0]+3]} : ((instruc[31:26] == 6'h19) ? {datmem[jspal[5:0]],datmem[jspal[5:0]+1],datmem[jspal[5:0]+2],datmem[jspal[5:0]+3]} : {datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]})));


//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

//mux for 31 signal for question 11
mult2_to_1_5 mult31(out31, out1, 5'b11111, signal31);


//mux for write data for question 11 and 5
mult2_to_1_32 multwriteData(writeData, out3, adder1out, linkaddressignal);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);




integer my_int;
always @( sum )
    my_int = sum;

//mux for question 5 (buyuge giren)
mult2_to_1_32 mult5(output5, out4, {datmem[my_int],datmem[my_int+1],datmem[my_int+2],datmem[my_int+3]}, nSignal_q);

//mux for question 7 (buyuge giren)
mult2_to_1_32 mult7(output7, out4, dataa, zSignal_q);


//mux for question 15 (buyuge giren)
mult2_to_1_32 mult15(output15, out4, {adder1out[31:28], instruc[25:0], 2'b00}, nSignal_q  && (instruc[31:26] == 6'b011001));


mult8_to_1_32 multFinal(outPc, out4, output5, output7, {datmem[my_int],datmem[my_int+1],datmem[my_int+2],datmem[my_int+3]}, output15, {datmem[jspal[5:0]],datmem[jspal[5:0]+1],datmem[jspal[5:0]+2],datmem[jspal[5:0]+3]}, out4, out4, {mux3signal2,mux3signal1,mux3signal0});

flipflop flipflop(nSignal, clk, nSignal_q);
flipflop flipflop2(zSignal, clk, zSignal_q);

new_component nz(sum, zSignal, nSignal);




// load pc
always @(negedge clk)
if ((zout == 1) && (inst31_26 == 6'h20) && (regdest == 1))
pc = dataa;
else if ((zout == 1) && (inst31_26 == 6'h20))
pc = dpack;
else if (regdest == 1 && instruc[5:0] == 6'h37)
pc = dpack;
else if ((nout == 1) && (instruc[31:26] == 6'h27))
pc = {adder1out[31:28],instruc[25:0],2'b00};
// else if (instruc[31:26] == 6'h19)
// pc = dpack;
else
pc=outPc; //!!!!!!

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,nout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch, aluop1,aluop0, instruc[5:0], mux3signal2,mux3signal1,mux3signal0,signal31,linkaddressignal,signal29,pc4signal,addresmemorysignal, nSignal_q);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate
assign pcsrc= (branch && zout); 

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

