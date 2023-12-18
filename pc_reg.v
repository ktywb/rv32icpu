`include "defines.v"

`define XXX 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
`define start_addr 32'h0001_0000

module Pc_reg (
    input clk,
    input rst_n,
    input fcD,

    input      [31:0] pc_in,
    output reg [31:0] pc_out,
    output reg [31:0] pc_out_
);
    reg [31:0] pc_in_r;
    reg init_done;

    always @(*) pc_in_r <= {32{rst_n}} & pc_in;                       // save pc_in

    always @(posedge clk) begin
        if (!init_done) begin
                pc_out <= `start_addr;                  // while rst_n = 1 and have not been reseted:  pc_out <= `start_addr
                init_done <= 1'b1;
        end else begin
                pc_out <= pc_in;
                // if (fcD)
                //     pc_out <= pc_out;
                // else
                //     pc_out <= pc_in;
        end
    end

    always @(negedge clk) begin
        pc_out_ <= pc_out;
    end

    always @(negedge rst_n) begin                              // reset   
        pc_out <= `start_addr;
        init_done <= 1'b0;
    end

endmodule   // endmodule Pc_reg

module PcRegWithStall (
    input clk,
    input rst_n,

    input fcD,

    input      [31:0] pc_in,
    output reg [31:0] pc_out,
    output reg [31:0] pc_out_
);
    reg [31:0] pc_in_r;
    reg init_done;
    reg f=1'b0;

    always @(*) pc_in_r <= {32{rst_n}} & pc_in;                       // save pc_in

    always @(posedge clk or negedge rst_n or fcD == 1'b1) begin
        // if (!init_done) begin
        //         pc_out <= `start_addr;                  // while rst_n = 1 and have not been reseted:  pc_out <= `start_addr
        //         init_done <= 1'b1;
        //     end 
        // else 
        //     pc_out <= ({32{ fcD}} & pc_out)
        //             | ({32{~fcD}} & pc_in );

        // pc_out <= ({32{ fcD}} & pc_out_)
        //         | ({32{~fcD}} & pc_in );
        
        // pc_out <= ( {32{ rst_n}} & ({32{ fcD}} & pc_out)
        //                          | ({32{~fcD}} & pc_in ) ) 
        //         | ( {32{~rst_n}} & `start_addr );
        if (!rst_n)
            pc_out <= `start_addr;
        else if(fcD) begin
            pc_out <= pc_out_;
            f <= ~f;
        end
        else
            pc_out <= pc_in_r;
        // f <= ~f;
    end

    always @(negedge clk) begin
        pc_out_ <= pc_out;
    end

    // always @(negedge rst_n) begin                              // reset   
    //     pc_out <= `start_addr;
    //     init_done <= 1'b0;
    // end

endmodule   // endmodule PcRegWithStall