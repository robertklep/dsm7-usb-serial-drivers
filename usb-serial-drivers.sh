#!/bin/sh

# Installation and loading of USB serial drivers for DSM 7.0, 7.1, and 7.2
# Designed for use with usb-serial-drivers https://github.com/robertklep/dsm7-usb-serial-drivers

ARCH=""
DSM_VERSION=""
GITHUB_URL="https://github.com/robertklep/dsm7-usb-serial-drivers"
BASE_URL="${GITHUB_URL}/raw/main"
MODULE_DIR="/lib/modules/"
PREFIX="[usb-serial-drivers]"
SUPPORTED_ARCHS=(alpine apollolake armada37xx armada38x armada370 armada375 armadaxp avoton braswell broadwell broadwellnk bromolow cedarview comcerto2k denverton epyc7002 evansport geminilake grantley kvmx64 monaco purley r1000 rtd1296 rtd1619b v1000)
SUPPORTED_DSM_VERSIONS=("7.0" "7.1" "7.2")
INSTALL_MODULES=(ch341 cp210x pl2303 ti_usb_3410_5052)
# Combine the two arrays into $MODULES
MODULES=(usbserial ftdi_sio cdc-acm "${INSTALL_MODULES[@]}")

log() {
  echo "${PREFIX} $@"
}

sudo_exec() {
  sudo "$@"
  if [ $? -ne 0 ]; then
    log "Command failed: $@"
    exit 1
  fi
}

download_module() {
  local module_name=$1
  local url="${BASE_URL}/modules/${ARCH}/dsm-${DSM_VERSION}"
  if lsmod | grep -q "${module_name}"; then
    log "${module_name} is already loaded. Removing it first."
    sudo_exec rmmod "${module_name}"
  fi
  sudo_exec wget -nv -O "${MODULE_DIR}${module_name}.ko" "${url}/${module_name}.ko"
}

load_unless_loaded() {
  local module_name=$1
  if lsmod | grep -q "${module_name}"; then
    log "${module_name} is already loaded."
  else
    log "Loading ${module_name}"
    sudo insmod "${MODULE_DIR}${module_name}.ko"
  fi
}

load_modules() {
  for module in "${MODULES[@]}"; do
    load_unless_loaded "${module}"
  done
  log "USB serial drivers have been enabled successfully."
}

prompt_for_arch_and_dsm_version() {
  ARCH="$1"
  DSM_VERSION="$2"
  if [ -z "$ARCH" ]; then
    echo
    echo "Supported architectures: ${SUPPORTED_ARCHS[@]}"
    read -p "Enter the architecture: " ARCH
    if [ -z "$ARCH" ]; then
      echo "No architecture specified. Exiting."
      exit 1
    fi
  fi
  if [[ ! " ${SUPPORTED_ARCHS[@]} " =~ " ${ARCH} " ]]; then
    echo "Unsupported architecture: ${ARCH}. Exiting."
    exit 1
  fi
  echo "Architecture set to: ${ARCH}"
  if [ -z "$DSM_VERSION" ]; then
    echo
    echo "Supported DSM Versions: ${SUPPORTED_DSM_VERSIONS[@]}"
    read -p "Enter the DSM version: " DSM_VERSION
    if [ -z "$DSM_VERSION" ]; then
      echo "No DSM version specified. Exiting."
      exit 1
    fi
  fi
  if [[ ! " ${SUPPORTED_DSM_VERSIONS[@]} " =~ " ${DSM_VERSION} " ]]; then
    echo "Unsupported DSM version: ${DSM_VERSION}. Exiting."
    exit 1
  fi
  echo "DSM version set to: ${DSM_VERSION}"
  echo
}

confirm() {
  echo
  read -p "This will download, install, and load the USB serial drivers using \`sudo\`. Are you sure? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Exiting."
    exit 1
  fi
  echo
}

case $1 in
install)
  # If --yes is passed, skip the confirmation prompt
  [ "$4" != "--yes" ] && confirm

  prompt_for_arch_and_dsm_version $2 $3

  for module in "${INSTALL_MODULES[@]}"; do
    download_module "${module}"
  done

  load_modules
  ;;
start)
  load_modules
  ;;
stop)
  exit 0
  ;;
*)
  echo
  echo "Install or enable the USB serial drivers on DSM ${DSM_VERSION}"
  echo
  echo "Unit Commands:"
  echo "  start                                         Load the USB serial drivers"
  echo "  install [ARCHITECTURE] [DSM_VERSION] [--yes]  Install the USB serial drivers for the specified architecture"
  echo "                                                    --yes Skip confirmation prompt"
  echo
  echo "More information available at ${GITHUB_URL}"
  exit 1
  ;;
esac
