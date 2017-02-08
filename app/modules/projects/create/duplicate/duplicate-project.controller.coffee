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
        @.members = Immutable.List()

        @.canCreatePublicProjects = @currentUserService.canCreatePublicProjects()
        @.canCreatePrivateProjects = @currentUserService.canCreatePrivateProjects()

        taiga.defineImmutableProperty @, 'projects', () => @currentUserService.projects.get("all")

        @.projectForm = {
            is_private: false
        }

        if !@.canCreateProject()
            @.projectForm.is_private = true

    refreshReferenceProject: (slug) ->
        @projectsService.getProjectBySlug(slug).then (project) =>
            @.referenceProject = project
            @.members = project.get('members')
            @.invitedMembers = @.members.map (it) -> return it.get('id')
            @.checkUsersLimit()

    toggleInvitedMember: (member) ->
        if @.invitedMembers.includes(member)
            @.invitedMembers = @.invitedMembers.filter (it) -> it != member
        else
            @.invitedMembers = @.invitedMembers.push(member)

        @.checkUsersLimit()

    checkUsersLimit: () ->
        @.limitMembersPrivateProject = @currentUserService.canAddMembersPrivateProject(@.invitedMembers.size)
        @.limitMembersPublicProject = @currentUserService.canAddMembersPublicProject(@.invitedMembers.size)

    submit: () ->
        projectId = @.referenceProject.get('id')
        data = @.projectForm

        @.formSubmitLoading = true
        @projectsService.duplicate(projectId, data).then (newProject) =>
            @.formSubmitLoading = false
            @location.path(@navUrls.resolve("project", {project: newProject.data.slug}))
            @currentUserService.loadProjects()

    canCreateProject: () ->
        if @.projectForm.is_private
            return @.canCreatePrivateProjects.valid
        else
            return @.canCreatePublicProjects.valid

    isDisabled: () ->
        return @.formSubmitLoading || !@.canCreateProject() || @.limitMembersPrivateProject || @.limitMembersPublicProject

    onCancelForm: () ->
        @location.path(@navUrls.resolve("create-project"))

angular.module("taigaProjects").controller("DuplicateProjectCtrl", DuplicateProjectController)
