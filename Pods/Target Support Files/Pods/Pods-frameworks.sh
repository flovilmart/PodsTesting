#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

install_framework()
{
  local source="${BUILT_PRODUCTS_DIR}/Pods/$1"
  local destination="${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
  
  if [ -L ${source} ]; then
      echo "Symlinked..."
      source=$(readlink "${source}")
  fi
  
  echo "rsync -av --exclude '*.h' ${source} ${destination}"
  rsync -av --exclude *.h "${source}" "${destination}"
  # Resign the code if required by the build settings to avoid unstable apps
  if [ "${CODE_SIGNING_REQUIRED}" == "YES" ]; then
      code_sign "${destination}/$1"
  fi
}

# Signs a framework with the provided identity
code_sign() {
  # Use the current code_sign_identitiy
  echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
  echo "codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements $1"
  /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements "$1"
}

if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework 'Intercom.framework'
  install_framework 'PaymentKit.framework'
  install_framework 'SDWebImage.framework'
  install_framework 'SVProgressHUD.framework'
  install_framework 'Stripe.framework'
  install_framework 'ViewDeck.framework'
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework 'Intercom.framework'
  install_framework 'PaymentKit.framework'
  install_framework 'SDWebImage.framework'
  install_framework 'SVProgressHUD.framework'
  install_framework 'Stripe.framework'
  install_framework 'ViewDeck.framework'
fi
