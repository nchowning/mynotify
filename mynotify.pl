use strict;
use warnings;
use DBI;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '0.1';
%IRSSI = (
	authors     => 'Nathan Chowning',
	contact     => 'nathanchowning@me.com',
	name        => 'mynotify',
	description => 'An irssi script that will pull notifications and drop them in a mysql database.',
	url         => 'http://www.nathanchowning.com/projects/mynotify',
	license     => 'GPL'
);

######
# Parts of this script are based on my irssi-prowl-notifier script which is based
# on fnotify created by Thorsten Leemhuis
# http://www.leemhuis.info/files/fnotify/
######

######
# Mysql configuration variables
######
my $database = "mynotify";
my $dbhost = "localhost";
my $dbusername = "testing";
my $dbpassword = "superpoop123";

######
# Private message parsing
######

sub private_msg {
	my ($server,$msg,$nick,$address,$target) = @_;
    # return unless $server->{usermode_away} eq 1;
    mysqlsend($nick,$msg);
}

######
# Sub to catch nick hilights
######

sub nick_hilight {
    my ($dest, $text, $stripped) = @_;
    if ($dest->{level} & MSGLEVEL_HILIGHT) {
	mysqlsend($dest->{target}, $stripped);
    }
}

######
# Send messages to mysql database
######

sub mysqlsend {
    my $dbh = DBI->connect("DBI:mysql:database=$database;host=$dbhost",
        $dbusername, $dbpassword,
        {'RaiseError' => 1});
    my $application = "irssi";
    my(@smessage) = @_;
    $dbh->do('INSERT INTO notifications VALUES(notifyid, ?, ?, ?, ?)', undef, $application, $smessage[0], $smessage[1], 0);
    $dbh->disconnect();
}

######
# Irssi::signal_add_last / Irssi::command_bind
######

Irssi::signal_add_last("message private", "private_msg");
Irssi::signal_add_last("print text", "nick_hilight");
