# Time zone and NTP configurations. 
{ config, ... }: {
  time.timeZone = "Asia/Oral";            # Set time zone to Asia/Oral (+5 GMT).
  services.ntp.enable = true;             # Use NTP for time correction.
}
