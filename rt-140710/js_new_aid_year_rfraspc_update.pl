#!/usr/bin/perl -w

=head1 js_new_aid_year_rfraspc_update.pl

=cut

=head1
AUTHOR:         Kalyani Singh (KS)

DATE:           2017-19-05

DESCRIPTION:    RT:140710
                PL file calling SQL file to update the amount of funds after
                ROPROLL is run.

                Check new_aid_year_rfraspc_update.sql for more details

PARAMETERS:     Previous Aid Year
                Next Aid Year

=cut

use strict;
use warnings;
use AIS::Common;
use Date::Format;

Set_Env();

my $data_path = "$ENV{POT_DATA}/fin";
my $script_path = "$ENV{POT_SCRIPTS}/fin";
my $script_name = 'js_new_aid_year_rfraspc_update.pl';
my $log_file = "${data_path}/logs/${script_name}.log";
my $timestamp = time2str('%Y-%m-%acd-%H%M%S', time); 

open (LOG_FILE, ">$log_file");
open (STDERR, ">>$log_file") || warn "not able to open $log_file $!";
log_updt();

my (
    $prev_aid_year,
    $next_aid_year
) = @ARGV;

# If this came from job submission, call get_js_params to get the parameters.
if ($prev_aid_year =~ /^js_/) {
	(
        $prev_aid_year,
        $next_aid_year
    ) =  get_js_params($prev_aid_year);
}
chomp($prev_aid_year);
chomp($next_aid_year);

my $sql_file_name = 'new_aid_year_rfraspc_update'; 
my $sql_file = "${script_path}/${sql_file_name}.sql";
my $report_file = 
    "${data_path}/${script_name}_${timestamp}_" . 
    "${prev_aid_year}_${next_aid_year}_$ENV{RUNUSER}.txt";
	
my $cmd = 
    "sqlplus / @/${sql_file} " .
    "${prev_aid_year} ${next_aid_year} ${report_file}";

exec_cmd($cmd);
if ($? != 0) {
    croak($cmd, $ENV{RUNUSER}, $0) && die "Croaked $!";
}

my $subject = 
    uc($script_name) . ' complete ' . 
    '(Updation of rfraspc records from ' . $prev_aid_year . 'to'. $next_aid_year . ')';

my @body = do {
    open my $fh, '<', $report_file or die "Could not open ${report_file} $!";
    <$fh>;
};
sendemail($ENV{RUNUSER}, $ENV{RUNUSER}, $subject, join('', @body));

log_updt();
close (LOG_FILE);
