/// <reference path="../../types/app.ts" />

/**
 * Specification knows how to construct an entire query thingy, i.e.
 * joins etc.
 */
module CSRS {
    export class Specification<T> {
        toPredicate () : Predicate<T> {
            throw new Error("Must implement toPredicate");
        }

        not () : Specification<T> {
            return new NotSpec<T>(this);
        }
    }
    
    export interface Predicate<T> {
        test (t: T) : boolean;
    }

    export class NotSpec<T> extends Specification<T> {
        constructor (
            private spec: Specification<T>
        ) {
            super();
        }

        toPredicate () : Predicate<T> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'Spec.Not',
                spec: this.spec
            })
        }
    }
    
    export class AndSpec<T> extends Specification<T> {
        constructor (
            private specs: Array<Specification<T>>
        ) {
            super();
        }

        toPredicate () : Predicate<T> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'Spec.And',
                specs: this.specs
            })
        }
    }
    
    export class OrSpec<T> extends Specification<T> {
        constructor (
            private specs: Array<Specification<T>>
        ) {
            super();
        }

        toPredicate () : Predicate<T> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'Spec.Or',
                specs: this.specs
            })
        }
    }

    export interface LogicalSpec {
        And: typeof AndSpec;
        Or: typeof OrSpec;
        Not: typeof NotSpec;
    }
}
