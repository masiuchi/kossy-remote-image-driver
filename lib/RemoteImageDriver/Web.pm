package RemoteImageDriver::Web;

use strict;
use warnings;
use utf8;
use Kossy;

use File::Copy;
use File::Spec;
use File::Temp qw( tempdir );
use RemoteImageDriver::Imager;

our $CONTENT_TYPE_MAP = {

    # text
    txt => 'text/plain',
    xml => 'text/xml',
    css => 'text/css',
    csv => 'text/csv',
    js  => 'text/javascript',

    # image
    png  => 'image/png',
    jpeg => 'image/jpeg',
    gif  => 'image/gif',
    bmp  => 'image/bmp',

    # application
    swf => 'application/x-shockwave-flash',
    zip => 'application/zip',
    pdf => 'application/pdf',
};

my $temp_dir = tempdir();

sub upload_file {
    my $c = shift;

    my $file = $c->req->uploads->{file};
    my $filename = File::Spec->catfile( $temp_dir, $file->{filename} );
    move( $file->{tempname}, $filename );

    my ($suffix) = $file->filename =~ /\.([^\.]+)$/;
    $suffix = lc $suffix;
    $suffix = 'jpeg' if $suffix eq 'jpg';

    ( $filename, $suffix );
}

# Copy from Amon2::Plugin::Web::Raw.
sub render_raw {
    my ( $c, $type, $data ) = @_;
    my $res = $c->res;

    my $content_type = $CONTENT_TYPE_MAP->{$type};
    die sprintf( "unsupport raw type [%s]", $type ) unless $content_type;

    $res->content_type($content_type);
    $res->content($data);
    $res->content_length( length $data );

    return $res;
}

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c ) = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->( $self, $c );
        }
};

get '/' => [qw/set_title/] => sub {
    my ( $self, $c ) = @_;
    $c->render( 'index.tx', { greeting => "Hello" } );
};

post 'scale' => sub {
    my ( $self,     $c )      = @_;
    my ( $filename, $suffix ) = upload_file($c);

    my $width  = $c->req->param('width');
    my $height = $c->req->param('height');

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->scale( width => $width, height => $height );

    render_raw( $c, $suffix => $blob );
};

post 'crop_rectangle' => sub {
    my ( $self,     $c )      = @_;
    my ( $filename, $suffix ) = upload_file($c);

    my $left = $c->req->param('left') || 0;
    my $top  = $c->req->param('top')  || 0;
    my $width  = $c->req->param('width');
    my $height = $c->req->param('height');

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->crop_rectangle(
        left   => $left,
        top    => $top,
        width  => $width,
        height => $height,
    );

    render_raw( $c, $suffix => $blob );
};

post 'flip_horizontal' => sub {
    my ( $self,     $c )      = @_;
    my ( $filename, $suffix ) = upload_file($c);

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->flip_hozontal;

    render_raw( $c, $suffix => $blob );
};

post 'flip_vertical' => sub {
    my ( $self,     $c )      = @_;
    my ( $filename, $suffix ) = upload_file($c);

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->flip_vertical;

    render_raw( $c, $suffix => $blob );
};

post '/rotate' => sub {
    my ( $self,     $c )      = @_;
    my ( $filename, $suffix ) = upload_file($c);

    my $degrees = $c->req->param('degrees');
    $degrees %= 360;

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->rotate( degrees => $degrees );

    render_raw( $c, $suffix => $blob );
};

post 'convert' => sub {
    my ( $self,     $c )      = @_;
    my ( $filename, $suffix ) = upload_file($c);

    my $type = $c->req->param('type');

    my $driver = RemoteImageDriver::Imager->new( $filename, $suffix );
    my $blob = $driver->convert( type => $type );

    render_raw( $c, $type => $blob );
};

1;

