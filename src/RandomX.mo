/// Provides functions for generating random numbers and selections using a finite entropy source.
///
/// Import from the random library to use this module.
/// ```motoko name=import
/// import RandomX "mo:xtended-random/RandomX";
/// ```

import Random "mo:core@1/Random";
import List "mo:core@1/List";
import Bool "mo:core@1/Bool";
import Float "mo:core@1/Float";
import Nat8 "mo:core@1/Nat8";
import Common "./Common";
import Runtime "mo:core@1/Runtime";

module {

  /// Returns a boolean based on the specified ratio of true outcomes to total outcomes.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let result : Bool = Random.nextRatio(random, 1, 3);
  /// ```
  public func nextRatio(random : Random.Random, trueCount : Nat, totalCount : Nat) : Bool {
    let randNat = func(min : Nat, max : Nat) : Nat { random.natRange(min, max) };
    Common.nextRatio(randNat, trueCount, totalCount);
  };

  /// Shuffles the elements of the given list in place.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
  /// Random.shuffleList(random, list);
  /// ```
  public func shuffleList<T>(random : Random.Random, list : List.List<T>) {
    let randNat = func(min : Nat, max : Nat) : Nat { random.natRange(min, max) };
    Common.shuffleList(randNat, list);
  };

  /// Generates a random floating-point number within the specified range.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let randomFloat = RandomX.nextFloat(random, 0.0, 1.0); // [0.0, 1.0)
  /// ```
  public func nextFloat(random : Random.Random, min : Float, max : Float) : Float {
    if (min > max) {
      Runtime.trap("Min cannot be larger than max");
    };
    if (min == max) {
      return min;
    };
    let randNat8 = random.nat8();
    let randFloat = Float.fromInt(Nat8.toNat(randNat8)) / 255.0;
    min + (max - min) * randFloat;
  };

  /// Selects a random element from the given list.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let list = List.fromArray<Text>(["a", "b", "c"]);
  /// let randomElement = RandomX.nextListElement(random, list);
  /// ```
  public func nextListElement<T>(random : Random.Random, list : List.List<T>) : T {
    let randNat = func(min : Nat, max : Nat) : Nat { random.natRange(min, max) };
    Common.nextListElement(randNat, list);
  };

  /// Selects a random element from the given array.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let array = [1, 2, 3, 4, 5];
  /// let randomElement = RandomX.nextArrayElement(random, array);
  /// ```
  public func nextArrayElement<T>(random : Random.Random, array : [T]) : T {
    let randNat = func(min : Nat, max : Nat) : Nat { random.natRange(min, max) };
    Common.nextArrayElement(randNat, array);
  };

  /// Selects a random element from the given array of tuples, where each tuple contains an element and its weight.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let weightedArray = [("rare", 0.1), ("uncommon", 0.3), ("common", 0.6)];
  /// let randomElement = RandomX.nextArrayElementWeighted(random, weightedArray);
  /// ```
  public func nextArrayElementWeighted<T>(random : Random.Random, array : [(T, Float)]) : T {
    let randFloat = func(min : Float, max : Float) : Float {
      nextFloat(random, min, max);
    };
    Common.nextArrayElementWeighted(randFloat, array);
  };

  /// Selects a random element from the given array using a provided weight function.
  ///
  /// ```motoko include=import
  /// let random : Random = Random.seed(123);
  /// let array = [1, 2, 3, 4, 5];
  /// let weightFunc = func (n : Nat) : Float { Float.fromInt(n) };
  /// let randomElement = RandomX.nextArrayElementWeightedFunc(random, array, weightFunc);
  /// ```
  public func nextArrayElementWeightedFunc<T>(random : Random.Random, array : [T], weightFunc : (T) -> Float) : T {
    let randFloat = func(min : Float, max : Float) : Float {
      nextFloat(random, min, max);
    };
    Common.nextArrayElementWeightedFunc(randFloat, array, weightFunc);
  };
};
