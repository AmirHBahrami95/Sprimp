#!/usr/bin/perl

=doc
the idea is to put different parts of java file in a hash so later on, it's easier to work with, then compare that hash's 
"already" (resembling already imported classes) and "big_guys" (CamelCased words) to exclude the already imported big_guy.
then import the not yet imported big_guys using a database connection to a sqlite3 file

and finally screw the whole thing together and print it some output file this script on it's own is not enough to import 
classes automatically and it doesn't handle package statement (altough it can) 

you need to call sprimp.sh script which utilizes this one to do the job (read the readme file when u git clone'd this thing)
=cut

use strict;
# use warnings;
use Set::Scalar;
use DBI;

# TODO add a second argument "database" to know which database to use
# then add support for plain java, and other pricks...

if ($#ARGV<0){
	print "usage: get_imports.pl <java-file-path>\n";
	exit 1;
}

# initializing
my $file=$ARGV[0];
my %result=get_imports($file); # parsing java file
my $db=db_init(get_setting("db_path"));
my @row=();

# getting packages of all unimported capital case words from db
foreach my $big_guy(@{$result{big_guys}}){
	if( contains(\@{$result{already}},$big_guy,1)){
		next;
	}
	@row=db_select_by_cname($db,$big_guy);
	if(@row){
		push(@{$result{new_imports}},"import $row[1].$row[0];");
	}
}

generate_swap_file($file,\%result);
# db->disconnect; # doesn't work for some reason (still, no problem, see perldocs)

# ============ SUBS
sub generate_swap_file{
	my ($filename)=$_[0];
	my (%result)=%{$_[1]};

	open(my ($out),"+>","$filename.imp")
	or die "cannot open .imp file:".$filename.".imp : $!";
	
	# ignore package statement and just solve it at sprimp.sh script
	# if(!contains(\@{$result{rest}}, $result{package_statement}){
		# print {$out} "$result{package_statement}\n\n";
	# }
	foreach my $already_import(@{$result{already_imports}}){
		if( !contains(\@{$result{rest}} , $already_import ) ){
			print {$out} "$already_import\n";	
		}
	}
	foreach my $new_import(@{$result{new_imports}}){
		print {$out} "$new_import\n";
	}
	foreach my $rest(@{$result{rest}}){
		if( !contains(\@{$result{already_imports}} , $rest ) ){
			print {$out} "$rest\n";
		}
	}

	close($out);
	return ;
}
sub get_imports{
	my ($filename)=$_[0];
	my (%result)=(
		# package_statement=>'',
		already=>[],
		already_imports=>[],
		big_guys=>Set::Scalar->new(),
		rest=>[],
		new_imports=>[] # used later (see @bigguy_import)
	);
	open(my ($in), '+<', $filename) 
	or die "failed to open file: ".$filename."\n";

	my ($tmp)="might come in handy, since this is fucking perl :)";
	my ($class_statement_reached)=0;

	# separation of inputs
	while(<$in>){
		chomp($_);
		if($_ =~ /^package\s*(.+)$/){ # just skip package statement for now (handled at sprimp.sh script)
			# $result{package_statement}=$_;
			next;
		}
		elsif($_ =~ /^import .+\.(\w+);$/
			&&!contains( \@{$result{already}})){ #import statements
			push( @{$result{already}}, $1);
			push( @{$result{already_imports}}, $_ );
			next;
		}
		while( $_ =~ /[\s@=(]*[^a-z]([A-Z]\w+)/g){  # handle multiple CamelCase words in a line
			print "$1\n";
			if( !contains(\@{$result{already}}, $1)){ # only starting with capital case, and not imported
				$result{big_guys}->insert($1);
			}
		}
		
		# skip empty lines before first class statement reached
		if( $_ =~ /public/){
			$class_statement_reached=1;
		}		
		if( !$class_statement_reached && $_ =~/^[\s]+$/ ){
			next; 
		}

		# happens anyways
		push(@{$result{rest}}, $_);
	}
	return %result;
}
# ============ DB
sub db_init{
	my ($db_path)=$_[0];
	return DBI->connect("dbi:SQLite:$db_path","","",{
		PrintError=>0,
		RaiseError=>1,
		AutoCommit=>1,
		# FetchHashKeyName=>'NAME_lc', # alles lower casei
	});
}
sub db_select_by_cname{
	my ($db)=$_[0];
	my ($cname)=$_[1];
	my ($st)=$db->prepare('SELECT * FROM full_class WHERE cname=?');
	$st->execute($cname);
	return $st->fetchrow_array;
}
# ============ ARRAY UTIL
sub contains{
	my (@array)=@{$_[0]};
	my ($element)=$_[1];
	if(@array && $#array<0){ # empty
		return 0;
	}
	foreach my $e(@array){
		if($e eq $element){
			return 1;
		}
	}
	return 0;
}
sub parr{	
	my ($arr)=$_[0];
	my ($prompt)="array: ";
	my ($delimiter)=" , ";
	if($#_ >=1){ $prompt=$_[1];}
	if($#_ >=2){ $delimiter=$_[2];}
	print "$prompt ".join($delimiter,@$arr)."\n";
	return ;
}
# ============ UTIL
sub get_setting{
	my ($setting)=$_[0]; # setting you're looking for
	my ($rgx)= "$setting:\\s*(.+)";
	open(my ($in),'<','settings.props');
	while(<$in>){
		if( $_ =~ qr/$rgx/){
			return $1;
		}
	}
	return ;
}
