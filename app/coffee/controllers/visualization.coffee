# This controller provides visualization data to the rendering directives
vizCtrl = ($scope, d3Config, d3Helper, d3Display) ->
  $scope.d3Display = d3Display
  $scope.minYear
  $scope.maxYear
  $scope.years = []
  $scope.majorData = []
  $scope.yearData = []

  $scope.year
  $scope.displayColumn = 'undergrad'
  $scope.idFilters = ['cs', 'history', 'humbio']
  $scope.catFilters = []
  $scope.schoolFilters = []

  d3Display.initColor($scope.idFilters)

  $scope.toggleId = (id) ->
    d3Helper.toggleId($scope.idFilters, id)
    d3Display.addColor(id)

  updateYearData = ->
    $scope.yearData = d3Helper.filterByColumn($scope.fullData, 'year', [$scope.year])

  updateFullMajorData = ->
    $scope.fullMajorData = d3Helper.filterByColumn($scope.fullData, 'cat', ['aggr', 'dept'], true)

  updateSidebarRange = ->
    $scope.sidebarMaxRange = d3.max $scope.fullMajorData, (d) -> d[$scope.displayColumn]

  updateSidebarData = ->
    data = $scope.yearData.slice 0
    data = d3Helper.filterByColumn(data, 'cat', ['aggr', 'dept'], true)
    data = d3Helper.filterByColumn(data, $scope.displayColumn, [0], true)
    data = d3Helper.sortByColumn(data, $scope.displayColumn, true)
    $scope.sidebarData = data

  $scope.$watch 'fullData', ->
    $scope.years = d3Helper.uniqueValues($scope.fullData, 'year')
    $scope.maxYear = d3.max $scope.years
    $scope.minYear = d3.min $scope.years
    $scope.year = $scope.maxYear

    updateYearData()
    updateFullMajorData()

  $scope.$watch 'fullMajorData', ->
    updateSidebarRange()

  $scope.$watch 'yearData', ->
    updateSidebarData()

  $scope.$watch 'year', ->
    updateYearData()

  $scope.$watch 'displayColumn', ->
    updateSidebarRange()
    updateSidebarData()

angular.module 'stanfordViz'
  .controller 'VizCtrl', ['$scope', 'd3Config', 'd3Helper', 'd3Display', vizCtrl]