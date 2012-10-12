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

if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else

include_recipe 'cloudfoundry-common'
  
   cf_id_node = node['cloudfoundry_dea']['cf_session']['cf_id']
   n_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}" )


   k = n_nodes.first
#   Chef::Log.warn(" =================================> k = " + k.first.ipaddress +  "=======================>")
          	node.set['cloudfoundry_dea']['searched_data']['nats_server']['host'] = k['ipaddress']
  		node.set['cloudfoundry_dea']['searched_data']['nats_server']['user'] = k['nats_server']['user']
  		node.set['cloudfoundry_dea']['searched_data']['nats_server']['password'] = k['nats_server']['password']
  		node.set['cloudfoundry_dea']['searched_data']['nats_server']['port'] = k['nats_server']['port']
      

	if(node['cloudfoundry_dea']['searched_data']['nats_server']['host'] == nil ) then 
        	Chef::Log.warn("No nats servers found for this cloud foundry session =  " + node['dea']['cf_session']['name'])
	end 

if platform?("ubuntu")



%w{lsof psmisc librmagick-ruby}.each do |pkg|
  package pkg
end

directory node['cloudfoundry_dea']['base_dir'] do
  recursive true
  owner node['cloudfoundry_common']['user']
  mode  '0755'
end

node['cloudfoundry_dea']['runtimes'].each do |k, runtime|
  include_recipe runtime['cookbook']
end
end
cloudfoundry_component "dea"

end 
