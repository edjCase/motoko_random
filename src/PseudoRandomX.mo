/// Provides functions for generating pseudo-random numbers and selections.
///
/// Import from the pseudo-random library to use this module.
/// ```motoko name=import
/// import PseudoRandomX "mo:xtended-random/PseudoRandomX";
/// ```

import Int "mo:core@1/Int";
import Nat8 "mo:core@1/Nat8";
import Array "mo:core@1/Array";
import Iter "mo:core@1/Iter";
import List "mo:core@1/List";
import Nat32 "mo:core@1/Nat32";
import Float "mo:core@1/Float";
import Blob "mo:core@1/Blob";
import Bool "mo:core@1/Bool";
import Runtime "mo:core@1/Runtime";
import Common "./Common";

module {

  /// The main type for the pseudo-random number generator,
  /// containing all methods for random number generation and selection.
  public type PseudoRandomGenerator = {
    getCurrentSeed : () -> Nat32;
    nextInt : (min : Int, max : Int) -> Int;
    nextNat : (min : Nat, max : Nat) -> Nat;
    nextFloat : (min : Float, max : Float) -> Float;
    nextCoin : () -> Bool;
    nextRatio : (trueCount : Nat, totalCount : Nat) -> Bool;
    nextListElement : <T>(list : List.List<T>) -> T;
    nextArrayElement : <T>(array : [T]) -> T;
    nextArrayElementWeighted : <T>(array : [(T, Float)]) -> T;
    nextArrayElementWeightedFunc : <T>(array : [T], weightFunc : (T) -> Float) -> T;
    shuffleList : <T>(list : List.List<T>) -> ();
    optionBuilder : <T>() -> PseudoRandomOptionBuilder<T>;
  };

  public type PseudoRandomOptionBuilder<T> = {
    withValue : (value : T, weight : Float) -> PseudoRandomOptionBuilder<T>;
    withFunc : (f : () -> T, weight : Float) -> PseudoRandomOptionBuilder<T>;
    next : () -> T;
  };

  /// The kinds of pseudo-random number generation algorithms available.
  /// - `#linearCongruential`: A simple and fast generator. Good for basic uses where speed is
  ///   prioritized over randomness quality
  /// - `#xorshift32`: Offers a good balance of speed and randomness quality. Better statistical
  ///   properties than linear congruential
  public type PseudoRandomKind = {
    #linearCongruential;
    #xorshift32;
  };

  /// Creates a new PseudoRandomGenerator from a Blob.
  ///
  /// ```motoko include=import
  /// let blob : Blob = ...;
  /// let prng = PseudoRandom.fromBlob(blob);
  /// ```
  public func fromBlob(blob : Blob, kind : PseudoRandomKind) : PseudoRandomGenerator {
    let seed = convertBlobToSeed(blob);
    DefaultPseudoRandomGenerator(seed, kind);
  };

  /// Converts a Blob to a 32-bit seed for the random number generator.
  private func convertBlobToSeed(blob : Blob) : Nat32 {
    var seed : Nat32 = 0;

    blob.vals()
    |> Iter.enumerate(_)
    |> Iter.forEach(
      _,
      func((i : Nat, byte : Nat8)) {
        // Determine the position of the byte within its 4-byte chunk
        let bytePosition : Nat32 = Nat32.fromNat(i % 4);
        let nat32Byte = Nat32.fromNat(Nat8.toNat(byte));
        // Shift the byte to its correct position and combine it with the current seed using XOR
        let shiftedByte = Nat32.bitshiftLeft(nat32Byte, (3 - bytePosition) * 8);
        seed := Nat32.bitxor(seed, shiftedByte);

        // Every 4 bytes, optionally mix the seed to ensure even distribution of entropy
        if ((i + 1) % 4 == 0) {
          seed := Nat32.bitxor(Nat32.mulWrap(seed, 2654435761), Nat32.bitrotLeft(seed, 13));
        };
      },
    );
    return seed;
  };

  /// Creates a new PseudoRandomGenerator from a 32-bit seed.
  ///
  /// ```motoko include=import
  /// let seed : Nat32 = 12345;
  /// let prng = PseudoRandom.fromSeed(seed);
  /// ```
  public func fromSeed(seed : Nat32, kind : PseudoRandomKind) : PseudoRandomGenerator {
    DefaultPseudoRandomGenerator(seed, kind);
  };

  /// Implements the specified algorithm kinds for pseudo-random number generation.
  public class DefaultPseudoRandomGenerator(seed : Nat32, kind : PseudoRandomKind) : PseudoRandomGenerator = this {
    var currentSeed = seed;

    let nextSeedInternal = switch (kind) {
      case (#linearCongruential) func() : Nat32 {
        let a : Nat32 = 1664525;
        let c : Nat32 = 1013904223;
        currentSeed
        |> Nat32.mulWrap(a, _)
        |> Nat32.addWrap(_, c); // Overflow is ok
      };
      case (#xorshift32) func() : Nat32 {
        var seed = currentSeed;
        seed := seed ^ (seed << 13);
        seed := seed ^ (seed >> 17);
        seed := seed ^ (seed << 5);
        seed;
      };
    };

    /// Generates the next seed in the sequence.
    let nextSeed = func() : Nat32 {
      let newSeed = nextSeedInternal();
      currentSeed := newSeed;
      newSeed;
    };

    /// Returns the current seed of the generator.
    public func getCurrentSeed() : Nat32 {
      currentSeed;
    };

    /// Generates a random integer within the specified range (inclusive min, exclusive max).
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let randomInt = prng.nextInt(0, 10); // [0, 10)
    /// ```
    public func nextInt(min : Int, max : Int) : Int {
      if (min >= max) {
        Runtime.trap("Max must be larger than min");
      };
      let randNat32 = nextSeed();
      let rangeSize = max - min;
      min + (Nat32.toNat(randNat32) % rangeSize);
    };

    /// Generates a random natural number within the specified range (inclusive min, exclusive max).
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let randomNat = prng.nextNat(0, 10); // [0, 10)
    /// ```
    public func nextNat(min : Nat, max : Nat) : Nat {
      let randInt = nextInt(min, max);
      Int.abs(randInt);
    };

    /// Simulates a coin flip, returning a random boolean value.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let coinFlip = prng.nextCoin();
    /// ```
    public func nextCoin() : Bool {
      Common.nextCoin(nextNat);
    };

    /// Generates a random floating-point number within the specified range.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let randomFloat = prng.nextFloat(0.0, 1.0); // [0.0, 1.0)
    /// ```
    public func nextFloat(min : Float, max : Float) : Float {
      if (min > max) {
        Runtime.trap("Min cannot be larger than max");
      };
      if (min == max) {
        return min;
      };
      let randNat32 = nextSeed();
      let randIntValue = Nat32.toNat(randNat32);
      let nat32Max : Float = 4_294_967_295;
      let randFloat = Float.fromInt(randIntValue) / nat32Max;
      min + (max - min) * randFloat;
    };

    /// Returns a boolean based on the specified ratio of true outcomes to total outcomes.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let oneInThreeChance = prng.nextRatio(1, 3);
    /// ```
    public func nextRatio(trueCount : Nat, totalCount : Nat) : Bool {
      Common.nextRatio(nextNat, trueCount, totalCount);
    };

    /// Selects a random element from the given list.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let list = List.fromArray<Text>(["a", "b", "c"]);
    /// let randomElement = prng.nextListElement(list);
    /// ```
    public func nextListElement<T>(list : List.List<T>) : T {
      Common.nextListElement(nextNat, list);
    };

    /// Selects a random element from the given array.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let array = [1, 2, 3, 4, 5];
    /// let randomElement = prng.nextArrayElement(array);
    /// ```
    public func nextArrayElement<T>(array : [T]) : T {
      Common.nextArrayElement(nextNat, array);
    };

    /// Selects a random element from the given array of tuples, where each tuple contains an element and its weight.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let weightedArray = [("rare", 0.1), ("uncommon", 0.3), ("common", 0.6)];
    /// let randomElement = prng.nextArrayElementWeighted(weightedArray);
    /// ```
    public func nextArrayElementWeighted<T>(array : [(T, Float)]) : T {
      Common.nextArrayElementWeighted(nextFloat, array);
    };

    /// Selects a random element from the given array using a provided weight function.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let array = [1, 2, 3, 4, 5];
    /// let weightFunc = func (n : Nat) : Float { Float.fromInt(n) };
    /// let randomElement = prng.nextArrayElementWeightedFunc(array, weightFunc);
    /// ```
    public func nextArrayElementWeightedFunc<T>(array : [T], weightFunc : (T) -> Float) : T {
      Common.nextArrayElementWeightedFunc(nextFloat, array, weightFunc);
    };

    /// Shuffles the elements of the given list in place.
    ///
    /// ```motoko include=import
    /// let prng : PseudoRandomGenerator = ...;
    /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
    /// prng.shuffleList(list);
    /// ```
    public func shuffleList<T>(list : List.List<T>) {
      Common.shuffleList(nextNat, list);
    };

    public func optionBuilder<T>() : PseudoRandomOptionBuilder<T> {
      DefaultPseudoRandomOptionBuilder<T>(this);
    };
  };

  public class DefaultPseudoRandomOptionBuilder<T>(prng : PseudoRandomGenerator) : PseudoRandomOptionBuilder<T> = this {
    var values : [(() -> T, Float)] = [];

    public func withValue(value : T, weight : Float) : PseudoRandomOptionBuilder<T> {
      values := Array.concat(values, [(func() : T = value, weight)]);
      this;
    };

    public func withFunc(f : () -> T, weight : Float) : PseudoRandomOptionBuilder<T> {
      values := Array.concat(values, [(f, weight)]);
      this;
    };

    public func next() : T {
      let func_ = prng.nextArrayElementWeighted(values);
      func_();
    };

  };
};
