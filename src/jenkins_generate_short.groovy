folder('GCS-CI-CD/TestsShort') {
   displayName('TestsShort')
   description('Tests in level short of GCS-CI-CD environemnt')
}
job('GCS-CI-CD/TestsShort/2753_0') {
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
queue('GCS-CI-CD/TestsShort/2753_0')
job('GCS-CI-CD/TestsShort/resource_reservation_2') {
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
queue('GCS-CI-CD/TestsShort/resource_reservation_2')
job('GCS-CI-CD/TestsShort/resource_reservation_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/resource_reservation 3')
   }
}
queue('GCS-CI-CD/TestsShort/resource_reservation_3')
job('GCS-CI-CD/TestsShort/resource_reservation_4') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/resource_reservation 4')
   }
}
queue('GCS-CI-CD/TestsShort/resource_reservation_4')
job('GCS-CI-CD/TestsShort/resource_reservation_5') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/resource_reservation 5')
   }
}
queue('GCS-CI-CD/TestsShort/resource_reservation_5')
job('GCS-CI-CD/TestsShort/exclusive_host_usage_0') {
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
queue('GCS-CI-CD/TestsShort/exclusive_host_usage_0')
job('GCS-CI-CD/TestsShort/connection_test_0') {
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
queue('GCS-CI-CD/TestsShort/connection_test_0')
job('GCS-CI-CD/TestsShort/connection_test_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/connection_test 1')
   }
}
queue('GCS-CI-CD/TestsShort/connection_test_1')
job('GCS-CI-CD/TestsShort/connection_test_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/testsuite/connection_test 2')
   }
}
queue('GCS-CI-CD/TestsShort/connection_test_2')
job('GCS-CI-CD/TestsShort/appcert_0') {
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
queue('GCS-CI-CD/TestsShort/appcert_0')
job('GCS-CI-CD/TestsShort/qsub_e_o_j_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_e_o_j_0')
job('GCS-CI-CD/TestsShort/1081_0') {
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
queue('GCS-CI-CD/TestsShort/1081_0')
job('GCS-CI-CD/TestsShort/1081_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1081 1')
   }
}
queue('GCS-CI-CD/TestsShort/1081_1')
job('GCS-CI-CD/TestsShort/pe_x_forks_slaves_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/pe/pe_x_forks_slaves 0')
   }
}
queue('GCS-CI-CD/TestsShort/pe_x_forks_slaves_0')
job('GCS-CI-CD/TestsShort/issues_0') {
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
queue('GCS-CI-CD/TestsShort/issues_0')
job('GCS-CI-CD/TestsShort/2344_0') {
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
queue('GCS-CI-CD/TestsShort/2344_0')
job('GCS-CI-CD/TestsShort/2952_0') {
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
queue('GCS-CI-CD/TestsShort/2952_0')
job('GCS-CI-CD/TestsShort/2433_0') {
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
queue('GCS-CI-CD/TestsShort/2433_0')
job('GCS-CI-CD/TestsShort/binary_submission_0') {
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
queue('GCS-CI-CD/TestsShort/binary_submission_0')
job('GCS-CI-CD/TestsShort/577_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/jira_cs/577 0')
   }
}
queue('GCS-CI-CD/TestsShort/577_0')
job('GCS-CI-CD/TestsShort/qrsub_0') {
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
queue('GCS-CI-CD/TestsShort/qrsub_0')
job('GCS-CI-CD/TestsShort/2050_0') {
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
queue('GCS-CI-CD/TestsShort/2050_0')
job('GCS-CI-CD/TestsShort/antivirus_0') {
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
queue('GCS-CI-CD/TestsShort/antivirus_0')
job('GCS-CI-CD/TestsShort/qrsh_0') {
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
queue('GCS-CI-CD/TestsShort/qrsh_0')
job('GCS-CI-CD/TestsShort/2061_0') {
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
queue('GCS-CI-CD/TestsShort/2061_0')
job('GCS-CI-CD/TestsShort/1715_0') {
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
queue('GCS-CI-CD/TestsShort/1715_0')
job('GCS-CI-CD/TestsShort/2418_0') {
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
queue('GCS-CI-CD/TestsShort/2418_0')
job('GCS-CI-CD/TestsShort/max_dyn_ec_0') {
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
queue('GCS-CI-CD/TestsShort/max_dyn_ec_0')
job('GCS-CI-CD/TestsShort/max_dyn_ec_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/event_client/max_dyn_ec 1')
   }
}
queue('GCS-CI-CD/TestsShort/max_dyn_ec_1')
job('GCS-CI-CD/TestsShort/2759_0') {
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
queue('GCS-CI-CD/TestsShort/2759_0')
job('GCS-CI-CD/TestsShort/sharetree_0') {
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
queue('GCS-CI-CD/TestsShort/sharetree_0')
job('GCS-CI-CD/TestsShort/enforce_limits_0') {
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
queue('GCS-CI-CD/TestsShort/enforce_limits_0')
job('GCS-CI-CD/TestsShort/user_permissions_0') {
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
queue('GCS-CI-CD/TestsShort/user_permissions_0')
job('GCS-CI-CD/TestsShort/test_template_0') {
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
queue('GCS-CI-CD/TestsShort/test_template_0')
job('GCS-CI-CD/TestsShort/test_template_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/test_template 1')
   }
}
queue('GCS-CI-CD/TestsShort/test_template_1')
job('GCS-CI-CD/TestsShort/qsub_sync_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_sync_0')
job('GCS-CI-CD/TestsShort/3068_0') {
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
queue('GCS-CI-CD/TestsShort/3068_0')
job('GCS-CI-CD/TestsShort/1751_0') {
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
queue('GCS-CI-CD/TestsShort/1751_0')
job('GCS-CI-CD/TestsShort/2339_0') {
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
queue('GCS-CI-CD/TestsShort/2339_0')
job('GCS-CI-CD/TestsShort/505_0') {
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
queue('GCS-CI-CD/TestsShort/505_0')
job('GCS-CI-CD/TestsShort/1832_0') {
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
queue('GCS-CI-CD/TestsShort/1832_0')
job('GCS-CI-CD/TestsShort/574_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/jira_cs/574 0')
   }
}
queue('GCS-CI-CD/TestsShort/574_0')
job('GCS-CI-CD/TestsShort/qdel_0') {
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
queue('GCS-CI-CD/TestsShort/qdel_0')
job('GCS-CI-CD/TestsShort/qdel_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qdel 1')
   }
}
queue('GCS-CI-CD/TestsShort/qdel_1')
job('GCS-CI-CD/TestsShort/qdel_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qdel 2')
   }
}
queue('GCS-CI-CD/TestsShort/qdel_2')
job('GCS-CI-CD/TestsShort/qdel_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qdel 3')
   }
}
queue('GCS-CI-CD/TestsShort/qdel_3')
job('GCS-CI-CD/TestsShort/2254_0') {
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
queue('GCS-CI-CD/TestsShort/2254_0')
job('GCS-CI-CD/TestsShort/2876_0') {
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
queue('GCS-CI-CD/TestsShort/2876_0')
job('GCS-CI-CD/TestsShort/config_execd_params_use_qsub_gid_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/config/config_execd_params/config_execd_params_use_qsub_gid 0')
   }
}
queue('GCS-CI-CD/TestsShort/config_execd_params_use_qsub_gid_0')
job('GCS-CI-CD/TestsShort/monitoring_0') {
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
queue('GCS-CI-CD/TestsShort/monitoring_0')
job('GCS-CI-CD/TestsShort/1768_0') {
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
queue('GCS-CI-CD/TestsShort/1768_0')
job('GCS-CI-CD/TestsShort/1819_0') {
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
queue('GCS-CI-CD/TestsShort/1819_0')
job('GCS-CI-CD/TestsShort/1914_0') {
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
queue('GCS-CI-CD/TestsShort/1914_0')
job('GCS-CI-CD/TestsShort/2387_0') {
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
queue('GCS-CI-CD/TestsShort/2387_0')
job('GCS-CI-CD/TestsShort/tickets_0') {
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
queue('GCS-CI-CD/TestsShort/tickets_0')
job('GCS-CI-CD/TestsShort/tickets_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/tickets 1')
   }
}
queue('GCS-CI-CD/TestsShort/tickets_1')
job('GCS-CI-CD/TestsShort/access_lists_0') {
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
queue('GCS-CI-CD/TestsShort/access_lists_0')
job('GCS-CI-CD/TestsShort/qsub_huge_script_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_huge_script_0')
job('GCS-CI-CD/TestsShort/1972_0') {
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
queue('GCS-CI-CD/TestsShort/1972_0')
job('GCS-CI-CD/TestsShort/ce_qconf_operations_0') {
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
queue('GCS-CI-CD/TestsShort/ce_qconf_operations_0')
job('GCS-CI-CD/TestsShort/host_alias_file_0') {
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
queue('GCS-CI-CD/TestsShort/host_alias_file_0')
job('GCS-CI-CD/TestsShort/2542_0') {
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
queue('GCS-CI-CD/TestsShort/2542_0')
job('GCS-CI-CD/TestsShort/2542_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2542 1')
   }
}
queue('GCS-CI-CD/TestsShort/2542_1')
job('GCS-CI-CD/TestsShort/commlib_0') {
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
queue('GCS-CI-CD/TestsShort/commlib_0')
job('GCS-CI-CD/TestsShort/commlib_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/commlib 1')
   }
}
queue('GCS-CI-CD/TestsShort/commlib_1')
job('GCS-CI-CD/TestsShort/commlib_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/commlib 2')
   }
}
queue('GCS-CI-CD/TestsShort/commlib_2')
job('GCS-CI-CD/TestsShort/2706_0') {
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
queue('GCS-CI-CD/TestsShort/2706_0')
job('GCS-CI-CD/TestsShort/2300_0') {
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
queue('GCS-CI-CD/TestsShort/2300_0')
job('GCS-CI-CD/TestsShort/ssos_general_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/ssos/ssos_general 0')
   }
}
queue('GCS-CI-CD/TestsShort/ssos_general_0')
job('GCS-CI-CD/TestsShort/qping_0') {
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
queue('GCS-CI-CD/TestsShort/qping_0')
job('GCS-CI-CD/TestsShort/1489_0') {
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
queue('GCS-CI-CD/TestsShort/1489_0')
job('GCS-CI-CD/TestsShort/qmaster_thread_start_stop_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/component/qmaster/qmaster_thread_start_stop 0')
   }
}
queue('GCS-CI-CD/TestsShort/qmaster_thread_start_stop_0')
job('GCS-CI-CD/TestsShort/2717_0') {
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
queue('GCS-CI-CD/TestsShort/2717_0')
job('GCS-CI-CD/TestsShort/config_execd_params_keep_active_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/config/config_execd_params/config_execd_params_keep_active 0')
   }
}
queue('GCS-CI-CD/TestsShort/config_execd_params_keep_active_0')
job('GCS-CI-CD/TestsShort/spooling_0') {
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
queue('GCS-CI-CD/TestsShort/spooling_0')
job('GCS-CI-CD/TestsShort/440_0') {
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
queue('GCS-CI-CD/TestsShort/440_0')
job('GCS-CI-CD/TestsShort/2465_0') {
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
queue('GCS-CI-CD/TestsShort/2465_0')
job('GCS-CI-CD/TestsShort/smf_0') {
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
queue('GCS-CI-CD/TestsShort/smf_0')
job('GCS-CI-CD/TestsShort/1141_0') {
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
queue('GCS-CI-CD/TestsShort/1141_0')
job('GCS-CI-CD/TestsShort/job_state_handling_0') {
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
queue('GCS-CI-CD/TestsShort/job_state_handling_0')
job('GCS-CI-CD/TestsShort/job_state_handling_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/job_state_handling 1')
   }
}
queue('GCS-CI-CD/TestsShort/job_state_handling_1')
job('GCS-CI-CD/TestsShort/expressions_0') {
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
queue('GCS-CI-CD/TestsShort/expressions_0')
job('GCS-CI-CD/TestsShort/home_dirs_0') {
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
queue('GCS-CI-CD/TestsShort/home_dirs_0')
job('GCS-CI-CD/TestsShort/3216_0') {
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
queue('GCS-CI-CD/TestsShort/3216_0')
job('GCS-CI-CD/TestsShort/shutdown_0') {
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
queue('GCS-CI-CD/TestsShort/shutdown_0')
job('GCS-CI-CD/TestsShort/shutdown_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/shutdown 1')
   }
}
queue('GCS-CI-CD/TestsShort/shutdown_1')
job('GCS-CI-CD/TestsShort/shutdown_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/shutdown 2')
   }
}
queue('GCS-CI-CD/TestsShort/shutdown_2')
job('GCS-CI-CD/TestsShort/shutdown_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/commlib/shutdown 3')
   }
}
queue('GCS-CI-CD/TestsShort/shutdown_3')
job('GCS-CI-CD/TestsShort/1760_0') {
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
queue('GCS-CI-CD/TestsShort/1760_0')
job('GCS-CI-CD/TestsShort/2419_0') {
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
queue('GCS-CI-CD/TestsShort/2419_0')
job('GCS-CI-CD/TestsShort/1193_0') {
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
queue('GCS-CI-CD/TestsShort/1193_0')
job('GCS-CI-CD/TestsShort/524_0') {
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
queue('GCS-CI-CD/TestsShort/524_0')
job('GCS-CI-CD/TestsShort/1251_0') {
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
queue('GCS-CI-CD/TestsShort/1251_0')
job('GCS-CI-CD/TestsShort/jsv_ge_mod_0') {
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
queue('GCS-CI-CD/TestsShort/jsv_ge_mod_0')
job('GCS-CI-CD/TestsShort/jsv_ge_mod_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/jsv/jsv_ge_mod 1')
   }
}
queue('GCS-CI-CD/TestsShort/jsv_ge_mod_1')
job('GCS-CI-CD/TestsShort/3474_0') {
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
queue('GCS-CI-CD/TestsShort/3474_0')
job('GCS-CI-CD/TestsShort/171_0') {
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
queue('GCS-CI-CD/TestsShort/171_0')
job('GCS-CI-CD/TestsShort/submit_hosts_0') {
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
queue('GCS-CI-CD/TestsShort/submit_hosts_0')
job('GCS-CI-CD/TestsShort/submit_hosts_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/config/submit_hosts 1')
   }
}
queue('GCS-CI-CD/TestsShort/submit_hosts_1')
job('GCS-CI-CD/TestsShort/2564_0') {
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
queue('GCS-CI-CD/TestsShort/2564_0')
job('GCS-CI-CD/TestsShort/193_0') {
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
queue('GCS-CI-CD/TestsShort/193_0')
job('GCS-CI-CD/TestsShort/copy_certs_0') {
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
queue('GCS-CI-CD/TestsShort/copy_certs_0')
job('GCS-CI-CD/TestsShort/527_0') {
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
queue('GCS-CI-CD/TestsShort/527_0')
job('GCS-CI-CD/TestsShort/2183_0') {
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
queue('GCS-CI-CD/TestsShort/2183_0')
job('GCS-CI-CD/TestsShort/backup_restore_0') {
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
queue('GCS-CI-CD/TestsShort/backup_restore_0')
job('GCS-CI-CD/TestsShort/system_time_0') {
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
queue('GCS-CI-CD/TestsShort/system_time_0')
job('GCS-CI-CD/TestsShort/qsub_ac_dc_sc_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_ac_dc_sc_0')
job('GCS-CI-CD/TestsShort/509_0') {
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
queue('GCS-CI-CD/TestsShort/509_0')
job('GCS-CI-CD/TestsShort/project_user_xuser_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/project/project_user_xuser 0')
   }
}
queue('GCS-CI-CD/TestsShort/project_user_xuser_0')
job('GCS-CI-CD/TestsShort/fork_0') {
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
queue('GCS-CI-CD/TestsShort/fork_0')
job('GCS-CI-CD/TestsShort/1096_0') {
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
queue('GCS-CI-CD/TestsShort/1096_0')
job('GCS-CI-CD/TestsShort/2411_0') {
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
queue('GCS-CI-CD/TestsShort/2411_0')
job('GCS-CI-CD/TestsShort/2411_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2411 1')
   }
}
queue('GCS-CI-CD/TestsShort/2411_1')
job('GCS-CI-CD/TestsShort/423_0') {
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
queue('GCS-CI-CD/TestsShort/423_0')
job('GCS-CI-CD/TestsShort/1661_0') {
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
queue('GCS-CI-CD/TestsShort/1661_0')
job('GCS-CI-CD/TestsShort/jsv_issues_0') {
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
queue('GCS-CI-CD/TestsShort/jsv_issues_0')
job('GCS-CI-CD/TestsShort/3479_0') {
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
queue('GCS-CI-CD/TestsShort/3479_0')
job('GCS-CI-CD/TestsShort/qmod_general_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/qmod_general 0')
   }
}
queue('GCS-CI-CD/TestsShort/qmod_general_0')
job('GCS-CI-CD/TestsShort/3223_0') {
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
queue('GCS-CI-CD/TestsShort/3223_0')
job('GCS-CI-CD/TestsShort/2378_0') {
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
queue('GCS-CI-CD/TestsShort/2378_0')
job('GCS-CI-CD/TestsShort/scheduler_perf_generic_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/component/scheduler/scheduler_perf_generic 0')
   }
}
queue('GCS-CI-CD/TestsShort/scheduler_perf_generic_0')
job('GCS-CI-CD/TestsShort/file_parsing_0') {
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
queue('GCS-CI-CD/TestsShort/file_parsing_0')
job('GCS-CI-CD/TestsShort/3129_0') {
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
queue('GCS-CI-CD/TestsShort/3129_0')
job('GCS-CI-CD/TestsShort/config_qmaster_params_old_reschedule_behavior_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/config/config_qmaster_params/config_qmaster_params_old_reschedule_behavior 0')
   }
}
queue('GCS-CI-CD/TestsShort/config_qmaster_params_old_reschedule_behavior_0')
job('GCS-CI-CD/TestsShort/cluster_config_0') {
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
queue('GCS-CI-CD/TestsShort/cluster_config_0')
job('GCS-CI-CD/TestsShort/1156_0') {
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
queue('GCS-CI-CD/TestsShort/1156_0')
job('GCS-CI-CD/TestsShort/1156_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/1156 1')
   }
}
queue('GCS-CI-CD/TestsShort/1156_1')
job('GCS-CI-CD/TestsShort/2158_0') {
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
queue('GCS-CI-CD/TestsShort/2158_0')
job('GCS-CI-CD/TestsShort/extensive_qrsh_0') {
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
queue('GCS-CI-CD/TestsShort/extensive_qrsh_0')
job('GCS-CI-CD/TestsShort/extensive_qrsh_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/extensive_qrsh 1')
   }
}
queue('GCS-CI-CD/TestsShort/extensive_qrsh_1')
job('GCS-CI-CD/TestsShort/1401_0') {
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
queue('GCS-CI-CD/TestsShort/1401_0')
job('GCS-CI-CD/TestsShort/submit_del_0') {
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
queue('GCS-CI-CD/TestsShort/submit_del_0')
job('GCS-CI-CD/TestsShort/per_host_consumables_0') {
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
queue('GCS-CI-CD/TestsShort/per_host_consumables_0')
job('GCS-CI-CD/TestsShort/per_host_consumables_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_host_consumables 1')
   }
}
queue('GCS-CI-CD/TestsShort/per_host_consumables_1')
job('GCS-CI-CD/TestsShort/per_host_consumables_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_host_consumables 2')
   }
}
queue('GCS-CI-CD/TestsShort/per_host_consumables_2')
job('GCS-CI-CD/TestsShort/per_host_consumables_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_host_consumables 3')
   }
}
queue('GCS-CI-CD/TestsShort/per_host_consumables_3')
job('GCS-CI-CD/TestsShort/per_host_consumables_4') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_host_consumables 4')
   }
}
queue('GCS-CI-CD/TestsShort/per_host_consumables_4')
job('GCS-CI-CD/TestsShort/per_host_consumables_5') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/per_host_consumables 5')
   }
}
queue('GCS-CI-CD/TestsShort/per_host_consumables_5')
job('GCS-CI-CD/TestsShort/host_test_0') {
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
queue('GCS-CI-CD/TestsShort/host_test_0')
job('GCS-CI-CD/TestsShort/qsub_hold_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_hold_0')
job('GCS-CI-CD/TestsShort/1802_0') {
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
queue('GCS-CI-CD/TestsShort/1802_0')
job('GCS-CI-CD/TestsShort/deadlock_0') {
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
queue('GCS-CI-CD/TestsShort/deadlock_0')
job('GCS-CI-CD/TestsShort/3172_0') {
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
queue('GCS-CI-CD/TestsShort/3172_0')
job('GCS-CI-CD/TestsShort/511_0') {
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
queue('GCS-CI-CD/TestsShort/511_0')
job('GCS-CI-CD/TestsShort/2979_0') {
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
queue('GCS-CI-CD/TestsShort/2979_0')
job('GCS-CI-CD/TestsShort/2459_0') {
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
queue('GCS-CI-CD/TestsShort/2459_0')
job('GCS-CI-CD/TestsShort/2459_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2459 1')
   }
}
queue('GCS-CI-CD/TestsShort/2459_1')
job('GCS-CI-CD/TestsShort/1848_0') {
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
queue('GCS-CI-CD/TestsShort/1848_0')
job('GCS-CI-CD/TestsShort/3306_0') {
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
queue('GCS-CI-CD/TestsShort/3306_0')
job('GCS-CI-CD/TestsShort/reschedule_0') {
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
queue('GCS-CI-CD/TestsShort/reschedule_0')
job('GCS-CI-CD/TestsShort/2396_0') {
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
queue('GCS-CI-CD/TestsShort/2396_0')
job('GCS-CI-CD/TestsShort/host_aliases_0') {
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
queue('GCS-CI-CD/TestsShort/host_aliases_0')
job('GCS-CI-CD/TestsShort/1933_0') {
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
queue('GCS-CI-CD/TestsShort/1933_0')
job('GCS-CI-CD/TestsShort/host_user_xuser_reset_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/host/host_user_xuser_reset 0')
   }
}
queue('GCS-CI-CD/TestsShort/host_user_xuser_reset_0')
job('GCS-CI-CD/TestsShort/advance_reservation_0') {
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
queue('GCS-CI-CD/TestsShort/advance_reservation_0')
job('GCS-CI-CD/TestsShort/profiling_0') {
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
queue('GCS-CI-CD/TestsShort/profiling_0')
job('GCS-CI-CD/TestsShort/2967_0') {
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
queue('GCS-CI-CD/TestsShort/2967_0')
job('GCS-CI-CD/TestsShort/2682_0') {
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
queue('GCS-CI-CD/TestsShort/2682_0')
job('GCS-CI-CD/TestsShort/inst_submit_host_0') {
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
queue('GCS-CI-CD/TestsShort/inst_submit_host_0')
job('GCS-CI-CD/TestsShort/rsmap_basic_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/rsmap/rsmap_basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/rsmap_basic_0')
job('GCS-CI-CD/TestsShort/rsmap_basic_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/rsmap/rsmap_basic 1')
   }
}
queue('GCS-CI-CD/TestsShort/rsmap_basic_1')
job('GCS-CI-CD/TestsShort/framework_0') {
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
queue('GCS-CI-CD/TestsShort/framework_0')
job('GCS-CI-CD/TestsShort/1359_0') {
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
queue('GCS-CI-CD/TestsShort/1359_0')
job('GCS-CI-CD/TestsShort/job_groups_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/job/job_groups 0')
   }
}
queue('GCS-CI-CD/TestsShort/job_groups_0')
job('GCS-CI-CD/TestsShort/1741_0') {
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
queue('GCS-CI-CD/TestsShort/1741_0')
job('GCS-CI-CD/TestsShort/360_0') {
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
queue('GCS-CI-CD/TestsShort/360_0')
job('GCS-CI-CD/TestsShort/1798_0') {
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
queue('GCS-CI-CD/TestsShort/1798_0')
job('GCS-CI-CD/TestsShort/2864_0') {
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
queue('GCS-CI-CD/TestsShort/2864_0')
job('GCS-CI-CD/TestsShort/auto_reschedule_0') {
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
queue('GCS-CI-CD/TestsShort/auto_reschedule_0')
job('GCS-CI-CD/TestsShort/auto_reschedule_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/auto_reschedule 1')
   }
}
queue('GCS-CI-CD/TestsShort/auto_reschedule_1')
job('GCS-CI-CD/TestsShort/auto_reschedule_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/auto_reschedule 2')
   }
}
queue('GCS-CI-CD/TestsShort/auto_reschedule_2')
job('GCS-CI-CD/TestsShort/auto_reschedule_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/auto_reschedule 3')
   }
}
queue('GCS-CI-CD/TestsShort/auto_reschedule_3')
job('GCS-CI-CD/TestsShort/auto_reschedule_4') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmod/auto_reschedule 4')
   }
}
queue('GCS-CI-CD/TestsShort/auto_reschedule_4')
job('GCS-CI-CD/TestsShort/2202_0') {
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
queue('GCS-CI-CD/TestsShort/2202_0')
job('GCS-CI-CD/TestsShort/1161_0') {
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
queue('GCS-CI-CD/TestsShort/1161_0')
job('GCS-CI-CD/TestsShort/1806_0') {
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
queue('GCS-CI-CD/TestsShort/1806_0')
job('GCS-CI-CD/TestsShort/host_user_xuser_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/host/host_user_xuser 0')
   }
}
queue('GCS-CI-CD/TestsShort/host_user_xuser_0')
job('GCS-CI-CD/TestsShort/1146_0') {
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
queue('GCS-CI-CD/TestsShort/1146_0')
job('GCS-CI-CD/TestsShort/core_binding_general_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/corebinding/core_binding_general 0')
   }
}
queue('GCS-CI-CD/TestsShort/core_binding_general_0')
job('GCS-CI-CD/TestsShort/226_0') {
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
queue('GCS-CI-CD/TestsShort/226_0')
job('GCS-CI-CD/TestsShort/qquota_0') {
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
queue('GCS-CI-CD/TestsShort/qquota_0')
job('GCS-CI-CD/TestsShort/custom-usage_0') {
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
queue('GCS-CI-CD/TestsShort/custom-usage_0')
job('GCS-CI-CD/TestsShort/advance_reservation_0') {
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
queue('GCS-CI-CD/TestsShort/advance_reservation_0')
job('GCS-CI-CD/TestsShort/1324_0') {
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
queue('GCS-CI-CD/TestsShort/1324_0')
job('GCS-CI-CD/TestsShort/scheduler_messages_0') {
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
queue('GCS-CI-CD/TestsShort/scheduler_messages_0')
job('GCS-CI-CD/TestsShort/scheduler_messages_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/scheduler_messages 1')
   }
}
queue('GCS-CI-CD/TestsShort/scheduler_messages_1')
job('GCS-CI-CD/TestsShort/sge_share_mon_0') {
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
queue('GCS-CI-CD/TestsShort/sge_share_mon_0')
job('GCS-CI-CD/TestsShort/sge_share_mon_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/utilbin/sge_share_mon 1')
   }
}
queue('GCS-CI-CD/TestsShort/sge_share_mon_1')
job('GCS-CI-CD/TestsShort/2895_0') {
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
queue('GCS-CI-CD/TestsShort/2895_0')
job('GCS-CI-CD/TestsShort/2895_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2895 1')
   }
}
queue('GCS-CI-CD/TestsShort/2895_1')
job('GCS-CI-CD/TestsShort/1502_0') {
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
queue('GCS-CI-CD/TestsShort/1502_0')
job('GCS-CI-CD/TestsShort/3017_0') {
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
queue('GCS-CI-CD/TestsShort/3017_0')
job('GCS-CI-CD/TestsShort/3017_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3017 1')
   }
}
queue('GCS-CI-CD/TestsShort/3017_1')
job('GCS-CI-CD/TestsShort/141_0') {
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
queue('GCS-CI-CD/TestsShort/141_0')
job('GCS-CI-CD/TestsShort/1780_0') {
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
queue('GCS-CI-CD/TestsShort/1780_0')
job('GCS-CI-CD/TestsShort/manager_sup_group_allow_delete_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/acl/manager_sup_group_allow_delete 0')
   }
}
queue('GCS-CI-CD/TestsShort/manager_sup_group_allow_delete_0')
job('GCS-CI-CD/TestsShort/140_0') {
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
queue('GCS-CI-CD/TestsShort/140_0')
job('GCS-CI-CD/TestsShort/540_0') {
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
queue('GCS-CI-CD/TestsShort/540_0')
job('GCS-CI-CD/TestsShort/2754_0') {
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
queue('GCS-CI-CD/TestsShort/2754_0')
job('GCS-CI-CD/TestsShort/1270_0') {
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
queue('GCS-CI-CD/TestsShort/1270_0')
job('GCS-CI-CD/TestsShort/qhost_0') {
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
queue('GCS-CI-CD/TestsShort/qhost_0')
job('GCS-CI-CD/TestsShort/job_environment_enhanced_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/job_environment/job_environment_enhanced 0')
   }
}
queue('GCS-CI-CD/TestsShort/job_environment_enhanced_0')
job('GCS-CI-CD/TestsShort/job_environment_basic_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/job_environment/job_environment_basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/job_environment_basic_0')
job('GCS-CI-CD/TestsShort/setup_0') {
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
queue('GCS-CI-CD/TestsShort/setup_0')
job('GCS-CI-CD/TestsShort/1291_0') {
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
queue('GCS-CI-CD/TestsShort/1291_0')
job('GCS-CI-CD/TestsShort/reconnect_0') {
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
queue('GCS-CI-CD/TestsShort/reconnect_0')
job('GCS-CI-CD/TestsShort/queue_user_xuser_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/queue/queue_user_xuser 0')
   }
}
queue('GCS-CI-CD/TestsShort/queue_user_xuser_0')
job('GCS-CI-CD/TestsShort/spooledit_0') {
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
queue('GCS-CI-CD/TestsShort/spooledit_0')
job('GCS-CI-CD/TestsShort/2161_0') {
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
queue('GCS-CI-CD/TestsShort/2161_0')
job('GCS-CI-CD/TestsShort/3013_0') {
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
queue('GCS-CI-CD/TestsShort/3013_0')
job('GCS-CI-CD/TestsShort/2582_0') {
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
queue('GCS-CI-CD/TestsShort/2582_0')
job('GCS-CI-CD/TestsShort/2582_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2582 1')
   }
}
queue('GCS-CI-CD/TestsShort/2582_1')
job('GCS-CI-CD/TestsShort/resource_quota_0') {
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
queue('GCS-CI-CD/TestsShort/resource_quota_0')
job('GCS-CI-CD/TestsShort/1977_0') {
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
queue('GCS-CI-CD/TestsShort/1977_0')
job('GCS-CI-CD/TestsShort/jsv_script_0') {
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
queue('GCS-CI-CD/TestsShort/jsv_script_0')
job('GCS-CI-CD/TestsShort/2735_0') {
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
queue('GCS-CI-CD/TestsShort/2735_0')
job('GCS-CI-CD/TestsShort/reconnect_0') {
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
queue('GCS-CI-CD/TestsShort/reconnect_0')
job('GCS-CI-CD/TestsShort/1556_0') {
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
queue('GCS-CI-CD/TestsShort/1556_0')
job('GCS-CI-CD/TestsShort/2304_0') {
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
queue('GCS-CI-CD/TestsShort/2304_0')
job('GCS-CI-CD/TestsShort/2743_0') {
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
queue('GCS-CI-CD/TestsShort/2743_0')
job('GCS-CI-CD/TestsShort/314_0') {
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
queue('GCS-CI-CD/TestsShort/314_0')
job('GCS-CI-CD/TestsShort/1640_0') {
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
queue('GCS-CI-CD/TestsShort/1640_0')
job('GCS-CI-CD/TestsShort/qrdel_0') {
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
queue('GCS-CI-CD/TestsShort/qrdel_0')
job('GCS-CI-CD/TestsShort/scope_basic_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/scope_basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/scope_basic_0')
job('GCS-CI-CD/TestsShort/scope_basic_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/scope_basic 1')
   }
}
queue('GCS-CI-CD/TestsShort/scope_basic_1')
job('GCS-CI-CD/TestsShort/scope_basic_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/scope_basic 2')
   }
}
queue('GCS-CI-CD/TestsShort/scope_basic_2')
job('GCS-CI-CD/TestsShort/scope_basic_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/scope_basic 3')
   }
}
queue('GCS-CI-CD/TestsShort/scope_basic_3')
job('GCS-CI-CD/TestsShort/scope_basic_4') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/scope_basic 4')
   }
}
queue('GCS-CI-CD/TestsShort/scope_basic_4')
job('GCS-CI-CD/TestsShort/submit_cmd_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/common/submit_cmd 0')
   }
}
queue('GCS-CI-CD/TestsShort/submit_cmd_0')
job('GCS-CI-CD/TestsShort/2329_0') {
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
queue('GCS-CI-CD/TestsShort/2329_0')
job('GCS-CI-CD/TestsShort/queue_requests_0') {
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
queue('GCS-CI-CD/TestsShort/queue_requests_0')
job('GCS-CI-CD/TestsShort/rqs_user_xuser_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/rqs/rqs_user_xuser 0')
   }
}
queue('GCS-CI-CD/TestsShort/rqs_user_xuser_0')
job('GCS-CI-CD/TestsShort/loadcheck_0') {
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
queue('GCS-CI-CD/TestsShort/loadcheck_0')
job('GCS-CI-CD/TestsShort/jemalloc_0') {
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
queue('GCS-CI-CD/TestsShort/jemalloc_0')
job('GCS-CI-CD/TestsShort/2755_0') {
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
queue('GCS-CI-CD/TestsShort/2755_0')
job('GCS-CI-CD/TestsShort/2408_0') {
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
queue('GCS-CI-CD/TestsShort/2408_0')
job('GCS-CI-CD/TestsShort/3094_0') {
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
queue('GCS-CI-CD/TestsShort/3094_0')
job('GCS-CI-CD/TestsShort/3094_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3094 1')
   }
}
queue('GCS-CI-CD/TestsShort/3094_1')
job('GCS-CI-CD/TestsShort/3094_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3094 2')
   }
}
queue('GCS-CI-CD/TestsShort/3094_2')
job('GCS-CI-CD/TestsShort/3094_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3094 3')
   }
}
queue('GCS-CI-CD/TestsShort/3094_3')
job('GCS-CI-CD/TestsShort/advance_reservation_0') {
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
queue('GCS-CI-CD/TestsShort/advance_reservation_0')
job('GCS-CI-CD/TestsShort/advance_reservation_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/advance_reservation 1')
   }
}
queue('GCS-CI-CD/TestsShort/advance_reservation_1')
job('GCS-CI-CD/TestsShort/2406_0') {
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
queue('GCS-CI-CD/TestsShort/2406_0')
job('GCS-CI-CD/TestsShort/reprioritization_0') {
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
queue('GCS-CI-CD/TestsShort/reprioritization_0')
job('GCS-CI-CD/TestsShort/wait_for_remote_file_test_0') {
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
queue('GCS-CI-CD/TestsShort/wait_for_remote_file_test_0')
job('GCS-CI-CD/TestsShort/2372_0') {
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
queue('GCS-CI-CD/TestsShort/2372_0')
job('GCS-CI-CD/TestsShort/2372_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2372 1')
   }
}
queue('GCS-CI-CD/TestsShort/2372_1')
job('GCS-CI-CD/TestsShort/2372_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2372 2')
   }
}
queue('GCS-CI-CD/TestsShort/2372_2')
job('GCS-CI-CD/TestsShort/2372_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2372 3')
   }
}
queue('GCS-CI-CD/TestsShort/2372_3')
job('GCS-CI-CD/TestsShort/rsmap_qconf_operations_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/rsmap/rsmap_qconf_operations 0')
   }
}
queue('GCS-CI-CD/TestsShort/rsmap_qconf_operations_0')
job('GCS-CI-CD/TestsShort/startup_0') {
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
queue('GCS-CI-CD/TestsShort/startup_0')
job('GCS-CI-CD/TestsShort/startup_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/execd/startup 1')
   }
}
queue('GCS-CI-CD/TestsShort/startup_1')
job('GCS-CI-CD/TestsShort/startup_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/execd/startup 2')
   }
}
queue('GCS-CI-CD/TestsShort/startup_2')
job('GCS-CI-CD/TestsShort/startup_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/execd/startup 3')
   }
}
queue('GCS-CI-CD/TestsShort/startup_3')
job('GCS-CI-CD/TestsShort/1892_0') {
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
queue('GCS-CI-CD/TestsShort/1892_0')
job('GCS-CI-CD/TestsShort/simhosts_basic_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/simhosts/simhosts_basic 0')
   }
}
queue('GCS-CI-CD/TestsShort/simhosts_basic_0')
job('GCS-CI-CD/TestsShort/2145_0') {
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
queue('GCS-CI-CD/TestsShort/2145_0')
job('GCS-CI-CD/TestsShort/1877_0') {
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
queue('GCS-CI-CD/TestsShort/1877_0')
job('GCS-CI-CD/TestsShort/1104_0') {
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
queue('GCS-CI-CD/TestsShort/1104_0')
job('GCS-CI-CD/TestsShort/qmake_0') {
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
queue('GCS-CI-CD/TestsShort/qmake_0')
job('GCS-CI-CD/TestsShort/qmake_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmake 1')
   }
}
queue('GCS-CI-CD/TestsShort/qmake_1')
job('GCS-CI-CD/TestsShort/qmake_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qmake 2')
   }
}
queue('GCS-CI-CD/TestsShort/qmake_2')
job('GCS-CI-CD/TestsShort/ign_sreq_on_mhost_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/ign_sreq_on_mhost 0')
   }
}
queue('GCS-CI-CD/TestsShort/ign_sreq_on_mhost_0')
job('GCS-CI-CD/TestsShort/ign_sreq_on_mhost_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/ign_sreq_on_mhost 1')
   }
}
queue('GCS-CI-CD/TestsShort/ign_sreq_on_mhost_1')
job('GCS-CI-CD/TestsShort/qconf_0') {
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
queue('GCS-CI-CD/TestsShort/qconf_0')
job('GCS-CI-CD/TestsShort/1198_0') {
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
queue('GCS-CI-CD/TestsShort/1198_0')
job('GCS-CI-CD/TestsShort/1823_0') {
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
queue('GCS-CI-CD/TestsShort/1823_0')
job('GCS-CI-CD/TestsShort/config_0') {
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
queue('GCS-CI-CD/TestsShort/config_0')
job('GCS-CI-CD/TestsShort/request_set_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/request_set 0')
   }
}
queue('GCS-CI-CD/TestsShort/request_set_0')
job('GCS-CI-CD/TestsShort/dtrace_0') {
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
queue('GCS-CI-CD/TestsShort/dtrace_0')
job('GCS-CI-CD/TestsShort/1334_0') {
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
queue('GCS-CI-CD/TestsShort/1334_0')
job('GCS-CI-CD/TestsShort/1803_0') {
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
queue('GCS-CI-CD/TestsShort/1803_0')
job('GCS-CI-CD/TestsShort/2222_0') {
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
queue('GCS-CI-CD/TestsShort/2222_0')
job('GCS-CI-CD/TestsShort/2222_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2222 1')
   }
}
queue('GCS-CI-CD/TestsShort/2222_1')
job('GCS-CI-CD/TestsShort/throughput_0') {
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
queue('GCS-CI-CD/TestsShort/throughput_0')
job('GCS-CI-CD/TestsShort/throughput_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 1')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_1')
job('GCS-CI-CD/TestsShort/throughput_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 2')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_2')
job('GCS-CI-CD/TestsShort/throughput_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 3')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_3')
job('GCS-CI-CD/TestsShort/throughput_4') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 4')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_4')
job('GCS-CI-CD/TestsShort/throughput_5') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 5')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_5')
job('GCS-CI-CD/TestsShort/throughput_6') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 6')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_6')
job('GCS-CI-CD/TestsShort/throughput_7') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 7')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_7')
job('GCS-CI-CD/TestsShort/throughput_8') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 8')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_8')
job('GCS-CI-CD/TestsShort/throughput_9') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 9')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_9')
job('GCS-CI-CD/TestsShort/throughput_10') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/performance/throughput 10')
   }
}
queue('GCS-CI-CD/TestsShort/throughput_10')
job('GCS-CI-CD/TestsShort/2495_0') {
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
queue('GCS-CI-CD/TestsShort/2495_0')
job('GCS-CI-CD/TestsShort/pe_ranges_0') {
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
queue('GCS-CI-CD/TestsShort/pe_ranges_0')
job('GCS-CI-CD/TestsShort/pe_ranges_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/pe_ranges 1')
   }
}
queue('GCS-CI-CD/TestsShort/pe_ranges_1')
job('GCS-CI-CD/TestsShort/execution_time_0') {
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
queue('GCS-CI-CD/TestsShort/execution_time_0')
job('GCS-CI-CD/TestsShort/qsub_w_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_w_0')
job('GCS-CI-CD/TestsShort/qsub_t_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_t_0')
job('GCS-CI-CD/TestsShort/1422_0') {
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
queue('GCS-CI-CD/TestsShort/1422_0')
job('GCS-CI-CD/TestsShort/1451_0') {
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
queue('GCS-CI-CD/TestsShort/1451_0')
job('GCS-CI-CD/TestsShort/2822_0') {
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
queue('GCS-CI-CD/TestsShort/2822_0')
job('GCS-CI-CD/TestsShort/2492_0') {
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
queue('GCS-CI-CD/TestsShort/2492_0')
job('GCS-CI-CD/TestsShort/2136_0') {
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
queue('GCS-CI-CD/TestsShort/2136_0')
job('GCS-CI-CD/TestsShort/consumable_resources_0') {
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
queue('GCS-CI-CD/TestsShort/consumable_resources_0')
job('GCS-CI-CD/TestsShort/consumable_resources_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 1')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_1')
job('GCS-CI-CD/TestsShort/consumable_resources_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 2')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_2')
job('GCS-CI-CD/TestsShort/consumable_resources_3') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 3')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_3')
job('GCS-CI-CD/TestsShort/consumable_resources_4') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 4')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_4')
job('GCS-CI-CD/TestsShort/consumable_resources_5') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 5')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_5')
job('GCS-CI-CD/TestsShort/consumable_resources_6') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 6')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_6')
job('GCS-CI-CD/TestsShort/consumable_resources_7') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 7')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_7')
job('GCS-CI-CD/TestsShort/consumable_resources_8') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/consumable_resources 8')
   }
}
queue('GCS-CI-CD/TestsShort/consumable_resources_8')
job('GCS-CI-CD/TestsShort/qrstat_0') {
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
queue('GCS-CI-CD/TestsShort/qrstat_0')
job('GCS-CI-CD/TestsShort/2978_0') {
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
queue('GCS-CI-CD/TestsShort/2978_0')
job('GCS-CI-CD/TestsShort/disjoint_master_slave_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/functional/scope/disjoint_master_slave 0')
   }
}
queue('GCS-CI-CD/TestsShort/disjoint_master_slave_0')
job('GCS-CI-CD/TestsShort/qresub_0') {
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
queue('GCS-CI-CD/TestsShort/qresub_0')
job('GCS-CI-CD/TestsShort/1473_0') {
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
queue('GCS-CI-CD/TestsShort/1473_0')
job('GCS-CI-CD/TestsShort/deadline_0') {
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
queue('GCS-CI-CD/TestsShort/deadline_0')
job('GCS-CI-CD/TestsShort/deadline_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/deadline 1')
   }
}
queue('GCS-CI-CD/TestsShort/deadline_1')
job('GCS-CI-CD/TestsShort/deadline_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/scheduler/deadline 2')
   }
}
queue('GCS-CI-CD/TestsShort/deadline_2')
job('GCS-CI-CD/TestsShort/3170_0') {
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
queue('GCS-CI-CD/TestsShort/3170_0')
job('GCS-CI-CD/TestsShort/1874_0') {
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
queue('GCS-CI-CD/TestsShort/1874_0')
job('GCS-CI-CD/TestsShort/2325_0') {
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
queue('GCS-CI-CD/TestsShort/2325_0')
job('GCS-CI-CD/TestsShort/653_0') {
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
queue('GCS-CI-CD/TestsShort/653_0')
job('GCS-CI-CD/TestsShort/soft_requests_0') {
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
queue('GCS-CI-CD/TestsShort/soft_requests_0')
job('GCS-CI-CD/TestsShort/subordinate_0') {
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
queue('GCS-CI-CD/TestsShort/subordinate_0')
job('GCS-CI-CD/TestsShort/display_test_0') {
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
queue('GCS-CI-CD/TestsShort/display_test_0')
job('GCS-CI-CD/TestsShort/module_test_generic_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/module_tests/module_test_generic 0')
   }
}
queue('GCS-CI-CD/TestsShort/module_test_generic_0')
job('GCS-CI-CD/TestsShort/qsub_pty_0') {
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
queue('GCS-CI-CD/TestsShort/qsub_pty_0')
job('GCS-CI-CD/TestsShort/403_0') {
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
queue('GCS-CI-CD/TestsShort/403_0')
job('GCS-CI-CD/TestsShort/ign_sreq_on_mhost_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/pe/ign_sreq_on_mhost 0')
   }
}
queue('GCS-CI-CD/TestsShort/ign_sreq_on_mhost_0')
job('GCS-CI-CD/TestsShort/pe_user_xuser_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/pe/pe_user_xuser 0')
   }
}
queue('GCS-CI-CD/TestsShort/pe_user_xuser_0')
job('GCS-CI-CD/TestsShort/project_access_lists_0') {
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
queue('GCS-CI-CD/TestsShort/project_access_lists_0')
job('GCS-CI-CD/TestsShort/3185_0') {
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
queue('GCS-CI-CD/TestsShort/3185_0')
job('GCS-CI-CD/TestsShort/3185_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/3185 1')
   }
}
queue('GCS-CI-CD/TestsShort/3185_1')
job('GCS-CI-CD/TestsShort/current_version_upgrade_0') {
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
queue('GCS-CI-CD/TestsShort/current_version_upgrade_0')
job('GCS-CI-CD/TestsShort/402_0') {
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
queue('GCS-CI-CD/TestsShort/402_0')
job('GCS-CI-CD/TestsShort/2345_0') {
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
queue('GCS-CI-CD/TestsShort/2345_0')
job('GCS-CI-CD/TestsShort/usage_0') {
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
queue('GCS-CI-CD/TestsShort/usage_0')
job('GCS-CI-CD/TestsShort/usage_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/usage 1')
   }
}
queue('GCS-CI-CD/TestsShort/usage_1')
job('GCS-CI-CD/TestsShort/usage_2') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/functional/usage 2')
   }
}
queue('GCS-CI-CD/TestsShort/usage_2')
job('GCS-CI-CD/TestsShort/2128_0') {
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
queue('GCS-CI-CD/TestsShort/2128_0')
job('GCS-CI-CD/TestsShort/2128_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/bugs/issuezilla/2128 1')
   }
}
queue('GCS-CI-CD/TestsShort/2128_1')
job('GCS-CI-CD/TestsShort/qacct_0') {
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
queue('GCS-CI-CD/TestsShort/qacct_0')
job('GCS-CI-CD/TestsShort/qacct_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/clients/qacct 1')
   }
}
queue('GCS-CI-CD/TestsShort/qacct_1')
job('GCS-CI-CD/TestsShort/1330_0') {
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
queue('GCS-CI-CD/TestsShort/1330_0')
job('GCS-CI-CD/TestsShort/qselect_0') {
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
queue('GCS-CI-CD/TestsShort/qselect_0')
job('GCS-CI-CD/TestsShort/2896_0') {
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
queue('GCS-CI-CD/TestsShort/2896_0')
job('GCS-CI-CD/TestsShort/urgency_0') {
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
queue('GCS-CI-CD/TestsShort/urgency_0')
job('GCS-CI-CD/TestsShort/config_user_xuser_0') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/ocs-testsuite/checktree_gcs/checktree/object/config/config_user_xuser 0')
   }
}
queue('GCS-CI-CD/TestsShort/config_user_xuser_0')
job('GCS-CI-CD/TestsShort/complex_0') {
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
queue('GCS-CI-CD/TestsShort/complex_0')
job('GCS-CI-CD/TestsShort/complex_1') {
   lockableResources {
      label('gcs-ci-cd-cluster')
      resourcesVariable('CLUSTER')
      resourceNumber(1)
   }
   wrappers {
      sshAgent('tstusr-rsa-key')
   }
   steps {
      shell('ssh tstusr@h007 /tools/CS/bin/gcs-ci-cd ${CLUSTER} check /home/tstusr/CS/gcs-ci-cd-0/testsuite/src/checktree/system_tests/qmaster/complex 1')
   }
}
queue('GCS-CI-CD/TestsShort/complex_1')
job('GCS-CI-CD/TestsShort/2328_0') {
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
queue('GCS-CI-CD/TestsShort/2328_0')
job('GCS-CI-CD/TestsShort/1529_0') {
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
queue('GCS-CI-CD/TestsShort/1529_0')
job('GCS-CI-CD/TestsShort/478_0') {
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
queue('GCS-CI-CD/TestsShort/478_0')
job('GCS-CI-CD/TestsShort/2028_0') {
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
queue('GCS-CI-CD/TestsShort/2028_0')
