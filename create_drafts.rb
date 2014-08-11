require 'rubygems'
require 'mechanize'
require 'date'
require 'active_support/all'
# require 'active_support/core_ext/time/calculations'

arg_day = Date.parse(ARGV[0]) rescue nil
day = arg_day || Date.today
sundays = (day.beginning_of_month..day.end_of_month).select { |e| e.sunday? }.map {|e| e.strftime("%m-%d-%y") }

agent = Mechanize.new
agent.get("http://www.podbean.com/site/user/login?return=http%3A%2F%2Fopcusa.podbean.com%2Fadmin")

login_form = agent.page.form_with(:id => "login-form")

unless login_form
  puts "unable to find the login form"
  puts "*"*80
  puts login_form.inspect
  exit
end

login_form.send('LoginForm[username]', ENV['OPCUSA_USERNAME'])
login_form.send('LoginForm[password]', ENV['OPCUSA_PASSWORD'])
login_form.submit

sundays.each do |day|
  agent.page.link_with(:text => "Publish").click
  agent.page.link_with(:text => " Publish New Episode").click
  post_form = agent.page.form_with(:action => "http://opcusa.podbean.com/admin/post.php")

  # Set title
  post_form.title = "#{day} Sermon"

  # Set categories
  post_form.checkbox_with(:value => '369247').check
  post_form.checkbox_with(:value => '369249').check
  post_form.checkbox_with(:value => '368932').uncheck

  # Change to draft and submit
  post_form.buttons[0].value = "Save draft"
  post_form.submit

  puts "created #{day}"
  sleep(rand(2))
end
