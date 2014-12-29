app = angular.module 'stanfordViz'

# Allows any nested modules to set page titles
app.factory 'pageMeta', ->
  page = {
    loading: true,
    title: '',
    fullTitle: ''
  }

  page.setTitle = (title) ->
    page.title = title
    if title.length > 0
      page.fullTitle = "#{title} | Stanford Visualized"
    else
      page.fullTitle = "Stanford Visualized"

  return page

# Consolidate all the $(window).resize() callbacks and implement delay logic
app.factory 'windowResize', ->
  callbacks = []

  $(window).resize ->
    if this.resizeTO
      clearTimeout(this.resizeTO) 
    this.resizeTO = setTimeout(
      ()-> $(this).trigger('resizeEnd')
      300)

  $(window).bind 'resizeEnd', ->
    callback() for callback in callbacks

  return {
    register: (callback) ->
      callbacks.push callback

    remove: (callback) ->
      index = callbacks.indexOf callback
      if index != -1
        callbacks.splice index, 1
  }

# Display helpers for d3
app.factory 'd3Display', ->
  highlight = []
  seen = []
  color = d3.scale.category20()

  getColorById = (id) ->
    if id not in highlight
      d3.rgb(150, 150, 150)
    else
      color(id)

  return {
    addColor: (id) ->
      if id not in seen
        seen.push(id)
        color.domain(seen)

    initColor: (ids) ->
      highlight = ids
      seen = ids.slice 0
      color.domain(seen)

    getColor: (d) ->
      getColorById d.id

    getColorById: getColorById

    getOpacity: (d) ->
      if d.id not in highlight
        0.3
      else
        1.0
  }

# Data manipulation helpers for d3
app.factory 'd3Helper', ->
  return {
    filterByColumn: (data, column, values, exclude=false) ->
      # filters creates a copy
      data.filter (d) ->
        (d[column] in values and not exclude) or (d[column] not in values and exclude)

    sortByColumn: (data, column, descending=false) ->
      # sort does not create a copy
      data.sort (a, b) ->
        if descending
          b[column] - a[column]
        else
          a[column] - b[column]

    uniqueValues: (data, column) ->
      return [] if data.length == 0
      map = {}
      map[d[column]] = d[column] for d in data
      (value for key, value of map).sort (a, b) -> a - b

    toggleId: (ids, id) ->
      index = ids.indexOf(id)
      if index == -1
        ids.push(id)
      else
        ids.splice(index, 1)
  }

# Data retrieval for d3
app.service 'd3Data', ['$q', ($q) ->
  defer = $q.defer()

  parseEnrollment = (d) ->
    return {
      year: +d.year,
      id: d.id,
      undergrad_men: +d.undergrad_men,
      undergrad_women: +d.undergrad_women,
      undergrad: +d.undergrad,
      graduate_men: +d.graduate_men,
      graduate_women: +d.graduate_women,
      graduate: +d.graduate,
      total_men: +d.total_men,
      total_women: +d.total_women,
      total: +d.total,
      cat: d.cat,
      school: d.school
    }

  return {
    get: (path) ->
      d3.csv path, parseEnrollment, (error, data) ->
        defer.resolve(data)
      defer.promise
  }
]