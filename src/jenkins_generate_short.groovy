folder('GCS-CI-CD/TestsShort') {
   displayName('TestsShort')
   description('Tests in level short of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsShort/2387') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2387 0')
   }
}
queue('GCS-CI-CD/TestsShort/2387')
job('GCS-CI-CD/TestsShort/resource_reservation') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/resource_reservation 2')
   }
}
queue('GCS-CI-CD/TestsShort/resource_reservation')
job('GCS-CI-CD/TestsShort/access_lists') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/access_lists 0')
   }
}
queue('GCS-CI-CD/TestsShort/access_lists')
job('GCS-CI-CD/TestsShort/host_test') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/host_test 0')
   }
}
queue('GCS-CI-CD/TestsShort/host_test')
job('GCS-CI-CD/TestsShort/qsub_e_o_j') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_e_o_j 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_e_o_j')
job('GCS-CI-CD/TestsShort/1751') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1751 0')
   }
}
queue('GCS-CI-CD/TestsShort/1751')
job('GCS-CI-CD/TestsShort/issues') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/issues 0')
   }
}
queue('GCS-CI-CD/TestsShort/issues')
job('GCS-CI-CD/TestsShort/2542') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2542 0')
   }
}
queue('GCS-CI-CD/TestsShort/2542')
job('GCS-CI-CD/TestsShort/2706') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2706 0')
   }
}
queue('GCS-CI-CD/TestsShort/2706')
job('GCS-CI-CD/TestsShort/2300') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2300 0')
   }
}
queue('GCS-CI-CD/TestsShort/2300')
job('GCS-CI-CD/TestsShort/3306') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/jira/3306 0')
   }
}
queue('GCS-CI-CD/TestsShort/3306')
job('GCS-CI-CD/TestsShort/3479') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/jira/3479 0')
   }
}
queue('GCS-CI-CD/TestsShort/3479')
job('GCS-CI-CD/TestsShort/qrsub') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qrsub 0')
   }
}
queue('GCS-CI-CD/TestsShort/qrsub')
job('GCS-CI-CD/TestsShort/1489') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1489 0')
   }
}
queue('GCS-CI-CD/TestsShort/1489')
job('GCS-CI-CD/TestsShort/2717') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2717 0')
   }
}
queue('GCS-CI-CD/TestsShort/2717')
job('GCS-CI-CD/TestsShort/monitoring') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/monitoring 0')
   }
}
queue('GCS-CI-CD/TestsShort/monitoring')
job('GCS-CI-CD/TestsShort/440') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/440 0')
   }
}
queue('GCS-CI-CD/TestsShort/440')
job('GCS-CI-CD/TestsShort/1914') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1914 0')
   }
}
queue('GCS-CI-CD/TestsShort/1914')
job('GCS-CI-CD/TestsShort/per_job_consumables') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_job_consumables 0')
   }
}
queue('GCS-CI-CD/TestsShort/per_job_consumables')
job('GCS-CI-CD/TestsShort/1141') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1141 0')
   }
}
queue('GCS-CI-CD/TestsShort/1141')
job('GCS-CI-CD/TestsShort/sharetree') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/sharetree 0')
   }
}
queue('GCS-CI-CD/TestsShort/sharetree')
job('GCS-CI-CD/TestsShort/expressions') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/expressions 0')
   }
}
queue('GCS-CI-CD/TestsShort/expressions')
job('GCS-CI-CD/TestsShort/basic') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/rsmap/basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/basic')
job('GCS-CI-CD/TestsShort/framework') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/framework 0')
   }
}
queue('GCS-CI-CD/TestsShort/framework')
job('GCS-CI-CD/TestsShort/qsub_sync') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_sync 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_sync')
job('GCS-CI-CD/TestsShort/1972') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1972 0')
   }
}
queue('GCS-CI-CD/TestsShort/1972')
job('GCS-CI-CD/TestsShort/3216') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3216 0')
   }
}
queue('GCS-CI-CD/TestsShort/3216')
job('GCS-CI-CD/TestsShort/host_alias_file') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/resolving/host_alias_file 0')
   }
}
queue('GCS-CI-CD/TestsShort/host_alias_file')
job('GCS-CI-CD/TestsShort/1760') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1760 0')
   }
}
queue('GCS-CI-CD/TestsShort/1760')
job('GCS-CI-CD/TestsShort/commlib') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/commlib 0')
   }
}
queue('GCS-CI-CD/TestsShort/commlib')
job('GCS-CI-CD/TestsShort/524') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/524 0')
   }
}
queue('GCS-CI-CD/TestsShort/524')
job('GCS-CI-CD/TestsShort/1251') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1251 0')
   }
}
queue('GCS-CI-CD/TestsShort/1251')
job('GCS-CI-CD/TestsShort/general') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/ssos/general 0')
   }
}
queue('GCS-CI-CD/TestsShort/general')
job('GCS-CI-CD/TestsShort/qalter') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qalter 0')
   }
}
queue('GCS-CI-CD/TestsShort/qalter')
job('GCS-CI-CD/TestsShort/qdel') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qdel 0')
   }
}
queue('GCS-CI-CD/TestsShort/qdel')
job('GCS-CI-CD/TestsShort/171') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/171 0')
   }
}
queue('GCS-CI-CD/TestsShort/171')
job('GCS-CI-CD/TestsShort/migrate') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/shadowd/migrate 0')
   }
}
queue('GCS-CI-CD/TestsShort/migrate')
job('GCS-CI-CD/TestsShort/2564') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2564 0')
   }
}
queue('GCS-CI-CD/TestsShort/2564')
job('GCS-CI-CD/TestsShort/spooling') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/spooling 0')
   }
}
queue('GCS-CI-CD/TestsShort/spooling')
job('GCS-CI-CD/TestsShort/193') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/193 0')
   }
}
queue('GCS-CI-CD/TestsShort/193')
job('GCS-CI-CD/TestsShort/2465') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2465 0')
   }
}
queue('GCS-CI-CD/TestsShort/2465')
job('GCS-CI-CD/TestsShort/smf') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/smf 0')
   }
}
queue('GCS-CI-CD/TestsShort/smf')
job('GCS-CI-CD/TestsShort/2183') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2183 0')
   }
}
queue('GCS-CI-CD/TestsShort/2183')
job('GCS-CI-CD/TestsShort/tickets') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/tickets 0')
   }
}
queue('GCS-CI-CD/TestsShort/tickets')
job('GCS-CI-CD/TestsShort/backup_restore') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/backup_restore 0')
   }
}
queue('GCS-CI-CD/TestsShort/backup_restore')
job('GCS-CI-CD/TestsShort/wait_for_remote_file_test') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/wait_for_remote_file_test 0')
   }
}
queue('GCS-CI-CD/TestsShort/wait_for_remote_file_test')
job('GCS-CI-CD/TestsShort/qsub_huge_script') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_huge_script 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_huge_script')
job('GCS-CI-CD/TestsShort/509') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/509 0')
   }
}
queue('GCS-CI-CD/TestsShort/509')
job('GCS-CI-CD/TestsShort/shutdown') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/shutdown 0')
   }
}
queue('GCS-CI-CD/TestsShort/shutdown')
job('GCS-CI-CD/TestsShort/2419') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2419 0')
   }
}
queue('GCS-CI-CD/TestsShort/2419')
job('GCS-CI-CD/TestsShort/423') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/423 0')
   }
}
queue('GCS-CI-CD/TestsShort/423')
job('GCS-CI-CD/TestsShort/1661') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1661 0')
   }
}
queue('GCS-CI-CD/TestsShort/1661')
job('GCS-CI-CD/TestsShort/jsv_ge_mod') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_ge_mod 0')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_ge_mod')
job('GCS-CI-CD/TestsShort/qping') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qping 0')
   }
}
queue('GCS-CI-CD/TestsShort/qping')
job('GCS-CI-CD/TestsShort/3223') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3223 0')
   }
}
queue('GCS-CI-CD/TestsShort/3223')
job('GCS-CI-CD/TestsShort/3129') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3129 0')
   }
}
queue('GCS-CI-CD/TestsShort/3129')
job('GCS-CI-CD/TestsShort/reporting') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/reporting 0')
   }
}
queue('GCS-CI-CD/TestsShort/reporting')
job('GCS-CI-CD/TestsShort/1156') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1156 0')
   }
}
queue('GCS-CI-CD/TestsShort/1156')
job('GCS-CI-CD/TestsShort/2158') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2158 0')
   }
}
queue('GCS-CI-CD/TestsShort/2158')
job('GCS-CI-CD/TestsShort/copy_certs') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/copy_certs 0')
   }
}
queue('GCS-CI-CD/TestsShort/copy_certs')
job('GCS-CI-CD/TestsShort/527') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/527 0')
   }
}
queue('GCS-CI-CD/TestsShort/527')
job('GCS-CI-CD/TestsShort/job_state_handling') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/job_state_handling 0')
   }
}
queue('GCS-CI-CD/TestsShort/job_state_handling')
job('GCS-CI-CD/TestsShort/per_host_consumables') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_host_consumables 0')
   }
}
queue('GCS-CI-CD/TestsShort/per_host_consumables')
job('GCS-CI-CD/TestsShort/custom-usage') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/accounting/custom-usage 0')
   }
}
queue('GCS-CI-CD/TestsShort/custom-usage')
job('GCS-CI-CD/TestsShort/execution_time') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/execution_time 0')
   }
}
queue('GCS-CI-CD/TestsShort/execution_time')
job('GCS-CI-CD/TestsShort/qsub_all_other') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_all_other 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_all_other')
job('GCS-CI-CD/TestsShort/1802') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1802 0')
   }
}
queue('GCS-CI-CD/TestsShort/1802')
job('GCS-CI-CD/TestsShort/fork') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/fork 0')
   }
}
queue('GCS-CI-CD/TestsShort/fork')
job('GCS-CI-CD/TestsShort/1096') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1096 0')
   }
}
queue('GCS-CI-CD/TestsShort/1096')
job('GCS-CI-CD/TestsShort/3172') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3172 0')
   }
}
queue('GCS-CI-CD/TestsShort/3172')
job('GCS-CI-CD/TestsShort/511') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/511 0')
   }
}
queue('GCS-CI-CD/TestsShort/511')
job('GCS-CI-CD/TestsShort/2979') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2979 0')
   }
}
queue('GCS-CI-CD/TestsShort/2979')
job('GCS-CI-CD/TestsShort/1848') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1848 0')
   }
}
queue('GCS-CI-CD/TestsShort/1848')
job('GCS-CI-CD/TestsShort/jsv_issues') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_issues 0')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_issues')
job('GCS-CI-CD/TestsShort/2378') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2378 0')
   }
}
queue('GCS-CI-CD/TestsShort/2378')
job('GCS-CI-CD/TestsShort/file_parsing') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/config/file_parsing 0')
   }
}
queue('GCS-CI-CD/TestsShort/file_parsing')
job('GCS-CI-CD/TestsShort/submit_hosts') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/config/submit_hosts 0')
   }
}
queue('GCS-CI-CD/TestsShort/submit_hosts')
job('GCS-CI-CD/TestsShort/1933') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1933 0')
   }
}
queue('GCS-CI-CD/TestsShort/1933')
job('GCS-CI-CD/TestsShort/cluster_config') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/cluster_config 0')
   }
}
queue('GCS-CI-CD/TestsShort/cluster_config')
job('GCS-CI-CD/TestsShort/2967') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2967 0')
   }
}
queue('GCS-CI-CD/TestsShort/2967')
job('GCS-CI-CD/TestsShort/3179') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3179 0')
   }
}
queue('GCS-CI-CD/TestsShort/3179')
job('GCS-CI-CD/TestsShort/extensive_qrsh') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/extensive_qrsh 0')
   }
}
queue('GCS-CI-CD/TestsShort/extensive_qrsh')
job('GCS-CI-CD/TestsShort/2682') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2682 0')
   }
}
queue('GCS-CI-CD/TestsShort/2682')
job('GCS-CI-CD/TestsShort/1401') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1401 0')
   }
}
queue('GCS-CI-CD/TestsShort/1401')
job('GCS-CI-CD/TestsShort/inst_submit_host') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/inst_submit_host 0')
   }
}
queue('GCS-CI-CD/TestsShort/inst_submit_host')
job('GCS-CI-CD/TestsShort/display_test') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/display_test 0')
   }
}
queue('GCS-CI-CD/TestsShort/display_test')
job('GCS-CI-CD/TestsShort/qsub_ac_dc_sc') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_ac_dc_sc 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_ac_dc_sc')
job('GCS-CI-CD/TestsShort/1359') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1359 0')
   }
}
queue('GCS-CI-CD/TestsShort/1359')
job('GCS-CI-CD/TestsShort/deadlock') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/deadlock 0')
   }
}
queue('GCS-CI-CD/TestsShort/deadlock')
job('GCS-CI-CD/TestsShort/1741') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1741 0')
   }
}
queue('GCS-CI-CD/TestsShort/1741')
job('GCS-CI-CD/TestsShort/360') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/360 0')
   }
}
queue('GCS-CI-CD/TestsShort/360')
job('GCS-CI-CD/TestsShort/2459') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2459 0')
   }
}
queue('GCS-CI-CD/TestsShort/2459')
job('GCS-CI-CD/TestsShort/2864') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2864 0')
   }
}
queue('GCS-CI-CD/TestsShort/2864')
job('GCS-CI-CD/TestsShort/jsv_full') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_full 0')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_full')
job('GCS-CI-CD/TestsShort/reschedule') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/reschedule 0')
   }
}
queue('GCS-CI-CD/TestsShort/reschedule')
job('GCS-CI-CD/TestsShort/2396') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2396 0')
   }
}
queue('GCS-CI-CD/TestsShort/2396')
job('GCS-CI-CD/TestsShort/2202') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2202 0')
   }
}
queue('GCS-CI-CD/TestsShort/2202')
job('GCS-CI-CD/TestsShort/host_aliases') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/config/host_aliases 0')
   }
}
queue('GCS-CI-CD/TestsShort/host_aliases')
job('GCS-CI-CD/TestsShort/1161') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1161 0')
   }
}
queue('GCS-CI-CD/TestsShort/1161')
job('GCS-CI-CD/TestsShort/advance_reservation') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/advance_reservation 0')
   }
}
queue('GCS-CI-CD/TestsShort/advance_reservation')
job('GCS-CI-CD/TestsShort/1146') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1146 0')
   }
}
queue('GCS-CI-CD/TestsShort/1146')
job('GCS-CI-CD/TestsShort/migration') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/migration 0')
   }
}
queue('GCS-CI-CD/TestsShort/migration')
job('GCS-CI-CD/TestsShort/226') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/226 0')
   }
}
queue('GCS-CI-CD/TestsShort/226')
job('GCS-CI-CD/TestsShort/submit_del') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/shepherd/submit_del 0')
   }
}
queue('GCS-CI-CD/TestsShort/submit_del')
job('GCS-CI-CD/TestsShort/antivirus') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/product/antivirus 0')
   }
}
queue('GCS-CI-CD/TestsShort/antivirus')
job('GCS-CI-CD/TestsShort/connection_test') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/connection_test 0')
   }
}
queue('GCS-CI-CD/TestsShort/connection_test')
job('GCS-CI-CD/TestsShort/qsub_hold') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_hold 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_hold')
job('GCS-CI-CD/TestsShort/1324') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1324 0')
   }
}
queue('GCS-CI-CD/TestsShort/1324')
job('GCS-CI-CD/TestsShort/2895') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2895 0')
   }
}
queue('GCS-CI-CD/TestsShort/2895')
job('GCS-CI-CD/TestsShort/1502') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1502 0')
   }
}
queue('GCS-CI-CD/TestsShort/1502')
job('GCS-CI-CD/TestsShort/1798') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1798 0')
   }
}
queue('GCS-CI-CD/TestsShort/1798')
job('GCS-CI-CD/TestsShort/3017') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3017 0')
   }
}
queue('GCS-CI-CD/TestsShort/3017')
job('GCS-CI-CD/TestsShort/jsv_ge_add') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_ge_add 0')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_ge_add')
job('GCS-CI-CD/TestsShort/drmaa') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/api/drmaa 0')
   }
}
queue('GCS-CI-CD/TestsShort/drmaa')
job('GCS-CI-CD/TestsShort/general') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/general 0')
   }
}
queue('GCS-CI-CD/TestsShort/general')
job('GCS-CI-CD/TestsShort/1780') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1780 0')
   }
}
queue('GCS-CI-CD/TestsShort/1780')
job('GCS-CI-CD/TestsShort/path_alias') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/config/path_alias 0')
   }
}
queue('GCS-CI-CD/TestsShort/path_alias')
job('GCS-CI-CD/TestsShort/1806') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1806 0')
   }
}
queue('GCS-CI-CD/TestsShort/1806')
job('GCS-CI-CD/TestsShort/profiling') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/profiling 0')
   }
}
queue('GCS-CI-CD/TestsShort/profiling')
job('GCS-CI-CD/TestsShort/size') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/size 0')
   }
}
queue('GCS-CI-CD/TestsShort/size')
job('GCS-CI-CD/TestsShort/540') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/540 0')
   }
}
queue('GCS-CI-CD/TestsShort/540')
job('GCS-CI-CD/TestsShort/2754') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2754 0')
   }
}
queue('GCS-CI-CD/TestsShort/2754')
job('GCS-CI-CD/TestsShort/general') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/corebinding/general 0')
   }
}
queue('GCS-CI-CD/TestsShort/general')
job('GCS-CI-CD/TestsShort/1270') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1270 0')
   }
}
queue('GCS-CI-CD/TestsShort/1270')
job('GCS-CI-CD/TestsShort/basic') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/job_environment/basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/basic')
job('GCS-CI-CD/TestsShort/rsmap') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/rsmap 0')
   }
}
queue('GCS-CI-CD/TestsShort/rsmap')
job('GCS-CI-CD/TestsShort/user_permissions') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/user_permissions 0')
   }
}
queue('GCS-CI-CD/TestsShort/user_permissions')
job('GCS-CI-CD/TestsShort/qstat') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qstat 0')
   }
}
queue('GCS-CI-CD/TestsShort/qstat')
job('GCS-CI-CD/TestsShort/1291') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1291 0')
   }
}
queue('GCS-CI-CD/TestsShort/1291')
job('GCS-CI-CD/TestsShort/sge_share_mon') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/utilbin/sge_share_mon 0')
   }
}
queue('GCS-CI-CD/TestsShort/sge_share_mon')
job('GCS-CI-CD/TestsShort/2161') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2161 0')
   }
}
queue('GCS-CI-CD/TestsShort/2161')
job('GCS-CI-CD/TestsShort/3013') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3013 0')
   }
}
queue('GCS-CI-CD/TestsShort/3013')
job('GCS-CI-CD/TestsShort/2582') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2582 0')
   }
}
queue('GCS-CI-CD/TestsShort/2582')
job('GCS-CI-CD/TestsShort/141') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/141 0')
   }
}
queue('GCS-CI-CD/TestsShort/141')
job('GCS-CI-CD/TestsShort/jsv_ge') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_ge 0')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_ge')
job('GCS-CI-CD/TestsShort/auto_reschedule') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/auto_reschedule 0')
   }
}
queue('GCS-CI-CD/TestsShort/auto_reschedule')
job('GCS-CI-CD/TestsShort/2735') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2735 0')
   }
}
queue('GCS-CI-CD/TestsShort/2735')
job('GCS-CI-CD/TestsShort/140') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/140 0')
   }
}
queue('GCS-CI-CD/TestsShort/140')
job('GCS-CI-CD/TestsShort/1556') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1556 0')
   }
}
queue('GCS-CI-CD/TestsShort/1556')
job('GCS-CI-CD/TestsShort/failover') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/failover 0')
   }
}
queue('GCS-CI-CD/TestsShort/failover')
job('GCS-CI-CD/TestsShort/2304') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2304 0')
   }
}
queue('GCS-CI-CD/TestsShort/2304')
job('GCS-CI-CD/TestsShort/314') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/314 0')
   }
}
queue('GCS-CI-CD/TestsShort/314')
job('GCS-CI-CD/TestsShort/1640') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1640 0')
   }
}
queue('GCS-CI-CD/TestsShort/1640')
job('GCS-CI-CD/TestsShort/qquota') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qquota 0')
   }
}
queue('GCS-CI-CD/TestsShort/qquota')
job('GCS-CI-CD/TestsShort/enhanced') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/job_environment/enhanced 0')
   }
}
queue('GCS-CI-CD/TestsShort/enhanced')
job('GCS-CI-CD/TestsShort/advance_reservation') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/common/advance_reservation 0')
   }
}
queue('GCS-CI-CD/TestsShort/advance_reservation')
job('GCS-CI-CD/TestsShort/2329') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2329 0')
   }
}
queue('GCS-CI-CD/TestsShort/2329')
job('GCS-CI-CD/TestsShort/scheduler_messages') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/scheduler_messages 0')
   }
}
queue('GCS-CI-CD/TestsShort/scheduler_messages')
job('GCS-CI-CD/TestsShort/spooledit') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/utilbin/spooledit 0')
   }
}
queue('GCS-CI-CD/TestsShort/spooledit')
job('GCS-CI-CD/TestsShort/2755') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2755 0')
   }
}
queue('GCS-CI-CD/TestsShort/2755')
job('GCS-CI-CD/TestsShort/2408') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2408 0')
   }
}
queue('GCS-CI-CD/TestsShort/2408')
job('GCS-CI-CD/TestsShort/3094') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3094 0')
   }
}
queue('GCS-CI-CD/TestsShort/3094')
job('GCS-CI-CD/TestsShort/1977') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1977 0')
   }
}
queue('GCS-CI-CD/TestsShort/1977')
job('GCS-CI-CD/TestsShort/2406') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2406 0')
   }
}
queue('GCS-CI-CD/TestsShort/2406')
job('GCS-CI-CD/TestsShort/jsv_script') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_script 0')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_script')
job('GCS-CI-CD/TestsShort/generic') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/module_tests/generic 0')
   }
}
queue('GCS-CI-CD/TestsShort/generic')
job('GCS-CI-CD/TestsShort/2372') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2372 0')
   }
}
queue('GCS-CI-CD/TestsShort/2372')
job('GCS-CI-CD/TestsShort/reconnect') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/execd/reconnect 0')
   }
}
queue('GCS-CI-CD/TestsShort/reconnect')
job('GCS-CI-CD/TestsShort/1892') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1892 0')
   }
}
queue('GCS-CI-CD/TestsShort/1892')
job('GCS-CI-CD/TestsShort/2743') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2743 0')
   }
}
queue('GCS-CI-CD/TestsShort/2743')
job('GCS-CI-CD/TestsShort/1877') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1877 0')
   }
}
queue('GCS-CI-CD/TestsShort/1877')
job('GCS-CI-CD/TestsShort/1104') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1104 0')
   }
}
queue('GCS-CI-CD/TestsShort/1104')
job('GCS-CI-CD/TestsShort/qhost') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qhost 0')
   }
}
queue('GCS-CI-CD/TestsShort/qhost')
job('GCS-CI-CD/TestsShort/ce_qconf_operations') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/ce/ce_qconf_operations 0')
   }
}
queue('GCS-CI-CD/TestsShort/ce_qconf_operations')
job('GCS-CI-CD/TestsShort/setup') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/common/setup 0')
   }
}
queue('GCS-CI-CD/TestsShort/setup')
job('GCS-CI-CD/TestsShort/1198') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1198 0')
   }
}
queue('GCS-CI-CD/TestsShort/1198')
job('GCS-CI-CD/TestsShort/reconnect') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/reconnect 0')
   }
}
queue('GCS-CI-CD/TestsShort/reconnect')
job('GCS-CI-CD/TestsShort/loadcheck') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/utilbin/loadcheck 0')
   }
}
queue('GCS-CI-CD/TestsShort/loadcheck')
job('GCS-CI-CD/TestsShort/1334') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1334 0')
   }
}
queue('GCS-CI-CD/TestsShort/1334')
job('GCS-CI-CD/TestsShort/1803') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1803 0')
   }
}
queue('GCS-CI-CD/TestsShort/1803')
job('GCS-CI-CD/TestsShort/2222') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2222 0')
   }
}
queue('GCS-CI-CD/TestsShort/2222')
job('GCS-CI-CD/TestsShort/resource_quota') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/resource_quota 0')
   }
}
queue('GCS-CI-CD/TestsShort/resource_quota')
job('GCS-CI-CD/TestsShort/2495') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2495 0')
   }
}
queue('GCS-CI-CD/TestsShort/2495')
job('GCS-CI-CD/TestsShort/reprioritization') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/reprioritization 0')
   }
}
queue('GCS-CI-CD/TestsShort/reprioritization')
job('GCS-CI-CD/TestsShort/appcert') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/module_tests/appcert 0')
   }
}
queue('GCS-CI-CD/TestsShort/appcert')
job('GCS-CI-CD/TestsShort/1422') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1422 0')
   }
}
queue('GCS-CI-CD/TestsShort/1422')
job('GCS-CI-CD/TestsShort/startup') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/execd/startup 0')
   }
}
queue('GCS-CI-CD/TestsShort/startup')
job('GCS-CI-CD/TestsShort/1451') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1451 0')
   }
}
queue('GCS-CI-CD/TestsShort/1451')
job('GCS-CI-CD/TestsShort/basic') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/simhosts/basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/basic')
job('GCS-CI-CD/TestsShort/2145') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2145 0')
   }
}
queue('GCS-CI-CD/TestsShort/2145')
job('GCS-CI-CD/TestsShort/2822') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2822 0')
   }
}
queue('GCS-CI-CD/TestsShort/2822')
job('GCS-CI-CD/TestsShort/2492') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2492 0')
   }
}
queue('GCS-CI-CD/TestsShort/2492')
job('GCS-CI-CD/TestsShort/2122') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2122 0')
   }
}
queue('GCS-CI-CD/TestsShort/2122')
job('GCS-CI-CD/TestsShort/qrdel') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qrdel 0')
   }
}
queue('GCS-CI-CD/TestsShort/qrdel')
job('GCS-CI-CD/TestsShort/2978') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2978 0')
   }
}
queue('GCS-CI-CD/TestsShort/2978')
job('GCS-CI-CD/TestsShort/qconf') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qconf 0')
   }
}
queue('GCS-CI-CD/TestsShort/qconf')
job('GCS-CI-CD/TestsShort/1823') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1823 0')
   }
}
queue('GCS-CI-CD/TestsShort/1823')
job('GCS-CI-CD/TestsShort/queue_requests') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/queue_requests 0')
   }
}
queue('GCS-CI-CD/TestsShort/queue_requests')
job('GCS-CI-CD/TestsShort/jemalloc') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/jemalloc 0')
   }
}
queue('GCS-CI-CD/TestsShort/jemalloc')
job('GCS-CI-CD/TestsShort/dtrace') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/dtrace 0')
   }
}
queue('GCS-CI-CD/TestsShort/dtrace')
job('GCS-CI-CD/TestsShort/3170') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3170 0')
   }
}
queue('GCS-CI-CD/TestsShort/3170')
job('GCS-CI-CD/TestsShort/1874') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1874 0')
   }
}
queue('GCS-CI-CD/TestsShort/1874')
job('GCS-CI-CD/TestsShort/2325') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2325 0')
   }
}
queue('GCS-CI-CD/TestsShort/2325')
job('GCS-CI-CD/TestsShort/throughput') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 0')
   }
}
queue('GCS-CI-CD/TestsShort/throughput')
job('GCS-CI-CD/TestsShort/advance_reservation') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/advance_reservation 0')
   }
}
queue('GCS-CI-CD/TestsShort/advance_reservation')
job('GCS-CI-CD/TestsShort/653') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/653 0')
   }
}
queue('GCS-CI-CD/TestsShort/653')
job('GCS-CI-CD/TestsShort/tight_integration') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/tight_integration 0')
   }
}
queue('GCS-CI-CD/TestsShort/tight_integration')
job('GCS-CI-CD/TestsShort/test_template') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/test_template 0')
   }
}
queue('GCS-CI-CD/TestsShort/test_template')
job('GCS-CI-CD/TestsShort/403') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/403 0')
   }
}
queue('GCS-CI-CD/TestsShort/403')
job('GCS-CI-CD/TestsShort/3185') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3185 0')
   }
}
queue('GCS-CI-CD/TestsShort/3185')
job('GCS-CI-CD/TestsShort/402') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/402 0')
   }
}
queue('GCS-CI-CD/TestsShort/402')
job('GCS-CI-CD/TestsShort/2136') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2136 0')
   }
}
queue('GCS-CI-CD/TestsShort/2136')
job('GCS-CI-CD/TestsShort/consumable_resources') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 0')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources')
job('GCS-CI-CD/TestsShort/2128') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2128 0')
   }
}
queue('GCS-CI-CD/TestsShort/2128')
job('GCS-CI-CD/TestsShort/qmake') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmake 0')
   }
}
queue('GCS-CI-CD/TestsShort/qmake')
job('GCS-CI-CD/TestsShort/1330') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1330 0')
   }
}
queue('GCS-CI-CD/TestsShort/1330')
job('GCS-CI-CD/TestsShort/qresub') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qresub 0')
   }
}
queue('GCS-CI-CD/TestsShort/qresub')
job('GCS-CI-CD/TestsShort/1473') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1473 0')
   }
}
queue('GCS-CI-CD/TestsShort/1473')
job('GCS-CI-CD/TestsShort/2896') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2896 0')
   }
}
queue('GCS-CI-CD/TestsShort/2896')
job('GCS-CI-CD/TestsShort/config') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/config 0')
   }
}
queue('GCS-CI-CD/TestsShort/config')
job('GCS-CI-CD/TestsShort/2328') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2328 0')
   }
}
queue('GCS-CI-CD/TestsShort/2328')
job('GCS-CI-CD/TestsShort/1529') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1529 0')
   }
}
queue('GCS-CI-CD/TestsShort/1529')
job('GCS-CI-CD/TestsShort/2028') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2028 0')
   }
}
queue('GCS-CI-CD/TestsShort/2028')
job('GCS-CI-CD/TestsShort/2753') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2753 0')
   }
}
queue('GCS-CI-CD/TestsShort/2753')
job('GCS-CI-CD/TestsShort/pe_ranges') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/pe_ranges 0')
   }
}
queue('GCS-CI-CD/TestsShort/pe_ranges')
job('GCS-CI-CD/TestsShort/subordinate') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/subordinate 0')
   }
}
queue('GCS-CI-CD/TestsShort/subordinate')
job('GCS-CI-CD/TestsShort/home_dirs') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/home_dirs 0')
   }
}
queue('GCS-CI-CD/TestsShort/home_dirs')
job('GCS-CI-CD/TestsShort/qsub_w') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_w 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_w')
job('GCS-CI-CD/TestsShort/qsub_t') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_t 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_t')
job('GCS-CI-CD/TestsShort/1081') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1081 0')
   }
}
queue('GCS-CI-CD/TestsShort/1081')
job('GCS-CI-CD/TestsShort/project_access_lists') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/geee/project_access_lists 0')
   }
}
queue('GCS-CI-CD/TestsShort/project_access_lists')
job('GCS-CI-CD/TestsShort/2344') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2344 0')
   }
}
queue('GCS-CI-CD/TestsShort/2344')
job('GCS-CI-CD/TestsShort/current_version_upgrade') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/upgrade_test/current_version_upgrade 0')
   }
}
queue('GCS-CI-CD/TestsShort/current_version_upgrade')
job('GCS-CI-CD/TestsShort/2952') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2952 0')
   }
}
queue('GCS-CI-CD/TestsShort/2952')
job('GCS-CI-CD/TestsShort/2345') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2345 0')
   }
}
queue('GCS-CI-CD/TestsShort/2345')
job('GCS-CI-CD/TestsShort/2433') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2433 0')
   }
}
queue('GCS-CI-CD/TestsShort/2433')
job('GCS-CI-CD/TestsShort/usage') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/usage 0')
   }
}
queue('GCS-CI-CD/TestsShort/usage')
job('GCS-CI-CD/TestsShort/qrstat') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qrstat 0')
   }
}
queue('GCS-CI-CD/TestsShort/qrstat')
job('GCS-CI-CD/TestsShort/2050') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2050 0')
   }
}
queue('GCS-CI-CD/TestsShort/2050')
job('GCS-CI-CD/TestsShort/qselect') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qselect 0')
   }
}
queue('GCS-CI-CD/TestsShort/qselect')
job('GCS-CI-CD/TestsShort/2061') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2061 0')
   }
}
queue('GCS-CI-CD/TestsShort/2061')
job('GCS-CI-CD/TestsShort/deadline') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/deadline 0')
   }
}
queue('GCS-CI-CD/TestsShort/deadline')
job('GCS-CI-CD/TestsShort/complex') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/complex 0')
   }
}
queue('GCS-CI-CD/TestsShort/complex')
job('GCS-CI-CD/TestsShort/1193') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1193 0')
   }
}
queue('GCS-CI-CD/TestsShort/1193')
job('GCS-CI-CD/TestsShort/478') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/478 0')
   }
}
queue('GCS-CI-CD/TestsShort/478')
job('GCS-CI-CD/TestsShort/2418') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2418 0')
   }
}
queue('GCS-CI-CD/TestsShort/2418')
job('GCS-CI-CD/TestsShort/2759') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2759 0')
   }
}
queue('GCS-CI-CD/TestsShort/2759')
job('GCS-CI-CD/TestsShort/soft_requests') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/soft_requests 0')
   }
}
queue('GCS-CI-CD/TestsShort/soft_requests')
job('GCS-CI-CD/TestsShort/exclusive_host_usage') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/exclusive_host_usage 0')
   }
}
queue('GCS-CI-CD/TestsShort/exclusive_host_usage')
job('GCS-CI-CD/TestsShort/enforce_limits') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/enforce_limits 0')
   }
}
queue('GCS-CI-CD/TestsShort/enforce_limits')
job('GCS-CI-CD/TestsShort/system_time') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/system_time 0')
   }
}
queue('GCS-CI-CD/TestsShort/system_time')
job('GCS-CI-CD/TestsShort/qsub_pty') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qsub/qsub_pty 0')
   }
}
queue('GCS-CI-CD/TestsShort/qsub_pty')
job('GCS-CI-CD/TestsShort/3068') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3068 0')
   }
}
queue('GCS-CI-CD/TestsShort/3068')
job('GCS-CI-CD/TestsShort/2339') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2339 0')
   }
}
queue('GCS-CI-CD/TestsShort/2339')
job('GCS-CI-CD/TestsShort/general') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/upgrade_test/general 0')
   }
}
queue('GCS-CI-CD/TestsShort/general')
job('GCS-CI-CD/TestsShort/505') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/505 0')
   }
}
queue('GCS-CI-CD/TestsShort/505')
job('GCS-CI-CD/TestsShort/1832') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1832 0')
   }
}
queue('GCS-CI-CD/TestsShort/1832')
job('GCS-CI-CD/TestsShort/binary_submission') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/binary_submission 0')
   }
}
queue('GCS-CI-CD/TestsShort/binary_submission')
job('GCS-CI-CD/TestsShort/3474') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/jira/3474 0')
   }
}
queue('GCS-CI-CD/TestsShort/3474')
job('GCS-CI-CD/TestsShort/qacct') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qacct 0')
   }
}
queue('GCS-CI-CD/TestsShort/qacct')
job('GCS-CI-CD/TestsShort/2254') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2254 0')
   }
}
queue('GCS-CI-CD/TestsShort/2254')
job('GCS-CI-CD/TestsShort/qrsh') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qrsh 0')
   }
}
queue('GCS-CI-CD/TestsShort/qrsh')
job('GCS-CI-CD/TestsShort/2876') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2876 0')
   }
}
queue('GCS-CI-CD/TestsShort/2876')
job('GCS-CI-CD/TestsShort/urgency') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/urgency 0')
   }
}
queue('GCS-CI-CD/TestsShort/urgency')
job('GCS-CI-CD/TestsShort/2411') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2411 0')
   }
}
queue('GCS-CI-CD/TestsShort/2411')
job('GCS-CI-CD/TestsShort/1715') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1715 0')
   }
}
queue('GCS-CI-CD/TestsShort/1715')
job('GCS-CI-CD/TestsShort/1768') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1768 0')
   }
}
queue('GCS-CI-CD/TestsShort/1768')
job('GCS-CI-CD/TestsShort/1819') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1819 0')
   }
}
queue('GCS-CI-CD/TestsShort/1819')
job('GCS-CI-CD/TestsShort/max_dyn_ec') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/event_client/max_dyn_ec 0')
   }
}
queue('GCS-CI-CD/TestsShort/max_dyn_ec')
