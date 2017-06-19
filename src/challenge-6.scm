(load "mk/test-check.scm")
(load "evalo-optimized.scm")
(set! allow-incomplete-search? #t)

;; For your convenience, we've factored out the proof-checking evaluation goal.
(define proof?-evalo
  (lambda (proof result)
    (evalo
      `(letrec ([member?
                  (lambda (x ls)
                    (cond
                      ((null? ls) #f)
                      ((equal? (car ls) x) #t)
                      (else (member? x (cdr ls)))))]
                [proof?
                  (lambda (proof)
                    (match proof
                      [`(,A ,assms assumption ()) (member? A assms)]
                      [`(,B ,assms modus-ponens
                            (((,A => ,B) ,assms ,r1 ,ants1)
                             (,A ,assms ,r2 ,ants2)))
                        (and (proof? `((,A => ,B) ,assms ,r1 ,ants1))
                             (proof? `(,A ,assms ,r2 ,ants2)))]
                      [`((,A => ,B) ,assms conditional
                                    ((,B (,A . ,assms) ,rule ,ants)))
                        (proof? `(,B (,A . ,assms) ,rule ,ants))]))])
         (proof? ',proof))
      result)))

;; The structure of a proof is: `(,conclusion ,assumptions . ,justification)
;; where:
;; `conclusion` is a term
;; `assumptions` is a list of terms
;; `justification` is: `(,rule-name ,sub-proofs)
(define example-proof
  ;; prove C holds, given A, A => B, B => C
  '(C (A (A => B) (B => C))
      modus-ponens
      (((B => C) (A (A => B) (B => C)) assumption ())
       (B (A (A => B) (B => C))
          modus-ponens
          (((A => B) (A (A => B) (B => C)) assumption ())
           (A (A (A => B) (B => C)) assumption ()))))))

(time
  (test 'proof-checker-example
    (run* (q) (proof?-evalo example-proof q))
    '((#t))))

(time
  (test 'prover-example
    (run 1 (prf)
      (fresh (body)
        ;; prove C holds, given A, A => B, B => C
        (== prf `(C (A (A => B) (B => C)) . ,body))
        (proof?-evalo prf #t)))
    `((,example-proof))))

(time
  (test 'prover-implication-transitivity
    (run 1 (prf)
      (fresh (body)
        ;; prove (A => B) => (B => C) => (A => C) holds absolutely
        (== prf `(((A => B) => ((B => C) => (A => C))) () . ,body))
        (proof?-evalo prf #t)))
    '(((((A => B) => ((B => C) => (A => C)))
        ()
        conditional
        ((((B => C) => (A => C))
          ((A => B))
          conditional
          (((A => C)
            ((B => C) (A => B))
            conditional
            ((C (A (B => C) (A => B))
                modus-ponens
                (((B => C) (A (B => C) (A => B)) assumption ())
                 (B (A (B => C) (A => B))
                    modus-ponens
                    (((A => B) (A (B => C) (A => B)) assumption ())
                     (A (A (B => C) (A => B)) assumption ())))))))))))))))

(printf "This may take a few minutes.\n")
(time
  (test 'prover-conjunction-commutativity
    (run 1 (prf)
      (fresh (body)
        ;; prove commutativity of ∧, encoded with =>
        ;; ((A ∧ B) => (B ∧ A))
        ;; (¬(¬A ∨ ¬B) => ¬(¬B ∨ ¬A))
        ;; (¬(A => ¬B) => ¬(B => ¬A))
        ;; (((A => (B => C)) => C) => ((B => (A => C)) => C))
        (== prf `((((A => (B => C)) => C) => ((B => (A => C)) => C)) () . ,body))
        (proof?-evalo prf #t)))
    '((((((A => (B => C)) => C) => ((B => (A => C)) => C))
        ()
        conditional
        ((((B => (A => C)) => C)
          (((A => (B => C)) => C))
          conditional
          ((C ((B => (A => C)) ((A => (B => C)) => C))
              modus-ponens
              ((((A => (B => C)) => C) ((B => (A => C)) ((A => (B => C)) => C)) assumption ())
               ((A => (B => C))
                ((B => (A => C)) ((A => (B => C)) => C))
                conditional
                (((B => C)
                  (A (B => (A => C)) ((A => (B => C)) => C))
                  conditional
                  ((C (B A (B => (A => C)) ((A => (B => C)) => C))
                      modus-ponens
                      (((A => C) (B A (B => (A => C)) ((A => (B => C)) => C))
                                 modus-ponens
                                 (((B => (A => C)) (B A (B => (A => C)) ((A => (B => C)) => C)) assumption ())
                                  (B (B A (B => (A => C)) ((A => (B => C)) => C)) assumption ())))
                       (A (B A (B => (A => C)) ((A => (B => C)) => C)) assumption ())))))))))))))))))


;; We can also explore the space of proofs available by relaxing more of the
;; target proof structure.

(time
  (test 'prover-explore
    (run 20 (prf)
      (fresh (body conclusion)
        ;; given A, A => B, B => C, what can we prove?
        (== prf `(,conclusion (A (A => B) (B => C)) . ,body))
        (proof?-evalo prf #t)))

    '(((A (A (A => B) (B => C)) assumption ()))

      (((A => B) (A (A => B) (B => C)) assumption ()))

      (((B => C) (A (A => B) (B => C)) assumption ()))

      (((_.0 => _.0)
        (A (A => B) (B => C))
        conditional
        ((_.0 (_.0 A (A => B) (B => C)) assumption ())))
       (absento (closure _.0) (prim _.0)))

      ((B
         (A (A => B) (B => C))
         modus-ponens
         (((A => B) (A (A => B) (B => C))
                    assumption ())
          (A (A (A => B) (B => C)) assumption ()))))

      (((_.0 => A)
        (A (A => B) (B => C))
        conditional
        ((A (_.0 A (A => B) (B => C)) assumption ())))
       (=/= ((_.0 A))) (absento (closure _.0) (prim _.0)))

      (((_.0 => (_.1 => _.1))
        (A (A => B) (B => C))
        conditional
        (((_.1 => _.1)
          (_.0 A (A => B) (B => C))
          conditional
          ((_.1 (_.1 _.0 A (A => B) (B => C)) assumption ())))))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))

      (((_.0 => (A => B))
        (A (A => B) (B => C))
        conditional
        (((A => B) (_.0 A (A => B) (B => C)) assumption ())))
       (=/= ((_.0 (A => B)))) (absento (closure _.0) (prim _.0)))

      ((B
         (A (A => B) (B => C))
         modus-ponens
         (((A => B) (A (A => B) (B => C)) assumption ())
          (A (A (A => B) (B => C))
             modus-ponens
             (((A => A)
               (A (A => B) (B => C))
               conditional
               ((A (A A (A => B) (B => C)) assumption ())))
              (A (A (A => B) (B => C)) assumption ()))))))

      ((A
         (A (A => B) (B => C))
         modus-ponens
         (((A => A)
           (A (A => B) (B => C))
           conditional
           ((A (A A (A => B) (B => C)) assumption ())))
          (A (A (A => B) (B => C)) assumption ()))))

      (((_.0 => (B => C))
        (A (A => B) (B => C))
        conditional
        (((B => C) (_.0 A (A => B) (B => C)) assumption ())))
       (=/= ((_.0 (B => C)))) (absento (closure _.0) (prim _.0)))

      (((A => B)
        (A (A => B) (B => C))
        modus-ponens
        ((((A => B) => (A => B))
          (A (A => B) (B => C))
          conditional
          (((A => B) ((A => B) A (A => B) (B => C)) assumption ())))
         ((A => B) (A (A => B) (B => C)) assumption ()))))

      (((_.0 => (_.1 => _.0))
        (A (A => B) (B => C))
        conditional
        (((_.1 => _.0)
          (_.0 A (A => B) (B => C))
          conditional
          ((_.0 (_.1 _.0 A (A => B) (B => C)) assumption ())))))
       (=/= ((_.0 _.1)))
       (absento (closure _.0)
                (closure _.1) (prim _.0) (prim _.1)))

      ((C (A (A => B) (B => C))
          modus-ponens
          (((B => C) (A (A => B) (B => C)) assumption ())
           (B (A (A => B) (B => C))
              modus-ponens
              (((A => B) (A (A => B) (B => C)) assumption ())
               (A (A (A => B) (B => C)) assumption ()))))))

      ((((A => _.0) => _.0)
        (A (A => B) (B => C))
        conditional
        ((_.0
           ((A => _.0) A (A => B) (B => C))
           modus-ponens
           (((A => _.0) ((A => _.0) A (A => B) (B => C)) assumption ())
            (A ((A => _.0) A (A => B) (B => C)) assumption ())))))
       (absento (closure _.0) (prim _.0)))

      ((B
         (A (A => B) (B => C))
         modus-ponens
         (((A => B) (A (A => B) (B => C)) assumption ())
          (A (A (A => B) (B => C))
             modus-ponens
             (((A => A)
               (A (A => B) (B => C))
               conditional
               ((A (A A (A => B) (B => C)) assumption ())))
              (A (A (A => B) (B => C))
                 modus-ponens
                 (((A => A)
                   (A (A => B) (B => C))
                   conditional
                   ((A (A A (A => B) (B => C)) assumption ())))
                  (A (A (A => B) (B => C)) assumption ()))))))))

      ((B
         (A (A => B) (B => C))
         modus-ponens
         (((A => B) (A (A => B) (B => C)) assumption ())
          (A (A (A => B) (B => C))
             modus-ponens
             ((((A => B) => A)
               (A (A => B) (B => C))
               conditional
               ((A ((A => B) A (A => B) (B => C)) assumption ())))
              ((A => B) (A (A => B) (B => C)) assumption ()))))))

      (((_.0 => (_.1 => (_.2 => _.2)))
        (A (A => B) (B => C))
        conditional
        (((_.1 => (_.2 => _.2))
          (_.0 A (A => B) (B => C))
          conditional
          (((_.2 => _.2)
            (_.1 _.0 A (A => B) (B => C))
            conditional
            ((_.2 (_.2 _.1 _.0 A (A => B) (B => C)) assumption ())))))))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))

      (((_.0 => (_.1 => A))
        (A (A => B) (B => C))
        conditional
        (((_.1 => A)
          (_.0 A (A => B) (B => C))
          conditional
          ((A (_.1 _.0 A (A => B) (B => C)) assumption ())))))
       (=/= ((_.0 A)) ((_.1 A)))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))

      (((B => C)
        (A (A => B) (B => C))
        modus-ponens
        ((((B => C) => (B => C))
          (A (A => B) (B => C))
          conditional
          (((B => C) ((B => C) A (A => B) (B => C)) assumption ())))
         ((B => C) (A (A => B) (B => C)) assumption ())))))))

(printf "Give this a minute or so.\n")
(time
  (test 'find-50-theorems
    (run 50 (conclusion)
      (fresh (prf body)
        ;; given no assumptions, what conclusions can we prove?
        (== prf `(,conclusion () . ,body))
        (proof?-evalo prf #t)))
    '(((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => (_.1 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => (_.1 => _.0))
       (=/= ((_.0 _.1)))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => (_.2 => _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((((_.0 => _.0) => _.1) => _.1)
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => (_.1 => _.0))
       (=/= ((_.0 _.1)))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => (_.2 => _.1)))
       (=/= ((_.1 _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => ((_.0 => _.1) => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => (_.2 => _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      (((_.0 => _.1) => (_.0 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => (_.2 => _.0)))
       (=/= ((_.0 _.1)) ((_.0 _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => (_.2 => (_.3 => _.3))))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (closure _.3) (prim _.0) (prim _.1) (prim _.2) (prim _.3)))
      ((((_.0 => _.0) => _.1) => _.1)
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => _.1))
       (=/= ((_.0 (_.1 => _.1))))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => (((_.1 => _.1) => _.2) => _.2))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => (_.2 => _.1)))
       (=/= ((_.1 _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((((_.0 => (_.1 => _.1)) => _.2) => _.2)
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => (_.2 => (_.3 => _.2))))
       (=/= ((_.2 _.3)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (closure _.3) (prim _.0) (prim _.1) (prim _.2) (prim _.3)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => ((_.0 => _.1) => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => ((_.1 => _.2) => _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      (((_.0 => _.1) => (_.0 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((((_.0 => _.0) => (_.0 => _.0)) => (_.0 => _.0))
       (absento (closure _.0) (prim _.0)))
      ((_.0 => (_.1 => (_.2 => _.0)))
       (=/= ((_.0 _.1)) ((_.0 _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => (_.2 => _.2)))
       (=/= ((_.0 (_.1 => (_.2 => _.2)))))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => ((_.1 => _.2) => (_.1 => _.2)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => (_.2 => (_.3 => _.3))))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (closure _.3) (prim _.0) (prim _.1) (prim _.2) (prim _.3)))
      ((_.0 => (_.1 => _.0))
       (=/= ((_.0 _.1)))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0)))
      ((((_.0 => _.0) => _.1) => (_.2 => _.1))
       (=/= ((_.2 ((_.0 => _.0) => _.1))))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => (_.2 => (_.3 => (_.4 => _.4)))))
       (absento (closure _.0) (closure _.1) (closure _.2) (closure _.3)
                (closure _.4) (prim _.0) (prim _.1) (prim _.2) (prim _.3)
                (prim _.4)))
      ((_.0 => (_.1 => (_.2 => (_.3 => _.1))))
       (=/= ((_.1 _.2)) ((_.1 _.3)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (closure _.3) (prim _.0) (prim _.1) (prim _.2) (prim _.3)))
      ((((_.0 => (_.1 => _.0)) => _.2) => _.2)
       (=/= ((_.0 _.1)))
       (absento (closure _.0) (closure _.1) (closure _.2)
                (prim _.0) (prim _.1) (prim _.2)))
      ((_.0 => (_.1 => _.0))
       (=/= ((_.0 _.1)))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => (_.1 => _.1))
       (absento (closure _.0) (closure _.1) (prim _.0) (prim _.1)))
      ((_.0 => _.0) (absento (closure _.0) (prim _.0))))))
