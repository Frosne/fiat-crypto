[![Build Status](https://api.travis-ci.org/mit-plv/fiat-crypto.png?branch=master)](https://travis-ci.org/mit-plv/fiat-crypto)

Fiat-Crypto: Synthesizing Correct-by-Construction Code for Cryptographic Primitives
=====

Build Requirements
-----
This repository requires:
- To build the proofs and almost-C-like outputs: [Coq 8.7](https://github.com/coq/coq/releases/tag/V8.7.2) or [Coq 8.8](https://github.com/coq/coq/releases/tag/V8.8.0) (tested with 8.7.2, 8.8.0)

If you checked out this repository via `git`, you should run

    git submodule update --init --recursive

To build (if your COQPATH variable is empty):

	make

To build:

	export COQPATH="$(pwd)/coqprime${COQPATH:+:}$COQPATH"
	make

You may get non-fatal errors such as `make: execvp: /bin/sh: Argument list too long`; this is an artifact of the [old pipeline](#old-pipeline) and is a [bug in Coq](https://github.com/coq/coq/issues/7584) that will prevent `make install` from succeeding, but will not impact the build itself.

New Pipeline
-----
The new pipeline (nearly finished) generates binaries that take in arguments on the command line and print out C code on stdout.

A collection of C files can be made with

    make c-files

The C files will appear in the top-level directory.

The binaries generating these C files can be made with

    make standalone

or `make standalone-haskell` or `make standalone-ocaml` for binaries generated with just one compiler.

The binaries are located in

    src/Experiments/NewPipeline/ExtractionOCaml/

or

    src/Experiments/NewPipeline/ExtractionHaskell/

The binaries are:

 - `saturated_solinas`
 - `unsaturated_solinas`
 - `word_by_word_montgomery`

Passing no arguments, or passing `-h` or `--help` (or any other invalid arguments) will result in a usage message being printed.  These binaries output C code on stdout.

Here are some examples of ways to invoke the binaries (from the directories that they live in):

    # Generate code for 2^255-19
    ./unsaturated_solinas '25519' '5' '2^255' '1,19' '64' carry_mul carry_square carry_scmul121666 carry add sub opp selectznz to_bytes from_bytes > curve25519_64.c
    ./unsaturated_solinas '25519' '10' '2^255' '1,19' '32' carry_mul carry_square carry_scmul121666 carry add sub opp selectznz to_bytes from_bytes > curve25519_32.c

    # Generate code for NIST-P256 (2^256 - 2^224 + 2^192 + 2^96 - 1)
    ./word_by_word_montgomery 'p256' '2^256' '2^224,1;2^192,-1;2^96,-1;1,1' '32' > p256_32.c
    ./word_by_word_montgomery 'p256' '2^256' '2^224,1;2^192,-1;2^96,-1;1,1' '64' > p256_64.c

Old Pipeline
----

To build a representative subset, instead of `make`, run

        make selected-specific-display non-specific

The core library (target `nonautogenerated-specific-display non-specific`) is expected to build within about one hour (in serial, on a particularly fast machine), within about 3.5--4 GB of RAM, plus an additional 1-5 minutes to run `coqdep` on all of our files.  Of the additional curves, 90% finish within 5 minutes per file, and 99% finish within 15 minutes per file (though some take upwards of 50 GB of RAM).  These 99% of curves together take about 60 hours.

- To build the C outputs: Python (2 or 3)

To build:

        make c

or, for a representative subset,

        make selected-c

- To build and run the binaries, gcc (7.1.2; or 7.1.1 with `-fno-peephole2`) or clang of a new enough version to support the appropriate compiler intrinsics.

To build and run:

        make test bench

or, for a representative subset,

        make selected-test selected-bench

Exploring the code
-----

### Push-button synthesis

To add a new prime, add a new line to [`primes.txt`](https://github.com/mit-plv/fiat-crypto/blob/master/primes.txt) with your prime.  Then run

        ./generate_parameters.py; ./src/Specific/CurveParameters/remake_curves.sh

You will see a bunch of lines starting with `git add`; any `.v` files that show up in these lines must be added to `_CoqProject`.  (If you are working in the git repository, you may simply run the `git add` lines, and then run `make update-_CoqProject`.)  Note that the directory structure involves a textual representation of your prime, call it `${REPRESENTATION_OF_YOUR_PRIME}`.  To build, you can run

        make src/Specific/{montgomery,solinas}{32,64}_${REPRESENTATION_OF_YOUR_PRIME}/fibe

This will build all the necessary `.vo` and `.c` files, as well as the `fibe` binary, which is automatically run when you `make bench` or `make test`.

### Curve Correctness Theorems

Specifications live in [`src/Spec`](./src/Spec), e.g., [`src/Spec/Ed25519.v`](./src/Spec/Ed25519.v).
Some selected cuve-level proofs live in
- [`src/Curves/Edwards/AffineProofs.v`](./src/Curves/Edwards/AffineProofs.v),
- [`src/Curves/Edwards/XYZT/Basic.v`](./src/Curves/Edwards/XYZT/Basic.v),
- [`src/Curves/Montgomery/AffineProofs.v`](./src/Curves/Montgomery/AffineProofs.v),
- [`src/Curves/Montgomery/XZProofs.v`](src/Curves/Montgomery/XZProofs.v).

### Arithmetic Core

Generic mathematical optimization strategies live in [`src/Arithmetic`](./src/Arithmetic).
Good examples include
- [`src/Arithmetic/Core.v`](src/Arithmetic/Core.v),
- [`src/Arithmetic/Karatsuba.v`](src/Arithmetic/Karatsuba.v),
- [`src/Arithmetic/Saturated/Core.v`](./src/Arithmetic/Saturated/Core.v),
- [`src/Arithmetic/BarrettReduction/HAC.v`](./src/Arithmetic/BarrettReduction/HAC.v),
- [`src/Arithmetic/MontgomeryReduction/Definition.v`](./src/Arithmetic/MontgomeryReduction/Definition.v),
- [`src/Arithmetic/MontgomeryReduction/WordByWord/Abstract/Definition.v`](./src/Arithmetic/MontgomeryReduction/WordByWord/Abstract/Definition.v).

### Demo of Synthesis

The idea of the synthesis process is demoed in [`src/Demo.v`](./src/Demo.v).

### Actual Synthesis

- The curve-non-specific synthesis framework lives in [`src/Compilers/Z/Bounds/Pipeline`](./src/Compilers/Z/Bounds/Pipeline).
- The API for the reflective simplification and bounds analysis pipeline is in [`src/Compilers/Z/Bounds/Pipeline.v`](./src/Compilers/Z/Bounds/Pipeline.v).
- The definition of the pipeline and the correctness proof are in [`src/Compilers/Z/Bounds/Pipeline/Definition.v`](./src/Compilers/Z/Bounds/Pipeline/Definition.v).
- Generic reflective syntax trees are defined in [`src/Compilers/Syntax.v`](./src/Compilers/Syntax.v); the specialization to the arithmetic operations on Z that we use occurs in [`src/Compilers/Z/Syntax.v`](./src/Compilers/Z/Syntax.v).
- The trusted pretty-printer lives in [`src/Compilers/Z/CNotations.v`](./src/Compilers/Z/CNotations.v) and [`src/Compilers/Z/HexNotationConstants.v`](./src/Compilers/Z/HexNotationConstants.v), which were generated by the couple-hundred-line Python scripts in a comment near the top of each file.
- The core of the bounds-analysis transformation lives in [`src/Compilers/Z/Bounds/Interpretation.v`](./src/Compilers/Z/Bounds/Interpretation.v); the corresponding proofs live in [`src/Compilers/Z/Bounds/InterpretationLemmas`](./src/Compilers/Z/Bounds/InterpretationLemmas), and the instantation of the bounds-analysis transformation with the core lives in [`src/Compilers/Z/Bounds/MapCastByDeBruijn.v`](./src/Compilers/Z/Bounds/MapCastByDeBruijn.v).


The curve-specific synthesis framework lives in [`src/Specific/Framework`](./src/Specific/Framework).
- The input `.json` files live in [`src/Specific/CurveParameters`](./src/Specific/CurveParameters), and the processor for those files lives in [`src/Specific/Framework/make_curve.py`](./src/Specific/Framework/make_curve.py).
- The record of curve specific parameters is defined in [`src/Specific/Framework/RawCurveParameters.v`](./src/Specific/Framework/RawCurveParameters.v), and defaults are filled in [`src/Specific/Framework/CurveParameters.v`](src/Specific/Framework/CurveParameters.v).
- The tactics that specialize the various arithmetic optimizations to specific curves live in [`src/Specific/Framework/ArithmeticSynthesis`](./src/Specific/Framework/ArithmeticSynthesis), e.g., [`src/Specific/Framework/ArithmeticSynthesis/Montgomery.v`](./src/Specific/Framework/ArithmeticSynthesis/Montgomery.v).
- The script at [`src/Specific/Framework/ArithmeticSynthesis/remake_packages.py`](./src/Specific/Framework/ArithmeticSynthesis/remake_packages.py) processes these files to add relevant boilerplate, and gets run after significantly changing an optimization, or after adding a new optimization.
- The synthesis tactics are assembled in [`src/Specific/Framework/SynthesisFramework.v`](./src/Specific/Framework/SynthesisFramework.v).
Note that magic<a name="magic-ref">[¹](#magic)</a> is used to create identifiers refering to the curve-specific parameters, from tactics, so that they can be used in other curve-specific files.

### Example Output

The c output lives in the various subfolders of [`src/Specific`](./src/Specific).  For example, C-like code for X25519 multiplication on 64-bit machines lives in [`src/Specific/X25519/C64/femulDisplay.log`](./src/Specific/X25519/C64/femulDisplay.log), which is generated from [`src/Specific/X25519/C64/femulDisplay.v`](./src/Specific/X25519/C64/femulDisplay.v), which in turn uses synthesis run in [`src/Specific/X25519/C64/femul.v`](./src/Specific/X25519/C64/femul.v).  The `c` target turns this into `src/Specific/X25519/C64/femul.c`.

## Footnotes
<a name="magic">[¹](#magic-ref)</a> This magic comes in the form of calls to `transparent_abstract`, packaged up in some tactics in [`src/Util/Tactics/CacheTerm.v`](./src/Util/Tactics/CacheTerm.v).
