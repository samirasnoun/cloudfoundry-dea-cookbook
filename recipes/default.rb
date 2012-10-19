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
#   node.save
   cf_id_node = node['cloudfoundry_dea']['cf_session']['cf_id']
   n_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}" )
   
      while n_nodes.count < 1 
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        n_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}")        
       end



    k = n_nodes.first
          	node.set['cloudfoundry_dea']['searched_data']['nats_server']['host'] = k['ipaddress']
  		node.set['cloudfoundry_dea']['searched_data']['nats_server']['user'] = k['nats_server']['user']
  		node.set['cloudfoundry_dea']['searched_data']['nats_server']['password'] = k['nats_server']['password']
  		node.set['cloudfoundry_dea']['searched_data']['nats_server']['port'] = k['nats_server']['port']
      
   node.set['cloudfoundry_common']['cf_session']['cf_id'] = cf_id_node
    
   node.save

#   include_recipe 'cloudfoundry-common'




#	if(node['cloudfoundry_dea']['searched_data']['nats_server']['host'] == nil ) then 
#        	Chef::Log.warn("No nats servers found for this cloud foundry session =  " + node['dea']['cf_session']['name'])
#	end 

 if platform?("ubuntu")
       include_recipe 'cloudfoundry-common'
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

        cloudfoundry_component "dea"


  elsif platform?("windows")
      Chef::Log.warn("Welcome to windows ! ")
     
   	cc_nodes = search(:node, "role:cloudfoundry_controller AND cf_id:#{cf_id_node}")
       while cc_nodes.count < 1 
        Chef::Log.warn("Waiting for controller .... I am sleeping 7 sec")
        sleep 7
        cc_nodes = search(:node, "role:cloudfoundry_nats_server AND cf_id:#{cf_id_node}")        
       end
 
        cc_node = cc_nodes.first

	node.set['cloudfoundry_dea']['searched_data']['cloudfoundry_cloud_controller']['ip']	= cc_node.ipaddress  # used for local route uhuru attribute
	
        template 'C:\Program Files\Uhuru Software\Uhuru .NET Droplet Execution Agent\uhuru.config' do
  	 source "Uhuru_config.erb"
  	 action :create 
	end 

  	#windows_batch "start_DEA" do
  	# cwd 'C:\Program Files\Uhuru Software\Uhuru .NET Droplet Execution Agent'
  	# code <<-EOH
  	# net start dea > trace_dea_uhuru_starting.txt
  	# EOH
	#end

        chef_gem "win32-service"

	require 'win32/service'

	 dea_service = Win32::Service.status('DEA') 
  	if (dea_service.current_state == 'running')
            Win32::Service.stop('DEA')
            sleep 10
            Win32::Service.start('DEA')	
        else 
   		Win32::Service.start('DEA')
  	end


        node['cloudfoundry_dea']['runtimes'].each do |k, runtime|
         include_recipe runtime['cookbook']
        end
  end

end 
