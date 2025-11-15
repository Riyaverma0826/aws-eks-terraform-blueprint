data "http" "efs_csi_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/master/docs/iam-policy-example.json"

  request_headers = {
    Accept = "application/json"
  }
}


output "efs_csi_policy_json_preview" {
  description = "Preview of downloaded EFS CSI IAM policy JSON"
  value       = substr(data.http.efs_csi_iam_policy.response_body, 0, 300)
}
