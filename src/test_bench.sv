module memory_controller_tb();

logic      [12:0]                    ADR_IN; 
logic      [12:0]                    ADR_OUT; 
logic      [1:0]                     BDR_IN;
logic      [1:0]                     BDR_OUT; 
logic      [15:0]                    DIN; 
logic      [15:0]                    DOUT; 
logic                   RE_IN,  
                        WE_IN, 
                        WE_OUT, 
                        NRST, 
                        CLK, 
                        RDY, 
                        CKE, 
                        CS, 
                        RAS, 
                        CAS;
wire      [15:0]                    DQ;

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

initial begin

        CLK = 0;

end

always  begin
        #5;
        CLK = ~CLK;
end

endmodule