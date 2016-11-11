module = angular.module("taigaProject")

createProjectRestrictionsDirective = () ->
    return {
        scope: {
            canCreatePrivateProjects: '=',
            canCreatePrivateProjects: '='
        },
        templateUrl: "projects/create/create-project-restrictions/create-project-restrictions.html"
    }

module.directive('tgCreateProjectRestrictions', [createProjectRestrictionsDirective])
