#!/bin/sh
# rebuild the pear documentation (manual) from svn
#
# deps:
# - pear/console_commandline
# - docs.php.net/phd
# - gz, bzip2, tar, zip
cd `dirname "$0"`


[ ! -d live ] && mkdir live
[ ! -d live/manual ] && mkdir live/manual

if [ ! -d trunk ]; then
    svn co https://svn.php.net/repository/pear/peardoc/trunk
fi

cd trunk
svn up

rm -rf build
for lang in en; do #$(ls -d ?? ??_??); do
    echo "$lang";
    php configure.php --quiet -l "$lang"
    if [ $? -gt 0 ]; then
        echo "ERROR broken: $lang"
        echo "Subject: peardoc $lang build is broken" | sendmail cweiske@php.net
        continue;
    fi

    for format in php tocfeed bigxhtml xhtml; do
        phd -L "$lang" -P PEAR -f $format -o build/"$lang" -d .manual.xml
    done

    #pearweb manual
    [ -d ../live/$lang-old ] && rm -r ../live/$lang-old
    [ -d ../live/$lang ] && mv ../live/$lang ../live/$lang-old
    mv build/$lang/pear-web ../live/$lang

    #download
    cd build/$lang

    ## single html file
    ### bz2
    targetfile=pear_manual_$lang.html.tar.bz2
    [ -f $targetfile ] && rm $targetfile
    tar cjf $targetfile pear-bigxhtml.html pear-bigxhtml-data
    mv -f $targetfile ../../../live/manual/

    ### gz
    targetfile=pear_manual_$lang.html.tar.gz
    [ -f $targetfile ] && rm $targetfile
    tar czf $targetfile pear-bigxhtml.html pear-bigxhtml-data
    mv -f $targetfile ../../../live/manual/

    ### zip
    targetfile=pear_manual_$lang.html.zip
    [ -f $targetfile ] && rm $targetfile
    zip --quiet $targetfile pear-bigxhtml.html pear-bigxhtml-data
    mv -f $targetfile ../../../live/manual/


    ## many html files
    mv pear-chunked-xhtml pear_manual_$lang

    ### bz2
    targetfile=pear_manual_$lang.tar.bz2
    [ -f $targetfile ] && rm $targetfile
    tar cjf $targetfile pear_manual_$lang
    mv -f $targetfile ../../../live/manual/

    ### gz
    targetfile=pear_manual_$lang.tar.gz
    [ -f $targetfile ] && rm $targetfile
    tar cvf $targetfile pear_manual_$lang
    mv -f $targetfile ../../../live/manual/

    ### zip
    targetfile=pear_manual_$lang.zip
    [ -f $targetfile ] && rm $targetfile
    zip --quiet $targetfile pear_manual_$lang
    mv -f $targetfile ../../../live/manual/

done