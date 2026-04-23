package fifo_pkg; 
//   
Transaction 
class transaction; 
rand bit wr_en; 
rand bit rd_en; 
rand bit [7:0] wr_data; 
bit [7:0] rd_data; 
function void display(string tag); 
$display("[%s] wr_en=%0b rd_en=%0b wr_data=%0h rd_data=%0h @%0t", 
tag, wr_en, rd_en, wr_data, rd_data, $time); 
endfunction 
endclass 
//   
Generator 
class generator; 
mailbox #(transaction) gen2drv; 
function new(mailbox #(transaction) gen2drv); 
this.gen2drv = gen2drv; 
endfunction 
task run(); 
transaction tr; 
repeat(20) begin 
tr = new(); 
assert(tr.randomize() with { 
wr_en dist {1:=70, 0:=30}; 
rd_en dist {1:=70, 0:=30}; 
}); 
gen2drv.put(tr); 
tr.display("GEN"); 
#10; 
end 
endtask 
endclass 
//   
Driver 
class driver; 
virtual fifo_if vif; 
mailbox #(transaction) gen2drv; 
function new(virtual fifo_if vif, 
mailbox #(transaction) gen2drv); 
this.vif = vif; 
this.gen2drv = gen2drv; 
endfunction 
task run(); 
transaction tr; 
wait(vif.rst == 0); 
forever begin 
gen2drv.get(tr); 
@(posedge vif.wr_clk); 
vif.wr_en   <= tr.wr_en; 
vif.wr_data <= tr.wr_data; 
@(posedge vif.rd_clk); 
vif.rd_en <= tr.rd_en; 
$display("[DRV] wr=%0b rd=%0b data=%0h @%0t", 
tr.wr_en, tr.rd_en, tr.wr_data, $time); 
end 
endtask 
endclass 
//   
Monitor 
class monitor; 
virtual fifo_if vif; 
mailbox #(transaction) mon2scb; 
function new(virtual fifo_if vif, 
mailbox #(transaction) mon2scb); 
this.vif = vif; 
this.mon2scb = mon2scb; 
endfunction 
task run(); 
transaction tr; 
wait(vif.rst == 0); 
forever begin 
@(posedge vif.rd_clk); 
tr = new(); 
tr.wr_en   = vif.wr_en; 
tr.rd_en   = vif.rd_en; 
tr.wr_data = vif.wr_data; 
tr.rd_data = vif.rd_data; 
mon2scb.put(tr); 
tr.display("MON"); 
end 
endtask 
endclass 
//   
Scoreboard (FIFO model) 
class scoreboard; 
mailbox #(transaction) mon2scb; 
bit [7:0] queue[$]; // reference model 
function new(mailbox #(transaction) mon2scb); 
this.mon2scb = mon2scb; 
endfunction 
task run(); 
transaction tr; 
bit [7:0] expected; 
forever begin 
mon2scb.get(tr); 
// WRITE 
if (tr.wr_en) 
queue.push_back(tr.wr_data); 
// READ 
if (tr.rd_en && queue.size() > 0) begin 
expected = queue.pop_front(); 
if (tr.rd_data == expected) 
$display("   
PASS: expected=%0h got=%0h @%0t", 
expected, tr.rd_data, $time); 
else 
$display("  
FAIL: expected=%0h got=%0h @%0t", 
expected, tr.rd_data, $time); 
end 
end 
endtask 
endclass 
endpackage