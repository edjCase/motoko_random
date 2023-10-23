import Iter "mo:base/Iter";
import { test } "mo:test";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import RandomX "../src/RandomX";

let assertEqualInt = func(expected : Int, actual : ?Int) : () {
  if (actual != ?expected) {
    switch (actual) {
      case (null) Debug.trap("Expected " # Int.toText(expected) # ", but ran out of entropy.");
      case (?i) Debug.trap("Expected " # Int.toText(expected) # ", got " # Int.toText(i));
    };
  };
};

test(
  "int",
  func() {
    let testCases : [{ seed : Blob; expected : Int; min : Int; max : Int }] = [
      {
        seed = "\A1\B2\C3\D4\E5\F6\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27";
        expected = 1;
        min = 0;
        max = 10;
      },
      {
        seed = "\A1\B2\C8\D4\E5\F6\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27";
        expected = -3;
        min = -4;
        max = 5;
      },
      {
        seed = "\A1\B2\C8\D4\E5\F6\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27";
        expected = 711156982585303;
        min = -1;
        max = 1_000_000_000_000_000;
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromSeed(testCase.seed);
      let randInt = rand.int(testCase.min, testCase.max);
      assertEqualInt(testCase.expected, randInt);
    };
  },
);

test(
  "nat",
  func() {
    let testCases : [{ seed : Blob; expected : Nat; min : Nat; max : Nat }] = [
      {
        seed = "\A1\B2\C3\D4\E5\F6\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27";
        expected = 1;
        min = 0;
        max = 10;
      },
      {
        seed = "\A1\B2\C8\D4\E5\F6\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27";
        expected = 2;
        min = 1;
        max = 5;
      },
      {
        seed = "\A1\B2\C8\D4\E5\F6\10\11\12\13\14\15\16\17\18\19\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27\1A\1B\1C\1D\1E\1F\20\21\22\23\24\25\26\27";
        expected = 711156982685303;
        min = 99999;
        max = 1_000_000_000_000_000;
      },
    ];
    for (testCase in Iter.fromArray(testCases)) {
      let rand = RandomX.fromSeed(testCase.seed);
      let randInt = rand.nat(testCase.min, testCase.max);
      assertEqualInt(testCase.expected, randInt);
    };
  },
);
