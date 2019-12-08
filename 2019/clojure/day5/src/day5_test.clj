(ns day5-test
  (:require [clojure.test :refer [deftest is testing]]
            [clojure.string :refer [split]]
            [day5 :refer :all]))

(deftest qa
  (testing "Instruction parser"
    (is (= [:multiply [:position :immediate :position]]
           (parse-instr 1002)))
    (is (= [:add [:immediate :position :position]]
           (parse-instr 101))))
  
  ;; (testing "Intcode parser"
  ;;   (is (= [:multiply [:position 4 :immediate 3 :position 4]]
  ;;          (-> "1002,4,3,4,33"
  ;;              (split #",")
  ;;              parse-instr)
  ;;   (is (= [:add [:immediate 5 :position 6 :position 7]]
  ;;          (-> "101,5,6,7"
  ;;              (split #",")
  ;;              parse-instr)))))
  ;;   ))
    
  ;; (testing "Output its input"
  ;;   (is (= 1 (run "3,0,4,0,99" 1)))
  ;;   (is (= 0 (run "3,0,4,0,99" 0)))
  ;;   (is (= -1 (run "3,0,4,0,99" -1)))
  ;;   (is (= 1234 (run "3,0,4,0,99" 1234)))

    )
