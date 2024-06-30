import Iter "mo:base/Iter";
import { test } "mo:test";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Buffer "mo:base/Buffer";
import PseudoRandomX "../src/PseudoRandomX";

let assertEqualInt = func(expected : Int, actual : Int) : () {
  if (actual != expected) {
    Debug.trap("Expected " # Int.toText(expected) # ", got " # Int.toText(actual));
  };
};

let assertEqualFloat = func(expected : Float, actual : Float, epsilon : Float) : () {
  if (Float.abs(actual - expected) > epsilon) {
    Debug.trap("Expected " # Float.toText(expected) # ", got " # Float.toText(actual));
  };
};

let assertEqualBool = func(expected : Bool, actual : Bool) : () {
  if (actual != expected) {
    Debug.trap("Expected " # debug_show (expected) # ", got " # debug_show (actual));
  };
};

test(
  "nextInt",
  func() {
    let testCases : [{ seed : Nat32; expected : Int; min : Int; max : Int }] = [
      { seed = 1; expected = 7; min = 0; max = 10 },
      { seed = 2; expected = -1; min = -4; max = 5 },
      { seed = 3; expected = 1018897797; min = -1; max = 1_000_000_000_000_000 },
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
      { seed = 1; expected = 7; min = 0; max = 10 },
      { seed = 2; expected = 4; min = 1; max = 5 },
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
      let rand = PseudoRandomX.fromSeed(testCase.seed);
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
      let rand = PseudoRandomX.fromSeed(testCase.seed);
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
      let rand = PseudoRandomX.fromSeed(testCase.seed);
      let randBool = rand.nextRatio(testCase.trueCount, testCase.totalCount);
      assertEqualBool(testCase.expected, randBool);
    };
  },
);

test(
  "nextBufferElement",
  func() {
    let testCases : [{
      seed : Nat32;
      expected : Int;
      buffer : Buffer.Buffer<Int>;
    }] = [
      { seed = 1; expected = 1; buffer = Buffer.fromArray<Int>([1, 2, 3]) },
      { seed = 2; expected = 6; buffer = Buffer.fromArray<Int>([4, 5, 6]) },
      { seed = 3; expected = 8; buffer = Buffer.fromArray<Int>([7, 8, 9]) },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed);
      let randElement = rand.nextBufferElement(testCase.buffer);
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
      let rand = PseudoRandomX.fromSeed(testCase.seed);
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
      let rand = PseudoRandomX.fromSeed(testCase.seed);
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
      let rand = PseudoRandomX.fromSeed(testCase.seed);
      let randElement = rand.nextArrayElementWeightedFunc(testCase.array, testCase.weightFunc);
      assertEqualInt(testCase.expected, randElement);
    };
  },
);

test(
  "shuffleBuffer",
  func() {
    let testCases : [{ seed : Nat32; expected : [Int]; input : [Int] }] = [
      { seed = 1; expected = [1, 2, 3]; input = [1, 2, 3] },
      { seed = 2; expected = [5, 6, 4]; input = [4, 5, 6] },
      { seed = 3; expected = [9, 7, 8]; input = [7, 8, 9] },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = PseudoRandomX.fromSeed(testCase.seed);
      let buffer = Buffer.fromArray<Int>(testCase.input);
      rand.shuffleBuffer(buffer);
      for (i in Iter.range(0, buffer.size() - 1)) {
        assertEqualInt(testCase.expected[i], buffer.get(i));
      };
    };
  },
);
