(ns day4
  (:require [clojure.string :refer [split]]))

(defn has-double?
  [xs]
  (loop [xs xs]
    (let [[x y] xs
          match (= x y)]
      (cond
        (nil? y) false
        match true
        :else (recur (rest xs))))))

(defn split-groups
  [xs]
  (loop [group []
         current nil
         groups []
         xs xs]
    (if (empty? xs)
      (conj groups group)
      (let [x (first xs)]
        (if (= current x)
          (recur (conj group x) current groups (rest xs))
          (recur [x] x (conj groups group) (rest xs)))))))

(defn has-strict-double?
  [xs]
  (as-> xs $
    (split-groups $)
    (map count $)
    (set $)
    (contains? $ 2)))

(defn decreasing?
  [xs]
  (loop [xs xs]
    (let [[x y] xs]
      (cond
        (nil? y) false
        (< y x) true
        :else (recur (rest xs))))))

(defn int->xs
  [int]
  (as-> int $
    (str $)
    (split $ #"")
    (map #(Integer/parseInt %) $)))

(defn qa
  [mini maxi]
  (let [passwords (range mini (+ 1 maxi))]
    (->> passwords
         (map int->xs)
         (filter (fn [xs] (and (has-double? xs)
                               (not (decreasing? xs)))))
         count)))

(defn qb
  [mini maxi]
  (let [passwords (range mini (+ 1 maxi))]
    (->> passwords
         (map int->xs)
         (filter (fn [xs] (and (has-strict-double? xs)
                               (not (decreasing? xs)))))
         count)))

(defn -main
  [input]
  (let [[mini maxi] (split input #"-")
        mini (Integer/parseInt mini)
        maxi (Integer/parseInt maxi)]
    (println "qa:" (qa mini maxi))
    (println "qb:" (qb mini maxi))))
