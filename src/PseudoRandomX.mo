import Random "mo:base/Random";
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

module Module {

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

    public func fromBlob(blob : Blob) : PseudoRandomGenerator {
        let seed = convertBlobToSeed(blob);
        LinearCongruentialGenerator(seed);
    };

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

    public func fromSeed(seed : Nat32) : PseudoRandomGenerator {
        LinearCongruentialGenerator(seed);
    };

    public class LinearCongruentialGenerator(seed : Nat32) : PseudoRandomGenerator {
        var currentSeed = seed;
        let a : Nat32 = 1664525;
        let c : Nat32 = 1013904223;

        private func nextSeed() : Nat32 {
            currentSeed := currentSeed
            |> Nat32.mulWrap(a, _)
            |> Nat32.addWrap(_, c); // Overflow is ok
            return currentSeed;
        };

        public func getCurrentSeed() : Nat32 {
            currentSeed;
        };

        public func nextInt(min : Int, max : Int) : Int {
            if (min > max) {
                Debug.trap("Min cannot be larger than max");
            };
            let range : Nat = Int.abs(max - min) + 1;

            let randNat32 = nextSeed();
            let rangeSize = max - min + 1;
            min + (Nat32.toNat(randNat32) % rangeSize);
        };

        public func nextNat(min : Nat, max : Nat) : Nat {
            let randInt = nextInt(min, max);
            Int.abs(randInt);
        };

        public func nextCoin() : Bool {
            nextRatio(1, 2);
        };

        public func nextFloat(min : Float, max : Float) : Float {
            if (min > max) {
                Debug.trap("Min cannot be larger than max");
            };
            let randNat32 = nextSeed();
            let randIntValue = Nat32.toNat(randNat32);
            let nat32Max : Float = 4_294_967_295;
            let randFloat = Float.fromInt(randIntValue) / nat32Max;
            min + (max - min) * randFloat;
        };

        public func nextRatio(trueCount : Nat, totalCount : Nat) : Bool {
            if (trueCount > totalCount) {
                Debug.trap("True count cannot be larger than total count");
            };
            let randomValue = nextNat(1, totalCount);
            return randomValue <= trueCount;
        };

        public func nextBufferElement<T>(buffer : Buffer.Buffer<T>) : T {
            let bufferSize = buffer.size();
            if (bufferSize == 0) {
                Debug.trap("Cannot get random element from an empty buffer");
            };
            let randomIndex = nextNat(0, bufferSize - 1);
            buffer.get(randomIndex);
        };

        public func nextArrayElement<T>(array : [T]) : T {
            let arraySize = array.size();
            if (arraySize == 0) {
                Debug.trap("Cannot get random element from an empty array");
            };
            let randomIndex = nextNat(0, arraySize - 1);
            array[randomIndex];
        };

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

        public func nextArrayElementWeightedFunc<T>(array : [T], weightFunc : (T) -> Float) : T {
            let weightedArray = Array.map<T, (T, Float)>(
                array,
                func(item : T) : (T, Float) = (item, weightFunc(item)),
            );
            nextArrayElementWeighted(weightedArray);
        };

        public func shuffleBuffer<T>(buffer : Buffer.Buffer<T>) {
            let bufferSize = buffer.size();
            if (bufferSize == 0) {
                return;
            };
            Buffer.reverse(buffer);
            var i : Nat = bufferSize;
            for (item in buffer.vals()) {
                i -= 1;
                let randomIndex = nextNat(0, i);
                let temp = buffer.get(i);
                buffer.put(i, buffer.get(randomIndex));
                buffer.put(randomIndex, temp);
            };
        };
    };
};
