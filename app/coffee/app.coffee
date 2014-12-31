angular.module 'stanfordViz', ['ngRoute', 'cfp.hotkeys']
  .config ($routeProvider) ->
    $routeProvider
      .when '/',        { templateUrl: 'views/home.html', controller: 'VizCtrl' }
      .when '/about',   { templateUrl: 'views/about.html', controller: 'AboutCtrl' }
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
          <div class="cfp-hotkeys-close">
            <i class="fa fa-times"></i>
          </div>
        </div>
      </div>';

  .constant 'd3Config', {
    path: './csv/data.csv'
    keyPath: './csv/keys.csv'
    sidebarEntries: 30
    defaultMajors: ['cs', 'econ', 'history']
    dataColumns: {
      'undergrad_men': 'Number of undergraduate men'
      'undergrad_women': 'Number of undergraduate women'
      'undergrad': 'Number of undergraduate students'
      'graduate_men': 'Number of graduate men'
      'graduate_women': 'Number of graduate women'
      'graduate': 'Number of graduate students'
      'total_men': 'Number of men overall'
      'total_women': 'Number of women overall'
      'total': 'Number of students overall'
      'undergrad_ratio': 'Ratio of undergraduate men to women'
      'graduate_ratio': 'Ratio of graduate men to women'
      'total_ratio': 'Ratio of men to women overall'
      'undergrad_men_percentage_of_declared': 'Percentage of declared undergraduate men'
      'undergrad_women_percentage_of_declared': 'Percentage of declared undergraduate women'
      'undergrad_percentage_of_declared': 'Percentage of declared undergraduate students'
      'graduate_men_percentage_of_declared': 'Percentage of declared graduate men'
      'graduate_women_percentage_of_declared': 'Percentage of declared graduate women'
      'graduate_percentage_of_declared': 'Percentage of declared graduate students'
      'total_men_percentage_of_declared': 'Percentage of declared men overall'
      'total_women_percentage_of_declared': 'Percentage of declared women overall'
      'total_percentage_of_declared': 'Percentage of declared students overall'
    }
  }