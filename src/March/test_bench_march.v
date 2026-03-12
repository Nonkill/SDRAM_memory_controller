////////////////////////////////////////////////////////////////////////////////
//
// Company:
// Engineer:        Ilinov Artem Alekseevich
//
// Create Date:     19:13 11.03.2026
// Design Name:
// Module Name:     test_bench_march
// Project Name:
// Target Devices:
// Tool versions:
// Description:     test_bench for march algorithm
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/100 ps
`default_nettype none

module test_bench_march;

parameter PERIOD = 7;

reg     [  8 :  0 ] r_reset = 9'b011111111;
reg                 r_clk   = 1'b0;

reg                 r_mem_rdy = 1'b0;
reg     [ 15 :  0 ] r_di = 16'b0;


initial begin
            forever
            #(PERIOD/2) r_clk = ~r_clk;
        end


    always @(posedge r_clk)
        if(~r_reset[8])
            r_reset <= r_reset - 9'd1;


initial
begin
    @(posedge r_reset[8])

    #10;

    @(posedge r_clk)
    #1;
    r_mem_rdy = 1'b0;


end



march
    march_inst
    (
        .CLK                        (r_clk),            //  in, u[ 1], Clock
        .NRESET                     (r_reset[8]),       //  in, u[ 1], Async. negedge reset
        .MEM_RDY                    (r_mem_rdy),        //  in, u[ 1], Memory controller ready
        .DI                         (r_di),             //  in, u[16], Data from RAM
        .A                          (),                 // out, u[16], Address
        .DO                         (),                 // out, u[16], Data to RAM
        .WE                         (),                 // out, u[16], Write enable for memory
        .RE                         (),                 // out, u[16], Read enable for memory
        .RDY                        (),                 // out, u[ 1], Ready
        .FLAG                       (),                 // out, u[ 1], error flag
        .ADDR_ERR                   (),                 // out, u[16], address of error
        .VALUE_ERR                  (),                 // out, u[ 1], value of error
        .VALUE_EXP                  ()                 // out, u[ 1], expected value
    );

endmodule
