# vim:set filetype=ruby:
def run(cmd)
  puts cmd
  system cmd
end

def spec(file)
  if File.exists?(file)
    run("rspec --fail-fast #{file}")
  else
    puts("Spec: #{file} does not exist.")
  end
end

watch("spec/.*/*_spec\.rb") do |match|
  puts(match[0])
  spec(match[0])
end

watch("app/(.*)\.rb") do |match|
  puts(match)
  spec("spec/requests/#{match[1]}_spec.rb")
end

watch("app/(.*/.*)\.rb") do |match|
  puts(match)
  spec("spec/#{match[1]}_spec.rb")
end


watch("app/views/*") do
  spec("spec/requests/app_spec.rb")
end
