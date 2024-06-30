/// Provides functions for generating random numbers and selections using a finite entropy source.
///
/// Import from the random library to use this module.
/// ```motoko name=import
/// import RandomX "mo:xtended-random/RandomX";
/// ```

import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";
import Bool "mo:base/Bool";

module {
    /// The main type for the random number generator,
    /// containing methods for random number generation and selection.
    public type RandomGenerator = {
        nextInt : (min : Int, max : Int) -> ?Int;
        nextNat : (min : Nat, max : Nat) -> ?Nat;
        nextCoin : () -> ?Bool;
        nextRatio : (trueCount : Nat, totalCount : Nat) -> ?Bool;
        shuffleBuffer : <T>(buffer : Buffer.Buffer<T>) -> ?();
    };

    /// Creates a new FiniteX random generator from a seed.
    ///
    /// ```motoko include=import
    /// let entropy : Blob = ...;
    /// let randomGen = RandomX.fromEntropy(entropy);
    /// ```
    public func fromEntropy(entropy : Blob) : FiniteX {
        FiniteX(entropy);
    };

    /// Implements a finite random number generator using a given seed.
    public class FiniteX(seed : Blob) : RandomGenerator {
        let random = Random.Finite(seed);

        /// Simulates a coin flip, returning a random boolean value.
        /// Returns null if there's not enough entropy.
        ///
        /// ```motoko include=import
        /// let randomGen : RandomGenerator = ...;
        /// let ?coinFlip = randomGen.nextCoin() else return #err("Not enough entropy");
        /// ```
        public func nextCoin() : ?Bool {
            random.coin();
        };

        /// Returns a boolean based on the specified ratio of true outcomes to total outcomes.
        /// Returns null if there's not enough entropy.
        ///
        /// ```motoko include=import
        /// let randomGen : RandomGenerator = ...;
        /// let ?result = randomGen.nextRatio(1, 3) else return #err("Not enough entropy");
        /// ```
        public func nextRatio(trueCount : Nat, totalCount : Nat) : ?Bool {
            if (trueCount > totalCount) {
                Debug.trap("True count cannot be larger than total count");
            };
            let ?randValue = nextNat(1, totalCount) else return null;
            ?(randValue <= trueCount);
        };

        /// Generates a random integer within the specified range (inclusive).
        /// Returns null if there's not enough entropy.
        ///
        /// ```motoko include=import
        /// let randomGen : RandomGenerator = ...;
        /// let ?randomInt = randomGen.nextInt(1, 10) else return #err("Not enough entropy");
        /// ```
        public func nextInt(min : Int, max : Int) : ?Int {
            if (min > max) {
                Debug.trap("Min cannot be larger than max");
            };
            let range : Nat = Int.abs(max - min) + 1;

            // Calculate the number of bits needed to represent the range
            var bitsNeeded : Nat = 0;
            var temp : Nat = range;
            while (temp > 0) {
                temp := temp / 2;
                bitsNeeded += 1;
            };

            let ?randVal = random.range(Nat8.fromNat(bitsNeeded)) else return null;
            let randInt = min + (randVal % range);
            ?randInt;
        };

        /// Generates a random natural number within the specified range (inclusive).
        /// Returns null if there's not enough entropy.
        ///
        /// ```motoko include=import
        /// let randomGen : RandomGenerator = ...;
        /// let ?randomNat = randomGen.nextNat(1, 10) else return #err("Not enough entropy");
        /// ```
        public func nextNat(min : Nat, max : Nat) : ?Nat {
            let ?randInt = nextInt(min, max) else return null;
            ?Int.abs(randInt);
        };

        /// Shuffles the elements of the given buffer in place.
        /// Returns null if there's not enough entropy to complete the shuffle.
        ///
        /// ```motoko include=import
        /// let randomGen : RandomGenerator = ...;
        /// let buffer = Buffer.fromArray<Nat>([1, 2, 3, 4, 5]);
        /// let ?() = randomGen.shuffleBuffer(buffer) else return #err("Not enough entropy");
        /// ```
        public func shuffleBuffer<T>(buffer : Buffer.Buffer<T>) : ?() {
            let bufferSize = buffer.size();
            if (bufferSize == 0) {
                return ?();
            };
            Buffer.reverse(buffer);
            var i : Nat = bufferSize;
            for (item in buffer.vals()) {
                i -= 1;
                let ?randIdx = nextNat(0, i) else return null;
                let temp = buffer.get(i);
                buffer.put(i, buffer.get(randIdx));
                buffer.put(randIdx, temp);
            };
            return ?();
        };
    };
};
