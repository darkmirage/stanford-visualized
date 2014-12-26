# This controller provides visualization data to the rendering directives
vizCtrl = ($scope, d3Helper) ->
  $scope.year
  $scope.minYear
  $scope.maxYear
  $scope.years = []

  $scope.$watch 'fullData', (newData, oldData) ->
    $scope.yearData = d3Helper.filterByColumn(newData, 'year', [$scope.year])
    $scope.years = d3Helper.uniqueValues(newData, 'year')
    $scope.maxYear = Math.max.apply null, $scope.years
    $scope.minYear = Math.min.apply null, $scope.years
    $scope.year = $scope.maxYear
    console.log $scope.years

  $scope.$watch 'year', (newYear, oldYear) ->
    $scope.yearData = d3Helper.filterByColumn($scope.fullData, 'year', [newYear])

angular.module 'stanfordViz'
  .controller 'VizCtrl', ['$scope', 'd3Helper', vizCtrl]