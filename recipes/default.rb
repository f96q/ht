#
# Cookbook Name:: htpasswd
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require 'webrick'
require 'tempfile'

directory node[:htpasswd][:dir] do
  group 'root'
  owner 'root'
  mode 0755
  action :create
  recursive true
end

node[:deploy].each do |application, deploy|
  next unless deploy[:htpasswd]
  password = deploy[:htpasswd][:password]
  Tempfile.open('htpasswd') do |f|
    htpasswd = WEBrick::HTTPAuth::Htpasswd.new(f.path)
    password = htpasswd.set_passwd(nil, deploy[:htpasswd][:username], password)
  end
  template "#{node[:htpasswd][:dir]}/#{application}" do
    source 'htpasswd.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables(:username => deploy[:htpasswd][:username], :password => password)
  end
end
