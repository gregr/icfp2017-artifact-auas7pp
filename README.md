# Functional Pearl: A Unified Approach to Solving Seven Programming Problems

http://icfp17.sigplan.org/event/icfp-2017-papers-functional-pearl-a-unified-approach-to-solving-seven-programming-problems

Try out the examples while reading the paper.

The paper and pre-built Docker image:
https://dl.acm.org/citation.cfm?id=3110252

The io.livecode.ch version of the paper:
http://io.livecode.ch/learn/namin/icfp2017-artifact-auas7pp

The io.livecode.ch miniKanren tutorial:
http://io.livecode.ch/learn/webyrd/webmk

You can also follow along with the paper by running the challenge examples locally.  You can either install Chez Scheme and clone this repo, or use the Docker image.


### Setup for local running

If you'd like to use Docker, read [SETUP-DOCKER-EVAL.md](https://github.com/gregr/icfp2017-artifact-auas7pp/blob/master/SETUP-DOCKER-EVAL.md).

To run with from this repo directly with Chez Scheme installed, make sure to first `cd src`.

If you'd like to install Chez yourself, you can find it here, with build instructions: https://cisco.github.io/ChezScheme/#get.  You can also try to figure out how to install it by reading our [Dockerfile](https://github.com/gregr/icfp2017-artifact-auas7pp/blob/master/Dockerfile).


### Review the challenge files

Each challenge file corresponds to a numbered section of the paper, testing each of its examples.  Some files contain an extended set of examples, demonstrating variations and capabilities that we didn't have space for in the paper.

Most examples are run as tests, and appear with their expected output.  The meatier examples are also timed to assess performance.  Any test failures will appear loud and clear in the test run output.  When applicable, timings will also appear, along with other resource usage statistics.


#### Challenge 1

Generate 99000 ways to say `'(I love you)`.  We do this by setting the expected result of `evalo` while leaving the input program unconstrained.


#### Challenge 2

Generate quines, twines, and thrines.  To keep the test suite fast, we use `evalo-small.scm` for performant generation of the twines and thrines.

There's also an extra-slow version of this challenge that we don't recommend running unless you're really adventurous.  It is not run as part of the normal test suite.  It uses `evalo-standard.scm` even for finding twines and thrines.  While it will likely find a twine after a few minutes, your machine may not have enough resources for it to find a thrine in a reasonable amount of time.


#### Challenge 3

Generate 100 expressions that evaluate to `42` under lexical scope, and `137` under dynamic scope.

Look at `evalo-scoping.scm` to see the correspondence between inference rules and their implementation as a relation, as shown in the paper.


#### Challenge 4

Treat function definitions (such as `append`) relationally.  Aside from inferring inputs from outputs, this also enables inference of code: program synthesis.  We demonstrate several examples of program synthesis, including some we couldn't fit in the paper.


#### Challenge 5

Refute erroneous function definitions, even if you haven't finished writing them.  Once failure is detected, judicious relaxation of sub-expressions (replacing them with holes) can help you diagnose the mistake.


#### Challenge 6

Use a proof-checking function as an automated theorem prover for free.  We choose a couple interesting theorems to prove, then send it into logician mode, asking it to prove everything it can, from scratch.


#### Challenge 7

Generate a quine that uses quasiquote instead of list or cons, even if the host language doesn't support it.  In Scheme, we define a small interpreter that does support quasiquote, then run it relationally within `evalo`.


### Continue exploring

#### Review the relational interpreter implementations

We've included a few versions of the relational interpreter (`evalo`).

* `evalo-scoping.scm`, containing `eval-lexo` and `eval-dyno`, used in the lexical vs. dynamic scope examples.
* `evalo-small.scm`, which supports fewer language constructs than the standard interpreter, reducing the branching factor, improving performance when generating quines, twines, and thrines.
* `evalo-standard.scm`, implementing a reasonable subset of pure Scheme.
* `evalo-optimized.scm`, containing a more complicated implementation of the standard interpreter with several optimizations.


#### Try your own examples

Edit and re-run some examples to validate output (e.g. intentionally change queries or their expected outputs to break tests and see their output for yourself).  Each challenge may be run independently: `scheme --script challenge-N.scm` for any N in {1..7}


#### Freestyle interaction

If you'd like to run your own tests directly in the REPL, run `scheme`, then load an appropriate definition of `evalo` before running any queries.

For example:

```
(load "evalo-standard.scm")
```

If you'd like to experiment with program synthesis, you probably want to use the optimized interpreter with the `allow-incomplete-search?` flag set:

```
(load "evalo-optimized.scm")
(set! allow-incomplete-search? #t)
```

Of course, do not set this flag if you intend to prove that there are a finite number of answers to your query.  You need a complete search to be certain of that.
