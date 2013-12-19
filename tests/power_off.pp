include ciscoucs

transport { 'ciscoucs':
  username => 'admin',
  password => 'admin',
  server   => '192.168.24.130',
}

ciscoucs_serviceprofile { 'name':
   name => 'test_123', 
  ensure    => absent,
  transport  => Transport['ciscoucs'],
}
