angular.module 'stanfordViz'
  .directive 'lineChart', ->
    return {
      restrict: 'A',
      link: initLine,
      templateUrl: 'views/_chart-line.html'
    }

initLine = (scope, element, attrs) ->
  watchOnce = scope.$watch 'charts.dataLoaded', (loaded) ->
    return if loaded is false
    watchOnce()
    dataLoaded scope, element, attrs

dataLoaded = (scope, element, attrs) ->
  cachedColumns = {}
  currentColumns = []
  currentIds = []

  c3RectClassMatcher = /(?:c3-event-rect-)([0-9]+)/
  bindTarget = $('#c3-target-line')

  chart = c3.generate {
    bindto: '#c3-target-line',
    transition: {
      duration: 500
    },
    padding: {
      right: 30
    },
    data: {
      x: 'year',
      columns: [['year']],
      color: (color, d) ->
        if d.id
          scope.d3Display.getColor(d)
        else
          scope.d3Display.getColorById(d)
    },
    axis: {
      x: {
        label: 'Year',
        tick: { values: (1963 + i * 10 for i in [0..5]) }
      },
      y: {
        label: 'Students',
        min: 0,
        padding: { bottom: 0 }
      }
    },
    tooltip: {
      format: {
        value: (value, ratio, id, index) ->
          show = scope.displayColumn.percentages()
          scope.d3Display.formatCount value, show, true
      }
    },
    legend: {
      item: {
        onclick: (id) ->
          scope.$apply ->
            scope.toggleId(id)
      }
    }
  }

  matchIds = (ids) ->
    return false if ids is undefined
    for id in ids
      return true if id in currentIds
    return false

  showEvents = ->
    # Adds marker for current year
    events = [{
      value: scope.year.current,
      class: 'c3-chart-current'
    }]

    # Adds event markers for selected IDs
    if scope.events.show
      for own key, value of scope.events.items
        if matchIds value[1]
          events.push {
            value: key,
            text: value[0],
          }

    chart.xgrids events

  bindRectsToChangeYear = ->
    $('.c3-event-rect', element).on 'click', ->
      match = $(this).attr('class').match c3RectClassMatcher
      if match != null
        year = parseInt(match[1]) + scope.year.min
        scope.$apply ->
          scope.changeYear year

  loadChart = (unload=[]) ->
    names = {}
    names[id] = scope.keys[id].name for id in currentIds

    chart.data.names names

    chart.load {
      columns: currentColumns,
      unload: unload
    }

    if scope.charts.displayMode is 'bars'
      chart.groups [currentIds]
    else
      chart.groups []

    bindRectsToChangeYear()
    showEvents()

  draw = ->
    return if scope.charts.singleMode
    data = scope.line.data
    column = scope.displayColumn.name
    ids = scope.filters.id

    yearStart = scope.year.min
    numYears = scope.data.years.length

    # Figure out which IDs are gone and should be removed and which are new
    removeIds = (id for id in currentIds when id not in ids)
    newIds = (id for id in ids when id not in currentIds)

    return if removeIds.length is 0 and newIds.length is 0

    # Update current ID list
    currentIds = ids.slice 0

    # Find the ids that are not yet cached
    uncachedIds = (id for id in ids when id not in cachedColumns)

    if uncachedIds.length > 0

      # Generate zero columns for all years with an extra column
      cachedColumns[id] = (0 for [0..numYears]) for id in uncachedIds

      # Fill in cache columns using actual data
      for majorData in data
        for d in majorData
          cachedColumns[d.id][d.year - yearStart + 1] = d[column] 

      # Use the extra column for the column label
      cachedColumns[id][0] = id for id in uncachedIds

    # Retrieve all the columns from the cache
    columns = (cachedColumns[id] for id in ids)

    # Add x-axis data
    years = scope.data.years.slice 0
    years.unshift 'year'
    columns.push years

    currentColumns = columns

    loadChart removeIds

  # Rendering callbacks
  scope.$watch 'line.data', ->
    scope.page.loaded += 1
    draw()

  scope.$watch 'displayColumn.name', (newValue, oldValue) ->
    return if newValue is oldValue
    # Clear caches when changing columns
    cachedColumns = {}
    currentColumns = []
    currentIds = []
    draw()

  scope.$watch 'events.show', (newValue, oldValue) ->
    return if newValue is oldValue
    showEvents()

  scope.$watch 'year.current', (newValue, oldValue) ->
    return if newValue is oldValue
    showEvents()

  scope.$watch 'charts.singleMode', (newValue, oldValue) ->
    return if newValue is oldValue
    if newValue
      element.hide()
    else
      element.hide().fadeIn(1000)
    cachedColumns = {}
    currentColumns = []
    currentIds = []
    draw()

  scope.$watch 'charts.displayMode', (newValue, oldValue) ->
    return if newValue is oldValue
    if scope.charts.displayMode == 'bars'
      chart.transform 'bar'
      loadChart()
    else if scope.charts.displayMode == 'lines'
      chart.transform 'line'
      loadChart()

  element.on '$destroy', ->
    # Clear watches
    watch() for watch in watches
