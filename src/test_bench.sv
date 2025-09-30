module memory_controller_tb();

logic               ADR_IN, 
                    ADR_OUT, 
                    BDR, 
                    DIN, 
                    DOUT, 
                    RE_IN,  
                    WE_IN, 
                    WE_OUT, 
                    NRST, 
                    CLK, 
                    RDY, 
                    CKE, 
                    CS, 
                    RAS, 
                    CAS;

memory_controller memory_contoller_inst ( 
                    .ADR_IN  (ADR_IN), 
                    .ADR_OUT (ADR_OUT), 
                    .BDR (BDR), 
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
                    .CAS (CAS)  
);

initial begin

        CLK = 0;

end

always  begin
        #5;
        CLK = ~CLK;
end

endmodule