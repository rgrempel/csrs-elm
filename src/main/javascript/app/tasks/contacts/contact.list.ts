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

    interface MemberSelections {
        [membership: number]: number;
    }

    interface YearSelection {
        memberships: MemberSelections;
        allStatus: number;
    }

    interface Selections {
        [year: number]: YearSelection;
    }
    
    var simplify = function (item : Selections) : string {
        var simplified: Selections = {};

        angular.forEach(item, (yearSelection: YearSelection, year: number) => {
            if (yearSelection.allStatus) {
                // If we have a status, that's all we need to record
                simplified[year] = {
                    allStatus: yearSelection.allStatus,
                    memberships: []
                }
            } else {
                angular.forEach(yearSelection.memberships, (required: number, membershipType: number) => {
                    if (required) {
                        if (!simplified[year]) {
                            simplified[year] = {
                                allStatus: 0,
                                memberships: []
                            };
                        }

                        simplified[year].memberships[membershipType] = required;
                    }
                });
            }
        });

        return angular.toJson(simplified);
    };

    class ContactListController {
        filtered: Array<Contact>;
        templates: Array<Template>;
        selectedTemplate: Template;

        years: Array<Year>;
        yearIndex: YearIndex;
        membershipTypes: Array<number>;

        selections: Selections;
        filterString: string;
        
        serverError: string;
        
        constructor (
            private contactRepository: JSData.DSResourceDefinition<Contact>,
            private templateRepository: JSData.DSResourceDefinition<Template>,

            private $http: angular.IHttpService,
            private $scope: angular.IScope,
            private Stream: streamjs.Stream,
            private $state: angular.ui.IStateService,
            private $location: angular.ILocationService,
            private $translate: any,
            private $window: angular.IWindowService
        ) {
            'ngInject';

            this.serverError = null;
            this.filtered = [];
            this.filterString = "";
           
            this.selections = $state.params['selections'] || {};
            this.membershipTypes = [1, 2, 3, 4, 5];

            $http.get(
                '/api/annuals/count'
            ).success((data: Array<MemberCount>) => {
                this.serverError = null;
                this.handleMemberCount(data);
            }).error((data, status, headers, config) => {
                this.serverError = angular.toJson(data);
            });

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
        
        sortContactsByName (a: Contact, b: Contact) {
            if (a.lastName > b.lastName) return 1;
            if (a.lastName < b.lastName) return -1;
            if (a.firstName > b.firstName) return 1;
            if (a.firstName < b.firstName) return -1;
            return 0;
        }

        updateLocation () : void {
            this.$location.search({
                selections: simplify(this.selections)
            });

            this.$location.replace();
        }

        updateFilter () : void {
            // Default the filter to anyone who has been a member
            var ands: Array<Specification<Contact>> = [];
            var ors: Array<Specification<Contact>> = [];
            var nots: Array<Specification<Contact>> = [];

            angular.forEach(this.selections, (yearSelection: YearSelection, year: number) => {
                if (yearSelection.allStatus) {
                    // We're requiring the year as a whole
                    var spec : Specification<Contact> = new ContactWasMemberInYear(year);
                    
                    if (yearSelection.allStatus == 1) {
                        ors.push(spec);
                    } else if (yearSelection.allStatus == 2) {
                        ands.push(spec);
                    } else if (yearSelection.allStatus == 3) {
                        nots.push(spec.not());
                    }
                } else {
                    angular.forEach(yearSelection.memberships, (required, membership) => {
                        if (required) {
                            var spec : Specification<Contact> = new ContactHadMembershipTypeInYear(membership, year);
                            
                            if (required == 1) {
                                ors.push(spec);
                            } else if (required == 2) {
                                ands.push(spec);
                            } else if (required == 3) {
                                nots.push(spec.not());
                            }
                        }
                    });
                }
            });

            if (ors.length == 0 && ands.length == 0) {
                // If no positive specs, then limit to members
                ors.push(new ContactWasEverMember());
            }

            var filter : Filter<Contact>;

            if (ands.length > 0) {
                // If we have some ands, the ors don't matter, because you have
                // to meet the and requirement.
                filter = {
                    spec: new AndSpec(ands.concat(nots))
                };
            } else {
                // So here we just have ors and nots
                if (nots.length > 0) {
                    filter = {
                        spec: new AndSpec([
                            new OrSpec(ors),
                            new AndSpec(nots)
                        ])
                    };
                } else {
                    filter = {
                        spec: new OrSpec(ors)
                    };
                }
            }

            this.filterString = angular.toJson(filter);

            this.$http.post(
                "/api/contacts/filter", filter    
            ).success((data: Array<Contact>) => {
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
            if (!this.selectedTemplate || !this.filterString) {
                return "#";
            }

            return "/letters/" + this.selectedTemplate.code + ".pdf?filter=" + this.filterString;
        }
        
        getExportURL () {
            if (!this.filterString) {
                return "#";
            }

            return "/export/contacts.xls?filter=" + this.filterString;
        }

        sendInvitations () {
            var ids = Stream(this.filtered).map('id').toArray();
            this.$translate("membership.byYear.confirmSendInvitations", {
                howMany: ids.length
            }).then((message: any) => {
                if (confirm(message)) {
                    this.$http.post("/api/invitation/contacts", {
                        contactIDs: ids
                    }).success(() => {
                        this.$translate("membership.byYear.invitationsHaveBeenSent").then((msg: any) => {
                            alert(msg);
                        });
                    }).error((data: any) => {
                        alert(angular.toJson(data));
                    });
                }
            });
        }

        // So:
        //
        // 0 means nothing
        // 1 means or'd ... i.e. include multiple
        // 2 means and'd ... i.e. require all
        // 3 means not'd ... i.e. exclude
        initYearSelection (year: number) : void {
            if (!this.selections[year]) this.selections[year] = {
                allStatus: 0,
                memberships: {}
            };
        }

        isYearIncluded (year: number) : boolean {
            this.initYearSelection(year);
            return this.selections[year].allStatus == 1;
        }

        isIncluded (year: number, membershipType: number) : boolean {
            this.initYearSelection(year);
            let membership = this.selections[year].memberships[membershipType];
            return membership == 1;
        }

        isYearRequired (year: number) : boolean {
            this.initYearSelection(year);
            return this.selections[year].allStatus == 2;
        }

        isRequired (year: number, membershipType: number) : boolean {
            this.initYearSelection(year);
            let membership = this.selections[year].memberships[membershipType];
            return membership == 2;
        }

        isYearForbidden (year: number) : boolean {
            this.initYearSelection(year);
            return this.selections[year].allStatus == 3;
        }
        
        isForbidden (year: number, membershipType: number) : boolean {
            this.initYearSelection(year);
            let membership = this.selections[year].memberships[membershipType];
            return membership == 3;
        }

        setYearIncluded (year: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 1;
            this.selections[year].memberships = {};
        }

        setIncluded (year: number, membershipType: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 0;
            this.selections[year].memberships[membershipType] = 1;
        }

        setYearRequired (year: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 2;
            this.selections[year].memberships = {};
        }

        setRequired (year: number, membershipType: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 0;
            this.selections[year].memberships[membershipType] = 2;
        }

        setYearForbidden (year: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 3;
            this.selections[year].memberships = {};
        }
        
        setForbidden (year: number, membershipType: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 0;
            this.selections[year].memberships[membershipType] = 3;
        }

        setYearIndifferent (year: number) : void {
            this.initYearSelection(year);
            this.selections[year].allStatus = 0;
        }
        
        setIndifferent (year: number, membershipType: number) : void {
            this.initYearSelection(year);
            this.selections[year].memberships[membershipType] = 0;
        }

        cycleYearRequired (year: number) : void {
            if (this.isYearIncluded(year)) {
                // Cycle from included to required
                this.setYearRequired(year);
            } else if (this.isYearRequired(year)) {
                // Cycle from required to forbidden
                this.setYearForbidden(year);
            } else if (this.isYearForbidden(year)) {
                // Cycle from forbidden to indifferent
                this.setYearIndifferent(year);
            } else {
                // Cycle from indifferent to included
                this.setYearIncluded(year);
            }
            
            this.updateLocation();
            this.updateFilter();
        }
 
        cycleRequired (year: number, membershipType: number) : void {
            if (this.isIncluded(year, membershipType)) {
                this.setRequired(year, membershipType);
            } else if (this.isRequired(year, membershipType)) {
                this.setForbidden(year, membershipType);
            } else if (this.isForbidden(year, membershipType)) {
                this.setIndifferent(year, membershipType);
            } else {
                this.setIncluded(year, membershipType);
            }

            this.updateLocation();
            this.updateFilter();
        }
    }

    angular.module('csrsApp').controller('ContactListController', ContactListController);

    angular.module('csrsApp').config(function (
        $stateProvider: angular.ui.IStateProvider,
        $urlMatcherFactoryProvider: angular.ui.IUrlMatcherFactory
    ) {
        'ngInject';

        $urlMatcherFactoryProvider.type('selection', {
            encode: function (item: any) {
                return simplify(item);
            },
            
            decode: function (item: string) {
                return angular.fromJson(item);
            },
            
            is: function (val: any, key: string) {
                return angular.isObject(val);
            },

            equals: function (a: any, b: any) {
                return simplify(a) == simplify(b);
            }
        });

        $stateProvider.state('contact-list', {
            parent: 'admin',
            url: '/contacts?{selections:selection}',
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
