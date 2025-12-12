module LFSR_16 (NRST, CLK);

input NRST, CLK;

reg [15:0] r_shiftreg;

always @(posedge CLK)
    if (NRST)
        r_shiftreg <= 16'b0000_0000_0000_0001;
    else 
        r_shiftreg <= {r_shiftreg[14:0], ~(r_shiftreg[15]^r_shiftreg[14]^r_shiftreg[12]^r_shiftreg[3])};




endmodule