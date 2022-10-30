# mirror-scripts
 
## Cron tasks

```
MIRROR_SCRIPTS="/home/mirror/git/mirror-scripts"
MIRROR_LOGS="/home/mirror/logs"
# m h  dom mon dow   command
09 */6      * * *    $MIRROR_SCRIPTS/ctan-mirror.bash >> $MIRROR_LOGS/ctan.log
09 2-23/6   * * *    $MIRROR_SCRIPTS/termux-mirror.bash >> $MIRROR_LOGS/termux.log
41 4-23/6   * * *    $MIRROR_SCRIPTS/apt-mirror.bash >> $MIRROR_LOGS/apt-mirror.log
02 4-23/6   * * *    $MIRROR_SCRIPTS/dnf-reposync.bash >> $MIRROR_LOGS/dnf-reposync.log
17 4-23/6   * * *    $MIRROR_SCRIPTS/makerepo.bash >> $MIRROR_LOGS/makerepo.log
```
