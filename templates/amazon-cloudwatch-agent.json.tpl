{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/opt/jfrog/artifactory/logs/artifactory.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "artifactory.log"
          },
          {
            "file_path": "/var/opt/jfrog/artifactory/logs/access.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "access.log"
          },
          {
            "file_path": "/var/opt/jfrog/artifactory/logs/request.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "request.log"
          },
          {
            "file_path": "/var/opt/jfrog/artifactory/logs/import.export.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "import.export.log"
          }
        ]
      }
    }
  },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}",
      "ImageId": "$${aws:ImageId}",
      "InstanceId": "$${aws:InstanceId}",
      "InstanceType": "$${aws:InstanceType}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    },
    "namespace": "${namespace}"
  }
}
