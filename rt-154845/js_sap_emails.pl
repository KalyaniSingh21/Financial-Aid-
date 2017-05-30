#!/usr/bin/perl -w

use strict;
use warnings;
use AIS::Common;
use Date::Format;

=head1 Script Name

=head2 fin_xxxxx.pl

=cut

=head1 Documentation and Revision History

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! REPORT:   js_sap_emails.sql
!
! SCRIPT:   js_sap_emails.pl
!
! DESC:     This script creates a CSV file of students who have a locked
!           Eligibility Status record on ROASTAT for a given term.
! 
! INPUT:    
!
! OUTPUT:   
!
! KEYWORDS: 
!
! AUTHOR:  Janet van Weringh
!
! CREATED:  July 2011
!
! MODIFICATION HISTORY:
!
! 10-DEC-2012   MJT Converted to pdf_2_helios
! 13-JAN-2015   JWB RT:140965
!                   Rewrote the script for the updated request from the
!                   Financial Aid department.
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! --------------------------------------------------------------------

=cut

Set_Env();

my $data_dir = "$ENV{POT_DATA}/fin";
my $scripts_dir = "$ENV{POT_SCRIPTS}/fin";
my $script_name = 'js_sap_emails';
my $log_file = "$data_dir/logs/$script_name.log";
open( LOG_FILE, ">$log_file" );
open( STDERR,   ">>$log_file") || warn "Not able to open $log_file.  $!";
log_updt();

printw("Take parameters");
# my $term_code = $ARGV[0];
# my $aid_year = $ARGV[1];

my (
  $term_code,
  $aid_year
) = @ARGV;

if($term_code =~ /^js_/) {
    ($term_code,
     $aid_year
    ) = get_js_params($term_code);
}
printw("Done with parameters");
=begin
 else {
    printw("Enter the term code (e.g. 201602)");
    $term_code = <STDIN>;
    printw("Enter the aid year (e.g. 1617)");
    $aid_year = <STDIN>;
}
=cut

chomp($term_code);
chomp($aid_year);

my $timestamp = time2str('_%Y-%m-%d-%H%M%S', time);
my $sql_file = "$scripts_dir/$script_name.sql";
my $csv_file = "$data_dir/$script_name$timestamp.csv";

printw("try running sql command");

# The SQL file takes two parameters: Term Code and CSV File
my $cmd_sql = "sqlplus / @ $sql_file ". "$term_code $aid_year $csv_file";

printw($cmd_sql);
exec_cmd($cmd_sql);

printw("ran sql command");
if ( $? != 0 ) { croak($cmd_sql, $ENV{RUNUSER}, $0 ) && die "Croaked $!"; }
log_updt();



my $ftp_share = '/shares/finaid/reports/sap_emails';
my $ftp_file = "$data_dir/$script_name.ftp";
exec_cmd("unlink $ftp_file");
open(FTP_FILE, ">$ftp_file");
print FTP_FILE "cd $ftp_share \n";
print FTP_FILE "put $csv_file \n";
print FTP_FILE "quit \n";
close(FTP_FILE);
exec_cmd("ftp_2_helios $ftp_file");
log_updt();

close(LOG_FILE);
