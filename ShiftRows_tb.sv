`timescale 1ns/1ps
interface SR_if (input bit clk);
  logic reset, valid_in, valid_out;
  logic [127:0]data_in, data_out;
  
  covergroup cg @(posedge clk);
    option.per_instance = 1;
    cp1: coverpoint valid_in;
    cp2: coverpoint reset;
    cp3: coverpoint data_in {option.auto_bin_max = 512;}
  endgroup
  cg cg_inst = new();
  
  clocking ck @(posedge clk);
    default input #1ns output #1ns;
    input data_out, valid_out;
    output reset, valid_in, data_in;
  endclocking
  
endinterface



class transaction;
  rand bit [127:0]data_in;
  rand bit valid_in;
  bit reset;
  bit [127:0]data_out;
  bit valid_out;
  
  constraint valid_in_rd 
  {
    valid_in dist {0:/ 1, 1:/ 255}; 
  } 
  
  function void display(input string tag, bit reset=0);
    $display("[%s] :  reset = %0b \t valid_in = %0b \t data_in = %32x \tvalid_out = %0b \t dout = %32x", tag, reset, valid_in, data_in, valid_out, data_out);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.valid_in = this.valid_in;
    copy.data_in = this.data_in;
    copy.data_out = this.data_out;
    copy.valid_out = this.valid_out;
  endfunction
  
endclass



class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  int count = 200;
  event next, done;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction
  
  task run();
    repeat(count) begin
      assert(tr.randomize()) else $error("Randomization Failed");
      mbx.put(tr.copy);
      tr.display("GEN");
      @(next);
    end
    ->done;
  endtask
endclass




class driver;
  transaction datac;
  mailbox #(transaction) mbx;
  virtual SR_if sif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  ///// Reset DUT
  task reset();
    sif.reset <= 0;
    sif.data_in = 0;
    sif.valid_in <= 0;
    repeat(2) @(posedge sif.clk);
    sif.reset <= 1;
  endtask
  
  ///// Apply random stimulus
  task run();
    forever begin
      mbx.get(datac);
      datac.display("DRV");
      sif.valid_in <= datac.valid_in;
      sif.data_in <= datac.data_in;
      repeat(2) @(posedge sif.clk);
    end
  endtask
  
endclass




class monitor;
  virtual SR_if sif;
  mailbox #(transaction) mbx;
  transaction tr;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    tr = new();
    forever begin
      repeat(2) @(posedge sif.clk);
      tr.reset = sif.reset;
      tr.valid_in = sif.valid_in;
      tr.data_out = sif.data_out;
      tr.data_in = sif.data_in;
      tr.valid_out = sif.valid_out;
      mbx.put(tr);
      tr.display("MON");
    end
  endtask
endclass





class scoreboard;
  mailbox #(transaction) mbx;
  transaction tr;
  event next;
  bit [127:0]dout;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task func(input [127:0]din); /////////shifting state rows as delared in fips197 standard document
    dout[127:120] = din[127:120];
    dout[119:112] = din[87:80];
    dout[111:104] = din[47:40];
    dout[103:96] = din[7:0];
    dout[95:88] = din[95:88];
    dout[87:80] = din[55:48];
    dout[79:72] = din[15:8];
    dout[71:64] = din[103:96];
    dout[63:56] = din[63:56];
    dout[55:48] = din[23:16];
    dout[47:40] = din[111:104];
    dout[39:32] = din[71:64];
    dout[31:24] = din[31:24];
    dout[23:16] = din[119:112];
    dout[15:8] = din[79:72];
    dout[7:0] = din[39:32];
  endtask
  
  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");
      func(tr.data_in);
      if(!tr.reset && tr.data_out == 0 && tr.valid_out == 0) $display("Scoreboard Pass!");
      else if (tr.reset && tr.data_out == dout && tr.valid_out == tr.valid_in) $display("Scoreboard Pass!");
      else $error("Scoreboard Fail!");
    -> next;
    end
  endtask
endclass


class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  event nextgs;
  
  mailbox #(transaction) gdmbx;
  mailbox #(transaction) msmbx;
  
  virtual SR_if sif;
  
  function new(virtual SR_if sif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.sif = sif;
    drv.sif = this.sif;
    mon.sif = this.sif;
    
    gen.next = nextgs;
    sco.next = nextgs;
  endfunction
  
  task  pre_test();
    drv.reset();
  endtask
  
  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);
    $finish;
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
  
endclass


module tb();
  environment env;
  bit clk;
  SR_if sif(clk);
  ShiftRows dut(sif.clk, sif.reset, sif.valid_in, sif.data_in, sif.valid_out, sif.data_out);
  
  initial begin
    clk <= 0;
  end
  
  always #5 clk = ~clk;
  
  initial begin
    env = new(sif);
    env.gen.count = 5000;
    env.run();
  end
endmodule