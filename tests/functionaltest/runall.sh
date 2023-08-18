if [ x$GOPATH = x ]
then
  # when running in github actions workflow
  export GOPATH=$PWD/testrun
  mkdir -p testrun/src/github.com/paypal
  ln -s $PWD testrun/src/github.com/paypal/hera
fi
$GOROOT/bin/go install github.com/paypal/hera/worker/mysqlworker
$GOROOT/bin/go install github.com/paypal/hera/watchdog
$GOROOT/bin/go install github.com/paypal/hera/mux
ls -l $GOPATH/bin

cat << EOF > shortRun
sharding_tests/set_shard_id
strandedchild_tests/no_free_worker3
bind_eviction_tests/bind_eviction_disable
EOF

basedir=$GOPATH/src/github.com/paypal/hera/tests/functionaltest/
find $basedir -name main_test.go  | sed -e "s,^$basedir,,;s,/main_test.go,," | grep -vFf shortRun > toRun
grep set_shard_id toRun shortRun
wc toRun shortRun

# suites="bind_eviction_tests strandedchild_tests coordinator_tests saturation_tests adaptive_queue_tests rac_tests sharding_tests"
# ls -F $GOPATH/src/github.com/paypal/hera/tests/functionaltest/$suite | grep /$ | sed -e 's,/,,' | egrep -v '(testutil|
#     no_shard_no_error|set_shard_id_wl|reset_shard_id_wl)' | sed -e "s,^,$suite/," >> toRun

finalResult=0
for pathD in `cat shortRun`
do 
    pushd $GOPATH/src/github.com/paypal/hera/tests/functionaltest/$pathD
    d=`basename $pathD`
    ln $GOPATH/bin/mysqlworker .
    $GOROOT/bin/go test -c .
    ./$d.test -test.v
    rv=$?
    if [ 0 != $rv ]
    then
       echo failing $pathD
       grep ^ *.log
       finalResult=$rv
    fi
    rm *.log
    popd
    df -m
    time du -m | sort -n | tail
    pkill watchdog
    pkill -ILL mux
done
exit $finalResult
