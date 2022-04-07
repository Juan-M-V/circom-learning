pragma circom 2.0.0;

template multiplier() {
	// Signals.
	signal input in1;
	signal input in2;
	signal output out;

	// Statements.
	out <== in1 * in2;
}

template powN(N) {
	signal input in;
	signal output out;
	component comp[N-1];

	for (var i = 0; i < N - 1; i++) {
		comp[i] = multiplier();
	}

	// Assign values to component.
	comp[0].in1 <== in;
	comp[0].in2 <== in;
	for (var i = 0; i < N - 2; i++) {
		// Feed values to the next component.
		comp[i+1].in1 <== comp[i].out;
		comp[i+1].in2 <== in;
	}

	out <== comp[N-2].out;
}

component main {public [in]} = powN(4);
