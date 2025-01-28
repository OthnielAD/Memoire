#!/bin/bash

# Message de bienvenue
echo "Bienvenue dans le processus d'automatisation de la redirection de port."
# Demande à l'utilisateur s'il souhaite configurer une paire de clés SSH
read -p "Voulez-vous configurer une paire de clés SSH ? (o/n) " CONFIGURE_KEYS
# Vérification et création des clés SSH si nécessaire
if [[ "$CONFIGURE_KEYS" =~ ^[oO]$ ]]; then
    KEY_PATH="$HOME/.ssh/id_rsa"

    echo "Les clés SSH seront enregistrées dans $KEY_PATH."
    # Création de la paire de clés
    read -p "Voulez-vous ajouter une passphrase à votre clé SSH ? (o/n) " RESPONSE
    if [[ "$RESPONSE" =~ ^[oO]$ ]]; then
        ssh-keygen -t rsa -b 2048 -f "$KEY_PATH"
    else
        ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N ""
    fi
        echo "Clé SSH générée avec succès."
    echo "N'oubliez pas d'ajouter la clé publique à 'authorized_keys' sur la machine intermédiaire."
else
    echo "Aucune configuration de clé SSH n'est nécessaire, poursuite du processus."
fi

# Demande à l'utilisateur de choisir une clé
read -p "Entrez le chemin de la clé privée à utiliser (ou appuyez sur Entrée pour utiliser $KEY_PATH) : " USER_KEY_PATH
USER_KEY_PATH=${USER_KEY_PATH:-$KEY_PATH}  # Utilise la clé par défaut si aucun chemin n'est fourni

# Demande le type de redirection de port
echo "Choisissez le type de port forwarding :"
echo "1) Local Port Forwarding"
echo "2) Dynamic Port Forwarding"
read -p "Entrez le numéro correspondant : " PORT_FORWARDING_CHOICE

# Demande l'IP publique de la machine intermédiaire
read -p "Veuillez entrer l'IP de la machine intermédiaire : " INTERMEDIATE_IP

# Demande le nom d'utilisateur de la machine intermédiaire
read -p "Veuillez entrer le nom d'utilisateur de la machine intermédiaire : " USERNAME

# Gestion des choix de port forwarding
case $PORT_FORWARDING_CHOICE in
    1)
        # Redirection de port local
        echo "Vous avez choisi la redirection de port local."
        echo "Choisissez comment définir le port local :"
        echo "1) Port local personnalisé"
        echo "2) Port aléatoire (entre 9000 et 65535)"
        read -p "Entrez le numéro correspondant : " PORT_CHOICE
        if [ "$PORT_CHOICE" == "1" ]; then
            read -p "Veuillez entrer le port local : " LOCAL_PORT
            # Vérification de la validité du port
            if [[ $LOCAL_PORT -lt 9000 || $LOCAL_PORT -gt 65535 ]]; then
                echo "Port local non valide. Veuillez entrer un port entre 9000 et 65535."
                exit 1
            fi
        elif [ "$PORT_CHOICE" == "2" ]; then
            LOCAL_PORT=$((RANDOM % 56535 + 9000))  # Port aléatoire entre 9000 et 65535
            echo "Un port local aléatoire a été sélectionné : $LOCAL_PORT"
        else
            echo "Choix invalide. Veuillez relancer le script."
            exit 1
        fi
        # Demande l'IP de la machine cible du réseau intranet
        read -p "Veuillez entrer l'IP de la machine cible du réseau intranet : " TARGET_IP
        # Demande le port distant sur lequel tourne le service sur la machine cible
        read -p "Veuillez entrer le port distant sur lequel le service tourne sur la machine cible : " TARGET_PORT
            echo "Lancement de la redirection de port local : ssh -i $USER_KEY_PATH -L $LOCAL_PORT:$TARGET_IP:$TARGET_PORT $USERNAME@$INTERMEDIATE_IP"
        ssh -i "$USER_KEY_PATH" -L "$LOCAL_PORT:$TARGET_IP:$TARGET_PORT" "$USERNAME@$INTERMEDIATE_IP"
        ;;
        
    2)
        # Redirection de port dynamique
        echo "Vous avez choisi la redirection de port dynamique."
        
        # Redirection de port distant
        echo "Vous avez choisi la redirection de port dynamique."
        echo "Choisissez comment définir le port dynamique :"
        echo "1) Port dynamique personnalisé"
        echo "2) Port aléatoire (entre 9000 et 65535)"
        read -p "Entrez le numéro correspondant : " PORT_CHOICE
        
        if [ "$PORT_CHOICE" == "1" ]; then
            read -p "Veuillez entrer le port dynamique : " REMOTE_PORT
            # Vérification de la validité du port
            if [[ $REMOTE_PORT -lt 9000 || $REMOTE_PORT -gt 65535 ]]; then
                echo "Port dynamique non valide. Veuillez entrer un port valide."
                exit 1
            fi
        elif [ "$PORT_CHOICE" == "2" ]; then
            REMOTE_PORT=$((RANDOM % 56535 + 9000))  # Port aléatoire entre 9000 et 65535
            echo "Un port dynamique aléatoire a été sélectionné : $REMOTE_PORT"
        else
            echo "Choix invalide. Veuillez relancer le script."
            exit 1
        fi
        
        echo "Lancement de la redirection de port dynamique : ssh -i $USER_KEY_PATH -D $REMOTE_PORT $USERNAME@$INTERMEDIATE_IP"
        ssh -i "$USER_KEY_PATH" -D "$REMOTE_PORT" "$USERNAME@$INTERMEDIATE_IP"
        ;;

    *)
        echo "Choix invalide. Veuillez relancer le script."
        exit 1
        ;;   
esac
