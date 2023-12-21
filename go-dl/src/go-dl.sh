#!/usr/bin/env bash

function check_go_version {
    declare -g GO_VERSION
    GO_VERSION="$(go version 2> "/dev/null")"
}

function is_go_installed {
    local -i IS_GO_INSTALLED
    local GO_PATH
    GO_PATH="$(which go 2> "/dev/null")"
    [ -x "${GO_PATH}" ] || [ -d "/usr/lib/go" ] || [ -d "/usr/local/go" ] ; IS_GO_INSTALLED="${?}"
    if [ "${IS_GO_INSTALLED}" -eq 0 ] ; then
        check_go_version
        echo "Go is installed already as ${GO_PATH:-"/usr/lib/go/bin/go"}, version: ${GO_VERSION}."
        return "${IS_GO_INSTALLED}"
    else
        echo "Go is not installed." && return "${IS_GO_INSTALLED}"
    fi
}

function download_go_latest {
    local GO_DL_URL="https://go.dev/dl/"
    local -i IS_DOWNLOAD_SUCCESSFUL
    declare -g GO_LATEST_LINUX
    GO_LATEST_LINUX="$(curl -s "${GO_DL_URL}" 2> "/dev/null" | grep --color=never -om 1 "go.*.linux-amd64.tar.gz")"
    echo "Downloading the latest Go version: ${GO_LATEST_LINUX}"
    curl -fLO "${GO_DL_URL}${GO_LATEST_LINUX}" 2> "/dev/null" ; IS_DOWNLOAD_SUCCESSFUL="${?}" && echo "Done!"
    return "${IS_DOWNLOAD_SUCCESSFUL}"
}

function install_go_local {
    local GO_LOCAL_INSTALL_PATH="/usr/local/go/"
    local GO_LINUX_ARCHIVE="${GO_TARGET_VERSION:-${GO_LATEST_LINUX}}"
    if [ -d "${GO_LOCAL_INSTALL_PATH}" ] ; then
        echo "Deleting previous local installation of go..."
        sudo -E rm -rf "${GO_LOCAL_INSTALL_PATH}" && echo "Done!" || exit "${?}"
        echo "Unpacking archive..."
        sudo -E tar -C "/usr/local" -xzf "${GO_LINUX_ARCHIVE}" && echo "Done!" || exit "${?}"
    else
        echo "Unpacking archive..."
        sudo -E tar -C "/usr/local" -xzf "${GO_LINUX_ARCHIVE}" && echo "Done!" || exit "${?}"
    fi
    # Cleanup
    rm -f "${GO_LINUX_ARCHIVE}"
    return "${?}"
}

function add_go_to_path {
    local GO_BIN_PATH="/usr/local/go/bin"
    local -l USER_SHELL
    local SHELLRC
    USER_SHELL="$(basename "$(printenv SHELL)")"
    if [[ ! "${PATH}" =~ .*${GO_BIN_PATH}.* ]] ; then
        echo "Adding Go to PATH in your SHELL's rc file..."
        case "${USER_SHELL}" in
        "bash" )
            SHELLRC="${HOME:-~}/.bashrc"
            grep -qF "${GO_BIN_PATH}" "${SHELLRC}" \
            && echo "Go is already in PATH through your .bashrc. If it is's still not on your PATH, make sure to source your .bashrc." \
            || echo -e '\n# Add Go to path\nexport PATH="${PATH}:/usr/local/go/bin"' >> "${SHELLRC}"
            ;;
        "zsh" )
            SHELLRC="${HOME:-~}/.zshrc"
            grep -qF "${GO_BIN_PATH}" "${SHELLRC}" \
            && echo "Go is already in PATH through your .zshrc. If it is's still not on your PATH, make sure to source your .zshrc." \
            || echo -e '\n# Add Go to path\nexport PATH="${PATH}:/usr/local/go/bin"' >> "${SHELLRC}"
            ;;
        esac
    fi
    return "${?}"
}

function main {
    is_go_installed
    if [ "${?}" -eq 1 ] ; then
        declare -g GO_TARGET
        GO_TARGET="${1:-"latest"}"
        case "${GO_TARGET}" in
        *latest* )
            download_go_latest && install_go_local && add_go_to_path || return "${?}"
            echo "Done! Changes to PATH will take effect on new shell sessions."
            echo "Source your SHELL's rc file for those changes to take effect immediately."
            ;;
        * )
            echo "Invalid target ${GO_TARGET}." && exit 3
            ;;
        esac
    fi
    return "${?}"
}

if [ "${#}" -lt 1 ] ; then
    echo "No version provided. Defaulting to latest."
    main "${@}" || exit "${?}"
else
    main "${@}" || exit "${?}"
fi
