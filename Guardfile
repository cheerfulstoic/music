guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard :rubocop, cli: '--auto-correct --display-cop-names' do
  watch(/.+\.rb$/)
  watch(/(?:.+\/)?\.rubocop.*\.yml$/) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(/^spec\/.+_spec\.rb$/)
  watch(/^lib\/(.+)\.rb/)     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end
