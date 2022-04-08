MAIN_FILE := polynomial-root
WASM_DIR := $(MAIN_FILE)_js
INPUT := input.json
FLAGS := --r1cs --wasm

default:
	circom $(MAIN_FILE).circom $(FLAGS)
	cp $(INPUT) $(WASM_DIR)
	mv $(MAIN_FILE).r1cs $(WASM_DIR)
	cd $(WASM_DIR) && \
	echo entered $(PWD) && \
	node generate_witness.js $(MAIN_FILE).wasm input.json witness.wtns && \
	snarkjs powersoftau new bn128 12 pot12_0000.ptau -v && \
	snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="1234" && \
	snarkjs powersoftau contribute pot12_0001.ptau pot12_0002.ptau --name="First contribution" -v -e="1234" && \
	snarkjs powersoftau prepare phase2 pot12_0002.ptau pot12_final.ptau -v && \
	snarkjs groth16 setup $(MAIN_FILE).r1cs pot12_final.ptau $(MAIN_FILE)_0000.zkey && \
	snarkjs zkey contribute $(MAIN_FILE)_0000.zkey $(MAIN_FILE)_0001.zkey --name="1st Contributor Name" -v -e='1234' && \
	snarkjs zkey export verificationkey $(MAIN_FILE)_0001.zkey verification_key.json && \
	snarkjs groth16 prove $(MAIN_FILE)_0001.zkey witness.wtns proof.json public.json

prove: verification_key.json proof.json public.json
	cd $(WASM_DIR)
	snarkjs groth16 verify verification_key.json public.json proof.json

clean:
	rm -rf $(WASM_DIR)
