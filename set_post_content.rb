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

tbody = agent.page.at("//table//tbody")

post_to_edit = nil
tbody.children.each do |row|
  row.children.each do |column|
    if column && column.children && column.children.first &&
      column.children.first.content =~ /#{day}/
      post_to_edit = row
    end
  end
end

# open up the edit page for the post
agent.get(post_to_edit.css("a[@href*='edit']").first.attributes["href"])

post_form = agent.page.form_with(:action => "/admin/post.php")
post_form.content = "<p><em>#{sermon_title}</em></p><p>#{preacher}</p>"

# Change to draft and submit
post_form.buttons[0].value = "Save draft"
post_form.submit
