/// <reference path="../../../types/app.ts" />

module CSRS {
    'use strict';

    interface MemberCount {
        year: number;
        membership: number;
        count: number;
    }

    interface Memberships {
        [membership: number]: MemberCount;
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
//        contacts: Array<Contact>;
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

        http: angular.IHttpService;
        window: angular.IWindowService;
        stream: streamjs.Stream;
        location: angular.ILocationService;

        constructor (
            contactRepository: JSData.DSResourceDefinition<Contact>,
            templateRepository: JSData.DSResourceDefinition<Template>,

            $http: angular.IHttpService,
            $scope: angular.IScope,
            Stream: streamjs.Stream,
            $state: angular.ui.IStateService,
            $location: angular.ILocationService,
            $window: angular.IWindowService
        ) {
            'ngInject';

            this.contactRepository = contactRepository;
            this.templateRepository = templateRepository;

            this.location = $location;
            this.window = $window;
            this.http = $http;

            this.serverError = null;
            this.scope = $scope;

//            this.contacts = [];
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

            $http.get(
                '/api/annuals/count'
            ).success((data: Array<MemberCount>) => {
                this.serverError = null;
                this.handleMemberCount(data);
            }).error((data, status, headers, config) => {
                this.serverError = angular.toJson(data);
            });

/*            
            $scope.$watch(() => {
                return contactRepository.lastModified();
            }, () => {
                this.handleContactsChanged();
            });

            contactRepository.findAll();
*/
            this.updateFilter();

            $scope.$watch(() => {
                return templateRepository.lastModified();
            }, () => {
                this.templates = Stream(
                    this.templateRepository.filter({})
                ).sorted('code').toArray();
            });

            templateRepository.findAll();
        }

        handleMemberCount (input: Array<MemberCount>) : void {
            // Partition according to membership type and year
            this.years = [];
            this.yearIndex = {};
            
            Stream(input).filter((count) => {
                return count.membership != 0;
            }).forEach((memberCount) => {
                if (!this.yearIndex[memberCount.year]) {
                    var newYear = {
                        year: memberCount.year,
                        total: 0,
                        memberships: <Memberships> {}
                    };

                    this.yearIndex[memberCount.year] = newYear;
                    this.years.push(newYear);
                }

                var year = this.yearIndex[memberCount.year];
                year.total += memberCount.count;

                year.memberships[memberCount.membership] = memberCount;
            });

            this.years = Stream(this.years).sorted((a, b) => {
                if (a.year > b.year) return -1;
                if (a.year < b.year) return 1;
                return 0;
            }).toArray();
        }
/*
        handleContactsChanged () : void {
            this.contacts = this.contactRepository.filter({});
            this.updateFilter();
        }
*/
        sortContactsByName (a: Contact, b: Contact) {
            if (a.lastName > b.lastName) return 1;
            if (a.lastName < b.lastName) return -1;
            if (a.firstName > b.firstName) return 1;
            if (a.firstName < b.firstName) return -1;
            return 0;
        }

        updateFilter () : void {
            this.http.get("/api/contacts", {
                params: {
                    yr: this.getYearsRequiredArray(),
                    yf: this.getYearsForbiddenArray()
                }
            }).success((data: Array<Contact>) => {
                this.serverError = null;
                this.handleContacts(data);
            }).error((data, status, headers, config) => {
                this.serverError = angular.toJson(data);
            });
        }

        handleContacts (input: Array<Contact>) {
            this.filtered = Stream(input).sorted(
                this.sortContactsByName
            ).toArray();
        }

        getMergeURL () {
            if (!this.selectedTemplate) return "";

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
