#
# Cookbook Name:: users-augment
# Recipe:: default
#
# Copyright 2013, ModCloth, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

augment_keys = nil
if data_bag(:users).include?('augment_keys')
  augment_keys = data_bag_item(:users, :augment_keys)
end
augment_data = node['users_augment']

info = nil
info = if augment_keys && augment_data
  info = augment_data.each_with_object({}) do |u, hash|
    name = u[0]
    data = u[1]
    allowed_users = data['users']

    keys = allowed_users.map do |allowed_user|
      augment_keys[allowed_user]
    end.reject(&:nil?).join("\n")

    hash[name] = {
      authorized_keys_path: data['authorized_keys_path'] || "/home/#{name}/.ssh/authorized_keys",
      keys: keys,
    }
  end
end

bash 'do_augment' do
  code '/root/augment-users'
  user 'root'
  group 'root'
  action :nothing
end

template '/root/augment-users' do
  cookbook 'users-augment'
  source 'augment-users.erb'
  mode 0500
  variables info: info
  notifies :run, 'bash[do_augment]', :delayed
  action [:create, :touch]
end
