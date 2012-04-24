package WWW::Chargify::Tests::HTTP;

use v5.10.0;
use strict;
use base qw( WWW::Chargify::Tests::Base );
use Test::More;
use WWW::Chargify::HTTP;
use Data::Dumper;

sub test_helper_test_filter_string {
    my( $fixture, $testcase, $desc ) = @_;
    my $filter_string = WWW::Chargify::HTTP->filter_string( $testcase ); 
    diag(" $fixture neq $filter_string : hash => ".Dumper($testcase) )
      unless ok( $fixture eq $filter_string, " Testing $desc " );
}

sub test_filter_string : Test(11) {


  # The filter string method is pretty simple,
  #   It should take a hash_ref of key, value pairs, and
  #   transform them into a php encoded url string.

  # given: { a => b, c => [1,2,3] }
  # it should return 'a=b&c[]=1&c[]=2&c[]=3'

  my %tests = (

     '' => [
          'Empty case test.',
          {},
          'Hashs are ignored.',
          { a => {} },
          'Scalar refs are ignored.',
          { a => \'b' }
          ],
     'c[]=1&c[]=2&c[]=3&a=b' => [
             'One variable and an array', 
             { a => 'b', c => [ 1, 2, 3 ] },
             { c => [ 1, 2, 3 ], a => 'b' } 
          ],
      'a=b' => [ 'Simple varible', 
                 {a => 'b'},
                 'Hash overwites value.',
                 { a => 'e' , a => 'b' },
                 'Hash refs are ignored.',
                 { a => 'b', b => { a => 'b', b => 'c' } }
               ],
      'a=b&b=c' => [ 'Simple variable 2 values.', 
            { a => 'b', b => 'c' },
            { b => 'c', a => 'b' } ],
      'a=b&b=c&d[]=a&d[]=b' => { a => 'b', b => 'c', d => [ 'a', 'b' ] },
  );

  foreach my $test ( keys %tests ){
     my $testcase = $tests{ $test };
     my $description  = 'for <<'.$test.'>>';
     if( ref( $testcase ) eq 'ARRAY' ){
        my @testcases = @{ $testcase };
        foreach my $tc ( @testcases ){
           if( !ref( $tc ) ){
              $description = $tc;
              next;
           }
           test_helper_test_filter_string( $test, $tc, $description );
        }
     } else {
        test_helper_test_filter_string( $test, $testcase, $description );
     }
  }

}

#sub test_get_404 : Test { };

1;
