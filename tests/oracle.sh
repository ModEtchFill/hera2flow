if [ x$GOPATH = x ]
then
  # when running in github actions workflow
  export GOPATH=$PWD/testrun
  mkdir -p testrun/src/github.com/paypal
  ln -s $PWD testrun/src/github.com/paypal/hera
fi
# $GOROOT/bin/go install github.com/paypal/hera/worker/mysqlworker
# ls -l $GOPATH/bin/mysqlworker

# check oracle
docker ps
ss -tln

# how do we install oracle libraries
dpkg -l | head
dnf -qa | head
id
find .

# make oracle worker
pushd worker/cppworker/worker
sudo apt install libboost-regex-dev -y
wget https://download.oracle.com/otn_software/linux/instantclient/1919000/instantclient-basiclite-linux.x64-19.19.0.0.0dbru.zip https://download.oracle.com/otn_software/linux/instantclient/1919000/instantclient-sdk-linux.x64-19.19.0.0.0dbru.zip
( echo SHA384 (instantclient-basiclite-linux.x64-19.19.0.0.0dbru.zip) = bb68094a12e754fc633874e8c2b4c4d38a45a65a5a536195d628d968fca72d7a5006a62a7b1fdd92a29134a06605d2b4 ; echo SHA384 (instantclient-sdk-linux.x64-19.19.0.0.0dbru.zip) = 5999f2333a9b73426c7af589ab13480f015c2cbd82bb395c7347ade37cc7040a833a398e9ce947ae2781365bd3a2e371 ) | sha384sum -c -
pubdir=$PWD
pushd /opt
ln -s instantclient_19_19 instantclient_19_17
unzip $pubdir/*.zip
popd
make -f ../build/makefile19

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
