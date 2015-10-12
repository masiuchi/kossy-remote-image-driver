package RemoteImageDriver::Imager;
use strict;
use warnings;

use Imager;

sub new {
    my ( $class, $file, $suffix ) = @_;
    my $imager = Imager->new;
    $imager->read( file => $file );
    bless {
        file   => $file,
        type   => $suffix,
        imager => $imager,
    }, $class;
}

sub blob {
    my ( $self, %param ) = @_;
    my $type = $param{type} || $self->{type};
    my $blob;
    $self->{imager}->write( data => \$blob, type => $type );
    $blob;
}

sub scale {
    my ( $self, %param ) = @_;
    return if !$param{width} || !$param{height};
    $self->{imager} = $self->{imager}->scale(
        xpixels => $param{width},
        ypixels => $param{height},
        type    => 'nonprop',
    );
    $self->blob;
}

sub crop_rectangle {
    my ( $self, %param ) = @_;

    $param{left} ||= 0;
    $param{top}  ||= 0;
    return if !$param{width} || !$param{height};

    $self->{imager} = $self->{imager}->crop(
        left   => $param{left},
        top    => $param{top},
        width  => $param{width},
        height => $param{height},
    );

    $self->blob;
}

sub flip_horizontal {
    my $self = shift;
    $self->{imager}->flip( dir => 'h' );
    $self->blob;
}

sub flip_vertical {
    my $self = shift;
    $self->{imager}->flip( dir => 'v' );
    $self->blob;
}

sub rotate {
    my ( $self, %param ) = @_;
    my $degrees = $param{degrees} or return;
    $degrees %= 360;
    $self->{imager} = $self->{imager}->rotate( right => $degrees );
    $self->blob;
}

sub convert {
    my ( $self, %param ) = @_;
    my $type = $param{type} or return;
    $self->blog( type => $type );
}

1;



1;

