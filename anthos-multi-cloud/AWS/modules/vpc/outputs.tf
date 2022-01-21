/**
 * Copyright 2022 Google LLC
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

output "aws_vpc_id" {
  description = "ARN of the actuated KMS key resource for cluster secret encryption"
  value       = aws_vpc.this.id
}
output "aws_cp_subnet_id_1" {
  description = "private subnet ID of control plane 1"
  value       = aws_subnet.private_cp[0].id
}

output "aws_cp_subnet_id_2" {
  description = "private subnet ID of control plane 2"
  value       = aws_subnet.private_cp[1].id
}
output "aws_cp_subnet_id_3" {
  description = "private subnet ID of control plane 3"
  value       = aws_subnet.private_cp[2].id
}
