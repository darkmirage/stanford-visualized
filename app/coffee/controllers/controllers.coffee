# This is the parent controller to all routes
appCtrl = ($scope, hotkeys, pageMeta, windowResize) ->
  $scope.page = pageMeta
  $scope.windowResize = windowResize
  $scope.toggleHelp = -> hotkeys.toggleCheatSheet()

  # Page loading screen
  # ==========================================================================
  $scope.page.loading = true
  $scope.$on '$routeChangeStart', ->
    $scope.page.loading = true

# Route: /faq
aboutCtrl = ($scope, d3Display, d3Helper) ->
  $scope.page.setTitle 'About'
  $scope.page.loading = false
  $scope.depts = d3Display.getSchoolColors()

  $scope.majorFilter = (keys) ->
    arr = (major for id, major of keys when major.cat != 'dept' and major.cat != 'aggr')
    arr.sort (a, b) -> a.name.localeCompare(b.name)
    return arr

angular.module 'stanfordViz'
  .controller 'AppCtrl', ['$scope', 'hotkeys', 'pageMeta', 'windowResize',
                          appCtrl]
  .controller 'AboutCtrl', ['$scope', 'd3Display', 'd3Helper', aboutCtrl]
