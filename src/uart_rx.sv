module uart_rx (
    input logic clk,
    input logic arst_n,

    input logic cpb_i,
    input logic stp_i,
    input logic rx_i,

    output logic rx_data_o,
    output logic rx_done_o,
    output logic rx_busy_o
);

endmodule