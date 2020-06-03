use strict;
use warnings;
use JSON;
use REST::Client;
use Data::Dumper;
use MIME::Base64;
use Config::Tiny;
use Net::Twitter;
use Number::Format;

#load config
my $config_file = ".keys";
die "$config_file is missing\n" if not -e $config_file;
my $config = Config::Tiny->read($config_file, 'utf8');

#setup Net::Twitter Client
my $nt = Net::Twitter->new(
    ssl      => 1,
    traits   => [qw/API::RESTv1_1/],
    consumer_key        => $config->{keys}{api_key},
    consumer_secret     => $config->{keys}{api_secret},
    access_token        => $config->{keys}{access_token},
    access_token_secret => $config->{keys}{access_token_secret},
);

sub getResult(){
    my $client = REST::Client->new();
    $client->setHost('https://coronavirus-tracker-api.herokuapp.com:443');
    $client->GET('/v2/latest');

    return from_json($client->responseContent());
}

#setup formater
my $nf = new Number::Format(-thousands_sep   => '.');

my $confirmed = $nf->format_number(getResult()->{'latest'}{'confirmed'});
my $deaths = $nf->format_number(getResult()->{'latest'}{'deaths'});
my $recovered = $nf->format_number(getResult()->{'latest'}{'recovered'});
my $current = $nf->format_number(getResult()->{'latest'}{'confirmed'}-getResult()->{'latest'}{'deaths'}-getResult()->{'latest'}{'recovered'});


#send tweet
print "$confirmed, $deaths, $recovered";
$nt->update("Currently $current people are infected. Globally $confirmed people got infected by the #corona virus, $deaths people died of #Covid_19 and $recovered people got recovered");