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

(printf "Challenge 3: generate 100 expressions that evaluate to 42 under lexical scope, and 137 under dynamic scope.\n")
(time
  (run 100 (expr)
    (eval-dyno expr 137)
    (eval-lexo expr 42)))
