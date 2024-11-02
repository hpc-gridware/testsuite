folder('GCS-CI-CD/TestsMedium') {
   displayName('TestsMedium')
   description('Tests in level medium of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsMedium/sharetree_100') {
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
queue('GCS-CI-CD/TestsMedium/sharetree_100')
job('GCS-CI-CD/TestsMedium/ssos_general_100') {
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
queue('GCS-CI-CD/TestsMedium/ssos_general_100')
job('GCS-CI-CD/TestsMedium/2411_100') {
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
queue('GCS-CI-CD/TestsMedium/2411_100')
job('GCS-CI-CD/TestsMedium/throughput_100') {
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
queue('GCS-CI-CD/TestsMedium/throughput_100')
job('GCS-CI-CD/TestsMedium/throughput_101') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 101')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_101')
job('GCS-CI-CD/TestsMedium/throughput_102') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 102')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_102')
job('GCS-CI-CD/TestsMedium/throughput_103') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 103')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_103')
job('GCS-CI-CD/TestsMedium/throughput_104') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 104')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_104')
job('GCS-CI-CD/TestsMedium/throughput_105') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 105')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_105')
job('GCS-CI-CD/TestsMedium/throughput_106') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 106')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_106')
job('GCS-CI-CD/TestsMedium/throughput_107') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 107')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_107')
job('GCS-CI-CD/TestsMedium/throughput_108') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 108')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_108')
job('GCS-CI-CD/TestsMedium/throughput_109') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 109')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_109')
job('GCS-CI-CD/TestsMedium/throughput_110') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 110')
   }
}
queue('GCS-CI-CD/TestsMedium/throughput_110')
job('GCS-CI-CD/TestsMedium/module_test_generic_100') {
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
queue('GCS-CI-CD/TestsMedium/module_test_generic_100')
job('GCS-CI-CD/TestsMedium/usage_100') {
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
queue('GCS-CI-CD/TestsMedium/usage_100')
job('GCS-CI-CD/TestsMedium/usage_101') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/usage 101')
   }
}
queue('GCS-CI-CD/TestsMedium/usage_101')
job('GCS-CI-CD/TestsMedium/usage_102') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/usage 102')
   }
}
queue('GCS-CI-CD/TestsMedium/usage_102')
