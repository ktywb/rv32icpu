`include "includes.v"

//---------------------------
// test function 
//---------------------------
module PplDatapathTest (
    // in
    input  [0 :0 ] clk,
    input  [0 :0 ] rst_n,

    // i_mem io
    output [31:0 ] pc_out_o,
    input  [31:0 ] inst_i,
    input  [0 :0 ] is_jjru,
    input  [0 :0 ] is_j,
    input  [0 :0 ] is_jr,
    input  [0 :0 ] is_b,
    
    // d_mem io
    input  [31:0 ] mem_read_data_i,
    output [31:0 ] mem_address_o,
    output [2 :0 ] wr_width_o,
    output [0 :0 ] mem_read_ctrl_o,
    output [0 :0 ] mem_write_ctrl_o,
    output [31:0 ] mem_write_data_o
);
// WIRES
    wire [31:0 ] pc_out, pc_out_;                                       // PC Reg

    wire [31:0 ] inst;                                                  // Imem Conv

    wire [0 :0 ] rst_n_ifid;                                            // RegCondRster for jal & jalr

    wire [31:0 ] pc_out_ifid, inst_ifid;                                // IF2ID
    wire [0 :0 ] is_jjru_ifid, fcD_ifid, b2_ifid;

    wire [9 :0 ] jbs_flag_cache;                                        // Decoder
    wire [4 :0 ] rs1, rs2, rd;
    wire [31:0 ] imm_exten;
    wire [3 :0 ] alu_ctrl;
    wire [2 :0 ] wr_width;
    wire [0 :0 ] alu_dataB_sel, reg_w_ctrl, reg_w_data_sel,   
                 mem_read_ctrl, mem_write_ctrl; 

    wire [31:0 ] reg_dataA, reg_dataB;                                  // Reg

    wire [31:0 ] reg_dataA_muxed;                                       // RegDataA Mux31

    wire [31:0 ] reg_dataB_muxed;                                       // RegDataB Mux31

    wire [0 :0 ] bneq;                                                  // EqJduger

    wire [0 :0 ] judge_a, judge_b1, judge_d, judge_e, jjruF;            // JJrUJudger

    wire [31:0 ] imm_jb;                                                // jbhandler
    wire [0 :0 ] jb;

    wire [31:0 ] pc_out_slect;                                          // jjru MUX
    wire [31:0 ] pc_reg_data;                                           // pc reg MUX
    wire [31:0 ] typeu_1_wire;                                          // Type U 1 MUX
    wire [31:0 ] pc_plus4;                                              // PC 4 Add
    wire [31:0 ] pcreg_plusimm;                                         // Pc or Reg Imm Add
    wire [31:0 ] pc_temp;                                               // Plus 4 or Plus Imm
    wire [31:0 ] bneq_sel;                                              // bne beq sel
    wire [31:0 ] typeu_2_wire;                                          // Type U 2 MUX

    wire [0 :0 ] rst_n_idex;                                            // RegCondRster for branch

    wire [31:0 ] typeb_pc_idex, pc_wb_idex, regalu_dataA_idex,          // ID2EX
                 reg_dataB_idex, imm_exten_idex;
    wire [5 :0 ] b_flag_cache_idex;
    wire [2 :0 ] wr_width_idex;
    wire [4 :0 ] rd_idex, rs1_idex, rs2_idex;
    wire [0 :0 ] jjruF_idex, reg_w_ctrl_idex, reg_w_data_sel_idex, 
                 mem_read_ctrl_idex, mem_write_ctrl_idex, alu_dataB_sel_idex,
                 load_bneq_sig_idex;
    wire [3 :0 ] alu_ctrl_idex;
    wire [1 :0 ] bneqFlag_idex;

    wire [31:0 ] data_a_muxed;                                          // DataA Mux31

    wire [31:0 ] data_b_muxed;                                          // DataB Mux31

    wire [31:0 ] mux_ALU_dataB;                                         // Reg Imm Mux

    wire [31:0 ] alu_dataC;                                             // ALU
    wire [0 :0 ] compare_res;
    wire [0 :0 ] alu_zero;

    wire [31:0 ] computed_data;                                         // data_pc_mux

    wire [1 :0 ] fcA, fcB, fcE, fcF;                                              // Forward Controller 
    wire [0 :0 ] fcC, fcD;

    wire [0 :0 ] judge_b2, judge_c;                                     // BranchJudger
    wire [31:0 ] typeb_pc;

    wire [31:0 ] pc_gen;                                                // PC Gen Mux

    wire [31:0 ] pc_wb_exmem, alu_dataCaddress_exmem, w_data_exmem;     // EX2MEM
    wire [2 :0 ] wr_width_exmem;
    wire [4 :0 ] rd_exmem;
    wire [0 :0 ] c_o_exmem, reg_w_ctrl_exmem, reg_w_data_sel_exmem, 
                 mem_read_ctrl_exmem, mem_write_ctrl_exmem, fcC_exmem;

    wire [31:0 ] mem_write_data_muxed;                                  // Dmem_w_data_mux

    wire [31:0 ] data_a_premuxed;                                       // alu_dmem_mux
    
    wire [31:0 ] mem_read_data;                                         // Dmem Conv

    wire [31:0 ] pc_wb_memwb, r_data_memwb, alu_dataC_memwb;            // MEM2WB
    wire [4 :0 ] rd_memwb;
    wire [0 :0 ] c_o_memwb, reg_w_ctrl_memwb, reg_w_data_sel_memwb;

    wire [31:0 ] wb_gen;                                                // Write Back

    wire [0 :0 ] load_bneq_sig; 
    wire [1 :0 ] bneqFlag;
    wire csig;
// WIRES

// test wire
    wire [31:0 ] inst_idex,inst_exmem,inst_memwb;
// test wire

// PC Reg
    //wire [31:0 ] pc_in; 
    // Pc_reg pc_reg(
    PcRegWithStall pc_reg(
        .clk( clk ),
        .rst_n( rst_n ),
        .pc_in( pc_gen ),      .pc_out( pc_out ),       .pc_out_( pc_out_ ),
        .fcD( fcD )
    );
// PC Reg

// Imem Conv
    assign pc_out_o = pc_out;
    assign inst = inst_i;
    // is_jjru
// Imem Conv

// RegCondRster for jal & jalr
    RegCondRster rster1(
        .clk( clk ),
        .rst_n_i( rst_n ),
        .ctrl_sig( (judge_b1) & (~b2_ifid) & (~fcD)  ), //  
        .times( { 1'b0, (~fcD) } ), // { 1'b0, (~fcD_ifid) } 2'b01
        .rst_n_o( rst_n_ifid )
    );
// RegCondRster for jal & jalr

// IF2ID
    // IF2ID if2id(
    IF2IDWithStall if2id(
        .clk( clk ),
        .rst_n( rst_n_ifid ),
        .pc_out_i( pc_out_ ),                       .pc_out_o( pc_out_ifid ),
        .inst_i( inst ),                            .inst_o( inst_ifid ),
        .is_jjru_i( is_jjru ),                      .is_jjru_o( is_jjru_ifid ),
        // .is_jjru_i( is_jr ),                        .is_jjru_o( is_jjru_ifid ),
        .fcD_i( fcD ),                              .fcD_o( fcD_ifid ),
        .b2_i( judge_b2 ),                          .b2_o( b2_ifid )
    );
// IF2ID

// Decoder
    Decoder decoder(
        .inst( inst_ifid ),
        .rs1( rs1 ),
        .rs2( rs2 ),
        .rd( rd ),
        .imm_exten( imm_exten ),
        .jbs_flag_cache( jbs_flag_cache ),
        .wr_width( wr_width ),                   
        .alu_ctrl( alu_ctrl ),              
        .alu_dataB_sel( alu_dataB_sel ),  
        .reg_w_ctrl( reg_w_ctrl ),
        .reg_w_data_sel( reg_w_data_sel ),
        .mem_read_ctrl( mem_read_ctrl ),
        .mem_write_ctrl( mem_write_ctrl ),
        .alu_op(),.pc_add_sel()
    );
// Decoder

//  Reg
    rf32x32 rf(
        .clk( clk ),
        .reset( rst_n ),               
        .wr_n( reg_w_ctrl_memwb ),
		.rd1_addr( rs1 ), 
        .rd2_addr( rs2 ), 
        .wr_addr( rd_memwb ), // rd_memwb
		.data_in( wb_gen ),
		.data1_out( reg_dataA ), 
        .data2_out( reg_dataB )
    );
//  Reg

// RegDataA Mux31
    Mux31 reg_data_a_mux31(
        .select( fcE ),
        .dataA( reg_dataA ),
        .dataB( wb_gen ),
        .dataC( alu_dataCaddress_exmem ),
        .dataD( reg_dataA_muxed )
    );
// RegDataA Mux31

// RegDataB Mux31
    Mux31 reg_data_b_mux31(
        .select( fcF ),
        .dataA( reg_dataB ),
        .dataB( wb_gen ),
        .dataC( alu_dataCaddress_exmem ),
        .dataD( reg_dataB_muxed )
    );
// RegDataB Mux31

// EqJduger

    EqJduger eq_judger(
        .bneqF( jbs_flag_cache[9:8] & {2{~fcD}} ),
        .dataA( reg_dataA_muxed ),
        .dataB( reg_dataB_muxed ),
        .load_bneq_sig( load_bneq_sig_idex ),
        .bneq( bneq ),
        .bneqF_o( bneqFlag )
    );
// EqJduger

// JJrUJudger
    JJrUJudger jjru_judger(
        .jjru_flag_cache( jbs_flag_cache[3:0] ),
        .judge_a( judge_a ),
        .judge_b1( judge_b1 ),
        .judge_d( judge_d ),
        .judge_e( judge_e ),
        .jjruF( jjruF ),
        .bneqF( bneq & (~load_bneq_sig_idex) )
    );
// JJrUJudger

// jbhandler
    JBHandler jbhandler(
        .inst( inst ),
        .is_j( is_j & (~clk) ),
        .is_jr( is_jr ),
        .is_b( is_b ),
        .b2(judge_b2),
        .imm_exten( imm_jb ),
        .jb( jb )
    );
// jbhandler

// jjru MUX
    Mux jjru_mux(
        .select( (is_jjru_ifid & (~fcD)) & (~b2_ifid)), // (is_jjru_ifid & (~fcD)) & (~b2_ifid)
        .dataA( pc_out ),
        .dataB( pc_out_ifid ),
        .dataC( pc_out_slect )
    );
// jjru MUX
    
// pc reg MUX
    Mux pc_reg_mux(
        .select( judge_a ),
        .dataA( pc_out_ifid ),
        .dataB( reg_dataA ),
        .dataC( pc_reg_data )
    );
// pc reg MUX

// Type U 1 MUX
    Mux typeu_1_mux(
        .select( judge_d ),
        .dataA( pc_reg_data ),
        .dataB( 32'b0 ),
        .dataC( typeu_1_wire )
    );
// Type U 1 MUX

// PC 4 Add
    Add pc_4_add (
        .dataA( pc_out_slect ),
        .dataB( 32'd4 ),        // 32'd4
        .cin( 1'd0 ),
        .cout(),
        .dataC( pc_plus4 )
    );
// PC 4 Add

// Pc or Reg Imm Add
    Add pcoreg_imm_add (
        .dataA( typeu_1_wire ),
        .dataB( imm_exten ),           // imm << 1
        .cin( 1'd0 ),
        .cout(),
        .dataC( pcreg_plusimm )
    );
// Pc or Reg Imm Add

// Plus 4 or Plus Imm
    Mux plus4_plusimm_mux(
        .select( (judge_b1 & (~fcD)) & (~b2_ifid) ),
        .dataA( pc_plus4 ),
        .dataB( pcreg_plusimm ),
        .dataC( pc_temp )
    );
// Plus 4 or Plus Imm

// // bne beq sel
//     Mux tempMux(
//         .select( 1'b0 ),  // bneq 1'b0
//         .dataA( pc_temp ),
//         .dataB( pcreg_plusimm ),
//         .dataC( bneq_sel )
//     );
// // bne beq sel

//  Type U 2 MUX
    Mux typeu_2_mux(
        .select( judge_e ),
        .dataA( pc_plus4 ),
        .dataB( pcreg_plusimm ),           
        .dataC( typeu_2_wire )
    );
//  Type U 2 MUX

// RegCondRster for branch

    assign csig = judge_b2 | fcD;
    RegCondRster rster2(
        .clk( clk ),
        .rst_n_i( rst_n ),
        .ctrl_sig( csig ),
        .times( { judge_b2, fcD } ), // 2'b10
        .rst_n_o( rst_n_idex )
    );
// RegCondRster for branch

// ID2EX
    ID2EX id2ex(
        .inst_i( inst_ifid ),                            .inst_o( inst_idex ),
        .clk( clk ),
        // .rst_n( rst_n_idex ),
        .rst_n( rst_n_idex ),
        .typeb_pc_i( pcreg_plusimm ),               .typeb_pc_o( typeb_pc_idex ),
        .pc_wb_i( typeu_2_wire ),                   .pc_wb_o( pc_wb_idex ),
        .b_flag_cache_i( jbs_flag_cache[9:4] ),     .b_flag_cache_o( b_flag_cache_idex ),
        .wr_width_i( wr_width ),                    .wr_width_o( wr_width_idex ),
        .reg_dataA_i( reg_dataA ),                  .regalu_dataA_o( regalu_dataA_idex ),
        .reg_dataB_i( reg_dataB ),                  .reg_dataB_o( reg_dataB_idex ),
        .imm_exten_i( imm_exten ),                  .imm_exten_o( imm_exten_idex ),
        .rd_i( rd ),                                .rd_o( rd_idex ),
        .rs1_i( rs1 ),                              .rs1_o( rs1_idex ),
        .rs2_i( rs2 ),                              .rs2_o( rs2_idex ),
        .jjruF_i( jjruF ),                          .jjruF_o( jjruF_idex ),
        .reg_w_ctrl_i( reg_w_ctrl ),                .reg_w_ctrl_o( reg_w_ctrl_idex ),
        .reg_w_data_sel_i( reg_w_data_sel ),        .reg_w_data_sel_o( reg_w_data_sel_idex ),
        .mem_read_ctrl_i( mem_read_ctrl ),          .mem_read_ctrl_o( mem_read_ctrl_idex ),
        .mem_write_ctrl_i( mem_write_ctrl ),        .mem_write_ctrl_o( mem_write_ctrl_idex ),
        .alu_ctrl_i( alu_ctrl ),                    .alu_ctrl_o( alu_ctrl_idex ),
        .alu_dataB_sel_i( alu_dataB_sel ),          .alu_dataB_sel_o( alu_dataB_sel_idex ),
        .load_bneq_sig_i( load_bneq_sig ),          .load_bneq_sig_o( load_bneq_sig_idex ),
        .bneqFlag_i( bneqFlag ),          .bneqFlag_o( bneqFlag_idex )
        
    );
// ID2EX

// DataA Mux31
    Mux31 data_a_mux31(
        .select( fcA ),
        // .select( 2'b00 ),
        .dataA( regalu_dataA_idex ),    // 00
        .dataB( wb_gen ),               // 01
        .dataC( alu_dataCaddress_exmem ),         // 10
        .dataD( data_a_muxed )
    );
// DataA Mux31

// DataB Mux31
    Mux31 data_b_mux31(
        .select( fcB ),
        // .select( 2'b00 ),
        .dataA( reg_dataB_idex ),
        .dataB( wb_gen ),
        .dataC( alu_dataCaddress_exmem ),
        .dataD( data_b_muxed )
    );
// DataB Mux31


// Reg Imm Mux
    Mux reg_imm_mux(
        .select( alu_dataB_sel_idex ),
        .dataA( data_b_muxed ),
        .dataB( imm_exten_idex ),
        .dataC( mux_ALU_dataB )
    );
// Reg Imm Mux

// ALU
    Ex_alu alu(     //.clk(clk),
        .rst_n( rst_n ),
        .alu_ctrl( alu_ctrl_idex ),
        .alu_dataA( data_a_muxed ),
        .alu_dataB( mux_ALU_dataB ),
        .alu_dataC( alu_dataC ),
        .alu_zero( alu_zero ),
        .compare_res( compare_res ),
        .alu_overflow()
    );
// ALU

// data_pc_mux
    Mux data_pc_mux(
        .select( judge_c ),
        .dataA( alu_dataC ),
        .dataB( pc_wb_idex ),
        .dataC( computed_data )
    );
// data_pc_mux

// Forward Controller  

    FwdCtrler fwd_ctrler(
        .id2ex_rs1( rs1_idex ),
        .id2ex_rs2( rs2_idex ),
        .ex2mem_rd( rd_exmem ),
        .mem2wb_rd( rd_memwb ),
        .ex2mem_reg_w_ctrl( reg_w_ctrl_exmem ),
        .mem2wb_reg_w_ctrl( reg_w_ctrl_memwb ),
        .id2ex_mem_write_ctrl( mem_write_ctrl_idex ),
        .ex2mem_mem_read_ctrl( mem_read_ctrl_exmem ),
        .id2ex_rd( rd_idex ),
        .id2ex_mem_read_ctrl( mem_read_ctrl_idex ),
        .id2ex_reg_w_ctrl( reg_w_ctrl_idex ),
        .rs1( rs1 ),
        .rs2( rs2 ),
        .mem_write_ctrl( mem_write_ctrl ),
        .is_jr( jbs_flag_cache[2] ),
        .bneqF( jbs_flag_cache[9:8]), //  jbs_flag_cache[9:8] & {2{~fcD}} 
        .fcA( fcA ),
        .fcB( fcB ),
        .fcC( fcC ),
        .fcD( fcD ),
        .fcE( fcE ),
        .fcF( fcF ),
        .load_bneq_sig( load_bneq_sig )
    );
// Forward Controller   

// Branch Judger
    BranchJudger branch_judger(
        .typeb_pc_i( typeb_pc_idex ),.typeb_pc_o( typeb_pc ),
        .jjruF( jjruF_idex ),
        .b_flag_cache( {bneqFlag_idex,b_flag_cache_idex[3:0]} ),
        .compare_res( compare_res ),
        .alu_zero( alu_zero ),
        .judge_b2( judge_b2 ),
        .judge_c( judge_c )
    ); 
// Branch Judger

// PC Gen Mux
    Mux pc_gen_mux(
        .select( judge_b2 ),
        .dataA( pc_temp ),  // pc_temp bneq_sel
        .dataB( typeb_pc ),
        .dataC( pc_gen )
    );
// PC Gen Mux

// EX2MEM
    EX2MEM ex2mem(
        .inst_i( inst_idex ),                            .inst_o( inst_exmem ),
        .clk( clk ),
        .rst_n( rst_n ),
        .pc_wb_i( pc_wb_idex ),                     .pc_wb_o( pc_wb_exmem ),
        .wr_width_i( wr_width_idex ),               .wr_width_o( wr_width_exmem ),
        .alu_dataC_i( computed_data ),              .alu_dataCaddress_o( alu_dataCaddress_exmem ),
        .reg_dataB_i( data_b_muxed ),               .w_data_o( w_data_exmem ),  
        //.reg_dataB_i( reg_dataB_idex ),             .w_data_o( w_data_exmem ),  
        .rd_i( rd_idex ),                           .rd_o( rd_exmem ),      
        .c_i( judge_c ),                            .c_o( c_o_exmem ),
        .reg_w_ctrl_i( reg_w_ctrl_idex ),           .reg_w_ctrl_o( reg_w_ctrl_exmem ),
        .reg_w_data_sel_i( reg_w_data_sel_idex ),   .reg_w_data_sel_o( reg_w_data_sel_exmem ),
        .mem_read_ctrl_i( mem_read_ctrl_idex ),     .mem_read_ctrl_o( mem_read_ctrl_exmem ),
        .mem_write_ctrl_i( mem_write_ctrl_idex ),   .mem_write_ctrl_o( mem_write_ctrl_exmem ),
        .fcC_i( fcC ),                              .fcC_o( fcC_exmem )
    );
// EX2MEM

// Dmem_w_data_mux
    Mux Dmem_w_data_mux(
        .select( fcC_exmem ),
        .dataA( w_data_exmem ),
        .dataB( wb_gen ), // r_data_memwb
        .dataC( mem_write_data_muxed )
    );
// Dmem_w_data_mux

// // alu_dmem_mux
//     Mux alu_dmem_mux(
//         .select( 1'b0 ),
//         .dataA( alu_dataCaddress_exmem ),
//         .dataB( mem_read_data ),
//         .dataC( data_a_premuxed )
//     );
// // alu_dmem_mux

// Dmem Conv
    assign mem_read_data = mem_read_data_i;
    assign mem_address_o = alu_dataCaddress_exmem;
    assign wr_width_o = wr_width_exmem;
    assign mem_read_ctrl_o = mem_read_ctrl_exmem;
    assign mem_write_ctrl_o = mem_write_ctrl_exmem;
    assign mem_write_data_o = mem_write_data_muxed;
// Dmem Conv

// MEM2WB
    MEM2WB mem2wb(
        .inst_i( inst_exmem ),                            .inst_o( inst_memwb ),
        .clk( clk ),
        .rst_n( rst_n ),
        .pc_wb_i( pc_wb_exmem ),                    .pc_wb_o( pc_wb_memwb ),
        .r_data_i( mem_read_data ),                 .r_data_o( r_data_memwb ),
        .alu_dataC_i( alu_dataCaddress_exmem ),     .alu_dataC_o( alu_dataC_memwb ),
        .rd_i( rd_exmem ),                          .rd_o( rd_memwb ), 
        .c_i( c_o_exmem ),                          .c_o( c_o_memwb ),
        .reg_w_ctrl_i( reg_w_ctrl_exmem ),          .reg_w_ctrl_o( reg_w_ctrl_memwb ),
        .reg_w_data_sel_i( reg_w_data_sel_exmem ),  .reg_w_data_sel_o( reg_w_data_sel_memwb )
    );
// MEM2WB

// Write Back
    Mux ALU_Dmem_mux(
        .select( reg_w_data_sel_memwb ),
        .dataA( alu_dataC_memwb ),
        .dataB( r_data_memwb ),
        .dataC( wb_gen )
    );

// Write Back    

endmodule   // endmodule PplDatapathTest