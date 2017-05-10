(load "mk/test-check.scm")
(load "evalo-standard.scm")

;; The small interpreter finds quines, twines, and thrines very quickly.  If
;; you want to stress your machine, use the standard interpreter instead for
;; its larger branching factor.  The first twine should appear after several
;; minutes.  Finding the first thrine will be much, much more computationally
;; expensive.

(printf "WARNING!  This will take a long time and a lot of memory!\n")

(time
  (test 'twine-slow
    (run 1 (p q)
      (=/= p q)
      (evalo p q)
      (evalo q p))
    '((('((lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))
          '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0)))))
        ((lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))
         '(lambda (_.0) (list 'quote (list _.0 (list 'quote _.0))))))
       (=/= ((_.0 closure)) ((_.0 list)) ((_.0 prim)) ((_.0 quote)))
       (sym _.0)))))

(time
  (test 'thrine-super-duper-slow
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
       (=/= ((_.0 closure)) ((_.0 list)) ((_.0 prim)) ((_.0 quote)))
       (sym _.0)))))
