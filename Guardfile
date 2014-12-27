## Uncomment to clear the screen before every task
# clearing :on

source_dir = 'app'
target_dir = 'public'
build_at_start = true

coffeescript_options = {
  input: "#{source_dir}/coffee",
  output: "#{source_dir}/js",
  all_on_start: true,
  shallow: false,
  patterns: [%r{^app/.+\.(coffee|coffee\.md|litcoffee)$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end

guard :sass, input: "#{source_dir}/sass",
              output: "#{source_dir}/css",
              all_on_start: build_at_start

guard :copy, from: source_dir,
              to: target_dir,
              mkpath: true,
              run_at_start: build_at_start do
  watch(%r{.+\.(html|csv|json)$})
end

guard :copy, from: 'bower_components',
              to: "#{target_dir}/lib",
              mkpath: true,
              run_at_start: build_at_start do
  watch(%r{.+\.(min\.css|min\.js|min\.js\.map)$})
end

guard :jammit, output_folder: "#{target_dir}/assets",
               package_on_start: build_at_start do
  watch(%r{^#{Regexp.quote(source_dir)}/css/.+\.css})
  watch(%r{^#{Regexp.quote(source_dir)}/js/.+\.js})
end

guard :livereload do
  watch(%r{#{Regexp.quote(target_dir)}/.+\.(css|js|html|png|jpg|csv|json)})
end
