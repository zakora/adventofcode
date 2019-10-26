(ns day3
  (:require [clojure.string :as str]
            [clojure.set :as cset]))

(defn get-lines
  "Take input from stdin, returns a vector of strings"
  []
  (loop [input (read-line)
         lines []]
    (if (str/blank? input)
      lines
      (recur (read-line)
             (conj lines input)))))

(defn find-claim-values
  "Takes a textual claim and return (id left top width height)"
  [line]
  (as-> line c
    (str/split c #"[#@,:x]")
    (map str/trim c)
    (rest c)
    (map #(Integer/parseInt %) c)))

(defn parse-claim
  "Parse a textual claim into a map"
  [line]
  (let [[id left top width height] (find-claim-values line)]
    {:id id :left left :top top :width width :height height}))

(defn claim-area
  "Return the list of {:id :x :y} square inches that covers the given claim"
  [claim]
  (let [id (:id claim)
        xmin (:left claim)
        ymin (:top claim)
        xmax (- (+ xmin (:width claim)) 1)
        ymax (- (+ ymin (:height claim)) 1)]
    (loop [area (conj '() {:id id :x xmin :y ymin})
           x xmin
           y ymin]
      (cond
        (and (= x xmax) (= y ymax)) area
        (= x xmax) (recur (conj area {:id id :x xmin :y (+ y 1)})
                          xmin
                          (+ y 1))
        (< x xmax) (recur (conj area {:id id :x (+ x 1) :y y})
                          (+ x 1)
                          y)))))

(defn claims-per-sqin
  "Count the number of overlapping claims for each square inch"
  [claims]
  (let [xys (->> claims
                (map claim-area)
                flatten)]
    (loop [sqins {}
           xys xys]
      (if (empty? xys)
        sqins
        (let [{id :id x :x y :y} (first xys)
              xy {:x x :y y}
              ids (get sqins xy  #{})
              new-ids (conj ids id)]
          (recur (assoc sqins xy new-ids)
                 (rest xys)))))))

(defn count-overlapping
  "Count how many square inches have overlapping claims"
  [claims]
  (->> claims
       claims-per-sqin
       vals
       (map count)
       (filter (fn [x] (> x 1)))
       count))

(defn find-overlapping
  "Return the set of ids of overlapping claims"
  [sqins]
  (->> sqins
    vals
    (filter (fn [ids] (> (count ids) 1)))
    (reduce cset/union #{})))

(defn qa
  [lines]
  (let [claims (map parse-claim lines)]
    (println "qa:" (count-overlapping claims))))

(defn qb
  [lines]
  (let [claims (map parse-claim lines)
        sqins (claims-per-sqin claims)
        all-ids (->> sqins vals (reduce cset/union #{}))
        overlapping (find-overlapping sqins)
        non-overlapping (cset/difference all-ids overlapping)]
    (println "qb:" (first non-overlapping))))

(defn -main
  []
  (let [lines (get-lines)]
    (qa lines)
    (qb lines)))
