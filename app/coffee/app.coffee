angular.module 'stanfordViz', ['ngRoute', 'cfp.hotkeys']
  .config ($routeProvider) ->
    $routeProvider
      .when '/',        { templateUrl: 'views/home.html', controller: 'VizCtrl' }
      .when '/contact', { templateUrl: 'views/contact.html', controller: 'ContactCtrl' }
      .when '/faq',     { templateUrl: 'views/faq.html', controller: 'FaqCtrl' }
      .otherwise        { redirectTo: '/' }

  .config (hotkeysProvider) ->
    hotkeysProvider.template =
      '<div class="cfp-hotkeys-container fade" ng-class="{in: helpVisible}" style="display: none;">
        <div class="cfp-hotkeys" ng-click="toggleCheatSheet()">
          <h4 class="cfp-hotkeys-title">{{ title }}</h4>
          <table>
          <tbody>
            <tr ng-repeat="hotkey in hotkeys | filter:{ description: \'!$$undefined$$\' }">
              <td class="cfp-hotkeys-keys">
                <span ng-repeat="key in hotkey.format() track by $index" class="cfp-hotkeys-key">
                  {{ key }}
                </span>
              </td>
              <td class="cfp-hotkeys-text">{{ hotkey.description }}</td>
            </tr>
          </tbody>
          </table>
          <div class="cfp-hotkeys-close" ng-click="toggleCheatSheet()">
            <i class="fa fa-times"></i>
          </div>
        </div>
      </div>';

  .constant 'd3Config', {
    path: './csv/data.csv',
    sidebarEntries: 30,
    defaultMajors: ['cs', 'econ', 'history'],
    dataColumns: [
      'undergrad_men',
      'undergrad_women',
      'undergrad',
      'graduate_men',
      'graduate_women',
      'graduate',
      'total_men',
      'total_women',
      'total'
    ]
  }