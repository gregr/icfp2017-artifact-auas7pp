(load "mk/test-check.scm")
(load "evalo-standard.scm")

(test 'first-love
  (run 1 (q) (evalo q '(I love you)))
  '(('(I love you))))

(define file-name "generated-by-challenge-1.scm")
(printf "Generating 99000 expressions that evaluate to '(I love you).\n")
(printf "Give it a minute or so.\n")
(time
  (with-output-to-file
    file-name
    (lambda () (pretty-print (run 99000 (q) (evalo q '(I love you)))))
    'replace))
(printf "Generated expressions written to: ~s\n" file-name)
