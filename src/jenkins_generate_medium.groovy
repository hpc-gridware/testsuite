folder('GCS-CI-CD/TestsMedium') {
   displayName('TestsMedium')
   description('Tests in level medium of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsMedium/sharetree') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/sharetree 100')
   }
}
queue('GCS-CI-CD/TestsMedium/sharetree')
job('GCS-CI-CD/TestsMedium/ssos_general') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/ssos/ssos_general 100')
   }
}
queue('GCS-CI-CD/TestsMedium/ssos_general')
job('GCS-CI-CD/TestsMedium/2411') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2411 100')
   }
}
queue('GCS-CI-CD/TestsMedium/2411')
job('GCS-CI-CD/TestsMedium/throughput') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 100')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput')
job('GCS-CI-CD/TestsMedium/module_test_generic') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/module_tests/module_test_generic 100')
   }
}
queue('GCS-CI-CD/TestsMedium/module_test_generic')
job('GCS-CI-CD/TestsMedium/usage') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/usage 100')
   }
}
queue('GCS-CI-CD/TestsMedium/usage')
