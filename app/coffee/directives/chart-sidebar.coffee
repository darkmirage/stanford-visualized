angular.module 'stanfordViz'
  .directive 'sidebarChart', ->
    return {
      restrict: 'A',
      link: initSidebar
    }

initSidebar = (scope, element, attrs) ->
  groupTransitionDuration = 300
  barHeight = 20
  barSpacing = 2
  textYOffset = 15 # not sure what this should be based off
  textXOffset = 5
  textWidth = 100
  barSlot = barHeight + barSpacing * 2

  scale = d3.scale.linear()

  container = d3.select(element[0])
  container.selectAll('svg').remove()
  svg = container.append('svg')
  svgJ = $('svg', element)

  getBarY = (d, i) -> barSpacing + i * barSlot

  getLabelY = (d, i) ->
    barY = getBarY d, i
    barY + textYOffset

  draw = (duration=400) ->
    maxRange = scope.sidebarMaxRange
    data = scope.sidebarData
    column = scope.displayColumn

    barStart = svgJ.width() + barSpacing - textWidth

    # Update height of svg according to numbe of elements present
    svgJ.height((data.length + 1) * barSlot)

    scale.domain [0, maxRange]
    scale.range [0, svgJ.width() - textWidth - barSpacing * 2]

    groups = svg.selectAll('svg').data data, (d) -> d.id

    groupsEnter = groups.enter().append 'svg'
      .attr 'class', 'bar-group'
      .attr 'data-action', 'id-selector'
      .attr 'data-id', (d) -> d.id
      .attr 'data-value', (d) -> d[column]
      .attr 'y', getBarY

    groups.transition()
      .attr 'y', getBarY
      .duration groupTransitionDuration

    groups.exit().remove()


    # Draw background
    groupsEnter.append 'rect'
      .attr 'class', 'bar-background'
      .attr 'width', svgJ.width()
      .attr 'height', barSlot
      .attr 'fill', '#ffffff'
      .attr 'fill-opacity', 0

    backgrounds = groups.select '.bar-background'

    backgrounds.transition()
      .attr 'width', svgJ.width()
      .attr 'fill-opacity', 1.0
      .duration duration
      .delay groupTransitionDuration


    # Draw bars
    groupsEnter.append 'rect'
      .attr 'class', 'bar'
      .attr 'x', (d) -> barStart - scale d[column]
      .attr 'y', barSpacing
      .attr 'width', 0
      .attr 'height', barHeight
      .attr 'fill', (d) -> scope.d3Display.getColor d
      .attr 'fill-opacity', 0

    bars = groups.select '.bar'

    bars.transition()
      .attr 'x', (d) -> barStart - scale d[column]
      .attr 'width', (d) -> scale d[column]
      .attr 'fill', (d) -> scope.d3Display.getColor d
      .attr 'fill-opacity', (d) -> scope.d3Display.getOpacity d
      .duration duration
      .delay groupTransitionDuration


    # Draw name labels
    groupsEnter.append 'text'
      .text (d) -> d.id
      .attr 'class', 'bar-label'
      .attr 'y', textYOffset
      .attr 'x', barStart + textXOffset
      .attr 'fill', (d) -> scope.d3Display.getColor d
      .attr 'fill-opacity', 0

    labels = groups.select '.bar-label'

    labels.transition()
      .attr 'fill', (d) -> scope.d3Display.getColor d
      .attr 'fill-opacity', 1.0
      .duration duration
      .delay groupTransitionDuration


    # Draw count labels
    groupsEnter.append 'text'
      .text (d) -> d[column]
      .attr 'class', 'bar-count'
      .attr 'text-anchor', 'end'
      .attr 'y', textYOffset
      .attr 'x', (d) -> barStart - scale d[column] + textXOffset
      .attr 'fill', (d) -> scope.d3Display.getColor d
      .attr 'fill-opacity', 0

    counts = groups.select '.bar-count'

    counts.transition()
      .text (d) -> d[column]
      .attr 'x', (d) -> barStart - scale d[column] + textXOffset
      .attr 'fill', (d) -> scope.d3Display.getColor d
      .attr 'fill-opacity', 1.0
      .duration duration
      .delay groupTransitionDuration

    # User interaction callbacks
    groupsEnter.each ->
      $(this).on 'click', ->
        group = $(this)
        scope.$apply ->
          scope.toggleId group.data('id')


  # Rendering callbacks
  watches = []
  watches.push scope.$watch 'sidebarMaxRange', -> draw()
  watches.push scope.$watch 'sidebarData', -> draw()
  watches.push scope.$watchCollection 'idFilters', -> draw(0)

  resizer = -> draw(0)
  $(window).on 'resize', resizer

  element.on '$destroy', ->
    $(window).off 'resize', -> resizer

    # Clear watches
    watch() for watch in watches
