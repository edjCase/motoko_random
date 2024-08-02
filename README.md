# Random Number Generator Library

This library provides two implementations of random number generators:
1. Pseudo Random Number Generator
2. Finite Random Number Generator

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

#### nextBufferElement

Selects a random element from the given buffer.

```motoko
nextBufferElement : <T>(buffer : Buffer.Buffer<T>) -> T
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

#### shuffleBuffer

Shuffles the elements of the given buffer in place.

```motoko
shuffleBuffer : <T>(buffer : Buffer.Buffer<T>) -> ()
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

let buffer = Buffer.fromArray<Nat>([1, 2, 3, 4, 5]);
prng.shuffleBuffer(buffer);
Debug.print("Shuffled buffer: " # debug_show (Buffer.toArray(buffer)));

// Select a random element from an array
let array = [1, 2, 3, 4, 5];
let randomElement = prng.nextArrayElement(array);
Debug.print("Random element from array: " # Int.toText(randomElement));

```

Note: This pseudo-random number generator is deterministic and should not be used for cryptographic purposes or in situations where true randomness is required.

## Finite Random Number Generator

This generator provides a finite random number generator using a finite entropy source. It may return `null` if there's not enough entropy available.

### Usage

Import the module to use this library:

```motoko
import RandomX "mo:xtended-random/RandomX";
```

### Types

#### RandomGenerator

The main type provided by this library, which includes methods for random number generation and selection.

### Functions

#### fromSeed

Creates a new FiniteX random generator from a seed.

```motoko
public func fromSeed(seed : Blob) : FiniteX
```

#### nextCoin

Simulates a coin flip, returning a random boolean value.

```motoko
nextCoin : () -> ?Bool
```

#### nextRatio

Returns a boolean based on the specified ratio of true outcomes to total outcomes.

```motoko
nextRatio : (trueCount : Nat, totalCount : Nat) -> ?Bool
```

#### nextInt

Generates a random integer within the specified range (exclusive).

```motoko
nextInt : (min : Int, max : Int) -> ?Int
```

#### nextNat

Generates a random natural number within the specified range (exclusive).

```motoko
nextNat : (min : Nat, max : Nat) -> ?Nat
```

#### shuffleBuffer

Shuffles the elements of the given buffer in place.

```motoko
shuffleBuffer : <T>(buffer : Buffer.Buffer<T>) -> ?()
```

### Examples

Here are some examples of how to use the Finite Random Number Generator:

```motoko
let entropy : Blob = ...; // Initialize with a proper seed
let randomGen = RandomX.fromEntropy(seed);
let ?randomInt = randomGen.nextInt(1, 10) else return #err("Not enough entropy");
Debug.print("Random integer between 1 and 10 (exclusive): " # Int.toText(randomInt));

let ?randomCoin = randomGen.nextCoin() else return #err("Not enough entropy");
Debug.print("Random coin flip: " # Bool.toText(randomCoin));

let buffer = Buffer.fromArray<Nat>([1, 2, 3, 4, 5]);
let _ = randomGen.shuffleBuffer(buffer) else return #err("Not enough entropy");;
Debug.print("Shuffled buffer: " # debug_show (Buffer.toArray(buffer)));

```

Note: This finite random number generator uses a limited entropy source and may return `null` if there's not enough entropy available. It's suitable for use cases where a non-deterministic source of randomness is required, but be prepared to handle cases where randomness may be unavailable.