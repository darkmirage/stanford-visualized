angular.module 'stanfordViz'
  .directive 'singleChart', ->
    return {
      restrict: 'A',
      link: initSingle,
      templateUrl: 'views/_chart-single.html'
    }

initSingle = (scope, element, attrs) ->
  watchOnce = scope.$watch 'charts.dataLoaded', (loaded) ->
    return if loaded is false
    watchOnce()
    dataLoaded scope, element, attrs

dataLoaded = (scope, element, attrs) ->
  c3RectClassMatcher = /(?:c3-event-rect-)([0-9]+)/

  element.hide()

  scope.description = ''
  scope.majorName = ''

  chart = c3.generate {
    bindto: '#c3-target-single',
    size: { height: 500 },
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
    }
  }

  bindRectsToChangeYear = ->
    $('.c3-event-rect', element).on 'click', ->
      match = $(this).attr('class').match c3RectClassMatcher
      if match != null
        year = parseInt(match[1]) + scope.year.min
        scope.$apply ->
          scope.changeYear year

  updateDescription = (prefix=scope.displayColumn.prefix) ->
    id = scope.filters.selected
    description = ''
    switch prefix
      when 'undergrad' then description = 'undergraduate'
      when 'graduate' then description = 'graduate'
      when 'total' then description = 'graduate and undergraduate'
    scope.description = description
    scope.majorName = scope.keys[id].name

  updateYear = ->
    chart.xgrids [{
      value: scope.year.current,
      class: 'c3-chart-current'
    }]

  draw = (id=scope.filters.selected) ->
    return if not scope.charts.singleMode

    id = scope.filters.selected

    data = scope.single.data.slice 0

    names = {}
    names['_men'] = 'Men in ' + scope.keys[id].name
    names['_women'] = 'Women in ' + scope.keys[id].name
    chart.data.names names

    chart.load {
      columns: data
    }

    if scope.charts.displayMode is 'bars'
      chart.groups [['_men', '_women']]
    else
      chart.groups []

    updateYear()
    bindRectsToChangeYear()


  # Rendering callbacks
  watches = []

  watches.push scope.$watch 'single.data', ->
    updateDescription()
    draw()

  watches.push scope.$watch 'displayColumn.prefix', (newValue, oldValue) ->
    return if newValue is oldValue
    updateDescription(newValue)
    draw()

  watches.push scope.$watch 'year.current', (newValue, oldValue) ->
    return if newValue is oldValue
    updateYear()

  watches.push scope.$watch 'charts.singleMode', (newValue, oldValue) ->
    return if newValue is oldValue
    if newValue
      element.hide().fadeIn(1000)
    else
      element.hide()
    draw()

  watches.push scope.$watch 'charts.displayMode', (newValue, oldValue) ->
    return if newValue is oldValue
    if scope.charts.displayMode == 'bars'
      chart.transform 'bar'
      draw()
    else if scope.charts.displayMode == 'lines'
      chart.transform 'line'
      draw()

  element.on '$destroy', ->
    # Clear watches
    watch() for watch in watches
