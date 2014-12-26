angular.module 'stanfordViz'
  .directive 'mainToolbar', ->
    return {
      link: initToolbar,
      templateUrl: 'views/_main-toolbar.html'
    }

invalidToolbar = ->
  new Error('main-toolbar template should contain only one div')

initToolbar = (scope, element, attrs) ->
  toolbar = $(element).children()

  throw invalidToolbar() if toolbar.length != 1

  padding = $('<div></div>')
  $(element).append(padding)

  # Remember original toolbar location
  originalTop = toolbar.offset().top

  # Set a fixed width so width is preserved even when position fixed
  toolbar.width(toolbar.closest('.container').outerWidth())

  isFixed = false

  resizer = ->
    toolbar.width(toolbar.closest('.container').outerWidth())
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

  $(window).on 'resize', resizer
  $(window).on 'scroll', scroller

  element.on '$destroy', ->
    $(window).off 'resize', resizer
    $(window).off 'scroll', scroller
