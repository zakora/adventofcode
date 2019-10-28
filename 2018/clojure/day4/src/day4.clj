(ns day4
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

(defn parse-record
  "Parse the time components of a record"
  [line]
  (let [log (subs line 19)
        action (cond
                 (str/ends-with? line "falls asleep") :sleep
                 (str/ends-with? line "wakes up") :wake
                 :else :begin-shift)
        guard (if (= action :begin-shift)
                (as-> line l
                  (re-find #"#\d+" l)
                  (subs l 1)
                  (Integer/parseInt l))
                nil)]
    {:year  (-> line (subs 1 5) (Integer/parseInt))
     :month (-> line (subs 6 8) (Integer/parseInt))
     :day   (-> line (subs 9 11) (Integer/parseInt))
     :hour  (-> line (subs 12 14) (Integer/parseInt))
     :min   (-> line (subs 15 17) (Integer/parseInt))
     :guard guard
     :action action}))

(defn compare-time
  "Compare the time of 2 record strings"
  [a b]
  (let [la (parse-record a)
        lb (parse-record b)]
    (cond
      (< (:year la) (:year lb)) -1
      (> (:year la) (:year lb)) 1
      (< (:month la) (:month lb)) -1
      (> (:month la) (:month lb)) 1
      (< (:day la) (:day lb)) -1
      (> (:day la) (:day lb)) 1
      (< (:hour la) (:hour lb)) -1
      (> (:hour la) (:hour lb)) 1
      (< (:min la) (:min lb)) -1
      (> (:min la) (:min lb)) 1
      :else 0)))

(defn sort-by-time
  "Sort the given lines by their time, from newest to oldest"
  [lines]
  (->> lines (sort compare-time) (map parse-record)))

(defn associate-record
  "Parse the given record and associate it to a guard"
  [{:keys [guard groups :as original]} record]
  (if (= (:action record) :begin-shift)
    {:guard (:guard record) :groups groups}
    (let [guard-logs (get groups guard)]
      {:guard guard
       :groups (->> record
                    (conj guard-logs)
                    (assoc groups guard))})))

(defn expand-minutes-asleep
  "Compute the minutes asleep for a guard given its records.

  The provided records must be sorted from newest to oldest.
  Ignoring hour, assuming guards sleep only between 00:00 and 00:59.

  Data in:
    ({:year ... :hour :min :guard :action}, ...)

  Data out:
    (yy, yy+1, y+10, y+11, ...)
  "
  [records]
  (loop [records records
         minutes '()]
    (if (empty? records)
      minutes
      (let [ra (-> records first (get :min))
            rb (-> records second (get :min))
            minutes (concat (range rb ra) minutes)]
        (recur (nthrest records 2) minutes)))))

(defn find-minutes-asleep
  "Find minutes asleep for each guard"
  [map-minutes]
  (into {} (for [[guard minutes] map-minutes]
             [guard (-> minutes
                        expand-minutes-asleep)])))

(defn qa
  [lines]
  (let [guards-minutes
        (->> lines
             sort-by-time
             (reduce associate-record {:guard nil :groups {}})
             :groups
             find-minutes-asleep)

        sleepest-guard
        (->> (into {} (for [[guard minutes] guards-minutes]
                       [guard (count minutes)]))
             (sort-by (fn [kv] (second kv)))
             last
             first)

        sleepest-minute
        (->> sleepest-guard
             (get guards-minutes)
             (group-by identity)
             vals
             (sort-by count)
             last
             first)]
    (* sleepest-guard sleepest-minute)))

(defn qb
  "Find guard with is the most frequently asleep on the same minute"
  [lines]
  (let [guards-minutes
        (->> lines
             sort-by-time
             (reduce associate-record {:guard nil :groups {}})
             :groups
             find-minutes-asleep)

        guards-sleepest-minute
        (->> (into {} (for [[guard minutes] guards-minutes]
                        [guard (->> (frequencies minutes)
                                    (sort-by (fn [kv] (- (second kv))))
                                    first)])))

        guards-sorted
        (sort-by
         (fn [gmc]
           (let [[guard [minute cnt]] gmc]
             (- cnt)))
         guards-sleepest-minute)

        id-minute
        (let [[guard [minute _]] (first guards-sorted)]
          (* guard minute))
        ]
    id-minute))

(defn -main
  []
  (let [lines (get-lines)]
    (->> lines
        qa
        (println "qa: "))
    (->> lines
        qb
        (println "qb: "))))

