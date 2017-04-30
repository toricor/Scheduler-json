package Scheduler::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Time::Piece;
use DDP;

get '/' => sub {
    my ($c) = @_;
    my @schedules = $c->db->search('schedule', {}, { order_by => 'date'});
    return $c->render_json([ 
        map {
            +{
                 id    => $_->id,
                 title => $_->title,
                 date  => $_->date->ymd,
             }
         } @schedules
       ]
    );
};

get '/item/:item_id' => sub {
     my ($c, $args) = @_;
     my $item_id = $args->{item_id};
     my $row = $c->db->single('schedule', { id => $item_id});
     return $c->render_json({
         id    => $item_id,
         title => $row->title,
         date  => $row->date->ymd,
     });
};

post '/post' => sub {
    my ($c) = @_;
    
    $c->db->insert(schedule => {
        title => $c->req->parameters->{title},
        date  => $c->req->parameters->{date},
    });
    
    return $c->redirect('/');

};

post '/schedules/update_title' => sub {
    my ($c, $args) = @_;
    my $id         = $c->req->parameters->{id};
    my $new_title  = $c->req->parameters->{new_title};

    $c->db->update('schedule', {'title' => $new_title},{'id' => $id});
    return $c->redirect('/login/edit');
};

post '/schedules/delete' => sub {
    my ($c, $args) = @_;
    my $id = $c->req->parameters->{id};

    $c->db->delete('schedule' => { id => $id});
    return $c->redirect('/');
};

1;
