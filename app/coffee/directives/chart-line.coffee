angular.module 'stanfordViz'
  .directive 'lineChart', ->
    return {
      restrict: 'A',
      link: initLine,
      templateUrl: 'views/_chart-line.html'
    }

initLine = (scope, element, attrs) ->
  watchOnce = scope.$watch 'line.loaded', (loaded) ->
    return if loaded is false
    watchOnce()
    dataLoaded scope, element, attrs

dataLoaded = (scope, element, attrs) ->
  cachedColumns = {}
  currentColumns = []
  currentIds = []

  c3RectClassMatcher = /(?:c3-event-rect-)([0-9]+)/
  scope.mode = 'lines'

  chart = c3.generate {
    bindto: '#c3-target',
    size: { height: 500 },
    transition: {
      duration: 500
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
        label: 'Students'
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
    chart.load {
      columns: currentColumns,
      unload: unload
    }

    if scope.mode is 'bars'
      chart.groups [currentIds]
    else
      chart.groups []

    bindRectsToChangeYear()
    showEvents()

  draw = ->
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

  scope.setBars = ->
    scope.mode = 'bars'
    loadChart()
    chart.transform 'bar'

  scope.setLines = ->
    scope.mode = 'lines'
    chart.transform 'line'
    loadChart()

  # Line chart specific hotkeys
  scope.bindKey {
    combo: 'b',
    description: 'Show stacked bar charts',
    callback: -> scope.setBars()
  }
  
  scope.bindKey {
    combo: 'l',
    description: 'Show line charts',
    callback: -> scope.setLines()
  }

  # Rendering callbacks
  watches = []

  watches.push scope.$watch 'line.data', ->
    scope.page.loaded += 1
    draw()

  watches.push scope.$watch 'displayColumn.name', (newValue, oldValue) ->
    return if newValue is oldValue
    # Clear caches when changing columns
    cachedColumns = {}
    currentColumns = []
    currentIds = []
    draw()

  watches.push scope.$watch 'events.show', (newValue, oldValue) ->
    return if newValue is oldValue
    showEvents()

  watches.push scope.$watch 'year.current', (newValue, oldValue) ->
    return if newValue is oldValue
    showEvents()

  element.on '$destroy', ->
    # Clear watches
    watch() for watch in watches
