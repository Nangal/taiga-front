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
# File: github-import.controller.coffee
###

class GithubImportController
    constructor: (@githubImportService, @confirm, @translate, @importProjectService) ->
        @.step = 'autorization-github'
        @.project = null

        taiga.defineImmutableProperty @, 'projects', () => return @githubImportService.projects
        taiga.defineImmutableProperty @, 'members', () => return @githubImportService.projectUsers

    startProjectSelector: () ->
        @.step = 'project-select-github'
        @githubImportService.fetchProjects()

    onSelectProject: (project) ->
        @.step = 'project-form-github'
        @.project = project

    onSaveProjectDetails: (project) ->
        @.project = project
        @.step = 'project-members-github'

        @githubImportService.fetchUsers(@.project.get('id'))

    startImport: (users) ->
        loader = @confirm.loader(@translate.instant('PROJECT.IMPORT.IN_PROGRESS.TITLE'), @translate.instant('PROJECT.IMPORT.IN_PROGRESS.DESCRIPTION'), true)

        loader.start()

        promise = @githubImportService.importProject(
            @.project.get('name'),
            @.project.get('description'),
            @.project.get('id'),
            users,
            @.project.get('keepExternalReference'),
            @.project.get('is_private')
            @.project.get('project_type')
        )

        @importProjectService.importPromise(promise).then () => loader.stop()

    onSelectUsers: (users) ->
        @.startImport(users)
        return null

angular.module('taigaProjects').controller('GithubImportCtrl', [
    'tgGithubImportService',
    '$tgConfirm',
    '$translate',
    'tgImportProjectService',
    GithubImportController])
