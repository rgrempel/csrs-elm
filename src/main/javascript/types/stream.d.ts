declare var Stream: streamjs.Stream;

declare module streamjs {
    interface Stream {
        <T> (input: Array<T>) : Pipeline<T>;
        
        range (startInclusive: number, endInclusive: number) : Pipeline<number>;
        rangeClosed (startInclusive: number, endInclusive: number) : Pipeline<number>;

        of<T> (...args: Array<T>) : Pipeline<T>;

        // Stream.generate = function (supplier) {
        // Stream.iterate = function (seed, fn) {

        empty () : Pipeline<void>;
        VERSION: string;
        Optional: Optional<void>;
    }

    interface Pipeline<T> {
        map<U> (property: string) : Pipeline<U>;
        map<U> (callback: (value: T) => U) : Pipeline<U>;
        flatMap<U> (property: string) : Pipeline<U>;
        flatMap<U> (callback: (value: T) => Array<U>) : Pipeline<U>;
        forEach (callback: (value: T) => void) : void;
        toArray () : Array<T>;
        distinct () : Pipeline<T>;
        joining (delimiter: string) : string;
        reduce<U> (accum: U, callback: (accum: U, value: T) => U) : U; 
        sorted (callback: (a: T, b: T) => number) : Pipeline<T>;
        sorted () : Pipeline<T>;
        sorted (property: string) : Pipeline<T>;
        limit (size: number) : Pipeline<T>;
        filter (callback: (value: T) => boolean) : Pipeline<T>;
        anyMatch (callback: (value: T) => boolean) : boolean;
        allMatch (callback: (value: T) => boolean) : boolean;
        max (property: string) : Optional<T>;
    }

    interface Optional<T> {
        ofNullable<U> (nullable: U) : Optional<U>;
        map<U> (callback: (value: T) => U) : Optional<U>;
        orElse (value: T) : T;
    }
}
