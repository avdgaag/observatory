def run(cmd)
  puts cmd
  `#{cmd}`
end

def run_all_tests
  system 'rake test'
end

def growl(message)
  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  passed = message.include?('0 failures, 0 errors')
  image = passed ? "~/.watchr_images/passed.png" : "~/.watchr_images/failed.png"
  severity = passed ? "-1" : "1"
  options = "-w -n Watchr --image '#{File.expand_path(image)}'"
  options << " -m '#{message}' '#{title}' -p #{severity}"
  system %(#{growlnotify} #{options} &)
end

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch('^lib.*/(.*)\.rb') do |m|
  result = run("ruby test/#{m[1]}_test.rb")
  growl result.split("\n").last
end

watch('test.*/teststrap\.rb') do
  run_all_tests
end

watch('^test/(.*)_test\.rb')  do |m|
  result = run("ruby test/#{m[1]}_test.rb")
  growl result.split("\n").last
end


# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end

@interrupted = false

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_suite
  end
end
