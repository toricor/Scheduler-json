package Scheduler::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Time::Piece;

get '/' => sub {
    my ($c) = @_;
    my $keyword = 'reverse';
    my $query   = $c->req->parameters->{order} // '';
    my $order = $keyword eq $query ? 1 : 0; #'/?order=reverse'
    my @schedules;
    unless ($order) {
        @schedules = $c->db->search('schedule', {}, { order_by => 'date DESC'});
    }else{
        @schedules = $c->db->search('schedule', {}, { order_by => 'date'});
    }
    #for my $sche (@schedules) {
    #    print STDERR $sche->title . "\n";
    #}  
    #
    #
    return $c->render('index.tx', { schedules => \@schedules });
};

get '/login/edit' => sub {
    my ($c) = @_;
    my @schedules = $c->db->search('schedule', {}, { order_by => 'date'});
    return $c->render('index_editable.tx', { schedules => \@schedules});
};

post '/post' => sub {
    my ($c) = @_;
    my $title = $c->req->parameters->{title};
    my $date  = $c->req->parameters->{date};
    my $date_epoch = Time::Piece->strptime($date, '%Y/%m/%d')->epoch;

    $c->db->insert(schedule => {
        title => $title,
        date  => $date_epoch,
    });
    
    return $c->redirect('/');

};

post '/schedules/update_title' => sub {
    my ($c, $args) = @_;
    my $id         = $c->req->parameters->{id};
    my $new_title  = $c->req->parameters->{new_title};

    my $row = $c->db->single('schedule', {id => $id});
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
