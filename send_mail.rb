require "mail"
require "ap"
require 'open-uri'
require "json"

SITE = ARGV[0] == "live" ? "http://instabil.heroku.com" : "http://localhost:9292"
KEY = ARGV[0] == "live" ? ENV["API_KEY"] : "1234"
URL = "#{SITE}/api/people.json?key=#{KEY}"

puts "Fetching people from #{SITE}...".white

people = JSON.parse(open(URL).read)

puts "Done, got #{people.length} records.".green

print "Subject: ".white
SUBJECT = $stdin.gets

print "Body filename: ".white
filename = $stdin.gets.strip
BODY = File.read(filename)
puts BODY.encoding

puts "Press Enter to continue.".yellow
$stdin.gets

options = {
  :address              => 'smtp.gmail.com',
  :port                 => '587',
  :enable_starttls_auto => true,
  :user_name            => ENV['GMAIL_SMTP_USER'],
  :password             => ENV['GMAIL_SMTP_PASSWORD'],
  :authentication       => :plain,
  :domain               => ENV['GMAIL_SMTP_USER'] # the HELO domain provided by the client to the server
}

Mail.defaults do
  delivery_method :smtp, options
end

puts
sent = 0
people.each do |person|
  print "#{person["name"]} <#{person["email"]}>: ".white
  if person["email"].nil? || person["email"].empty?
    puts "skipping".yellow
    next
  end
  begin
    m = Mail.new({
      :from => ENV['GMAIL_SMTP_USER'],
      :to => person["email"],
      :subject => SUBJECT,
      :body => BODY,
      :charset => "utf-8"
    })
    m.deliver!
  rescue Exception => e
    puts e.message.red
  end
  puts "sent".green
  sent += 1
end
puts
puts "All done, sent #{sent} mails.".green