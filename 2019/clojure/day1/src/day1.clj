(ns day1
  (:require [clojure.string :refer [split-lines]]))

(defn fuel-amount
  "Calculate how much fuel is necessary to carry a module of a given mass"
  [mass]
  (- (quot mass 3) 2))

(defn modules-fuel
  [masses]
  (->> masses
    (map fuel-amount)
    (reduce +)))

(defn qa
  [masses]
  (modules-fuel masses))

(defn total-fuel
  "Returns how much fuel is necessary to carry a module and the fuel"
  [mass]
  (loop [fuel (fuel-amount mass)
         acc 0]
    (if (<= fuel 0)
      acc
      (recur (fuel-amount fuel) (+ acc fuel)))))

(defn qb
  [masses]
  (->> masses
       (map total-fuel)
       (reduce +)))

(defn -main
  [filepath]
  (let [modules (->> filepath
                     slurp
                     split-lines
                     (map #(Integer/parseInt %)))]
    (println "qa:" (qa modules))
    (println "qb:" (qb modules))))
