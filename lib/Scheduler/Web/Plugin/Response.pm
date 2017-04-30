package Scheduler::Web::Plugin::Response;
use strict;
use utf8;
use warnings;

use Amon2::Util ();

sub init {
    my ($class, $c, $conf) = @_;
    Amon2::Util::add_method($c, 'res_400_json', \&res_400_json) unless $c->can('res_400_json');    
    Amon2::Util::add_method($c, 'res_404_json', \&res_404_json) unless $c->can('res_404_json');    
}
sub res_400_json {_render_error_json($_[0], 400, 'Bad Request.')}
sub res_404_json {_render_error_json($_[0], 404, 'Not Found.'  )}
sub _render_error_json {
    my ($c, $code, $message) = @_;
    my $response = shift->render_json({status_code => $code, message => $message});
    $response->status($code);
    return $response;
};

1;
