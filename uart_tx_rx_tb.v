`timescale 1ns/1ps

module uart_tx_rx_tb;

    localparam CLK_FREQ  = 1_000_000;
    localparam BAUD_RATE = 115200;

    reg clk, rst_n, tx_start;
    reg [7:0] tx_data;
    wire tx_line, tx_busy;
    wire [7:0] rx_data;
    wire rx_done;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) TX (
        .clk(clk), .rst_n(rst_n), .tx_start(tx_start), .tx_data(tx_data), .tx(tx_line), .tx_busy(tx_busy)
    );
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) RX (
        .clk(clk), .rst_n(rst_n), .rx(tx_line), .rx_data(rx_data), .rx_done(rx_done)
    );

    always #500 clk = ~clk;

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tx_rx_tb);
        clk = 0; rst_n = 0; tx_start = 0; tx_data = 8'h00;
        #1000 rst_n = 1;
        #1000;
        tx_data = 8'hA5; tx_start = 1;
        #1000 tx_start = 0;
        wait (rx_done == 1);
        $display("Sent = 0x%02h | Received = 0x%02h | %s", 8'hA5, rx_data, (rx_data == 8'hA5) ? "PASS" : "FAIL");
        #5000 $finish;
    end

endmodule
