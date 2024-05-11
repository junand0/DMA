`define WORD_SIZE 16
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus grant (BG) signal, 
*        data from the device (edata), and DMA command (cmd)
* output: bus request (BR) signal 
*         WRITE signal
*         memory address (addr) to be written by the device, 
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports 
* (e.g., wire -> reg) if you want 
* Do not add more ports! 
*************************************************/

module DMA (
    input CLK, BG,
    input [4 * `WORD_SIZE - 1 : 0] edata,
    input cmd,
    output BR, WRITE,
    output [`WORD_SIZE - 1 : 0] addr, 
    output [4 * `WORD_SIZE - 1 : 0] data,
    output [1:0] offset,
    output interrupt);

//// create BR signal
    reg BR_reg = 0;
    assign BR = BR_reg;

    always @(*) begin
        if(cmd) begin
            BR_reg = 1;
        end
        if(offset == 2'b10 && dwrite_clk_cnt == 0) begin
            BR_reg = 0;
        end
    end

//// send data to memory
    reg WRITE_reg = 0;
    assign WRITE = !BG ? 1'bz
                    : WRITE_reg ? 1 : 1'bz;
    assign addr = BG ? `WORD_SIZE'h1f4 : `WORD_SIZE'bz;
    assign data = BG ? edata : 64'bz;

    assign offset = !BG ? 2'bz 
                    : dwrite_clk_cnt == 0 ? 0
                    : dwrite_clk_cnt == 4 ? 2'b01
                    : dwrite_clk_cnt == 8 ? 2'b10
                    : offset;


    always @(posedge CLK) begin
        if(BG) begin
            WRITE_reg <= 1;
        end
        else begin
            WRITE_reg <= 0;
        end
    end

//// data write latency calculation
    reg [3:0] dwrite_clk_cnt = 0; // # of memory write latency

    always @(posedge CLK) begin
        if(WRITE) begin
            dwrite_clk_cnt = dwrite_clk_cnt + 1;
        end
        if(dwrite_clk_cnt == 12) begin
            dwrite_clk_cnt = 0;
        end
    end

endmodule


