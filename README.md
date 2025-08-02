# Random Number Generator Library

This library provides two implementations of random number generators:

1. Pseudo Random Number Generator
2. Extension methods to Random.Random from core library

## Pseudo Random Number Generator

This generator provides a pseudo-random number generator with various methods for generating random numbers, selecting random elements, and performing weighted selections.

### Usage

Import the module to use this library:

```motoko
import PseudoRandom "mo:pseudo-random/PseudoRandom";
```

### Types

#### PseudoRandomGenerator

The main type provided by this library, which includes all the methods for random number generation and selection.

### Functions

#### fromBlob

Creates a new PseudoRandomGenerator from a Blob.

```motoko
public func fromBlob(blob : Blob) : PseudoRandomGenerator
```

#### fromSeed

Creates a new PseudoRandomGenerator from a 32-bit seed.

```motoko
public func fromSeed(seed : Nat32) : PseudoRandomGenerator
```

#### getCurrentSeed

Returns the current seed of the generator.

```motoko
getCurrentSeed : () -> Nat32
```

#### nextInt

Generates a random integer within the specified range (exclusive).

```motoko
nextInt : (min : Int, max : Int) -> Int
```

#### nextNat

Generates a random natural number within the specified range (exclusive).

```motoko
nextNat : (min : Nat, max : Nat) -> Nat
```

#### nextFloat

Generates a random floating-point number within the specified range.

```motoko
nextFloat : (min : Float, max : Float) -> Float
```

#### nextCoin

Simulates a coin flip, returning a random boolean value.

```motoko
nextCoin : () -> Bool
```

#### nextRatio

Returns a boolean based on the specified ratio of true outcomes to total outcomes.

```motoko
nextRatio : (trueCount : Nat, totalCount : Nat) -> Bool
```

#### nextListElement

Selects a random element from the given list.

```motoko
nextListElement : <T>(list : List.List<T>) -> T
```

#### nextArrayElement

Selects a random element from the given array.

```motoko
nextArrayElement : <T>(array : [T]) -> T
```

#### nextArrayElementWeighted

Selects a random element from the given array of tuples, where each tuple contains an element and its weight.

```motoko
nextArrayElementWeighted : <T>(array : [(T, Float)]) -> T
```

#### nextArrayElementWeightedFunc

Selects a random element from the given array using a provided weight function.

```motoko
nextArrayElementWeightedFunc : <T>(array : [T], weightFunc : (T) -> Float) -> T
```

#### shuffleList

Shuffles the elements of the given list in place.

```motoko
shuffleList : <T>(list : List.List<T>) -> ()
```

### Examples

Here are some examples of how to use the Pseudo Random Number Generator:

```motoko
// Create a generator from a seed value
let prng = PseudoRandomX.fromSeed(0);

let randomInt = prng.nextInt(1, 10);
Debug.print("Random integer between 1 and 10 (exclusive): " # Int.toText(randomInt));

let randomCoin = prng.nextCoin();
Debug.print("Random coin flip: " # Bool.toText(randomCoin));


let randomFloat = prng.nextFloat(0.0, 1.0);
Debug.print("Random float between 0.0 and 1.0 (exclusive): " # Float.toText(randomFloat));

let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
prng.shuffleList(list);
Debug.print("Shuffled list: " # debug_show (List.toArray(list)));

// Select a random element from an array
let array = [1, 2, 3, 4, 5];
let randomElement = prng.nextArrayElement(array);
Debug.print("Random element from array: " # Int.toText(randomElement));

```

Note: This pseudo-random number generator is deterministic and should not be used for cryptographic purposes or in situations where true randomness is required.

## Extension methods to Random.Random in core library

Some helper functions for Random.Random that aren't included in the core library

### Usage

Import the module to use this library:

```motoko
import Random "mo:core/Random";
import RandomX "mo:xtended-random/RandomX";
```

### Functions

#### nextRatio

Returns a boolean based on the specified ratio of true outcomes to total outcomes.

```motoko
nextRatio : (random : Random.Random, trueCount : Nat, totalCount : Nat) -> Bool
```

#### nextFloat

Generates a random floating-point number within the specified range.

```motoko
nextFloat : (random : Random.Random, min : Float, max : Float) -> Float
```

#### nextListElement

Selects a random element from the given list.

```motoko
nextListElement : <T>(random : Random.Random, list : List.List<T>) -> T
```

#### nextArrayElement

Selects a random element from the given array.

```motoko
nextArrayElement : <T>(random : Random.Random, array : [T]) -> T
```

#### nextArrayElementWeighted

Selects a random element from the given array of tuples, where each tuple contains an element and its weight.

```motoko
nextArrayElementWeighted : <T>(random : Random.Random, array : [(T, Float)]) -> T
```

#### nextArrayElementWeightedFunc

Selects a random element from the given array using a provided weight function.

```motoko
nextArrayElementWeightedFunc : <T>(random : Random.Random, array : [T], weightFunc : (T) -> Float) -> T
```

#### shuffleList

Shuffles the elements of the given list in place.

```motoko
shuffleList : <T>(random : Random.Random, list : List.List<T>) -> ()
```

### Examples

Here are some examples of how to use the Finite Random Number Generator:

```motoko
let list = List.fromArray<Nat>([1, 2, 3, 4, 5]);
let random = Random.seed(123);

// Shuffle a list
RandomX.shuffleList(random, list);
Debug.print("Shuffled list: " # debug_show (List.toArray(list)));

// Generate a random float
let randomFloat = RandomX.nextFloat(random, 0.0, 1.0);
Debug.print("Random float between 0.0 and 1.0: " # Float.toText(randomFloat));

// Select a random element from a list
let fruits = List.fromArray<Text>(["apple", "banana", "orange"]);
let randomFruit = RandomX.nextListElement(random, fruits);
Debug.print("Random fruit: " # randomFruit);

// Select a random element from an array
let numbers = [1, 2, 3, 4, 5];
let randomNumber = RandomX.nextArrayElement(random, numbers);
Debug.print("Random number: " # Int.toText(randomNumber));

// Weighted selection
let weightedItems = [("rare", 0.1), ("uncommon", 0.3), ("common", 0.6)];
let randomItem = RandomX.nextArrayElementWeighted(random, weightedItems);
Debug.print("Random weighted item: " # randomItem);

// Weighted selection with function
let items = [1, 2, 3, 4, 5];
let weightFunc = func (n : Nat) : Float { Float.fromInt(n) };
let randomWeightedNumber = RandomX.nextArrayElementWeightedFunc(random, items, weightFunc);
Debug.print("Random weighted number: " # Int.toText(randomWeightedNumber));
```
