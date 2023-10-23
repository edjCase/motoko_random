import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";

module Module {
    public type RandomBinomialGenerator = {
        binomial : (Nat8) -> ?Nat8;
    };
    public type RandomByteGenerator = {
        byte : () -> ?Nat8;
    };
    public type RandomRangeGenerator = {
        range : (Nat8) -> ?Nat;
    };
    public type RandomCoinGenerator = {
        coin : () -> ?Bool;
    };
    public type RandomNumberGenerator = RandomBinomialGenerator and RandomByteGenerator and RandomRangeGenerator and RandomCoinGenerator;

    public func fromSeed(seed : Blob) : FiniteX {
        FiniteX(seed);
    };

    public func randomInt(random : RandomRangeGenerator, min : Int, max : Int) : ?Int {
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

    public func randomNat(random : RandomRangeGenerator, min : Nat, max : Nat) : ?Nat {
        let ?randInt = randomInt(random, min, max) else return null;
        ?Int.abs(randInt);
    };

    public func shuffleArray<T>(random : RandomRangeGenerator, array : [T]) : ?[T] {
        let arraySize = array.size();
        if (arraySize == 0) {
            return ?array;
        };
        let shuffledArray = Buffer.fromArray<T>(array);
        Buffer.reverse(shuffledArray);
        var i : Nat = arraySize;
        for (item in shuffledArray.vals()) {
            i -= 1;
            let ?randIdx = randomNat(random, 0, i) else return null;
            let temp = shuffledArray.get(i);
            shuffledArray.put(i, shuffledArray.get(randIdx));
            shuffledArray.put(randIdx, temp);
        };
        return ?Buffer.toArray(shuffledArray);
    };

    public class FiniteX(seed : Blob) {
        let random : RandomNumberGenerator = Random.Finite(seed);

        public func byte() : ?Nat8 {
            random.byte();
        };

        public func bool() : ?Bool {
            random.coin();
        };

        public func int(min : Int, max : Int) : ?Int {
            Module.randomInt(random, min, max);
        };

        public func nat(min : Nat, max : Nat) : ?Nat {
            Module.randomNat(random, min, max);
        };

        public func shuffleElements<T>(array : [T]) : ?[T] {
            Module.shuffleArray<T>(random, array);
        };

        public func randomElement<T>(array : [T]) : ?T {
            let ?i = nat(0, array.size() - 1) else return null;
            ?array.get(i);
        };
    };
};
