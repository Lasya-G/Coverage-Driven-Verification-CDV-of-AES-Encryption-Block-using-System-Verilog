`timescale 1ns/1ps
interface ET_if (input bit clk);
  logic reset, data_valid_in, cipherkey_valid_in;
  logic [127:0]cipher_key, plain_text, cipher_text, cipher_key_out;
  logic valid_out;
  
  covergroup cg @(posedge clk);
    option.per_instance = 1;
    cp1: coverpoint data_valid_in;
    cp2: coverpoint reset;
    cp3: coverpoint cipher_key {option.auto_bin_max = 512;}
	cp4: coverpoint cipherkey_valid_in;
	cp5: coverpoint cipher_key;
	cp6: coverpoint plain_text {option.auto_bin_max = 512;}
  endgroup
  cg cg_inst = new();
  
  clocking ck @(posedge clk);
    default input #1ns output #1ns;
    input cipher_text, valid_out, cipher_key_out;
    output reset, cipherkey_valid_in, cipher_key;
  endclocking
  
endinterface



class transaction;
  rand bit [127:0]cipher_key, plain_text;
  rand bit data_valid_in, cipherkey_valid_in;
  bit reset;
  bit [127:0] cipher_text;
  bit [127:0] cipher_key_out;
  bit valid_out;
  
  constraint valid_in_rd 
  {
    data_valid_in dist {0:/ 1, 1:/ 255}; 
	cipherkey_valid_in dist {0:/ 1, 1:/ 255}; 
  } 
  
  function void display(input string tag, bit reset=0);
    $display("[%s] :  reset = %0b \t data_valid_in = %0b \t cipherkey_valid_in = %0b \t cipher_key = %32x \t plain_text = %32x \t valid_out = %0b \t cipher_text = %32x \t dout = %32x", tag, reset, data_valid_in, cipherkey_valid_in , cipher_key , plain_text, valid_out, cipher_text, cipher_key_out);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.data_valid_in = this.data_valid_in;
	copy.cipherkey_valid_in = this.cipherkey_valid_in;
    copy.cipher_key = this.cipher_key;
	copy.plain_text = this.plain_text;
    copy.cipher_text = this.cipher_text;
    copy.cipher_key_out = this.cipher_key_out;
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
  virtual ET_if eif;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  ///// Reset DUT
  task reset();
    eif.reset <= 0;
    eif.cipher_key <= 0;
	eif.plain_text <= 0;
    eif.data_valid_in <= 0;
	eif.cipherkey_valid_in <= 0;
    repeat(2) @(posedge eif.clk);
    eif.reset <= 1;
  endtask
  
  ///// Apply random stimulus
  task run();
    forever begin
      mbx.get(datac);
      datac.display("DRV");
      eif.data_valid_in <= datac.data_valid_in;
	  eif.cipherkey_valid_in <= datac.cipherkey_valid_in;
      eif.cipher_key <= datac.cipher_key;
	  eif.plain_text <= datac.plain_text;
      repeat(2) @(posedge eif.clk);
    end
  endtask
  
endclass


class monitor;
  virtual ET_if eif;
  mailbox #(transaction) mbx;
  transaction tr;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    tr = new();
    forever begin
      repeat(1) @(posedge eif.clk);
      tr.reset = eif.reset;
      tr.data_valid_in = eif.data_valid_in;
	  tr.cipherkey_valid_in = eif.cipherkey_valid_in;
      tr.cipher_key = eif.cipher_key;
	  tr.plain_text = eif.plain_text;
	  tr.valid_out = eif.valid_out;
      tr.cipher_text = eif.cipher_text;
	  tr.cipher_key_out = eif.cipher_key_out;
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
  bit [127:0]doutSB, doutSR, doutMC, doutARK;

bit [9:0] valid_round_key;            
bit [9:0] valid_round_data;           
bit [127:0] data_round [0:9];    
bit valid_sub2shift;                            
bit valid_shift2key;                            
bit [127:0]data_sub2shift;                 
bit [127:0]data_shift2key;                
bit [1279:0] W;               

reg[127:0] data_shift2key_delayed;         
reg valid_shift2key_delayed;

  bit [7:0]State[16];
  bit [7:0]State_Mulx2[16];
  bit [7:0]State_Mulx3[16];

bit [31:0] RCON [0:9]; 
bit [9:0] keygen_valid_out; 
bit [127:0] W_array  [0:9]; 

bit [31:0]Key_RotWord;
bit [31:0]Key_SubBytes;
bit [127:0] temp_round_key;
bit [127:0] round_key;
bit [127:0] cipher_text;
bit [127:0] cipher_key_out;
bit [127:0] cipher_key;
bit valid_out;
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
 bit [7:0]reference_model[] = '{8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5, 8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76, 8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0, 8'had, 8'hd4, 8'ha2,  8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0, 8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc, 8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a, 8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75, 8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0, 8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84, 8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b, 8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58,8'hcf, 8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85, 8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8, 8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d,8'h38,8'hf5, 8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2, 8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17, 8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64,8'h5d,8'h19, 8'h73, 8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88, 8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb, 8'he0, 8'h32, 8'h3a, 8'h0a,8'h49,8'h06, 8'h24, 8'h5c, 8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79, 8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9, 8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08, 8'hba,  8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4,  8'hc6, 8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a, 8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6,  8'h0e, 8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e, 8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94, 8'h9b, 8'h1e, 8'h87, 8'he9,  8'hce, 8'h55, 8'h28, 8'hdf, 8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf,  8'he6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16};

// bit [31:0] RCON[] ='{32'h01000000,32'h02000000,32'h04000000,32'h08000000,32'h10000000,
 // 32'h20000000,32'h40000000,32'h80000000,32'h1b000000,32'h36000000};
  
  task func(input [127:0]din, input bit [127:0]plain_text);
    
  Key_RotWord = {cipher_key[23:0], cipher_key[31:24]};
    Key_SubBytes[7:0] = reference_model[Key_RotWord[7:0]];
    Key_SubBytes[15:8] = reference_model[Key_RotWord[15:8]];
    Key_SubBytes[23:16] = reference_model[Key_RotWord[23:16]];
    Key_SubBytes[31:24] = reference_model[Key_RotWord[31:24]];
    temp_round_key[127:96] = cipher_key[127:96] ^ Key_SubBytes ^ RCON[0];
    temp_round_key[95:64] = cipher_key[95:64] ^ temp_round_key[127:96];
    temp_round_key[63:32] = cipher_key[63:32] ^ temp_round_key[95:64];
    temp_round_key[31:0] = cipher_key[31:0] ^ temp_round_key[63:32];
    W_array[0] = temp_round_key;
	
    for(int i = 1; i < 10; i=i+1) begin
         Key_RotWord = {cipher_key[23:0], cipher_key[31:24]};
    Key_SubBytes[7:0] = reference_model[Key_RotWord[7:0]];
    Key_SubBytes[15:8] = reference_model[Key_RotWord[15:8]];
    Key_SubBytes[23:16] = reference_model[Key_RotWord[23:16]];
    Key_SubBytes[31:24] = reference_model[Key_RotWord[31:24]];
    temp_round_key[127:96] = W_array[i-1] ^ Key_SubBytes ^ RCON[i];
    temp_round_key[95:64] = W_array[i-1] ^ temp_round_key[127:96];
    temp_round_key[63:32] = W_array[i-1] ^ temp_round_key[95:64];
    temp_round_key[31:0] = W_array[i-1] ^ temp_round_key[63:32];
    W_array[i] = temp_round_key;
    end
	W = {W_array[0],W_array[1],W_array[2],W_array[3],W_array[4], W_array[5],W_array[6],W_array[7],W_array[8],W_array[9] };
   
   data_round[0] = plain_text^cipher_key;
   
   for(int i=0;i<9;i=i+1) begin
	 doutSB[7:0] = reference_model[din[7:0]];
    doutSB[15:8] = reference_model[din[15:8]];
    doutSB[23:16] = reference_model[din[23:16]];
    doutSB[31:24] = reference_model[din[31:24]];
    doutSB[39:32] = reference_model[din[39:32]];
    doutSB[47:40] = reference_model[din[47:40]];
    doutSB[55:48] = reference_model[din[55:48]];
    doutSB[63:56] = reference_model[din[63:56]];
    doutSB[71:64] = reference_model[din[71:64]];
    doutSB[79:72] = reference_model[din[79:72]];
    doutSB[87:80] = reference_model[din[87:80]];
    doutSB[95:88] = reference_model[din[95:88]];
    doutSB[103:96] = reference_model[din[103:96]];
    doutSB[111:104] = reference_model[din[111:104]];
    doutSB[119:112] = reference_model[din[119:112]];
    doutSB[127:120] = reference_model[din[127:120]];
    
    doutSR[127:120] = doutSB[127:120];
    doutSR[119:112] = doutSB[87:80];
    doutSR[111:104] = doutSB[47:40];
    doutSR[103:96] = doutSB[7:0];
    doutSR[95:88] = doutSB[95:88];
    doutSR[87:80] = doutSB[55:48];
    doutSR[79:72] = doutSB[15:8];
    doutSR[71:64] = doutSB[103:96];
    doutSR[63:56] = doutSB[63:56];
    doutSR[55:48] = doutSB[23:16];
    doutSR[47:40] = doutSB[111:104];
    doutSR[39:32] = doutSB[71:64];
    doutSR[31:24] = doutSB[31:24];
    doutSR[23:16] = doutSB[119:112];
    doutSR[15:8] = doutSB[79:72];
    doutSR[7:0] = doutSB[39:32];
    
    State[0] = doutSR[127:120];
    State[1] = doutSR[119:112];
    State[2] = doutSR[111:104];
    State[3] = doutSR[103:96];
    State[4] = doutSR[95:88];
    State[5] = doutSR[87:80];
    State[6] = doutSR[79:72];
    State[7] = doutSR[71:64];
    State[8] = doutSR[63:56];
    State[9] = doutSR[55:48];
    State[10] = doutSR[47:40];
    State[11] = doutSR[39:32];
    State[12] = doutSR[31:24];
    State[13] = doutSR[23:16];
    State[14] = doutSR[15:8];
    State[15] = doutSR[7:0];
    for(i = 0; i < 16; i=i+1) begin
      State_Mulx2[i]= (State[i][7])?((State[i]<<1) ^ 8'h1b):(State[i]<<1); State_Mulx3[i]= (State_Mulx2[i])^State[i];
    end
    doutMC[(15*8)+7:(15*8)]<=  State_Mulx2[0] ^ State_Mulx3[1] ^ State[2] ^ State[3];
    doutMC[(14*8)+7:(14*8)]<= State[0] ^ State_Mulx2[1] ^ State_Mulx3[2] ^ State[3]; 
    doutMC[(13*8)+7:(13*8)]<= State[0] ^ State[1] ^ State_Mulx2[2] ^ State_Mulx3[3]; 
    doutMC[(12*8)+7:(12*8)]<= State_Mulx3[0] ^ State[1] ^ State[2] ^ State_Mulx2[3];
    doutMC[(11*8)+7:(11*8)]<= State_Mulx2[4] ^ State_Mulx3[5] ^ State[6] ^ State[7];
    doutMC[(10*8)+7:(10*8)]<= State[4] ^ State_Mulx2[5] ^ State_Mulx3[6] ^ State[7]; 
    doutMC[(9*8)+7:(9*8)] <=  State[4] ^ State[5] ^ State_Mulx2[6] ^ State_Mulx3[7]; 
    doutMC[(8*8)+7:(8*8)]<= State_Mulx3[4] ^ State[5] ^ State[6] ^ State_Mulx2[7];
    doutMC[(7*8)+7:(7*8)]<= State_Mulx2[8] ^ State_Mulx3[9] ^ State[10] ^ State[11];
    doutMC[(6*8)+7:(6*8)]<= State[8] ^ State_Mulx2[9] ^ State_Mulx3[10] ^ State[11]; 
    doutMC[(5*8)+7:(5*8)]<= State[8] ^ State[9] ^ State_Mulx2[10] ^ State_Mulx3[11]; 
    doutMC[(4*8)+7:(4*8)]<= State_Mulx3[8] ^ State[9] ^ State[10] ^ State_Mulx2[11];
    doutMC[(3*8)+7:(3*8)]<= State_Mulx2[12] ^ State_Mulx3[13] ^ State[14] ^ State[15];
    doutMC[(2*8)+7:(2*8)]<= State[12] ^ State_Mulx2[13] ^ State_Mulx3[14] ^ State[15]; 
    doutMC[(1*8)+7:(1*8)]<= State[12] ^ State[13] ^ State_Mulx2[14] ^ State_Mulx3[15]; 
    doutMC[(0*8)+7:(0*8)]<= State_Mulx3[12] ^ State[13] ^ State[14] ^ State_Mulx2[15];
    
    doutARK = doutMC^round_key;
 end
  doutSB[7:0] = reference_model[din[7:0]];
    doutSB[15:8] = reference_model[din[15:8]];
    doutSB[23:16] = reference_model[din[23:16]];
    doutSB[31:24] = reference_model[din[31:24]];
    doutSB[39:32] = reference_model[din[39:32]];
    doutSB[47:40] = reference_model[din[47:40]];
    doutSB[55:48] = reference_model[din[55:48]];
    doutSB[63:56] = reference_model[din[63:56]];
    doutSB[71:64] = reference_model[din[71:64]];
    doutSB[79:72] = reference_model[din[79:72]];
    doutSB[87:80] = reference_model[din[87:80]];
    doutSB[95:88] = reference_model[din[95:88]];
    doutSB[103:96] = reference_model[din[103:96]];
    doutSB[111:104] = reference_model[din[111:104]];
    doutSB[119:112] = reference_model[din[119:112]];
    doutSB[127:120] = reference_model[din[127:120]];
    
    doutSR[127:120] = doutSB[127:120];
    doutSR[119:112] = doutSB[87:80];
    doutSR[111:104] = doutSB[47:40];
    doutSR[103:96] = doutSB[7:0];
    doutSR[95:88] = doutSB[95:88];
    doutSR[87:80] = doutSB[55:48];
    doutSR[79:72] = doutSB[15:8];
    doutSR[71:64] = doutSB[103:96];
    doutSR[63:56] = doutSB[63:56];
    doutSR[55:48] = doutSB[23:16];
    doutSR[47:40] = doutSB[111:104];
    doutSR[39:32] = doutSB[71:64];
    doutSR[31:24] = doutSB[31:24];
    doutSR[23:16] = doutSB[119:112];
    doutSR[15:8] = doutSB[79:72];
    doutSR[7:0] = doutSB[39:32];
	
	cipher_text = data_shift2key_delayed^W[127:0];
	cipher_key_out = W[127:0];
 endtask
  
  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");
      func(tr.cipher_key, tr.plain_text);
      $display("%x", dout);
      if(!tr.reset && tr.cipher_text == 0 && tr.valid_out && tr.cipher_key_out == 0) $display("Data Match");
      else if (tr.reset && tr.cipher_text == cipher_text && tr.valid_out == valid_out && tr.cipher_key_out == cipher_key_out) $display("Data Match");
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
  
  virtual ET_if eif;
  
  function new(virtual ET_if eif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.eif = eif;
    drv.eif = this.eif;
    mon.eif = this.eif;
    
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
  ET_if eif(clk);
  Encryption_Top dut(eif.clk, eif.reset, eif.data_valid_in, eif.cipherkey_valid_in, eif.cipher_key, eif.valid_out, eif.cipher_text, eif.cipher_key_out);
  
  initial begin
    clk <= 0;
  end
  
  always #5 clk = ~clk;
  
  initial begin
    env = new(eif);
    env.gen.count = 5000;
    env.run();
  end
endmodule