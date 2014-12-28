app = angular.module 'stanfordViz'

app.factory 'events', ->
  # Temporary hacky hack
  return {
    show: true,
    items: {
      '1965': ['US bombs Vietnam', ['history', 'polisci']]
      '1973': ['Oil shock', ['chemeng']]
      '1991': ['End of Soviet Union', ['history', 'polisci']]
      '1984': ['Reagan re-elected', ['econ', 'polisci']]
      '1999': ['MS&E department formed', ['ms&e', 'ie', 'opsres']]
      '2000': ['Dot-com burst', ['cs', 'econ']]
      '2001': ['9/11 terrorist attacks']
      '2003': ['Invasion of Iraq', ['polisci']]
      '2009': ['CS revamps curriculum', ['cs']]
    }
  }