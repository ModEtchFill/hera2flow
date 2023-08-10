rm -rf $GOPATH/allcover
mkdir $GOPATH/allcover
overall=0
for d in `ls -F tests/unittest | grep /$ | sed -e "s,/,," | egrep -v '(mysql_recycle|log_checker_initdb|testutil|rac_maint|mysql_direct|failover)'`
do 
    echo ==== $d
    pushd tests/unittest/$d 
    #cp /home/runner/go/bin/mysqlworker .
    cp $GOPATH/bin/mysqlworker .
    rm -f *.log 

    go run github.com/paypal/hera/tests/testutil/regen rewrite tests/unittest/$d
    go build -cover github.com/paypal/hera/tests/unittest/$d
    mkdir integcov
    GOCOVERDIR=integcov ./$d
    go tool covdata percent -i=integcov
    go tool covdata merge -i=integcov,$GOPATH/allcover -o $GOPATH/allcover

    #$GOROOT/bin/go test -c github.com/paypal/hera/tests/unittest/$d 
    #./$d.test -test.v
    #rv=$?
#    grep -E '(FAIL|PASS)' -A1 *.log
#    if [ 0 != $rv ]
#    then
#        echo "Retrying" $d
#        echo "exit code" $rv 
#        ./$d.test -test.v
#        rv=$?
#        grep -E '(FAIL|PASS)' -A1 *.log
#    fi
#    if [ 0 != $rv ]
#    then
#        #grep ^ *.log
#        popd
#        #exit $rv
#        overall=1
#        continue
#    fi
    rm -f *.log 
    popd
done
go tool covdata func -i=$GOPATH/allcover
go tool covdata percent -i=$GOPATH/allcover
exit $overall
