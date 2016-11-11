###
# Copyright (C) 2014-2015 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: import.controller.spec.coffee
###

describe "ImportProjectMembersCtrl", ->
    $provide = null
    $controller = null
    mocks = {}

    _inject = ->
        inject (_$controller_) ->
            $controller = _$controller_

    _setup = ->
        _inject()

    beforeEach ->
        module "taigaProjects"

        _setup()

    it "search user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        user = {
            id: 1,
            name: "username"
        }

        ctrl.searchUser(user)

        expect(ctrl.selectImportUserLightbox).to.be.true
        expect(ctrl.searchingUser).to.be.equal(user)

    it "prepare submit users, warning if needed", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        user = {
            id: 1,
            name: "username"
        }

        ctrl.selectedUsers = Immutable.fromJS([
            {id: 1},
            {id: 2}
        ])

        ctrl.members = Immutable.fromJS([
            {id: 1}
        ])

        ctrl.beforeSubmitUsers()

        expect(ctrl.warningImportUsers).to.be.true

    it "prepare submit users, submit", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        user = {
            id: 1,
            name: "username"
        }

        ctrl.selectedUsers = Immutable.fromJS([
            {id: 1}
        ])

        ctrl.members = Immutable.fromJS([
            {id: 1}
        ])


        ctrl.submit = sinon.spy()
        ctrl.beforeSubmitUsers()

        expect(ctrl.warningImportUsers).to.be.false
        expect(ctrl.submit).have.been.called

    it "confirm user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.discardSuggestedUser = sinon.spy()

        ctrl.confirmUser('user', 'taiga-user')

        expect(ctrl.selectedUsers.size).to.be.equal(1)

        expect(ctrl.selectedUsers.get(0).get('user')).to.be.equal('user')
        expect(ctrl.selectedUsers.get(0).get('taigaUser')).to.be.equal('taiga-user')
        expect(ctrl.discardSuggestedUser).have.been.called

    it "discard suggested user", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.discardSuggestedUser(Immutable.fromJS({
            id: 3
        }))

        expect(ctrl.cancelledUsers.get(0)).to.be.equal(3)

    it "clean member selection", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.selectedUsers = Immutable.fromJS([
            {
                user: {
                    id: 1
                }
            },
            {
                user: {
                    id: 2
                }
            }
        ])

        ctrl.cleanMember(Immutable.fromJS({
            id: 2
        }))

        expect(ctrl.selectedUsers.size).to.be.equal(1)


    it "get a selected member", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        member = Immutable.fromJS({
            id: 3
        })

        ctrl.selectedUsers = ctrl.selectedUsers.push(Immutable.fromJS({
            user: {
                id: 3
            }
        }))

        user = ctrl.getSelectedMember(member)

        expect(user.getIn(['user', 'id'])).to.be.equal(3)

    it "submit", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.selectedUsers = ctrl.selectedUsers.push(Immutable.fromJS({
            user: {
                id: 3
            },
            taigaUser: {
                id: 2
            }
        }))

        ctrl.onSubmit = sinon.stub()

        ctrl.submit()

        user = Immutable.Map()
        user = user.set(3, 2)

        expect(ctrl.onSubmit).have.been.called
        expect(ctrl.warningImportUsers).to.be.false

    it "show suggested match", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.isMemberSelected = sinon.stub().returns(false)
        ctrl.cancelledUsers = [
            3
        ]

        member = Immutable.fromJS({
            id: 1,
            user: {
                id: 10
            }
        })

        expect(ctrl.showSuggestedMatch(member)).to.be.true

    it "doesn't show suggested match", () ->
        ctrl = $controller("ImportProjectMembersCtrl")

        ctrl.isMemberSelected = sinon.stub().returns(false)
        ctrl.cancelledUsers = [
            3
        ]

        member = Immutable.fromJS({
            id: 3,
            user: {
                id: 10
            }
        })

        expect(ctrl.showSuggestedMatch(member)).to.be.false
