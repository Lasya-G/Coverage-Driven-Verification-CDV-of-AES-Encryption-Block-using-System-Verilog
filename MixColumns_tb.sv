`timescale 1ns/1ps
interface MC_if (input bit clk);
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
  virtual MC_if mif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  ///// Reset DUT
  task reset();
    mif.reset <= 0;
    mif.data_in = 0;
    mif.valid_in <= 0;
    repeat(2) @(posedge mif.clk);
    mif.reset <= 1;
  endtask
  
  ///// Apply random stimulus
  task run();
    forever begin
      mbx.get(datac);
      datac.display("DRV");
      mif.valid_in <= datac.valid_in;
      mif.data_in <= datac.data_in;
      repeat(2) @(posedge mif.clk);
    end
  endtask
  
endclass


class monitor;
  virtual MC_if mif;
  mailbox #(transaction) mbx;
  transaction tr;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    tr = new();
    forever begin
      repeat(1) @(posedge mif.clk);
      tr.reset = mif.reset;
      tr.valid_in = mif.valid_in;
      tr.data_out = mif.data_out;
      tr.data_in = mif.data_in;
      tr.valid_out = mif.valid_out;
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
  
  bit [7:0]State[16];
  bit [7:0]State_Mulx2[16];
  bit [7:0]State_Mulx3[16];
  int i = 0, j = 0, k = 0;
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task func(input bit [127:0]din);
    State[0] = din[127:120];
    State[1] = din[119:112];
    State[2] = din[111:104];
    State[3] = din[103:96];
    State[4] = din[95:88];
    State[5] = din[87:80];
    State[6] = din[79:72];
    State[7] = din[71:64];
    State[8] = din[63:56];
    State[9] = din[55:48];
    State[10] = din[47:40];
    State[11] = din[39:32];
    State[12] = din[31:24];
    State[13] = din[23:16];
    State[14] = din[15:8];
    State[15] = din[7:0];
    for(i = 0; i < 16; i=i+1) begin
      State_Mulx2[i]= (State[i][7])?((State[i]<<1) ^ 8'h1b):(State[i]<<1); State_Mulx3[i]= (State_Mulx2[i])^State[i];
    end
    dout[(15*8)+7:(15*8)]<=  State_Mulx2[0] ^ State_Mulx3[1] ^ State[2] ^ State[3];
    dout[(14*8)+7:(14*8)]<= State[0] ^ State_Mulx2[1] ^ State_Mulx3[2] ^ State[3]; 
    dout[(13*8)+7:(13*8)]<= State[0] ^ State[1] ^ State_Mulx2[2] ^ State_Mulx3[3]; 
    dout[(12*8)+7:(12*8)]<= State_Mulx3[0] ^ State[1] ^ State[2] ^ State_Mulx2[3];
    dout[(11*8)+7:(11*8)]<= State_Mulx2[4] ^ State_Mulx3[5] ^ State[6] ^ State[7];
    dout[(10*8)+7:(10*8)]<= State[4] ^ State_Mulx2[5] ^ State_Mulx3[6] ^ State[7]; 
    dout[(9*8)+7:(9*8)] <=  State[4] ^ State[5] ^ State_Mulx2[6] ^ State_Mulx3[7]; 
    dout[(8*8)+7:(8*8)]<= State_Mulx3[4] ^ State[5] ^ State[6] ^ State_Mulx2[7];
    dout[(7*8)+7:(7*8)]<= State_Mulx2[8] ^ State_Mulx3[9] ^ State[10] ^ State[11];
    dout[(6*8)+7:(6*8)]<= State[8] ^ State_Mulx2[9] ^ State_Mulx3[10] ^ State[11]; 
    dout[(5*8)+7:(5*8)]<= State[8] ^ State[9] ^ State_Mulx2[10] ^ State_Mulx3[11]; 
    dout[(4*8)+7:(4*8)]<= State_Mulx3[8] ^ State[9] ^ State[10] ^ State_Mulx2[11];
    dout[(3*8)+7:(3*8)]<= State_Mulx2[12] ^ State_Mulx3[13] ^ State[14] ^ State[15];
    dout[(2*8)+7:(2*8)]<= State[12] ^ State_Mulx2[13] ^ State_Mulx3[14] ^ State[15]; 
    dout[(1*8)+7:(1*8)]<= State[12] ^ State[13] ^ State_Mulx2[14] ^ State_Mulx3[15]; 
    dout[(0*8)+7:(0*8)]<= State_Mulx3[12] ^ State[13] ^ State[14] ^ State_Mulx2[15];
  endtask
  
  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");
      func(tr.data_in);
      $display("%x", dout);
      if(!tr.reset && tr.data_out == 0 && tr.valid_out == 0) $display("Data Match");
      else if (tr.reset && tr.data_out == dout && tr.valid_out == tr.valid_in) $display("Data Match");
      else $error("Error Data Mismatch");
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
  
  virtual MC_if mif;
  
  function new(virtual MC_if mif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.mif = mif;
    drv.mif = this.mif;
    mon.mif = this.mif;
    
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
  MC_if mif(clk);
  MixColumns dut(mif.clk, mif.reset, mif.valid_in, mif.data_in, mif.valid_out, mif.data_out);
  
  initial begin
    clk <= 0;
  end
  
  always #5 clk = ~clk;
  
  initial begin
    env = new(mif);
    env.gen.count = 5000;
    env.run();
  end
endmodule