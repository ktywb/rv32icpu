`include "ppl_datapath_test.v"
// `include "datapath.v"
`include "defines.v"

//iverilog -o top_test.vvp top_test.v
//vvp top_test.vvp
module top(
    // in
    input  [0 :0 ] clk,
    input  [0 :0 ] rst,
    input  [10:0 ] index,

    // dmem in
    input  [0 :0 ] ACKD_n,          // [ ? ] Acknowledge for Data
    // dmem out
    output [1 :0 ] SIZE,
    output [0 :0 ] MREQ,
    output [31:0 ] DAD,
    output [0 :0 ] WRITE,
    // dmem inout
    inout  [31:0 ] DDT,

    // imem in
    input  [0 :0 ] ACKI_n,          // [ ? ] Acknowledge for Instruction
    input  [31:0 ] IDT,
    input  [31:0 ] IDT2,
    // imem out
    output [31:0 ] IAD,
    output [0 :0 ] IACK_n,      // [ ? ] Instruction Acknowledge

    // interrupt
    input  [2 :0 ] OINT_n           // [ ? ] unknown
);

    wire [31:0 ] pc_out;
    wire [31:0 ] inst;

    wire is_jjru, is_j, is_jr, is_b;      // ppl test
    wire [31:0 ] mem_read_data;
    wire [31:0 ] mem_address;
    wire [2 :0 ] wr_width;
    wire [0 :0 ] mem_read_ctrl;
    wire [0 :0 ] mem_write_ctrl;
    wire [31:0 ] mem_write_data;
    
    I_mem i_mem(
        .clk(clk),
        .pc_out(pc_out),
        .inst(inst),
        .ACKI_n(ACKI_n),
        .IDT(IDT),
        .IDT2(IDT2),
        .IAD(IAD),
        .IACK_n(IACK_n),
        .is_jjru(is_jjru),
        .is_j(is_j),
        .is_jr(is_jr),
        .is_b(is_b)
    );




    // Datapath datapath(
    //     .clk(clk),
    //     .rst_n(rst),
    //     .is_type_l(is_type_l),              // from Imem part judge inst type 

    //     .inst_i(inst),
    //     .pc_out_o(pc_out),

    //     .mem_read_data_i(mem_read_data),
    //     .mem_address_o(mem_address),
    //     .wr_width_o(wr_width),
    //     .mem_read_ctrl_o(mem_read_ctrl),
    //     .mem_write_ctrl_o(mem_write_ctrl),
    //     .mem_write_data_o(mem_write_data)
    // );

    PplDatapathTest datapath(
        .clk(clk),
        .rst_n(rst),
        .is_j(is_j),
        .is_jr(is_jr),
        .is_b(is_b),
        .is_jjru(is_jjru),

        .inst_i(inst),
        .pc_out_o(pc_out),

        .mem_read_data_i(mem_read_data),
        .mem_address_o(mem_address),
        .wr_width_o(wr_width),
        .mem_read_ctrl_o(mem_read_ctrl),
        .mem_write_ctrl_o(mem_write_ctrl),
        .mem_write_data_o(mem_write_data)
    );



    D_mem d_mem(
    .clk(clk),
    .mem_read_ctrl(mem_read_ctrl),
    .mem_write_ctrl(mem_write_ctrl), //  & clk
    .wr_width(wr_width),
    .address(mem_address),
    .w_data(mem_write_data),

    .r_data(mem_read_data),

    .ACKD_n(ACKD_n),
    .SIZE(SIZE),
    .MREQ(MREQ),
    .DAD(DAD),
    .WRITE(WRITE),
    .DDT(DDT)
    );
endmodule   // endmodule top