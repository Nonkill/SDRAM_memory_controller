module top (ADR_IN, ADR_OUT, BDR_IN, BDR_OUT, DIN, DOUT, RE_IN,  WE_IN, WE_OUT, NRST, CLK, RDY, CKE, CS, RAS, CAS, DQ);

input   wire       [12:0]                   ADR_IN; 
output  wire       [12:0]                   ADR_OUT; 
input   wire       [1:0]                    BDR_IN;
output  wire       [1:0]                    BDR_OUT; 
input   wire       [15:0]                   DIN; 
output  wire       [15:0]                   DOUT; 
input   wire                                RE_IN;  
input   wire                                WE_IN; 
output  wire                                WE_OUT; 
input   wire                                NRST; 
input   wire                                CLK ; 
output  wire                                RDY; 
output  wire                                CKE;       
output  wire                                CS;        
output  wire                                RAS;       
output  wire                                CAS;       
output  wire       [15:0]                   DQ;

        wire                                DIRECTION;

memory_controller memory_contoller_inst ( 
                        .ADR_IN  (ADR_IN), 
                        .ADR_OUT (ADR_OUT), 
                        .BDR_IN (BDR_IN),
                        .BDR_OUT (BDR_OUT),  
                        //.DIN (DIN), 
                        //.DOUT (DOUT), 
                        .RE_IN (RE_IN),  
                        .WE_IN (WE_IN),  
                        .NRST (NRST), 
                        .CLK (CLK), 
                        .RDY (RDY), 
                        .WE_OUT (WE_OUT),
                        .CKE (CKE), 
                        .CS (CS), 
                        .RAS (RAS), 
                        .CAS (CAS),
                        //.DQ (DQ),
                        .DIRECTION(DIRECTION)  
);


generate
    genvar i;
    for (i = 0; i < 16; i = i + 1) begin
        IOBUF #(
            .DRIVE (12), // Specify the output drive strength
            .IBUF_LOW_PWR ("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE"
            .IOSTANDARD ("DEFAULT"), // Specify the I/O standard
            .SLEW ("SLOW") // Specify the output slew rate
        ) IOBUF_inst (
            .O (DOUT[i]),             // Buffer output
            .IO(DQ  [i]),              // Buffer inout port (connect directly to top-level port)
            .I (DIN [i]),            // Buffer input
            .T (DIRECTION)      // 3-state enable input, high=input, low=output
        );
    end
endgenerate



endmodule