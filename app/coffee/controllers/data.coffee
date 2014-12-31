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
    departments: []
    items: []
    years: []
    updated: 0 # Flag watched by child controller
  }

  # Reference keys for major and category descriptions
  $scope.keys = {}
  $scope.majorCount = 0

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
    for column of d3Config.dataColumns
      columnToMaxRange[column] = d3.max items, (d) -> d[column]

  parseData = (data) ->
    years = d3Helper.uniqueValues(data, 'year')
    items = d3Filter(data, 'cat', ['aggr', 'dept'], true)
    aggregates = d3Filter(data, 'cat', ['aggr'])
    departments = d3Filter(data, 'cat', ['dept'])

    createIndices items

    $scope.data.years = years
    $scope.data.aggregates = aggregates
    $scope.data.departments = departments
    $scope.data.items = items

  saveKeys = (keys) ->
    for key in keys
      $scope.keys[key.id] = key
      $scope.majorCount += 1 if key.cat not in ['aggr', 'dept']

  d3Data.get(d3Config.path).then (result) ->
    parseData(result.data)
    saveKeys(result.keys)

    # Updates flag to signal to child controller to proceed
    $scope.data.updated += 1

angular.module 'stanfordViz'
  .controller 'DataCtrl', ['$scope', 'd3Config', 'd3Data', 'd3Helper',
                           dataCtrl]