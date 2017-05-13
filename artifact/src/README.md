## Validate Challenge Examples

To validate examples related to the challenges from the paper, enter `scheme --script all-challenges.scm`.

Some of the challenge examples write their output to file for more convenient examination.  The names of these files will be displayed during the validation run, and will be of the form `generated-by-challenge-[1-7].scm`.

If you'd like to consider variations on the provided examples, or intentionally break the tests, modify the challenge files (named `challenge-[1-7].scm`).


## Freestyle Interaction

Enter `scheme` and load an `evalo` definition of your choice for interactive use (each lives in a separate `evalo-X.scm` file).

When using `evalo-optimized` for synthesis, you should probably also run:

```
(set! allow-incomplete-search? #t)
```

Of course, do not set this if you intend to prove that there are a finite number of answers to your query.
