(ns day1
  (:require [clojure.string :as s]))

(defn get-lines
  "Take input from stdin, returns a vector of strings"
  []
  (loop [input (read-line)
         lines []]
    (if (s/blank? input)
      lines
      (recur (read-line)
             (conj lines input)))))

(defn parse
  [input]
  (let [number (Integer/parseInt (subs input 1))]
    (if (s/starts-with? input "+")
      number
      (* -1 number))))

(defn qa
  [lines]
  (loop [numbers lines
         sum 0]
    (if (empty? numbers)
      (println sum)
      (recur (rest numbers)
             (+ sum (first numbers))))))

(defn qb
  [lines]
  (loop [numbers lines
         freq 0
         past #{0}]
    (let [x (first numbers)
          new-freq (+ x freq)]
      (if (contains? past new-freq)
        (println new-freq)
        (recur (rest numbers)
               new-freq
               (conj past new-freq))))))

(defn -main
  []
  (let [lines (map parse (get-lines))]
    (do
      (qa lines)
      (qb (cycle lines)))))
