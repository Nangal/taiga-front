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
# File: import-project-members.controller.coffee
###

class ImportProjectMembersController
    constructor: () ->
        @.selectImportUserLightbox = false
        @.warningImportUsers = false
        @.selectedUsers = Immutable.List()
        @.cancelledUsers = Immutable.List()

    searchUser: (user) ->
        @.selectImportUserLightbox = true
        @.searchingUser = user

    beforeSubmitUsers: () ->
        if @.selectedUsers.size != @.members.size
            @.warningImportUsers = true
        else
            @.submit()

    confirmUser: (externalUser, taigaUser) ->
        @.selectImportUserLightbox = false

        user = Immutable.Map()

        user = user.set('user', externalUser)
        user = user.set('taigaUser', taigaUser)

        @.selectedUsers = @.selectedUsers.push(user)

        @.discardSuggestedUser(externalUser)

    discardSuggestedUser: (member) ->
        @.cancelledUsers = @.cancelledUsers.push(member.get('id'))

    cleanMember: (member) ->
        index = @.selectedUsers.findIndex (it) -> it.getIn(['user', 'id']) == member.get('id')

        @.selectedUsers = @.selectedUsers.delete(index)

    getSelectedMember: (member) ->
        return @.selectedUsers.find (it) ->
            return it.getIn(['user', 'id']) == member.get('id')

    isMemberSelected: (member) ->
        return !!@.getSelectedMember(member)

    getUser: (user) ->
        userSelected = @.getSelectedMember(user)

        if userSelected
            return userSelected.get('taigaUser')
        else
            return null

    submit: () ->
        @.warningImportUsers = false

        users = Immutable.Map()

        @.selectedUsers.map (it) ->
            users = users.set(it.getIn(['user', 'id']), it.getIn(['taigaUser', 'id']))

        @.onSubmit({users: users})

    showSuggestedMatch: (member) ->
        return member.get('user') && @.cancelledUsers.indexOf(member.get('id')) == -1 && !@.isMemberSelected(member)

angular.module('taigaProjects').controller('ImportProjectMembersCtrl', ImportProjectMembersController)
