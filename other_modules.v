//=================================//
// MUX  2-1                        //
//=================================//
module Mux (
    // in
    input  [0 :0] select,
    input  [31:0] dataA,        // 0
    input  [31:0] dataB,        // 1

    // out
    output reg [31:0] dataC
);
    reg [31:0] temp;
    always @(*) begin
        //temp <= ( {32{!select}} & dataA ) | ( {32{ select}} & dataB );
        temp = (select == 1'b1) ? dataB : dataA;
        dataC = temp;
    end
endmodule   // endmoudle Mux

//=================================//
// MUX  3-1                        //
//=================================//
module Mux31 (
    // in
    input  [1 :0] select,
    input  [31:0] dataA,        // 00
    input  [31:0] dataB,        // 01
    input  [31:0] dataC,        // 1x

    // out
    output reg [31:0] dataD
);
    reg [31:0] temp;
    always @(*) begin
        //temp <= (select == 1'b1) ? dataB : dataA;
        temp = ( {32{ select[1]}} & dataC ) 
              | ( {32{~select[1]}} & ( ({32{ select[0]}} & dataB) 
                                     | ({32{~select[0]}} & dataA) 
                                     )
               );
        dataD = temp;
    end
endmodule   // endmoudle Mux

//=================================//
// ADD                             //
//=================================//
module Add (
    // in
    input  [31:0] dataA,
    input  [31:0] dataB,
    input  [0 :0] cin,

    // out
    output reg [0 :0] cout,
    output reg [31:0] dataC
);
    //assign {cout,dataC} = cin+ dataA+ dataB ;
    always @(*) begin
        {cout,dataC} = cin+ dataA+ dataB ;
    end
endmodule   // endmodule Add

/*- B_J_Jr_judge -*/
//=================================//
// Single cycle B_J_Jr_judge       //
//=================================//
module Judger(
    // in
    input  [9 :0 ] jbs_flag_cache,
    input  [0 :0 ] compare_res,
    input  [0 :0 ] alu_zero,

    // out
    output reg [0 :0 ] judge_a,
    output reg [0 :0 ] judge_b,
    output reg [0 :0 ] judge_c,
    output reg [0 :0 ] judge_d,
    output reg [0 :0 ] judge_e
);

    wire wa,wb,wc,wd,we;

/* jbs_flag_cache:  [beq ], [bne ], [blt ], [bge ], [bltu], [bgeu], [jal ], [jalr], [lui ], [auipc]
                       9       8       7       6       5       4       3       2       1       0        */
    wire [0 :0 ] nF, bF, jF, jrF, luiF, auipcF;
    assign bF  =  ( jbs_flag_cache[9] && ( alu_zero   ) )       // beq  : sub  -> alu_zero  =  1
                | ( jbs_flag_cache[8] && (!alu_zero   ) )       // bne  : sub  -> alu_zero  =  0
                | ( jbs_flag_cache[7] && ( compare_res) )       // blt  : slt  -> compare_res= 1 ( a-b <  0 )
                | ( jbs_flag_cache[6] && (!compare_res) )       // bge  : slt  -> compare_res= 0 ( a-b >= 0 )
                | ( jbs_flag_cache[5] && ( compare_res) )       // bltu : sltu -> compare_res= 1 ( a-b <  0 )
                | ( jbs_flag_cache[4] && (!compare_res) );      // bgeu : sltu -> compare_res= 0 ( a-b >= 0 )
    assign jF     = jbs_flag_cache[3];
    assign jrF    = jbs_flag_cache[2];
    assign luiF   = jbs_flag_cache[1];
    assign auipcF = jbs_flag_cache[0];
    //assign nF     = ~( |jbs_flag_cache ) | ~( bF );
    assign nF     = ~(
        ( |jbs_flag_cache[3:0] ) | bF
    );

    assign wa = jrF;
    assign wb = bF | jF | jrF;
    assign wc = ~( nF | bF );
    assign wd = luiF;
    assign we = luiF | auipcF;

    always @(*) begin
        judge_a = wa ;
        judge_b = wb ;
        judge_c = wc ;
        judge_d = wd ;
        judge_e = we ;
    end
endmodule   // endmodule Judger

//=================================//
// Instruction Memory Data Conv    //
//=================================//
module I_mem (
    input clk,
    // in
    input  [31:0 ] pc_out,

    // out
    output [31:0 ] inst,

    // interface
    input  [0 :0 ] ACKI_n,
    input  [31:0 ] IDT,
    input  [31:0 ] IDT2,

    output [31:0 ] IAD,
    output [0 :0 ] IACK_n,
    output reg [0 :0 ] is_jjru,          // judge if jjr
    output reg [0 :0 ] is_j,
    output reg [0 :0 ] is_jr,
    output reg [0 :0 ] is_b
);
    wire [0 :0 ] IACK_n_wire;
    wire [0 :0 ] type_b, type_jjr, type_u, typr_jr;
    wire [6 :0 ] opcode;

    wire temp, inst_temp;
    assign inst_temp = ( ACKI_n == 1'b0 ) ? IDT : 32'b0;
    
    assign inst = ( ACKI_n == 1'b0 ) ? IDT : 32'b0;
    assign IAD = pc_out;
    assign opcode = inst[6 :0 ];
    assign IACK_n = ( pc_out != 32'b0 ) ? 1'b0 : 1'b1;

    assign type_b = (~opcode[2]) & (~opcode[4]) & opcode[6];
    assign type_jjr = (~opcode[4]) & opcode[2] & opcode[6];
    assign type_jr  = type_jjr & (~opcode[3]);
    assign type_j   = type_jjr & ( opcode[3]);
    assign type_u = (~opcode[5]) & opcode[2] & opcode[4];
    // assign temp = ( (type_jjr | type_u) === 1'b1);
    // assign temp = ( (type_jjr) === 1'b1);
    assign temp = ( (type_jjr) == 1'b1);

    // always @(negedge clk, posedge temp, negedge temp) begin        // opcode
    always @(*) begin        // opcode
        is_jjru = temp;  //  ? 1'b1 : 1'b0
        is_j    = type_j;
        is_jr   = type_jr;   //  ? 1'b1 : 1'b0
        is_b    = type_b;
    end
endmodule   // endmodule I_mem

//=================================//
// Data Memory Data Conv           //
//=================================//
module D_mem(
    // in
    input clk,
    input [0 :0 ] mem_read_ctrl,
    input [0 :0 ] mem_write_ctrl,
    input [2 :0 ] wr_width,
    input [31:0 ] address,
    input [31:0 ] w_data,
    
    // out 
    output [31:0 ] r_data,

    // interface
    input  [0 :0 ] ACKD_n,
    output [1 :0 ] SIZE,        // * width
    output [0 :0 ] MREQ,        // * access flag: if read or write then MREQ=1, else MREQ=0
    output [31:0 ] DAD,         // data address
    output [0 :0 ] WRITE,       // * write flag : if write rhen WRITE=1, else WRITE=0
    inout  [31:0 ] DDT          // read or write data
);
    /* wdith of load or store data
       000-> lb,sb  read or write 1  byte，extens 8th  bit to 32 bit when read
       100-> lbu    read 1  byte，unsigned extens to 32 bit when read

       001-> lh,sh  read or write 2  byte，extens 16th bit to 32 bit when read
       101-> lhu    read 2  byte，unsigned extens to 32 bit when read     

       010-> lw ,sw read or write 32 bit  

        1x-> byte
        01-> half
        00-> word  
    */
    reg [31: 0] DDT_r;

    assign SIZE = { !( wr_width[1] | wr_width[0] ) , ( wr_width[0] ) };

    assign MREQ = ( mem_read_ctrl | mem_write_ctrl );
    assign WRITE= mem_write_ctrl;
    assign DAD = address;
    
    assign DDT = (mem_write_ctrl ) ? w_data : 32'bz;    // if read : DDT <= DDT_reg
                                                       // if write：DDT <= z to get from outside
    assign r_data = (mem_read_ctrl & ~(ACKD_n) ) ? DDT : 32'bz;
endmodule   // endmodule D_mem

//=================================//
// Pipeline J, Jr,Type U judger    //
//=================================//
module JJrUJudger (
    // in
    input  [3 :0 ] jjru_flag_cache,
    input  [0 :0 ] bneqF,

    // out
    output reg [0 :0 ] judge_a,
    output reg [0 :0 ] judge_b1,
    output reg [0 :0 ] judge_d,
    output reg [0 :0 ] judge_e,

    output reg [0 :0 ] jjruF
);
    wire [0 :0 ] wa, wb1, wd, we;
    wire [0 :0 ] jF, jrF, luiF, auipcF;
/*                  [beq ], [bne ], [blt ], [bge ], [bltu], [bgeu], [jal ], [jalr], [lui ], [auipc]
   jbs_flag_cache:     9       8       7       6       5       4       3       2       1       0       
   jjru_flag_cache:    5       4                                       3       2       1       0
 */
    assign jF     = jjru_flag_cache[3];
    assign jrF    = jjru_flag_cache[2];
    assign luiF   = jjru_flag_cache[1];
    assign auipcF = jjru_flag_cache[0];

    assign wa  = jrF;
    assign wb1 = jF | jrF | bneqF;
    //assign wb1 = jrF;
    assign wd  = luiF;
    assign we  = luiF | auipcF;

    always @(*) begin
        judge_a  = wa ;
        judge_b1 = wb1 ;
        judge_d  = wd ;
        judge_e  = we ;   
        jjruF    = (|jjru_flag_cache);     
    end
endmodule   // endmodule JJrU_Judger

//=================================//
// Pipeline Branch judger          //
//=================================//
module BranchJudger (
    // in
    input  [0 :0 ] jjruF,
    input  [31:0 ] typeb_pc_i,
    input  [5 :0 ] b_flag_cache,
    input  [0 :0 ] compare_res,
    input  [0 :0 ] alu_zero,
    input  [0 :0 ] load_bneq_sig,

    // out
    output reg [31:0 ] typeb_pc_o,
    output reg [0 :0 ] judge_b2,
    output reg [0 :0 ] judge_c
);
    wire [0 :0 ] wb2, wc;
    wire [0 :0 ] nF, bF , jF, jrF;
/*                  [beq ], [bne ], [blt ], [bge ], [bltu], [bgeu], [jal ], [jalr], [lui ], [auipc]
   jbs_flag_cache:     9       8       7       6       5       4       3       2       1       0        
   b_flag_cache  :     5       4       3       2       1       0
*/
    assign bF  =  
                  ( b_flag_cache[5] && ( alu_zero   ) )       // beq  : sub  -> alu_zero  =  1
                | ( b_flag_cache[4] && (!alu_zero   ) ) |      // bne  : sub  -> alu_zero  =  0
                 ( b_flag_cache[3] && ( compare_res) )       // blt  : slt  -> compare_res= 1 ( a-b <  0 )
                | ( b_flag_cache[2] && (!compare_res) )       // bge  : slt  -> compare_res= 0 ( a-b >= 0 )
                | ( b_flag_cache[1] && ( compare_res) )       // bltu : sltu -> compare_res= 1 ( a-b <  0 )
                | ( b_flag_cache[0] && (!compare_res) );      // bgeu : sltu -> compare_res= 0 ( a-b >= 0 )  
    //assign nF  = ~( ( |jbs_flag_cache[3:0] ) | bF ); 
    assign nF = ~( jjruF | bF ) ;

    assign wb2 = bF;
    assign wc  = ~( nF | bF );

    // out
    always @(*) begin
        typeb_pc_o = typeb_pc_i;
        judge_b2 = wb2;
        judge_c  = wc;
    end   
endmodule   // endmodule Branch_Judger

//=================================//
// Register Condition Resetter     //
//=================================//
module RegCondRster (
    // in
    input  [0 :0 ] clk,    
    input  [0 :0 ] rst_n_i,
    input  [0 :0 ] ctrl_sig,
    input  [1 :0 ] times,       // 00->0    11->3

    // out
    output reg [0 :0 ] rst_n_o
);
    reg  [1 :0 ] times_r;

    always @(posedge clk) begin
        times_r <= (ctrl_sig & (~(|times_r))) ? times : ({ ( times_r[1] & times_r[0] ), ( times_r[1] & (~times_r[0]) ) });
        rst_n_o <= rst_n_i & (~(|times_r));
    end

    always @(rst_n_i == 1'b0) begin
        times_r = 2'b00;
        rst_n_o = rst_n_i ;
    end
endmodule   // endmodule RegCondRster

//=================================//
// Forward Controller              //
//=================================//
module FwdCtrler (
        input  [4 :0 ] id2ex_rs1,           // next     inst    rs1
        input  [4 :0 ] id2ex_rs2,           // next     inst    rs2
        input  [4 :0 ] ex2mem_rd,           // current  inst    rd
        input  [4 :0 ] mem2wb_rd,           // previous inst    rd

        input  [0 :0 ] ex2mem_reg_w_ctrl,
        input  [0 :0 ] mem2wb_reg_w_ctrl,

        input  [0 :0 ] id2ex_mem_write_ctrl,
        input  [0 :0 ] ex2mem_mem_read_ctrl,

        input  [4 :0 ] id2ex_rd,
        input  [0 :0 ] id2ex_mem_read_ctrl,
        input  [0 :0 ] id2ex_reg_w_ctrl,
        input  [4 :0 ] rs1,
        input  [4 :0 ] rs2,
        input  [0 :0 ] mem_write_ctrl,

        input  [0 :0 ] is_jr,
        input  [1 :0 ] bneqF,

        output [1 :0 ] fcA,         // 00 -> ID2EX  ( self data )   
        output [1 :0 ] fcB,         // 01 ->  WB    ( Dmem data )
        output [0 :0 ] fcC,         // 10 -> EX2MEM (  ALU res  )
        output [0 :0 ] fcD,
        output [1 :0 ] fcE,
        output [1 :0 ] fcF,

        output [0 :0 ] load_bneq_sig
);     
    wire [0 :0 ] is_bneq;
    assign is_bneq = (|bneqF);

    wire f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12;

    assign fcC = ( ~ex2mem_reg_w_ctrl ) && ( ex2mem_rd!=5'd0 ) && ( ex2mem_rd!=id2ex_rs1 ) && ( ex2mem_rd==id2ex_rs2 ) && ( id2ex_mem_write_ctrl );

    // assign fcD   = (  ( ( id2ex_mem_read_ctrl & (~id2ex_reg_w_ctrl) & (id2ex_rd!=5'd0) )     //load
	// 				     & (!mem_write_ctrl)                                               // not store
	// 				     & ((id2ex_rd ==rs1) | (id2ex_rd ==rs2) ) )
	// 			    | ( ( id2ex_mem_read_ctrl & (~id2ex_reg_w_ctrl) & (id2ex_rd!=5'd0) )     //load
    //                      & (mem_write_ctrl)                                                // store
    //                      & (id2ex_rd ==rs1))) 
    //              | ( ( is_jr ) & (ex2mem_mem_read_ctrl) && ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && (ex2mem_rd==rs1))//;
    //              | f1
    //              | f2;

    assign f3 = ( ( id2ex_mem_read_ctrl & (~id2ex_reg_w_ctrl) & (id2ex_rd!=5'd0) )     //load
					     & (!mem_write_ctrl)                                               // not store
					     & ((id2ex_rd ==rs1) | (id2ex_rd ==rs2) ) );
    assign f4 = ( ( id2ex_mem_read_ctrl & (~id2ex_reg_w_ctrl) & (id2ex_rd!=5'd0) )     //load
                         & (mem_write_ctrl)                                                // store
                         & (id2ex_rd ==rs1));
    assign f5 = ( ( is_jr ) & (ex2mem_mem_read_ctrl) && ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && (ex2mem_rd==rs1));

    assign fcD   = (  f3
				    | f4) 
                 | f5//;
                 | f1
                 | f2;                 

    //assign f13 = ( ( is_jr | is_bneq ) & (ex2mem_mem_read_ctrl) && ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && ((ex2mem_rd==rs1)|(ex2mem_rd==rs2)) );
                    // need stall for EqJduger
    //assign f14 = f13 | fcD; 

    assign f1 = (~load_bneq_sig) & (is_bneq) 
              & (ex2mem_mem_read_ctrl) & ( ~ex2mem_reg_w_ctrl ) & (ex2mem_rd!=5'd0) 
              & ((ex2mem_rd==rs1) | (ex2mem_rd==rs2));

    assign f2 = (~load_bneq_sig) & (is_bneq) 
              & ( ~id2ex_reg_w_ctrl ) & (id2ex_rd!=5'd0) 
              & ((id2ex_rd==rs1) | (id2ex_rd==rs2));

    assign load_bneq_sig = ( is_bneq ) & (id2ex_mem_read_ctrl) & (~id2ex_reg_w_ctrl) & (id2ex_rd!=5'd0) & ((id2ex_rd==rs1)|(id2ex_rd==rs2));

    assign fcA[1] = ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && (ex2mem_rd==id2ex_rs1);
    assign fcA[0] = ( ~mem2wb_reg_w_ctrl ) && (mem2wb_rd!=5'd0) && (mem2wb_rd==id2ex_rs1);

    assign fcB[1] = ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && (ex2mem_rd==id2ex_rs2);
    assign fcB[0] = ( ~mem2wb_reg_w_ctrl ) && (mem2wb_rd!=5'd0) && (mem2wb_rd==id2ex_rs2);

    assign fcE[1] = is_bneq && ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && (ex2mem_rd==rs1);    // is_bneq && 
    assign fcE[0] = is_bneq && ( ~mem2wb_reg_w_ctrl ) && (mem2wb_rd!=5'd0) && (mem2wb_rd==rs1);    // is_bneq && 

    assign fcF[1] = is_bneq && ( ~ex2mem_reg_w_ctrl ) && (ex2mem_rd!=5'd0) && (ex2mem_rd==rs2);    // is_bneq && 
    assign fcF[0] = is_bneq && ( ~mem2wb_reg_w_ctrl ) && (mem2wb_rd!=5'd0) && (mem2wb_rd==rs2);    // is_bneq && 

endmodule   // endmodule FwdCtrler

//=================================//
// Eq Tpye Branch Jduger           //
//=================================//
module EqJduger (
    input [1 :0 ] bneqF,
    input [31:0 ] dataA,
    input [31:0 ] dataB,

    input [0 :0 ] load_bneq_sig,

    output reg [0:0] bneq,
    output reg [1:0] bneqF_o
);
    //  [beq ], [bne ]
    //    1       0
    wire [0 :0 ] is_bneq, is_equal, result;
    assign is_bneq = (|bneqF);
    assign is_equal = ~(|( dataA ^ dataB )) & is_bneq; // if equal , then =1
    assign result = bneqF[1] & ( is_equal)
                  | bneqF[0] & (~is_equal);

    always @(*) begin
        bneq <= result;
        bneqF_o <= {2{ load_bneq_sig}} & bneqF
                 | {2{~load_bneq_sig}} & 2'b0;
    end
    
endmodule   // endmodule EqJduge

//=================================//
// JBHandler                       //
//=================================//
module JBHandler (
    input [31:0 ] inst,

    input [0 :0 ] is_j,
    input [0 :0 ] is_jr,
    input [0 :0 ] is_b,
    inout [0 :0 ] b2,

    output reg [31:0 ] imm_exten,
    output reg [0 :0 ] jb
);
    wire [31:0 ] imm_exten_J,imm_exten_B, branch_dist;
    wire b;
    reg [0 :0 ] sa, sb;

    assign imm_exten_J = { {12{inst[31]}} , inst[19:12] , inst[20] , inst[30:21] , 1'b0 };
    assign imm_exten_B = { {20{inst[31]}} , inst[7] , inst[30:25] , inst[11:8] , 1'b0 };
    assign b = sa; 
    

    // assign branch_dist = 
    always @(*) begin
        jb = is_j | b;
        imm_exten = {32{is_j}} & imm_exten_J
                   | {32{  b }} & imm_exten_B;
    end
    
endmodule
