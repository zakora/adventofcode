(ns day1-test
  (:require [clojure.test :refer [deftest testing is]]
            [day1 :refer :all]))

(deftest qa-examples
  (testing "Fuel amount for 1 module, excluding fuel for the fuel itself"
    (is (= 2 (fuel-amount 12)))
    (is (= 2 (fuel-amount 14)))
    (is (= 654 (fuel-amount 1969)))
    (is (= 33583 (fuel-amount 100756)))))

(deftest qb-examples
  (testing "Total fuel for 1 module to carry its mass plus the fuel itself"
    (is (= 966 (total-fuel 1969)))
    (is (= 50346 (total-fuel 100756)))))
