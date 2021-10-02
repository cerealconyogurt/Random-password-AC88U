#!/bin/sh

## default password based on date if we cannot create one elsewhere
datepasswd=`date +"%A%B%d"`

############################################################################
#
#   getrandomphrase - uses a list of known phrases in a file
#                   - phrase needs to be min 7 chars long
#                   - combines this with a random number between 0 and 999
#
############################################################################

getrandomphrase () {
    if [ -f /jffs/scripts/newpass-phrases.txt ]; then
        phrasecount=`wc -l /jffs/scripts/newpass-phrases.txt | cut -d " " -f 1`
        if [ $phrasecount == 0 ]; then
            # file is empty
            phrasepasswd=$datepasswd
        else
            randomnumber=`tr -cd 0-9 </dev/urandom | head -c 7 | sed 's/^0*//'`
            if [ $randomnumber == "" ]; then
                # cannot get a random number, bailing
                phrasepasswd=$datepasswd
            else
                phrasetext=`sed -n $(( $randomnumber % $phrasecount + 1 ))p /jffs/scripts/newpass-phrases.txt`
                if [ $phrasetext == "" ]; then
                    # blank lines in file, bailing
                    phrasepasswd=$datepasswd
                else
                    if [ ${#phrasetext} -lt 7 ]; then
                        # phrase is too short to make a valid password
                        phrasepasswd=$datepasswd
                    else
                        # we have a phrase now get the three digit number
                        randomnumber=`tr -cd 0-9 </dev/urandom | head -c 7 | sed 's/^0*//'`
                        if [ $randomnumber == "" ]; then
                            # cannot get a random number, bailing
                            phrasepasswd=$datepasswd
                        else
                            phrasenum=`printf "%03d" $(( $randomnumber % 1000 ))`
                            phrasepasswd=$phrasetext$phrasenum
                        fi
                    fi
                fi
            fi
        fi
    else
        # file does not exist
        phrasepasswd=$datepasswd
    fi
}

############################################################################
#
#   getrandopenssl - uses openssl rand function to create a password
#
############################################################################

getrandopenssl () {
    phrasepasswd=`openssl rand -base64 8`
    if [ $phrasepasswd == "" ]; then
        # we were unable to get something from openssl
        phrasepasswd=$datepasswd
    fi
}

############################################################################
#
#   getpasswfromapi - uses passwordolf.com api to get random password
#                   - needs jq and curl to be installed
#
############################################################################

getpasswfromapi () {
    ping -c 1 8.8.8.8 >> /dev/null 2>&1
    if [ $? == 0 ]; then
        curl -k -s "https://passwordwolf.com/api/?length=8&upper=on&lower=on&number=on&special=off&exclude=?!<>li1I0OB8&repeat=1" >> /tmp/pass.json
        phrasepasswd=`jq '.[] | .password' /tmp/pass.json | sed 's/"//g'`
        rm /tmp/pass.json
        if [ $phrasepasswd == "" ]; then
            # we were unable to get something from passwordolf.com
            phrasepasswd=$datepasswd
        fi
    else
        # no network access at this time
        phrasepasswd=$datepasswd
    fi
}

## Now call the function we want to use

# getrandomphrase
# getrandopenssl
getpasswfromapi

## log what we have done
logger -t $(basename $0) "Today's Guest1 password is :" $phrasepasswd

# nvram settings for the three guest 2.4 networks
nvram set wl0.1_wpa_psk=$phrasepasswd
nvram set wl0.2_wpa_psk=$datepasswd
nvram set wl0.3_wpa_psk=$datepasswd

# nvram settings for the three guest 5.0 networks
nvram set wl1.1_wpa_psk=$phrasepasswd
nvram set wl1.2_wpa_psk=$datepasswd
nvram set wl1.3_wpa_psk=$datepasswd

## passwords have been changed but we need to restart the wifi for it to pick them up
service restart_wireless

## now send out the message to gotify

GOTIFY_SERVER_IP="http://gotifyserverip:port/message?token=xxxxxxxxxxx."

TITLE="Guest network password notification"
MESSAGE="Today's guest password is : ${phrasepasswd}"

curl $GOTIFY_SERVER_IP -F "title=${TITLE}" -F "message=${MESSAGE}" -F "priority=5" &> /dev/null 2>&1
