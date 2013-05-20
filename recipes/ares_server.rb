#
# Cookbook Name:: postgresql
# Recipe:: ares_server
#
# Author:: Léo Unbekandt <(leo@unbekandt.eu)>
# © 2013 ARES
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

include_recipe "postgresql::server"

execute "backup postgresql pid file" do
  command "cp #{node['postgresql']['config']['data_directory']}/postmaster.pid /tmp"
end

include_recipe "fs_mount"

execute "Restore postgresql pid file" do
  command "cp /tmp/postmaster.pid #{node['postgresql']['config']['data_directory']}"
end
execute "Give correct owner to pid file" do
  command "chown postgres:postgres #{node['postgresql']['config']['data_directory']}/postmaster.pid"
end

execute "fixup /var/lib/postgresql owner" do
  command "chown -Rf postgres:postgres /var/lib/postgresql"
  only_if { Etc.getpwuid(File.stat('/var/lib/postgresql').uid).name != "postgres" }
end

service "postgresql" do
  action :restart
end
