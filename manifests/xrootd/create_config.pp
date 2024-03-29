define dmlite::xrootd::create_config (
  $filename = $title,
  $dmlite_conf = undef,
  $dpm_host = $fqdn,

  $xrootd_user = $xrootd::config::xrootd_user,
  $xrootd_group = $xrootd::config::xrootd_group,

  $configdir = $xrootd::config::configdir,

  # sets 'daemon.trace all' for ofs,xrd,cms,oss
  $xrd_debug = $xrootd::config::xrd_debug,

  $all_adminpath = $xrootd::config::all_adminpath,
  $all_pidpath = $xrootd::config::all_pidpath,
  # all.role for exec xrootd/cmsd
  $xrd_allrole = $xrootd::config::xrd_allrole,
  $cmsd_allrole = $xrootd::config::cmsd_allrole,
  $all_export = $xrootd::config::all_export,
  $all_manager = $xrootd::config::all_manager,
  $all_sitename = $xrootd::config::all_sitename,

  $xrootd_redirect = $xrootd::config::xrootd_redirect,
  $xrootd_export = $xrootd::config::xrootd_export,
  $xrootd_seclib = $xrootd::config::xrootd_seclib,
  $xrootd_async = $xrootd::config::xrootd_async,

  $xrd_port = $xrootd::config::xrd_port,
  $xrd_network = $xrootd::config::xrd_network,
  $xrd_report = $xrootd::config::xrd_report,
  $xrootd_monitor = $xrootd::config::xrootd_monitor,
  $xrootd_chksum = $xrootd::config::xrootd_chksum,
  $xrd_timeout = $xrootd::config::xrd_timeout,
  $ofs_authlib = $xrootd::config::ofs_authlib,
  $ofs_authorize = $xrootd::config::ofs_authorize,
  $ofs_persist = $xrootd::config::ofs_persist,
  # ofs.osslib for exec xrootd/cmsd
  $xrd_ofsosslib = $xrootd::config::xrd_ofsosslib,
  $cmsd_ofsosslib = $xrootd::config::cmsd_ofsosslib,
  $ofs_cmslib = $xrootd::config::ofs_cmslib,
  $ofs_forward = $xrootd::config::ofs_forward,
  $ofs_tpc = $xrootd::config::ofs_tpc,
  $xrd_ofsckslib = undef,
  $sec_protocol = $xrootd::config::sec_protocol,
  $sec_level = $xrootd::config::sec_level,

  $tls = $xrootd::config::tls,
  $tls_cert = $xrootd::config::tls_cert,
  $tls_key = $xrootd::config::tls_key,
  $tls_cafile = $xrootd::config::tls_cafile,
  $tls_capath = $xrootd::config::tls_capath,
  $tls_caopts = $xrootd::config::tls_caopts,
  $tls_ciphers = $xrootd::config::tls_ciphers,
  $tls_reuse = $xrootd::config::tls_reuse,

  $pss_origin = $xrootd::config::pss_origin,

  $dpm_listvoms = undef,
  $dpm_mmreqhost = undef,
  $dpm_defaultprefix = undef,
  $dpm_xrootd_serverport = undef,
  $dpm_enablecmsclient = undef,
  $dpm_namelib = undef,
  $dpm_replacementprefix = undef,

  $domainpath = undef,
  $alice_token = undef,
  $alice_token_conf = undef,
  $alice_token_principal = undef,
  $alice_token_libname = undef,
  $alice_fqans = undef,

  $dpm_xrootd_fedredirs = undef,
  $use_dmlite_io = false,
  $dpm_enable_dome = false,
  $dpm_xrdhttp_secret_key = undef,
  $dpm_dome_conf_file = undef,
  $dpm_xrdhttp_cipherlist = undef
) {
  include xrootd::config

  file { $filename:
    ensure  => file,
    owner   => $xrootd::config::xrootd_user,
    group   => $xrootd::config::xrootd_group,
    content => template($xrootd::config::configfile_template, 'dmlite/xrootd/dpm-xrootd.cfg.erb')
  }

}
