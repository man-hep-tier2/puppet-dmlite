# EGI StaR accounting - https://wiki.egi.eu/wiki/APEL/Storage
# For publishing data in the EGI it is necessary to create
# eu.egi.storage.accounting service for DPM headnode in GOCDB
# (https://goc.egi.eu) with "Host DN" set to certificate subject
# Usage:
#   class { '::dmlite::accounting':
#     site_name => 'praguelcg2',
#   }
class dmlite::accounting (
  Boolean $enabled = hiera('dmlite::accounting::enabled',true),
  String $cron_interval = hiera('dmlite::accounting::cron_interval','daily'),
  Optional[Stdlib::Host] $broker_host = hiera('dmlite::accounting::broker_host','msg.argo.grnet.gr'),
  Optional[Stdlib::Port] $broker_port = hiera('dmlite::accounting::broker_port',443),
  Optional[Stdlib::Port] $broker_auth_port = hiera('dmlite::accounting::broker_auth_port',8443),
  Optional[Stdlib::Unixpath] $certificate = hiera('dmlite::accounting::certificate','/etc/grid-security/dpmmgr/dpmcert.pem'),
  Optional[Stdlib::Unixpath] $key = hiera('dmlite::accounting::key','/etc/grid-security/dpmmgr/dpmkey.pem'),
  Optional[Stdlib::Unixpath] $capath = hiera('dmlite::accounting::capath','/etc/grid-security/certificates'),

  String $site_name = hiera('dmlite::accounting::site_name',''),

  Stdlib::Unixpath $nsconfig = hiera('dmlite::accounting::nsconfig','/usr/etc/NSCONFIG'),

  Stdlib::Host $dbhost = hiera('dmlite::accounting::dbhost','localhost'),
  String $dbuser = hiera('dmlite::accounting::dbuser',''),
  String $dbpwd = hiera('dmlite::accounting::dbpwd',''),
  String $nsdbname = hiera('dmlite::accounting::nsdbname','cns_db'),
  String $dpmdbname = hiera('dmlite::accounting::dpmdbname','dpm_db'),

) {

  if $site_name == '' {
    fail("'site_name' not defined")
  }

  # do not break in case the new parameters are not defined
  if $dbuser == '' {
    $cron_content = inline_template('/usr/share/dmlite/StAR-accounting/star-accounting.py --reportgroups --nsconfig=<%= @nsconfig %> --site=<%= @site_name %> --ams-host=<%= @broker_host %> --ams-port=<%= @broker_port %> --ams-auth-port=<%= @broker_auth_port %> --cert=<%= @certificate %> --key=<%= @key %> --capath=<%= @capath %>')
  } else {
    $cron_content = inline_template('/usr/share/dmlite/StAR-accounting/star-accounting.py --reportgroups --dbhost=<%= @dbhost %> --dbuser=<%= @dbuser %> --dbpwd=<%= @dbpwd %> --nsdbname=<%= @nsdbname %> --dpmdbname=<%= @dpmdbname %> --site=<%= @site_name %> --ams-host=<%= @broker_host %> --ams-port=<%= @broker_port %> --ams-auth-port=<%= @broker_auth_port %> --cert=<%= @certificate %> --key=<%= @key %> --capath=<%= @capath %>')
  }

  # remove legacy cron file
  file {"/etc/cron.${cron_interval}/dmlite-StAR-accounting":
    ensure  => absent,
  }

  # daily cron for publishing APEL storage accounting
  cron { 'dmlite-star-accounting':
    ensure  => $enabled ? {
      true  => present,
      false => absent,
    },
    command => $cron_content,
    user    => 'root',
    hour    => '2',
    minute  => '22',
    require => Package['dmlite-shell'];
  }

}
