class dmlite::dome::config (
  Boolean $dome_head  = $dmlite::dome::params::head,
  Boolean $dome_disk  = $dmlite::dome::params::disk,
  $head_debug         = $dmlite::dome::params::head_debug,
  $disk_debug         = $dmlite::dome::params::disk_debug,
  $head_maxfilepulls  = $dmlite::dome::params::head_maxfilepulls,
  $head_maxfilepullspernode = $dmlite::dome::params::head_maxfilepullspernode,
  $head_checksum_maxtotal = $dmlite::dome::params::head_checksum_maxtotal,
  $head_checksum_maxpernode = $dmlite::dome::params::head_checksum_maxpernode,
  $db_host            = $dmlite::dome::params::db_host,
  $db_user            = $dmlite::dome::params::db_user,
  $db_password        = undef,
  $db_port            = $dmlite::dome::params::db_port,
  $db_pool_size       = $dmlite::dome::params::db_pool_size,
  $cnsdb_name         = $dmlite::dome::params::cnsdb_name,
  $dpmdb_name         = $dmlite::dome::params::dpmdb_name,
  $head_task_maxrunningtime = $dmlite::dome::params::head_task_maxrunningtime,
  $head_task_purgetime = $dmlite::dome::params::head_task_purgetime,
  $disk_task_maxrunningtime = $dmlite::dome::params::disk_task_maxrunningtime,
  $disk_task_purgetime = $dmlite::dome::params::disk_task_purgetime,
  $put_minfreespace_mb = $dmlite::dome::params::put_minfreespace_mb,
  $head_auth_authorizeDN = $dmlite::dome::params::head_auth_authorizeDN,
  $disk_auth_authorizeDN = $dmlite::dome::params::disk_auth_authorizeDN,
  $dirspacereportdepth = $dmlite::dome::params::dirspacereportdepth,
  $restclient_cli_certificate = $dmlite::dome::params::restclient_cli_certificate,
  $restclient_cli_private_key = $dmlite::dome::params::restclient_cli_private_key,
  $head_filepuller_stathook = $dmlite::dome::params::head_filepuller_stathook,
  $head_filepuller_stathooktimeout = $dmlite::dome::params::head_filepuller_stathooktimeout,
  $disk_filepuller_pullhook = $dmlite::dome::params::disk_filepuller_pullhook,
  $filepuller = undef,
  $headnode_domeurl = $dmlite::dome::params::headnode_domeurl,
  $proxy_timeout = $dmlite::dome::params::proxy_timeout,
  $restclient_cli_xrdhttpkey = $dmlite::dome::params::restclient_cli_xrdhttpkey,

  $enable_ns_oidc            = $dmlite::dome::params::enable_ns_oidc,
  $ns_oidc_clientid          = $dmlite::dome::params::ns_oidc_clientid,
  $ns_oidc_allowissuer   = $dmlite::dome::params::ns_oidc_allowissuer,
  $ns_oidc_allowaudience = $dmlite::dome::params::ns_oidc_allowaudience,

  $informer_urls         = $dmlite::dome::params::informer_urls,
  $informer_more         = $dmlite::dome::params::informer_more,
) inherits dmlite::dome::params {

  $domehead_template = 'dmlite/dome/domehead.conf.erb'
  $domedisk_template = 'dmlite/dome/domedisk.conf.erb'

  file {
    '/etc/httpd/conf.d/zdome.conf':
      ensure  => absent,
  }


  Class[dmlite::dome::install] -> Class[dmlite::dome::config]

  if $dome_head {
    file {
      '/etc/domehead.conf':
        ensure  => present,
        content => template($domehead_template),
        notify => Class[xrootd::service];
    }
  }

  if $dome_disk {
    file {
      '/etc/domedisk.conf':
        ensure  => present,
        content => template($domedisk_template),
        notify => Class[xrootd::service];
    }
  }

}
