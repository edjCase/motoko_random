import Iter "mo:base/Iter";
import { test } "mo:test";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import RandomX "../src/RandomX";

let assertEqualInt = func(expected : Int, actual : Int) : () {
  if (actual != expected) {
    Debug.trap("Expected " # Int.toText(expected) # ", got " # Int.toText(actual));
  };
};

let assertEqualNat = func(expected : Nat, actual : Nat) : () {
  if (actual != expected) {
    Debug.trap("Expected " # Int.toText(expected) # ", got " # Int.toText(actual));
  };
};

let assertEqualBool = func(expected : Bool, actual : Bool) : () {
  if (actual != expected) {
    Debug.trap("Expected " # debug_show (expected) # ", got " # debug_show (actual));
  };
};

let assertNotNull = func<T>(value : ?T) : () {
  switch (value) {
    case (null) { Debug.trap("Expected non-null value, got null") };
    case (_) {};
  };
};

// Helper function to create a Blob from a Nat32
func blobFromNat32(n : Nat32) : Blob {
  let bytes = [
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 24 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 16 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n >> 8 & 0xFF)),
    Nat8.fromNat(Nat32.toNat(n & 0xFF)),
  ];
  Blob.fromArray(bytes);
};

test(
  "nextInt",
  func() {
    let testCases : [{ seed : Nat32; min : Int; max : Int }] = [
      { seed = 1; min = 0; max = 10 },
      { seed = 2; min = -4; max = 5 },
      { seed = 3; min = -1; max = 1_000_000_000_000_000 },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromEntropy(blobFromNat32(testCase.seed));
      let ?randInt = rand.nextInt(testCase.min, testCase.max) else Debug.trap("Not enough entropy");
      assert (randInt >= testCase.min and randInt <= testCase.max);
    };
  },
);

test(
  "nextNat",
  func() {
    let testCases : [{ seed : Nat32; min : Nat; max : Nat }] = [
      { seed = 1; min = 0; max = 10 },
      { seed = 2; min = 1; max = 5 },
      { seed = 3; min = 99999; max = 1_000_000_000_000_000 },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromEntropy(blobFromNat32(testCase.seed));
      let ?randNat = rand.nextNat(testCase.min, testCase.max) else Debug.trap("Not enough entropy");
      assert (randNat >= testCase.min and randNat <= testCase.max);
    };
  },
);

test(
  "nextCoin",
  func() {
    let testCases : [{ seed : Nat32 }] = [
      { seed = 1 },
      { seed = 2 },
      { seed = 3 },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromEntropy(blobFromNat32(testCase.seed));
      let ?randBool = rand.nextCoin() else Debug.trap("Not enough entropy");
      assertNotNull(?randBool);
    };
  },
);

test(
  "nextRatio",
  func() {
    let testCases : [{
      seed : Nat32;
      trueCount : Nat;
      totalCount : Nat;
    }] = [
      { seed = 1; trueCount = 1; totalCount = 2 },
      { seed = 2; trueCount = 1; totalCount = 3 },
      { seed = 3; trueCount = 2; totalCount = 3 },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromEntropy(blobFromNat32(testCase.seed));
      let ?randBool = rand.nextRatio(testCase.trueCount, testCase.totalCount) else Debug.trap("Not enough entropy");
      assertNotNull(?randBool);
    };
  },
);

test(
  "shuffleBuffer",
  func() {
    let testCases : [{ seed : Nat32; input : [Int] }] = [
      { seed = 1; input = [1, 2, 3] },
      { seed = 2; input = [4, 5, 6] },
      { seed = 3; input = [7, 8, 9] },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromEntropy(blobFromNat32(testCase.seed));
      let buffer = Buffer.fromArray<Int>(testCase.input);
      let ?() = rand.shuffleBuffer(buffer) else Debug.trap("Not enough entropy");
      assert (buffer.size() == testCase.input.size());
      // Check that all elements are still present (in any order)
      for (item in testCase.input.vals()) {
        assert (Buffer.contains<Int>(buffer, item, Int.equal));
      };
    };
  },
);
