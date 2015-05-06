/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    export interface Annual {
        id: number;
        year: number;
        membership: number;
        contact: Contact;
    }

    export class Contact {
        id: number;
        salutation: string;
        firstName: string;
        lastName: string;
        plainFirstName: string;
        plainLastName: string;
        department: string;
        affiliation: string;
        street: string;
        city: string;
        region: string;
        country: string;
        postalCode: string;
        omitNameFromDirectory: boolean;
        omitEmailFromDirectory: boolean;
        annuals: Array<Annual>;

        fullName () : string {
            return Stream.of(this.salutation, this.firstName, this.lastName).filter((o) => {
                return (o != null) && (o.length != 0);
            }).joining(" ");
        }

        fullAddress () : string {
            var cityState: string = Stream.of(this.city, this.region).filter((o) => {
                return (o != null) && (o.length != 0);
            }).joining(", ");

            return Stream.of(this.street, cityState, this.country, this.postalCode).filter((o) => {
                return (o != null) && (o.length != 0);
            }).joining("\n");
        }
    }

    angular.module('csrsApp').factory('contactRepository', function (DS: JSData.DS) {
        'ngInject';

        return DS.defineResource<Contact>({
            name: 'Contact',
            endpoint: 'contacts',
            useClass: Contact
        }); 
    });
}
