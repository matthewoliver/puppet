# == Class: rcbau::nodepool
#
class rcbau::nodepool(
  $mysql_root_password,
  $mysql_password,
  $nodepool_ssh_private_key = '',
  $nodepool_template = 'nodepool.yaml.erb',
  $sysadmins = [],
  $statsd_host = '',
  $rackspace_username ='',
  $rackspace_password ='',
  $rackspace_project ='',
  $git_source_repo = 'https://git.openstack.org/openstack-infra/nodepool',
  $revision = 'master',
  $puppetmaster = '',
) {
  class { 'rcbau::server':
    sysadmins                 => $sysadmins,
  }

  class { '::nodepool':
    mysql_root_password      => $mysql_root_password,
    mysql_password           => $mysql_password,
    nodepool_ssh_private_key => $nodepool_ssh_private_key,
    statsd_host              => $statsd_host,
    git_source_repo          => $git_source_repo,
    revision                 => $revision,
  }

  file { '/etc/nodepool/nodepool.yaml':
    ensure  => present,
    owner   => 'nodepool',
    group   => 'root',
    mode    => '0400',
    content => template("rcbau/nodepool/${nodepool_template}"),
    require => [
      File['/etc/nodepool'],
      User['nodepool'],
    ],
  }

  file { '/etc/nodepool/scripts':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => File['/etc/nodepool'],
    source  => 'puppet:///modules/rcbau/nodepool/scripts',
  }

  file { '/etc/nodepool/scripts/prepare_node_turbo_hipster.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('rcbau/nodepool/prepare_node_turbo_hipster.sh.erb'),
    require => File['/etc/nodepool/scripts'],
  }
}