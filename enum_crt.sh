#!/bin/bash
#2016.03.11
#Enumerate domains using certificate transparency project https://crt.sh
#Does wild card search for base domain, then recursively gathers info about altnames. Future improvements could include recursing on new altnames discovered.

domain="$1"

useragent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0)"

[ -z "$domain" ] && echo "usage: $0 <domain>" && exit 1

echoerr(){ echo "$@" 1>&2; }

tmpfile="/tmp/$(basename $0).$domain.$$.tmp"

tmpfileresults="/tmp/$(basename $0).$domain.results.$$.tmp"

#Sanitize the domain, for a regex grep search
regexdomain="${domain/\./\\.}"

echoerr "Retrieving domain infomation from crt.sh"
echoerr ""

#Download the crt.sh domain information
#todo detect if show-progress is supported
wget --wait 1 -A "*?id*" -I / -L -N -r -l1 -qO "$tmpfile" -e robots=off -U "$useragent" --no-remove-listing "https://crt.sh/?q=%25$domain" --show-progress

#Extract altnames
grep -P -o 'DNS:.*?<BR>' "$tmpfile" | tr -d "DNS:" | tr -d "<BR>" >> $tmpfileresults

#Extract subdomains identified.
grep -o "[a-zA-Z0-9.-]*$regexdomain" "$tmpfile" >> $tmpfileresults

#Make results lower case, then eliminate duplicates
cat $tmpfileresults | tr A-Z a-z | sort -u

rm "$tmpfile"
rm "$tmpfileresults"

