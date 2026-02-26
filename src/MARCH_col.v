module MARCH_col (type, col_to_go, adr_o, d_o, col_flag, raw_to_go, WE_i, RE_i);

input   wire                                OPERATION;     // w = 1, r = 0;
input   wire                                VALUE;         // value equal to provided number
input   wire                                GO_DIRECTION;  // falling (n to 0) - 1, rising (0 to n) - 0

input   wire                                col_to_go;
output  reg       [15:0]                    d_i; 
output  reg       [12:0]                    adr_o;
output  reg       [15:0]                    d_o; 
output  reg                                 col_flag;
output  reg                                 raw_to_go;
output  reg                                 WE_i;
output  reg                                 RE_i;
reg               [12:0]                    col_counter;

always @( posedge clk )
    if (!NRST) begin
        col_counter <= 0;

        col_flag    <= 0;
        raw_to_go   <= 0;
        adr_o       <= 0;
        d_o         <= 0;
    end
    else begin
        case ({ OPERATION, VALUE, GO_DIRECTION})    

            000:    begin

                    RE_i <= 1;
                    WE_i <= 0;
                    if ( col_to_go && !raw_to_go ) begin
                        
                        adr_o        <= col_counter;
                        col_counter  <= col_counter + 1;
                        raw_to_go    <= 1;
                        LED_error_flag <= 1;

                    end

                    else
                        // DETECTION OF ERRORS
                        if ( !d_i ) 
                            LED_error_flag <= 0;

                        raw_to_go <= 0;


                    if (&(col_counter[12:1]))
                        col_flag <= 1;
                    else 
                        col_flag <= 0;
            end





        endcase
    end

endmodule