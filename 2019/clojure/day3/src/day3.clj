(ns day3
  (:require [clojure.string :refer [split split-lines]]
            [clojure.set :refer [difference intersection union]]))

(defn parse-move
  [move]
  (let [dir (subs move 0 1)
        dist (-> move
                 (subs 1)
                 Integer/parseInt)]
    (cond
      (= "R" dir) {:dir :right :dist dist}
      (= "L" dir) {:dir :left :dist dist}
      (= "U" dir) {:dir :up :dist dist}
      (= "D" dir) {:dir :down :dist dist})))

(defn parse-moves
  [moves]
  (as-> moves $
    (split $ #",")
    (map parse-move $)))

(defn parse-input
  [input]
  (let [[wirea wireb]
        (-> input
            split-lines)
        
        movesa
        (parse-moves wirea)
        
        movesb
        (parse-moves wireb)]
    [movesa movesb]))

(defn move->xys
  [[x y] {dir :dir dist :dist}]
  (let [d (range 1 (+ 1 dist))]
    (cond
      (= :right dir)
      (for [d d]
        [(+ x d) y])

      (= :left dir)
      (for [d d]
        [(- x d) y])

      (= :up dir)
      (for [d d]
        [x (+ y d)])

      (= :down dir)
      (for [d d]
        [x (- y d)]))))

(defn moves->xys
  [moves]
  (loop [xys []
         origin [0 0]
         moves moves]
    (if (empty? moves)
      xys
      (let [move (first moves)
            new-xys (move->xys origin move)
            xys (apply conj xys new-xys)
            origin (last new-xys)]
        (recur xys origin (rest moves))))))

(defn manhattan-dist
  [[x y]]
  (+ (Math/abs x)
     (Math/abs y)))

(defn find-closest
  [xysa xysb]
  (let [xysa (set xysa)
        xysb (set xysb)
        crossings (intersection xysa xysb)]
    (->> crossings
         (map manhattan-dist)
         (apply min))))

(defn qa
  [input]
  (let [[movesa movesb] (parse-input input)
        xysa (moves->xys movesa)
        xysb (moves->xys movesb)]
    (find-closest xysa xysb)))

(defn signal-delay
  [xy xysa xysb]
  (let [delaya (+ 1 (.indexOf xysa xy))
        delayb (+ 1 (.indexOf xysb xy))]
    (+ delaya delayb)))

(defn find-shortest
  [xysa xysb]
  (let [crossings (difference (intersection (set xysa) (set xysb))
                              #{[0 0]})
        delays (map (fn [xy]
                      (signal-delay xy xysa xysb))
                    crossings)]
    (apply min delays)))

(defn qb
  [input]
  (let [[movesa movesb] (parse-input input)
        xysa (moves->xys movesa)
        xysb (moves->xys movesb)]
    (find-shortest xysa xysb)))

(defn -main
  [filepath]
  (let [input (slurp filepath)]
    (println "qa:" (qa input))
    (println "qb:" (qb input))))
