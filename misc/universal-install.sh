# This script installs an repository for apt, dnf, yum, or zypper. It expects
# the following eniroment variables.
# GPG_KEY     : the gpg key itself
# APP_NAME    : the name to use for the repo file and key
# DEB_REPO    : (optional) the string to appear in the .list file
# RPM_REPO    : (optional) the string to appear in the .repo file

# Override repostiroy based on distribution identity
test -e /etc/os-release && os_release='/etc/os-release' || os_release='/usr/lib/os-release'
if [ -f "${os_release}" ]; then
    # Load OS release info
    . "${os_release}"

    # Check if apt exists and repo is set
    if [ -n "$DEB_REPO" ] && command -v apt >/dev/null; then
        # Set variable for existance of APT
        PACKAGE_MANAGER_EXISTS="$PACKAGE_MANAGER_EXISTS apt"

        case " ${ID:-linux} ${ID_LIKE:-unix}" in
        *" ubuntu"*)
            echo "Ubuntu based distribution detected. Installing APT repository."
            PACKAGE_MANAGER="apt"
            ;;
        *" debian"*)
            echo "Debian based distribution detected. Installing APT repository."
            PACKAGE_MANAGER="apt"
            ;;
        esac
    fi

    # Check if dnf/yum exists and repo is set
    if [ -n "$RPM_REPO" ] && (command -v dnf >/dev/null || command -v yum >/dev/null); then
        # Set variable for existance of yum/dnf
        PACKAGE_MANAGER_EXISTS="$PACKAGE_MANAGER_EXISTS yum"

        case " ${ID:-linux} ${ID_LIKE:-unix}" in
        *" fedora"*)
            echo "Fedora based distribution detected. Installing YUM/DNF repository."
            PACKAGE_MANAGER="yum"
            ;;
        *" rhel"*)
            echo "Red Hat based distribution detected. Installing YUM/DNF repository."
            PACKAGE_MANAGER="yum"
            ;;
        esac
    fi

    # Check if zypper exists and repo is set
    if [ -n "$RPM_REPO" ] && command -v zypper >/dev/null; then
        # Set variable for existance of zypper
        PACKAGE_MANAGER_EXISTS="$PACKAGE_MANAGER_EXISTS zyp"

        case " ${ID:-linux} ${ID_LIKE:-unix}" in
        *" sles"*)
            echo "SUSE based distribution detected. Installing Zypper repository."
            PACKAGE_MANAGER="zyp"
            ;;
        *" opensuse"*)
            echo "openSUSE based distribution detected. Installing Zypper repository."
            PACKAGE_MANAGER="zyp"
            ;;
        esac
    fi
fi

# Heuristic when OS release detection fails
# 1. If APT and YUM/DNF are detected, use the one that installed the other
# 2. Otherwise, proceed in order of APT, YUM/DNF, and Zypper
if [ -z "$PACKAGE_MANAGER" ]; then
    echo "WARNING: OS release detection failed, using heuristics."

    case "$PACKAGE_MANAGER_EXISTS" in
    *" apt yum"*)
        echo "Both APT and YUM/DNF detected."
        if dpkg -s dsf >/dev/null 2>&1; then
            echo "RPM is installed through dpkg. Installing APT repository."
            PACKAGE_MANAGER="apt"
        elif rpm -q dpkg >/dev/null 2>&1; then
            echo "dpkg is installed through RPM. Installing YUM/DNF repository."
            PACKAGE_MANAGER="yum"
        else
            echo "ERROR: Both APT and YUM/DNF were found, but neither is installed through the other."
            echo "Please follow manual installation instructions."
            exit 1
        fi
        ;;
    *" apt"*)
        echo "APT detected. Installing APT repository."
        PACKAGE_MANAGER="apt"
        ;;
    *" yum"*)
        echo "YUM/DNF detected. Installing YUM repository."
        PACKAGE_MANAGER="yum"
        ;;
    *" zyp"*)
        echo "Zypper detected. Installing zypper repository."
        PACKAGE_MANAGER="zyp"
        ;;
    *)
        echo "FAILED: No supported package manager found."
        exit 1
        ;;
    esac
fi

if [ "$PACKAGE_MANAGER" = "apt" ]; then
    GPG_KEY_DIR="/etc/apt/keyrings"
    GPG_KEY_PATH="$GPG_KEY_DIR/$APP_NAME.asc"
    APTLIST_PATH="/etc/apt/sources.list.d/$APP_NAME.list"

    # Make sure the keyring directory exists
    mkdir -p "$GPG_KEY_DIR"

    # Export key to file
    echo "$GPG_KEY" >"$GPG_KEY_PATH"
    # get arch
    DEBIAN_ARCH=$(dpkg --print-architecture)
    echo "deb [arch=$DEBIAN_ARCH signed-by=$GPG_KEY_PATH by-hash=force] $DEB_REPO" >"$APTLIST_PATH"
    echo "DONE!"
    exit
else
    GPG_KEY_DIR="/etc/pki/rpm-gpg"
    GPG_KEY_PATH="$GPG_KEY_DIR/$APP_NAME.asc"

    # set the path for the repo file depending on the package manager
    case "$PACKAGE_MANAGER" in
    "yum")
        RPMLIST_PATH="/etc/yum.repos.d/$APP_NAME.repo"
        ;;
    "zyp")
        RPMLIST_PATH="/etc/zypp/repos.d/$APP_NAME.repo"
        ;;
    esac

    # Make sure the keyring directory exists
    mkdir -p "$GPG_KEY_DIR"

    # Export key to file
    echo "$GPG_KEY" >"$GPG_KEY_PATH"

    rpm --import "$GPG_KEY_PATH"
    echo "$RPM_REPO" >"$RPMLIST_PATH"
    echo "DONE!"

    # Give a helpful note if we assumed yum despite zypper being installed
    if [ "$PACKAGE_MANAGER" = "yum" ] && [ "${PACKAGE_MANAGER_EXISTS#* zyp*}" != "${PACKAGE_MANAGER_EXISTS}" ]; then
        echo "NOTE: I assumed yum/dnf. However, zypper is installed. You may switch to zypper using the following command:"
        echo "      sudo mv '/etc/yum.repos.d/$APP_NAME.repo' '/etc/zypp/repos.d/$APP_NAME.repo'"
    fi
    exit
fi
