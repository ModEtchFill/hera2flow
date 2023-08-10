export GOROOT=/home/runner/work/hera2flow/hera2flow/go
mkdir -p /home/runner/go/src/github.com/paypal
ln -s /home/runner/work/hera2flow/hera2flow /home/runner/go/src/github.com/paypal/hera
export GOPATH=/home/runner/go

rm -rf $GOPATH/allcover{,2}
mkdir $GOPATH/allcover

$GOROOT/bin/go install -cover github.com/paypal/hera/worker/mysqlworker
ls -l $GOPATH/bin
pwd

overall=0
for d in `ls -F tests/unittest | grep /$ | sed -e "s,/,," | egrep -v '(mysql_recycle|log_checker_initdb|testutil|rac_maint|mysql_direct|failover)'`
do 
    echo ==== $d
    pushd tests/unittest/$d 
    #cp /home/runner/go/bin/mysqlworker .
    cp $GOPATH/bin/mysqlworker .
    rm -f *.log 

    $GOROOT/bin/go run ../testutil/regen rewrite tests/unittest/$d
    $GOROOT/bin/go build -cover github.com/paypal/hera/tests/unittest/$d
    mkdir integcov
    GOCOVERDIR=integcov ./$d
    rv=$?
    echo rv rv $rv for test $d under integration coverage run
    $GOROOT/bin/go tool covdata percent -i=integcov
    mkdir $GOPATH/allcover2
    $GOROOT/bin/go tool covdata merge -i=integcov,$GOPATH/allcover -o $GOPATH/allcover2
    rm -rf $GOPATH/allcover
    mv $GOPATH/allcover{2,}

    rm -f *.log 
    popd
done
$GOROOT/bin/go tool covdata func -i=$GOPATH/allcover
$GOROOT/bin/go tool covdata percent -i=$GOPATH/allcover
exit $overall
