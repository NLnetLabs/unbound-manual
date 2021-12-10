# Unbound Website Sitetools man2pre.sh
# makes nicely formatted manual page in a <pre> block.
# first argument: manual page source.
# second argument: destination file.

if test "$#" -ne 2; then
	echo "usage: man2pre <manpage.8> <destfile.html>"
	echo "for unbound website tools"
	exit 1
fi
echo "man2pre from $1 to $2"

sed s!\<title\>\</title\>!\<title\>$(basename $1)\</title\>! man_header.html > $2
echo '<pre class="man">' >> $2
# exclude the ul and sed statements for plain ascii.
# col -b removes backspaces. expand removes tabs.
# the ul fails on Fedora now, we can parse the groff output right away.
if groff -man -Tascii $1 | ul -txterm >/dev/null 2>&1; then
groff -man -Tascii $1 | ul -txterm | sed -e "s?<?\&lt;?g" -e "s?>?\&gt;?g" | sed -e 's?\[1m?<b>?g' -e 's?(B\[m?</b>?g' | sed -e 's?\[4m\[22m?</b><i>?g' -e 's?\[m?</b>?g' -e 's?\[m\000?</b>?g' -e 's?\[4m?<i>?g' -e 's?\[24m?</i>?g' -e 's?<\([bi]\)>\([^<]*\)\[0m?<\1>\2</\1>?g' -e 's?\[22m?</b>?g' | col -b | expand >> $2
else
groff -man -Tascii $1 | sed -e "s?<?\&lt;?g" -e "s?>?\&gt;?g" | sed -e 's?\[1m?<b>?g' -e 's?(B\[m?</b>?g' | sed -e 's?\[4m\[22m?</b><i>?g' -e 's?\[m?</b>?g' -e 's?\[m\000?</b>?g' -e 's?\[4m?<i>?g' -e 's?\[24m?</i>?g' -e 's?<\([bi]\)>\([^<]*\)\[0m?<\1>\2</\1>?g' -e 's?\[22m?</b>?g' | col -b | expand >> $2
fi
echo '</pre>' >> $2
#echo '<div id="writings"><div class="footer" style="border:0; font-size: 60%;">Generated from manual pages of version ' >> $2
#cat version.txt >> $2
cat man_footer.html >> $2
