module alu32(sum,a,b,zout,nout,gin);//ALU operation according to the ALU control line values
output [31:0] sum;
input [31:0] a,b; 
input [2:0] gin;//ALU control line
reg [31:0] sum;
reg [31:0] less;
output zout,nout;
reg zout,nout;
always @(a or b or gin)
begin
	case(gin)
	3'b010: sum=a+b; 		//ALU control line=010, ADD
	3'b110: sum=a+1+(~b);	//ALU control line=110, SUB
	3'b111: begin less=a+1+(~b);	//ALU control line=111, set on less than
			if (less[31]) sum=1;	
			else sum=0;
		  end
	3'b000: sum=a & b;	//ALU control line=000, AND
	3'b001: sum=a|b;		//ALU control line=001, OR
	3'b011: sum = a<<b; //ALU control for question 24 
	default: sum=31'bx;	
	endcase
zout=~(|sum);
nout = sum[31];
end
endmodule

// 000000 00001 00010 00011 00000 000100 Shift register 1 by the value in register 2, and store in register 3
// 00221804