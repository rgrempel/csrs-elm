/// <reference path="../../types/app.ts" />

/**
 * Specification knows how to construct an entire query thingy, i.e.
 * joins etc.
 */
module CSRS {
    export interface Specification<T> {
        toPredicate () : Predicate<T>;
    }
    
    export interface Predicate<T> {
        test (t: T) : boolean;
    }
}
