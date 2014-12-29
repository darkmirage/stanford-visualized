# This controller provides visualization data to the rendering directives
vizCtrl = ($scope, hotkeys, events, d3Config, d3Helper, d3Display) ->
  $scope.page.setTitle ''
  watchers = []

  $scope.d3Display = d3Display
  d3Filter = d3Helper.filterByColumn
  d3Sort = d3Helper.sortByColumn

  # Temporary hacky hack for displaying events
  # ==========================================================================
  $scope.events = events
  $scope.events.show = true
  $scope.toggleEvents = -> $scope.events.show = not $scope.events.show

  # Misc helpers for directives
  # ==========================================================================
  $scope.bindKey = (config) ->
    hotkeys.bindTo($scope).add(config)

  # Page loading indicator
  # ==========================================================================
  $scope.page.loaded = 0
  watchers.push $scope.$watch 'page.loaded', ->
    if $scope.page.loaded >= 2
      $scope.page.loading = false

  # Data filters
  # ==========================================================================
  $scope.filters = {
    id: d3Config.defaultMajors.slice 0
    cat: [],
    school: []
  }

  d3Display.initColor($scope.filters.id)

  $scope.toggleId = (id) ->
    d3Helper.toggleId($scope.filters.id, id)
    d3Display.addColor(id)

  $scope.clearIds = ->
    $scope.filters.id.length = 0

  # Current year
  # ==========================================================================

  $scope.year = {
    current: 2000,
    min: 2000,
    max: 2000,
    event: ''
  }

  $scope.changeYear = (year) ->
    return if year < $scope.year.min or year > $scope.year.max
    $scope.year.current = year

    item = $scope.events.items[year.toString()]
    if item is undefined
      $scope.year.event = ''
    else
      $scope.year.event = item[0]

  $scope.increaseYear = -> $scope.changeYear($scope.year.current + 1)
  $scope.decreaseYear = -> $scope.changeYear($scope.year.current - 1)

  hotkeys.bindTo($scope)
    .add {
      combo: 'q',
      description: 'Go back one year',
      callback: $scope.decreaseYear
    }
    .add {
      combo: 'w',
      description: 'Go forward one year',
      callback: $scope.increaseYear
    }
    .add {
      combo: 'left',
      callback: $scope.decreaseYear
    }
    .add {
      combo: 'right',
      callback: $scope.increaseYear
    }

  # Column selection
  # ==========================================================================
  $scope.displayColumn = {
    gender: 'all',
    prefix: 'undergrad',
    name: 'undergrad_percentage_of_declared',
    showPercentages: true
    percentages: ->
      self = $scope.displayColumn
      return false if self.gender == 'ratio'
      self.showPercentages
  }

  updateColumnName = ->
    column = $scope.displayColumn
    name = column.prefix
    if column.gender != 'all'
      name = name + '_' + column.gender

    if column.showPercentages and column.gender != 'ratio'
      name = name + '_percentage_of_declared'
    column.name = name


  $scope.togglePercentages = ->
    $scope.displayColumn.showPercentages =
      not $scope.displayColumn.showPercentages
    updateColumnName()

  $scope.updatePrefix = (prefix) ->
    $scope.displayColumn.prefix = prefix
    updateColumnName()

  $scope.updateGender = (gender) ->
    $scope.displayColumn.gender = gender
    updateColumnName()

  # Chart states
  # ==========================================================================
  $scope.sidebar = {
    data: []
    maxRange: 0
  }

  $scope.line = {
    data: []
  }

  $scope.charts = {
    dataLoaded: false
  }

  # Data processing
  # ==========================================================================
  updateSidebarData = ->
    $scope.sidebar.maxRange =
      $scope.indices.columnToMaxRange[$scope.displayColumn.name]

    data = $scope.indices.yearToItems[$scope.year.current]
    data = data.slice 0
    data = d3Filter(data, $scope.displayColumn.name, [0], true)
    d3Sort(data, $scope.displayColumn.name, true)
    $scope.sidebar.data = data

  updateLineData = ->
    data = ($scope.indices.majorToItems[id] for id in $scope.filters.id)
    $scope.line.data = data

  initCharts = ->
    $scope.year.max = d3.max $scope.data.years
    $scope.year.min = d3.min $scope.data.years
    $scope.changeYear($scope.year.max)

    updateLineData()
    updateSidebarData()

    $scope.charts.dataLoaded = true

    watchers.push $scope.$watchCollection 'filters.id', ->
      updateLineData()

    watchers.push $scope.$watch 'year.current', (newValue, oldValue) ->
      return if newValue is oldValue
      updateSidebarData()

    watchers.push $scope.$watch 'displayColumn.name', (newValue, oldValue) ->
      return if newValue is oldValue
      updateSidebarData()

  watchOnce = $scope.$watch 'data.updated', (newValue, oldValue) ->
    return if newValue is 0
    watchOnce()
    initCharts()

  $scope.$on '$destroy', ->
    watcher() for watcher in watchers

angular.module 'stanfordViz'
  .controller 'VizCtrl', ['$scope', 'hotkeys', 'events', 'd3Config',
                          'd3Helper', 'd3Display', vizCtrl]