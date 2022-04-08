pragma circom 2.0.0;

template multiplier() {
	// Signals.
	signal input in1;
	signal input in2;
	signal output out;

	// Statements.
	/*
	out === in1 * in2; assertion
	out <-- in1 * in2; assignment
	*/
	out <== in1 * in2;
}

template powN(N) {
	signal input in;
	signal output out;
	component comp[N-1];

	if (N > 1) {
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
	} else if (N) {
		out <== in;
	} else {
		out <== 1;
	}
}

template summation(N) {
	signal input in[N];
	signal output out;

	var ret = in[0];
	for (var i = 1; i < N; i++) {
		ret += in[i];
	}

	out <== ret;
}

template evalPoly(N) {
	signal input coefs[N + 1];
	signal input x;
	signal output out;
	component powers[N];
	component mults[N];
	component sumAll = summation(N + 1);

	for (var i = 0; i < N; i++) {
		powers[i] = powN(N - i);
		mults[i] = multiplier();

		powers[i].in <== x;
		mults[i].in1 <== powers[i].out;
		mults[i].in2 <== coefs[i];
	}

	for (var i = 0; i < N; i++) {
		sumAll.in[i] <== mults[i].out;
	}

	sumAll.in[N] <== coefs[N];
	//log(sumAll.out);

	out <== sumAll.out;
}
	
template isRoot(N) {
	signal input coefs[N + 1];
	signal input root;
	signal output out;
	
	component ev = evalPoly(N);
	for (var i = 0; i < N + 1; i++) {
		ev.coefs[i] <== coefs[i];
	}
	ev.x <== root;

	assert(ev.out == 0);
	out <== ev.out;
}

component main = summation(2);
