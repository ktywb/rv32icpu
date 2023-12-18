`include "defines.v"

module ID2EX (

        // inst 
    input      [31:0 ] inst_i,
    output reg [31:0 ] inst_o,
/*- Norm -*/
    // in 
    input  [0 :0 ] clk,    
    input  [0 :0 ] rst_n,
    
/*- Data -*/
/*  // pc_out_
    input      [31:0 ] pc_out_i,
    output reg [31:0 ] pc_out_o, */
    // typeb_pc
    input      [31:0 ] typeb_pc_i,
    output reg [31:0 ] typeb_pc_o,
    // pc_wb
    input      [31:0 ] pc_wb_i,
    output reg [31:0 ] pc_wb_o,
    // jbs_flag_cache
    input      [5 :0 ] b_flag_cache_i,
    output reg [5 :0 ] b_flag_cache_o,
    // wr_width
    input      [2 :0 ] wr_width_i,
    output reg [2 :0 ] wr_width_o,
    // reg_dataA -> alu_dataA
    input      [31:0 ] reg_dataA_i,
    output reg [31:0 ] regalu_dataA_o,
    // reg_dataB
    input      [31:0 ] reg_dataB_i,
    output reg [31:0 ] reg_dataB_o,
    // imm_exten
    input      [31:0 ] imm_exten_i,
    output reg [31:0 ] imm_exten_o,
    // rd
    input      [4 :0 ] rd_i,
    output reg [4 :0 ] rd_o,
    // rs1
    input      [4 :0 ] rs1_i,
    output reg [4 :0 ] rs1_o,
    // rs2
    input      [4 :0 ] rs2_i,
    output reg [4 :0 ] rs2_o,

/*- Ctrl -*/
    // jjruF
    input      [0 :0 ] jjruF_i,
    output reg [0 :0 ] jjruF_o,
    // reg_w_ctrl
    input      [0 :0 ] reg_w_ctrl_i,
    output reg [0 :0 ] reg_w_ctrl_o,
    // reg_w_data_sel
    input      [0 :0 ] reg_w_data_sel_i,
    output reg [0 :0 ] reg_w_data_sel_o,
    // mem_read_ctrl
    input      [0 :0 ] mem_read_ctrl_i,
    output reg [0 :0 ] mem_read_ctrl_o,
    // mem_write_ctrl
    input      [0 :0 ] mem_write_ctrl_i,
    output reg [0 :0 ] mem_write_ctrl_o,
    // alu_ctrl
    input      [3 :0 ] alu_ctrl_i,
    output reg [3 :0 ] alu_ctrl_o,
    // alu_dataB_sel
    input      [0 :0 ] alu_dataB_sel_i,
    output reg [0 :0 ] alu_dataB_sel_o,
    // load_bneq_sig
    input      [0 :0 ] load_bneq_sig_i,
    output reg [0 :0 ] load_bneq_sig_o,
    // load_bneq_sig
    input      [1 :0 ] bneqFlag_i,
    output reg [1 :0 ] bneqFlag_o
);
    reg [31:0 ] inst_i_r, wr_width_i_r;
    always @(*) begin
        inst_i_r <= inst_i;
        wr_width_i_r <= wr_width_i;
    end

    always @(posedge clk or rst_n==1'b0) begin
    // always @(posedge clk or negedge rst_n) begin

        // inst
        inst_o      <= {32{ rst_n}} & inst_i_r ;
        // test_reg <= b_flag_cache_i;// & {5{ rst_n}};
        
        // test_reg2<= b_flag_cache_i & exten_num;

        // Data
//      pc_out_o <= ( {32{ rst_n}} & pc_out_i ) | ( {32{~rst_n}} & `ZERO_WORD );
        typeb_pc_o     <= ( {32{ rst_n}} & typeb_pc_i     ) | ( {32{~rst_n}} & `ZERO_WORD );
        pc_wb_o        <= ( {32{ rst_n}} & pc_wb_i        ) | ( {32{~rst_n}} & `ZERO_WORD );
        b_flag_cache_o <= ( { 6{ rst_n}} & b_flag_cache_i ) | ( { 6{~rst_n}} &   5'b0     );//{ 6{ rst_n}} & b_flag_cache_i_r ;                                     //
        wr_width_o     <= ( { 3{ rst_n}} & wr_width_i_r   ) | ( { 3{~rst_n}} &   3'b0     );
        regalu_dataA_o <= ( {32{ rst_n}} & reg_dataA_i    ) | ( {32{~rst_n}} & `ZERO_WORD );
        reg_dataB_o    <= ( {32{ rst_n}} & reg_dataB_i    ) | ( {32{~rst_n}} & `ZERO_WORD );
        imm_exten_o    <= ( {32{ rst_n}} & imm_exten_i    ) | ( {32{~rst_n}} & `ZERO_WORD );
        rd_o           <= ( { 5{ rst_n}} & rd_i           ) | ( { 5{~rst_n}} &   5'b0     );
        rs1_o          <= ( { 5{ rst_n}} & rs1_i          ) | ( { 5{~rst_n}} &   5'b0     );
        rs2_o          <= ( { 5{ rst_n}} & rs2_i          ) | ( { 5{~rst_n}} &   5'b0     );


        // Ctrl
        jjruF_o          <= ( {1{ rst_n}} & jjruF_i          ) | ( {1{~rst_n}} & 1'b0 );
        reg_w_ctrl_o     <= ( {1{ rst_n}} & reg_w_ctrl_i     ) | ( {1{~rst_n}} & 1'b1 );    // Active low
        reg_w_data_sel_o <= ( {1{ rst_n}} & reg_w_data_sel_i ) | ( {1{~rst_n}} & 1'b0 );
        mem_read_ctrl_o  <= ( {1{ rst_n}} & mem_read_ctrl_i  ) | ( {1{~rst_n}} & 1'b0 );
        mem_write_ctrl_o <= ( {1{ rst_n}} & mem_write_ctrl_i ) | ( {1{~rst_n}} & 1'b0 );
        alu_ctrl_o       <= ( {4{ rst_n}} & alu_ctrl_i       ) | ( {4{~rst_n}} & 4'b0 );
        alu_dataB_sel_o  <= ( {1{ rst_n}} & alu_dataB_sel_i  ) | ( {1{~rst_n}} & 1'b0 );
        load_bneq_sig_o  <= ( {1{ rst_n}} & load_bneq_sig_i  ) | ( {1{~rst_n}} & load_bneq_sig_i );
        bneqFlag_o       <= ( {2{ rst_n}} & bneqFlag_i       ) | ( {2{~rst_n}} & 2'b0 );
    end
endmodule   // endmodule IF2ID