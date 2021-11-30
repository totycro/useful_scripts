#!/usr/bin/env bash

# This script is inspired by the example:
# http://borgbackup.readthedocs.io/en/stable/quickstart.html#automating-backups
#
# See also: https://wiki.server.abteil.org/index.php/Backups


info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

if [ `id -u` -ne 0 ] ; then
    echo "Run this as root"
    exit 1
fi

# setting this explicitly avoids problems with wrong $HOME if script is run via su or sudo
export BORG_BASE_DIR='/home/totycro'

export BORG_REPO='ssh://borgbackup@backup.suuf.cc:9999/backup/bernhard'

# Setting this, so you won't be asked for your repository passphrase:
export BORG_PASSPHRASE=`cat /home/totycro/.config/borg-passphrase`    # some very long random genenerated string

export BORG_RSH='ssh -i /home/totycro/.ssh/id_rsa'

#export BORG_LOGGING_CONF=$BASEDIR/borg-logger-conf.ini

info "Starting backup"

borg break-lock
borg create                                                           \
    --verbose                                                         \
    --filter AME                                                      \
    --list                                                            \
    --progress                                                        \
    --stats                                                           \
    --show-rc                                                         \
    --checkpoint-interval 300                                         \
    --compression zstd,5                                              \
    --exclude-caches                                                  \
    --exclude '/home/*/.cache/*'                                      \
    --exclude '/home/*/.local/share/Trash/*'                          \
    --exclude '/var/cache/*'                                          \
    --exclude '/var/tmp/*'                                            \
    --exclude '/home/totycro/.PyCharmCE2019.3/'                       \
    --exclude '/home/totycro/.mozilla/'                               \
    --exclude '/home/totycro/tmp'                                     \
    --exclude '/home/totycro/musik'                                   \
    --exclude '/home/totycro/d'                                       \
    --exclude '/home/totycro/downs'                                   \
    --exclude '/home/totycro/.stack'                                  \
    --exclude '/home/totycro/.cache'                                  \
    --exclude '/home/totycro/.local'                                  \
    --exclude '/home/totycro/.config/chromium'                        \
    --exclude '/home/totycro/.config/Signal'                          \
    --exclude '/home/totycro/.config/Signal Beta'                     \
    --exclude '/home/totycro/local'                                   \
    --exclude '/home/totycro/Downloads'                               \
    --exclude '/home/totycro/old'                                     \
    --exclude '/home/totycro/.cabal'                                  \
    --exclude '/home/totycro/.hoogle'                                 \
    --exclude '/home/totycro/.wine'                                   \
                                                                      \
    ::'{hostname}-{now:%Y-%m-%dT%H:%M:%S}'                            \
    /root                                                             \
    /etc                                                              \
    /home/totycro                                                     \


backup_exit=$?

if [ ${backup_exit} -eq 1 ];
then
    info "Backup finished with a warning"
fi

if [ ${backup_exit} -gt 1 ];
then
    info "Backup finished with an error"
fi

exit ${backup_exit}

