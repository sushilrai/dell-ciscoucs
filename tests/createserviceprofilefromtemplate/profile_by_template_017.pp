include ciscoucs

import '../data.pp'

# As a user I want to create Service Profile from Template.

transport_ciscoucs { 'ciscoucs':
  username => "${ciscoucs['username']}",
  password => "${ciscoucs['password']}",
  server   => "${ciscoucs['server']}",
}


ciscoucs_serviceprofile { 'serviceprofile_name':
  #serviceprofile_name  => "${ciscoucs_serviceprofile['serviceprofile_name']}",
  #organization         => " ",
  profile_dn            => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  ensure                => "${ciscoucs_serviceprofile['ensure']}",
  source_template       => "${ciscoucs_serviceprofile['source_template']}",
  transport             => Transport_ciscoucs['ciscoucs'],
  number_of_profiles    => "${ciscoucs_serviceprofile['number_of_profiles']}",
}
