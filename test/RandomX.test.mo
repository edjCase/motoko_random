import Iter "mo:core/Iter";
import { test } "mo:test";
import Int "mo:core/Int";
import List "mo:core/List";
import RandomX "../src/RandomX";
import Runtime "mo:core/Runtime";
import Random "mo:core/Random";
import Float "mo:core/Float";
import Array "mo:core/Array";

let assertNotNull = func<T>(value : ?T) : () {
  switch (value) {
    case (null) { Runtime.trap("Expected non-null value, got null") };
    case (_) {};
  };
};

test(
  "nextRatio",
  func() {
    let testCases : [{
      seed : Nat64;
      trueCount : Nat;
      totalCount : Nat;
    }] = [
      { seed = 1; trueCount = 1; totalCount = 2 },
      { seed = 2; trueCount = 1; totalCount = 3 },
      { seed = 3; trueCount = 2; totalCount = 3 },
    ];
    for (testCase in testCases.vals()) {
      let random = Random.seed(testCase.seed);
      let randBool = RandomX.nextRatio(random, testCase.trueCount, testCase.totalCount);
      assertNotNull(?randBool);
    };
  },
);

test(
  "shuffleList",
  func() {
    let testCases : [{ seed : Nat64; input : [Int] }] = [
      { seed = 1; input = [1, 2, 3] },
      { seed = 2; input = [4, 5, 6] },
      { seed = 3; input = [7, 8, 9] },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let random = Random.seed(testCase.seed);
      let list = List.fromArray<Int>(testCase.input);
      RandomX.shuffleList(random, list);
      assert (List.size(list) == testCase.input.size());
      // Check that all elements are still present (in any order)
      for (item in testCase.input.vals()) {
        assert (List.contains<Int>(list, Int.equal, item));
      };
    };
  },
);

test(
  "nextFloat",
  func() {
    let testCases : [{
      seed : Nat64;
      min : Float;
      max : Float;
    }] = [
      { seed = 1; min = 0.0; max = 1.0 },
      { seed = 2; min = -5.0; max = 5.0 },
      { seed = 3; min = 10.0; max = 20.0 },
    ];
    for (testCase in testCases.vals()) {
      let random = Random.seed(testCase.seed);
      let result = RandomX.nextFloat(random, testCase.min, testCase.max);
      assert (result >= testCase.min and result < testCase.max);
    };
  },
);

test(
  "nextFloat_equalMinMax",
  func() {
    let random = Random.seed(123);
    let value = 5.5;
    let result = RandomX.nextFloat(random, value, value);
    assert (result == value);
  },
);

test(
  "nextListElement",
  func() {
    let testCases : [{ seed : Nat64; input : [Int] }] = [
      { seed = 1; input = [1, 2, 3] },
      { seed = 2; input = [4, 5, 6] },
      { seed = 3; input = [7, 8, 9, 10] },
    ];
    for (testCase in testCases.vals()) {
      let random = Random.seed(testCase.seed);
      let list = List.fromArray<Int>(testCase.input);
      let result = RandomX.nextListElement(random, list);
      assert (Array.find<Int>(testCase.input, func(x) = x == result) != null);
    };
  },
);

test(
  "nextArrayElement",
  func() {
    let testCases : [{ seed : Nat64; input : [Int] }] = [
      { seed = 1; input = [1, 2, 3] },
      { seed = 2; input = [4, 5, 6] },
      { seed = 3; input = [7, 8, 9, 10] },
    ];
    for (testCase in testCases.vals()) {
      let random = Random.seed(testCase.seed);
      let result = RandomX.nextArrayElement(random, testCase.input);
      assert (Array.find<Int>(testCase.input, func(x) = x == result) != null);
    };
  },
);

test(
  "nextArrayElementWeighted",
  func() {
    let testCases : [{
      seed : Nat64;
      input : [(Int, Float)];
    }] = [
      { seed = 1; input = [(1, 0.5), (2, 0.3), (3, 0.2)] },
      { seed = 2; input = [(4, 1.0), (5, 2.0), (6, 3.0)] },
      { seed = 3; input = [(7, 0.1), (8, 0.9)] },
    ];
    for (testCase in testCases.vals()) {
      let random = Random.seed(testCase.seed);
      let result = RandomX.nextArrayElementWeighted(random, testCase.input);
      let found = Array.find<(Int, Float)>(testCase.input, func((x, _)) = x == result);
      assert (found != null);
    };
  },
);

test(
  "nextArrayElementWeightedFunc",
  func() {
    let testCases : [{ seed : Nat64; input : [Int] }] = [
      { seed = 1; input = [1, 2, 3] },
      { seed = 2; input = [4, 5, 6] },
      { seed = 3; input = [7, 8, 9] },
    ];
    let weightFunc = func(x : Int) : Float { Float.fromInt(x) };
    for (testCase in testCases.vals()) {
      let random = Random.seed(testCase.seed);
      let result = RandomX.nextArrayElementWeightedFunc(random, testCase.input, weightFunc);
      assert (Array.find<Int>(testCase.input, func(x) = x == result) != null);
    };
  },
);
