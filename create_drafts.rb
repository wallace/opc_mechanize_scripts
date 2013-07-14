require 'rubygems'
require 'mechanize'
require 'date'
require 'active_support/all'
# require 'active_support/core_ext/time/calculations'

day = Date.parse(ARGV[0]) || Date.today
sundays = (day.beginning_of_month..day.end_of_month).select { |e| e.sunday? }.map {|e| e.strftime("%m-%d-%y") }

agent = Mechanize.new
agent.get("https://www.podbean.com/login")

login_form = agent.page.form_with(:name => "loginform")

unless login_form
  puts "unable to find the login form"
  puts "*"*80
  puts login_form.inspect
  exit
end

login_form.log = ENV['OPCUSA_USERNAME']
login_form.pwd = ENV['OPCUSA_PASSWORD']
login_form.submit

sundays.each do |day|
  agent.page.link_with(:text => "Publish a new episode").click
  post_form = agent.page.form_with(:action => "/admin/post.php")

  # Set title
  post_form.post_title = "#{day} Sermon"

  # Set categories
  post_form.checkbox_with(:value => '369247 ').check
  post_form.checkbox_with(:value => '369249 ').check
  post_form.checkbox_with(:value => '368932 ').uncheck

  # Change to draft and submit
  post_form.buttons[0].value = "Save draft"
  post_form.submit

  puts "created #{day}"
end
