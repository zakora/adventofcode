(ns day2-test
  (:require [clojure.test :refer [deftest testing is]]
            [day2 :refer :all]))

(deftest qa-examples
  (testing "Running intcodes"
    (is (= "3500,9,10,70,2,3,11,0,99,30,40,50"
           (-> "1,9,10,3,2,3,11,0,99,30,40,50"
               str->intcode
               run-intcode
               intcode->str)))
    (is (= "2,0,0,0,99"
           (-> "1,0,0,0,99"
               str->intcode
               run-intcode
               intcode->str)))
    (is (= "2,4,4,5,99,9801"
           (-> "2,4,4,5,99,0"
               str->intcode
               run-intcode
               intcode->str)))
    (is (= "30,1,1,4,2,5,6,0,99"
           (-> "1,1,1,4,99,5,6,0,99"
               str->intcode
               run-intcode
               intcode->str)))))
