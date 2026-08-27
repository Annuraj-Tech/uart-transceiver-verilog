# UART Transceiver — Verilog

A UART (Universal Asynchronous Receiver/Transmitter) implementing the standard **8N1** frame format: 1 start bit, 8 data bits, no parity, 1 stop bit. Includes both transmitter (`uart_tx`) and receiver (`uart_rx`) modules, verified together via loopback in the testbench.

## Frame Format

```
Idle(1) → Start(0) → D0 D1 D2 D3 D4 D5 D6 D7 → Stop(1) → Idle(1)
```

The line idles high; a falling edge signals the start of a new byte.

## Module Interfaces

**`uart_tx`**

| Signal | Direction | Description |
|--------|-----------|--------------|
| `tx_start` | input | Pulse high to begin transmitting `tx_data` |
| `tx_data` | input | Byte to send |
| `tx` | output | Serial output line |
| `tx_busy` | output | High while a frame is in progress |

**`uart_rx`**

| Signal | Direction | Description |
|--------|-----------|--------------|
| `rx` | input | Serial input line |
| `rx_data` | output | Byte received |
| `rx_done` | output | Pulses high for one cycle when a byte is fully received |

## Design Notes

- Both modules use a baud tick counter (`CLK_FREQ / BAUD_RATE`) to time each bit against the system clock.
- The receiver samples at the middle of each bit period (`HALF_TICK` offset) to maximize noise margin against clock/data skew.
- `CLK_FREQ` and `BAUD_RATE` are Verilog parameters, so the RTL works at any target clock frequency without modification.

## Repository Structure

```
uart-transceiver-verilog/
├── uart_tx.v
├── uart_rx.v
├── uart_tx_rx_tb.v
└── README.md
```

## Simulation

```bash
iverilog -o uart_sim uart_tx.v uart_rx.v uart_tx_rx_tb.v
vvp uart_sim
```

The testbench wires `uart_tx`'s output directly into `uart_rx`'s input (loopback) and sends a test byte (`0xA5`), printing `Sent = 0xA5 | Received = 0xA5 | PASS` when the TX→RX chain reconstructs the byte correctly.

## Possible Extensions

- Add parity bit support and framing-error detection.
- Add a FIFO buffer on both TX and RX sides for back-to-back byte streaming.
- Integrate with an AXI-Stream or SPI bridge for use in a larger SoC design.

## Author

**Annuraj**
