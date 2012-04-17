#!/usr/bin/perl

@cats = (502, 603);

for ($d = 0; $d < scalar(@cats); $d++)
{
# first determine category and base dir
  print "Category ".$cats[$d]."\n";
  $cat = $cats[$d];
  $baseDir = 'thefont';

# create  directory for the  font
  `mkdir -p $baseDir/cat$cat`;

# obtain all fonts
  getFonts ($cat);

# all characters (for now only latin standard)
  $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

  for ($i = 0; $i < length($alphabet); $i++)
  {
    $letter = substr($alphabet, $i, 1);
    print "\n    Rending letter $letter.. \n";
    `mkdir -p $baseDir/cat$cat/rendered/$letter`;
    render ($letter, "$baseDir/cat$cat/");

    # render the font
    print `octave ./theFont.m $baseDir/cat$cat/rendered $letter`
  }
}

die;



sub getFonts
{
  $nPage = 1;
  for (my $k = 0; $k < 545; $k++)
  {
    print "-- Loading fonts on page $nPage..\n";
    $curhref = "www.dafont.com/theme.php?cat=$cat&page=".$nPage;
    #print $curhref."\n";
    $curHTML = `curl -s \"$curhref\"`;
    $nextPage = $nPage+1;
   
    # also download links
    while ($curHTML =~ m/href=(.http...img.dafont.*?f=.*?)..nbsp.Download/gis)
    {
      #print "\n---found font: $1;\n\n";
      $fontURL = $1;
      $filename = $1;
      $filename =~ s/http.*f=//gis;
      $wgetCmd = "wget -q $fontURL -nc -O $baseDir/cat$cat/tmp.zip";
      print `$wgetCmd`;

      # and unpack
      $unzipCmd = "unzip -qq -o $baseDir/cat$cat/tmp.zip -d $baseDir/cat$cat 2>&1";
      `$unzipCmd`;
      $rmCmd = "rm $baseDir/cat$cat/tmp.zip";
      print `$rmCmd`;
    }


    # check if there is a link to the next page
    if ($curHTML =~ m/href..theme.php.cat=$cat.page=$nextPage/gis)
    {
      # next font
    }
    else
    {
      print "No more founds found, finished with page $nPage\n\n";
      return;
    }

    $nPage++;
  }

}





sub render
{
  $letter = $_[0];
  $dir = $_[1];

  opendir DIR,"$dir" or die "open failed : $!\n";

  for(readdir DIR)
  { 
      $count++;
      $filename = $_;
      $ftype = `file \"$dir/$filename\"`;
      if (($ftype =~ m/TrueType/) || ($ftype =~ m/OpenType/))
      {
	  # first trim the image
	  print `convert -pointsize 350 -trim -font \"$dir/$filename\" label:\"$letter\" \"$dir/rendered/$letter/$filename"."$letter.png\" 2>&1`;
	  # then force it to be 512x512
	  print `convert -resize 384x768^  \"$dir/rendered/$letter/$filename"."$letter.png\" /tmp/a.png 2>&1`;
	  # then scale canvas up to 1024x1024
	  print `cp /tmp/a.png \"$dir/rendered/$letter/$filename"."$letter.png\"`;
#	  `convert -gravity center -bordercolor white -border 2048x2048-crop 1024x1024+0+0 /tmp/a.png \"rendered/$letter/$filename"."$letter.png\"`;
      }
      print ".";
#      die if ($count ==5)
  }
}
