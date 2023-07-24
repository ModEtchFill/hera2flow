if [ x$GOPATH = x ]
then
  # when running in github actions workflow
  export GOPATH=$PWD/testrun
  mkdir -p testrun/src/github.com/paypal
  ln -s $PWD testrun/src/github.com/paypal/hera
fi
# $GOROOT/bin/go install github.com/paypal/hera/worker/mysqlworker
# ls -l $GOPATH/bin/mysqlworker

#chkOracle# docker ps
#chkOracle# ss -tln

# make oracle worker
pushd worker/cppworker/worker
sudo apt install libboost-regex-dev -y
wget -nv https://download.oracle.com/otn_software/linux/instantclient/1919000/instantclient-basiclite-linux.x64-19.19.0.0.0dbru.zip 
curl -O https://download.oracle.com/otn_software/linux/instantclient/1919000/instantclient-sdk-linux.x64-19.19.0.0.0dbru.zip
echo bb68094a12e754fc633874e8c2b4c4d38a45a65a5a536195d628d968fca72d7a5006a62a7b1fdd92a29134a06605d2b4  instantclient-basiclite-linux.x64-19.19.0.0.0dbru.zip >> SHA384
echo 5999f2333a9b73426c7af589ab13480f015c2cbd82bb395c7347ade37cc7040a833a398e9ce947ae2781365bd3a2e371  instantclient-sdk-linux.x64-19.19.0.0.0dbru.zip >> SHA384
## ???? sqlplus for verification
sha384sum -c SHA384
pubdir=$PWD
pushd /opt
ln -s instantclient_19_19 instantclient_19_17
unzip $pubdir/instantclient-basiclite-linux.x64-19.19.0.0.0dbru.zip
unzip $pubdir/instantclient-sdk-linux.x64-19.19.0.0.0dbru.zip
popd
make -f ../build/makefile19 -j 3
mkdir -p $GOPATH/bin
cp -v oracleworker $GOPATH/bin/
popd

export ORACLE_HOME=/opt/instantclient_19_17
mkdir -p $ORACLE_HOME/network/admin
echo 'TEST3=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XEPDB1)(FAILOVER_MODE=(TYPE=SESSION)(METHOD=BASIC)(RETRIES=1000)(DELAY=5))))' > $ORACLE_HOME/network/admin/tnsnames.ora
export TWO_TASK=TEST3

# run test with oracle
d=oracleHighLoadAdj
pushd $GOPATH/src/github.com/paypal/hera/tests/unittest2/$d
cp -v $GOPATH/bin/oracleworker .
$GOROOT/bin/go test -c .
./$d.test -test.v | tee /dev/null
rv=$?
if [ 0 != $rv ]
then
    echo failing $suite $d
    grep ^ *.log
fi
exit $rv
