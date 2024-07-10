folder('GCS-CI-CD/TestsWeek') {
   displayName('TestsWeek')
   description('Tests in level week of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsWeek/size') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/size 400')
   }
}
queue('GCS-CI-CD/TestsWeek/size')
