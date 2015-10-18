#!/bin/sh
name="$1"
sensitive_services_list=/etc/sensitive_services
grep -x "$name" "$sensitive_services_list" && exit 101
exit 0
