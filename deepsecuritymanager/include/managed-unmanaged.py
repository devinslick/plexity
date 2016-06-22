module import *

mgr = deepsecurity.dsm.Manager(hostname="localhost", username="datareader", password="abc123abc", ignore_ssl_validation=True)
mgr.sign_in()
mgr.computers.get()

print "Managed:"
for computer_id in mgr.computers.find(overall_status='Managed.*'):
  computer = mgr.computers[computer_id]
  print "\t{}\t{}".format(computer.name, computer.overall_status)

print "Unmanaged:"
for computer_id in mgr.computers.find(overall_status='Unmanaged.*'):
  computer = mgr.computers[computer_id]
  print "\t{}\t{}".format(computer.name, computer.overall_status)

mgr.sign_out()

