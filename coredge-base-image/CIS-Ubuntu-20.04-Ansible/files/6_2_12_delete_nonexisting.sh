#!/bin/bash
if echo $PATH | grep -q "::"; then
    echo "Empty Directory in PATH (::)"
fi
if echo $PATH | grep -q ":$"; then
    echo "Trailing : in PATH"
fi
for x in $(echo $PATH | tr ":" " "); do
    echo "Working on $x"
    if [ -d "$x" ]; then
        ls -ldH "$x" | awk '
$9 == "." {print "PATH contains current working directory (.)"}
$3 != "root" {print $9, "is not owned by root"}
substr($1,6,1) != "-" {print $9, "is group writable"}
substr($1,9,1) != "-" {print $9, "is world writable"}'
    else
        if [ -f "$x" ]; then
            echo "$x is a file and not a directory"
        else
            echo "$x is nor a directory neither a file"
            newpath=$(echo "$PATH" |sed -e "s#\(^\|:\)$(echo "$x" |sed -e 's/[^^]/[&]/g' -e 's/\^/\\^/g')\(:\|/\{0,1\}$\)#\1\2#" -e 's#:\+#:#g' -e 's#^:\|:$##g')
            sed -i  's%PATH=.*%PATH="'$(echo $newpath)'"%'"" /etc/environment
        fi
   fi
done
