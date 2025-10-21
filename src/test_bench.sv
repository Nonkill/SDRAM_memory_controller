`timescale 1ns / 1ns

module memory_controller_tb();
logic      [12:0]                    ADR_IN; 
logic      [12:0]                    ADR_OUT; 
logic      [1:0]                     BDR_IN;
logic      [1:0]                     BDR_OUT; 
logic      [15:0]                    DIN; 
logic      [15:0]                    DOUT; 
logic                                RE_IN;  
logic                                WE_IN; 
logic                                WE_OUT; 
logic                                NRST; 
logic                                CLK; 
logic                                RDY; 
logic                                CKE; 
logic                                CS;
logic                                RAS; 
logic                                CAS;
wire      [15:0]                     DQ;

memory_controller memory_contoller_inst ( 
                    .ADR_IN  (ADR_IN), 
                    .ADR_OUT (ADR_OUT), 
                    .BDR_IN (BDR_IN),
                    .BDR_OUT (BDR_OUT),  
                    .DIN (DIN), 
                    .DOUT (DOUT), 
                    .RE_IN (RE_IN),  
                    .WE_IN (WE_IN), 
                    .WE_OUT (WE_OUT), 
                    .NRST (NRST), 
                    .CLK (CLK), 
                    .RDY (RDY), 
                    .CKE (CKE), 
                    .CS (CS), 
                    .RAS (RAS), 
                    .CAS (CAS),
                    .DQ (DQ)  
);



 always begin
    #(7/2); CLK = ~CLK;
    end

initial begin
        
        #5;
        NRST = 0;
        #10;
        NRST = 1;
        #5
        CLK = 1;
end
endmodule