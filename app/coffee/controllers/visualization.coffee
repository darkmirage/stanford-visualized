# This controller provides visualization data to the rendering directives
vizCtrl = ($scope, hotkeys, d3Config, d3Helper, d3Display) ->
  $scope.page.setTitle 'Home'
  watchers = []

  $scope.d3Display = d3Display
  $scope.bindKey = (config) ->
    hotkeys.bindTo($scope).add(config)

  $scope.years = []
  $scope.year = {
    current: 2000,
    min: 2000,
    max: 2000
  }

  $scope.displayColumn = {
    gender: 'all',
    prefix: 'undergrad',
    name: 'undergrad'
  }

  updateColumnName = ->
    column = $scope.displayColumn
    if column.gender is 'all'
      column.name = column.prefix
    else
      column.name = "#{column.prefix}_#{column.gender}"

  $scope.updatePrefix = (prefix) ->
    $scope.displayColumn.prefix = prefix
    updateColumnName()

  $scope.updateGender = (gender) ->
    $scope.displayColumn.gender = gender
    updateColumnName()

  $scope.data = {
    fullMajor: [],
    selectedMajor: [],
    year: [],
    total: []
  }

  $scope.filters = {
    id: ['cs', 'psych', 'econ', 'history', 'humbio'],
    cat: [],
    school: []
  }

  $scope.sidebar = {
    data: [],
    maxRange: 0
  }

  d3Display.initColor($scope.filters.id)

  d3Filter = d3Helper.filterByColumn
  d3Sort = d3Helper.sortByColumn

  $scope.toggleId = (id) ->
    d3Helper.toggleId($scope.filters.id, id)
    d3Display.addColor(id)

  updateYearData = ->
    $scope.data.year = d3Filter($scope.fullData, 'year', [$scope.year.current])

  updateFullMajorData = ->
    $scope.data.fullMajor = d3Filter($scope.fullData, 'cat', ['aggr', 'dept'], true)

  updateSelectedMajorData = ->
    $scope.data.selectedMajor = d3Filter($scope.data.fullMajor, 'id', $scope.filters.id)

  updateTotalData = ->
    $scope.data.total = d3Filter($scope.fullData, 'id', ['total'])

  updateSidebarRange = ->
    $scope.sidebar.maxRange = d3.max $scope.data.fullMajor, (d) -> d[$scope.displayColumn.name]

  updateSidebarData = ->
    data = d3Filter($scope.data.year, 'cat', ['aggr', 'dept'], true)
    data = d3Filter(data, $scope.displayColumn.name, [0], true)
    d3Sort(data, $scope.displayColumn.name, true)
    $scope.sidebar.data = data

  watchers.push $scope.$watch 'fullData', ->
    $scope.years = d3Helper.uniqueValues($scope.fullData, 'year')
    $scope.year.max = d3.max $scope.years
    $scope.year.min = d3.min $scope.years
    $scope.year.current = $scope.year.max

    updateYearData()
    updateFullMajorData()
    updateTotalData()
    $scope.page.loading = false

  watchers.push $scope.$watch 'data.fullMajor', ->
    updateSidebarRange()
    updateSelectedMajorData()

  watchers.push $scope.$watch 'data.year', ->
    updateSidebarData()

  watchers.push $scope.$watch 'year.current', ->
    updateYearData()

  watchers.push $scope.$watch 'displayColumn.name', ->
    updateSidebarRange()
    updateSidebarData()

  watchers.push $scope.$watchCollection 'filters.id', ->
    updateSelectedMajorData()

  $scope.$on '$destroy', ->
    watcher() for watcher in watchers
    $scope.page.loading = true

  changeYear = (year) ->
    return if year < $scope.year.min or year > $scope.year.max
    $scope.year.current = year

  increaseYear = -> changeYear($scope.year.current + 1)
  decreaseYear = -> changeYear($scope.year.current - 1)

  hotkeys.bindTo($scope)
    .add {
      combo: 'left',
      description: 'Go back one year',
      callback: decreaseYear
    }
    .add {
      combo: 'right',
      description: 'Go forward one year',
      callback: increaseYear
    }

angular.module 'stanfordViz'
  .controller 'VizCtrl', ['$scope', 'hotkeys', 'd3Config', 'd3Helper', 'd3Display', vizCtrl]