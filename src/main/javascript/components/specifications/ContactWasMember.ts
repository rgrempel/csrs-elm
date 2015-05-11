/// <reference path="../../types/app.ts" />

module CSRS {
    export class ContactWasMember implements Specification<Contact> {
        constructor (
            private yearsRequired: Array<number | string>,
            private yearsForbidden: Array<number | string>
        ) {}

        toPredicate () : Predicate<Contact> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'ContactWasMember', 
                yearsRequired: this.yearsRequired,
                yearsForbidden: this.yearsForbidden,
            });
        }
    }

    angular.module('csrsApp').factory("ContactWasMember", () => {
        return ContactWasMember;
    });
}
