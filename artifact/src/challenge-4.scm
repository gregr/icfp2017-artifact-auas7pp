(load "mk/test-check.scm")
(load "evalo-standard.scm")

;; See "intro-examples.scm" for comparison with the `appendo` relation defined
;; directly in miniKanren.

(test 'append-forward
  (run 1 (q)
    (evalo
      `(letrec ([append
                  (lambda (l s)
                    (if (null? l)
                      s
                      (cons (car l) (append (cdr l) s))))])
         (append '(a b c) '(d e)))
      q))
  '(((a b c d e))))

(test 'append-backward-1
  (run 1 (q)  ;; NOTE: run* will never return due to infinitely many answers.
    (evalo
      `(letrec ([append
                  (lambda (l s)
                    (if (null? l)
                      s
                      (cons (car l) (append (cdr l) s))))])
         (append ,q '(d e)))  ;; Notice that "q" is not quoted.
      '(a b c d e)))
  '(('(a b c))))

(test 'append-backward-2
  (run 2 (q)  ;; Ask for two answers to understand why run* won't finish.
    (evalo
      `(letrec ([append
                  (lambda (l s)
                    (if (null? l)
                      s
                      (cons (car l) (append (cdr l) s))))])
         (append ,q '(d e)))
      '(a b c d e)))
  '(('(a b c))
    (((lambda _.0 '(a b c))) (=/= ((_.0 quote))) (sym _.0))))

(test 'append-backward-3
  (run* (q)  ;; Now run* will work, proving there is a single answer.
    (evalo
      `(letrec ([append
                  (lambda (l s)
                    (if (null? l)
                      s
                      (cons (car l) (append (cdr l) s))))])
         (append ',q '(d e)))  ;; Notice that "q" is quoted.
      '(a b c d e)))
  '(((a b c))))

(test 'append-backward-4
  (run* (x y)
    (evalo
      `(letrec ([append
                  (lambda (l s)
                    (if (null? l)
                      s
                      (cons (car l) (append (cdr l) s))))])
         (append ',x ',y))
      '(a b c d e)))
  '(((() (a b c d e)))
    (((a) (b c d e)))
    (((a b) (c d e)))
    (((a b c) (d e)))
    (((a b c d) (e)))
    (((a b c d e) ()))))

(test 'append-backward-and-small-synthesis
  (run 1 (x y)
    (evalo
      `(letrec ([append
                  (lambda (l s)
                    (if (null? l)
                      s
                      (cons ,x (append (cdr l) s))))])
         (list (append ,y '(c d e)) (append '(f g h) '(i j))))
      '((a b c d e) (f g h i j))))
  '((((car l) '(a b)))))


(load "evalo-optimized.scm")
(set! allow-incomplete-search? #t)

(test 'append-synthesis-1
  (run 1 (defn)
    (fresh (body)
      (== defn `(append (lambda (xs ys) ,body)))
      (evalo
        `(letrec (,defn)
           (list (append '() '())
                 (append '(1) '(2))))
        '(() (1 2)))))
  '(((append
       (lambda (xs ys)
         (if (null? ys)
           ys
           '(1 2)))))))

(test 'append-synthesis-2
  (run 1 (defn)
    (fresh (body)
      (absento 1 defn) (absento 2 defn)
      (== defn `(append (lambda (xs ys) ,body)))
      (evalo
        `(letrec (,defn)
           (list (append '() '())
                 (append '(1) '(2))))
        '(() (1 2)))))
  '(((append
       (lambda (xs ys)
         (if (null? ys)
           ys
           (cons (car xs) ys)))))))

(printf "Be patient, the next one takes a little longer.\n")
(time
  (test 'append-synthesis-3
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (== defn `(append (lambda (xs ys) ,body)))
        (evalo
          `(letrec (,defn)
             (list (append '() '())
                   (append '(1) '())
                   (append '(1) '(2))
                   (append '(1 2) '(3 4))))
          '(() (1) (1 2) (1 2 3 4)))))
    '(((append
         (lambda (xs ys)
           (if (null? xs)
             ys
             (if (null? ys)
               xs
               (cons (car xs) (append (cdr xs) ys))))))))))

(time
  (test 'append-synthesis-4
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (== defn `(append (lambda (xs ys) ,body)))
        (evalo
          `(letrec ((fold-right
                      (lambda (f acc xs)
                        (if (null? xs) acc
                          (f (car xs) (fold-right f acc (cdr xs))))))
                    ,defn)
             (list (append '() '())
                   (append '(1) '())
                   (append '(1) '(2))
                   (append '(1 2) '(3 4))))
          '(() (1) (1 2) (1 2 3 4)))))
    '(((append
         (lambda (xs ys)
           (if (null? ys)
             xs
             (fold-right cons ys xs))))))))


;; A better choice of examples can greatly improve synthesis performance.  We
;; demonstrate the synthesis of a simpler definition of append by focusing on
;; the most interesting examples.

(printf "This one is about 10x faster than append-synthesis-3.\n")
(time
  (test 'append-synthesis-faster-1
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (== defn `(append (lambda (xs ys) ,body)))
        (evalo
          `(letrec (,defn)
             (list (append '() '())
                   (append '(1) '(2))
                   (append '(1 2) '(3 4))))
          '(() (1 2) (1 2 3 4)))))
    '(((append
         (lambda (xs ys)
           (if (null? xs)
             ys
             (cons (car xs) (append (cdr xs) ys)))))))))

;; This synthesis is fast, but can be made even faster by providing examples
;; that demand support for improper lists.

(printf "This one is more than 10x faster than append-synthesis-faster-1!\n")
(time
  (test 'append-synthesis-faster-2
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (== defn `(append (lambda (xs ys) ,body)))
        (evalo
          `(letrec (,defn)
             ;; Scheme append supports improper lists, so clarify that.
             (list (append '() 1)
                   (append '(1) 2)
                   (append '(1 2) 3)))
          '(1 (1 . 2) (1 2 . 3)))))
    '(((append
         (lambda (xs ys)
           (if (null? xs)
             ys
             (cons (car xs) (append (cdr xs) ys)))))))))
