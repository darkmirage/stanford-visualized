# This is the parent controller to all routes
appCtrl = ($scope, $location, hotkeys, pageMeta, windowResize, d3Config, d3Data, d3Helper) ->
  $scope.page = pageMeta
  $scope.windowResize = windowResize
  $scope.isActive = (route) ->
    route == $location.path()

  $scope.toggleHelp = ->
    hotkeys.toggleCheatSheet()

  $scope.fullData = []
  d3Data.get(d3Config.path).then (data) ->
    $scope.fullData = data

# Route: /
homeCtrl = ($scope) ->
  $scope.page.setTitle 'Home'

# Route: /contact
contactCtrl = ($scope) ->
  $scope.page.setTitle 'Contact'

# Route: /faq
faqCtrl = ($scope) ->
  $scope.page.setTitle 'FAQs'

angular.module 'stanfordViz'
  .controller 'AppCtrl', ['$scope', '$location', 'hotkeys', 'pageMeta',
                          'windowResize', 'd3Config', 'd3Data', 'd3Helper',
                          appCtrl]
  .controller 'HomeCtrl', ['$scope', homeCtrl]
  .controller 'ContactCtrl', ['$scope', contactCtrl]
  .controller 'FaqCtrl', ['$scope', faqCtrl]
