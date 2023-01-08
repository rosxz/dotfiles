{ config, pkgs, ... }:

# Figure out why this writeText aint doin shit (also how to force creation of dirs)

let
  configFile = pkgs.writeText "/var/lib/qBittorrent/config/qBittorrent.conf"
      ''
[AutoRun]
enabled=false
program=

[BitTorrent]
Session\Port=19307
Session\QueueingSystemEnabled=false

[Core]
AutoDeleteAddedTorrentFile=Never

[Meta]
MigrationVersion=3

[Network]
PortForwardingEnabled=false
Proxy\OnlyForTorrents=false

[Preferences]
Advanced\RecheckOnCompletion=false
Advanced\trackerPort=9000
Connection\ResolvePeerCountries=true
DynDNS\DomainName=changeme.dyndns.org
DynDNS\Enabled=false
DynDNS\Password=
DynDNS\Service=DynDNS
DynDNS\Username=
General\Locale=en
MailNotification\email=
MailNotification\enabled=false
MailNotification\password=
MailNotification\req_auth=true
MailNotification\req_ssl=false
MailNotification\sender=qBittorrent_notification@example.com
MailNotification\smtp_server=smtp.changeme.com
MailNotification\username=
WebUI\Address=100.*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelist=@Invalid()
WebUI\AuthSubnetWhitelistEnabled=false
WebUI\BanDuration=3600
WebUI\CSRFProtection=true
WebUI\ClickjackingProtection=true
WebUI\CustomHTTPHeaders=
WebUI\CustomHTTPHeadersEnabled=false
WebUI\HTTPS\CertificatePath=
WebUI\HTTPS\Enabled=false
WebUI\HTTPS\KeyPath=
WebUI\HostHeaderValidation=true
WebUI\LocalHostAuth=true
WebUI\MaxAuthenticationFailCount=5
WebUI\Password_PBKDF2="@ByteArray(OL/6FsKHc0pX9Ehu+U/9SA==:QLq3y7LTLfiEOuyQ0bb/7f3G/pC5HiL41LMhMWE28bFY7xyz5/CG7gdec3vnzDaF3seqJOB/oSO9jLS19TrDSQ==)"
WebUI\Port=8082
WebUI\ReverseProxySupportEnabled=false
WebUI\RootFolder=
WebUI\SecureCookie=true
WebUI\ServerDomains=*
WebUI\SessionTimeout=3600
WebUI\TrustedReverseProxiesList=
WebUI\UseUPnP=false
WebUI\Username=admin

[RSS]
AutoDownloader\DownloadRepacks=true
AutoDownloader\SmartEpisodeFilter=s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"
'';

in 

{
  environment.systemPackages = with pkgs; [
    qbittorrent-nox
  ];

  users.users.qbt = {
    group = "qbt";
    isSystemUser = true;
    extraGroups = [ "media" ];
  };
  users.groups.qbt = { };

  systemd.services.qbittorrent = {
    description = "QBittorrent-nox service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      User = "qbt";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --profile=/var/lib";
      Restart = "always";
      # uncomment this for versions of qBittorrent < 4.2.0 to set the maximum number of open files to unlimited
      # LimitNOFILE=infinity 
    };
  };
}
