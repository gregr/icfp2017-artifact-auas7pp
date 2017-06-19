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
                      (cons ,x (append (cdr l) s))))])  ;; Note the hole: ,x
         (list (append ,y '(c d e)) (append '(f g h) '(i j))))
      '((a b c d e) (f g h i j))))
  '((((car l) '(a b)))))


(load "evalo-optimized.scm")
(set! allow-incomplete-search? #t)

(test 'append-synthesis-insufficient-1
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

(test 'append-synthesis-insufficient-2
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
  (test 'append-synthesis-fully-general
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
  (test 'append-synthesis-using-fold-right
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

(printf "This one is about 10x faster than append-synthesis-fully-general.\n")
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


;; It's also possible to synthesize all of append from scratch, including
;; figuring out the parameter list.  The downside is that the output is
;; somewhat harder to read since the parameter names could be almost anything,
;; and are therefore represented by constrained logic variables.

(time
  (test 'append-synthesis-from-scratch
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        ;(== defn `(append (lambda (xs ys) ,body)))  ;; This is the difference.
        (evalo
          `(letrec (,defn)
             (list (append '() '())
                   (append '(1) '(2))
                   (append '(1 2) '(3 4))))
          '(() (1 2) (1 2 3 4)))))
    '(((append
         (lambda (_.0 _.1)
           (if (null? _.0)
             _.1
             (cons (car _.0) (append (cdr _.0) _.1)))))
       (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons))
            ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr))
            ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
       (sym _.0 _.1)))))


;; We can also play other interesting games, such as indirectly synthesizing
;; fold-right given a definition of append that uses it.

(time
  (test 'fold-right-synthesis-given-append
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (== defn `(fold-right (lambda (f acc xs) ,body)))
        (evalo
          `(letrec (,defn)
             ;; We nest letrec expressions to prevent cheating.
             (letrec ((append
                        (lambda (xs ys)
                          (fold-right cons ys xs))))
               (list (append '() '())
                     (append '(1) '(2))
                     (append '(1 2) '(3 4)))))
          `(() (1 2) (1 2 3 4)))))
    '(((fold-right
         (lambda (f acc xs)
           (if (null? xs)
             acc
             (f (car xs) (fold-right f acc (cdr xs))))))))))


;; This idea of indirect synthesis is useful for more than just games.  For
;; instance, we can synthesize an efficient definition of reverse by
;; hypothesizing the existence of an accumulator-passing algorithm, and
;; defining reverse in terms of it.

(time
  (test 'reverse-accumulator-passing-synthesis
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (== defn `(reverse-acc (lambda (xs acc) ,body)))
        (evalo
          `(letrec ((reverse
                      (lambda (xs)
                        (reverse-acc xs '())))
                    ,defn)
             (list (reverse '())
                   (reverse '(1))
                   (reverse '(1 2))))
          '(() (1) (2 1)))))
    '(((reverse-acc
         (lambda (xs acc)
           (if (null? xs)
             acc
             (reverse-acc (cdr xs) (cons (car xs) acc)))))))))


;; We can also perform synthesis using fancier examples, such as equalities.

(time
  (test 'append-synthesis-equalities-1
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (evalo
          `(letrec (,defn)
             (list
               (equal? '() (append '() '()))
               (equal? (append '(1) '(2)) '(1 2))
               (equal? '(1 2 3 4) (append '(1 2) '(3 4)))))
          (list #t #t #t))))
    '(((append
         (lambda (_.0 _.1)
           (if (null? _.0)
             _.1
             (cons (car _.0) (append (cdr _.0) _.1)))))
       (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons))
            ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr))
            ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
       (sym _.0 _.1)))))

;; These equalities can involve nontrivial evaluation on both sides, enabling a
;; form of algebraic property-based specification.

(time
  (test 'append-synthesis-equalities-2
    (run 1 (defn)
      (fresh (body)
        (absento 1 defn) (absento 2 defn) (absento 3 defn) (absento 4 defn)
        (evalo
          `(letrec (,defn)
             (list
               (equal? (cons 1 (append '() 2)) (append (cons 1 '()) 2))
               (equal? (cons 1 (append '(2) 3)) (append (cons 1 '(2)) 3))
               (equal? (append '(1) '(2 . 3)) (append '(1 2) 3))
               (equal? (append '(1) (append '(2) 3)) (append (append '(1) '(2)) 3))))
          (list #t #t #t #t))))
    '(((append
         (lambda (_.0 _.1)
           (if (null? _.0)
             _.1
             (cons (car _.0) (append (cdr _.0) _.1)))))
       (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons))
            ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr))
            ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
       (sym _.0 _.1)))))
