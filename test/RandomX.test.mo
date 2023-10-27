import Iter "mo:base/Iter";
import { test } "mo:test";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import PseudoRandomX "../src/PseudoRandomX";

let assertEqualInt = func(expected : Int, actual : Int) : () {
  if (actual != expected) {
    Debug.trap("Expected " # Int.toText(expected) # ", got " # Int.toText(actual));
  };
};

test(
  "nextInt",
  func() {
    let testCases : [{ seed : Nat32; expected : Int; min : Int; max : Int }] = [
      {
        seed = 1;
        expected = 7;
        min = 0;
        max = 10;
      },
      {
        seed = 2;
        expected = -1;
        min = -4;
        max = 5;
      },
      {
        seed = 3;
        expected = 1018897797;
        min = -1;
        max = 1_000_000_000_000_000;
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed);
      let randInt = rand.nextInt(testCase.min, testCase.max);
      assertEqualInt(testCase.expected, randInt);
    };
  },
);

test(
  "nextNat",
  func() {
    let testCases : [{ seed : Nat32; expected : Nat; min : Nat; max : Nat }] = [
      {
        seed = 1;
        expected = 7;
        min = 0;
        max = 10;
      },
      {
        seed = 2;
        expected = 4;
        min = 1;
        max = 5;
      },
      {
        seed = 3;
        expected = 1018997797;
        min = 99999;
        max = 1_000_000_000_000_000;
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed);
      let randInt = rand.nextNat(testCase.min, testCase.max);
      assertEqualInt(testCase.expected, randInt);
    };
  },
);
