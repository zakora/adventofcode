#lang racket
(module+ test
  (require rackunit))


(struct posn (x y dir) #:inspector #f)


;; posn -> Pair Integer
;; produces the (x, y) pair of the given position
(module+ test
  (check-equal? (posn-xy (posn 0 0 "N")) (cons 0 0))
  (check-equal? (posn-xy (posn 10 10 "E")) (cons 10 10))
  (check-equal? (posn-xy (posn -10 3 "S")) (cons -10 3)))

(define (posn-xy p)
  (cons (posn-x p) (posn-y p)))


;; String -> List of String
;; produces a list of moves by splitting the input on ", "
(module+ test
  (check-equal? (input->moves "L2, R3") '("L2" "R3"))
  (check-equal? (input->moves "") '())
  (check-equal? (input->moves "L2, R3\n") '("L2" "R3")))

(define (input->moves input)
  (define trimmed (string-trim input))
  (string-split trimmed ", "))


;; String -> Pair (String, Integer)
;; produces a pair of (turn, step) given its concatenated string representation
(module+ test
  (check-equal? (move->turn-steps "L2") '("L" . 2))
  (check-equal? (move->turn-steps "R1234") '("R" . 1234)))

(define (move->turn-steps move)
  (define turn (substring move 0 1))
  (define steps
    (string->number
     (substring move 1)))
  (cons turn steps))


;; String -> String -> String
;; produces a new direction given the current direction and a turn
(module+ test
  (check-equal? (do-turn "N" "L") "W")
  (check-equal? (do-turn "N" "R") "E"))

(define (do-turn dir turn)
  (match (list dir turn)
    [(list "N" "L") "W"]
    [(list "N" "R") "E"]
    [(list "W" "L") "S"]
    [(list "W" "R") "N"]
    [(list "S" "L") "E"]
    [(list "S" "R") "W"]
    [(list "E" "L") "N"]
    [(list "E" "R") "S"]))


;; posn -> String -> Integer -> posn? -> Set posns -> (posn, Pair Integer, Set posn)
;; perform each steps of a move, adding walked by positions
(module+ test
  (let ([posn-init (posn 0 0 "N")])
    (check-equal? (do-steps posn-init "E" 1 null (set (cons 0 0)))
                  (list (posn 1 0 "E") null (set (cons 0 0)
                                                 (cons 1 0))))
    (check-equal? (do-steps posn-init "E" 2 null (set (cons 0 0) (cons 1 0)))
                  (list (posn 2 0 "E")
                        (cons 1 0)
                        (set (cons 0 0) (cons 1 0) (cons 2 0))))
    (check-equal? (do-steps posn-init "N" 3 (cons -1 -1) (set (cons 0 0)))
                  (list (posn 0 3 "N")
                        (cons -1 -1)
                        (set (cons 0 0)
                             (cons 0 1)
                             (cons 0 2)
                             (cons 0 3))))
    (check-equal? (do-steps posn-init "N" 3 null (set (cons 0 0) (cons 0 3)))
                  (list (posn 0 3 "N")
                        (cons 0 3)
                        (set (cons 0 0)
                             (cons 0 1)
                             (cons 0 2)
                             (cons 0 3))))))

(define (do-steps cposn dir steps found-posn past-posns)
  (if (eq? 0 steps)
      (list cposn found-posn past-posns)
      (let* ([cposn
              (match dir
                ["N" (struct-copy posn cposn
                                  [y (+ (posn-y cposn) 1)]
                                  [dir dir])]
                ["W" (struct-copy posn cposn
                                  [x (- (posn-x cposn) 1)]
                                  [dir dir])]
                ["S" (struct-copy posn cposn
                                  [y (- (posn-y cposn) 1)]
                                  [dir dir])]
                ["E" (struct-copy posn cposn
                                  [x (+ (posn-x cposn) 1)]
                                  [dir dir])])]
             [cxy (posn-xy cposn)]
             [found-posn
              (if (and (null? found-posn)
                       (set-member? past-posns cxy))
                  cxy
                  found-posn)]
             [past-posns (set-add past-posns cxy)])
        (do-steps cposn dir (- steps 1) found-posn past-posns))))


;; posn -> String -> Integer -> posn? -> Set posns -> (posn, posn-xy?, Set posn-xy)
;; produces a new position given the current one, a turn and a number of steps
(module+ test
  (check-equal? (do-move (posn 0 0 "N") "R" 5 null (set (cons 0 0)))
                (list (posn 5 0 "E")
                      null
                      (set (cons 0 0)
                           (cons 1 0)
                           (cons 2 0)
                           (cons 3 0)
                           (cons 4 0)
                           (cons 5 0))))
  (check-equal? (do-move (posn 10 10 "S") "L" 2 null (set (cons 10 10)))
                (list (posn 12 10 "E")
                      null
                      (set (cons 10 10)
                           (cons 11 10)
                           (cons 12 10))))
  (check-equal? (do-move (posn 0 0 "W") "R" 2 null (set (cons 0 0)))
                (list (posn 0 2 "N")
                      null
                      (set (cons 0 0) (cons 0 1) (cons 0 2)))))

(define (do-move cposn turn steps found-posn past-posns)
  (let ([new-dir (do-turn (posn-dir cposn) turn)])
    (do-steps cposn new-dir steps found-posn past-posns)))


;; posn -> List String -> posn? -> Set posn -> posn
;; produces a position by applying every moves to the given position
(module+ test
  (let ([posn-init (posn 0 0 "N")])
    (check-equal? (apply-moves posn-init
                               (input->moves "R1, L1")
                               null
                               (set (cons 0 0)))
                  (cons (posn 1 1 "N") null))
    (check-equal? (apply-moves posn-init
                               (input->moves "R10, L10, R10, L10")
                               null
                               (set (cons 0 0)))
                  (cons (posn 20 20 "N") null))
    (check-equal? (apply-moves posn-init
                               (input->moves "R1, L1, L1, L1")
                               null
                               (set (cons 0 0)))
                  (cons (posn 0 0 "S") (cons 0 0)))))

(define (apply-moves cposn moves found-posn past-posns)
  (if (null? moves)
      (cons cposn found-posn)
      (let* ([turn-steps (move->turn-steps (car moves))]
             [turn (car turn-steps)]
             [steps (cdr turn-steps)]
             [move-res (do-move cposn turn steps found-posn past-posns)]
             [cposn (first move-res)]
             [found-posn (second move-res)]
             [past-posns (third move-res)])
        (apply-moves cposn (cdr moves) found-posn past-posns))))


(module* main #f
  (let* ([moves (input->moves (port->string))]
         [cposn (posn 0 0 "N")]
         [a-b (apply-moves cposn moves null (set (cons 0 0)))]
         [posna (car a-b)]
         [posnb (cdr a-b)]
         [resa (+ (abs (posn-x posna))
                  (abs (posn-y posna)))]
         [resb (+ (abs (car posnb))
                  (abs (cdr posnb)))])
    (format "qa: ~a; qb: ~a" resa resb)))
