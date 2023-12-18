// `include "config.v"

// ZERO 32
`define		ZERO_WORD		32'd0
`define     TRUE            1'b1
`define     FALSE           1'b0

//           inst            opcode        w_to_rd   reg_w_data_sel    mem_acces   mem_write
// R
`define		type_R			7'b0110011  //    1            0            
// I
`define		type_I			7'b0010011  //    1            0
`define		jalr			7'b1100111  //    1            0
`define		load_group		7'b0000011  //    1            1
`define     env_group       7'b1110011  //    0            0
// S    
`define		type_S			7'b0100011  //    0            0
// B
`define		type_B			7'b1100011  //    0            0
// U
`define		lui				7'b0110111  //    1            0
`define		auipc			7'b0010111  //    1            0
// J
`define		type_J			7'b1101111  //    1            0
`define		jal		     	7'b1101111
//  define  jal is completely same as type_J

// alu_ctrl
`define 	ADD  			4'b0000
`define 	SUB  			4'b0001

`define 	OR    			4'b0010			
`define 	AND   			4'b0011
`define 	XOR   			4'b0100

`define 	SRL  			4'b0101
`define 	SLL   			4'b0110
`define 	SRA  			4'b0111

`define 	SLT  		    4'b1001
`define 	SLTU 			4'b1000
 			
  			
  			
 			
