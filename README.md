**Random password guest generator for routers using Asuswrt-Merlin firmware**\
Setting a random password for guest wifi in Asuswrt-Merlin firmware

This script is a personal improvement of the original one. You can find it here -> [Setting a random password for guest wifi](https://github.com/RMerl/asuswrt-merlin.ng/wiki/Setting-a-random-password-for-guest-wifi). **All credit goes to the author of the original script**

The main changes are:

**1** Add gotify notification\
**2** Replace the API generator with this one [passwordwolf](https://passwordwolf.com). It appear that [passwd.me](https://passwd.me) is no longer active\
**3** Fix the openssl instruction\
**4** remove the e-mail functionality since I am still working to understand it\

These may require additional software to be installed over & above the default busy box installation so if you find the the scritp is not working check the error message.
Also, I am using a Gotify server installed in my local network

There are four methodes to get a password:

1 The password is made up of a phrase selected from a text file followed by a random three digit number\
2 The password is made up using the openssl rand option\
3 The password is made up accesing the API [passwordwolf](https://passwordwolf.com) using the curl command\
4 If none of the previous alternatives works at the moment of running the script, a simple pass is defined using `date +"%A%B%d"`\

**Install**

To install this very simple scripts you need to copy both the script and the phrases file in `/jffs/scripts/` folder in your router:

`curl --retry 3 -O "https://raw.githubusercontent.com/cerealconyogurt/Random-password-AC88U/main/newpass.sh" -O "https://raw.githubusercontent.com/cerealconyogurt/Random-password-AC88U/main/newpass-phrases.txt" && chmod 0755 /jffs/scripts/newpass.sh`

and ensure you make it executable `chmod a+rx /jffs/scripts/newpass.sh`

**Setting up**

There are 3 methodes you can select within the script:

**getrandomphrase**: These phrases are the basis for the password - I've chosen bird names from my country, but you could use anything you want.
Ensure that each phrase is at least 7 characters long (+3 for random number = min length of 10 characters) and that there are no blank lines.
Try and have a reasonable number of entries in here, or you will end up with the same phrase being picked on a regular basis. The author of this script had in his file more than 70 different bands! Way to go!

**getrandopenssl**: This fucntion uses openssl rand function to create a password. Quite simple indeed but maybe more problematic to communicate the pass to the guest/famaly

**getpasswfromapi**: This fucntion uses an API call to create a pass following some rules. Pretty simple as well

In order to chose what functions you want to use, you just need to uncomment the function in the script:

`## Now call the function we want to use`\
`# getrandomphrase`\
`# getrandopenssl`\
`# getpasswfromapi`

To get this process to run at 4am each day, add the following into `/jffs/scripts/services-start` and make it executable :

`#!/bin/sh
cru a ResetGuestPassword "0 4 * * * /jffs/scripts/newpass.sh"`

This will set it up so that the script will be run at 4am every day.

Reboot your router, and you're done!

END
