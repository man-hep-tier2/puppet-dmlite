class dmlite::lfc (
  Enum['mysql','oracle'] $dbflavor,
  String $dbuser,
  String $dbpass,
  Stdlib::Host $dbhost = 'localhost',
  Stdlib::Host $dpmhost = $facts['networking']['fqdn'],
  Stdlib::Host $nshost = $facts['networking']['fqdn'],
  Boolean $debuginfo = false,
) {
  # for the LFC, the token password is not used
  $token_password = 'gfgzmup)itecwhvjckp2nvvdcgNurywvhrbIhlfiwp8ctmmwbr'

  class{'dmlite::config::lfc':}
  class{'dmlite::install':
    debuginfo => $debuginfo
  }
  class{'dmlite::plugins::adapter::config::lfc':
    token_password => $token_password,
    dpmhost        => $dpmhost,
    nshost         => $nshost
  }
  class{'dmlite::plugins::adapter::install':}
}
