/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    interface Memberships {
        [membership: number]: Array<Annual>;
    }

    interface Year {
        year: number;
        total: number;
        memberships: Memberships
    }

    interface YearIndex {
        [year: number]: Year;
    }

    class ContactListController {
        contacts: Array<Contact>;
        filtered: Array<Contact>;
        templates: Array<Template>;
        selectedTemplate: Template;

        years: Array<Year>;
        yearIndex: YearIndex;
        membershipTypes: Array<number>;

        yearsRequired: {[year: number]: boolean};
        yearsForbidden: {[year: number]: boolean};
        
        serverError: string;
        scope: angular.IScope;
        
        contactRepository: JSData.DSResourceDefinition<Contact>;
        templateRepository: JSData.DSResourceDefinition<Template>;
        window: angular.IWindowService;

        stream: streamjs.Stream;
        location: angular.ILocationService;

        constructor (
            contactRepository: JSData.DSResourceDefinition<Contact>,
            templateRepository: JSData.DSResourceDefinition<Template>,
            $scope: angular.IScope,
            Stream: streamjs.Stream,
            $state: angular.ui.IStateService,
            $location: angular.ILocationService,
            $window: angular.IWindowService
        ) {
            'ngInject';

            this.serverError = null;
            this.contactRepository = contactRepository;
            this.templateRepository = templateRepository;
            this.location = $location;
            this.window = $window;

            this.scope = $scope;
            this.contacts = [];
            this.filtered = [];
            
            this.yearsRequired = {};
            this.yearsForbidden = {};
            this.membershipTypes = [1, 2, 3, 4, 5];

            var param = $state.params['yr'];
            if (param && !angular.isArray(param)) param = [param];
            angular.forEach(param, (yr: number) => {
                this.yearsRequired[yr] = true;
            });
            
            var param = $state.params['yf'];
            if (param && !angular.isArray(param)) param = [param];
            angular.forEach(param, (yf: number) => {
                this.yearsForbidden[yf] = true;
            });

            $scope.$watch(() => {
                return contactRepository.lastModified();
            }, () => {
                this.handleContactsChanged();
            });

            contactRepository.findAll();

            $scope.$watch(() => {
                return templateRepository.lastModified();
            }, () => {
                this.templates = Stream(
                    this.templateRepository.filter({})
                ).sorted('code').toArray();
            });

            templateRepository.findAll();
        }

        handleContactsChanged () : void {
            this.contacts = this.contactRepository.filter({});

            // Partition according to membership type and year
            this.years = [];
            this.yearIndex = {};
            
            Stream(
                this.contacts
            ).flatMap((contact) => {
                return contact.annuals;
            }).filter((annual) => {
                return annual.membership !== 0;
            }).forEach((annual) => {
                if (!this.yearIndex[annual.year]) {
                    var newYear = {
                        year: annual.year,
                        total: 0,
                        memberships: <Memberships> {}
                    };

                    this.yearIndex[annual.year] = newYear;
                    this.years.push(newYear);
                }

                var year = this.yearIndex[annual.year];
                year.total += 1;

                if (year.memberships[annual.membership] == null) {
                    year.memberships[annual.membership] = [];
                }

                year.memberships[annual.membership].push(annual);
            });

            this.years = Stream(this.years).sorted((a, b) => {
                if (a.year > b.year) return -1;
                if (a.year < b.year) return 1;
                return 0;
            }).toArray();

            this.updateFilter();
        }

        sortContactsByName (a: Contact, b: Contact) {
            if (a.lastName > b.lastName) return 1;
            if (a.lastName < b.lastName) return -1;
            if (a.firstName > b.firstName) return 1;
            if (a.firstName < b.firstName) return -1;
            return 0;
        }

        updateFilter () : void {
            var totalRequired = 0;
            angular.forEach(this.yearsRequired, (required, year) => {
                if (required) totalRequired += 1;
            });

            this.filtered = Stream(this.contacts).filter((contact) => {
                var requiredCount = 0;

                // If there are no annuals, then they were never a member, so false
                if (contact.annuals.length === 0) return false;
                
                var foundForbidden = Stream(contact.annuals).anyMatch((annual) => {
                    // Also count the requireds ...
                    if (this.isRequired(annual.year)) {
                        requiredCount += 1;
                    }

                    return this.isForbidden(annual.year);
                });

                // If any were forbidden, return false
                if (foundForbidden) return false;

                // Otherwise, return whether we found everything that was required
                return requiredCount === totalRequired;
            }).sorted(
                this.sortContactsByName
            ).toArray();
        }

        getMergeURL () {
            var loc = "/letters/" + this.selectedTemplate.code + ".pdf?";

            var yr = this.getYearsRequiredArray();
            var yf = this.getYearsForbiddenArray();

            loc += "yr=";
            loc += yr.join("&yr=");

            if (yf.length > 0) {
                loc += '&yf=';
                loc += yf.join("&yf=");
            }

            return loc;
        }

        getYearsRequiredArray () : Array<string> {
            return _.keys(this.yearsRequired);
        }

        getYearsForbiddenArray () : Array<string> {
            return _.keys(this.yearsForbidden);
        }
        
        isRequired (year: number) : boolean {
            return this.yearsRequired[year];
        }

        isForbidden (year: number) : boolean {
            return this.yearsForbidden[year];
        }

        setRequired (year: number) : void {
            this.yearsRequired[year] = true;
            delete this.yearsForbidden[year];
        }

        setForbidden (year: number) : void {
            delete this.yearsRequired[year];
            this.yearsForbidden[year] = true;
        }

        setIndifferent (year: number) : void {
            delete this.yearsRequired[year];
            delete this.yearsForbidden[year];
        }

        cycleRequired (year: number) : void {
            if (this.isRequired(year))
                // Cycle from required to forbidden
                this.setForbidden(year);
            else if (this.isForbidden(year)) {
                // Cycle from forbidden to indifferent
                this.setIndifferent(year);
            } else {
                // Cycle from indifferent to required
                this.setRequired(year);
            }

            this.location.search({
                yr: this.getYearsRequiredArray(),
                yf: this.getYearsForbiddenArray()
            });

            this.location.replace();

            this.updateFilter();
        }
    }

    angular.module('csrsApp').controller('ContactListController', ContactListController);

    angular.module('csrsApp').config(function ($stateProvider: angular.ui.IStateProvider) {
        'ngInject';

        $stateProvider.state('contact-list', {
            parent: 'admin',
            url: '/contacts?yr&yf',
            reloadOnSearch: false,
            data: {
                roles: ['ROLE_ADMIN'],
                pageTitle: 'contacts.title'
            },
            views: {
                'content@': {
                    templateUrl: 'scripts/app/tasks/contacts/contact.list.html',
                    controller: 'ContactListController',
                    controllerAs: 'contactList'
                }
            }
        });
    });
}
