import sdk
mgr = sdk.dsm.Manager(hostname="localhost", username=$(cat /var/plexity/dsm.script.user), password=$(cat /var/plexity/dsm.script.password), ignore_ssl_validation=True)
mgr.sign_in()
mgr.computers.get()
for computer_id in mgr.computers.find(overall_status='Unmanaged.*'):
  computer = mgr.computers[computer_id]
  print "\t{}\t{}".format(computer.name, computer.overall_status)
mgr.sign_out()
