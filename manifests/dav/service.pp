class dmlite::dav::service (
  $dmlite_conf        = $dmlite::dav::dmlite_conf,
  $dmlite_disk_conf   = $dmlite::dav::dmlite_disk_conf,
  $ns_type            = $dmlite::dav::ns_type,
  $ns_prefix          = $dmlite::dav::ns_prefix,
  $disk_prefix        = $dmlite::dav::disk_prefix,
  $ns_flags           = $dmlite::dav::ns_flags,
  $ns_anon            = $dmlite::dav::ns_anon,
  $ns_max_replicas    = $dmlite::dav::ns_max_replicas,
  $ns_secure_redirect = $dmlite::dav::ns_secure_redirect,
  $ns_trusted_dns     = $dmlite::dav::ns_trusted_dns,
  $ns_macaroon_secret = $dmlite::dav::ns_macaroon_secret,
  $disk_flags         = $dmlite::dav::disk_flags,
  $disk_anon          = $dmlite::dav::disk_anon,
  $ssl_cert           = $dmlite::dav::ssl_cert,
  $ssl_key            = $dmlite::dav::ssl_key,
  $ssl_capath         = $dmlite::dav::ssl_capath,
  $ssl_options        = $dmlite::dav::ssl_options,
  $ssl_protocol       = $dmlite::dav::ssl_protocol,
  $ssl_ciphersuite    = $dmlite::dav::ssl_ciphersuite,
  $log_error          = $dmlite::dav::log_error,
  $log_transfer       = $dmlite::dav::log_transfer,
  $log_level          = $dmlite::dav::log_level,
  $user               = $dmlite::dav::user,
  $group              = $dmlite::dav::group,
  $coredump_dir       = $dmlite::dav::coredump_dir,
  $ulimit             = $dmlite::dav::ulimit,
  $enable_ns          = $dmlite::dav::enable_ns,
  $enable_disk        = $dmlite::dav::enable_disk,
  $enable_https       = $dmlite::dav::enable_https,
  $enable_http        = $dmlite::dav::enable_http,
  $enable_keep_alive  = $dmlite::dav::enable_keep_alive,
  $mpm_model          = $dmlite::dav::mpm_model,
  $enable_hdfs        = $dmlite::dav::enable_hdfs,
  $libdir             = $dmlite::dav::libdir,
  $dav_http_port      = $dmlite::dav::dav_http_port,
  $dav_https_port     = $dmlite::dav::dav_https_port,

  $enable_ns_oidc         = $dmlite::dav::enable_ns_oidc,
  $ns_oidc_scope          = $dmlite::dav::ns_oidc_scope,
  $ns_oidc_metadataurl    = $dmlite::dav::ns_oidc_metadataurl,
  $ns_oidc_clientid       = $dmlite::dav::ns_oidc_clientid,
  $ns_oidc_clientsecret   = $dmlite::dav::ns_oidc_clientsecret,
  $ns_oidc_passphrase     = $dmlite::dav::ns_oidc_passphrase,
  $ns_oidc_redirecturi    = $dmlite::dav::ns_oidc_redirecturi,
  $ns_oidc_auth_verify_jwks_uri = $dmlite::dav::params::ns_oidc_auth_verify_jwks_uri,

) {

  Class[dmlite::dav::config] ~> Class[dmlite::dav::service]

  case $dmlite::dav::config::ns_type  {
    'LFC': {
      $certfilename='lfccert.pem';
      $keyfilename='lfckey.pem'
    }
    default: {
      $certfilename='dpmcert.pem';
      $keyfilename='dpmkey.pem'
    }
  }

  $certificates_files = File[
      "/etc/grid-security/${dmlite::dav::config::user}/${certfilename}",
      "/etc/grid-security/${dmlite::dav::config::user}/${keyfilename}",
  ]

  service { 'httpd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [Class['dmlite::dav::config'], Class['dmlite::dav::install']],
    subscribe  => $certificates_files,
  }
}
