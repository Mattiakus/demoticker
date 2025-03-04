#!/bin/bash

uid="$1"
gid="$2"
TEXT="$3"
COMMAND="${TEXT,,}"
COMMAND="${COMMAND#!}"
COMMAND="${COMMAND%% *}"
COMMAND="${COMMAND%%\\*}"
echo "the command is \"$COMMAND\""
FILE="$4"
NAME="$5"

ACCOUNT=$(cat ./Data/Account)
ADMINGROUP="NiZFSzOdvI5aysoKSp6tOPOGqCqKaqWKn+/kAtAt7wY="

ADMIN="0"
while read user; do
	#echo "vergleiche '$user' mit '$uid'"
	if [[ "$user" = "$uid" ]]; then
		echo "der Autormensch ist Admin"
		ADMIN="1"
	fi
done <<<$(cat ./Data/Admins)

SUBBED="0"
while read user; do	
	if [[ "$user" = "$uid" ]]; then
		echo "der Autormensch hat abonniert"
		SUBBED="1"
	fi
done <<<$(cat ./Data/Subscribed)

if [[ $gid = "" ]]; then
	GROUP="0"
else
	GROUP="1"
fi

if [[ "$TEXT" = !* ]]; then

	if [[ "$COMMAND" = "version" ]] || [[ "$COMMAND" = "v" ]]; then
		signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "$(cat ./Data/version)"
	elif [[ "$COMMAND" = "shouts" ]] || [[ "$COMMAND" = "s" ]]; then
		SHOUTFILE="${TEXT#* }"
		SHOUTFILE="${SHOUTFILE,,}"
		if [ -f "./Data/Shouts/$SHOUTFILE" ]; then
			signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "$(cat ./Data/Shouts/$SHOUTFILE)"
		else
			signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "Habe Liste namens \"$SHOUTFILE\" nicht gefunden. Schreibe \"-help\" (ohne die Ahnführungszeichen) um zu sehen, welche Listen es gibt"
		fi
	elif [[ "$COMMAND" = help ]] || [[ "$COMMAND" = "h" ]]; then
		if [[ "$ADMIN" = "0" ]]; then
			signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "$(printf "\
			Hier ist eine Liste von commands:\n\
			-shouts [Antifa|Umwelt] zeigt eine Liste mit Demorufen an\n\
			-subscribe fügt dich zu der Verteilerliste hinzu\n\
			-unsubscribe entfernt dich von der Verteilerliste\n\
			Wenn du eine Nachricht schreibst, die nicht mit einem command anfängt, schreibst du eine Nachricht an die Admins")"
		else
			signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "$(printf "Hier ist eine Liste von commands:\n\
			-shouts [Antifa|Umwelt] zeigt eine Liste mit Demorufen an\n\
			-subscribe fügt dich zu der Verteilerliste hinzu\n\
			-unsubscribe entfernt dich von der Verteilerliste\n\
			-echo [NACHRICHT] schickt dir eine Nachricht mit dem Inhalt NACHRICHT\n\
			Wenn du eine Nachricht schreibst, die nicht mit einem command anfängt, schreibst du eine Nachricht an die Admins")"
		fi

	elif [[ "$COMMAND" = "subscribe" ]] && [[ $GROUP = "0" ]]; then

		if [[ $SUBBED = "1" ]]; then
			signal-cli --dbus -a $ACCOUNT send $uid -m "Du hast schon Abonniert :)"
		else
			echo "Abonniere $uid"
			echo "$uid" >> ./Data/Subscribed
			signal-cli --dbus -a $ACCOUNT send $uid -m "Du wurdest erfolgreich zur Liste hinzugefügt"
		fi

	elif [[ "$COMMAND" = "unsubscribe" ]] && [[ $GROUP = "0" ]]; then

		sed -i /$uid/d  ./Data/Subscribed
		signal-cli --dbus -a $ACCOUNT send $uid -m "Du wurdest von der Liste entfernt"
	
	elif [[ "$COMMAND" = "echo" ]]; then
		echo "gebe folgendes aus: ${TEXT#* }"
		OUTPUT="${TEXT#* }"
		signal-cli --dbus -a $ACCOUNT send $uid -m "$(printf "$OUTPUT")"
	else
		signal-cli --dbus -a $ACCOUNT send $uid -m "Diesen Befehl kenne ich nicht. Schreibe mir \"-help\" (ohne Anführungszeichen) um eine Liste mit den Befehlen angezeigt zu bekommen"
		echo "$TEXT" >> ./Data/errors
	fi
elif [[ $GROUP = "0" ]]; then
	if [[ $ADMIN = "1" ]]; then
	 ###ADMIN COMMANDS###
		signal-cli --dbus -a $ACCOUNT send $uid -m "Die nachricht wird gepostet"
		bash ./Bash/sending.sh "$TEXT" "$FILE" "$NAME"
		
	else
	 ###NORMAL COMMANDS###
		signal-cli --dbus -a $ACCOUNT send $uid -m "Deine Nachricht wird an die Admins weitergeleitet :)"
		if [[ $FILE != "" ]]; then
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$NAME:"
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$(printf "$TEXT")" -a "$FILE"
		else
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$NAME:"
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$(printf "$TEXT")"
		fi
	fi
fi
