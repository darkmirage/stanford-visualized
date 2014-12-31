# This is the parent controller to all routes
appCtrl = ($scope, $location, hotkeys, pageMeta, windowResize) ->
  $scope.page = pageMeta
  $scope.windowResize = windowResize
  $scope.isActive = (route) -> route == $location.path()
  $scope.toggleHelp = -> hotkeys.toggleCheatSheet()

  # Page loading screen
  # ==========================================================================
  $scope.page.loading = true
  $scope.$on '$routeChangeStart', ->
    $scope.page.loading = true

# Route: /faq
aboutCtrl = ($scope) ->
  $scope.page.setTitle 'About'
  $scope.page.loading = false

angular.module 'stanfordViz'
  .controller 'AppCtrl', ['$scope', '$location', 'hotkeys', 'pageMeta',
                          'windowResize', appCtrl]
  .controller 'AboutCtrl', ['$scope', aboutCtrl]
