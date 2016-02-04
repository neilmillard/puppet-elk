# == Class: elk
#
# This class installs and configures an elk stack on one node
#
# === Parameters
#
#
#
# === Authors
#
# Neil Millard
#
class elk(
) inherits elk::params {

  require java
  include yum

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/2.2.0/elasticsearch-2.2.0.rpm',
  }

  elasticsearch::instance { 'es-01':
    config => { 
    'cluster.name' => 'vagrant_elasticsearch',
    'index.number_of_replicas' => '0',
    'index.number_of_shards'   => '1',
    'network.host' => '0.0.0.0',
    'marvel.agent.enabled' => false #DISABLE marvel data collection. 
    },        # Configuration hash
    init_defaults => { }, # Init defaults hash
    before => Class['::kibana4']
  }

#  elasticsearch::plugin{'royrusso/elasticsearch-HQ':
#    instances  => 'es-01'
#  }

#  elasticsearch::plugin{'elasticsearch/marvel/latest':
#    instances  => 'es-01'
#  }

# Logstash
  class { 'logstash':
    # autoupgrade  => true,
    ensure       => 'present',
    manage_repo  => true,
    repo_version => '1.5',
    require      => [ Class['java'], Class['elasticsearch'] ],
  }


# Kibana
  class { '::kibana4':
    config            => {
        'server.port'           => 5601,
        'server.host'           => '0.0.0.0',
        'elasticsearch.url'     => 'http://localhost:9200',
        }
  }


}
