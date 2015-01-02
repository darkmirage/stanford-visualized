# This is the parent controller to all routes
appCtrl = ($scope, $window, hotkeys, pageMeta, windowResize) ->
  $scope.page = pageMeta
  $scope.windowResize = windowResize
  $scope.toggleHelp = -> hotkeys.toggleCheatSheet()

  # Page loading screen
  # ==========================================================================
  $scope.page.loading = true
  $scope.$on '$routeChangeStart', ->
    $scope.page.loading = true

  # Only activate Bootstrap tooltip if not on mobile
  $window.activateTooltips = (parent) ->
    unless /(iPad|iPhone|iPod)/g.test(navigator.userAgent) or window.innerWidth < 992
      $(parent).find('[data-toggle="tooltip"]').tooltip()

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
  .controller 'AppCtrl', ['$scope', '$window', 'hotkeys', 'pageMeta', 'windowResize',
                          appCtrl]
  .controller 'AboutCtrl', ['$scope', 'd3Display', 'd3Helper', aboutCtrl]
