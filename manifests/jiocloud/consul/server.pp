# 
# Class rjil::jiocloud::consul::server
# Standup a consul server

class rjil::jiocloud::consul::server(
  $bind_addr = '0.0.0.0'
){
  if ($::consul_discovery_token) {
    $join_address = "${::consul_discovery_token}.service.consuldiscovery.linux2go.dk"
  } else {
    $join_address = ''
  }

  class { 'rjil::jiocloud::consul':
    config_hash => {
      'bind_addr'        => $bind_addr,
      'start_join'       => [$join_address],
      'data_dir'         => '/var/lib/consul-jio',
      'log_level'        => 'DEBUG',
      'server'           => true,
      'datacenter'       => $::consul_discovery_token,
    }
  }
}
