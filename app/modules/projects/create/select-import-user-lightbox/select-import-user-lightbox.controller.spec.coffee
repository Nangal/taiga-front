###
# Copyright (C) 2014-2016 Taiga Agile LLC <taiga@taiga.io>
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
# File: select-import-user-lightbox.controller.spec.coffee
###

describe "SelectImportUserLightboxCtrl", ->
    $provide = null
    $controller = null
    mocks = {}

    _inject = (callback) ->
        inject (_$controller_, _$q_, _$rootScope_) ->
            $controller = _$controller_


    _mockUserService = () ->
        mocks.userService = {
            getContacts: sinon.stub()
        }

        $provide.value("tgUserService", mocks.userService)

    _mockCurrentUserService = ->
        mocks.currentUserService = {
            getUser: sinon.stub()
        }

        $provide.value("tgCurrentUserService", mocks.currentUserService)

    _mocks = ->
        module (_$provide_) ->
            $provide = _$provide_

            _mockUserService()
            _mockCurrentUserService()

            return null

    beforeEach ->
        module "taigaProjects"

        _mocks()
        _inject()

    it "init select user lightbox", (done) ->
        user = Immutable.fromJS({
            id: 2,
            name: 'xxyy'
        })

        mocks.currentUserService.getUser.returns(user)

        mocks.userService.getContacts.withArgs(2).promise().resolve()

        ctrl = $controller("SelectImportUserLightboxCtrl")

        ctrl.setContacts = sinon.spy()

        ctrl.start().then () ->
            expect(ctrl.currentUser).to.be.equal(user)
            expect(ctrl.setContacts).to.have.been.called
            ctrl.mode = 'search'
            ctrl.invalid = false

            done()
