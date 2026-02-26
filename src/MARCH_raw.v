module MARCH_col (clk, NRST, col_flag, adr_o, bdr_o, col_to_go);

input   wire                                clk;
input   wire                                NRST;  
input   wire                                col_flag;
output  reg       [12:0]                    adr_o;
output  reg       [1:0]                     bdr_o;
output  reg                                 col_to_go;
reg               [12:0]                    raw_counter;
reg               [1:0]                     bdr_counter;
always @( posedge clk )
    if (!NRST) begin
        raw_counter <= 0;
        bdr_counter <= 0;

        col_to_go   <= 0;
        adr_o       <= 0;
        bdr_o       <= 0;
    end
    else begin
        case ({})    
            if ( RDY && raw_to_go && !col_to_go) begin
                adr_o <= raw_counter;
                bdr_o <= bdr_counter;
                col_to_go <= 1;
            end
            else 
                col_to_go <= 0;


            if ( RDY && col_flag)
                raw_counter <= raw_counter + 1;

            if ( &raw_counter )
                bdr_counter <= bdr_counter + 1;
        endcase

    end


endmodule