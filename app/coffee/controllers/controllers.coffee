# This is the parent controller to all routes
appCtrl = ($scope, $location, hotkeys, pageMeta, windowResize, events) ->
  $scope.page = pageMeta
  $scope.windowResize = windowResize
  $scope.isActive = (route) -> route == $location.path()
  $scope.toggleHelp = -> hotkeys.toggleCheatSheet()

  # Temporary hacky hack
  $scope.events = events
  $scope.toggleEvents = -> $scope.events.show = not $scope.events.show

# Route: /
homeCtrl = ($scope) ->
  $scope.page.setTitle ''

# Route: /contact
contactCtrl = ($scope) ->
  $scope.page.setTitle 'Contact'

# Route: /faq
faqCtrl = ($scope) ->
  $scope.page.setTitle 'FAQs'

angular.module 'stanfordViz'
  .controller 'AppCtrl', ['$scope', '$location', 'hotkeys', 'pageMeta',
                          'windowResize', 'events', appCtrl]
  .controller 'HomeCtrl', ['$scope', homeCtrl]
  .controller 'ContactCtrl', ['$scope', contactCtrl]
  .controller 'FaqCtrl', ['$scope', faqCtrl]
