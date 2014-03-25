# audit_super_users
#
# Any account with UID 0 has superuser privileges on the system.
# This access must be limited to only the default root account
# and only from the system console.
#
# Refer to Section(s) 8.6 Page(s) 28 CIS FreeBSD Benchmark v1.0.5
#.

audit_super_users () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ] || [ "$os_name" = "FreeBSD" ]; then
    funct_verbose_message "Accounts with UID 0"
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  Super users other than root"
      total=`expr $total + 1`
      for user_name in `awk -F: '$3 == "0" { print $1 }' /etc/passwd |grep -v root`; do
        echo "$user_name"
        if [ "$audit_mode" = 1 ]; then
          score=`expr $score - 1`
          echo "Warning:   UID 0 for $user_name [$score]"
          funct_verbose_message "" fix
          funct_verbose_message "userdel $user_name" fix
          funct_verbose_message "" fix
        fi
        if [ "$audit_mode" = 0 ]; then
          check_file="/etc/shadow"
          funct_backup_file $check_file
          check_file="/etc/passwd"
          backup_file="$work_dir$check_file"
          funct_backup_file $check_file
          echo "Removing:  Account $user_name it UID 0"
          userdel $user_name
        fi
      done
      if [ "$user_name" = "" ]; then
        if [ "$audit_mode" = 1 ]; then
          score=`expr $score + 1`
          echo "Secure:    No accounts other than root have UID 0 [$score]"
        fi
      fi
    else
      check_file="/etc/shadow"
      funct_restore_file $check_file $restore_dir
      check_file="/etc/passwd"
      funct_restore_file $check_file $restore_dir
    fi
  fi
}