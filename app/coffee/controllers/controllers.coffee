# This is the parent controller to all routes
appCtrl = ($scope, $location, hotkeys, pageMeta, windowResize, d3Config, d3Data, d3Helper) ->
  $scope.page = pageMeta
  $scope.windowResize = windowResize
  $scope.isActive = (route) ->
    route == $location.path()

  $scope.toggleHelp = ->
    hotkeys.toggleCheatSheet()

  # Temporary hacky hack
  $scope.events = {
    show: true,
    items: {
      '1965': ['US bombs Vietnam', ['history', 'polisci']]
      '1973': ['Oil shock', ['chemeng']]
      '1991': ['End of Soviet Union', ['history', 'polisci']]
      '1984': ['Reagan re-elected', ['econ', 'polisci']]
      '1999': ['MS&E department formed', ['ms&e', 'ie', 'opsres']]
      '2000': ['Dot-com burst', ['cs', 'econ']]
      '2001': ['9/11 terrorist attacks']
      '2003': ['Invasion of Iraq', ['polisci']]
      '2013': ['CS revamps curriculum', ['cs']]
    }
  }

  $scope.toggleEvents = ->
    $scope.events.show = not $scope.events.show

  $scope.fullData = []
  d3Data.get(d3Config.path).then (data) ->
    $scope.fullData = data

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
                          'windowResize', 'd3Config', 'd3Data', 'd3Helper',
                          appCtrl]
  .controller 'HomeCtrl', ['$scope', homeCtrl]
  .controller 'ContactCtrl', ['$scope', contactCtrl]
  .controller 'FaqCtrl', ['$scope', faqCtrl]
