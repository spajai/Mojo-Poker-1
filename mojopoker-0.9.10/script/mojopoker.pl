#!/usr/bin/env perl

use strict;
use warnings;
use feature qw(say);
use lib '/opt/mojopoker/lib';
use Ships;
use EV;
use Mojo::Server::Daemon;
use POSIX qw(setsid);

# PRODUCTION MODE DEPRECATED
# Best practice is to use reverse proxy for production
# See nginx documentation

$ENV{MOJO_MODE} = 'production';
my @listen = ('http://*:3000');

my $daemon = Mojo::Server::Daemon->new(
    app                => Ships->new,
    listen             => [@listen],
    accepts            => 0,
    inactivity_timeout => 0,
);

# Fork and kill parent
die "Can't fork: $!" unless defined( my $pid = fork );
exit 0 if $pid;
POSIX::setsid or die "Can't start a new session: $!";

# pid file
open my $handle, '>', 'mojopoker.pid';
print $handle $$;
close $handle;

# Close filehandles
open STDIN,  '</dev/null';
open STDERR, '>&STDOUT';

$daemon->start;

open STDOUT, '>/dev/null';

EV::run;
