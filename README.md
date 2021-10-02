**Random password guest generator for routers using Asuswrt-Merlin firmware**\
Setting a random password for guest wifi in Asuswrt-Merlin firmware

This script is a personal improvement of the original one. You can find it here -> [Setting a random password for guest wifi](https://github.com/RMerl/asuswrt-merlin.ng/wiki/Setting-a-random-password-for-guest-wifi)

The main changes are:

**1** Add gotify notification\
**2** Replace the API generator with this one [passwordwolf](https://passwordwolf.com). It appear that [passwd.me](https://passwd.me) is no longer active\
**3** Fix the openssl instruction\
**4** remove the e-mail functionality since I am still working to understand it\

These may require additional software to be installed over & above the default busy box installation so if you find the the scritp is not working check the error message.
Also, I am using a Gotify server installed in my local network

There are four method to get a password:

1 The password is made up of a phrase selected from a text file followed by a random three digit number
2 The password is made up using the openssl rand option
3 The password is made up accesing the API [passwordwolf](https://passwordwolf.com) using the curl command
4 If none of the previous alternatives works at the moment of running the script, a simple pass is defined using `date +"%A%B%d"`

**Install**

To install this very simple scripts you need to copy both the script and the phrases file in `/jffs/scripts/` folder in your router



and ensure you make it executable `chmod a+rx /jffs/scripts/newpass.sh`
