(load "mk/test-check.scm")
(load "evalo-standard.scm")

(test 'first-love
  (run 1 (q) (evalo q '(I love you)))
  '(('(I love you))))

(define file-name "challenge-1-generated-expressions.scm")
(if (file-exists? file-name)
  (printf "Delete ~s if you'd like to regenerate it.\n" file-name)
  (begin
    (printf "Generating 99000 expressions that evaluate to '(I love you).\n")
    (printf "Give it a minute or so.\n")
    (time
      (with-output-to-file
        file-name
        (lambda () (pretty-print (run 99000 (q) (evalo q '(I love you)))))))
    (printf "Generated expressions written to: ~s\n" file-name)))
