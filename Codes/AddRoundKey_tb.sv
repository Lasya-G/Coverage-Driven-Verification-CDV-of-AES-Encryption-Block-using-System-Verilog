`timescale 1ns/1ps
interface ARK_if (input bit clk);
  logic reset, data_valid_in, key_valid_in, valid_out;
  logic [127:0]data_in, data_out, round_key;
  
  covergroup cg @(posedge clk);
    option.per_instance = 1;
    cp1: coverpoint reset;
    cp2: coverpoint data_valid_in;
    cp3: coverpoint key_valid_in;
    cp4: coverpoint round_key  {option.auto_bin_max = 512;}
    cp5: coverpoint data_in {option.auto_bin_max = 512;}
  endgroup
  cg cg_inst = new();
  
  clocking ck @(posedge clk);
    default input #1ns output #1ns;
    input data_out, valid_out;
    output reset, data_valid_in, key_valid_in, data_in, round_key;
  endclocking
  
endinterface


class transaction;
  rand bit [127:0]data_in;
  rand bit [127:0] round_key;
  rand bit data_valid_in;
  rand bit key_valid_in;
  bit reset;
  bit [127:0] data_out;
  bit valid_out;
  
  constraint valid_in_rd 
  {
    data_valid_in dist {0:/ 1, 1:/ 255}; 
    key_valid_in dist {0:/ 1, 1:/ 255};
  } 
  
  function void display(input string tag);
    $display("[%s] :  reset = %0b \t data_valid_in = %0b \t data_in = %32x \tvalid_out = %0b \t data_out = %32x \t key_valid_in = %0b \t round_key = %32x", tag, reset, data_valid_in, data_in, valid_out, data_out, key_valid_in, round_key);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.data_valid_in = this.data_valid_in;
    copy.key_valid_in = this.key_valid_in;
    copy.data_in = this.data_in;
    copy.round_key = this.round_key;
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
  virtual ARK_if aif;
 event next;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  ///// Reset DUT
  task reset();
    aif.reset <= 0;
    aif.data_in = 0;
    aif.data_valid_in <= 0;
	aif.key_valid_in <= 0;
	aif.round_key <= 0;
    repeat(2) @(posedge aif.clk);
    aif.reset <= 1;
  endtask
  
  ///// Apply random stimulus
  task run();
    forever begin
      mbx.get(datac);
      datac.display("DRV");
      aif.data_valid_in <= datac.data_valid_in;
	  aif.key_valid_in <= datac.key_valid_in;
      aif.data_in <= datac.data_in;
	  aif.round_key <= datac.round_key;
      repeat(2) @(posedge aif.clk);
	->next;
    end
  endtask
  
endclass




class monitor;
  virtual ARK_if aif;
  mailbox #(transaction) mbx;
  transaction tr;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    tr = new();
    forever begin
      repeat(2) @(posedge aif.clk);
      tr.reset = aif.reset;
      tr.data_valid_in = aif.data_valid_in;
      tr.key_valid_in = aif.key_valid_in;
      tr.round_key = aif.round_key;
      tr.data_out = aif.data_out;
      tr.data_in = aif.data_in;
      tr.valid_out = aif.valid_out;
      mbx.put(tr);
      tr.display("MON");
    end
  endtask
endclass




class scoreboard;
  mailbox #(transaction) mbx;
  transaction tr;
  event next;
  bit [127:0]data_out;
  bit valid_out;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  //bit [7:0]reference_model[] = '{8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76, 8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2,  8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0, 8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75, 8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84, 8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58,8'hcf, 8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8, 8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d,8'h38,8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2, 8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64,8'h5d,8'h19, 8'h73, 8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb, 8'he0, 8'h32, 8'h3a, 8'h0a,8'h49,8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79, 8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08, 8'hba,  8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4,  8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a, 8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6,  8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e, 8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9,  8'hce, 8'h55, 8'h28, 8'hdf, 8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf,  8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16};
  

 task run();
   forever begin
   mbx.get(tr);
   tr.display("SCO");
   if((tr.data_valid_in && tr.key_valid_in) == 1'b1)
   begin 
    data_out <=  tr.data_in ^ tr.round_key;
	#100;
	if (tr.data_out == data_out) begin
	$display("Data Match");
end  
	else
	$error("Error Data Mismatch");
end
->next;
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
  
  virtual ARK_if aif;
  
  function new(virtual ARK_if aif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.aif = aif;
    drv.aif = this.aif;
    mon.aif = this.aif;
    
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
  ARK_if aif(clk);
 AddRoundKey dut(aif.clk, aif.reset, aif.data_valid_in, aif.key_valid_in, aif.data_in, aif.round_key, aif.valid_out, aif.data_out);
  
  initial begin
    clk <= 0;
  end
  
  always #5 clk = ~clk;
  
  initial begin
    env = new(aif);
    env.gen.count = 5000;
    env.run();
  end
endmodule
