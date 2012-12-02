require 'rubygems'
require 'mechanize'

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

agent.page.link_with(:text => "Upload").click
agent.page.link_with(:text => "FTP Upload").click

ftp_import_form = agent.page.form_with(:name => 'form1')
# we have to manually add another field because mechanize doesn't recognize
# buttons as fields when submitting the form and without this field value, files
# are not actually imported
ftp_import_form.add_field!('ftp_import', 'Import FTP uploaded files')
ftp_import_form.submit
