#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LENGTH 256

void sendSignal(const char *account, const char *uid, const char *message) {
    char command[MAX_LINE_LENGTH];
    snprintf(command, sizeof(command), "signal-cli --dbus -a %s send %s -m \"%s\"", account, uid, message);
    system(command);
}

int isUserInFile(const char *user, const char *filename) {
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror("Could not open file");
        return 0;
    }
    
    char line[MAX_LINE_LENGTH];
    while (fgets(line, sizeof(line), file)) {
        line[strcspn(line, "\n")] = 0; // Remove newline character
        if (strcmp(line, user) == 0) {
            fclose(file);
            return 1;
        }
    }
    fclose(file);
    return 0;
}

void subscribeUser(const char *uid) {
    FILE *file = fopen("/home/johbot/Demoticker/Data/Subscribed", "a");
    if (file) {
        fprintf(file, "%s\n", uid);
        fclose(file);
    } else {
        perror("Could not open file for subscribing");
    }
}

void unsubscribeUser(const char *uid) {
    FILE *file = fopen("/home/johbot/Demoticker/Data/Subscribed", "r");
    if (!file) {
        perror("Could not open file");
    }

    char line[MAX_LINE_LENGTH];
    char tempFile[] = "/home/johbot/Demoticker/Data/temp.txt";
    FILE *temp = fopen(tempFile, "w");
    
    while (fgets(line, sizeof(line), file)) {
        line[strcspn(line, "\n")] = 0; // Remove newline character
        if (strcmp(line, uid) != 0) {
            fprintf(temp, "%s\n", line);
        }
    }
    fclose(file);
    fclose(temp);
    
    remove("/home/johbot/Demoticker/Data/Subscribed");
    rename(tempFile, "/home/johbot/Demoticker/Data/Subscribed");
}

int main(int argc, char *argv[]) {

    const char *uid = argv[1];
    const char *gid = argv[2];
    const char *TEXT = argv[3];
    const char *file = argv[4];
    const char *NAME = argv[5];

    char ACCOUNT[MAX_LINE_LENGTH];
    FILE* accountFile = fopen("/home/johbot/Demoticker/Data/Account", "r");
    if (accountFile) {
        fgets(ACCOUNT, sizeof(ACCOUNT), accountFile);
        ACCOUNT[strcspn(ACCOUNT, "\n")] = 0; // Remove newline character
        fclose(accountFile);
    } else {
        perror("Could not open account file");
        return 1;
    }

    const char *ADMINGROUP = "NiZFSzOdvI5aysoKSp6tOPOGqCqKaqWKn+/kAtAt7wY=";
    int ADMIN = isUserInFile(uid, "/home/johbot/Demoticker/Data/Admins");
    int SUBBED = isUserInFile(uid, "/home/johbot/Demoticker/Data/Subscribed");
    int GROUP = (strlen(gid) == 0) ? 0 : 1;

    if (strncmp(TEXT, "-shouts", 7) == 0) {
        char shoutFile[MAX_LINE_LENGTH];
        snprintf(shoutFile, sizeof(shoutFile), "/home/johbot/Demoticker/Data/Shouts/%s", TEXT + 8);
        FILE *shoutStream = fopen(shoutFile, "r");
        if (shoutStream) {
            char shoutMessage[MAX_LINE_LENGTH];
            fgets(shoutMessage, sizeof(shoutMessage), shoutStream);
            sendSignal(ACCOUNT, uid, shoutMessage);
            fclose(shoutStream);
        }
    } else if (strncmp(TEXT, "-help", 5) == 0) {
        sendSignal(ACCOUNT, uid, "Hier ist eine Liste von commands:\n-shouts [Antifa|Umwelt] zeigt eine Liste mit Demorufen an\n-subscribe fügt dich zu der Verteilerliste hinzu\n-unsubscribe entfernt dich von der Verteilerliste");
    } else if (strncmp(TEXT, "-subscribe", 10) == 0 && GROUP == 0) {
        if (SUBBED) {
            sendSignal(ACCOUNT, uid, "Du hast schon Abonniert :)");
        } else {
             printf("Abonniere %s\n", uid);
            subscribeUser(uid);
            sendSignal(ACCOUNT, uid, "Du wurdest erfolgreich zur Liste hinzugefügt");
        }
    } else if (strncmp(TEXT, "-unsubscribe", 12) == 0 && GROUP == 0) {
        unsubscribeUser(uid);
        sendSignal(ACCOUNT, uid, "Du wurdest von der Liste entfernt");
    } else if (GROUP == 0) {
        if (ADMIN) {
            sendSignal(ACCOUNT, uid, "Du bist krass");
            char command[MAX_LINE_LENGTH];
            snprintf(command, sizeof(command), "/home/johbot/Demoticker/Bash/sending.sh \"%s\" \"%s\" \"%s\" &", TEXT, file, NAME);
            system(command);
        } else {
            sendSignal(ACCOUNT, uid, "Du wurdest noch nicht verifiziert. Deine Nachricht wird manuell überprüft. Das kann einen Moment dauern, bitte habe etwas Geduld.");
            if (strlen(file) > 0) {
                sendSignal(ACCOUNT, ADMINGROUP, NAME);
                sendSignal(ACCOUNT, ADMINGROUP, TEXT);
                char command[MAX_LINE_LENGTH];
                snprintf(command, sizeof(command), "signal-cli -a %s send -g %s -m \"%s\" -a \"%s\" &", ACCOUNT, ADMINGROUP, TEXT, file);
                system(command);
            } else {
                sendSignal(ACCOUNT, ADMINGROUP, NAME);
                sendSignal(ACCOUNT, ADMINGROUP, TEXT);
            }
        }
    }

    return 0;
}
