## Uncomment to clear the screen before every task
# clearing :on

source_dir = 'app'
target_dir = 'public'
build_at_start = true

coffeescript_options = {
  input: "#{source_dir}/js",
  output: "#{target_dir}/js",
  all_on_start: true,
  patterns: [%r{.+\.(?:coffee|coffee\.md|litcoffee)$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end

guard 'sass', input: "#{source_dir}/css",
              output: "#{target_dir}/css",
              all_on_start: build_at_start

guard 'copy', from: source_dir,
              to: target_dir,
              mkpath: true,
              run_at_start: build_at_start do
  watch(%r{.+\.(html|csv|json)$})
end

guard 'copy', from: 'bower_components',
              to: "#{target_dir}/js/lib",
              mkpath: true,
              run_at_start: build_at_start do
  watch(%r{.+\.(js|min\.js|min\.js\.map)$})
end

guard 'livereload' do
  watch(%r{#{Regexp.quote(target_dir)}/.+\.(css|js|html|png|jpg|csv|json)})
end
