if [ x$GOPATH = x ]
then
  # when running in github actions workflow
  export GOPATH=$PWD/testrun
  mkdir -p testrun/src/github.com/paypal
  ln -s $PWD testrun/src/github.com/paypal/hera
fi
$GOROOT/bin/go install github.com/paypal/hera/worker/mysqlworker
ls -l $GOPATH/bin/mysqlworker
ping -c1 -w1 odb3
# TODO make oracle worker

#origSh# suites="bind_eviction_tests strandedchild_tests coordinator_tests saturation_tests adaptive_queue_tests rac_tests sharding_tests"
#origSh# finalResult=0
#origSh# for suite in $suites
#origSh# do 
#origSh#   for d in `ls -F $GOPATH/src/github.com/paypal/hera/tests/functionaltest/$suite | grep /$ | sed -e 's,/,,' | egrep -v '(testutil|no_shard_no_error|set_shard_id_wl|reset_shard_id_wl)'`
#origSh#   do 
#origSh#       pushd $GOPATH/src/github.com/paypal/hera/tests/functionaltest/$suite/$d
#origSh#       cp $GOPATH/bin/mysqlworker .
#origSh#       $GOROOT/bin/go test -c .
#origSh#       ./$d.test -test.v
#origSh#       rv=$?
#origSh#       if [ 0 != $rv ]
#origSh#       then
#origSh#          echo failing $suite $d
#origSh#          grep ^ *.log
#origSh#          finalResult=$rv
#origSh# #        exit $rv
#origSh#       fi
#origSh#       popd
#origSh#       sleep 10
#origSh#   done
#origSh# done
#origSh# exit $finalResult
