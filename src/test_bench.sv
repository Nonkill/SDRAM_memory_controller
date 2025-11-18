`timescale 100ps / 1ps

module memory_controller_tb();

int                                  cnt;
int                                  errors;
logic     [12:0]                     addr_row;
logic     [8:0]                      addr_collumn;
logic     [15:0]                     mem_double [3:0][8192:0][8:0];

logic      [12:0]                    ADR_IN; 
wire       [12:0]                    ADR_OUT; 
logic      [1:0]                     BDR_IN;
wire       [1:0]                     BDR_OUT; 
logic      [15:0]                    DIN; 
logic      [15:0]                    DOUT; 
logic                                RE_IN;  
logic                                WE_IN; 
wire                                 WE_OUT; 
logic                                NRST = 0; 
logic                                CLK = 0; 
logic                                RDY; 
wire                                 CKE;       
wire                                 CS;        
wire                                 RAS;       
wire                                 CAS;       
wire      [15:0]                     DQ;        
wire       [12:0]                    adr_out; 
wire       [1:0]                     bdr_out;  
wire                                 we_out;  
wire                                 cke;       
wire                                 cs;        
wire                                 ras;       
wire                                 cas;       
wire      [15:0]                     dq;  


memory_controller memory_contoller_inst ( 
                        .ADR_IN  (ADR_IN), 
                        .ADR_OUT (ADR_OUT), 
                        .BDR_IN (BDR_IN),
                        .BDR_OUT (BDR_OUT),  
                        .DIN (DIN), 
                        .DOUT (DOUT), 
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
                        .DQ (DQ)  
);
//////sdfdsfsdfsdfsdfsdfsdfsd
assign #20 adr_out = ADR_OUT; 
assign #20 bdr_out = BDR_OUT;  
assign #20 we_out  = WE_OUT;  
assign #20 cke     = CKE;       
assign #20 cs      = CS;        
assign #20 ras     = RAS;       
assign #20 cas     = CAS ;       
assign #20 dq      = DQ;    

IS42S16160 memory_inst (
                        .Dq(dq),
                        .Addr(adr_out),
                        .Ba(bdr_out),
                        .Clk(CLK),
                        .Cke(cke),
                        .Cs_n(cs),
                        .Ras_n(ras),
                        .Cas_n(cas),
                        .We_n(we_out),
                        .Dqm(2'b00)
);

task automatic mem_ACTIVE_select_row (ref logic [12:0] ADR_IN);
        //#10;
        ADR_IN = addr_row;
endtask

task automatic mem_WRITE_collumn (ref logic [12:0] ADR_IN);
        //#10;
        ADR_IN = addr_collumn;
endtask

task automatic mem_WRITE (ref logic CLK, ref logic [12:0] addr_row, ref logic [8:0] addr_collumn, input logic RDY, ref logic [12:0] ADR_IN, inout logic [1:0] BDR_IN, output logic RE_IN, output logic WE_IN, output logic [15:0] DIN);

                //@(posedge CLK);
                if (1) begin
                        if (addr_collumn < 511) begin

                                repeat (4) @(posedge CLK);
                                //$display("[%0t] ADR_IN set to addr_row: %h", $time, addr_row);
                                WE_IN = 1;
                                RE_IN = 0;
                                DIN = $urandom();
                                mem_double [BDR_IN][addr_row][addr_collumn] = DIN;
                                mem_WRITE_collumn (ADR_IN);
                                //$display("[%0t] ADR_IN changed to addr_collumn: %h", $time, addr_collumn);
                                addr_collumn += 1;
                                repeat (5) @(posedge CLK);
                                mem_ACTIVE_select_row (ADR_IN);

                        end
                        else begin

                                if (&addr_row && (addr_collumn >= 511))
                                        BDR_IN = BDR_IN + 1;
                                
                                addr_row += 1;
                                addr_collumn += 1;
                                repeat (4) @(posedge CLK);
                                //$display("[%0t] ADR_IN set to addr_row: %h", $time, addr_row);
                                WE_IN = 1;
                                RE_IN = 0;
                                DIN = $urandom();
                                mem_double [BDR_IN][addr_row][addr_collumn] = DIN;
                                mem_WRITE_collumn (ADR_IN);
                                //$display("[%0t] ADR_IN changed to addr_collumn: %h", $time, addr_collumn);
                                addr_collumn += 1;
                                repeat (5) @(posedge CLK);
                                mem_ACTIVE_select_row (ADR_IN);

                        end
                end

endtask

task automatic mem_READ (ref logic CLK, ref logic [12:0] addr_row, ref logic [8:0] addr_collumn, input logic RDY, input logic [15:0] DQ, ref logic [12:0] ADR_IN, inout logic [1:0] BDR_IN, output logic RE_IN, output logic WE_IN);

                //@(posedge CLK);
                if (1) begin
                        if (addr_collumn < 511) begin

                                repeat (3) @(posedge CLK);
                                $display("[%0t] ADR_IN set to addr_row: %h", $time, addr_row);
                                WE_IN = 0;
                                RE_IN = 1;
                                mem_WRITE_collumn (ADR_IN);
                                $display("[%0t] ADR_IN changed to addr_collumn: %h", $time, addr_collumn);
                                addr_collumn += 1;
                                repeat (3) @(posedge CLK);
                                if ( DQ != mem_double [BDR_IN][addr_row][addr_collumn]) begin
                                        $error ("Found error in cell [%d][%d][%d]", BDR_IN, addr_row, addr_collumn);
                                        errors += 1;
                                end
                                repeat (2) @(posedge CLK);
                                mem_ACTIVE_select_row (ADR_IN);

                        end
                        else begin
                                if (&addr_row && (addr_collumn >= 511))
                                        BDR_IN = BDR_IN + 1;
                                
                                addr_row += 1;
                                addr_collumn += 1;
                                repeat (3) @(posedge CLK);
                                $display("[%0t] ADR_IN set to addr_row: %h", $time, addr_row);
                                WE_IN = 0;
                                RE_IN = 1;
                                mem_WRITE_collumn (ADR_IN);
                                $display("[%0t] ADR_IN changed to addr_collumn: %h", $time, addr_collumn);
                                addr_collumn += 1;
                                repeat (3) @(posedge CLK);
                                if ( DQ != mem_double [BDR_IN][addr_row][addr_collumn]) begin
                                        $error ("Found error in cell [%d][%d][%d]", BDR_IN, addr_row, addr_collumn);
                                        errors += 1;
                                end
                                repeat (2) @(posedge CLK);
                                mem_ACTIVE_select_row (ADR_IN);

                        end
                end


endtask

always begin
        #35; CLK = ~CLK;
    end

initial begin
        
        //reseting
        #50;
        NRST = 0;
      #100;
        NRST = 1;

        WE_IN =  0;
        RE_IN =  0;
        DIN   = '0;
        BDR_IN = 0;
        addr_row = 0;
        addr_collumn = 0;

        repeat (14401)
                @(posedge CLK);

        //16777216 - full size
        repeat (520) begin
                //wait(RDY);
                mem_WRITE (CLK, addr_row, addr_collumn, RDY, ADR_IN, BDR_IN, RE_IN, WE_IN, DIN);
        end

        BDR_IN = 0;
        addr_row = 0;
        addr_collumn = 0;

        repeat(520) begin
                mem_READ (CLK, addr_row, addr_collumn, RDY, DQ, ADR_IN, BDR_IN, RE_IN, WE_IN);
        end

        RE_IN = 0;
        WE_IN = 0;

        $display ("Sim ended with %d errors", errors );
end
endmodule