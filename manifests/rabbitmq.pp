#
# Class: rjil::rabbitmq
#  This class to manage contrail rabbitmq dependency
#
# == Hiera elements required
#
# rabbitmq::manage_repo: no
#   This parameter to disable apt repo management in rabbitmq module
#
# rabbitmq::admin::enable: no
#   To disable rabbitmqadmin
#   Note: In original contrail installation it is disabled, so starting with
#   disabling it.
#


class rjil::rabbitmq (
  $rabbit_admin_user = undef,
  $rabbit_admin_pass = undef,
) {

  rjil::test { 'check_rabbitmq.sh': }

  include ::rabbitmq

  rabbitmq_user { $rabbit_admin_user:
    admin    => true,
    password => $rabbit_admin_pass,
  }

  rabbitmq_user_permissions { "${rabbit_admin_user}@/":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

}
