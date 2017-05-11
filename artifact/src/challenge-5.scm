(load "mk/test-check.scm")
(load "evalo-optimized.scm")
(set! allow-incomplete-search? #f)

(time
  (test 'shallow-remove-refutation-full
    (run 1 (A B C)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) (cons ,A ,B)]
                        .
                        ,C))))
           (list (remove 'foo '())
                 (remove 'foo '(foo))
                 (remove 'foo '(1))
                 (remove 'foo '(2 foo 3))
                 (remove 'foo '((4 foo) foo (5 (foo 6 foo)) foo 7 foo (8)))))
        '(() () (1) (2 3) ((4 foo) (5 (foo 6 foo)) 7 (8)))))
    '()))

(time
  (test 'shallow-remove-refutation-minimal
    (run 1 (A B C)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) (cons ,A ,B)]
                        .
                        ,C))))
           (list (remove 'foo '(foo))))
        '(())))
    '()))

(time
  (test 'shallow-remove-relaxation-1-unsatisfiable
    (run 1 (A B C D)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) ,D] ;; Relaxing this clause doesn't help.
                        [(equal? (car ls) x) (cons ,A ,B)]
                        .
                        ,C))))
           (list (remove 'foo '(foo))))
        '(())))
    '()))

(time
  (test 'shallow-remove-relaxation-2-satisfiable
    (run 1 (A B C)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) ,A] ;; Relaxing this clause helps.
                        .
                        ,C))))
           (list (remove 'foo '(foo))))
        '(())))
    '((('() _.0 _.1)))))

(time
  (test 'deep-remove-refutation-full
    (run 1 (A B)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) ,A]
                        [else (cons (car ls) ,B)]))))
           (list (remove 'foo '())
                 (remove 'foo '(foo))
                 (remove 'foo '(1))
                 (remove 'foo '(2 foo 3))
                 (remove 'foo '((4 foo) foo (5 (foo 6 foo)) foo 7 foo (8)))))
        '(() () (1) (2 3) ((4) (5 (6)) 7 (8)))))
    '()))

(time
  (test 'deep-remove-refutation-minimal
    (run 1 (A B)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) ,A]
                        [else (cons (car ls) ,B)]))))
           (list (remove 'foo '((4 foo) foo (5 (foo 6 foo)) foo 7 foo (8)))))
        '(((4) (5 (6)) 7 (8)))))
    '()))

(time
  (test 'deep-remove-relaxation-satisfiable
    (run 1 (A B C)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) ,A]
                        [else (cons ,C ,B)])))) ;; What does this hole suggest?
           (list (remove 'foo '((4 foo) foo (5 (foo 6 foo)) foo 7 foo (8)))))
        '(((4) (5 (6)) 7 (8)))))
    '(((_.0 '((5 (6)) 7 (8)) '(4))))))

(time
  (test 'deep-remove-initial-repair-satisfiable
    (run 1 (A B C)
      (evalo
        `(letrec ((remove
                    (lambda (x ls)
                      (cond
                        [(null? ls) '()]
                        [(equal? (car ls) x) ,A]
                        [(pair? (car ls)) ,B] ;; Handle the missing case.
                        [else (cons (car ls) ,C)]))))
           (list (remove 'foo '((4 foo) foo (5 (foo 6 foo)) foo 7 foo (8)))))
        '(((4) (5 (6)) 7 (8)))))
    '(((_.0 '((4) (5 (6)) 7 (8)) _.1)))))
