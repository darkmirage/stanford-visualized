angular.module 'stanfordViz'
  .directive 'lineChart', ->
    return {
      restrict: 'A',
      link: initLine
    }

initLine = (scope, element, attrs) ->
  cachedColumns = {}
  currentColumns = []
  currentIds = []
  isGrouped = false

  years = null

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
        label: 'Students',
        tick: { values: (i * 250 for i in [0..100]) }
      }
    }
  }

  updateYears =->
    years = scope.years.slice 0
    years.unshift 'year'

  loadChart = (unload=[]) ->
    chart.load {
      columns: currentColumns,
      unload: unload
    }

    chart.groups [currentIds] if isGrouped

  draw = ->
    return if years is null
    data = scope.selectedMajorData
    column = scope.displayColumn
    ids = scope.idFilters

    yearStart = scope.minYear
    numYears = scope.years.length

    # Figure out which IDs are gone and should be removed
    removeIds = (id for id in currentIds when id not in ids)

    # Update current ID list
    currentIds = ids.slice 0

    # Find the ids that are not yet cached
    newIds = (id for id in ids when id not in cachedColumns)

    # Generate zero columns for all years with an extra column
    cachedColumns[id] = (0 for [0..numYears]) for id in newIds

    # Fill in cache columns using actual data
    cachedColumns[d.id][d.year - yearStart + 1] = d[column] for d in data

    # Use the extra column for the column label
    cachedColumns[id][0] = id for id in newIds

    # Retrieve all the columns from the cache
    columns = (cachedColumns[id] for id in ids)

    # Add x-axis data
    columns.push years

    currentColumns = columns

    loadChart removeIds

  setBars = ->
    isGrouped = true
    loadChart()
    chart.transform 'bar'

  setLines = ->
    isGrouped = false
    chart.transform 'line'
    loadChart()


  # Rendering callbacks
  watches = []

  watcher = scope.$watch 'years', ->
    updateYears()
    watcher()

  watches.push scope.$watch 'selectedMajorData', ->
    draw()

  watches.push scope.$watch 'displayColumn', ->
    # Clear caches when changing columns
    cachedColumns = {}
    currentColumns = []
    currentIds = []
    draw()

  element.on '$destroy', ->
    # Clear watches
    watch() for watch in watches
