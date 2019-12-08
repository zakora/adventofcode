;;;
;;; INTCODE COMPUTER
;;;

;; OPCODES

;; 1 x y z
;; -> adds

;; 2 x y z
;; -> multiplies

;; 3 x
;; input
;; -> stores

;; 4 x
;; output
;; -> outputs

;; 99
;; -> halt


;; MODES

;; 0 position mode
;; -> x is the adress of a value

;; 1 immediate mode
;; -> x is the value
;; (can't be this mode for writing)


;; POINTER
;; Increment by the number of values in the isntruction

;; EXAMPLE
;; RtL parameter modeS|opcode 
;;                  --|--
;;                  10_02


;;;
;;; STATES
;;;

;; INTCODE
;; [x1, x2, x3, ...]  list of ints

;; INSTRUCTION
;; [:inst-name [mode1 param1  mode2 param2  ...]]

(ns day5
  (:require [clojure.string :refer [split]]))


;; TODO
;; each opcode has a specific set of arguments
;; --> get the modes by leveraging the knowledge that we have X args for speficic opcodes
(defn parse-instr
  "Parse an instruction from an int"
  [int]
  (let [s (str int)
        stop (count s)
        modes (subs s 0 (- stop 2))
        opcode (subs s (- stop 2))
        modes (-> modes (split #"") reverse)]
    [(cond
       (= opcode "01") :add
       (= opcode "02") :multiply
       (= opcode "03") :store
       (= opcode "04") :output
       (= opcode "99") :halt)

     (map #(if (= % "0")
             :position
             :immediate)
          modes)]))
      


(defn -main
  []
  (println "hello"))
