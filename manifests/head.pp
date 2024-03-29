class dmlite::head (
  String $token_password,
  Enum['ip','id', 'none'] $token_id = 'ip',
  String $mysql_username,
  String $mysql_password,
  Stdlib::Host $mysql_host = 'localhost',
  String $dpm_db = 'dpm_db',
  String $ns_db = 'cns_db',
  Stdlib::Host $dpmhost = $::fqdn,
  Stdlib::Host $nshost = $::fqdn,
  Stdlib::Host $dbhost = $::fqdn,
  Optional[String] $domain = undef,
  Optional[Array[String]] $volist = undef,
  Boolean $legacy = true,
  String $mysqlrootpass = '',
  Boolean $dbmanage = true,
  Integer $uid = 151,
  Integer $gid = 151,
  Optional[String] $adminuser = undef,
  Boolean $debuginfo = false,
  Integer $log_level = 1,
  Array[String] $logcomponents = [],
  Boolean $enable_space_reporting = false,
  Boolean $enable_dome = false,
  Boolean $enable_disknode = false,
  Boolean $enable_domeadapter = false,
  String $host_dn = '',
  Optional[String] $oidc_clientid = undef,
  Array[String] $oidc_allowissuer = [],
  Array[String] $oidc_allowaudience = [],
) {
  class{'dmlite::config::head':
    log_level     => $log_level,
    logcomponents => $logcomponents
  }
  class{'dmlite::install':
    debuginfo => $debuginfo
  }
  if $enable_domeadapter and $enable_space_reporting{
    fail("'enable_domeadapter' and 'enable_space_reporting' options are mutual exclusive")
  }
  if !$enable_domeadapter and !$legacy{
    fail("'enable_domeadapter' and 'legacy' options both false are not supported")
  }

  if !$legacy {
    #
    # Base configuration
    #
    if !defined(Class['dmlite::base']) {
      if gid != undef {
        class { 'dmlite::base':
          uid => $uid,
          gid => $gid,
        }
      } else {
        class { 'dmlite::base':
          uid => $uid,
          gid => $uid,
        }
      }
    }
  
    #
    # In case the DB is not local we should configure the file /root/.my.cnf

    if $dbhost != 'localhost' and $dbhost != $::fqdn and $dbmanage {
        #check if root pass is empty
        if empty($mysqlrootpass ) {
                fail('mysqlrootpass parameter  should  not be empty')
        }
        #create the /root/.my.cnf
        file { '/root/.my.cnf':
          ensure  => present,
          mode    => '0655',
          content => template('dmlite/mysql/my.cnf.erb'),
          before  => [Class[dmlite::db::dpm], Class[dmlite::db::ns]]
        }
    }
    Package['dmlite-dpmhead-domeonly']
    ->
    class{'dmlite::db::dpm':
      dbname => $dpm_db,
      dbuser => $mysql_username,
      dbpass => $mysql_password,
      dbhost => $mysql_host,
    }

    Package['dmlite-dpmhead-domeonly']
    ->
    class{'dmlite::db::ns':
      flavor => 'mysql',
      dbname => $ns_db,
      dbuser => $mysql_username,
      dbpass => $mysql_password,
      dbhost => $mysql_host,
    }
  }

  if $enable_domeadapter and $enable_dome {
    class{'dmlite::plugins::domeadapter::config::head':
      token_password => $token_password,
      token_id       => $token_id,
      adminuser      => $adminuser,
      dome_head_url  => "http://${::fqdn}:1094/domehead",
      dome_disk_url  => "http://${::fqdn}:1095/domedisk",
      disknode       => $enable_disknode,
      host_dn        => $host_dn
    }
    class{'dmlite::plugins::domeadapter::install':}

    class{'dmlite::plugins::adapter::install':
      uninstall      => true,
    }
    class{'dmlite::plugins::adapter::config::head':
      token_password => $token_password,
      token_id       => $token_id,
      empty_conf     => true,
    }

    class{'dmlite::plugins::mysql::config':
      empty_conf     => true,
      mysql_password => '',
    }

    class{'dmlite::plugins::mysql::install':
      uninstall      => true,
    }
  }
  else
  {
    class{'dmlite::plugins::mysql::config':
      mysql_host     => $mysql_host,
      mysql_username => $mysql_username,
      mysql_password => $mysql_password,
      ns_db          => $ns_db,
      dpm_db         => $dpm_db,
      adminuser      => $adminuser,
      enable_io      => $enable_space_reporting,
      enable_dpm     => !$enable_domeadapter,
    }

    class{'dmlite::plugins::mysql::install':}

    class{'dmlite::plugins::adapter::config::head':
      token_password => $token_password,
      token_id       => $token_id,
      dpmhost        => $dpmhost,
      nshost         => $nshost,
      adminuser      => $adminuser,
      with_db_plugin => true,
    }
    class{'dmlite::plugins::adapter::install':}

    class{'dmlite::plugins::domeadapter::config::head':
      token_password => $token_password,
      token_id       => $token_id,
      empty_conf     => true,
    }

    class{'dmlite::plugins::domeadapter::install':
      uninstall      => true,
    }
  }


  if $enable_dome {
    if !$legacy {
      package{'dmlite-dpmhead':
        ensure => absent
      } ->
      package{'dmlite-dpmhead-domeonly':
        ensure => present
      }
      exec{'upgradedb350':
        command => "/bin/sh /usr/share/dmlite/dbscripts/upgrade/DPM_upgrade_mysql \"${mysql_host}\" \"${mysql_username}\" \"${mysql_password}\" \"${dpm_db}\" \"${ns_db}\"",
        require => [ Class['dmlite::db::dpm'], Class['dmlite::db::ns'], Package['dmlite-dpmhead-domeonly']]
      }
    } else {
      package{'dmlite-dpmhead-domeonly':
        ensure => absent
      }->
      package{'dmlite-dpmhead':
        ensure => present
      }
      exec{'upgradedb350':
        command => "/bin/sh /usr/share/dmlite/dbscripts/upgrade/DPM_upgrade_mysql \"${mysql_host}\" \"${mysql_username}\" \"${mysql_password}\" \"${dpm_db}\" \"${ns_db}\" ",
        require =>  [ Class['lcgdm'],  Package['dmlite-dpmhead']]
      }
    }
    if $enable_disknode {
      #install the metapackage for disk
      if !$legacy {
        package{'dmlite-dpmdisk':
          ensure => absent,
        }->
        package{'dmlite-dpmdisk-domeonly':
          ensure => present,
        }
      } else {
        package{'dmlite-dpmdisk-domeonly':
          ensure => absent,
        }->
        package{'dmlite-dpmdisk':
          ensure => present,
        }
      }
    }
    class{'dmlite::dome::config':
      dome_head                 => true,
      dome_disk                 => $enable_disknode,
      db_host                   => $mysql_host,
      db_user                   => $mysql_username,
      db_password               => $mysql_password,
      cnsdb_name                => $ns_db,
      dpmdb_name                => $dpm_db,
      headnode_domeurl          => "http://${dpmhost}:1094/domehead",
      restclient_cli_xrdhttpkey => $token_password,
      enable_ns_oidc            => $oidc_clientid != undef,
      ns_oidc_clientid          => $oidc_clientid,
      ns_oidc_allowissuer       => $oidc_allowissuer,
      ns_oidc_allowaudience     => $oidc_allowaudience,
    }
    class{'dmlite::dome::install':}
    if !$legacy {
      #need to configure xrootd first
      Class[dmlite::xrootd]
      ->
      dmlite::dpm::domain { $domain: }
      ->
      dmlite::dpm::vo { $volist:
        domain => $domain,
      }
    }
  }

}
