###########################################################################################################
## This is where you will setup all your variables for this to run. Everything must be filled out by you ##
###########################################################################################################
## Please specificy the root of either your TV or Movies direcotry."
## Examples:"
##   DO NOT INCLUDE A \ at end"
##   "C:\Media\TV Shows"
##   "192.168.1.10\movies"
##   UNC Paths are supported as well - Make sure you have write access!"
###########################################################################################################
## Make sure you have Handbrake and Handbrake-CLI install to C:\Program Files\HandBrake
## Please all of your drivers are up to date and if you're going to use QSV, make sure you have those video
##    drivers installed to the latest version.
###########################################################################################################
## If you are going to use your own profile, then make sure you call it "custom"
###########################################################################################################
###########################################################################################################


#--TV or Movies Directory?--#
$LibRoot = "M:"
#--net use M: "\\homeraid\HomeShare\Media\TV Shows"

#--Please type in the path of the profile you want to use--#
$preset = "C:\Users\Chris\Desktop\10bit-HEVC-QSV.json"

#--Sonarr/Radarr IP Address--#
$PVRIP = "192.168.1.11"

#--Sonarr/Radarr Port Number--#
$PVRPORT = "8989"

#--Sonarr/Radarr API Key--#
$PVRAPI = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"


#--Fetches list of files--#
$data = Get-ChildItem "$LibRoot" *.mkv -include *x264*, *h264*, *1080*, *AVC*, *.mkv*, *.mp4*, *.m4a* -Exclude *720*, *HEVC*, *x265*, *h265* -Recurse
$data | Sort-Object $_.directory.parent.name | Sort-Object $_.directory.name

#-- Processes each file in the list alphabetically--#
foreach($mkv in $data)
{
   $show    = $mkv.directory.parent.name
   $season  = $mkv.directory.name
   $episode = $mkv.basename
   $ext     = $mkv.extension
   $verif_input =  Test-Path   $("$LibRoot\$show\$season\$episode$ext")
   
   #--Verify if the file is actually there | This is needed for multiple computers working in the same directory--#
   If($verif_input -eq $true)
   {
       #--Rename the file to prevent other computers from processing the same file--#
       Rename-Item -Path "$LibRoot\$show\$season\$episode$ext" -NewName "$env:computername.$episode.$ext"
       
       #--Old Handbrake Conversion--#
       #--Handbrake the file with the proper name | You will need to specificy your preset to get this to work--#
       #--& "C:\Program Files\HandBrake\HandBrakeCLI.exe" --preset-import-file "$preset" -Z "custom" -i "$LibRoot$show\$season\$episode.$env:computername-1" -o "$LibRoot$show\$season\$episode.mkv"
       
       #--ffmpeg conversion
       & "C:\Encodarr\ffmpeg\bin\ffmpeg.exe" -hwaccel cuvid -i "$LibRoot\$show\$season\$env:computername.$episode.$ext" -pix_fmt p010le -c:v hevc_nvenc -preset slow -rc vbr_hq -b:v 6M -maxrate:v 10M -c:a aac -b:a 240k "$LibRoot\$show\$season\$episode.mp4"
       pause
       #--Removes the old (renamed) file--#
       Remove-Item "$LibRoot\$show\$season\$env:computername.$episode.$ext"
       
       #--Tells Sonarr or Radarr to rescan and organize the ENTIRE libarry | It waits 30 seconds to ensure that has been done--#
       $sonarr_series = Invoke-RestMethod -uri "http://${PVRIP}:${PVRPORT}/API/series?&apikey=$PVRAPI" -Method get
       $sonarr_seriesid =  $sonarr_series.id
           $params = @{"name"="RescanSeries";"seriesIds"=$sonarr_seriesid;} | ConvertTo-Json
           Invoke-RestMethod -Uri http://${PVRIP}:${PVRPORT}/api/command?apikey=$PVRAPI -Method POST -Body $params
           Start-Sleep -s 30
           $params = @{"name"="RenameSeries";"seriesIds"=$sonarr_seriesid;} | ConvertTo-Json
           Invoke-WebRequest -Uri http://${PVRIP}:${PVRPORT}/api/command?apikey=$PVRAPI -Method POST -Body $params
           Start-Sleep -s 30
        
        #--Rebuild the list of files | This can bet set to run indefinatly--#
        $data = Get-ChildItem "$LibRoot" *.mkv -include *x264*, *h264*, *1080*, *AVC*, *.mkv*, *.mp4*, *.m4a* -Exclude *720* *HEVC*, *x265*, *h265* -Recurse
        $data | Sort-Object $_.directory.parent.name | Sort-Object $_.directory.name
   }
}
