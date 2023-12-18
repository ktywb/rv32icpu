`include "defines.v"

module Regfile (
    // in
    input   [0 :0]  clk,
    //input   [0: 0]  rst_n,
    input   [0: 0]  w_en,
    input   [4 :0]  rs1,
	input   [4 :0]  rs2,
	input   [4 :0]  rd,
	input   [31:0]  rd_data,
	
    // out
	output  [31:0]  dataA,
	output  [31:0]  dataB
);
    reg [31:0] regs [31:0] ;

    always@( posedge clk ) begin
		if( w_en & ( rd != 0 ) )
			regs[ rd ] <= rd_data;	
	end

    assign dataA = ( rs1 == 5'd0 ) ? `ZERO_WORD : regs[rs1] ;
    assign dataB = ( rs2 == 5'd0 ) ? `ZERO_WORD : regs[rs2] ;
    
endmodule