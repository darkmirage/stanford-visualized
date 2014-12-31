app = angular.module 'stanfordViz'

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

    # Replace with <li ng-class="{active:isLinkActive()}"> for highlighting
    template: '<li>
                 <a ng-href="#{{linkTarget}}">{{linkText}}</a>
               </li>'
  }