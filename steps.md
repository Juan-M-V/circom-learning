# Circom: from writing to proving circuits.

## Generate and compute the circuit.
- Generate the rank 1 constraint system (r1cs).

`circom multiplier2.circom --r1cs --wasm`

- Compute the witness.

`node generate_witness.js multiplier2.wasm input.json witness.wtns`

## Prove the circuit.

Using `snarkjs` we'll prove the circuit through the Groth16 zk-SNARK protocol.

### Powers of Tau ceremony.
- Circuit independent.

`snarkjs powersoftau new bn128 12 pot12_0000.ptau -v`

`snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v`

- Circuit dependent.

`snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v`

- Generate zkey.

`snarkjs groth16 setup multiplier2.r1cs pot12_final.ptau multiplier2_0000.zkey`

`snarkjs zkey contribute multiplier2_0000.zkey multiplier2_0001.zkey --name="1st Contributor Name" -v`

- Export zkey.

`snarkjs zkey export verificationkey multiplier2_0001.zkey verification_key.json`

- Generate the proof.

`snarkjs groth16 prove multiplier2_0001.zkey witness.wtns proof.json public.json`
