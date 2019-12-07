;; OPCODES
;;
;; 1 x y z
;; x: *position* of first int A
;; y: *position* of second int B
;; z: *position* at which to store A+B
;;
;; 2 x y z
;; x: *position* of first int A
;; y: *position* of second int B
;; z: *position* at which to store A*B
;;
;; 99
;; program is finished

(ns day2
  (:require [clojure.string :refer [join split trim-newline]]))

(defn str->intcode
  "Parse the given intcode program into a vector of integers"
  [program]
  (as-> program $
    (trim-newline $)
    (split $ #",")
    (map #(Integer/parseInt %) $)
    (vec $)))

(defn intcode->str
  "Return the textual representation of an intcode program"
  [ints]
  (join "," ints))

(defn run-intcode
  "Run the given intcode program and return its final state"
  [ints noun verb]
  (let [ints (-> ints
                 (assoc 1 noun)
                 (assoc 2 verb))]
    (loop [ints ints
           cursor 0]
      (let [[opcode x y z] (drop cursor ints)]  ; subvec would be faster here but we would need to handle special cases were opcode 99 is near the end
        (cond
          (= 99 opcode)
          ints

          (= 1 opcode)
          (let [a (nth ints x)
                b (nth ints y)]
            (recur (assoc ints z (+ a b)) (+ 4 cursor)))

          (= 2 opcode)
          (let [a (nth ints x)
                b (nth ints y)]
            (recur (assoc ints z (* a b)) (+ 4 cursor))))))))

(defn qa
  [ints]
  (-> ints
      (run-intcode 12 2)
      (nth 0)))

(defn qb
  [ints]
  (let [inputs
        (for [noun (range 0 100)
              verb (range 0 100)]
          [noun verb])]
    (loop [inputs inputs]
      (let [[noun verb] (first inputs)
            res (-> ints
                    (run-intcode noun verb)
                    (nth 0))]
        (println noun verb)
        (if (= res 19690720)
          (+ (* 100 noun) verb)
          (recur (rest inputs)))))))

(defn -main
  [filepath]
  (let [ints (-> filepath
                 slurp
                 str->intcode)]
    (println "qa:" (qa ints))
    (println "qb:" (qb ints))))
