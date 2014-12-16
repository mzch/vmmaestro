#! /usr/bin/awk

BEGIN {
  DISKS    = 0;
  NICS     = 0;
  CSECTION = "";
}

/^[ \ta-zA-Z0-9_-+!@$%^&\\\/.:]+/ {
  pos   = index($0, "=");
  if (pos > 0)
  {
	left  = substr($0, 1, pos - 1);
	right = substr($0, pos + 1, length($0) - pos);
	gsub("^[ \t]+" ,"", left);
	gsub("[ \t]+$" ,"", left);
	gsub("^[ \t]+" ,"", right);
	gsub("[ \t]+$" ,"", right);
	left = tolower(left);
	if (match(CSECTION, "disk") > 0)
	{
	  left = sprintf("%s[%d]", left, DISKS);
	}
	if (match(CSECTION, "network") > 0)
	{
	  left = sprintf("%s[%d]", left, NICS);
	}
	printf ("%s_%s=%s\n", CSECTION, left, right);
  }
}

/^[ \t]*\[[a-zA-Z0-9_-+!@$%^&\\\/.:]+/ {
  gsub("^[ \t]+" ,"", $1);
  gsub("[ \t]+$" ,"", $1);
  gsub("^\[" ,"", $1);
  gsub("\]$" ,"", $1);
  CSECTION = $1;
  if (match(CSECTION,"disk") > 0)
  {
	DISKS = DISKS + 1;
  }
  if (match(CSECTION, "network") > 0)
  {
	NICS = NICS + 1;
  }
}
