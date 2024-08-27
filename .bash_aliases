rdp()
{
	xfreerdp /u:"$1" /v:"$2" /w:1920 /h:1080 /window-position:0x0 -grab-keyboard
}
