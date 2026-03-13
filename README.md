# Coverage-Driven-Verification-CDV-of-AES-Encryption-Block-using-System-Verilog

AES (Advanced Encryption Standard) employs a substitution-permutation network, which consists of a series of linked mathematical operations to transform plaintext into ciphertext and vice versa.

<p align="center">
<img width="300" height="500" alt="image" src="https://github.com/user-attachments/assets/93f532a7-44f6-49d7-81af-5a07d6865317" />
<p>

## Methodology of AES: 
### Key Expansion: 
- The AES Encryption process starts with Key Expansion where all the required round keys are generated depending on the input length (128 bits here) referred to as cipher key. So, in our case 10 round keys(one key for each round) are generated for a key length of 128 based on the formula - *No. of rounds = (Key length/32) + 6*.
### Initial Round:
#### AddRoundKey:
- AddRoundKey involves combining the current state of the data with a round key using the bitwise XOR operation. The round keys are derived from the initial cipher key through a process known as key expansion. The purpose of AddRoundKey is to mix the data with the key material in a way that is computationally infeasible to reverse without knowledge of the key.  
### Main Rounds:
#### Substitution Bytes: 
- **S-box**: It is the substitution table. Each byte is substituted by another byte.
- **Sub-Bytes**: Inthis, depending on number of bytes in data, every byte of data is replaced with a corresponding byte from the fixed substitution (S-box) table.    
#### ShiftRows: 
- The bytes in each row of the state are cyclically shifted to the left. If the input of shift rows is considered as a state matrix with each element being the byte of the input, then the output will be the state matrix as shown in the image below:
  
<img width="230" height="183" alt="image" src="https://github.com/user-attachments/assets/77291882-d406-4645-b22a-b27124b50073" /> <img width="585" height="183" alt="image" src="https://github.com/user-attachments/assets/9d7a46e3-31dd-4cfe-8067-fc22afa25dd4" />

#### MixColumns:
- Each column of the state is transformed using a linear transformation to provide diffusion.
- Each 4-byte column is considered as a vector and multiplied by a fixed 4×4 matrix. The matrix contains constant entries. For example, we show how the first four output bytes are computed:  
  <img width="368" height="136" alt="image" src="https://github.com/user-attachments/assets/d9a3e321-d16c-4c45-8e68-f29e9d338dd1" />

#### AddRoundKey:
- AddRoundKey involves combining the current state of the data with a round key using the bitwise XOR operation.

### Final Round:
- Similar to the main rounds but without the MixColumns step.
### RoundKeyGen:
- First, the input key is stored in a first-stage register and the valid_in signal is passed through to the next stage. Then, the key is stored in a second-stage register, and the valid_in signal is passed through to the next stage. The least significant word of the key is rotated, and the result is stored in a register. The SubBytes operation is performed on the result of the rotation operation in parallel with the second-stage register. The round key is calculated using the second-stage key, the result of the SubBytes operation, and the round constant word and so on. Finally, the delayed round key is stored in the output register, and the valid_out signal is passed through to the output.

## Verification Plan:

- Tools used: QuestaSim
- Verification Language: System Verilog
- Methodology: Layered TestBench

#### S-Box:
- Description of Design: The always block uses the positive edge of the clk and the negative edge of the reset signal. In this design the reset signal is low level signal i.e. whenever the reset is set to 0 the output is set to 0. Whenever the valid_in signal is high, the case statements execute depending on the addr, which is an input signal to this dut, the dout value is assigned.
- Possible Test Cases:
  - reset: Reset is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - valid_in: valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - addr: addr is an 8-bit port. So, 2^8 = 256 possible values are applied to get the 100% coverage.

#### Sub-Bytes:
 - Description of the design: The always block uses the positive edge of the clk and the negative edge of the reset signal. In this design the reset signal is low level signal i.e. whenever the reset is set to 0 the output is set to 0. And when the reset is set to 1 the valid_in is assigned to the valid_out. In this dut, s_box module is generated number of byte times which is 16. The data_in has width of 128 bits, so the number of bytes will be 16. For each input byte using s_box module a byte of data_out value is assigned.
 - Possible Test Csaes:
  - reset: Reset is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - valid_in: valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage
  - data_in: data_in is a 128-bit port. The range of data_in is divided into 512 bins. If all the groups are hit, then coverage is 100%.

#### Shift Rows:
- Description of the design: The always block uses the positive edge of the clk and the negative edge of the reset signal. In this design the reset signal is low level signal i.e. whenever the reset is set to 0 the output is set to 0. And when the reset is set to 1 the valid_in is assigned to the valid_out, states are assigned to the data_out in the manner which we discussed in the previous section. The states here are data_in values and each of the state is of 8-bits.
- Possible Test Cases:
  - reset: Reset is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - valid_in: valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - data_in: data_in is a 128-bit port. The range of data_in is divided into 512 bins. If all the groups are hit, then coverage is 100%.

#### MixColumns:
- Description of the design: The always block uses the positive edge of the clk and the negative edge of the reset signal. In this design the reset signal is low level signal i.e. whenever the reset is set to 0 the data_out and valid_out are set to 0. Whenever the valid_in signal is high, mixColumn computations are performed on the input state bits using already generated "State_Mulx2" and "State_Mulx3" arrays and final values are assigned to data_out. Also, valid_in is assigned to valid_out.
- Possible Test Cases:
    - reset – Reset is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
    - valid_in: valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
    - data_in: This is of 128 bit data obtained from shiftrows layer. The range of data_in is divided into 512 bits and coverage of 100% is obtained.

#### RoundKeyGen:
- Possible Test Cases:
  - Reset: Apply both 1 and 0 to this signal to get 100% coverage.
  - valid_in: apply both 0 and 1 to get 100% coverage.
  - RCON_Word: The range is divided into 128 bins. If all groups are hit, then coverage is 100%.
  - Key: The range is divided into 512 bins. If all groups are hit, then 100% coverage is achieved.

#### Round:
- Possible Test Cases:
  - Reset: Apply both 0 and 1 to get 100% coverage.
  - Data_valid_in: Apply both 0 and 1 to get 100% coverage.
  - Key_valid_in: Apply both 0 and 1 to get 100% coverage.
  - Data_in: The range is divided into 512 bins. If all groups are hit, then coverage is 100%.
  - Round_key: The range is divided into 512 bins. If all groups are hit, then coverage is 100%.

#### AddRoundKey:
- Possible Test Cases:
  - Reset: Apply both 1 and 0 to achieve 100% coverage.
  - Data_valid_in: Apply both 0 and 1 to get 100% coverage.
  - Key_valid_in: Apply both 0 and 1 to get 100% coverage.
  - Data_in: The range is divided into 512 bins. If all groups are hit, then coverage is 100%.
  - Round_key: The range is divided into 512 bins. If all groups are hit, then coverage is 100%.

#### Key Expansion:
- Description of the design: RoundKeyGen is instantiated for the first time to get the first 128 bit word array and the next 9 round keys are generated using a for loop and the initially generated word array. Finally all these word arrays are concatenated to get the final output word of length 128*10.
- Possible Test Cases:
  - reset – Reset is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - valid_in – valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - cipher_key – The range of data_in is divided into 512 bits and coverage of 100% is obtained.
 
#### Encryption Top:
- Description of the design: This module takes input plain text and cipher text, does all the above operations, uses some shift registers to accomodate the delays and finally outputs 128 bit cipher key .
- Possible Test Cases:
  - reset – Reset is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - data_valid_in – data_valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - cipherkey_valid_in – cipherkey_valid_in is a 1-bit port. Both 1 and 0 are applied to get the 100% coverage.
  - plain_text – The range of plain_text is divided into 512 bits and coverage of 100% is obtained.
  - cipher_key – The range of cipher_key is divided into 512 bits and coverage of 100% is obtained.
 
## Conclusion:
To ensure the robustness and correctness of the AES encryption implementation, we have meticulously tested all the submodules within the Encryption Top Module. The submodules, which include S_BOX, Shift Rows, Sub Bytes, Mix Columns, Round Key Gen, Add Round Key,Round and Key Expansion, were developed in Verilog. Each submodule has been subjected to exhaustive testing across all possible input combinations to validate their functionality. This rigorous verification process employed the Coverage Driven Verification (CDV) methodology by making use of QuestaSim Simulator.
