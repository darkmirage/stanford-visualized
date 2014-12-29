# This controller handles data preprocessing
dataCtrl = ($scope, d3Config, d3Data, d3Helper) ->
  d3Filter = d3Helper.filterByColumn
  d3Sort = d3Helper.sortByColumn

  $scope.indices = {
    columnToMaxRange: {}
    majorToItems: {}
    yearToItems: {}
  }

  $scope.data = {
    aggregates: []
    items: []
    years: []
    updated: 0 # FLag watched by child controller
  }

  createIndices = (items) ->
    majorToItems = $scope.indices.majorToItems
    for d in items
      if majorToItems[d.id] is undefined
        majorToItems[d.id] = []
      majorToItems[d.id].push d

    yearToItems = $scope.indices.yearToItems
    for d in items
      if yearToItems[d.year] is undefined
        yearToItems[d.year] = []
      yearToItems[d.year].push d

    columnToMaxRange = $scope.indices.columnToMaxRange
    for column in d3Config.dataColumns
      columnToMaxRange[column] = d3.max items, (d) -> d[column]

  parseData = (data) ->
    years = d3Helper.uniqueValues(data, 'year')
    items = d3Filter(data, 'cat', ['aggr', 'dept'], true)
    aggregates = d3Filter(data, 'cat', ['aggr', 'dept'])

    createIndices items

    $scope.data.years = years
    $scope.data.aggregates = aggregates
    $scope.data.items = items

  d3Data.get(d3Config.path).then (data) ->
    parseData(data)
    # Updates flag to signal to child controller to proceed
    $scope.data.updated += 1

angular.module 'stanfordViz'
  .controller 'DataCtrl', ['$scope', 'd3Config', 'd3Data', 'd3Helper',
                           dataCtrl]