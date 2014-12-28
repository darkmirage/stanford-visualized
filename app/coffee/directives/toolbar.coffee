app = angular.module 'stanfordViz'

app.directive 'toolbarFixed', ->
  return {
    link: initToolbar,
    templateUrl: 'views/_toolbar-fixed.html'
  }

app.directive 'toolbarNotFixed', ->
  return {
    templateUrl: 'views/_toolbar-not-fixed.html'
  }

app.directive 'toolbarColumnToggles', ->
  return {
    templateUrl: 'views/_toolbar-column-toggles.html'
  }

invalidToolbar = ->
  new Error('_toolbar-fixed template should contain only one div')

initToolbar = (scope, element, attrs) ->
  toolbar = $(element).children()

  throw invalidToolbar() if toolbar.length != 1

  padding = $('<div></div>')
  $(element).append(padding)

  # Remember original toolbar location
  originalTop = toolbar.offset().top

  # Set a fixed width so width is preserved even when position fixed
  toolbar.width(toolbar.closest('.container-fluid').outerWidth())

  isFixed = false

  resizer = ->
    toolbar.width(toolbar.closest('.container-fluid').outerWidth())
    if isFixed
      originalTop = padding.offset().top
    else
      originalTop = toolbar.offset().top

  scroller = ->
    if $(window).scrollTop() > originalTop
      if not isFixed
        toolbar.addClass('fixed-toolbar')
        padding.height(toolbar.height())
        isFixed = true
    else
      if isFixed
        toolbar.removeClass('fixed-toolbar')
        padding.height(0)
        isFixed = false

  scope.windowResize.register resizer
  $(window).on 'scroll', scroller

  element.on '$destroy', ->
    scope.windowResize.remove resizer
    $(window).off 'scroll', scroller
