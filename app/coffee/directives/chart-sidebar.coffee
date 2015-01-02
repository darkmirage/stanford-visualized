angular.module 'stanfordViz'
  .directive 'sidebarChart', ->
    return {
      restrict: 'A',
      link: initSidebar,
      templateUrl: 'views/_chart-sidebar.html'
    }

initSidebar = (scope, element, attrs) ->
  watchOnce = scope.$watch 'charts.dataLoaded', (loaded) ->
    return if loaded is false
    watchOnce()
    dataLoaded scope, element, attrs

dataLoaded = (scope, element, attrs) ->
  groupTransitionDuration = 300
  barHeight = 20
  barSpacing = 2
  textYOffset = 17 # not sure what this should be based off
  textXOffset = 5
  textWidth = 100
  countWidth = 30
  barSlot = barHeight + barSpacing * 2

  scale = d3.scale.linear()

  container = d3.select(element[0])
  container.selectAll('svg').remove()
  svg = container.append('svg')
  svgJ = $('svg', element)

  getColorById = scope.d3Display.getColorById

  getBarY = (d, i) -> barSpacing + i * barSlot

  getLabelY = (d, i) ->
    barY = getBarY d, i
    barY + textYOffset

  draw = (duration=400) ->
    data = scope.sidebar.data
    singleMode = scope.charts.singleMode

    menColor = getColorById '_men'
    womenColor = getColorById '_women'

    column = if singleMode
        scope.displayColumn.prefix
      else scope.displayColumn.name

    columnInner = scope.displayColumn.prefix + '_women'

    maxRange = scope.indices.columnToMaxRange[column]
    showPercentages = scope.displayColumn.percentages() and not singleMode

    barStart = svgJ.width() + barSpacing - textWidth

    # Update height of svg according to number of elements present
    svgJ.height((data.length + 1) * barSlot)

    scale.domain [0, maxRange]
    scale.range [0, svgJ.width() - textWidth - barSpacing * 2 - countWidth]

    groups = svg.selectAll('svg').data data, (d) -> d.id

    groupsEnter = groups.enter().append 'svg'
      .attr 'class', 'bar-group'
      .attr 'data-action', 'id-selector'
      .attr 'data-id', (d) -> d.id
      .attr 'data-value', (d) -> d[column]
      .attr 'y', getBarY

    groups.transition()
      .attr 'y', getBarY
      .attr 'class', (d) ->
        if singleMode and d.id is scope.filters.selected
          'bar-group bar-group-selected'
        else
          'bar-group'
      .duration groupTransitionDuration

    groups.exit().remove()

    # Draw background
    groupsEnter.append 'rect'
      .attr 'class', 'bar-background'
      .attr 'width', svgJ.width()
      .attr 'height', barSlot
      .attr 'fill', '#ffffff'
      .attr 'fill-opacity', 0
      .attr 'title', (d) -> scope.keys[d.id].name
      .attr 'data-toggle', 'tooltip'
      .attr 'data-placement', 'bottom'
      .attr 'data-container', 'body'

    backgrounds = groups.select '.bar-background'

    backgrounds.transition()
      .attr 'width', svgJ.width()
      .duration duration
      .delay groupTransitionDuration


    # Draw bars
    groupsEnter.append 'rect'
      .attr 'class', 'bar'
      .attr 'x', (d) -> barStart
      .attr 'y', barSpacing
      .attr 'width', 0
      .attr 'height', barHeight
      .attr 'fill-opacity', 0
      .attr 'fill', (d) ->
        if singleMode then menColor else getColorById d.id

    bars = groups.select '.bar'

    bars.transition()
      .attr 'x', (d) -> barStart - scale d[column]
      .attr 'width', (d) -> scale d[column]
      .attr 'fill-opacity', (d) -> scope.d3Display.getOpacity d
      .attr 'fill', (d) ->
        if singleMode then menColor else getColorById d.id
      .duration duration
      .delay groupTransitionDuration


    # Draw inner bars for single mode
    groupsEnter.append 'rect'
      .attr 'class', 'bar-inner'
      .attr 'x', (d) -> barStart
      .attr 'y', barSpacing
      .attr 'width', 0
      .attr 'height', barHeight
      .attr 'fill-opacity', 0
      .attr 'fill', (d) ->
        if singleMode then womenColor else getColorById d.id

    innerBars = groups.select '.bar-inner'

    if singleMode
      innerBars.transition()
        .attr 'x', (d) -> barStart - scale d[columnInner]
        .attr 'width', (d) -> scale d[columnInner]
        .attr 'fill-opacity', (d) -> scope.d3Display.getOpacity d
        .attr 'fill', (d) -> womenColor
        .duration duration
        .delay groupTransitionDuration
    else
      innerBars.transition()
        .attr 'x', barStart
        .attr 'width', 0
        .attr 'fill-opacity', 0
        .duration duration
        .delay groupTransitionDuration


    # Draw name labels
    groupsEnter.append 'text'
      .text (d) -> d.id
      .attr 'class', 'bar-label'
      .attr 'y', textYOffset
      .attr 'x', barStart + textXOffset
      .attr 'fill', (d) -> getColorById d.id
      .attr 'fill-opacity', 0

    labels = groups.select '.bar-label'

    labels.transition()
      .attr 'fill', (d) -> getColorById d.id
      .attr 'fill-opacity', 1.0
      .attr 'x', barStart + textXOffset
      .duration duration
      .delay groupTransitionDuration


    # Draw count labels
    groupsEnter.append 'text'
      .text (d) -> scope.d3Display.formatCount d[column], showPercentages
      .attr 'class', 'bar-count'
      .attr 'text-anchor', 'end'
      .attr 'y', textYOffset - 2
      .attr 'x', (d) -> barStart - scale(d[column]) - textXOffset
      .attr 'fill', (d) -> getColorById d.id
      .attr 'fill-opacity', 0

    counts = groups.select '.bar-count'

    counts.transition()
      .text (d) -> scope.d3Display.formatCount d[column], showPercentages
      .attr 'x', (d) -> barStart - scale(d[column]) - textXOffset
      .attr 'fill', (d) -> getColorById d.id
      .attr 'fill-opacity', 1.0
      .duration duration
      .delay groupTransitionDuration


    # Draw percentage labels for single mode
    groupsEnter.append 'text'
      .text (d) ->
        frac = d[columnInner]/d[column]
        "#{frac.toFixed(2)}".replace(/^0+/, '');
      .attr 'class', 'bar-compare'
      .attr 'y', textYOffset
      .attr 'x', svgJ.width() - 24
      .attr 'fill', womenColor
      .attr 'fill-opacity', 0

    compares = groups.select '.bar-compare'

    compares.transition()
      .text (d) ->
        frac = d[columnInner]/d[column]
        "#{frac.toFixed(2)}".replace(/^0+/, '');
      .attr 'fill', womenColor
      .attr 'fill-opacity', ->
        if singleMode then 1.0 else 0
      .attr 'x', svgJ.width() - 24

      .duration duration
      .delay groupTransitionDuration

    activateTooltips(svgJ)

    # User interaction callbacks
    groupsEnter.each ->
      $(this).on 'click', ->
        group = $(this)
        scope.$apply ->
          scope.toggleId group.data('id')


  # Watches for rendering updates

  scope.$watch 'sidebar.data', (oldValue, newValue) ->
    return if oldValue is newValue
    draw()

  scope.$watch 'charts.singleMode', (newValue, oldValue) ->
    return if newValue is oldValue

    column = if newValue
      scope.displayColumn.prefix
    else scope.displayColumn.name
    scope.d3Helper.sortByColumn(scope.sidebar.data, column, true)

    draw()

  scope.$watch 'filters.selected', (newValue, oldValue) ->
    return if newValue is oldValue
    draw()

  scope.$watch 'charts.updateFlag', (newValue, oldValue) ->
    return if newValue is oldValue
    draw()

  scope.$watchCollection 'filters.id', ->
    draw(300)
    scope.page.loaded += 1

  resizer = -> draw(0)
  scope.windowResize.register resizer

  element.on '$destroy', ->
    scope.windowResize.remove resizer
