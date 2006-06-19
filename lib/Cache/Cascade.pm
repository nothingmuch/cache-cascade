#!/usr/bin/perl

package Cache::Cascade;
use Moose;

use Carp qw/croak/;

has caches => (
	isa => "ArrayRef",
	is  => "rw",
);

has float_hits => (
	isa => "Bool",
	is  => "rw",
	default => 0,
);

has set_deep => (
	isa => "Bool",
	is  => "rw",
	default => 1,
);

sub get {
	my ( $self, $key ) = @_;

	if ( $self->float_hits ) {
		$self->get_and_float_result( $key, @{ $self->caches } );
	} else {
		foreach my $cache ( @{ $self->caches } ) {
			if ( defined( my $res = $cache->get($key) ) ) {
				return $res;
			}
		}

		return;
	}
}

sub get_and_float_result {
	my ( $self, $key, $head, @tail ) = @_;
	$head || return;

	if ( my $res = $head->get($key) ) {
		return $res;
	} elsif ( @tail ) {
		if ( my $res = $self->get_and_float_result( $key, @tail ) ) {
			$head->set( $key, $res );
			return $res;
		}
	}

	return;
}

sub remove {
	my ( $self, $key ) = @_;
	$_->remove($key) for @{ $self->caches };
}

sub set {
	my ( $self, $key, $value ) = @_;

	if ( $self->set_deep ) {
		$_->set($key, $value) for @{ $self->caches };
	} else {
		$self->caches->[0]->set($key, $value);
	}
}


__PACKAGE__;

__END__

=pod

=head1 NAME

Cache::Cascade - Get/set values to/from a group of caches, with some advanced
semantics.

=head1 SYNOPSIS

	use Cache::Cascade;

	Cache::Cascade->new(
		caches => [
			Cache::MemoryCache->new(...),
			Cache::FastMmap->new(...),
			Cache::Memcached->new(...),
		],
		float_hits => 1,
		set_deep   => 1,
	);

=head1 DESCRIPTION

In a multiprocess, and especially a multiserver application caching is a very
effective means of improving results.

The tradeoff with improving the scale of the caching is in added complexity.
For example, caching in a FastMmap based storage is much slower than using a
memory based cache, because pages must be locked to ensure that no corruption
will happen. Likewise Memcached is even more overhead than FastMmap because it
is network bound, and uses blocking IO (on the client side).

This module attempts to make a transparent cascade of caches based on several
backends.

The idea is to search from the cheapest backend to the most expensive, and
depending on the options also cache results in the chepear backends.

The benefita of using a cascade are that if the chance of a hit is much higher
in a slow cache, but checking a cheap cache is negligiable in comparison, we
may alreayd have the result we want in the cheap cache. Configure your
expriation policy so that there is approximately an order of magnitude better
probability of cache hits (bigger cache) for each level of the cascade.

=item FIELDS

=over 4

=item set_deep

Defaults to true. See C<set>.

=item float_hits

Defaults to false. See C<get>.

=back

=head1 OVERRIDDEN METHODS

=over 4

=item get $key

This method will delegate C<get> to every cache object in order, and return the first match.

Additionally, if C<float_hits> is set to a true value, it will also call C<set>
with the match on every cache object before the one that matched.

=item set $key, $value

If C<set_deep> is set to a true value this method will delegate C<set> to every
cache object in the list.

If C<set_deep> is set to a false value this method will delegate C<set> just to
the first cache object in the list.

=item remove $key

This method will delegate C<remove> on every cache object in the list.

=back

=head1 METHODS

=item

=item get_and_float_result $key, @caches

This is used to implement the C<float_hits> behavior of C<get> recursively.

=back

=head1 CAVEATS

When you set or remove a key from the cascade and this propagates downards, for
example from MemoryCache to FastMmap, other cascades will not notice the change
until their own MemoryCache is expired.

Thus, if cache invalidation is important in your algorithm (data changes) do
not use a cascade. If stale hits are permitted, or the cache is for non
changing data then you should use a cascade.

=cut


