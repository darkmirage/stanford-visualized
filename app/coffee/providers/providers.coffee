app = angular.module 'stanfordViz'

app.factory 'pageMeta', ->
  title = ''
  return {
    title: -> title
    fullTitle: ->
      if title.length > 0
        "#{title} | Stanford Visualized"
      else
        "Stanford Visualized"
    setTitle: (newTitle) -> title = newTitle
  }

app.factory 'd3Helper', ->
  return {
    filterByColumn: (data, column, values, exclude=false) ->
      data.filter (d) ->
        (d[column] in values and not exclude) or (d[column] not in values and exclude)
    sortByColumns: (data, columns, descending=false) ->
      newData = data.slice 0
      newData.sort (a, b) ->
        a.undergrad < b.undergrad
    uniqueValues: (data, column) ->
      return [] if data.length == 0
      map = {}
      map[d[column]] = d[column] for d in data
      (value for key, value of map).sort (a, b) -> b - a
  }

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