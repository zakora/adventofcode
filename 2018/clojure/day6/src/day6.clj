;;; DATA
;;; coordinates: [x y]  (places: dangerous or not)
;;; points: {:id 1 :x 0 :y 5}
;;;
;;; ret: 1 coordinate, the most distant, count area around it

;;; Sol 1: simple alg
;;; go from (0, 0) to (max, max)
;;; for each point: mark closest coord or tie
;;; NOPE: 4612 (id: 48) too high, actually this point has infinite area so should be discarded

(ns day6
  (:require [clojure.string :as string]))

(defn get-lines
  "Take input from stdin, returns a vector of strings"
  []
  (loop [input (read-line)
         lines []]
    (if (string/blank? input)
      lines
      (recur (read-line)
             (conj lines input)))))

(defn get-coords
  "Parse input lines as coordinates"
  [lines]
  (as-> lines $
    (map #(string/split % #", ") $)
    (map (fn [[a b]] [(Integer/parseInt a) (Integer/parseInt b)]) $)))

(defn get-points
  "Parse input lines as points"
  [lines]
  (let [coords (get-coords lines)
        ided (zipmap (range) coords)]
    (into []
          (for [[id [x y]] ided]
            {:id id :x x :y y}))))

(defn find-boundaries
  "Find grid boundaries as (xmin, ymin) (xmax, ymax)"
  [points]
  (let [xs (map :x points)
        ys (map :y points)
        pmin [(apply min xs) (apply min ys)]
        pmax [(apply max xs) (apply max ys)]]
      [pmin pmax]))

(defn dist
  "Manhattan distance between 2 coordinates"
  [[xa ya] [xb yb]]
  (+ (Math/abs (- xa xb))
     (Math/abs (- ya yb))))

(defn min-tie
  "Like min-key but returns nil in case of tie"
  [f coords]
  (let [mini (apply min-key f coords)
        [_id mini-dist] mini
        tie? (->> coords
                  (map (fn [[_id d]] d))
                  (filter #(= mini-dist %))
                  count
                  (< 1))]
    (if tie? nil mini)))

(defn find-closest
  "Find closest point to a coordinate"
  [coord points]
  (let [dists
        (into {} (map (fn [{id :id x :x y :y}]
                        [id (dist coord [x y])]) points))
        [id _] (min-tie (fn [[id d]] d) dists)]
    id))

(defn scan-closest
  "Scan the grid to find how many coordinates are closest to each point.

  Returns:
  :counts map of id -> area size
  :infinites set of id of infinites area
  "
  [points]
  (let [[[xmin ymin] [xmax ymax]] (find-boundaries points)]
    (loop [grid (for [x (range xmin (+ xmax 1))
                      y (range ymin (+ ymax 1))]
                  [x y])
           infinites #{}
           counts {}]
      (if (empty? grid)
        {:counts counts
         :infinites infinites}
        (let [[x y] (first grid)
              grid (rest grid)
              closest (find-closest [x y] points)
              inc-count (inc (get counts closest 0))
              ;; Areas extending to the boundaries are marked as infinites and discarded
              infinites (if (or (= x xmin) (= x xmax) (= y ymin) (= y ymax))
                          (conj infinites closest)
                          infinites)
              counts (assoc counts closest inc-count)]
          (recur grid infinites counts))))))

(defn print-grid
  "Print a grid with markers for each point"
  [points]
  (let [[[xmin ymin] [xmax ymax]] (find-boundaries points)
        coord->id (into {} (for [{id :id x :x y :y} points]
                             [[x y] id]))
        res (loop [x xmin
                   y ymin
                   grid ""]
              (let [c (get coord->id [x y] ".")]
                (cond
                  (> y ymax) grid
                  (= x xmax) (recur xmin (inc y) (str grid c "\n"))
                  :else (recur (inc x) y (str grid c)))))]
    (print res)))
  
(defn qa
  [points]
  (let [{counts :counts infinites :infinites} (scan-closest points)
        [_id cnt] (->> counts
                       ;; Discard infinite areas
                       (remove (fn [[id _cnt]] (contains? infinites id)))
                       ;; Get largest area size
                       (apply max-key (fn [[_id cnt]] cnt)))]
    cnt))

;;; GOAL: compute area size for which the coordinates inside it are 1000 units or less by summing distances to all points
;;; ALG:
;;; - get coords to check (from top-left -500 -500, to bot-right +500 +500)
;;; - for each coord, compute sum distance from coord -> all points
;;; - assoc coord -> sum distance

(defn sum-distances
  "Sum the distances from the given coordinates to every points"
  [coord points]
  (->> points
       (map (fn [{x :x y :y}] (dist coord [x y])))
       (reduce +)))

(defn scan-sum-distances
  "Scan a grid to find sum-distances for each of its coordinate"
  [points]
  (let [[[xmin ymin] [xmax ymax]] (find-boundaries points)
        xmin (- xmin 500)
        ymin (- ymin 500)
        xmax (+ xmax 500)
        ymax (+ ymax 500)]
    (loop [coords (for [x (range xmin xmax)
                        y (range ymin ymax)]
                    [x y])
           coord->sum-dist {}]
      (if (empty? coords)
        coord->sum-dist
        (let [coord (first coords)
              coords (rest coords)]
          (recur coords
                 (assoc coord->sum-dist coord (sum-distances coord points))))))))
(defn qb
  [points]
  (->> points
       scan-sum-distances
       vals
       (filter #(< % 1000))
       count))

(defn -main
  []
  (let [points (get-points (get-lines))]
    (println "qa:" (qa points))
    (println "qb:" (qb points))))
