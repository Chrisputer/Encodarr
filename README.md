# Encodarr
Automated library encoder

Pre-Alpha Stage

What will it do? This app will locate all your non-x265 and non-vp9 encoded media and convert it to either x265 or vp9; one by one without needing additional user input. It will either replace or add to your library. If you have any PVRs that "manage" your media, then it will send API calls to it for updating, renaming and modification of show/movie settings.

But Why?

To reduce storage costs and enable high quality (direct) streaming over the WAN. I spend quite a bit of time on the road and I have to stream via WAN a lot. I also have a lot of friends and family that I share my Plex server with. With only 20mbps upload, I am/was having problem getting good quality video to stream.

Already having something that works via Handbrake-CLI and PowerShell (I will share shortly)

I'm trying to get better at Python and I got WAY too much time on my hands.

What Codecs? Initial release will support x264, x265, & VP9. I do not have plans to support AV1 yet because it is still very young and highly experimental.

What about hardware acceleration?

I will include hardware encoding where it is possible. For Example, VP9 HW Encoding is only supported on Intel Quick Sync with Kaby Lake or newer hardware, running on a special built Ubuntu 18.04 OS. IMHO, I still feel that this is the best codec to use. Its still up in the air on how I'm going to do this so that everyone can use it. Possibly a container with webGUI front-end. **** Looking for suggestions!! ****

x264 and x265 HW acceleration works pretty much everywhere.

FYI - I run a 7700K and use QSV x265 Main10 @ 4mbps. Quality look like a 12mbps x264 stream and encodes ~70fps. Those x265 encodes work extreamly well on devices that can direct stream/play over the WAN.
