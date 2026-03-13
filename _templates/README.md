# Terragrunt templates for each resource type.
# The Lambda uses these as the basis for the terragrunt.hcl files
# it creates under environments/<project>/<resource_type>/
#
# Each template:
#   1. Includes the root terragrunt.hcl (remote state + provider)
#   2. Points terraform.source at the matching module
#   3. Reads resources.yaml and passes it as inputs
#   4. Declares dependency blocks for cross-resource references
