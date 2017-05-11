(load "mk/test-check.scm")
(load "evalo-standard.scm")

(test 'first-love
  (run 1 (q) (evalo q '(I love you)))
  '(('(I love you))))

(define file-name "challenge-1-generated-expressions.scm")
(printf "Generating 99000 expressions that evaluate to '(I love you)\n")
(time
  (call-with-output-file
    file-name
    (lambda (port)
      (pretty-print (run 99000 (q) (evalo q '(I love you)))
                    port))))
(printf "Generated expressions written to: ~s\n" file-name)
