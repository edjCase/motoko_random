import Iter "mo:core@1/Iter";
import { test } "mo:test";
import Int "mo:core@1/Int";
import Float "mo:core@1/Float";
import List "mo:core@1/List";
import Nat "mo:core@1/Nat";
import PseudoRandomX "../src/PseudoRandomX";
import Runtime "mo:core@1/Runtime";

let assertEqualInt = func(expected : Int, actual : Int) : () {
  if (actual != expected) {
    Runtime.trap("Expected " # Int.toText(expected) # ", got " # Int.toText(actual));
  };
};

let assertEqualFloat = func(expected : Float, actual : Float, epsilon : Float) : () {
  if (Float.abs(actual - expected) > epsilon) {
    Runtime.trap("Expected " # Float.toText(expected) # ", got " # Float.toText(actual));
  };
};

let assertEqualBool = func(expected : Bool, actual : Bool) : () {
  if (actual != expected) {
    Runtime.trap("Expected " # debug_show (expected) # ", got " # debug_show (actual));
  };
};

test(
  "nextInt LCG",
  func() {
    let testCases : [{ seed : Nat32; expected : Int; min : Int; max : Int }] = [
      { seed = 1; expected = 8; min = 0; max = 10 },
      { seed = 2; expected = -2; min = -4; max = 5 },
      { seed = 3; expected = 1018897797; min = -1; max = 1_000_000_000_000_000 },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randInt = rand.nextInt(testCase.min, testCase.max);
      assertEqualInt(testCase.expected, randInt);
    };
  },
);

test(
  "nextInt LCG many",
  func() {
    let rand = PseudoRandomX.fromSeed(1, #linearCongruential);
    let expected = [8, 7, 8, 5, 2, 7, 6, 1, 8, 5, 2, 1, 0, 5, 6, 9, 6, 5, 6, 9, 6, 7, 8, 9, 8, 3, 4, 3, 8, 5, 4, 3, 6, 1, 8, 9, 0, 5, 6, 1, 2, 3, 4, 7, 2, 5, 4, 3, 2, 9, 8, 1, 8, 5, 4, 5, 6, 9, 2, 5, 8, 1, 2, 9, 6, 3, 0, 1, 2, 9, 0, 5, 6, 5, 6, 5, 4, 9, 6, 7, 6, 9, 8, 5, 8, 7, 6, 7, 0, 5, 6, 7, 0, 1, 0, 3, 6, 9, 4, 5, 2, 1, 6, 3, 2, 1, 6, 7, 0, 7, 4, 9, 4, 9, 0, 5, 0, 3, 2, 7, 6, 1, 4, 5, 4, 7, 4, 9, 8, 1, 2, 3, 6, 9, 6, 9, 0, 3, 2, 5, 8, 5, 8, 7, 0, 1, 8, 1, 0, 3, 8, 3, 6, 3, 2, 1, 4, 5, 6, 1, 6, 3, 2, 5, 8, 3, 6, 5, 6, 7, 2, 7, 2, 5, 6, 5, 0, 3, 2, 9, 8, 5, 4, 1, 2, 5, 4, 5, 4, 3, 0, 1, 6, 9, 6, 1, 0, 7, 4, 1, 4, 1, 0, 1, 8, 5, 8, 5, 8, 5, 8, 5, 8, 3, 6, 3, 6, 5, 0, 1, 6, 1, 4, 7, 6, 1, 4, 7, 6, 3, 0, 9, 0, 3, 0, 9, 8, 1, 4, 5, 0, 1, 8, 9, 8, 9, 4, 1, 8, 5, 6, 9, 4, 3, 8, 9, 8, 7, 8, 1, 8, 3, 6, 5, 0, 1, 4, 9, 0, 1, 0, 1, 0, 1, 4, 3, 0, 9, 6, 5, 0, 1, 4, 9, 4, 1, 6, 7, 6, 1, 2, 9, 2, 1, 8, 3, 2, 7, 2, 9, 0, 7, 2, 5, 8, 1, 2, 1, 2, 7, 8, 1, 8, 5, 6, 9, 2, 3, 8, 5, 4, 9, 0, 1, 6, 9, 0, 3, 8, 7, 8, 1, 6, 7, 2, 3, 8, 5, 6, 5, 4, 7, 4, 9, 8, 9, 8, 7, 0, 1, 0, 5, 2, 3, 0, 7, 4, 1, 4, 7, 6, 5, 0, 9, 6, 5, 2, 1, 0, 1, 6, 5, 2, 3, 2, 3, 2, 7, 4, 1, 0, 5, 4, 1, 0, 3, 0, 1, 2, 5, 4, 5, 2, 7, 0, 5, 2, 5, 6, 3, 8, 5, 4, 9, 4, 7, 6, 3, 0, 1, 0, 5, 4, 3, 6, 1, 6, 3, 2, 9, 6, 1, 0, 3, 0, 9, 4, 1, 4, 3, 6, 1, 8, 9, 0, 9, 2, 3, 6, 3, 4, 3, 2, 1, 8, 3, 0, 1, 2, 5, 2, 5, 4, 7, 6, 5, 6, 9, 2, 1, 2, 5, 6, 3, 2, 3, 4, 9, 2, 7, 6, 1, 4, 1, 6, 3, 2, 3, 2, 9, 4, 3, 6, 5, 0, 3, 2, 7, 8, 1, 0, 3, 2, 9, 6, 9, 2, 7, 4, 9, 4, 3, 2, 1, 6, 7, 6, 5, 4, 5, 2, 1, 4, 1, 2, 9, 8, 3, 0, 7, 6, 7, 8, 3, 6, 5, 2, 1, 4, 7, 0, 9, 0, 5, 6, 9, 0, 1, 0, 3, 6, 1, 8, 7, 8, 1, 2, 7, 0, 3, 0, 9, 0, 9, 8, 1, 0, 7, 8, 1, 4, 1, 8, 1, 2, 5, 8, 9, 8, 3, 4, 3, 8, 7, 6, 5, 4, 5, 6, 3, 4, 1, 0, 1, 8, 7, 4, 1, 0, 5, 6, 3, 6, 5, 0, 7, 6, 9, 8, 7, 4, 1, 2, 7, 4, 7, 0, 9, 2, 7, 0, 5, 8, 5, 8, 3, 6, 5, 8, 7, 6, 9, 2, 7, 8, 5, 6, 5, 6, 5, 0, 5, 0, 3, 4, 3, 8, 7, 6, 9, 0, 9, 4, 5, 2, 3, 6, 5, 6, 1, 6, 5, 2, 5, 0, 9, 4, 3, 4, 9, 4, 3, 6, 9, 6, 1, 0, 1, 0, 7, 6, 3, 2, 3, 4, 5, 0, 7, 2, 5, 4, 9, 4, 3, 4, 7, 6, 7, 4, 3, 6, 3, 8, 1, 2, 5, 6, 9, 0, 9, 2, 7, 6, 3, 6, 1, 2, 5, 2, 7, 2, 1, 4, 3, 2, 7, 4, 7, 4, 1, 0, 7, 4, 9, 2, 1, 0, 3, 2, 3, 4, 9, 2, 9, 8, 5, 8, 5, 2, 9, 0, 5, 4, 9, 8, 9, 0, 7, 0, 5, 8, 9, 2, 1, 2, 3, 6, 1, 2, 9, 8, 5, 6, 1, 2, 3, 6, 5, 4, 5, 8, 9, 2, 3, 0, 3, 2, 7, 6, 7, 8, 3, 8, 9, 2, 3, 2, 7, 0, 3, 6, 5, 4, 9, 4, 9, 4, 1, 8, 3, 4, 1, 4, 5, 6, 7, 4, 7, 4, 5, 4, 1, 6, 1, 2, 3, 6, 5, 8, 5, 4, 7, 2, 3, 6, 9, 2, 9, 8, 9, 4, 9, 0, 1, 2, 1, 2, 3, 4, 9, 2, 9, 0, 1, 8, 3, 8, 1, 4, 7, 2, 5, 4, 9, 8, 1, 8, 9, 0, 7, 2, 9, 2, 9, 2, 7, 6, 9, 4, 5, 6, 9, 6, 1, 6, 5, 0, 9, 6, 7, 2, 3, 4, 3, 6, 9, 4, 7, 6, 5, 6, 1, 4, 9, 2, 5, 6, 1, 0, 9, 0, 3, 2, 7, 8, 1, 2, 9, 2, 7, 2, 9, 2, 3, 6, 9, 6, 9, 4, 9, 8, 9, 4, 9, 4, 9, 6, 3, 4, 3, 0, 1, 2, 7, 6, 7, 8, 3, 6, 3, 0, 3, 4, 7, 2, 1, 8, 1, 0, 1, 0, 5, 4, 9, 0, 5, 2, 3, 0, 9, 4, 7, 2, 9, 4, 9, 6, 3, 8, 5, 4, 9, 4, 7, 0, 9, 6, 7, 2, 5, 8, 1, 8, 7, 0, 5, 6, 9, 6, 9, 0, 5, 4, 7, 0, 3, 6, 7, 0, 7, 2];
    for (i in Nat.range(0, 1001)) {
      let randInt = rand.nextInt(0, 10);
      assertEqualInt(expected[i], randInt);
    };
  },
);

test(
  "nextNat LCG",
  func() {
    let testCases : [{ seed : Nat32; expected : Nat; min : Nat; max : Nat }] = [
      { seed = 1; expected = 8; min = 0; max = 10 },
      { seed = 2; expected = 2; min = 1; max = 5 },
      {
        seed = 3;
        expected = 1018997797;
        min = 99999;
        max = 1_000_000_000_000_000;
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randInt = rand.nextNat(testCase.min, testCase.max);
      assertEqualInt(testCase.expected, randInt);
    };
  },
);

test(
  "nextNat LCG many 0-10",
  func() {
    let rand = PseudoRandomX.fromSeed(1, #linearCongruential);
    let expected = [8, 7, 8, 5, 2, 7, 6, 1, 8, 5, 2, 1, 0, 5, 6, 9, 6, 5, 6, 9, 6, 7, 8, 9, 8, 3, 4, 3, 8, 5, 4, 3, 6, 1, 8, 9, 0, 5, 6, 1, 2, 3, 4, 7, 2, 5, 4, 3, 2, 9, 8, 1, 8, 5, 4, 5, 6, 9, 2, 5, 8, 1, 2, 9, 6, 3, 0, 1, 2, 9, 0, 5, 6, 5, 6, 5, 4, 9, 6, 7, 6, 9, 8, 5, 8, 7, 6, 7, 0, 5, 6, 7, 0, 1, 0, 3, 6, 9, 4, 5, 2, 1, 6, 3, 2, 1, 6, 7, 0, 7, 4, 9, 4, 9, 0, 5, 0, 3, 2, 7, 6, 1, 4, 5, 4, 7, 4, 9, 8, 1, 2, 3, 6, 9, 6, 9, 0, 3, 2, 5, 8, 5, 8, 7, 0, 1, 8, 1, 0, 3, 8, 3, 6, 3, 2, 1, 4, 5, 6, 1, 6, 3, 2, 5, 8, 3, 6, 5, 6, 7, 2, 7, 2, 5, 6, 5, 0, 3, 2, 9, 8, 5, 4, 1, 2, 5, 4, 5, 4, 3, 0, 1, 6, 9, 6, 1, 0, 7, 4, 1, 4, 1, 0, 1, 8, 5, 8, 5, 8, 5, 8, 5, 8, 3, 6, 3, 6, 5, 0, 1, 6, 1, 4, 7, 6, 1, 4, 7, 6, 3, 0, 9, 0, 3, 0, 9, 8, 1, 4, 5, 0, 1, 8, 9, 8, 9, 4, 1, 8, 5, 6, 9, 4, 3, 8, 9, 8, 7, 8, 1, 8, 3, 6, 5, 0, 1, 4, 9, 0, 1, 0, 1, 0, 1, 4, 3, 0, 9, 6, 5, 0, 1, 4, 9, 4, 1, 6, 7, 6, 1, 2, 9, 2, 1, 8, 3, 2, 7, 2, 9, 0, 7, 2, 5, 8, 1, 2, 1, 2, 7, 8, 1, 8, 5, 6, 9, 2, 3, 8, 5, 4, 9, 0, 1, 6, 9, 0, 3, 8, 7, 8, 1, 6, 7, 2, 3, 8, 5, 6, 5, 4, 7, 4, 9, 8, 9, 8, 7, 0, 1, 0, 5, 2, 3, 0, 7, 4, 1, 4, 7, 6, 5, 0, 9, 6, 5, 2, 1, 0, 1, 6, 5, 2, 3, 2, 3, 2, 7, 4, 1, 0, 5, 4, 1, 0, 3, 0, 1, 2, 5, 4, 5, 2, 7, 0, 5, 2, 5, 6, 3, 8, 5, 4, 9, 4, 7, 6, 3, 0, 1, 0, 5, 4, 3, 6, 1, 6, 3, 2, 9, 6, 1, 0, 3, 0, 9, 4, 1, 4, 3, 6, 1, 8, 9, 0, 9, 2, 3, 6, 3, 4, 3, 2, 1, 8, 3, 0, 1, 2, 5, 2, 5, 4, 7, 6, 5, 6, 9, 2, 1, 2, 5, 6, 3, 2, 3, 4, 9, 2, 7, 6, 1, 4, 1, 6, 3, 2, 3, 2, 9, 4, 3, 6, 5, 0, 3, 2, 7, 8, 1, 0, 3, 2, 9, 6, 9, 2, 7, 4, 9, 4, 3, 2, 1, 6, 7, 6, 5, 4, 5, 2, 1, 4, 1, 2, 9, 8, 3, 0, 7, 6, 7, 8, 3, 6, 5, 2, 1, 4, 7, 0, 9, 0, 5, 6, 9, 0, 1, 0, 3, 6, 1, 8, 7, 8, 1, 2, 7, 0, 3, 0, 9, 0, 9, 8, 1, 0, 7, 8, 1, 4, 1, 8, 1, 2, 5, 8, 9, 8, 3, 4, 3, 8, 7, 6, 5, 4, 5, 6, 3, 4, 1, 0, 1, 8, 7, 4, 1, 0, 5, 6, 3, 6, 5, 0, 7, 6, 9, 8, 7, 4, 1, 2, 7, 4, 7, 0, 9, 2, 7, 0, 5, 8, 5, 8, 3, 6, 5, 8, 7, 6, 9, 2, 7, 8, 5, 6, 5, 6, 5, 0, 5, 0, 3, 4, 3, 8, 7, 6, 9, 0, 9, 4, 5, 2, 3, 6, 5, 6, 1, 6, 5, 2, 5, 0, 9, 4, 3, 4, 9, 4, 3, 6, 9, 6, 1, 0, 1, 0, 7, 6, 3, 2, 3, 4, 5, 0, 7, 2, 5, 4, 9, 4, 3, 4, 7, 6, 7, 4, 3, 6, 3, 8, 1, 2, 5, 6, 9, 0, 9, 2, 7, 6, 3, 6, 1, 2, 5, 2, 7, 2, 1, 4, 3, 2, 7, 4, 7, 4, 1, 0, 7, 4, 9, 2, 1, 0, 3, 2, 3, 4, 9, 2, 9, 8, 5, 8, 5, 2, 9, 0, 5, 4, 9, 8, 9, 0, 7, 0, 5, 8, 9, 2, 1, 2, 3, 6, 1, 2, 9, 8, 5, 6, 1, 2, 3, 6, 5, 4, 5, 8, 9, 2, 3, 0, 3, 2, 7, 6, 7, 8, 3, 8, 9, 2, 3, 2, 7, 0, 3, 6, 5, 4, 9, 4, 9, 4, 1, 8, 3, 4, 1, 4, 5, 6, 7, 4, 7, 4, 5, 4, 1, 6, 1, 2, 3, 6, 5, 8, 5, 4, 7, 2, 3, 6, 9, 2, 9, 8, 9, 4, 9, 0, 1, 2, 1, 2, 3, 4, 9, 2, 9, 0, 1, 8, 3, 8, 1, 4, 7, 2, 5, 4, 9, 8, 1, 8, 9, 0, 7, 2, 9, 2, 9, 2, 7, 6, 9, 4, 5, 6, 9, 6, 1, 6, 5, 0, 9, 6, 7, 2, 3, 4, 3, 6, 9, 4, 7, 6, 5, 6, 1, 4, 9, 2, 5, 6, 1, 0, 9, 0, 3, 2, 7, 8, 1, 2, 9, 2, 7, 2, 9, 2, 3, 6, 9, 6, 9, 4, 9, 8, 9, 4, 9, 4, 9, 6, 3, 4, 3, 0, 1, 2, 7, 6, 7, 8, 3, 6, 3, 0, 3, 4, 7, 2, 1, 8, 1, 0, 1, 0, 5, 4, 9, 0, 5, 2, 3, 0, 9, 4, 7, 2, 9, 4, 9, 6, 3, 8, 5, 4, 9, 4, 7, 0, 9, 6, 7, 2, 5, 8, 1, 8, 7, 0, 5, 6, 9, 6, 9, 0, 5, 4, 7, 0, 3, 6, 7, 0, 7, 2];
    for (i in Nat.range(0, 1001)) {
      let randInt = rand.nextNat(0, 10);
      assertEqualInt(expected[i], randInt);
    };
  },
);
test(
  "nextNat LCG many 0-3",
  func() {
    let rand = PseudoRandomX.fromSeed(1, #linearCongruential);
    let expected = [0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0];
    for (i in Nat.range(0, 1001)) {
      let randInt = rand.nextNat(0, 4);
      assertEqualInt(expected[i], randInt);
    };
  },
);

test(
  "nextNat Xorshift32 many 0-3",
  func() {
    let rand = PseudoRandomX.fromSeed(2, #xorshift32);
    let expected = [2, 2, 2, 2, 2, 3, 1, 2, 2, 3, 2, 1, 1, 0, 2, 2, 3, 3, 1, 3, 0, 0, 2, 1, 3, 0, 0, 1, 0, 1, 3, 3, 1, 3, 1, 2, 2, 3, 1, 1, 0, 1, 1, 2, 2, 3, 0, 0, 0, 3, 2, 0, 0, 2, 3, 3, 0, 1, 1, 1, 1, 3, 0, 2, 2, 0, 2, 2, 1, 1, 3, 3, 0, 2, 1, 3, 1, 2, 1, 2, 0, 2, 3, 2, 1, 3, 3, 1, 3, 2, 0, 3, 3, 2, 0, 2, 1, 0, 1, 3, 3, 3, 1, 0, 1, 3, 2, 0, 3, 1, 1, 0, 1, 3, 0, 2, 1, 1, 2, 3, 1, 1, 3, 3, 1, 0, 1, 1, 3, 3, 1, 0, 2, 3, 1, 2, 2, 1, 3, 2, 2, 2, 2, 2, 1, 0, 0, 0, 0, 2, 3, 2, 0, 2, 1, 1, 1, 0, 2, 1, 1, 0, 3, 0, 2, 1, 3, 3, 2, 2, 3, 2, 2, 0, 2, 2, 3, 0, 3, 1, 3, 0, 2, 2, 3, 0, 0, 3, 1, 3, 2, 2, 1, 2, 2, 3, 0, 0, 2, 3, 1, 1, 3, 2, 2, 0, 1, 2, 2, 2, 2, 0, 0, 0, 3, 1, 0, 0, 1, 0, 1, 3, 3, 0, 1, 3, 3, 2, 3, 0, 2, 2, 3, 0, 0, 1, 3, 0, 1, 2, 3, 3, 1, 1, 0, 1, 1, 0, 2, 1, 0, 3, 0, 3, 3, 2, 2, 0, 0, 1, 0, 3, 2, 1, 1, 2, 0, 3, 0, 0, 3, 2, 0, 3, 3, 1, 1, 0, 1, 0, 3, 3, 2, 0, 2, 2, 1, 3, 3, 1, 0, 0, 3, 0, 3, 0, 1, 3, 3, 1, 3, 2, 3, 3, 2, 1, 2, 0, 0, 0, 3, 1, 0, 1, 3, 1, 1, 2, 1, 2, 0, 2, 1, 1, 3, 2, 1, 1, 1, 3, 1, 2, 0, 1, 1, 1, 0, 1, 1, 3, 1, 1, 1, 1, 2, 1, 3, 3, 1, 0, 0, 3, 1, 0, 0, 0, 3, 3, 2, 2, 1, 1, 0, 3, 2, 3, 2, 0, 3, 3, 1, 2, 1, 1, 2, 0, 1, 1, 2, 1, 0, 0, 3, 2, 0, 0, 2, 2, 0, 1, 3, 2, 0, 1, 1, 3, 0, 1, 1, 3, 0, 1, 3, 1, 2, 0, 0, 1, 1, 1, 1, 2, 3, 2, 0, 2, 1, 0, 2, 3, 3, 0, 0, 3, 2, 3, 1, 2, 1, 0, 1, 3, 1, 0, 2, 3, 2, 1, 3, 1, 3, 3, 3, 1, 1, 3, 2, 3, 2, 1, 1, 1, 0, 3, 2, 3, 2, 2, 1, 1, 1, 3, 0, 3, 2, 2, 0, 1, 0, 3, 1, 0, 1, 2, 0, 0, 3, 3, 1, 0, 1, 1, 1, 3, 2, 1, 0, 0, 3, 1, 0, 1, 0, 0, 2, 3, 0, 2, 1, 0, 2, 1, 2, 0, 1, 3, 0, 3, 1, 3, 3, 1, 1, 2, 0, 1, 2, 0, 1, 3, 3, 0, 1, 3, 1, 1, 1, 3, 2, 0, 1, 3, 1, 2, 2, 3, 0, 1, 2, 2, 2, 0, 1, 3, 3, 2, 3, 3, 2, 2, 2, 3, 0, 2, 3, 2, 1, 0, 3, 3, 1, 3, 0, 0, 2, 0, 3, 2, 0, 1, 3, 3, 0, 0, 0, 2, 2, 1, 0, 0, 1, 2, 1, 0, 0, 3, 2, 1, 0, 1, 2, 1, 3, 0, 2, 2, 1, 2, 2, 3, 1, 3, 1, 3, 0, 2, 2, 1, 0, 0, 2, 2, 3, 0, 0, 2, 0, 0, 3, 3, 3, 3, 3, 1, 2, 0, 3, 2, 0, 3, 2, 2, 1, 1, 2, 3, 1, 3, 1, 2, 0, 2, 2, 0, 1, 0, 2, 2, 1, 3, 1, 1, 0, 2, 1, 0, 3, 3, 2, 2, 1, 3, 0, 1, 3, 1, 2, 2, 0, 3, 0, 1, 1, 0, 3, 2, 2, 2, 3, 2, 0, 0, 2, 3, 2, 1, 3, 1, 2, 2, 1, 1, 2, 2, 2, 1, 0, 0, 3, 1, 3, 0, 2, 3, 2, 1, 2, 0, 0, 1, 3, 0, 3, 2, 2, 0, 1, 0, 1, 0, 3, 1, 1, 0, 0, 1, 0, 3, 1, 0, 0, 3, 1, 0, 0, 3, 3, 0, 1, 0, 0, 2, 2, 1, 2, 3, 1, 0, 2, 3, 2, 2, 3, 3, 1, 3, 1, 1, 1, 2, 1, 3, 3, 3, 0, 1, 0, 1, 3, 2, 3, 1, 0, 0, 2, 3, 2, 2, 0, 1, 3, 1, 2, 0, 0, 0, 2, 2, 0, 2, 2, 0, 3, 1, 0, 3, 1, 0, 1, 0, 3, 1, 2, 1, 3, 1, 2, 2, 1, 0, 3, 3, 3, 2, 2, 2, 2, 0, 3, 2, 3, 0, 2, 2, 2, 3, 1, 1, 2, 2, 0, 0, 3, 0, 3, 0, 2, 1, 3, 3, 0, 1, 3, 1, 1, 1, 3, 0, 3, 3, 0, 3, 3, 1, 3, 3, 1, 2, 1, 1, 0, 2, 2, 3, 0, 1, 3, 0, 1, 1, 0, 0, 0, 3, 2, 1, 2, 3, 0, 3, 1, 1, 1, 3, 1, 2, 0, 2, 3, 0, 1, 3, 1, 3, 3, 2, 0, 0, 0, 3, 1, 2, 1, 0, 3, 3, 3, 3, 1, 3, 0, 0, 0, 1, 0, 3, 3, 2, 0, 3, 0, 3, 3, 0, 1, 2, 2, 1, 1, 1, 0, 2, 0, 2, 2, 0, 2, 2, 3, 0, 1, 2, 0, 0, 1, 3, 2, 2, 0, 3, 1, 2, 3, 0, 3, 2, 0, 3, 3, 1, 1, 1, 2, 3, 2, 3, 0, 3, 0, 0, 0, 0, 0, 3, 1, 3, 3, 2, 2, 3, 1, 0, 2, 3, 1, 2, 0, 3, 1, 1, 2, 1, 1, 0, 0, 2, 2, 2, 1, 0, 3];
    for (i in Nat.range(0, 1001)) {
      let randInt = rand.nextNat(0, 4);
      assertEqualInt(expected[i], randInt);
    };
  },
);

test(
  "nextFloat",
  func() {
    let testCases : [{
      seed : Nat32;
      expected : Float;
      min : Float;
      max : Float;
    }] = [
      { seed = 1; expected = 0.236_455_525_326_648_62; min = 0.0; max = 1.0 },
      { seed = 2; expected = -1.868_412_300_215_198_7; min = -4.0; max = 5.0 },
      {
        seed = 3;
        expected = 237_230_630_181.084_99;
        min = 0.0;
        max = 1_000_000_000_000.0;
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randFloat = rand.nextFloat(testCase.min, testCase.max);
      assertEqualFloat(testCase.expected, randFloat, 0.000001);
    };
  },
);

test(
  "nextCoin",
  func() {
    let testCases : [{ seed : Nat32; expected : Bool }] = [
      { seed = 1; expected = true },
      { seed = 2; expected = false },
      { seed = 3; expected = true },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randBool = rand.nextCoin();
      assertEqualBool(testCase.expected, randBool);
    };
  },
);

test(
  "nextRatio",
  func() {
    let testCases : [{
      seed : Nat32;
      expected : Bool;
      trueCount : Nat;
      totalCount : Nat;
    }] = [
      { seed = 1; expected = true; trueCount = 1; totalCount = 2 },
      { seed = 2; expected = false; trueCount = 1; totalCount = 3 },
      { seed = 3; expected = true; trueCount = 2; totalCount = 3 },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randBool = rand.nextRatio(testCase.trueCount, testCase.totalCount);
      assertEqualBool(testCase.expected, randBool);
    };
  },
);

test(
  "nextListElement",
  func() {
    let testCases : [{
      seed : Nat32;
      expected : Int;
      list : List.List<Int>;
    }] = [
      { seed = 1; expected = 1; list = List.fromArray<Int>([1, 2, 3]) },
      { seed = 2; expected = 6; list = List.fromArray<Int>([4, 5, 6]) },
      { seed = 3; expected = 8; list = List.fromArray<Int>([7, 8, 9]) },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randElement = rand.nextListElement(testCase.list);
      assertEqualInt(testCase.expected, randElement);
    };
  },
);

test(
  "nextArrayElement",
  func() {
    let testCases : [{ seed : Nat32; expected : Int; array : [Int] }] = [
      { seed = 1; expected = 1; array = [1, 2, 3] },
      { seed = 2; expected = 6; array = [4, 5, 6] },
      { seed = 3; expected = 8; array = [7, 8, 9] },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randElement = rand.nextArrayElement(testCase.array);
      assertEqualInt(testCase.expected, randElement);
    };
  },
);

test(
  "nextArrayElementWeighted",
  func() {
    let testCases : [{ seed : Nat32; expected : Int; array : [(Int, Float)] }] = [
      { seed = 1; expected = 2; array = [(1, 0.1), (2, 0.7), (3, 0.2)] },
      { seed = 2; expected = 4; array = [(4, 0.5), (5, 0.3), (6, 0.2)] },
      { seed = 3; expected = 9; array = [(7, 0.1), (8, 0.1), (9, 0.8)] },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randElement = rand.nextArrayElementWeighted(testCase.array);
      assertEqualInt(testCase.expected, randElement);
    };
  },
);

test(
  "nextArrayElementWeightedFunc",
  func() {
    let testCases : [{
      seed : Nat32;
      expected : Int;
      array : [Int];
      weightFunc : (Int) -> Float;
    }] = [
      {
        seed = 1;
        expected = 2;
        array = [1, 2, 3];
        weightFunc = func(x : Int) : Float { Float.fromInt(x) / 6.0 };
      },
      {
        seed = 2;
        expected = 4;
        array = [4, 5, 6];
        weightFunc = func(x : Int) : Float { 1.0 / Float.fromInt(x) };
      },
      {
        seed = 3;
        expected = 7;
        array = [7, 8, 9];
        weightFunc = func(x : Int) : Float {
          Float.fromInt(x) * Float.fromInt(x) / 244.0;
        };
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let randElement = rand.nextArrayElementWeightedFunc(testCase.array, testCase.weightFunc);
      assertEqualInt(testCase.expected, randElement);
    };
  },
);

test(
  "shuffleList",
  func() {
    let testCases : [{ seed : Nat32; expected : [Int]; input : [Int] }] = [
      { seed = 1; expected = [3, 2, 1]; input = [1, 2, 3] },
      { seed = 2; expected = [5, 4, 6]; input = [4, 5, 6] },
      { seed = 3; expected = [7, 9, 8]; input = [7, 8, 9] },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed, #linearCongruential);
      let list = List.fromArray<Int>(testCase.input);
      rand.shuffleList(list);
      for (i in Nat.range(0, List.size(list))) {
        assertEqualInt(testCase.expected[i], List.at(list, i));
      };
    };
  },
);
