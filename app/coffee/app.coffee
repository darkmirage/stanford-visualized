angular.module 'stanfordViz', ['ngRoute']
  .config ($routeProvider) ->
    $routeProvider
      .when '/',        { templateUrl: 'views/home.html', controller: 'HomeCtrl' }
      .when '/contact', { templateUrl: 'views/contact.html', controller: 'ContactCtrl' }
      .when '/faq',     { templateUrl: 'views/faq.html', controller: 'FaqCtrl' }
      .otherwise        { redirectTo: '/' }

  .constant 'd3Path', './csv/data.csv'

  .constant 'd3Config', {
    path: './csv/data.csv',
    sidebarEntries: 30
  }