{ pkgs, lib,config, ... }:
{
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * *      root    curl https://hc-ping.com/3266303a-f07c-4168-952f-611c1f8da006"
    ];
  };
 
  # Taken from footvaalvica
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "1m"; # "30s"
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}" 
              "localhost:${toString config.services.prometheus.exporters.smartctl.port}" 
              "localhost:${toString config.services.prometheus.exporters.zfs.port}" 
            ];
          }
        ];
      }
    ];
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "systemd"
      ];
      openFirewall = true;
    };
    smartctl = {
      enable = true;
      port = 9101;
      openFirewall = true;
      devices = [ 
        "/dev/disk/by-path/pci-0000:00:14.0-usb-0:6.2:1.0-scsi-0:0:0:0"
        "/dev/disk/by-path/pci-0000:00:14.0-usb-0:6.3.1:1.0-scsi-0:0:0:0"
        "/dev/disk/by-path/pci-0000:00:14.0-usb-0:6.3.2:1.0-scsi-0:0:0:0"
        "/dev/disk/by-path/pci-0000:00:14.0-usb-0:6.3.3:1.0-scsi-0:0:0:0"
        #"/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX82D25FJ3SD"
        #"/dev/disk/by-id/usb-WDC_WD40_EFPX-68C6CN0_000000123AE8-0:0"
        #"/dev/disk/by-id/usb-ST6000NM_0115-1YZ110_000000123AE8-0:0"
        #"/dev/disk/by-id/usb-ST4000NM_0035-1V4107_000000123AE8-0:0"
      ];
    };
    zfs = {
      enable = true;
      port = 9102;
      openFirewall = true;
    };
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "0.0.0.0";
      http_port = 3000;
      root_url = "https://grafana.moniz.pt/";
      enable_gzip = true;
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
        }
      ];
    };
  };
}
