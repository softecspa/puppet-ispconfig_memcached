# == Define ispconfig_memcached::client
#
# create memcahed instances and push monitoring page in /var/www/cluster.$cluster.$clusterdomain/web/memcache.php
#
# [*daemons*]
#   array of hostname used to reach memcached instances. By default [ "cache-${cluster}01.${backplane_domain}", "cache-${cluster}02.${backplane_domain}"]
#
# [*daemons_ports*]
#   array of ports. More than one port will means thath more than one instances will be created of each hostname specified in <daemons>.  Default: [ 11211 ]
#
# [*dimension*]
#   portion of memory assigned to instance
#
# [*username*]
#   username for access to monitor page. By default it's set to $memcache_monitor_username global variable
#
# [*password*]
#   password for access to monitor page. By default it's set to $memcache_monitor_password global variable
#
# [*web_id*]
#   if this parameter is set, daemons port will be set to $(12000 + $web_id), unless you have set <daemons_ports>, and monitoring page will pushed in
#   /var/www/cluster.$cluster.$clusterdomain/web/memcache-web${web_id}.php
#
define ispconfig_memcached::client (
  $daemons      = [ "cache-${cluster}01.${backplane_domain}",
                    "cache-${cluster}02.${backplane_domain}"],
  $daemons_ports= '',
  $dimension    = '128',
  $username     = $::memcache_monitor_username,
  $password     = $::memcache_monitor_password,
  $web_id       = '',
) {

  if ($cluster == '') or ($backplane_domain == '') {
    fail ('variable cluster and backplane_domain must be set on the node')
  }

  $start_dedicated_port   = '12000'
  $default_instance_port  = '11211'

  if ($web_id!='') and (!is_integer($web_id)) {
    fail('web_id parameter must be integer value')
  }

  $array_daemons = is_array($daemons)? {
    true  => $daemons,
    false => [ $daemons ],
  }

  # se non vengono definiti ne webNN ne porte, uso la porta di default
  if ($daemons_ports == '') and ($web_id == '') {
    $array_ports= [ $default_instance_port ]
  }

  if $daemons_ports != '' {
    # se la variabile è definita uso le porte specificate, altrimenti valuto web_id.
    $array_ports = is_array($daemons_ports)? {
      true  => $daemons_ports,
      false => [ $daemons_ports ]
    }
  } else {
    if $web_id != '' {
      $ports = inline_template('<%= start_dedicated_port.to_i + web_id.to_i -%>')
      $array_ports = [ $ports ]
    }
  }

  memcached::client{ $name :
    daemons       => $array_daemons,
    daemons_ports => $array_ports,
    dimension     => $dimension,
  }

  $monitor_page = $web_id? {
    ''      => "/var/www/cluster.${cluster}.${clusterdomain}/web/memcache.php",
    default => "/var/www/cluster.${cluster}.${clusterdomain}/web/memcache-web${web_id}.php",
  }

  $concat_name = $web_id? {
    ''      => "memcache.php",
    default => "memcache${web_id}.php",
  }

  if !defined(Concat_build[$concat_name]) {
    concat_build{$concat_name :
      target  => $monitor_page,
      order   => ['*.tmp'],
    }

    concat_fragment {"${concat_name}+001.tmp":
      content => template('ispconfig_memcached/memcache.php_header.erb')
    }

    concat_fragment {"${concat_name}+999.tmp":
      content => template('ispconfig_memcached/memcache.php_footer.erb')
    }

    file {$monitor_page :
      ensure  => 'present',
      mode    => 755,
      owner   => 'www-data',
      require => Concat_build[$concat_name],
    }
  }

  #if $web_id == '' {
  #  if defined(Concat_build['ispconfig-vhost-master-template']) {
  #    if !defined(Concat_fragment['ispconfig-vhost-master-template+002-1.tmp']) {
  #      concat_fragment {'ispconfig-vhost-master-template+002-1.tmp':
  #        content => "php_value session.save_handler memcache\nphp_value session.save_path \"\\",
  #      }
  #      concat_fragment {'ispconfig-vhost-master-template+002-3.tmp':
  #        content => '"',
  #      }
  #    }
  #  }
  #
  #  concat_fragment {"ispconfig-vhost-master-template+002-2-${name}.tmp":
  #    content => template('ispconfig_memcached/ispconfig-vhost-template_instances.erb'),
  #  }
  #}

  concat_fragment {"${concat_name}+002-$name.tmp":
    content => template('ispconfig_memcached/memcache.php_instances.erb')
  }

}
