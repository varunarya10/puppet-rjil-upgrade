#
# Class: rjil::test::haproxy_openstack
#

class rjil::test::haproxy_openstack(
  $horizon_ips           = [],
  $keystone_ips          = [],
  $keystone_internal_ips = [],
  $glance_ips            = [],
  $cinder_ips            = [],
  $nova_ips              = [],
) {

  include openstack_extras::auth_file

  include rjil::test::base

  include keystone::client
  include glance::client

  file { "/usr/lib/jiocloud/tests/haproxy_openstack.sh":
    content => template('rjil/tests/haproxy_openstack.sh.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

}
