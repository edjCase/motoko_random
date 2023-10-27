import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

module Module {
    public type RandomGenerator = {
        nextInt : (min : Int, max : Int) -> ?Int;
        nextNat : (min : Nat, max : Nat) -> ?Nat;
        nextCoin : () -> ?Bool;
        nextRatio : (trueCount : Nat, totalCount : Nat) -> ?Bool;
        shuffleBuffer : <T>(buffer : Buffer.Buffer<T>) -> ?();
    };

    public type Result<T> = {
        #ok : T;
        #noEntropy;
    };

    public func fromSeed(seed : Blob) : FiniteX {
        FiniteX(seed);
    };

    public class FiniteX(seed : Blob) : RandomGenerator {
        let random = Random.Finite(seed);

        public func nextCoin() : ?Bool {
            random.coin();
        };

        public func nextRatio(trueCount : Nat, totalCount : Nat) : ?Bool {
            if (trueCount > totalCount) {
                Debug.trap("True count cannot be larger than total count");
            };
            let ?randValue = nextNat(1, totalCount) else return null;
            ?(randValue <= trueCount);
        };

        public func nextInt(min : Int, max : Int) : ?Int {
            if (min > max) {
                Debug.trap("Min cannot be larger than max");
            };
            let range : Nat = Int.abs(max - min) + 1;

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

        public func nextNat(min : Nat, max : Nat) : ?Nat {
            let ?randInt = nextInt(min, max) else return null;
            ?Int.abs(randInt);
        };

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
