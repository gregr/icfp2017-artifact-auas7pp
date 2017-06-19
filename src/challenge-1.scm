(load "mk/test-check.scm")
(load "evalo-standard.scm")

(test 'first-love
  (run 1 (q) (evalo q '(I love you)))
  '(('(I love you))))

(printf "Generating 99000 expressions that evaluate to '(I love you).\n")
(printf "Give it a minute or so.\n")
(time
  (test 'love-in-99000-ways
    (run 99000 (q) (evalo q '(I love you)))
    (with-input-from-file "love-in-99k-ways.scm" read)))
