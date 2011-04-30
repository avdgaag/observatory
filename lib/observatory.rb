module Observatory
  # Your code goes here...
end

%w{dispatcher event observable observer}.each do |f|
  require File.join(File.dirname(__FILE__), 'observatory', f)
end
