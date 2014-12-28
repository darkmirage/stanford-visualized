angular.module 'stanfordViz'
  .directive 'mainToolbarColumnToggles', ->
    return {
      link: initToggles,
      templateUrl: 'views/_toolbar-column-toggles.html'
    }

angular.module 'stanfordViz'
  .directive 'mainToolbarHelp', ->
    return {
      link: initHelp,
      templateUrl: 'views/_toolbar-help.html'
    }

initToggles = (scope, element, attrs) ->
  columnButtons = $('button[data-chart-toggle]', element)

  updateButtonsState = ->
    columnButtons.each ->
      button = $(this)
      if button.data('chart-toggle-value') is scope.displayColumn[button.data('chart-toggle')]
        button.addClass('active')
      else
        button.removeClass('active')

  updateButtonsState()

  columnButtons.on 'click', ->
    button = $(this)
    return if button.hasClass('active')
    scope.$apply ->
      scope.displayColumn[button.data('chart-toggle')] = button.data('chart-toggle-value')
    updateButtonsState()

initHelp = (scope, element, attrs) ->
  null