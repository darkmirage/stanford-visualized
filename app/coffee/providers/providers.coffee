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
  seen = []
  color = d3.scale.category20()
  filters = {}
  charts = {}

  getColorById = (id) ->
    if charts.singleMode
      if id is filters.selected
        color(id)
      else
        switch id
          when '_men' then '#aec7e8'
          when '_women' then '#ff9896'
          else d3.rgb(150, 150, 150)

    else if id not in filters.id
      d3.rgb(150, 150, 150)
    else
      color(id)
    
  return {
    formatCount: (count, percentages=false, sign=false) ->
      if percentages
        count = count * 100
        if sign then "#{count.toFixed(2)}%" else count.toFixed(2)
      else
        count

    addColor: (id) ->
      if id not in seen
        seen.push(id)
        color.domain(seen)

    initColor: (f, c) ->
      filters = f
      charts = c
      seen = f.id.slice 0
      color.domain(seen)

    getColor: (d) ->
      getColorById d.id

    getColorById: getColorById

    getOpacity: (d) ->
      if charts.singleMode
        if d.id is filters.selected
          1.0
        else
          0.3
      else
        if d.id not in filters.id
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
  }

# Data retrieval for d3
app.service 'd3Data', ['$q', 'd3Config', ($q, d3Config) ->
  defer = null

  parseEnrollment = (d) ->
    result = {
      year: +d.year,
      id: d.id,
      cat: d.cat,
      school: d.school
    }
    for column of d3Config.dataColumns
      result[column] = +d[column]
    return result

   {
    get: ->
      defer = $q.defer()
      d3.csv d3Config.keyPath, null, (error, keys) ->
        d3.csv d3Config.path, parseEnrollment, (error, data) ->
          defer.resolve {
            data: data
            keys: keys
          }
      defer.promise
  }
]