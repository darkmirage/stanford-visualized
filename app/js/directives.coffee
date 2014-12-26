app = angular.module 'stanfordViz'

app.directive 'pageTitle', ->
  return { template: '{{ page.fullTitle() }}' }

app.directive 'navLink', ->
  return {
    restrict: 'E',
    replace: true,
    scope: {
      linkTarget: '@target',
      linkText: '@text'
    },
    link: (scope, element, attrs) ->
      parentScope = element.parent().scope()
      scope.isLinkActive = -> parentScope.isActive(scope.linkTarget)

    template: '<li ng-class="{active:isLinkActive()}">
                 <a ng-href="#{{linkTarget}}">{{linkText}}</a>
               </li>'
  }