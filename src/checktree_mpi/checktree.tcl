#___INFO__MARK_BEGIN_NEW__
###########################################################################
#
#  Copyright 2025 HPC-Gridware GmbH
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#___INFO__MARK_END_NEW__

global ts_checktree mpi_config
global CHECK_DEFAULTS_FILE
global mpi_checktree_nr
global ACT_CHECKTREE

ts_source $ACT_CHECKTREE/config

set mpi_config(initialized) 0
set mpi_checktree_nr $ts_checktree($ACT_CHECKTREE)

set ts_checktree($mpi_checktree_nr,setup_hooks_0_name)         "MPI configuration"
set ts_checktree($mpi_checktree_nr,setup_hooks_0_config_array) mpi_config
set ts_checktree($mpi_checktree_nr,setup_hooks_0_init_func)    mpi_init_config
set ts_checktree($mpi_checktree_nr,setup_hooks_0_verify_func)  mpi_verify_config
set ts_checktree($mpi_checktree_nr,setup_hooks_0_save_func)    mpi_save_configuration
set ts_checktree($mpi_checktree_nr,setup_hooks_0_filename)     [get_additional_config_file_path "mpi"]
set ts_checktree($mpi_checktree_nr,setup_hooks_0_version)      "1.0"

set ts_checktree($mpi_checktree_nr,start_runlevel_hooks_0)   "mpi_test_run_level_check"

#set ts_checktree($mpi_checktree_nr,required_hosts_hook)    ""

proc mpi_test_run_level_check {is_starting was_error} {
   # anything to do?
   return 0
}
