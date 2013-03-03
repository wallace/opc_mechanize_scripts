require 'rubygems'
require 'mechanize'
require 'date'

sermon_title = ARGV[0] || exit
preacher     = ARGV[1] || exit

day = (ARGV[2] || Date.today.strftime("%m-%d-%y"))
day_link = "#{day} Sermon"

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

agent.page.link_with(:text => "Publish").click
agent.page.link_with(:text => day_link).click
post_form = agent.page.form_with(:name => "post")
post_form.content = "<p><em>#{sermon_title}</em></p><p>#{preacher}</p>"
post_form.submit
