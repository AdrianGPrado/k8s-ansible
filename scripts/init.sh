#!/bin/bash

# Copyright 2015 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INVENTORY_DIR="${CUR_DIR}/../inventory"
PLAYBOOKS_DIR="${CUR_DIR}/../playbooks"

DEFAULT_INVENTORY=${INVENTORY_DIR}/vagrant_inventory

inventory=${INVENTORY:-${DEFAULT_INVENTORY}}

check_inventory() {
	inv_dir=$(dirname $1)
	if [ ! -e "${inv_dir}/group_vars" ]; then
		echo "Inventory directory ${inv_dir} is missing group_vars directory"
		exit 1
	fi
}

check_if_disable_host_checking() {
	inventory=$1
	if [ "$inventory" == "$DEFAULT_INVENTORY" ]; then
		export ANSIBLE_HOST_KEY_CHECKING=False
	fi
}

check_if_unset_host_checking(){
	inventory=$1
	if [ "$inventory" == "$DEFAULT_INVENTORY" ]; then
		unset ANSIBLE_HOST_KEY_CHECKING
	fi
}

ansible_ping() {
	inventory=$1
	check_inventory ${inventory}
	check_if_disable_host_checking ${inventory} 
	
	ansible all -i ${inventory} -m ping

	check_if_unset_host_checking ${inventory}
}

ansible_playbook() {
	inventory=$1
	check_inventory ${inventory}
	check_if_disable_host_checking ${inventory} 
	
	ansible-playbook -i "$@"
	
	check_if_unset_host_checking ${inventory}

}
