folder('GCS-CI-CD/TestsDay') {
   displayName('TestsDay')
   description('Tests in level day of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsDay/throughput_300') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 300')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_300')
job('GCS-CI-CD/TestsDay/throughput_301') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 301')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_301')
job('GCS-CI-CD/TestsDay/throughput_302') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 302')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_302')
job('GCS-CI-CD/TestsDay/throughput_303') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 303')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_303')
job('GCS-CI-CD/TestsDay/throughput_304') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 304')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_304')
job('GCS-CI-CD/TestsDay/throughput_305') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 305')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_305')
job('GCS-CI-CD/TestsDay/throughput_306') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 306')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_306')
job('GCS-CI-CD/TestsDay/throughput_307') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 307')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_307')
job('GCS-CI-CD/TestsDay/throughput_308') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 308')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_308')
job('GCS-CI-CD/TestsDay/throughput_309') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 309')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_309')
job('GCS-CI-CD/TestsDay/throughput_310') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/ebablick/CS/cs0-0/testsuite/src/checktree/performance/throughput 310')
   }
}
queue('GCS-CI-CD/TestsDay/throughput_310')
