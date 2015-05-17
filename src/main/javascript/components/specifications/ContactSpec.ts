/// <reference path="../../types/app.ts" />

module CSRS {
    export class ContactWasMember extends Specification<Contact> {
        constructor (
            private yearsRequired: Array<number | string>,
            private yearsForbidden: Array<number | string>
        ) {
            super();
        }

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

    export class ContactWasEverMember extends Specification<Contact> {
        constructor () {
            super();
        }

        toPredicate () : Predicate<Contact> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'ContactWasEverMember'
            });
        }
    }
    
    export class ContactWasMemberInYear extends Specification<Contact> {
        constructor (
            private year: number
        ) {
            super();
        }

        toPredicate () : Predicate<Contact> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'ContactWasMemberInYear',
                year: this.year
            });
        }
    }

    export class ContactHadMembershipTypeInYear extends Specification<Contact> {
        constructor (
            private membershipType: number,
            private year: number
        ) {
            super();
        }

        toPredicate () : Predicate<Contact> {
            return null;
        }

        toJSON () : any {
            return ({
                '@type': 'ContactHadMembershipTypeInYear',
                membershipType: this.membershipType,
                year: this.year
            });
        }
    }

    export interface ContactSpec {
        WasMember: typeof ContactWasMember;
        WasEverMember: typeof ContactWasEverMember;
        WasMemberInYear: typeof ContactWasMemberInYear;
        HadMembershipTypeInYear: typeof ContactHadMembershipTypeInYear;
    }

    angular.module('csrsApp').factory("ContactSpec", () => {
        return {
            WasMember: ContactWasMember,
            WasEverMember: ContactWasEverMember,
            HadMembershipTypeInYear: ContactHadMembershipTypeInYear,
            WasMemberInYear: ContactWasMemberInYear
        };
    });
}
