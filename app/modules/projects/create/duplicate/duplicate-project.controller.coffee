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
# File: project.controller.coffee
###

class DuplicateProjectController
    @.$inject = [
        "tgCurrentUserService",
        "tgProjectsService",
        "$tgLocation",
        "$tgNavUrls"
    ]

    constructor: (@currentUserService, @projectsService, @location, @navUrls) ->
        @.user = @currentUserService.getUser()

        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        taiga.defineImmutableProperty @, 'projects', () => @currentUserService.projects.get("all")

        @.projectForm = {
            is_private: false
        }

    getReferenceProject: (slug) ->
        @projectsService.getProjectBySlug(slug).then (project) =>
            @.referenceProject = project
            @.invitedMembers = project.get('members')
            @._getInvitedMembers(@.invitedMembers)

    _getInvitedMembers: (members) ->
        @.invitedMembers = members
        @.invitedMembers = @.invitedMembers.filter (members) =>
            members.get('id') != @.user.get('id')
        @.setInvitedMembers(@.invitedMembers)
        @.checkUsersLimit(@.invitedMembers)

    setInvitedMembers: (members) ->
        @.projectForm.users = members.map (member) =>
            member.get('id')
        @.checkUsersLimit(members)

    checkUsersLimit: (members) ->
        size = members.size
        @.limitMembersPrivateProject = undefined
        @.limitMembersPublicProject = undefined
        if @.projectForm.is_private
            @.limitMembersPublicProject = false
            @.limitMembersPrivateProject = @.user.get('max_memberships_private_projects') < size
        else if !@.projectForm.is_private && @.user.get('max_memberships_public_projects')
            @.limitMembersPrivateProject = false
            @.limitMembersPublicProject = @.user.get('max_memberships_public_projects') < size

    submit: () ->
        projectId = @.referenceProject.get('id')
        data = @.projectForm

        @.formSubmitLoading = true
        @projectsService.duplicate(projectId, data).then (newProject) =>
            @.formSubmitLoading = false
            @location.path(@navUrls.resolve("project", {project: newProject.data.slug}))
            @currentUserService.loadProjects()

    isDisabled: () ->
        return !@.projectForm.description || !@.referenceProject || @.loading || @.limitMembersPrivateProject || @.limitMembersPublicProject

    onCancelForm: () ->
        @location.path(@navUrls.resolve("create-project"))

angular.module("taigaProjects").controller("DuplicateProjectCtrl", DuplicateProjectController)
