(load "mk/test-check.scm")
(load "evalo-standard.scm")

(define expected-quine
  '((lambda (_.0) (list _.0 (list 'quote _.0)))
    '(lambda (_.0) (list _.0 (list 'quote _.0)))))

(test 'validate-quine
  (eval expected-quine)
  expected-quine)

(time
  (test 'fourth-quine-standard
    (run 4 (e) (evalo e e))
    `((_.0 (num _.0))
      (#t)
      (#f)
      (,expected-quine
       (=/= ((_.0 closure)) ((_.0 list)) ((_.0 prim)) ((_.0 quote)))
       (sym _.0)))))

(time
  (test 'nontrivial-quine-standard
    (run 1 (e)
      (fresh (a d)
        (== `(,a . ,d) e)
        (evalo e e)))
    `((,expected-quine
        (=/= ((_.0 closure)) ((_.0 list)) ((_.0 prim)) ((_.0 quote)))
        (sym _.0)))))


(load "evalo-small.scm")

;; A smaller interpreter finds quines, twines, and thrines very quickly.

(time
  (test 'quine-fast
    (run 1 (e) (evalo e e))
    `((,expected-quine
        (=/= ((_.0 closure)) ((_.0 list)) ((_.0 quote)))
        (sym _.0)))))

(time
  (test 'twine
    (run 1 (p q)
      (=/= p q)
      (evalo p q)
      (evalo q p))
    '((('((lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))
          '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0)))))
        ((lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))
         '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))))
       (=/= ((_.0 closure)) ((_.0 list)) ((_.0 quote)))
       (sym _.0)))))

(time
  (test 'thrine
    (run 1 (p q r)
      (=/= p q)
      (=/= p r)
      (=/= q r)
      (evalo p q)
      (evalo q r)
      (evalo r p))
    '(((''((lambda (_.0) (list 'quote (list 'quote (list _.0 (list 'quote _.0)))))
           '(lambda (_.0) (list 'quote (list 'quote (list _.0 (list 'quote _.0))))))
        '((lambda (_.0) (list 'quote (list 'quote (list _.0 (list 'quote _.0)))))
          '(lambda (_.0) (list 'quote (list 'quote (list _.0 (list 'quote _.0))))))
        ((lambda (_.0) (list 'quote (list 'quote (list _.0 (list 'quote _.0)))))
         '(lambda (_.0) (list 'quote (list 'quote (list _.0 (list 'quote _.0)))))))
       (=/= ((_.0 closure)) ((_.0 list)) ((_.0 quote)))
       (sym _.0)))))
