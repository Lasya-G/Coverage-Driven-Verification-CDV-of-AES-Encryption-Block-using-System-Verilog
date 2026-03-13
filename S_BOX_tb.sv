// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
interface SBOX_IF (input bit clk);
  logic reset, valid_in;
  logic [7:0]addr, dout;
  
  covergroup cg @(posedge clk);
    option.per_instance = 1;
    cp1: coverpoint valid_in;
    cp2: coverpoint reset;
    cp3: coverpoint addr {option.auto_bin_max = 256;}
  endgroup
  
  clocking ck @(posedge clk);
    default input #1ns output #1ns;
    input dout;
    output reset, valid_in, addr;
  endclocking
  cg cg_inst = new();
  
endinterface 


class transaction;
  rand bit valid_in;
  randc bit [7:0]addr;
  bit [7:0]dout;
  bit reset;
  
  constraint valid_in_rd 
  {
    valid_in dist {0:/ 1, 1:/ 255}; 
  }
  
  function void display(input string tag, bit reset=0);
    $display("[%s] :  reset = %0b \t valid_in = %0b \t addr = %2x \t dout = %2x", tag, this.reset, valid_in, addr, dout);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.valid_in = this.valid_in;
    copy.addr = this.addr;
    copy.dout = this.dout;
  endfunction
  
endclass


class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  
  int count = 20;
  event next, done;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction
  
  task run();
    repeat(count) begin
      assert (tr.randomize()) else $error("Randomization Failed");
      mbx.put(tr.copy);
      tr.display("GEN");
      @(next);
    end
    ->done;
  endtask
endclass


class driver;
  transaction datac;
  mailbox #(transaction)mbx;
  virtual SBOX_IF sif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  ///// Reset DUT
  task reset();
    sif.reset <= 0;
    sif.addr <= 0;
    sif.valid_in <= 0;
    repeat(2) @(posedge sif.clk);
    sif.reset <= 1;
  endtask
  
  
  //// Apply random Stimulii
  task run();
    forever begin
      mbx.get(datac);
      datac.display("DRV");
      sif.valid_in <= datac.valid_in;
      sif.addr <= datac.addr;
      repeat(2) @(posedge sif.clk);
    end
  endtask
endclass




class monitor;
  virtual SBOX_IF sif;
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
      tr.addr = sif.addr;
      tr.dout = sif.dout;
      mbx.put(tr);
      tr.display("MON");
    end
  endtask
endclass



class scoreboard;
  mailbox #(transaction) mbx;
  transaction tr;
  event next;
  bit [7:0]reference_model[] = '{8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76, 8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2,  8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0, 8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75, 8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84, 8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58,8'hcf, 8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8, 8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d,8'h38,8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2, 8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64,8'h5d,8'h19, 8'h73, 8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb, 8'he0, 8'h32, 8'h3a, 8'h0a,8'h49,8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79, 8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08, 8'hba,  8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4,  8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a, 8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6,  8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e, 8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9,  8'hce, 8'h55, 8'h28, 8'hdf, 8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf,  8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16};
 
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");
      if(tr.reset && tr.dout == 8'h00)
        $display("Data Match");
      else if(tr.dout == reference_model[tr.addr] && tr.valid_in)
        $display("Data Match");
      else $error("Error");
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
  
  virtual SBOX_IF sif;
  
  function new(virtual SBOX_IF sif);
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
  SBOX_IF sif(clk);
  S_BOX dut(sif.clk, sif.reset, sif.valid_in, sif.addr, sif.dout);
  initial begin
    clk <= 0;
  end
  always #5 clk= ~clk;
  
  initial begin
    env = new(sif);
    env.gen.count = 500;
    env.run();
  end
endmodule