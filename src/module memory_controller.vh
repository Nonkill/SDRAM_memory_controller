module memory_controller( ADR_IN, ADR_OUT, BDR, DIN, DOUT, RE_IN,  WE_IN, WE_OUT, NRST, CLK, RDY, CKE, CS, RAS, CAS  );

//parameterized charactheristics of SDRAM
parametr BANK_NUM = 4;
parametr ROW_DEPTH = 8192;
parametr COLUMN_DEPTH = 512;
parametr COLUMN_WIDTH = 16;
parametr BANK_ADRESS = $clog2(BANK_NUM);
parametr ROW_ADRESS = $clog2(ROW_DEPTH);
parametr COLUMN_ADRESS = $clog2(COLUMN_DEPTH);

//delays and timings
parametr CAS_LATENCY = 7; //ns
parametr REFR_TIME = 64; //ms
parametr RP_TIME = 15; //ns, REQUIRED_PRECHARGE TIME
localparam init_delay  = $ceil (( 100 * 10^(-6) ) / CAS_LATENCY); //init delay
localparam REFR_count_width = $ceil ($clog2( (REFR_TIME * 10^(-3)) / (CAS_LATENCY * 10^(-9)))); //counter width due to refresh time


input   [ROW_ADRESS - 1:0]    ADR_IN;
input   [BANK_ADRESS - 1:0]   BDR;
input   [COLUMN_WIDTH - 1:0]  DIN;
input                         RE_IN;
input                         WE_IN;
input                         NRST;
input                         CLK;
output  [ROW_ADRESS - 1:0]    ADR_OUT;
output  [COLUMN_WIDTH - 1:0]  DOUT;
output                        RDY;
output                        CKE;
output                        CS;          //active low
output                        RAS;         //active low
output                        CAS;         //active low
output                        WE_OUT;      //active low

localparam [:0] INIT_HOLD =  ;
localparam [:0] PRECHARGE =  ;
localparam [:0] IDLE      =  ;
localparam [:0] AUTO_REFR =  ;
localparam [:0] MRS       =  ;            //mode register setup

/*localparam [3:0] POWER_ON = 5'b ;
localparam [3:0] PRECHARGE = 5'b ;
localparam [3:0] WRITE = 5'b ;
localparam [3:0] WRTIE_SUSP = 5'b ;
localparam [3:0] WRITEA = 5'b ;
localparam [3:0] WRITEA_SUSP = 5'b ;
localparam [3:0] READ = 5'b ;
localparam [3:0] READ_SUSP = 5'b ;
localparam [3:0] READA = 5'b ;
localparam [3:0] READA_SUSP = 5'b ;
localparam [3:0] ROW_ACTIVE = 5'b ;
localparam [3:0] ACTIVE_PWR_DWN = 5'b ;
localparam [3:0] IDLE = 5'b ;
localparam [3:0] PWR_DWN = 5'b ;
localparam [3:0] AUTO_REFR = 5'b ;
localparam [3:0] SELF_REFR = 5'b ;
localparam [3:0] MRS = 5'b ;*/

reg [3:0] state, next_state;
reg [REFR_count_width - 1: 0] counter, counter_db;
reg init_flag;

always @(posedge CLK or NRST) 
    begin
        if (!NRST)
        state <= INIT_HOLD;
        else 
        state <= next_state;
        
        //encount every clock to calculate refresh time and etc
        counter += 1;

        if (state == INIT_HOLD)        //надо сделать так для всех стейтов из которых доступен prechrage
            counter_db <= counter;
        if ( (state == AUTO_REFR) && (init_flag) )
            counter_db <= counter;
    end


always @(*)
    begin
        next_state = state;

        //вот тут условие if-else, которое стопроцентно делает refresh если счётчик досчитает до 64 мс, а потом уже свитч кейс

        case (state)

            INIT_HOLD:      begin
                            if (counter >= init_delay)
                                next_state = PRECHARGE;
                            init_hold;
            end

            PRECHARGE_ALL:  begin
                            if ( (counter - counter_db) >= (RP_TIME/CAS_LATENCY) ) begin
                                if ( init_flag )
                                    next_state = AUTO_REFR;
                                else
                                    next_state = IDLE;
                            end
                            prechrage_all;
            end

            IDLE:           begin
                           
            end

            AUTO_REFR:      begin
                            if ((counter - counter_db) = 2) begin
                                next_state = MRS;
                                //init_flag = 0;
                            end
                            auto_refr;
            end

            //дописать
            MRS:

        endcase
    end

task init_hold;
    begin

        CKE = 1;
        CS = 0;
        RAS = 1;
        CAS = 1;
        WE = 1;
        RDY = 0;
        init_flag = 1;
    end
endtask

task prechrage_all;
    begin
        
        ADR_OUT [10] = 1;
        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 1;
        WE = 0;
        RDY = 0;

    end
endtask

task auto_refr;
    begin
        
        CKE = 1;
        CS = 0;
        RAS = 0;
        CAS = 1;
        WE = 0;
        RDY = 0;

    end
endtask


  
endmodule