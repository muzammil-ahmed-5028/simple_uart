module uart_core 
import UART_CTRL_REGS_pkg::UART_CTRL_REGS__in_t;
import UART_CTRL_REGS_pkg::UART_CTRL_REGS__out_t;
(
    // Clocks and Resets
    input logic clk,
    input logic arst_n,
    
    // UART Top Interface
    input logic rx_i,
    output logic tx_o,

    // UART RIF Interface
    input wire s_apb_psel,
    input wire s_apb_penable,
    input wire s_apb_pwrite,
    input wire [4:0] s_apb_paddr,
    input wire [31:0] s_apb_pwdata,
    output logic s_apb_pready,
    output logic [31:0] s_apb_prdata,
    output logic s_apb_pslverr,

    output logic        irq_rx_o,
    output logic        irq_tx_o
);

logic [7:0]             rx_data;
logic                   rx_done;
logic                   rx_busy;

logic                   tx_done;
logic                   tx_busy;

UART_CTRL_REGS__in_t    hwif_in;
UART_CTRL_REGS__out_t   hwif_out;

assign hwif_in.UART_RDR.RD.next            = rx_data;
assign hwif_in.UART_CFG.RD_RECIEVED.hwset   = rx_done;

assign hwif_in.UART_CFG.TX_START.hwclr      = tx_done;
assign hwif_in.UART_CFG.TX_COMPLETE.hwset   = tx_done;

UART_CTRL_REGS uart_rif (
    .clk            (clk),
    .rst            (!arst_n),
    .s_apb_psel     (s_apb_psel),
    .s_apb_penable  (s_apb_penable),
    .s_apb_pwrite   (s_apb_pwrite),
    .s_apb_paddr    (s_apb_paddr),
    .s_apb_pwdata   (s_apb_pwdata),
    .s_apb_pready   (s_apb_pready),
    .s_apb_prdata   (s_apb_prdata),
    .s_apb_pslverr  (s_apb_pslverr),
    .hwif_in        (hwif_in),
    .hwif_out       (hwif_out)
);

uart_rx rx (
    .clk             (clk),
    .arst_n          (arst_n),
    .cpb_i           (hwif_out.UART_CPB.CPB.value),
    .rx_i            (rx_i),
    .rx_data_o       (rx_data),
    .rx_done_o       (rx_done),
    .rx_busy_o       (rx_busy)
);

uart_tx tx (
    .clk            (clk),
    .arst_n         (arst_n),
    .tx_start_i     (hwif_out.UART_CFG.TX_START.value),
    .tx_data_i      (hwif_out.UART_TDR.TD.value),
    .cpb_i          (hwif_out.UART_CPB.CPB.value),
    .stp_i          (hwif_out.UART_STP.STP.value),
    .tx_o           (tx_o),
    .tx_busy_o      (tx_busy),
    .tx_done_o      (tx_done)
);

assign irq_rx_o = hwif_out.UART_CFG.RD_RECIEVED.value;
assign irq_tx_o = hwif_out.UART_CFG.TX_COMPLETE.value;


endmodule