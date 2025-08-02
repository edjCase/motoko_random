/// Common utility functions for random number generation and selection.
/// This module provides shared implementations that can be used by both
/// PseudoRandomX and RandomX modules by accepting random generation functions as parameters.
///
/// Import this module to use the shared functions:
/// ```motoko name=import
/// import Common "mo:xtended-random/Common";
/// ```

import Array "mo:core/Array";
import Iter "mo:core/Iter";
import List "mo:core/List";
import Float "mo:core/Float";
import Runtime "mo:core/Runtime";
import Nat8 "mo:core/Nat8";

module {

  /// Type alias for a function that generates random natural numbers in a range.
  public type RandNatFunc = (min : Nat, max : Nat) -> Nat;

  /// Type alias for a function that generates random floating-point numbers in a range.
  public type RandFloatFunc = (min : Float, max : Float) -> Float;

  /// Returns a boolean based on the specified ratio of true outcomes to total outcomes.
  /// Uses the provided random natural number generator function.
  ///
  /// ```motoko include=import
  /// let randNat = func(min : Nat, max : Nat) : Nat { ... };
  /// let result = Common.nextRatio(randNat, 1, 3);
  /// ```
  public func nextRatio(randNat : RandNatFunc, trueCount : Nat, totalCount : Nat) : Bool {
    if (trueCount > totalCount) {
      Runtime.trap("True count cannot be larger than total count");
    };
    let randomValue = randNat(1, totalCount + 1);
    randomValue <= trueCount;
  };

  /// Generates a random floating-point number within the specified range using a more precise generator.
  /// This implementation is optimized for pseudo-random generators with larger entropy.
  ///
  /// ```motoko include=import
  /// let randFloat = func(min : Float, max : Float) : Float { ... };
  /// let result = Common.nextFloatFromGenerator(randFloat, 0.0, 1.0);
  /// ```
  public func nextFloatFromGenerator(randFloat : RandFloatFunc, min : Float, max : Float) : Float {
    if (min > max) {
      Runtime.trap("Min cannot be larger than max");
    };
    if (min == max) {
      return min;
    };
    randFloat(min, max);
  };

  /// Selects a random element from the given list using the provided random generator.
  ///
  /// ```motoko include=import
  /// let randNat = func(min : Nat, max : Nat) : Nat { ... };
  /// let list = List.fromArray<Text>(["a", "b", "c"]);
  /// let randomElement = Common.nextListElement(randNat, list);
  /// ```
  public func nextListElement<T>(randNat : RandNatFunc, list : List.List<T>) : T {
    let listSize = List.size(list);
    if (listSize == 0) {
      Runtime.trap("Cannot get random element from an empty list");
    };
    let randomIndex = randNat(0, listSize);
    List.get(list, randomIndex);
  };

  /// Selects a random element from the given array using the provided random generator.
  ///
  /// ```motoko include=import
  /// let randNat = func(min : Nat, max : Nat) : Nat { ... };
  /// let array = [1, 2, 3, 4, 5];
  /// let randomElement = Common.nextArrayElement(randNat, array);
  /// ```
  public func nextArrayElement<T>(randNat : RandNatFunc, array : [T]) : T {
    let arraySize = array.size();
    if (arraySize == 0) {
      Runtime.trap("Cannot get random element from an empty array");
    };
    let randomIndex = randNat(0, arraySize);
    array[randomIndex];
  };

  /// Selects a random element from the given array of tuples using weighted selection.
  /// Uses the provided random float generator for threshold selection.
  ///
  /// ```motoko include=import
  /// let randFloat = func(min : Float, max : Float) : Float { ... };
  /// let weightedArray = [("rare", 0.1), ("uncommon", 0.3), ("common", 0.6)];
  /// let randomElement = Common.nextArrayElementWeighted(randFloat, weightedArray);
  /// ```
  public func nextArrayElementWeighted<T>(randFloat : RandFloatFunc, array : [(T, Float)]) : T {
    let arraySize = array.size();
    if (arraySize == 0) {
      Runtime.trap("Cannot get random element from an empty array");
    };
    let totalWeight = Array.foldLeft<(T, Float), Float>(
      array,
      0.0,
      func(acc : Float, (item, weight) : (T, Float)) : Float {
        acc + weight;
      },
    );
    let randomThreshold = randFloat(0.0, totalWeight);
    var sum : Float = 0.0;
    for ((element, weight) in Iter.fromArray(array)) {
      sum += weight;
      if (sum > randomThreshold) {
        return element;
      };
    };
    Runtime.unreachable();
  };

  /// Selects a random element from the given array using a provided weight function.
  /// Uses weighted selection with the provided random float generator.
  ///
  /// ```motoko include=import
  /// let randFloat = func(min : Float, max : Float) : Float { ... };
  /// let array = [1, 2, 3, 4, 5];
  /// let weightFunc = func (n : Nat) : Float { Float.fromInt(n) };
  /// let randomElement = Common.nextArrayElementWeightedFunc(randFloat, array, weightFunc);
  /// ```
  public func nextArrayElementWeightedFunc<T>(randFloat : RandFloatFunc, array : [T], weightFunc : (T) -> Float) : T {
    let weightedArray = Array.map<T, (T, Float)>(
      array,
      func(item : T) : (T, Float) = (item, weightFunc(item)),
    );
    nextArrayElementWeighted(randFloat, weightedArray);
  };

  /// Shuffles the elements of the given list in place using the Fisher-Yates algorithm.
  /// Uses the provided random natural number generator.
  ///
  /// ```motoko include=import
  /// let randNat = func(min : Nat, max : Nat) : Nat { ... };
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  /// Common.shuffleList(randNat, list);
  /// ```
  public func shuffleList<T>(randNat : RandNatFunc, list : List.List<T>) {
    let listSize = List.size(list);
    if (listSize <= 1) {
      return;
    };

    // Fisher-Yates shuffle algorithm
    var i : Nat = listSize - 1;
    while (i > 0) {
      let randIdx = randNat(0, i + 1);
      let temp = List.get(list, i);
      List.put(list, i, List.get(list, randIdx));
      List.put(list, randIdx, temp);
      i -= 1;
    };
  };

  /// Simulates a coin flip using the provided random ratio generator.
  ///
  /// ```motoko include=import
  /// let randNat = func(min : Nat, max : Nat) : Nat { ... };
  /// let coinFlip = Common.nextCoin(randNat);
  /// ```
  public func nextCoin(randNat : RandNatFunc) : Bool {
    nextRatio(randNat, 1, 2);
  };
};
