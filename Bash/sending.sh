
#!bin/bash

MAIL="$1"
FILE="$2"
NAME="$3"
ACCOUNT=$(cat ./Data/Account)


echo "posting on mastodon"
if [[ $FILE = "" ]]; then
	toot post "$(printf "$MAIL")" &
else
	if [[ $MAIL = "" ]]; then
		toot post -m "$FILE" &
	else
		toot post -m "$FILE" "$(printf "$MAIL")" &
	fi
fi

echo "posting on instagram"
if [[ $FILE = "" ]]; then
	python3 "$MAIL" ./Python/instagramposting.py ~/Demoticker/Neuesevent.png &
else
	python3 ./Python/instagramposting.py "$(printf "$MAIL")" "$FILE" &
fi

while read user; do
	echo "sending $MAIL to $user"
	if [[ $FILE = "" ]]; then
		echo "kein Attachment"
		echo "Sende Nachricht an $user"
		signal-cli --dbus -a $ACCOUNT send "$user" -m "$(printf "$MAIL")"
	else
		echo  "Attachment gefunden"
		signal-cli --dbus -a $ACCOUNT send "$user" -m "$(printf "$MAIL")" -a "$FILE"
	fi
done<<<$(cat ./Data/Subscribed)
