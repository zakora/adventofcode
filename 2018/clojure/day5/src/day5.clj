(ns day5
  (:require [clojure.string :as string]))

(defn units-react?
  "True if the two units react together, false otherwise"
  [a b]
  (cond
    (nil? a) false
    (nil? b) false
    :else (and (= (string/lower-case a) (string/lower-case b))
               (not= a b))))

(defn react
  "React polymer units once"
  [units]
  (loop [units units
         reacted []]
    (if (empty? units)
      (string/join reacted)
      (let [[a b _] units]
        (if (units-react? a b)
          (recur (drop 2 units) reacted)
          (recur (rest units) (conj reacted (first units))))))))

(defn chain-react
  "React a polymer until it cannot react anymore"
  [polymer]
  (let [units (string/split polymer #"")]
    (loop [units units
           prev nil]
      (if (= (count units) (count prev))
        units
        (recur (react units) units)))))

(defn qa
  [polymer]
  (-> polymer
      chain-react
      count))

(defn find-types
  "Set of (lower-case) units forming the polymer"
  [polymer]
  (-> polymer
      string/lower-case
      (string/split #"")
      set))

(defn qb
  "List fully-reacted polymer lengths by recursively removing one unit type"
  [polymer]
  (let [types (find-types polymer)]
    (loop [types types
           lengths '()]
      (if (empty? types)
        (apply min lengths)
        (let [pol+ (first types)
              pol- (string/upper-case pol+)
              polymer (-> polymer
                          (string/replace pol+ "")
                          (string/replace pol- ""))
              reacted-polymer (chain-react polymer)]
          (recur (rest types) (conj lengths (count reacted-polymer))))))))

(defn -main
  []
  (let [polymer (read-line)]
    (println "qa: " (qa polymer))
    (println "qb: " (qb polymer))))
