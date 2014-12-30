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

  # Page loading indicator
  # ==========================================================================
  $scope.page.loaded = 0
  watchers.push $scope.$watch 'page.loaded', ->
    if $scope.page.loaded >= 2
      $scope.page.loading = false

  # Chart states
  # ==========================================================================
  $scope.sidebar = {
    data: []
    maxRange: 0
  }

  $scope.line = {
    data: []
  }

  $scope.single = {
    data : []
  }

  $scope.charts = {
    dataLoaded: false
    singleMode: false
    displayMode: 'lines'
  }

  $scope.toggleSingle = ->
    $scope.charts.singleMode = not $scope.charts.singleMode

  $scope.toggleSingleOn = ->
    $scope.charts.singleMode = on

  $scope.toggleSingleOff = ->
    $scope.charts.singleMode = off

  $scope.setBars = ->
    $scope.charts.displayMode = 'bars'

  $scope.setLines = ->
    $scope.charts.displayMode = 'lines'

  # Data filters
  # ==========================================================================
  $scope.filters = {
    id: d3Config.defaultMajors.slice 0
    selected: d3Config.defaultMajors[0]
    cat: [],
    school: []
  }

  d3Display.initColor($scope.filters, $scope.charts)

  $scope.toggleId = (id) ->
    unless $scope.charts.singleMode
      ids = $scope.filters.id
      index = ids.indexOf(id)
      if index == -1
        ids.push(id)
        d3Display.addColor(id)
      else
        ids.splice(index, 1)

    $scope.filters.selected = id

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
      combo: 'b',
      description: 'Show stacked bar charts',
      callback: -> $scope.setBars()
    }
  
    .add {
      combo: 'l',
      description: 'Show line charts',
      callback: -> $scope.setLines()
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
    genderDisplay: 'Total',
    prefix: 'undergrad',
    name: 'undergrad',
    description: 'Number of undergraduate students'
    showPercentages: false
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

    description = d3Config.dataColumns[name]
    column.description = description
    column.name = name


  $scope.togglePercentages = ->
    $scope.displayColumn.showPercentages =
      not $scope.displayColumn.showPercentages
    updateColumnName()

  $scope.updatePrefix = (prefix) ->
    $scope.displayColumn.prefix = prefix
    updateColumnName()

  $scope.updateGender = (gender) ->
    name = null
    switch gender
      when 'men' then name = 'male'
      when 'women' then name = 'female'
      when 'all' then name = 'total'
      when 'ratio' then name = 'ratio'

    $scope.displayColumn.genderDisplay = name
    $scope.displayColumn.gender = gender

    updateColumnName()
    $scope.toggleSingleOff()

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

  updateSingleData = ->
    data = $scope.indices.majorToItems[$scope.filters.selected]
    numYears = $scope.data.years.length
    yearStart = $scope.year.min
    id = $scope.filters.selected

    prefix = $scope.displayColumn.prefix
    columns = []
    men = (0 for [0..numYears])
    women = (0 for [0..numYears])

    for d in data
      men[d.year - yearStart + 1] = d[prefix + '_men']
      women[d.year - yearStart + 1] = d[prefix + '_women']

    men.unshift '_men'
    women.unshift '_women'

    years = $scope.data.years.slice 0
    years.unshift 'year'

    columns = [men, women, years]

    $scope.single.data = columns

  initCharts = ->
    $scope.year.max = d3.max $scope.data.years
    $scope.year.min = d3.min $scope.data.years
    $scope.changeYear($scope.year.max)

    updateLineData()
    updateSidebarData()
    updateSingleData()

    $scope.charts.dataLoaded = true

    watchers.push $scope.$watchCollection 'filters.id', ->
      updateLineData()

    watchers.push $scope.$watchCollection 'filters.selected', ->
      updateSingleData()

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
