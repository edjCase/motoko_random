/// Provides functions for generating pseudo-random numbers and selections.
///
/// Import from the pseudo-random library to use this module.
/// ```motoko name=import
/// import PseudoRandomX "mo:xtended-random/PseudoRandomX";
/// ```

import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";

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
        nextBufferElement : <T>(buffer : Buffer.Buffer<T>) -> T;
        nextArrayElement : <T>(array : [T]) -> T;
        nextArrayElementWeighted : <T>(array : [(T, Float)]) -> T;
        nextArrayElementWeightedFunc : <T>(array : [T], weightFunc : (T) -> Float) -> T;
        shuffleBuffer : <T>(buffer : Buffer.Buffer<T>) -> ();
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

        Iter.iterate(
            blob.vals(),
            func(byte : Nat8, i : Nat) {
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
    public class DefaultPseudoRandomGenerator(seed : Nat32, kind : PseudoRandomKind) : PseudoRandomGenerator {
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

        /// Generates a random integer within the specified range (exclusive).
        ///
        /// ```motoko include=import
        /// let prng : PseudoRandomGenerator = ...;
        /// let randomInt = prng.nextInt(0, 10); // [0, 10)
        /// ```
        public func nextInt(min : Int, max : Int) : Int {
            if (min >= max) {
                Debug.trap("Max must be larger than min");
            };
            let randNat32 = nextSeed();
            let rangeSize = max - min;
            min + (Nat32.toNat(randNat32) % rangeSize);
        };

        /// Generates a random natural number within the specified range (inclusive).
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
            nextRatio(1, 2);
        };

        /// Generates a random floating-point number within the specified range.
        ///
        /// ```motoko include=import
        /// let prng : PseudoRandomGenerator = ...;
        /// let randomFloat = prng.nextFloat(0.0, 1.0); // [0.0, 1.0)
        /// ```
        public func nextFloat(min : Float, max : Float) : Float {
            if (min > max) {
                Debug.trap("Min cannot be larger than max");
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
            if (trueCount > totalCount) {
                Debug.trap("True count cannot be larger than total count");
            };
            let randomValue = nextNat(1, totalCount + 1);
            return randomValue <= trueCount;
        };

        /// Selects a random element from the given buffer.
        ///
        /// ```motoko include=import
        /// let prng : PseudoRandomGenerator = ...;
        /// let buffer = Buffer.fromArray<Text>(["a", "b", "c"]);
        /// let randomElement = prng.nextBufferElement(buffer);
        /// ```
        public func nextBufferElement<T>(buffer : Buffer.Buffer<T>) : T {
            let bufferSize = buffer.size();
            if (bufferSize == 0) {
                Debug.trap("Cannot get random element from an empty buffer");
            };
            let randomIndex = nextNat(0, bufferSize);
            buffer.get(randomIndex);
        };

        /// Selects a random element from the given array.
        ///
        /// ```motoko include=import
        /// let prng : PseudoRandomGenerator = ...;
        /// let array = [1, 2, 3, 4, 5];
        /// let randomElement = prng.nextArrayElement(array);
        /// ```
        public func nextArrayElement<T>(array : [T]) : T {
            let arraySize = array.size();
            if (arraySize == 0) {
                Debug.trap("Cannot get random element from an empty array");
            };
            let randomIndex = nextNat(0, arraySize);
            array[randomIndex];
        };

        /// Selects a random element from the given array of tuples, where each tuple contains an element and its weight.
        ///
        /// ```motoko include=import
        /// let prng : PseudoRandomGenerator = ...;
        /// let weightedArray = [("rare", 0.1), ("uncommon", 0.3), ("common", 0.6)];
        /// let randomElement = prng.nextArrayElementWeighted(weightedArray);
        /// ```
        public func nextArrayElementWeighted<T>(array : [(T, Float)]) : T {
            let arraySize = array.size();
            if (arraySize == 0) {
                Debug.trap("Cannot get random element from an empty array");
            };
            let totalWeight = Array.foldLeft<(T, Float), Float>(
                array,
                0.0,
                func(acc : Float, (item, weight) : (T, Float)) : Float {
                    acc + weight;
                },
            );
            let randomThreshold = nextFloat(0.0, totalWeight);
            var sum : Float = 0.0;
            for ((element, weight) in Iter.fromArray(array)) {
                sum += weight;
                if (sum > randomThreshold) {
                    return element;
                };
            };
            Prelude.unreachable();
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
            let weightedArray = Array.map<T, (T, Float)>(
                array,
                func(item : T) : (T, Float) = (item, weightFunc(item)),
            );
            nextArrayElementWeighted(weightedArray);
        };

        /// Shuffles the elements of the given buffer in place.
        ///
        /// ```motoko include=import
        /// let prng : PseudoRandomGenerator = ...;mo
        /// let buffer = Buffer.fromArray<Nat>([1, 2, 3, 4, 5]);
        /// prng.shuffleBuffer(buffer);
        /// ```
        public func shuffleBuffer<T>(buffer : Buffer.Buffer<T>) {
            let bufferSize = buffer.size();
            if (bufferSize == 0) {
                return;
            };
            Buffer.reverse(buffer);
            var i : Nat = bufferSize;
            for (item in buffer.vals()) {
                i -= 1;
                let randomIndex = nextNat(0, i + 1);
                let temp = buffer.get(i);
                buffer.put(i, buffer.get(randomIndex));
                buffer.put(randomIndex, temp);
            };
        };
    };
};
