(load "mk/test-check.scm")
(load "mk/mk.scm")

(test 'unification
  (run* (q)
    (fresh (x y)
      (== (cons 3 4) (cons x y))
      ;; All of these expressions are equivalent.
      (== q (quasiquote (3 ((unquote x) . y) 4)))
      (== q `(3 (,x . y) 4))
      (== q (list 3 (cons x (quote y)) 4))
      (== q (cons 3 (cons (cons x 'y) (cons 4 '()))))))
  '(((3 (3 . y) 4))))

(define appendo
  (lambda (l s out)
    (conde
      [(== '() l) (== s out)]
      [(fresh (a d res)
         (== `(,a . ,d) l)
         (== `(,a . ,res) out)
         (appendo d s res))])))

(test 'appendo-forward
  (run* (q) (appendo '(a b c) '(d e) q))
  '(((a b c d e))))

(test 'appendo-backward-1
  (run* (q) (appendo q '(d e) '(a b c d e)))
  '(((a b c))))

(test 'appendo-backward-2
  (run* (q) (appendo '(a b) q '(a b c d e)))
  '(((c d e))))

(test 'appendo-backward-3
  (run* (x y) (appendo x y '(a b c d e)))
  '(((() (a b c d e)))
    (((a) (b c d e)))
    (((a b) (c d e)))
    (((a b c) (d e)))
    (((a b c d) (e)))
    (((a b c d e) ()))))
