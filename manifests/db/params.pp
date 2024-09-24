class dmlite::db::params ()  inherits dmlite::db {
  $host     = $facts['networking']['fqdn']
  $nshost   = $facts['networking']['fqdn']
  $dbflavor = 'mysql'
  $dbhost   = 'localhost'
  $dpm_db   = 'dpm_db'
  $ns_db    = 'cns_db'
  $dbmanage = true
  $active   = 'yes'
}
