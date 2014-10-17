# == Class ispconfig_memcached
#   This module is only a wrapper of memcached::client define.
#   ispconfig_memcached::client is a wrapper of memcahced::client define. The wrapper add creation of a monitoring page, and by default create two memcached instances (port 11211) on:
#
#   - cache-${cluster}01.${backplane_domain}
#   - cache-${cluster}02.${backplane_domain}
#
#   So, you need to define $cluster e $backplane_domain variables.
#   A monitoring page will be pushed in /var/www/cluster.${cluster}.${clusterdomain}/web/memcache.php
#
# === Examples:
#
#   node bar {
#     $cluster = 'bar'
#     $backplane_domain = 'backplane'
#   }
#
#   # note thath we don't need to define daemons
#   node bar01.example.com inherits bar {
#     ispconfig_memcached::client{'foo' : }
#   }
#
#   node bar-cache01.example.com {
#     class {'memcached':
#       bind_address        => 'x.x.x.x', #(ip address of memcache01.backplane)
#       memcached_hostname  => 'cache-bar01.backplane'
#     }
#   }
#
#   node bar-cache02.example.com {
#     class {'memcached':
#       bind_address        => 'y.y.y.y', #(ip address of memcache02.backplane)
#       memcached_hostname  => cache-bar02.backplane'
#     }
#   }
#
# === Use in IspConfig environment - assign a dedicated instance for a particular web$id
#   You can use ispconfig_memcached::client define to create also a dedicated memcahced instance for a particular web$id. You only need to set web_id parameter with the $id part of
#   your web$id. For example, create ad instance for the web100. By default memcahced instances will listen on port (12000 + 100) and bind on:
#
#   - cache-${cluster}01.${backplane_domain}
#   - cache-${cluster}02.${backplane_domain}
#
#   dedicated monitoring page will be pushed under /var/www/cluster.$cluster.$clusterdomain/web/memcache-web100.php
#   Examples:
#
#   node bar {
#     $cluster = 'bar'
#     $backplane_domain = 'backplane'
#   }
#
#   # note thath we don't need to define daemons
#   node bar01.example.com inherits bar {
#     ispconfig_memcached::client{'web100' : (define's name is not a convention!)
#       web_id  => '100'
#     }
#   }
#
#   node bar-cache01.example.com {
#     class {'memcached':
#       bind_address        => 'x.x.x.x', #(ip address of memcache01.backplane)
#       memcached_hostname  => 'cache-bar01.backplane'
#     }
#   }
#
#   node bar-cache02.example.com {
#     class {'memcached':
#       bind_address        => 'y.y.y.y', #(ip address of memcache02.backplane)
#       memcached_hostname  => cache-bar02.backplane'
#     }
#   }
#
class ispconfig_memcached {

}
