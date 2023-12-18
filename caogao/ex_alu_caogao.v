`include "defines.v"
// operate    code

// 算术加法     000
// 算术减法     001

// 逻辑或       010
// 逻辑与       011
// 逻辑异或     100

// 
// 算术右移     101
// 逻辑右移     110
// 逻辑左移     111

module ex_alu (
    input   [0 :0]      rst          ,
    
    input   [2 :0]      ALU_CTRL     ,
    input   [31:0]      ALU_DataA    ,
    input   [31:0]      ALU_DataB    ,

    output  [0 :0]      ALU_Overflow ,
    output  [31:0]      ALU_DataC
    );

    //reg [31:0] result
    wire [31:0] add_result;
    wire [31:0] logic_result;
    wire [31:0] shift_result;

    // OPeration Flag
    assign OpF1 = (ALU_CTRL[2] | ALU_CTRL[1]);
    assign OpF2 = ((ALU_CTRL[2] & ALU_CTRL[0]) | (ALU_CTRL[2] & ALU_CTRL[1]));
    assign OpF  = {OpF1, OpF2};
    assign Ovctr = ~ALU_CTRL[2] & ~ALU_CTRL[1] & ALU_CTRL[0];
    assign LogiOpF = ALU_CTRL[1:0];
    assign ShiftOpF = ALU_CTRL[1:0];
    assign SubOpF = ~ALU_CTRL[3]  & ~ALU_CTRL[2]  & ALU_CTRL[1];

    // add
    wire ADD_carry ;
    Adder adder(
        .ALU_DataA(ALU_DataA),
        .ALU_DataB(ALU_DataB),
        .SubOpF(SubOpF),
        .ALU_CTRL(ALU_CTRL),
        .ADD_carry(ADD_carry),
        .ADD_result(ADD_result)
    );


    // logic
    assign logic_result = (LogiOpF == 2'b10) ? (ALU_DataA | ALU_DataB) :      // OR
                                (LogiOpF == 2'b11) ? (ALU_DataA & ALU_DataB) :     // AND
                                (LogiOpF == 2'b00) ? (ALU_DataA ^ ALU_DataB) :     // XOR
                                `ZERO_WORD ;

    //shift
    wire [4:0] bit_num;
    assign bit_num = ALU_DataB[4:0];
    Shifter shifter(
        .ALU_DataA(ALU_DataA) ,
        .bit_num(bit_num),
        .ShiftOpF(ShiftOpF),
        .shift_result(shift_result)
    );

    // result
    assign ALU_DataC = (OpF == 2'b00) ? add_result :
                        (OpF == 2'b10) ? logic_result : 
                        (OpF == 2'b11) ? shift_result :
                        `ZERO_WORD ;
    
endmodule // ex_alu endmodule



// modules

// Shifter
module Shifter (
    input   [31:0]  ALU_DataA   ,
    input   [4 :0]  bit_num     ,
    input   [1 :0]  ShiftOpF    ,
    output  [31:0]  shift_result
    );

    assign shift_result = (ShiftOpF == 2'b01) ? ( ({32{ALU_DataA[31]}} << (6'd32-{1'b0, bit_num})) | (ALU_DataA >> bit_num) ) :   //算术右移 01
                                (ShiftOpF == 2'b10) ? ALU_DataA>>bit_num :   //逻辑右移 10
                                (ShiftOpF == 2'b11) ? ALU_DataA<<bit_num :   //逻辑左移 11
                                `ZERO_WORD ;


    
endmodule   // Shifter endmodule

// Adder
module Adder (
    input   [31:0]  ALU_DataA ,
    input   [31:0]  ALU_DataB ,
    input   [0 :0]  SubOpF ,
    input   [2 :0]  ALU_CTRL ,

    output  [0 :0]  ADD_carry,
    output  [31:0]  ADD_result
    );

    wire [32:0] full_res ;

    assign DataB = SubOpF ? (~ALU_DataB)+ 1 : ALU_DataB ;
    assign full_res = {1'b0, ALU_DataA} + {1'b0, DataB};
    assign ADD_carry = full_res[32];
    assign ADD_result = full_res[31:0] ;

endmodule

