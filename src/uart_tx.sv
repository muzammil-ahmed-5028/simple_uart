module uart_tx (
    // Clocks and Reset
    input logic         clk,
    input logic         arst_n,
    
    // Transmitter Parameters
    // Driven through RIFs
    input logic         tx_start_i,
    input logic [7:0]   tx_data_i,
    input logic [31:0]  cpb_i,
    input logic [1:0]   stp_i,
    
    // UART TX output
    output logic        tx_o,
    // Status signals sent to RIFs for 
    // software to use
    output logic        tx_busy_o,
    output logic        tx_done_o
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP,
        DONE,
        WAIT_FOR_CLEAR
    } tx_state_t;

    tx_state_t      tx_state;
    logic [32:0]    casted_cpb;
    logic [32:0]    baud_counter;
    logic [32:0]    stop_bit_cycles;
    logic [3:0]     tx_bit_idx;
    
    // -------------------------------------------------------------------------- //
    // Using the casted value of cpb_i from 32 to 33 bits for easier calcualtions //
    // and readable code                                                          //
    // -------------------------------------------------------------------------- //
    
    assign casted_cpb = {1'b0, cpb_i};

    // -------------------------------------------------------------------------- //
    //  UART Stop signal assertion control: Based on stp_i the following case is  // 
    //  used to determine the duration of the STOP signal. The signal is asserted //
    //  During the STOP state                                                     //
    //      STP = 2'b00 -> 1 bit period   i.e 1 CPB                               //
    //      STP = 2'b01 -> 1.5 bit period i.e 1 CPB + 0.5 CPB                     //
    //      STP = 2'b10 -> 2 bit period   i.e 2 CPB                               //
    // -------------------------------------------------------------------------- //
    
    always_comb begin
        case(stp_i) 
            2'b00:      stop_bit_cycles = casted_cpb;
            2'b01:      stop_bit_cycles = casted_cpb + (casted_cpb >> 1);
            2'b10:      stop_bit_cycles = (casted_cpb << 1);
            default:    stop_bit_cycles = (casted_cpb << 1);
        endcase
    end
    
    // -------------------------------------------------------------------------- //
    //  UART TX State Machine: Standard UART TX State Machine as follows          // 
    //      IDLE -> START -> DATA -> STOP -> DONE -> WAIT_FOR_CLEAR               //
    //  Each state transition requires the baud_counter to reach cpb_i (Clock per //
    //  Bit) before the next state transition                                     //
    //                                                                            //
    //  State Explanations                                                        //
    //  IDLE: Idle state with no operation. State transition to START occurs on   //
    //        assertion of tx_start_i                                             //
    //                                                                            //
    //  START:tx_o is asserted as low to signal start of transmission. Transition //
    //        to DATA after 1 baud cycle                                          //
    //                                                                            //
    //  DATA: State during which data is transmitted towards UART RX. tx_o is     //
    //        shifted in data via a shift register with the data from tx_data_i   //
    //        with the shift decided by tx_bit_idx. Transition to STOP state      //
    //        eight baud cycles                                                   //
    //                                                                            //
    //  STOP: UART Stop asserted in this state by tieing low tx_o by stp cycles.  // 
    //        Transition to Done state after one baud cycle                       //
    //                                                                            //
    //  DONE: Auxillary State to give one cycle delay to allow Software to        // 
    //        deassert tx_start_i. State transitions to WAIT_FOR_CLEAR after      //
    //        one cycle                                                           //
    //                                                                            //
    //  WAIT_FOR_CLEAR: State when waiting for software clear signal. This is     //
    //                  done via software by deassertint tx_start_i. Stays in this//
    //                  state until tx_start_i asserted. then transition to IDLE  //
    // -------------------------------------------------------------------------- //
    
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            baud_counter    <= '0;
            tx_state        <= IDLE;
            tx_bit_idx      <= '0;
        end
        else begin
            
            case(tx_state)
                IDLE: begin
                    baud_counter        <= '0;
                    tx_bit_idx          <= '0;  
                    if(tx_start_i) begin
                        tx_state        <= START;
                    end
                end
                
                START: begin  
                    if (baud_counter == (cpb_i - 1)) begin
                        tx_state        <= DATA;
                        baud_counter    <= '0;
                    end
                    else baud_counter <=  baud_counter + 1'b1;
                end

                DATA: begin
                    if(baud_counter == (cpb_i - 1)) begin
                        tx_state        <= (tx_bit_idx == 3'b111) ? STOP : DATA;
                        tx_bit_idx      <= (tx_bit_idx == 3'b111) ? '0   : tx_bit_idx + 1;
                        baud_counter    <= '0;
                    end
                    else baud_counter <=  baud_counter + 1'b1;
                end

                STOP: begin
                    if(baud_counter == (stop_bit_cycles - 1)) begin
                        baud_counter    <= '0;
                        tx_state        <= DONE;
                    end
                    else baud_counter <=  baud_counter + 1'b1;
                end

                DONE: tx_state <= WAIT_FOR_CLEAR;
                
                WAIT_FOR_CLEAR: tx_state <= (!tx_start_i) ? IDLE : WAIT_FOR_CLEAR;

                default: tx_state <= IDLE;
            
            endcase
        end
    end
    
    // -------------------------------------------------------------------------- //
    // Combinational part of UART State Machine. Explanations follow from above.    //
    // -------------------------------------------------------------------------- //
    
    always_comb begin
        tx_o        <= '1; // UART TX is high on idle
        tx_done_o   <= '0;
        tx_busy_o   <= '0;
        case (tx_state)
            IDLE: begin
                tx_o        <= '1;
                tx_busy_o   <= '0;
            end 

            START: begin
                tx_o        <= '0; // Assert low to signal start of Transaction
                tx_busy_o   <= '1; 
            end

            DATA: begin
                tx_o        <= tx_data_i[tx_bit_idx];
                tx_busy_o   <= '1;
            end

            STOP: begin
                tx_o        <= '1;
                tx_busy_o   <= '1;
            end

            DONE: begin
                tx_o        <= '1;
                tx_busy_o   <= '0;
            end

            WAIT_FOR_CLEAR: begin
                tx_o        <= '1;
                tx_busy_o   <= '0;
                tx_done_o   <= '1;
            end
        endcase
    end

endmodule
