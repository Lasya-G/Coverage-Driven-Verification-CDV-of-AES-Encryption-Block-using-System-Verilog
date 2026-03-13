# Coverage-Driven-Verification-CDV-of-AES-Encryption-Block-using-System-Verilog

AES (Advanced Encryption Standard) employs a substitution-permutation network, which consists of a series of linked mathematical operations to transform plaintext into ciphertext and vice versa.

Methodology of AES:  
- Key Expansion: The initial key is expanded into an array of key schedule words. These keys are used in each round.
- Initial Round:
    - AddRoundKey: Each byte of the state is combined with a block of the round key using bitwise XOR.
- Main Rounds:
  - SubBytes: Each byte in the state is replaced with a corresponding byte from a fixed substitution (S-box) table.
  - ShiftRows: The bytes in each row of the state are cyclically shifted to the left.
  - MixColumns: Each column of the state is transformed using a linear transformation to provide diffusion.
  - AddRoundKey: Another round key is added to the state.


- Final Round: Similar to the main rounds but without the MixColumns step.
