Geocode and reverse geocode netherland addresses and latitudes longitudes

github
https://tinyurl.com/yd9c7l94
https://github.com/rogerjdeangelis/utl_geocode_and_reverse_geocode_netherland_addresses_and_latitudes_longitudes

Google allows up to 2,500 queries per day. However, you are at the whim with Google
and Google seems to be more restrictive lately (dropped URL shortener).

  Solutions
      1. Address to Latitude Longitude
      2. Latitude and Logitude to Address

INPUT
=====

 SD1.havAdr total obs=2

                       ADR

   Ndustriestraat 14, 1704 AA Heerhugowaard, Netherlands
   Edisonweg 7, 1446 TM Purmerend, Netherlands

 SD1.havLatLon total obs=2

    LON        LAT

  4.946354 52.50997
  4.999136 52.51512

EXAMPLE OUTPUT
--------------

  1. Latittude and Longitude as input

                        ADDRESS

      Edisonweg 17, 1446 TM Purmerend, Netherlands
      Kaasmarkt 20, 1441 BG Purmerend, Netherlands


      STREET_                              ADMINISTRATIVE_    ADMINISTRATIVE_                   POSTAL_
       NUMBER      ROUTE      LOCALITY      AREA_LEVEL_2       AREA_LEVEL_1        COUNTRY       CODE

         17      Edisonweg    Purmerend       Purmerend        Noord-Holland     Netherlands    1446 TM
         20      Kaasmarkt    Purmerend       Purmerend        Noord-Holland     Netherlands    1441 BG


   2. Address as input

        LON        LAT

      4.94635    52.5100
      4.99914    52.5151


PROCESS
=======

 1. Address to Latitude Longitude

    proc datasets lib=work;
       delete want;
    run;quit;
    %utlfkil(d:/rda/work.Rdata);

    %utl_submit_r64('
    library(haven);
    library("ggmap");
    have<-read_sas("d:/sd1/havadr.sas7bdat");
    lonlat_sample <- c(NA,NA);
    for ( i in 1:2) {
      Sys.sleep(1);
      lonlat_sample <- rbind(lonlat_sample, as.numeric(geocode(have$ADR[i])));
    };
    want<-as.data.frame(lonlat_sample)[2:3,];
    colnames(want)<-c("lon","lat");
    want;
    save.image("d:/rda/work.Rdata");
    ');

    * create sas dataset from R dataframe;
    proc iml;
      submit / R;
      load("d:/rda/work.Rdata");
      want;
      endsubmit;
      run importdatasetfromr("work.want","want");
    run;quit;

    proc print data=work.want;
    run;quit;

    Obs      LON        LAT

    1     4.94635    52.5100
    2     4.99914    52.5151

 2. Latitude and Logitude to Address

    proc datasets lib=work;
       delete want;
    run;quit;
    %utlfkil(d:/rda/work.Rdata);

%utl_submit_r64('
library(haven);
library(ggmap);
lonlat_sample<-as.data.frame(read_sas("d:/sd1/havlonlat.sas7bdat"));
lonlat_sample[1,];
lonlat_sample[2,];
wantadr<-data.frame();
for (i in c(1,2)) {
   wantadr <- rbind(wantadr,revgeocode(as.numeric(lonlat_sample[i,]), output="more"));
};
wantadr;
save.image("d:/rda/work.Rdata");
');

* create sas dataset from R dataframe;
proc iml;
  submit / R;
  load("d:/rda/work.Rdata");
  want;
  endsubmit;
  run importdatasetfromr("work.wantadr","wantadr");
run;quit;

proc print data=work.wantadr;
run;quit;

OUTPUT


OUTPUT
======
   1. Latittude and Longitude as input

                        ADDRESS

      Edisonweg 17, 1446 TM Purmerend, Netherlands
      Kaasmarkt 20, 1441 BG Purmerend, Netherlands


      STREET_                              ADMINISTRATIVE_    ADMINISTRATIVE_                   POSTAL_
       NUMBER      ROUTE      LOCALITY      AREA_LEVEL_2       AREA_LEVEL_1        COUNTRY       CODE

         17      Edisonweg    Purmerend       Purmerend        Noord-Holland     Netherlands    1446 TM
         20      Kaasmarkt    Purmerend       Purmerend        Noord-Holland     Netherlands    1441 BG

   2. Address as input

        LON        LAT

      4.94635    52.5100
      4.99914    52.5151

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.havLonLat;
input lon lat;
cards4;
4.946354 52.50997
4.999136 52.51512
;;;;
run;quit;

data sd1.havAdr;
  length adr $60;
  input;
  adr=_infile_;
cards4;
Edisonweg 23, 1446 TM Purmerend, Netherlands
Kaasmarkt 20, 1441 BG Purmerend, Netherlands
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see process


