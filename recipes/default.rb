# 
# Cookbook Name:: cloudfoundry-dea
# Recipe:: default
#
# Copyright 2012, Trotter Cashion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


n_nodes = search(:node, "role:cloudfoundry_nats_server")
n_node = n_nodes.first
  
  node.set[:cloudfoundry_dea][:searched_data][:nats_server][:host] = n_node.ipaddress  
  node.set[:cloudfoundry_dea][:searched_data][:nats_server][:user] = n_node.nats_server.user
  node.set[:cloudfoundry_dea][:searched_data][:nats_server][:password] = n_node.nats_server.password
  node.set[:cloudfoundry_dea][:searched_data][:nats_server][:port] = n_node.nats_server.port




%w{lsof psmisc librmagick-ruby}.each do |pkg|
  package pkg
end

directory node[:cloudfoundry_dea][:base_dir] do
  recursive true
  owner node[:cloudfoundry_common][:user]
  mode  '0755'
end

node[:cloudfoundry_dea][:runtimes].each do |k, runtime|
  include_recipe runtime[:cookbook]
end

cloudfoundry_component "dea"
