folder('GCS-CI-CD/TestsDay') {
   displayName('TestsDay')
   description('Tests in level day of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsDay/throughput') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 300')
   }
}
queue('GCS-CI-CD/TestsDay/throughput')
