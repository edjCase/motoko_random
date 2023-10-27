import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";

module Module {

    public type PseudoRandomGenerator = {
        nextInt : (min : Int, max : Int) -> Int;
        nextNat : (min : Nat, max : Nat) -> Nat;
        nextCoin : () -> Bool;
        nextRatio : (trueCount : Nat, totalCount : Nat) -> Bool;
        shuffleBuffer : <T>(buffer : Buffer.Buffer<T>) -> ();
    };

    public func fromSeed(seed : Nat32) : PseudoRandomGenerator {
        LinearCongruentialGenerator(seed);
    };

    public class LinearCongruentialGenerator(seed : Nat32) : PseudoRandomGenerator {
        var currentValue = seed;
        let a : Nat32 = 1664525;
        let c : Nat32 = 1013904223;

        private func nextSeed() : Nat32 {
            currentValue := currentValue
            |> Nat32.mulWrap(a, _)
            |> Nat32.addWrap(_, c); // Overflow is ok
            return currentValue;
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

        public func nextRatio(trueCount : Nat, totalCount : Nat) : Bool {
            if (trueCount > totalCount) {
                Debug.trap("True count cannot be larger than total count");
            };
            let randomValue = nextNat(1, totalCount);
            return randomValue <= trueCount;
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
                let randIdx = nextNat(0, i);
                let temp = buffer.get(i);
                buffer.put(i, buffer.get(randIdx));
                buffer.put(randIdx, temp);
            };
        };
    };
};
