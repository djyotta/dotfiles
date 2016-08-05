#!/usr/bin/perl

use strict;
use Net::LDAP;

# davmail is serving ldap on port 1389
# davmail will then forward the request to
# the MS Exchange server
use constant HOST => 'localhost:1389';
use constant BASE => 'ou=people';

{
	print "Searching database... ";
	# Make sure the output of this 
	# program is just a string with
	# no new line!
	my $user = `~/.mutt/ldap_user.sh`;
	my $password = `gpg -q --local-user --batch --decrypt ~/.msmtp/work.gpg`;
	my $first = shift || die "Usage: $0 first|last [last]\n";
	my $last = shift || "";
	my $filter;
	if ("$last" == '*'){
		$filter = "(|(sn=*$first*)(givenname=*$first*))";
	} else {
		$filter = "(&(cn=*$first*$last*)(|(givenname=*$first*)(sn=*$last*)))" ;
	}
	my $ldap = Net::LDAP->new( HOST, onerror => 'die' ) 
		|| die "Cannot connect: $@";
	$ldap->bind( dn => $user,
				 password => $password) or die "Cannot bind: $@";
	my $msg = $ldap->search( base => BASE,
							 filter => "$filter");
	my @entries = ();
	foreach my $entry ( $msg->entries() ) {
		push @entries, 
		{ email      => $entry->get_value( 'mail' ),
          first_name => $entry->get_value( 'givenname' ),
		  last_name  => $entry->get_value( 'sn' ) };
	}
	$ldap->unbind();
	print scalar @entries, " entries found.\n";
	foreach my $entry ( @entries ) {
    print "$entry->{email}\t$entry->{first_name} $entry->{last_name}\n";
	}
}
