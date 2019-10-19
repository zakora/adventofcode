(ns day2
  (:require [clojure.string :as str]))

(defn get-lines
  "Take input from stdin, returns a vector of strings"
  []
  (loop [input (read-line)
         lines []]
    (if (str/blank? input)
      lines
      (recur (read-line)
             (conj lines input)))))

;;
;; QA
;;
(defn count-letters
  "Count the number of occurences of each letter in a word"
  [word]
  (loop [letters (str/split word #"")
         occurences {}]
    (if (empty? letters)
      occurences
      (let [letter (first letters)
            n (get occurences letter 0)]
        (recur (rest letters)
               (assoc occurences letter (+ n 1)))))))

(defn inc-boxid-n
  "Return 1 if the given box ID has a letter exactly n times, 0 otherwise"
  [n boxid]
  (let [counts (vals (count-letters boxid))]
    (if (.contains counts n)
      1
      0)))

(def inc-boxid-three
  (partial inc-boxid-n 3))

(def inc-boxid-two
  (partial inc-boxid-n 2))

(defn qa
  [lines]
  (loop [boxids lines
         twos 0
         threes 0]
    (if (empty? boxids)
      (println "qa" (* twos threes))
      (recur (rest boxids)
             (+ (inc-boxid-two (first boxids)) twos)
             (+ (inc-boxid-three (first boxids)) threes)))))


;;
;; QB
;;
(defn diff-letters
  "Cound letter differences between two words"
  [wa wb]
  (let [lsa (str/split wa #"")
        lsb (str/split wb #"")]
    (loop [la (first lsa)
           lb (first lsb)
           lsa (rest lsa)
           lsb (rest lsb)
           ndiff 0]
      (cond
        (or (nil? la) (nil? lb)) ndiff
        (= la lb) (recur (first lsa) (first lsb) (rest lsa) (rest lsb) ndiff)
        :else (recur (first lsa) (first lsb) (rest lsa) (rest lsb) (+ ndiff 1))))))

(defn diff-one?
  "True of the two words differ by exactly one letter, False otherwise"
  [wa wb]
  (= 1 (diff-letters wa wb)))

(defn common-letters
  "Given two same-size words, return their letters in common"
  [wa wb]
  (let [lsa (str/split wa #"")
        lsb (str/split wb #"")]
    (loop [lsa lsa
           lsb lsb
           common []]
      (cond
        (or (empty? lsa) (empty? lsb)) common
        (= (first lsa) (first lsb))
        (recur (rest lsa) (rest lsb) (conj common (first lsa)))
        :else (recur (rest lsa) (rest lsb) common)))))

(defn find-diff-one
  "Find a pair of box IDs that differs by one letter, nil if not found."
  [ba boxids]
  (loop [ba ba
         bb (first boxids)
         boxids boxids]
    (cond
      (empty? boxids) nil
      (diff-one? ba bb) [ba bb]
      :else (recur ba (first boxids) (rest boxids)))))

(defn find-boxids-pair
  "Given a list of boxids, find a pair that differs by 1 letter"
  [boxids]
  (loop [ba (first boxids)
         boxids (rest boxids)]
    (if (empty? boxids)
      nil
      (let [pair (find-diff-one ba boxids)]
        (if (nil? pair)
          (recur (first boxids) (rest boxids))
          (common-letters (first pair) (second pair)))))))

(defn qb
  [lines]
  (println "qb" (str/join "" (find-boxids-pair lines))))

(defn -main
  []
  (let [lines (get-lines)]
    (do
      (qa lines)
      (qb lines))))
