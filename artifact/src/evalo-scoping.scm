(load "mk/mk.scm")


;; Interpreter implementing lexical scope

(define eval-lexo
  (lambda (expr out)
    (eval-expr-lexo expr '() out)))

(define eval-expr-lexo
  (lambda (expr env out)
    (conde

      ;; --------- CONST
      ;; ρ ⊢ n ⇒ n
      [(numbero expr) (== expr out)]

      ;;               lambda ∉ ρ
      ;; ------------------------------------ ABS
      ;; ρ ⊢ (lambda (x) e) ⇒ (closure x e ρ)
      [(fresh (x body)
         (== `(lambda (,x) ,body) expr)
         (symbolo x)
         (== `(closure ,x ,body ,env) out)
         (not-in-envo 'lambda env))]

      ;; ρ(x) = v
      ;; --------- REF
      ;; ρ ⊢ x ⇒ v
      [(symbolo expr) (lookupo expr env out)]

      ;; ρ ⊢ e1 ⇒ (closure x ec ρc)
      ;; ρ ⊢ e2 ⇒ v2
      ;; ρc, x ↦ v2 ⊢ ec ⇒ v3
      ;; -------------------------- APP
      ;;      ρ ⊢ (e1 e2) ⇒ v3
      [(fresh (e1 e2 val x body cenv new-env)
         (== `(,e1 ,e2) expr)
         (eval-expr-lexo e1 env `(closure ,x ,body ,cenv))
         (eval-expr-lexo e2 env val)
         (ext-envo x val cenv new-env)
         (eval-expr-lexo body new-env out))])))


;; Interpreter implementing dynamic scope

(define eval-dyno
  (lambda (expr out)
    (eval-expr-dyno expr '() out)))

(define eval-expr-dyno
  (lambda (expr env out)
    (conde

      ;; --------- CONST
      ;; ρ ⊢ n ⇒ n
      [(numbero expr) (== expr out)]

      ;;               lambda ∉ ρ
      ;; ------------------------------------ ABS
      ;; ρ ⊢ (lambda (x) e) ⇒ (closure x e ρ)
      [(fresh (x body)
         (== `(lambda (,x) ,body) expr)
         (symbolo x)
         (== `(closure ,x ,body ,env) out)
         (not-in-envo 'lambda env))]

      ;; ρ(x) = v
      ;; --------- REF
      ;; ρ ⊢ x ⇒ v
      [(symbolo expr) (lookupo expr env out)]

      ;; ρ ⊢ e1 ⇒ (closure x ec ρc)
      ;; ρ ⊢ e2 ⇒ v2
      ;; ρ, x ↦ v2 ⊢ ec ⇒ v3
      ;; -------------------------- APP
      ;;      ρ ⊢ (e1 e2) ⇒ v3
      [(fresh (e1 e2 val x body cenv new-env)
         (== `(,e1 ,e2) expr)
         (eval-expr-dyno e1 env `(closure ,x ,body ,cenv))
         (eval-expr-dyno e2 env val)
         (ext-envo x val env new-env)  ;; Note the use of env instead of cenv.
         (eval-expr-dyno body new-env out))])))


;; Shared utilities

(define ext-envo
  (lambda (param arg env new-env)
    (== `((,param . ,arg) . ,env) new-env)))

(define lookupo
  (lambda (x env t)
    (fresh (rest y v)
      (== `((,y . ,v) . ,rest) env)
      (conde
        ((== y x) (== v t))
        ((=/= y x) (lookupo x rest t))))))

(define (not-in-envo x env)
  (conde
    ((== '() env))
    ((fresh (y v rest)
       (== `((,y . ,v) . ,rest) env)
       (=/= y x)
       (not-in-envo x rest)))))
