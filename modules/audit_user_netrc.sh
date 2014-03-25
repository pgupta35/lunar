# audit_user_netrc
#
# While the system administrator can establish secure permissions for users'
# .netrc files, the users can easily override these.
# Users' .netrc files may contain unencrypted passwords that may be used to
# attack other systems.
#
# Refer to Section 9.2.9 Page(s) 168-169 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 7.2 Page(s) 25 CIS FreeBSD Benchmark v1.0.5
#.

audit_user_netrc () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ] || [ "$os_name" = "FreeBSD" ]; then
    funct_verbose_message "User Netrc Files"
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  User netrc file permissions"
    fi
    check_fail=0
    for home_dir in `cat /etc/passwd |cut -f6 -d":" |grep -v "^/$"`; do
      check_file="$home_dir/.netrc"
      if [ -f "$check_file" ]; then
        check_fail=1
        funct_check_perms $check_file 0600
      fi
    done
    if [ "$check_fail" != 1 ]; then
      if [ "$audit_mode" = 1 ]; then
        total=`expr $total + 1`
        score=`expr $score + 1`
        echo "Secure:    No user netrc files exist [$score]"
      fi
    fi
  fi
}