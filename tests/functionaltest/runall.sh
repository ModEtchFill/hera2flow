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
if [ x-$1 == x-all ]
then
    suites="bind_eviction_tests strandedchild_tests coordinator_tests saturation_tests adaptive_queue_tests rac_tests sharding_tests"
    for suite in $suites
    do
        ls -F $GOPATH/src/github.com/paypal/hera/tests/functionaltest/$suite | grep /$ | sed -e 's,/,,' | egrep -v '(testutil|no_shard_no_error|set_shard_id_wl|reset_shard_id_wl)' | sed -e "s,^,$suite/," >> toRun
    done
else 
    echo $* > toRun
fi
finalResult=0
for d in `cat toRun`
do 
    pushd $GOPATH/src/github.com/paypal/hera/tests/functionaltest/$d
    ln $GOPATH/bin/mysqlworker .
    $GOROOT/bin/go test -c .
    ./$d.test -test.v
    rv=$?
    if [ 0 != $rv ]
    then
       echo failing $suite $d
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
