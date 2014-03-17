# Copyright 2014 SUSE
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

rabbitmq_environment = node[:rabbitmq][:config][:environment]

vhostname = CrowbarRabbitmqHelper.get_ha_vhostname(node)
vip_primitive = "#{vhostname}-vip-admin"
service_name = "#{rabbitmq_environment}-service"
group_name = "#{service_name}-group"

ip_addr = CrowbarRabbitmqHelper.get_listen_address(node)

agent_name = "ocf:rabbitmq:rabbitmq-server"
rabbitmq_op = {}
rabbitmq_op["monitor"] = {}
rabbitmq_op["monitor"]["interval"] = "10s"

pacemaker_primitive vip_primitive do
  agent "ocf:heartbeat:IPaddr2"
  params ({
    "ip" => ip_addr,
  })
  op rabbitmq_op
  action :create
end

pacemaker_primitive service_name do
  agent agent_name
  params ({
    "nodename" => node[:rabbitmq][:nodename],
  })
  op rabbitmq_op
  action :create
end

pacemaker_group group_name do
  # Membership order *is* significant; VIPs should come first so
  # that they are available for the haproxy service to bind to.
  members [vip_primitive, service_name]
  meta ({
    "is-managed" => true,
    "target-role" => "started"
  })
  action [ :create, :start ]
end

# adapt standard service commands to force chef use crm API
resource = resources(:service => "rabbitmq-server")
resource.start_command("crm resource start #{group_name}")
resource.restart_command("crm resource restart #{group_name}")
resource.stop_command("crm resource stop #{group_name}")
