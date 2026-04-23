RTL FILE  
module async_fifo ( 
    input        wr_clk, 
    input        rd_clk, 
    input        rst, 
 
    input        wr_en, 
    input  [7:0] wr_data, 
    output reg   full, 
 
    input        rd_en, 
    output reg [7:0] rd_data, 
    output reg   empty 
); 
 
    parameter DEPTH = 8; 
 
    reg [7:0] mem [0:DEPTH-1]; 
 
    reg [2:0] wr_ptr; 
    reg [2:0] rd_ptr; 
 
    // Write Logic 
    always @(posedge wr_clk or posedge rst) 
    begin 
        if (rst) 
        begin 
            wr_ptr <= 0; 
            full   <= 0; 
        end 
        else 
        begin 
            if (wr_en && !full) 
            begin 
                mem[wr_ptr] <= wr_data; 
                wr_ptr <= wr_ptr + 1; 
            end 
        end 
    end 
 
    // Read Logic 
    always @(posedge rd_clk or posedge rst) 
    begin 
        if (rst) 
        begin 
            rd_ptr <= 0; 
            rd_data <= 0; 
            empty <= 1; 
        end 
        else 
        begin 
            if (rd_en && !empty) 
            begin 
                rd_data <= mem[rd_ptr]; 
                rd_ptr <= rd_ptr + 1; 
            end 
        end 
    end 
 
    // Full Condition 
    always @(*) 
    begin 
        if ((wr_ptr + 1) == rd_ptr) 
            full = 1; 
        else 
            full = 0; 
    end 
 
    // Empty Condition 
    always @(*) 
    begin 
        if (wr_ptr == rd_ptr) 
            empty = 1; 
        else 
            empty = 0; 
    end 
 
endmodule