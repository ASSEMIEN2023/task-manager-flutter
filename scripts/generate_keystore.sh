#!/bin/bash
set -e
KEYSTORE_PATH="android/app/upload-keystore.jks"
KEY_PROPERTIES="android/key.properties"
echo "🔐 Génération du keystore pour signature APK..."
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool introuvable. Installe le JDK."
    exit 1
fi
mkdir -p android/app
read -p "Alias de la clé [upload] : " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-upload}
read -sp "Mot de passe du keystore : " STORE_PASSWORD
echo ""
read -sp "Mot de passe de la clé : " KEY_PASSWORD
echo ""
read -p "Nom (CN) [Task Manager] : " CN
CN=${CN:-Task Manager}
keytool -genkey -v -keystore "$KEYSTORE_PATH" -keyalg RSA -keysize 2048 -validity 10000 -alias "$KEY_ALIAS" -storepass "$STORE_PASSWORD" -keypass "$KEY_PASSWORD" -dname "CN=$CN, O=Mon Entreprise, C=FR"
cat > "$KEY_PROPERTIES" << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=upload-keystore.jks
EOF
echo "✅ Keystore généré. Ne le commit jamais sur Git !"
