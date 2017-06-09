#!/usr/bin/perl -w

=head1 origination.pl

=cut

=head1
AUTHOR:         Jeremy Bristol (JWB)

DATE:           2016-06-07

DESCRIPTION:    RT:144898
                This script runs these jobs for the origination process:
                RLPDLOC
                RPPSPGM
                REREX18
                These jobs generate a total of 9 files, as indicated in
                the @output_files array below.

                It will timestamp and send the LIS and LOG files to:
                /finaid/at_night/
                It will timestamp and send the XML file to:
                /finaid/Exp-Data/DL-send/

                For all of these jobs, the steps to run them are as follows:
                1. Insert the parameters into the GJBPRUN table.
                2. Execute the $BANNER_LINKS shell script.
                3. If necessary, copy output files where they need to go.

PARAMETERS:     None (for now, may add in Aid Year later)

MODIFICATION HISTORY : KS 09-JUN-2017 Add new parameter $aid_year_substr that chops first 2 numbers from $aid_year
                                      Add $aid_year_substr to rerex and crdl files because new files are called
                                      according to aid year
=cut

use strict;
use warnings;
use AIS::Common;
use Date::Format;
use Env;

Set_Env();

my $data_path = "$ENV{POT_DATA}/fin";
my $log_path = "$ENV{POT_DATA}/fin/logs";
my $script_path = "$ENV{POT_SCRIPTS}/fin";
my $log_file = "${data_path}/logs/origination.log";
my $ftp_file = "${data_path}/logs/origination.ftp";
my $timestamp = time2str('%Y-%m-%d-%H%M%S', time);
my $ftp_share_lis_log = '/shares/finaid/at_night';
my $ftp_share_xml = '/shares/finaid/Exp-Data/DL-send';

open (LOG_FILE, ">$log_file");
open (STDERR, ">>$log_file") || warn "not able to open $log_file $!";
log_updt();

# Set the environment variables for running the baseline jobs.

# Before setting HOME, we need to save the old value. The reason for this
# is that the user home variable contains the SSH keys for SFTP.
# If you don't do this, then ftp_2_helios will not work.
my $home = $ENV{'HOME'};

$ENV{'DATA_HOME'} = $data_path;
$ENV{'HOME'} = $data_path;
$ENV{'BANUID'}='pellcod';
$ENV{'PSWD'}='i8bamb';
my $aid_year = '1718';
my $one_up_no = '42';

my $aid_year_substr = substr $aid_year, 2, 2; # KS 09-JUN-2017 new parameter added

$ENV{'ONE_UP'}= $one_up_no;

# Create an array of the output file names.:
my @output_files = (
    "rlpdloc_${one_up_no}.log",
    "rlpdloc_${one_up_no}.lis",
    "rppspgm_${one_up_no}.log",
    "rppspgm_${one_up_no}.lis",
    "rerex".$aid_year_substr."_".${one_up_no}.".log", # KS 09-JUN-2017 new parameter added, was rerex17_${one_up_no}.log
    "rerex".$aid_year_substr."_".${one_up_no}.".lis", # KS 09-JUN-2017 new parameter added, was rerex17_${one_up_no}.lis
    "rerexim_${one_up_no}.log",
    "rerexim_${one_up_no}.lis",
    "crdl".$aid_year_substr."in_".${one_up_no}.".xml" # KS 09-JUN-2017 new parameter added, was crdl17in_${one_up_no}.log
);

# Delete the output files
foreach my $output_file (@output_files) {
    exec_cmd("unlink ${data_path}/${output_file}");
}

# Set up templates for the commands.
my $sqlplus_template =
    "sqlplus / @" . $script_path .
    "/insert-[job]-params ${aid_year} ${one_up_no}";
my $bash_template =
    "sh $ENV{BANNER_LINKS}/[job].shl";
my $sqlplus_cmd = '';
my $bash_cmd = '';

# RLPDLOC:
$ENV{'PROG'}='RLPDLOC';
$sqlplus_cmd = $sqlplus_template;
$sqlplus_cmd =~ s/\[job\]/rlpdloc/g;
$bash_cmd = $bash_template;
$bash_cmd =~ s/\[job\]/rlpdloc/g;
print "$ENV{'PROG'} \n";
print "$sqlplus_cmd \n";
print "$bash_cmd \n";
exec_cmd($sqlplus_cmd);
exec_cmd($bash_cmd);

# RPPSPGM:
$ENV{'PROG'}='RPPSPGM';
$sqlplus_cmd = $sqlplus_template;
$sqlplus_cmd =~ s/\[job\]/rppspgm/g;
$bash_cmd = $bash_template;
$bash_cmd =~ s/\[job\]/rppspgm/g;
print "$ENV{'PROG'} \n";
print "$sqlplus_cmd \n";
print "$bash_cmd \n";
exec_cmd($sqlplus_cmd);
exec_cmd($bash_cmd);

# "REREX$aid_year_substr":
$ENV{'PROG'}="REREX$aid_year_substr";   # KS 09-JUN-2017 new parameter added, was 'REREX17'
$sqlplus_cmd = $sqlplus_template;
$sqlplus_cmd =~ s/\[job\]/"rerex$aid_year_substr"/g;  # KS 09-JUN-2017 new parameter added, was s/\[job\]/"rerex17"/g
$bash_cmd = $bash_template;
$bash_cmd =~ s/\[job\]/"rerex$aid_year_substr"/g;  # KS 09-JUN-2017 new parameter added, was s/\[job\]/rerex17/g
print "$ENV{'PROG'} \n";
print "$sqlplus_cmd \n";
print "$bash_cmd \n";
exec_cmd($sqlplus_cmd);
exec_cmd($bash_cmd);

# Reset the HOME variable before doing the file transfer.
$ENV{'HOME'} = $home;

# Copy the files to Helios.
# Since we know the XML file is the last one in the list,
# we can switch to the XML directory once we reach that file.
exec_cmd("unlink $ftp_file");
open( FTP_FILE, ">$ftp_file" );
print FTP_FILE "cd $ftp_share_lis_log \n";
foreach my $output_file (@output_files) {
    if (substr($output_file, -3) eq 'xml') {
        print FTP_FILE "cd $ftp_share_xml \n";
    }
    print FTP_FILE "put ${data_path}/${output_file} ${timestamp}_${output_file} \n";
}
print FTP_FILE "quit \n";
close(FTP_FILE);
exec_cmd("ftp_2_helios $ftp_file");
