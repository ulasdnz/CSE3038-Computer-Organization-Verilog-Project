module new_component(aluResult,z,n);//ALU operation according to the ALU control line values
input [31:0] aluResult;
output z,n;
assign z = ~(|aluResult);
assign n = aluResult[31]; 
endmodule
