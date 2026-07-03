/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
* Made to resemble:
*
* gcloud compute instance-groups managed create example-bulk-igm \
* --target-size-policy-mode=bulk \
* --template=example-template \
* --zone=us-central1-ir1
*
* gcloud compute instance-groups managed create-instance example-bulk-igm \
* --instance per-instance-config-instance-1, per-instance-config-instance-2 \
* --zone us-central1-a
*/

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.39.0"
    }
  }
}

# [START compute_bulk_per_instance_config_parent_tag]
resource "google_compute_instance_template" "default" {
  name         = "example-template"
  machine_type = "e2-medium"

  scheduling {
    provisioning_model          = "FLEX_START"
    on_host_maintenance         = "TERMINATE"
    instance_termination_action = "DELETE"
    max_run_duration {
      seconds = 7200
      nanos   = 0
    }
  }

  disk {
    source_image = "debian-cloud/debian-12"
  }

  network_interface {
    network = "default"
  }
}

# [START compute_bulk_per_instance_config_tag]
resource "google_compute_instance_group_manager" "default" {
  name               = "example-bulk-igm"
  zone               = "us-central1-a"
  base_instance_name = "example-bulk-igm"

  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size_policy {
    mode = "BULK"
  }

  lifecycle {
    # Bulk per-instance configs manage the number of instances, so ignore target_size changes.
    ignore_changes = [target_size]
  }
}

resource "google_compute_bulk_per_instance_config" "default" {
  zone                   = google_compute_instance_group_manager.default.zone
  instance_group_manager = google_compute_instance_group_manager.default.name

  instances {
    name = "per-instance-config-instance-1"
  }

  instances {
    name = "per-instance-config-instance-2"
  }
}
# [END compute_bulk_per_instance_config_tag]
# [END compute_bulk_per_instance_config_parent_tag]
