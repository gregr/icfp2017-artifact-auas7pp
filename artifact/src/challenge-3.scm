(load "mk/test-check.scm")
(load "evalo-scoping.scm")

(test 'first-expression-dynamic-and-lexical
  (run 1 (expr)
    (eval-dyno expr 137)
    (eval-lexo expr 42))
  '((((lambda (_.0)
        (((lambda (_.0)
            (lambda (_.1) _.0))
          42)
         _.2))
      137)
     (=/= ((_.0 _.1)) ((_.0 lambda))) (num _.2) (sym _.0 _.1))))

(define file-name "generated-by-challenge-3.scm")
(if (file-exists? file-name)
  (printf "Delete ~s if you'd like to regenerate it.\n" file-name)
  (begin
    (printf "Generating 100 expressions that evaluate to 42 under lexical scope, and 137 under dynamic scope.\n")
    (time
      (with-output-to-file
        file-name
        (lambda ()
          (pretty-print
            (run 100 (expr)
              (eval-dyno expr 137)
              (eval-lexo expr 42))))))
    (printf "Generated expressions written to: ~s\n" file-name)))
