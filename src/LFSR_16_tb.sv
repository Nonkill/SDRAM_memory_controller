`timescale 100ps / 1ps;
module LFSR_16_tb;

logic NRST = 1;
logic CLK = 0;

LFSR_16 DUT (
                .NRST(NRST),
                .CLK(CLK)
);

always 
        #10 CLK = ~CLK;

initial begin
    #40 NRST = 0;
end




endmodule