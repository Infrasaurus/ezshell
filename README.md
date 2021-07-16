# ad-knackered
For those times when Active Directory is being difficult.  A collection of documentation and Powershell to make life easier.

## How do I use this?
You should already be decently versed in Active Directory maintenance and support before using these tools.  If you don't know how to use these Powershell scripts, you're likely not the intended audience of this content anyway.

## No seriously, how do I use this?
Read the comments in the script you want to use, change values to fit your environment (where required), and run as a Domain or Enterprise Administrator (preferably).  These may work under other rights/roles, but haven't been tested as such.

## These all seem like pretty basic tasks...
That's the idea.  These are, hands-down, the most common tasks I've had to do in every Active Directory environment I've taken over or built out.  I got tired of re-writing my Powershell every single time from scratch, so I built this repo instead.  This way I can copy-paste-edit-deploy into whatever environment the future takes me, and so can you.

## But why a repo? Why not share them on \[insert URL here\]
Namely because every time I started re-writing these scripts, I would do some searching for a more modern solution.  There never was one, but there were tons of shady "Active Directory Monitoring" shovelware from vendors that cost an arm and a leg just to replicate what this Powershell does, only fancier (ie, in HTML).  I refused to shell out cash for those solutions in the small/flat environments I managed, and got equally tired of finding my references across the usual communities, so I compiled this repo instead.  Think of it as a _highly focused_ Powershell Gallery.

## This is awesome!
Thank you.  Feel free to share it around, but if you try to package my work into yet another closed-source/proprietary "Active Directory Monitoring" suite I will be very cross with you.  Mind the license, and share your work.

## Anything else?
Just a **DISCLAIMER**: You run this code at your own risk, and acknowledge that you alone are responsible for making sure it does what's claimed in the comments/documentation.  **Never, _EVER_** run code you're unfamiliar with, especially in production.