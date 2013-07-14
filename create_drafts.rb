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
  puts "creating #{day}"
  agent.page.link_with(:text => "Publish").click
  post_form = agent.page.form_with(:name => "post")
  post_form.post_tag = 'oconee presbyterian church service podcast'
  post_form.post_title = "#{day} Sermon"
  post_form.checkbox_with(:id => 'category-369247').check
  post_form.checkbox_with(:id => 'category-369249').check
  post_form.checkbox_with(:id => 'category-368932').uncheck
  post_form.submit
  sleep 2
end
