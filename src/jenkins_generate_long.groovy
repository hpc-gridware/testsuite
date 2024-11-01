folder('GCS-CI-CD/TestsLong') {
   displayName('TestsLong')
   description('Tests in level long of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsLong/module_test_generic_200') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/module_tests/module_test_generic 200')
   }
}
queue('GCS-CI-CD/TestsLong/module_test_generic_200')
job('GCS-CI-CD/TestsLong/current_version_upgrade_200') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/upgrade_test/current_version_upgrade 200')
   }
}
queue('GCS-CI-CD/TestsLong/current_version_upgrade_200')
job('GCS-CI-CD/TestsLong/throughput_200') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 200')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_200')
job('GCS-CI-CD/TestsLong/throughput_201') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 201')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_201')
job('GCS-CI-CD/TestsLong/throughput_202') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 202')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_202')
job('GCS-CI-CD/TestsLong/throughput_203') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 203')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_203')
job('GCS-CI-CD/TestsLong/throughput_204') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 204')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_204')
job('GCS-CI-CD/TestsLong/throughput_205') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 205')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_205')
job('GCS-CI-CD/TestsLong/throughput_206') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 206')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_206')
job('GCS-CI-CD/TestsLong/throughput_207') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 207')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_207')
job('GCS-CI-CD/TestsLong/throughput_208') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 208')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_208')
job('GCS-CI-CD/TestsLong/throughput_209') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 209')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_209')
job('GCS-CI-CD/TestsLong/throughput_210') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 210')
   }
}
queue('GCS-CI-CD/TestsLong/throughput_210')
job('GCS-CI-CD/TestsLong/qrsh_200') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/system_tests/clients/qrsh 200')
   }
}
queue('GCS-CI-CD/TestsLong/qrsh_200')
