module IO_handler (
    input clk,
    input reset_n,
    // from external device
    input dma_start_int,
    // from dma controller
    input BR,
    input dma_end_int,
    // to dma controller
    output cmd,
    output BG,
    // from dcache
    input cache_memory_access
);

    assign cmd = reset_n ? dma_start_int : 0;
    assign BG = reset_n && !cache_memory_access ? BR : 0;


endmodule