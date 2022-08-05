#!/usr/bin/perl

##################################
# Magestic Management
# Written by Pavel Pavenskyy
# August 5, 2022
# 
# This is webserver made by perl 
#
#########################################################

use warnings;
use strict;

open(my $debug, '>>', '~/Code/perlProjetcs/Tests/testDebug.txt');

use HTTP::Server::Simple::CGI;
use File::stat;
use Time::localtime;
use File::Touch;



{ package WebServer; use base 'HTTP::Server::Simple::CGI';
   # import read_file and path_info
   use File::Slurp;
   my $nl = "\x0d\x0a";

   my $root = '.';
   if(@ARGV){
       $root = $_;
   }

   chdir($root);

#######################################################
#			Summary
# 			
#######################################################
sub printHeader {  

    my $contentType = $_;

    print "HTTP/1.0 200 OK$nl";
    print "Content-Type: $contentType; charset=utf-8$nl$nl";

} 
########################################################


########################################################
#			Summary
#
########################################################
sub serveFile {

    my($pathRelative, $contentType) = @_;

    printHeader($contentType);

    print STDOUT "serve_file: $pathRelative\n";

    if (-e $pathRelative) {
       print read_file($pathRelative, binmode => ":raw");
    }
    else {
       print "file $pathRelative not found"; 
    }

}
########################################################

########################################################
#		       Summary			       #
# This function delegates work with                    #
# files to others function, it uses		       #
# MIME type for parsing, furthermore		       #
# if there is, in a directory, the file		       #
# index.hmtl, it will parse it, otherwise - not        #
# (but at the moment it just throws from file all text #
# though)	        			       #
########################################################
sub handle_request {
    
    my($self, $cgi) = @_;

    my $path = $cgi -> path_info;

    if ($path eq '/') {
      if (-e 'index.html') {
        serveFile ("index.html", 'text/html');
      }      
      #else {
      print join "\n", glob('*');
	#}
      return;
    }

    if ($path =~ /\.htm$/  or $path =~ /\.html$/) {
      serveFile (".$path", 'text/html');
      return;
    }
    if ($path =~ /\.js$/ ) {
      serveFile (".$path", 'application/javascript');
      return;
    }
    if ($path =~ /\.txt$/) {
      serveFile (".$path", 'text/plain');
      return;
    }
    if ($path =~ /\.png$/) {
      serveFile (".$path", 'image/png');
      return;
    }
    if ($path =~ /\.jpg$/ or $path =~ /\.jpeg/) {
      serveFile (".$path", 'image/jpeg');
      return;
    }
    if ($path =~ /\.ico$/) {
      serveFile (".$path", 'image/x-icon');
      return;
    }

    print STDERR "Unknown Mime type for $path\n";

    serveFile( ".$path", 'text/plain');
   
}
}
####################################################


####################################################
#		MAIN FUNCTION			   #
####################################################

#print onto terminal
my $pid = WebServer -> new(2302) -> background;
print "pid of webserver=$pid\n";
