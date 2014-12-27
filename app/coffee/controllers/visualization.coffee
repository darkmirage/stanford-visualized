# This controller provides visualization data to the rendering directives
vizCtrl = ($scope, d3Config, d3Helper, d3Display) ->
  $scope.d3Display = d3Display
  $scope.minYear
  $scope.maxYear
  $scope.years = []
  $scope.majorData = []
  $scope.yearData = []
  $scope.totalData = []
  $scope.selectedMajorData = []

  $scope.year
  $scope.displayColumn = 'undergrad'
  $scope.idFilters = ['cs', 'psych', 'econ', 'history', 'humbio']
  $scope.catFilters = []
  $scope.schoolFilters = []

  d3Display.initColor($scope.idFilters)

  d3Filter = d3Helper.filterByColumn
  d3Sort = d3Helper.sortByColumn

  $scope.toggleId = (id) ->
    d3Helper.toggleId($scope.idFilters, id)
    d3Display.addColor(id)

  updateYearData = ->
    $scope.yearData = d3Filter($scope.fullData, 'year', [$scope.year])

  updateFullMajorData = ->
    $scope.fullMajorData = d3Filter($scope.fullData, 'cat', ['aggr', 'dept'], true)

  updateSelectedMajorData = ->
    $scope.selectedMajorData = d3Filter($scope.fullMajorData, 'id', $scope.idFilters)

  updateTotalData = ->
    $scope.totalData = d3Filter($scope.fullData, 'id', ['total'])

  updateSidebarRange = ->
    $scope.sidebarMaxRange = d3.max $scope.fullMajorData, (d) -> d[$scope.displayColumn]

  updateSidebarData = ->
    data = d3Filter($scope.yearData, 'cat', ['aggr', 'dept'], true)
    data = d3Filter(data, $scope.displayColumn, [0], true)
    d3Sort(data, $scope.displayColumn, true)
    $scope.sidebarData = data

  $scope.$watch 'fullData', ->
    $scope.years = d3Helper.uniqueValues($scope.fullData, 'year')
    $scope.maxYear = d3.max $scope.years
    $scope.minYear = d3.min $scope.years
    $scope.year = $scope.maxYear

    updateYearData()
    updateFullMajorData()
    updateTotalData()

  $scope.$watch 'fullMajorData', ->
    updateSidebarRange()
    updateSelectedMajorData()

  $scope.$watch 'yearData', ->
    updateSidebarData()

  $scope.$watch 'year', ->
    updateYearData()

  $scope.$watch 'displayColumn', ->
    updateSidebarRange()
    updateSidebarData()

  $scope.$watchCollection 'idFilters', ->
    updateSelectedMajorData()

angular.module 'stanfordViz'
  .controller 'VizCtrl', ['$scope', 'd3Config', 'd3Helper', 'd3Display', vizCtrl]